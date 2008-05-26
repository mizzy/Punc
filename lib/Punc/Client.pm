package Punc::Client;

use Moose;
use Moose::Util::TypeConstraints;
our $AUTOLOAD;
use Punc::ConfigLoader;
use Punc::Client::Request;
use UNIVERSAL::require;
use FindBin;

### TODO: confdir のデフォルト値を変更
has 'conf_dir' => (
    is      => 'rw',
    isa     => 'Str',
    default => "$FindBin::Bin/../etc",
);

has 'conf_file' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { File::Spec->catfile(shift->conf_dir, 'punc.yaml') },
    lazy    => 1,
);

has 'conf' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        my $conf_file = shift->conf_file;
        -f $conf_file ? Punc::ConfigLoader->new->load($conf_file) : {};
    },
    lazy    => 1,
);

coerce 'Str'
    => from 'Str'
    => via { s/\*/\.\*/g };

has 'target' => (
    is      => 'rw',
    isa     => 'Str',
    default => '.*',
    coerce  => 1,
);

sub hosts {
    my $self = shift;

    $self->conf->{conf_dir} = $self->conf_dir unless $self->conf->{conf_dir};

    my $hosts_class = ucfirst $self->conf->{hosts_class} || 'File';
    $hosts_class = "Punc::Hosts::$hosts_class";
    $hosts_class->require;

    my $hosts = $hosts_class->get_hosts({
        target => $self->target,
        conf   => $self->conf,
    });

    return $hosts;
}

sub AUTOLOAD {
    no strict 'refs';
    my $self = shift;
    (my $module = $AUTOLOAD) =~ s/^.*:://;
    return if $module eq 'DESTROY';

    my $client = Punc::Client::Request->new({
        conf   => $self->conf,
        hosts  => $self->hosts,
        module => $module,
    });

    return $client->init;
}

1;
