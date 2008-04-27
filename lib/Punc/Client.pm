package Punc::Client;

use strict;
use warnings;
our $VERSION = '0.01';
our $AUTOLOAD;
use Punc::ConfigLoader;
use Punc::Client::Request;
use UNIVERSAL::require;
use FindBin;
use UNIVERSAL::require;

sub new {
    my ( $class, $target ) = @_;

    $target =~ s/\*/\.\*/g;

    ### TODO: confdir のデフォルト値を変更
    my $confdir = "$FindBin::Bin/../etc";
    my $yaml    = File::Spec->catfile($confdir, 'punc.yaml');
    my $conf    = -f $yaml ? Punc::ConfigLoader->new->load($yaml) : {};
    $conf->{confdir} = $confdir;

    my $hosts_class = ucfirst $conf->{hosts_class} || 'File';
    $hosts_class = "Punc::Hosts::$hosts_class";
    $hosts_class->require;
    my $hosts = $hosts_class->get_hosts({ target => $target, conf => $conf });

    bless {
        hosts => $hosts,
        conf  => $conf,
    }, $class;
}

sub AUTOLOAD {
    no strict 'refs';
    my $self = shift;
    (my $module = $AUTOLOAD) =~ s/^.*:://;
    return if $module eq 'DESTROY';

    return Punc::Client::Request->new({
        conf   => $self->{conf},
        hosts  => $self->{hosts},
        module => $module,
    });
}

1;
__END__

=encoding utf8

=head1 NAME

Punc -

=head1 SYNOPSIS

  use Punc;

=head1 DESCRIPTION

Punc is

=head1 AUTHOR

Gosuke Miyashita E<lt>gosukenator@gmail.comE<gt>

=head1 SEE ALSO

=head1 REPOSITORY

  svn co http://svn.coderepos.org/share/lang/perl/Punc/trunk Punc

Punc is Subversion repository is hosted at L<http://coderepos.org/share/>.
patches and collaborators are welcome.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
