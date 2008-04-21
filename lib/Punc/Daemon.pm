package Punc::Daemon;

use strict;
use warnings;

use HTTP::Daemon::SSL;
use HTTP::Status;
use JSON;
use UNIVERSAL::require;

sub new {
    my ( $class, $args ) = @_;

    my $self = {
        %$args,
    };

    bless $self, $class;
}

sub run {
    my $self = shift;
    my $d = HTTP::Daemon::SSL->new(
        LocalPort      => $self->{port},
        ReuseAddr      => 1,
        SSL_key_file   => $self->{ssl_key},
        SSL_cert_file  => $self->{ssl_cert},
    ) || die $!;

    print "Please contact me at: <URL:", $d->url, ">\n";
    while ( my $c = $d->accept ) {
        while ( my $r = $c->get_request ) {
            my $module = $r->url->path;
            $module =~ s!^/!!;
            my $content = JSON::from_json($r->content);
            my $result  = $self->handle_request(
                $module,
                $content->{method},
                $content->{params},
            );

            my $json = to_json({
                result => $result,
                error  => undef,
            });

            my $response = HTTP::Response->new;
            $response->content($json);
            $c->send_response($response);
        }
        $c->close;
        undef($c);
    }
}

1;
