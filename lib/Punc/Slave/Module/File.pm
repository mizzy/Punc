package Punc::Slave::Module::File;

use strict;
use warnings;

use Punc::Slave::Module { operatingsystem => [ qw/ .* / ] };

sub md5sum {
    my ( $self, $args ) = @_;
    return `md5sum $args->{file}`;
}

sub copy {
    my ( $self, $args ) = @_;
    my $dest = $args->{dest} || $args->{src};
    open my $fh, '>', $dest or die $!;
    print $fh $args->{content};
    close $fh;
    return;
}

1;

__END__

=head1 NAME

Punc::Slave::Module::File - Punc module for file control.

=head1 SYNOPSIS

  # with punc command
  # md5sum
  $ sudo punc "*" call file md5sum --file=/path/to/file

  # file copy
  $ sudo punc "*" call file copy --src=/path/to/source --dest=/path/to/dest

  # with Punc::Client module
  my $punc = Punc::Client->new($target);

  # md5sum
  my $res  = $punc->file->md5sum({ file => '/path/to/file' });

  # file copy
  my $res  = $punc->file->copy({ src => '/path/to/source', dest => '/path/to/dest' });


=head1 DESCRIPTION

Punc::Slave::Module::File is the Punc module for file control.

=head1 METHODS

=head2 md5sum

Show md5sum of a file.

=cut
