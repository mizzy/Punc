package Punc::Client::Request;

use strict;
use warnings;
use JSON;
use JSON::RPC::Client;
use Punc::Client::Response;
our $AUTOLOAD;

sub new {
    my ( $class, $args ) = @_;
    bless $args, $class;
}

sub request {
    my $self = shift;

    my $response = Punc::Client::Response->new;
    for my $host ( @{ $self->{hosts} } ) {
        my $client = new JSON::RPC::Client;
        my $url    = "https://$host:7080/$self->{module}";
        my $callobj = {
            method  => $self->{method},
            params  => $self->{args},
        };

        my $res = $client->call($url, $callobj);

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
