package Punc::Logger::StdErr;

use Moose;

extends 'Punc::Logger';
with 'Punc::Logger::Role';

sub log {
    my ( $self, $level, $message ) = @_;
    warn "[$level] $message\n";
}

1;
