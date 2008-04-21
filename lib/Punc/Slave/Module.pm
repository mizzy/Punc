package Punc::Slave::Module;

use strict;
use warnings;
use Module::Pluggable;
use Punc::Util;

sub new {
    my $class = shift;
    $class->search_path( new => $class );

    my @modules = $class->plugins;
    for my $module ( @modules ) {
        $module->require or die $@;
        my $default_for = $module->default_for;
        next unless $default_for;

        my ( $fact ) = keys %$default_for;
        if ( grep { Punc::Util->fact($fact) =~ /$_/i } @{ $default_for->{$fact} } ) {
            $class = $module;
        }
    }

    bless {}, $class;
}

sub default_for { }

sub exec {
    my ( $self, $method, $args ) = @_;
    $self->$method($args);
}

sub description {
    my $class = shift;
    return `perldoc -t $class`;
}

1;
