package Punc::Client;

use strict;
use warnings;
our $VERSION = '0.01';
our $AUTOLOAD;
use Punc::Client::Request;
use UNIVERSAL::require;
use FindBin;

sub new {
    my ( $class, $target ) = @_;

    ### TODO: confdir のデフォルト値を変更
    ## TODO: $target から対象ホストをリストアップ

    bless {
        hosts   => [ $target ],
        confdir => "$FindBin::Bin/../etc",
    }, $class;
}

sub AUTOLOAD {
    no strict 'refs';
    my $self = shift;
    (my $module = $AUTOLOAD) =~ s/^.*:://;
    return if $module eq 'DESTROY';

    return Punc::Client::Request->new({
        confdir => $self->{confdir},
        hosts   => $self->{hosts},
        module  => $module,
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
