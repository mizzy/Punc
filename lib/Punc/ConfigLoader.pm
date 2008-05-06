package Punc::ConfigLoader;

use strict;
use warnings;
use YAML;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub load {
    my ( $self, $file ) = @_;
    my $config = YAML::LoadFile($file) or Punc->context->log( error => $! );
    return $config || {};
}

1;
