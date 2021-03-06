package Punc::Slave::Module::Service::RedHat;

use Punc::Slave::Module::Service { operatingsystem => [ qw / redhat centos fedora / ] };
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
        return $self->error("no such service: $service");
    }
}

1;
