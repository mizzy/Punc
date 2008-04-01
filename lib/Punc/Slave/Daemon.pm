package Punc::Slave::Daemon;

use strict;
use warnings;

use HTTP::Daemon;
use HTTP::Status;
use JSON;
use UNIVERSAL::require;

sub start_daemon {
    my $d = HTTP::Daemon->new( LocalPort => 7080, ReuseAddr => 1 ) || die;

    print "Please contact me at: <URL:", $d->url, ">\n";
    while ( my $c = $d->accept ) {
        while ( my $r = $c->get_request ) {
            my $module = $r->url->path;
            $module =~ s!^/!!;
            my $content = JSON::from_json($r->content);
            my $result  = dispatch_request($module, $content->{method}, $content->{params});

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

sub dispatch_request {
    my ( $module, $method, $args ) = @_;

    $module = ucfirst $module;
    $module = "Punc::Slave::Module::$module";
    $module->require or die $@;

    my $res;
    if ( $method eq 'description' ) {
        $res = $module->description;
    }
    else {
        my $obj = $module->new;
        $res = $obj->exec($method, $args);
    }

    return $res;
}

1;
