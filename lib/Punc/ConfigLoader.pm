package Punc::ConfigLoader;

use Moose;
use YAML;

sub load {
    my ( $self, $file ) = @_;
    my $config = YAML::LoadFile($file) or Punc->context->log( error => $! );
    return $config || {};
}

1;
