package Punc::Client::Response;

use strict;
use warnings;

sub new {
    bless [], shift;
}

sub add {
    my ( $self, $args ) = @_;
    push @$self, $args;
}

1;
