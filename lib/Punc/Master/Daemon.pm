package Punc::Master::Daemon;

use strict;
use warnings;
use base qw( Punc::Daemon );
use File::Spec;
use File::Path;
use Punc::Master::CA;
use Crypt::OpenSSL::CA;
use Crypt::OpenSSL::RSA;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{ca} = Punc::Master::CA->new({
        ssldir => File::Spec->catdir($self->{confdir}, 'ssl'),
    });

    $self->_find_or_create_ca_cert($self->{context});

    $self->{ssl_key}  = File::Spec->catfile($self->{ca}->{cadir}, 'ca.key');
    $self->{ssl_cert} = File::Spec->catfile($self->{ca}->{cadir}, 'ca.cert'),
    return $self;
}

sub _find_or_create_ca_cert {
    my ( $self, $c ) = @_;
    my $cadir = $self->{ca}->{cadir};
    unless ( -d $cadir ) {
        mkpath($cadir);
        chmod oct('0700'), $cadir;
    }

    my $cert = File::Spec->catfile($cadir, 'ca.cert');
    unless ( -f $cert ) {
        $self->_create_self_signed_cert($c);
    }
}

sub _create_self_signed_cert {
    my ( $self, $c ) = @_;

    # 鍵作成
    my $rsa = Crypt::OpenSSL::RSA->generate_key(1024);
    open my $out, '>', File::Spec->catfile($self->{ca}->{cadir}, 'ca.key') or die $!;
    print $out $rsa->get_private_key_string;
    close $out;

    my $privkey = Crypt::OpenSSL::CA::PrivateKey->parse($rsa->get_private_key_string);
    my $pubkey  = $privkey->get_public_key;

    # 自己署名証明書作成
    my $dn   = Crypt::OpenSSL::CA::X509_NAME->new( CN => $c->fact('fqdn') );
    my $x509 = Crypt::OpenSSL::CA::X509->new($pubkey);

    $x509->set_serial('0x00');
    $x509->set_subject_DN($dn);
    $x509->set_issuer_DN($dn);

    ### TODO: 有効期限をきちんと
    $x509->set_notBefore('20080101000000Z');
    $x509->set_notAfter('20090101000000Z');

    my $pem = $x509->sign($privkey, 'sha1');
    open my $cert, '>', File::Spec->catfile($self->{ca}->{cadir}, 'ca.cert') or die $!;
    print $cert $pem;
    close $cert;

    open my $srl, '>', File::Spec->catfile($self->{ca}->{cadir}, 'ca.srl') or die $!;
    print $srl '01';
    close $srl;
}


sub handle_request {
    my ( $self, $module, $method, $args ) = @_;

    # CSR 取得
    my $csr = $args->{csr};
    my $hostname = $self->{ca}->get_hostname_from_csr($csr);

    my $csrdir = $self->{ca}->{csrdir};
    mkpath($csrdir) unless -d $csrdir;

    $self->{ca}->save_csr($csr);

    ### TODO: 自動署名
    while ( 1 ) {
        last if $self->{ca}->is_signed($csr);
        sleep 1;
    }

    open my $in, '<', File::Spec->catfile($self->{ca}->{certdir}, "${hostname}.cert") 
        or die;
    my $cert = do { local $/; <$in> };
    close $in;
    return { cert => $cert };


}


1;