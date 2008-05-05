package Punc::Slave::Module::Service::RedHat;

use strict;
use warnings;
use Punc::Slave::Module::Service { operatingsystem => [ qw / redhat fedora centos / ] };
use Moose;

with 'Punc::Slave::Module::Service::Role';

sub status {
    my ( $self, $args ) = @_;
    return $self->_command($args->{service}, 'status');
}

sub _command {
    my ( $self, $service, $command ) = @_;
    if ( -f "/etc/init.d/$service" ) {
        `/sbin/service $service $command`;
        return $?;
    }
    else {
        ## TODO: エラー時に何を返すか考える
    }
}

1;
