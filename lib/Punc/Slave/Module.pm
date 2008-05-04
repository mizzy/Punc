package Punc::Slave::Module;

use strict;
use warnings;
use Punc::Util;
use Moose;
use MooseX::ClassAttribute;
use Module::Pluggable;

class_has 'default_for' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

sub import {
    my ( $class, $args ) = @_;
    my $pkg = caller(0);
    no strict 'refs';
    unshift @{"$pkg\::ISA"}, $class;
    $pkg->default_for($args);
}

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->delegate;
}

sub delegate {
    my $self = shift;

    $self->search_path( new => ref $self );
    my @modules = $self->plugins;
    my $module_to_delegate;
    for my $module ( @modules ) {
        next if $module =~ /Role$/;
        $module->require or die $@;
        my $default_for = $module->default_for;
        next unless $default_for;
        my ( $fact ) = keys %$default_for;
        if ( grep { Punc::Util->fact($fact) =~ /$_/i } @{ $default_for->{$fact} } ) {
            $module_to_delegate = $module;
        }
    }

    bless $self, $module_to_delegate;
}

sub exec {
    my ( $self, $method, $args ) = @_;
    $self->$method($args);
}

sub description {
    my $class = shift;
    return `perldoc -t $class`;
}

1;
