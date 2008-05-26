package Punc::Master::Daemon;

use Moose;
use File::Spec;
use File::Path;
use Punc::Master::CA;
use Crypt::OpenSSL::CA;
use Crypt::OpenSSL::RSA;

extends 'Punc::Daemon';
with    'Punc::Daemon::Role';

has 'ca' => (
    is      => 'rw',
    isa     => 'Punc::Master::CA',
    default => sub {
        Punc::Master::CA->new({
            ssldir => File::Spec->catdir(shift->confdir, 'ssl'),
        });
      },
    lazy    => 1,
);

has 'ssl_key' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catfile(shift->ca->cadir, 'ca.key') },
    lazy    => 1,
);

has 'ssl_cert' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catfile(shift->ca->cadir, 'ca.cert') },
    lazy    => 1,
);

before 'run' => sub {
    my $self = shift;
    $self->_find_or_create_ca_cert($self->context);
};

sub _find_or_create_ca_cert {
    my ( $self, $c ) = @_;
    my $cadir = $self->ca->cadir;
    unless ( -d $cadir ) {
        mkpath($cadir);
        chmod oct('0700'), $cadir;
    }

    my $cert = File::Spec->catfile($cadir, 'ca.cert');
    unless ( -f $cert ) {
        $self->_create_self_signed_cert($c);
    }
}

sub _create_self_signed_cert {
    my ( $self, $c ) = @_;

    # 鍵作成
    my $rsa = Crypt::OpenSSL::RSA->generate_key(1024);
    open my $out, '>', File::Spec->catfile($self->ca->cadir, 'ca.key') or die $!;
    print $out $rsa->get_private_key_string;
    close $out;

    my $privkey = Crypt::OpenSSL::CA::PrivateKey->parse($rsa->get_private_key_string);
    my $pubkey  = $privkey->get_public_key;

    # 自己署名証明書作成
    my $dn   = Crypt::OpenSSL::CA::X509_NAME->new( CN => $c->fact('fqdn') );
    my $x509 = Crypt::OpenSSL::CA::X509->new($pubkey);

    $x509->set_serial('0x00');
    $x509->set_subject_DN($dn);
    $x509->set_issuer_DN($dn);

    ### TODO: 有効期限をきちんと
    $x509->set_notBefore('20080101000000Z');
    $x509->set_notAfter('20090101000000Z');

    my $pem = $x509->sign($privkey, 'sha1');
    open my $cert, '>', File::Spec->catfile($self->ca->cadir, 'ca.cert') or die $!;
    print $cert $pem;
    close $cert;

    open my $srl, '>', File::Spec->catfile($self->ca->cadir, 'ca.srl') or die $!;
    print $srl '01';
    close $srl;
}


sub handle_request {
    my ( $self, $module, $method, $args ) = @_;

    # CSR 取得
    my $csr = $args->{csr};
    my $hostname = $self->ca->get_hostname_from_csr($csr);

    my $csrdir = $self->ca->csrdir;
    mkpath($csrdir) unless -d $csrdir;

    $self->ca->save_csr($csr);

    my $autosign = $self->{conf}->{autosign} || '';
    $autosign =~ s/\*/\.\*/g;
    if ( $hostname =~ /$autosign/ ) {
        $self->{ca}->sign($hostname);
    }
    else {
        while ( 1 ) {
            last if $self->{ca}->is_signed($csr);
            sleep 1;
        }
    }

    open my $cert_fh, '<', File::Spec->catfile(
        $self->ca->certdir,
        "${hostname}.cert"
    ) or do { return { error => $! } };

    my $cert = do { local $/; <$cert_fh> };
    close $cert_fh;

    open my $cacert_fh, '<', File::Spec->catfile(
        $self->ca->cadir,
        'ca.cert'
    ) or do { return { error => $! } };

    my $cacert = do { local $/; <$cacert_fh> };
    close $cacert_fh;

    return { result => { cert => $cert, cacert => $cacert } };
}


1;
