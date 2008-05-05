package Punc::Slave::Module::Punc;

use strict;
use warnings;
use Path::Class qw( dir );
use Punc::Slave::Module { operatingsystem => [ qw/ .* / ] };

sub info {
    my ( $self, $args ) = @_;

    return { punc_path => dir(`perldoc -l Punc`)->parent->stringify };
}

1;
