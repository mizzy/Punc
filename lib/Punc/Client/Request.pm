package Punc::Client::Request;

use strict;
use warnings;
use JSON;
use JSON::RPC::Client;
use Punc::Client::Response;
use File::Spec;

our $AUTOLOAD;

sub new {
    my ( $class, $args ) = @_;

    my $confdir = $args->{conf}->{confdir};

    $ENV{HTTPS_VERSION}   = 3;
    $ENV{HTTPS_CERT_FILE} = File::Spec->catfile(
        $confdir, 'ssl', 'ca', 'ca.cert'
    );
    $ENV{HTTPS_KEY_FILE}  = File::Spec->catfile(
        $confdir, 'ssl', 'ca', 'ca.key'
    );

    $args->{client} = JSON::RPC::Client->new;

    bless $args, $class;
}

sub request {
    my $self = shift;

    my $response = Punc::Client::Response->new;
    for my $host ( @{ $self->{hosts} } ) {

        my $url     = "https://$host:7080/$self->{module}";
        my $callobj = {
            method  => $self->{method},
            params  => $self->{args},
        };

        my $res = $self->{client}->call($url, $callobj) or warn @?;

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

    $self->{method} = $method;
    $self->{args}   = $args;
    return $self->request;
}

1;
