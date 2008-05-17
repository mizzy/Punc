package Punc::Client::Result;

use Moose;
our $AUTOLOAD;

has 'response' => ( is => 'rw' );

sub result {
    shift->{response}->{result};
}

sub error {
    shift->{response}->{error};
}

sub as_hash {
  my $self = shift;
  my %hash = %$self;
  return \%hash;
}

sub AUTOLOAD {
    no strict 'refs';
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/^.*:://;
    return if $method eq 'DESTROY';

    return $self->response->{result}->{$method};
}

1;
