package Punc::Util;

use strict;
use warnings;
use Pfacter;
use UNIVERSAL::require;

sub fact {
    my ( $class, $fact ) = @_;
    my $self = bless {}, $class;

    foreach ( qw( kernel operatingsystem hostname domain ) ) {
        $self->{'pfact'}->{$_} = $self->_pfact( $_ );
    }

    return $self->_pfact($fact);
}

sub _pfact {
    my $self   = shift;
    my $module = shift;

    return $self->{'pfact'}->{lc( $module )}
        if $self->{'pfact'}->{lc( $module )};

    $module = 'Pfacter::' . lc $module;
    $module->require or die $@;

    my $pfact = $module->pfact($self);
    chomp $pfact;
    return $pfact;
}

1;
