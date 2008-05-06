package Punc::Slave::Module::Service;

use Moose;
extends 'Punc::Slave::Module';

package Punc::Slave::Module::Service::Role;
use Moose::Role;
requires 'status';

1;

__END__

=head1 NAME

Punc::Slave::Module::Service - Punc module for service control.

=head1 SYNOPSIS

  # with punc command
  $ sudo punc "*" call service status --service=httpd

  # with Punc::Client module
  my $punc = Punc::Client->new($target);
  my $res  = $punc->service->status({ service => 'httpd' });

=head1 DESCRIPTION

Punc::Slave::Module::Service is the Punc module for service control.

=head1 METHODS

=head2 status({ service => 'service name' })

Show service status.


=cut
