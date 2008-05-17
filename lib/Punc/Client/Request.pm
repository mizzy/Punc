package Punc::Client::Request;

use Moose;
use JSON;
use JSON::RPC::Client;
use Punc::Client::Response;
use File::Spec;

our $AUTOLOAD;

use Moose;

has 'conf'   => ( is => 'rw', isa => 'HashRef' );
has 'hosts'  => ( is => 'rw', isa => 'ArrayRef' );
has 'module' => ( is => 'rw', isa => 'Str' );
has 'method' => ( is => 'rw', isa => 'Str' );
has 'args'   => ( is => 'rw', isa => 'HashRef' );

has 'client' => (
    is      => 'rw',
    isa     => 'JSON::RPC::Client',
    default => sub { JSON::RPC::Client->new },
);

sub init {
    my ( $self, $args ) = @_;

    my $confdir = $self->conf->{confdir};

    $ENV{HTTPS_VERSION}   = 3;
    $ENV{HTTPS_CERT_FILE} = File::Spec->catfile(
        $confdir, 'ssl', 'ca', 'ca.cert'
    );
    $ENV{HTTPS_KEY_FILE}  = File::Spec->catfile(
        $confdir, 'ssl', 'ca', 'ca.key'
    );

    return $self;
};

sub request {
    my $self = shift;

    my $response = Punc::Client::Response->new;
    for my $host ( @{ $self->hosts } ) {

        my $url     = "https://$host:7080/$self->{module}";
        my $callobj = {
            method  => $self->method,
            params  => $self->args,
        };

        my $res = $self->client->call($url, $callobj) or warn @?;

        if( $res ) {
            $response->add({
                host     => $host,
                response => $res->content,
            });
        }
    }

    return $response;
}

sub AUTOLOAD {
    no strict 'refs';
    my ( $self, $args ) = @_;
    (my $method = $AUTOLOAD) =~ s/^.*:://;
    return if $method eq 'DESTROY';

    $self->method($method);
    $self->args($args);

    if ( $self->module eq 'file' and $self->method eq 'copy' ) {
        open my $fh, '<', $args->{src} or die $!;
        $args->{content} = do { local $/; <$fh> };
        close $fh;
    }

    return $self->request;
}

1;
