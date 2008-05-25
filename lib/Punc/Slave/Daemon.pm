package Punc::Slave::Daemon;

use Moose;
use File::Spec;
use Crypt::OpenSSL::PKCS10 qw( :const );
use JSON::RPC::Client;
use JSON;
use File::Path;

extends 'Punc::Daemon';
with 'Punc::Daemon::Role';

has 'ssldir' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catdir(shift->confdir, 'ssl') },
    lazy    => 1,
);

has 'keydir'  => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catdir(shift->ssldir, 'keys') },
    lazy    => 1,
);

has 'csrdir'  => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catdir(shift->ssldir, 'csrs') },
    lazy    => 1,
);

has 'certdir' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catdir(shift->ssldir, 'certs') },
    lazy    => 1,
);

has 'fqdn'    => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { Punc->context->fact('fqdn') },
);

has 'ssl_key' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        File::Spec->catfile($self->keydir, $self->fqdn . '.key');
    },
    lazy    => 1,
);

has 'ssl_cert' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        File::Spec->catfile($self->certdir, $self->fqdn . '.cert');
    },
    lazy    => 1,
);

has 'ca_cert' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catfile(shift->certdir, 'ca.cert'); },
    lazy    => 1,
);

before 'run' => sub {
    my $self = shift;
    $self->_find_or_request_cert($self->context);
};

sub _find_or_request_cert {
    my ( $self, $c ) = @_;

    mkpath($self->certdir) unless -d $self->certdir;
    mkpath($self->csrdir) unless -d $self->csrdir;
    unless ( -d $self->keydir ) {
        mkpath($self->keydir);
        chmod oct('0700'), $self->keydir;
    }

    my $cert = File::Spec->catfile($self->certdir, $c->fact('fqdn') . '.cert');
    unless ( -f $cert ) {
        $self->_request_cert($c);
    }
}

sub _request_cert {
    my ( $self, $c ) = @_;

    my $req  = Crypt::OpenSSL::PKCS10->new;
    my $fqdn = $c->fact('fqdn');
    $req->set_subject("/CN=$fqdn");
    $req->sign();

    $req->write_pem_req( File::Spec->catfile( $self->csrdir, "${fqdn}.csr" ) );
    $req->write_pem_pk( File::Spec->catfile( $self->keydir, "${fqdn}.key" ) );

    my $client = JSON::RPC::Client->new;
    $client->ua->timeout(0);
    my $host   = $self->conf->{puncmaster_host} || 'localhost';
    my $port   = $self->conf->{puncmaster_port} || 7081;
    my $url    = "https://$host:$port/cert";

    my $callobj = {
        method  => 'request',
        params  => { csr => $req->get_pem_req() },
    };

    my $res = $client->call($url, $callobj);

    if( $res ) {
        my $cert = $res->content->{result}->{cert};
        open my $cert_fh, '>', File::Spec->catfile($self->{certdir}, "${fqdn}.cert")
            or die $!;
        print $cert_fh $cert;
        close $cert_fh;

        my $cacert = $res->content->{result}->{cacert};
        open my $cacert_fh, '>', File::Spec->catfile($self->{certdir}, 'ca.cert')
            or die $!;
        print $cacert_fh $cacert;
        close $cacert_fh;
    }
    else {
        warn 'error';
    }
}

sub handle_request {
    my ( $self, $module, $method, $args ) = @_;

    $module = ucfirst $module;
    $module = "Punc::Slave::Module::$module";
    $module->require or do { return { error => "no such module: $module" } };

    my $res;
    if ( $method eq 'description' || $method eq 'desc' ) {
        $res = $module->description;
    }
    else {
        my $obj = $module->new;
        my $module_to_delegate = $obj->delegate;
        if ( $module_to_delegate ) {
            $res = $module_to_delegate->$method($args);
            if ( defined $res ) {
                $res = { result => $res };
            } else {
                $res = { error => $module_to_delegate->errstr };
            }
        }
        else {
            Punc->context->log( error => $obj->errstr );
            return { error => $obj->errstr };
        }
    }

    return $res;
}

1;
