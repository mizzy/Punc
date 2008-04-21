package Punc::Master::CA;

use strict;
use warnings;
use File::Spec;
use File::Path;

sub new {
    my ( $class, $args ) = @_;

    bless {
        %$args,
        csrdir  => File::Spec->catdir($args->{ssldir}, 'csrs'),
        certdir => File::Spec->catdir($args->{ssldir}, 'certs'),
        cadir   => File::Spec->catdir($args->{ssldir}, 'ca'),
    }, $class;
}

sub get_hostname_from_csr {
    my ( $self, $csr ) = @_;

    my ( $hostname ) = ( `echo "$csr" | openssl req -subject` =~ m!subject=/CN=([^\n]+)\n! );
    return $hostname;
}

sub save_csr {
    my ( $self, $csr ) = @_;

    my $hostname = $self->get_hostname_from_csr($csr);

    my $csrdir = $self->{csrdir};
    mkpath($csrdir) unless -f $csrdir;

    my $outfile = File::Spec->catfile($csrdir, "${hostname}.csr");
    open my $out, '>', $outfile or die $!;
    print $out $csr;
    close $out;
}

sub is_signed {
    my ( $self, $csr ) = @_;
    my $hostname = $self->get_hostname_from_csr($csr);
    return -f File::Spec->catfile($self->{certdir}, "${hostname}.cert");
}

sub sign {
    my ( $self, $hostname ) = @_;
    my $cakey    = File::Spec->catfile($self->{cadir}, 'ca.key');
    my $cacert   = File::Spec->catfile($self->{cadir}, 'ca.cert');
    my $caserial = File::Spec->catfile($self->{cadir}, 'ca.srl');

    my $certdir = $self->{certdir};
    mkpath($certdir) unless -f $certdir;
    my $cert = File::Spec->catfile($certdir, "${hostname}.cert");

    my $csr = File::Spec->catfile($self->{csrdir}, "${hostname}.csr");
    die "no csr of $hostname\n" unless -f $csr;

    ### TODO: days の日数はどれぐらいがいいか？
    `openssl x509 -req -days 365 -CA $cacert -CAkey $cakey -CAserial $caserial -in $csr -out $cert`;
    unlink $csr;
}

1;