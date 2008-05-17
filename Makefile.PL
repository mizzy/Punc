use inc::Module::Install;
name 'Punc';
all_from 'lib/Punc.pm';

requires $_ for (qw/
                       JSON
                       JSON::RPC::Client
                       Pfacter
                       UNIVERSAL::require
                       YAML
                       Module::Pluggable
                       Crypt::OpenSSL::PKCS10
                       Crypt::OpenSSL::RSA
                       Crypt::OpenSSL::CA
                       HTTP::Daemon::SSL
                       File::Spec
                       Getopt::Long
                       Pod::Usage
                       File::Path
                       Crypt::SSLeay
                       Moose
                       MooseX::ClassAttribute
                       Class::ErrorHandler
                   /);

build_requires $_ for (qw/
                             Test::More
                             File::Temp
                         /);

use_test_base;
auto_include;
WriteAll;
