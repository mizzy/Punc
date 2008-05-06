package Punc::Hosts::File;
use File::Spec;
use File::Basename;
use Moose;

extends 'Punc::Hosts';
with 'Punc::Hosts::Role';

sub get_hosts {
    my ( $class, $args ) = @_;

    my $confdir = $args->{conf}->{confdir};
    my $certdir = File::Spec->catdir($confdir, 'ssl', 'certs');
    my @files = glob("$certdir/*");

    my @hosts;
    for my $file ( @files ) {
        if ( $file =~ /$args->{target}/ ) {
            my $host = basename($file, '.cert');
            push @hosts, $host;
        }
    }

    return wantarray ? @hosts : \@hosts;
}

1;
