package Punc::Client;

use Moose;
our $VERSION = '0.01';
our $AUTOLOAD;
use Punc::ConfigLoader;
use Punc::Client::Request;
use UNIVERSAL::require;
use FindBin;

has 'hosts' => ( is => 'rw', isa => 'ArrayRef' );
has 'conf'  => ( is => 'rw', isa => 'HashRef' );

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
        conf   => $self->conf,
        hosts  => $self->hosts,
        module => $module,
    });
}

1;
