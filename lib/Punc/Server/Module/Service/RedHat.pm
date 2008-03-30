package Punc::Server::Module::Service::RedHat;

use base qw( Punc::Server::Module::Service );

sub status {
    my ( $self, $args ) = @_;

    return $self->_command($args->[0], 'status');
}

sub _command {
    my ( $self, $service, $command ) = @_;
    if ( -f "/etc/init.d/$service" ) {
        `/sbin/service $service status`;
        return $?;
    }
    else {
        ## TODO: エラー時に何を返すか考える
    }
}

1;
