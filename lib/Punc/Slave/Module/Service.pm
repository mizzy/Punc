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

Show service status.Following return values are expected.

=over

=item result: 0

Service is alive.

=item result: not 0

Service is dead.

=item error: error string

Error occurs.(e.g.: Service does not exist.)

=back

=cut
