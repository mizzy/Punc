package Punc::Client::Response;

use Moose;
use Punc::Client::Result;

has 'index' => ( isa => 'Int', is => 'rw', default => 0 );

has 'results' => (
    isa     => 'ArrayRef[Punc::Client::Result]',
    is      => 'rw',
    default => sub { [] },
);

sub add {
    my ( $self, $args ) = @_;
    push @{$self->results}, Punc::Client::Result->new($args);
}

sub next {
    my $self = shift;
    my $current = $self->results->[ $self->index ];
    $self->index( $self->index + 1 );
    return $current;
}

1;
