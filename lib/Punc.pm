package Punc;

use strict;
use warnings;
our $VERSION = '0.01';

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

Punc では Puppet の様なプロバイダメカニズムを用意しており、その実現のために Ruby 製の Facter (L<http://reductivelabs.com/projects/facter/>) が必要となっています。（Perl で Facter と同じことができるモジュールをご存知の方は教えてください。）

=head1 USAGE

=head2 デーモン起動

  # ./bin/puncd

=head2 punc コマンドでのモジュール実行

  # ./bin/punc localhost call service description
  # ./bin/punc localhost call service status httpd

=head2 Punc::Client でのモジュール実行

  use Punc::Client;
  my $punc = Punc::Client->new('localhost');
  my $res  = $punc->service->status('httpd');

=head1 TODO

たくさん


=head1 AUTHOR

Gosuke Miyashita E<lt>gosukenator at gmail.comE<gt>

=head1 SEE ALSO

L<https://fedorahosted.org/func/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
