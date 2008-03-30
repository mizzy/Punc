package Punc::Server::Module::Service;

use strict;
use warnings;
use base qw( Punc::Server::Module );
use UNIVERSAL::require;

sub new {
    my $class = shift;
    my $provider = get_provider();
    $class = "${class}::${provider}";
    $class->require or die $@;
    bless {}, $class;
}

my %provider_map = (
    'centos|fedora' => 'RedHat',
);

sub get_provider {
    my $os = `facter operatingsystem`;

    for ( keys %provider_map ) {
        return $provider_map{$_} if $os =~ /$_/i;
    }

    return 'RedHat' # default;
}

sub status {
    die;
}


1;

__END__

=encoding utf8

=head1 NAME

Punc::Server::Module::Service - Punc module for service control.

=head1 SYNOPSIS

  # with punc command
  $ sudo punc "*" call service status httpd

  # with Punc::Client module
  my $punc = Punc::Client->new($target);
  my $res = $punc->service->status('httpd');

=head1 DESCRIPTION

Punc::Server::Module::Service is the Punc module for service control.

=head1 METHODS

=head2 status

Show service status.

=cut
