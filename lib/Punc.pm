package Punc;

use strict;
use warnings;
our $VERSION = '0.01';

use Pfacter;
use UNIVERSAL::require;

my $context;
sub context {
    $context = $_[1] if $_[1];
    return $context;
}

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->context($self);
}

sub fact {
    my ( $self, $fact ) = @_;

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

sub logger {
    my $self = shift;
    require Punc::Logger::StdErr;
    $self->{logger} ||= 'Punc::Logger::StdErr';
}

sub log {
    my ( $self, $level, $message ) = @_;
    $self->logger->log( $level => $message );
}

1;
__END__

=encoding utf8

=head1 NAME

Punc - Perl Unified Network Controller

=head1 SOURCE

http://coderepos.org/share/browser/lang/perl/Punc

=head1 REPOSITORY

  svn co http://svn.coderepos.org/share/lang/perl/Punc/trunk Punc

=head1 DESCRIPTION

Punc は Python 製のシステム管理フレームワーク Func の Perl 実装です。現状はまだプロトタイプです。

=head1 USAGE

=head2 puncmasterd 起動

puncmasterd は SSL 証明書発行/管理用デーモンです。

 # ./bin/puncmasterd

=head2 スレーブデーモン起動

スレーブデーモンが各ホスト上で動作し、マスターからの指令にしたがいモジュールを実行します。

  # ./bin/puncd

puncmasterdとは別ホスト上で動かす場合、./etc/puncd.yaml の puncmaster_host を適宜変更してから puncd を起動してください。

=head2 puncmaster-ca コマンドによる証明書への署名

  # ./bin/puncmaster-ca --sign host.example.com

=head2 punc コマンドでのモジュール実行

  # ./bin/punc "*" call service description
  # ./bin/punc "*" call service status httpd

=head2 Punc::Client でのモジュール実行

  use Punc::Client;
  my $punc = Punc::Client->new('*');
  my $res  = $punc->service->status('httpd');

=head1 TODO

とりあえず、YAPC::Asia 2008 までには以下のあたりは実装する。

 * SSL 実装
 * ホスト管理（とりあえずはファイルベース。YAMLとかLDAPに切り替えやすいようにする。）
 * モジュールの配布メカニズム


=head1 AUTHOR

Gosuke Miyashita E<lt>gosukenator at gmail.comE<gt>

=head1 SEE ALSO

L<https://fedorahosted.org/func/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
