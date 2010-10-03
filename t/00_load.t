# -*- perl -*-

# t/00_load.t - check module loading

use Test::Most tests => 6;

BEGIN { 
    use_ok('MooseX::Exception');
    use_ok('MooseX::Exception::Base');
    use_ok('MooseX::Exception::Extended');
    use_ok('MooseX::Exception::Feature::Autodie');
    use_ok('MooseX::Exception::Feature::Moose');
    use_ok('MooseX::Exception::Feature::TryCatch');
}