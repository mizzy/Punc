package Punc::Slave::Module::Service;

use strict;
use warnings;
use base qw( Punc::Slave::Module );
use UNIVERSAL::require;

sub status {
    die;
}


1;

__END__

=encoding utf8

=head1 NAME

Punc::Slave::Module::Service - Punc module for service control.

=head1 SYNOPSIS

  # with punc command
  $ sudo punc "*" call service status httpd

  # with Punc::Client module
  my $punc = Punc::Client->new($target);
  my $res = $punc->service->status('httpd');

=head1 DESCRIPTION

Punc::Slave::Module::Service is the Punc module for service control.

=head1 METHODS

=head2 status

Show service status.

=cut
