use inc::Module::Install;
name 'Punc';
all_from 'lib/Punc.pm';

requires $_ for (qw/ /);

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;