package Punc::Client::Response;

use strict;
use warnings;
use Punc::Client::Result;

sub new {
    my $self = {
        index => 0,
        results => [],
    };
    bless $self, shift;
}

sub add {
    my ( $self, $args ) = @_;
    push @{$self->{results}}, Punc::Client::Result->new($args);
}

sub next {
    my $self = shift;
    return $self->{results}->[ $self->{index}++ ];
}

1;
