package Punc::Slave::Module::Service::Debian;

use strict;
use warnings;
use Punc::Slave::Module::Service { operatingsystem => [ qw / debian ubuntu / ] };
use Moose;

with 'Punc::Slave::Module::Service::Role';


sub status {
    my ( $self, $args ) = @_;

    return $self->_command($args->{service}, 'status');
}

sub _command {
    my ( $self, $service, $command ) = @_;
    if ( -f "/etc/init.d/$service" ) {
        # TODO: これじゃほんとはだめ。
        # サービス名 = プロセス名を仮定しているので。
        `start-stop-daemon --stop --test --name $service`;
        return { result => $? }; # TODO: $? >> 8 を返した方がいい？
    }
    else {
        return { error => "no such service: $service" };
    }
}

1;
