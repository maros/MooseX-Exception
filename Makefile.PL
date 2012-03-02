# Load the Module::Install bundled in ./inc/
use strict;
use inc::Module::Install 0.92;

my $from = 'lib/MooseX/Exception.pm';

# Define metadata
name            'MooseX-Exception';
all_from        $from;
readme_from     $from;

perl_version    '5.008';

# Specific dependencies
requires        'Moose'                     => '2.0301';

build_requires  'Test::Most'                => 0;

author_requires 'Test::Pod'                 => '1.14';
author_requires 'Test::Pod::Coverage'       => '1.04';
author_requires 'Test::Perl::Critic'        => 0;
author_requires 'Module::Install::ReadmeFromPod'        => 0;

repository 'git://github.com/maros/moosex-exception.git';

WriteAll;