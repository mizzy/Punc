package Punc::Slave::Module;

use Moose;
use Module::Pluggable;
use Class::MakeMethods ( 'Standard::Inheritable:scalar' => 'default_for' );

sub import {
    my ( $class, $args ) = @_;
    my $pkg = caller(0);
    no strict 'refs';
    unshift @{"$pkg\::ISA"}, $class;
    $pkg->default_for($args);
}

sub delegate {
    my $self = shift;
    $self->search_path( new => ref $self );
    my @modules = ( $self->plugins, ref $self );
    my $module_to_delegate;
    for my $module ( @modules ) {
        next if $module =~ /Role$/;
        $module->require or do {
            return $self->error($@);
        };
        my $default_for = $module->default_for;
        next unless $default_for;
        my ( $fact ) = keys %$default_for;
        if ( grep { Punc->context->fact($fact) =~ /$_/i } @{ $default_for->{$fact} } ) {
            $module_to_delegate = $module;
            last;
        }
    }

    if ( $module_to_delegate ) {
        Punc->context->log( info => "Delegated to $module_to_delegate." );
        bless $self, $module_to_delegate;
    }
    else {
        return $self->error('Could not find a module to delegate.');
    }
}

sub description {
    my $class = shift;
    return { result => `perldoc -t $class` || '' };
}

# code from Class::ErrorHandler
use vars qw( $ERROR );

sub error {
    my $msg = $_[1] || '';
    if (ref($_[0])) {
        $_[0]->{_errstr} = $msg;
    } else {
        $ERROR = $msg;
    }
    return;
}

sub errstr {
    ref($_[0]) ? $_[0]->{_errstr} : $ERROR
}

1;
