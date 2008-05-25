package Punc::Daemon;

use Moose;

use HTTP::Daemon::SSL;
use HTTP::Status;
use JSON;
use UNIVERSAL::require;

has 'port'     => ( is => 'rw', isa => 'Int' );
has 'confdir'  => ( is => 'rw', isa => 'Str' );
has 'conf'     => ( is => 'rw', isa => 'HashRef' );
has 'context'  => ( is => 'rw', isa => 'Punc' );
has 'ssl_key'  => ( is => 'rw', isa => 'Str' );
has 'ssl_cert' => ( is => 'rw', isa => 'Str' );
has 'ca_cert'  => ( is => 'rw', isa => 'Str' );

sub run {
    my $self = shift;

    my $ssl_verify_mode = ref $self eq 'Punc::Master::Daemon' ? 0x00 : 0x07;

    my $d = HTTP::Daemon::SSL->new(
        LocalPort       => $self->port,
        ReuseAddr       => 1,
        SSL_key_file    => $self->ssl_key,
        SSL_cert_file   => $self->ssl_cert,
        SSL_ca_file     => $self->ca_cert || '',
        SSL_verify_mode => $ssl_verify_mode,
    );

    print "Please contact me at: <URL:", $d->url, ">\n";
    while ( my $c = $d->accept ) {
        while ( my $r = $c->get_request ) {
            my $module = $r->url->path;
            $module =~ s!^/!!;
            my $content = JSON::from_json($r->content);
            my $res = $self->handle_request(
                $module,
                $content->{method},
                $content->{params},
            );

            Punc->context->log( error => $res->{error} ) if $res->{error};

            my $json = to_json({
                result => $res->{result},
                error  => $res->{error},
            });

            my $response = HTTP::Response->new;
            $response->content($json);
            $c->send_response($response);
        }
        $c->close;
        undef($c);
    }
}

package Punc::Daemon::Role;

use Moose::Role;

requires 'handle_request';

1;
