package Punc::Client::Result;

use strict;
use warnings;
our $AUTOLOAD;

sub new {
    my ( $class, $args ) = @_;
    bless $args, $class;
}

sub as_hash {
  my $self = shift;
  my %hash = %$self; 
  return \%hash;
}

sub result {
    my $self = shift;
    return $self->{response}->{result};
}

sub error {
    my $self = shift;
    return $self->{response}->{error};    
}

sub AUTOLOAD {
    no strict 'refs';
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/^.*:://;
    return if $method eq 'DESTROY';

    return $self->{response}->{result}->{$method};
}

1;
