package Punc::Server::Module;

use strict;
use warnings;
use Pod::Text;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub exec {
    my ( $self, $method, $args ) = @_;
    $self->$method($args);
}

sub description {
    my $class = shift;
    my $parser = Pod::Text->new;
    return `perldoc -t $class`;
}

1;
