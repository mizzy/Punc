package Punc::Client::Response;

sub new {
    bless [], shift;
}

sub add {
    my ( $self, $args ) = @_;
    push @$self, $args;
}

1;
