package Punc::Slave::Module::Service;

use strict;
use warnings;

use Moose;

extends 'Punc::Slave::Module';

package Punc::Slave::Module::Service::Role;
use Moose::Role;
requires 'status';

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
