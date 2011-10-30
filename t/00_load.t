# -*- perl -*-

use Test::More tests => 12;

BEGIN {
    use_ok( 'MooseX::Exception' );
}

diag( "Testing MooseX::Exception MooseX::Exception->VERSION, Perl $], $^X" );

use_ok( 'MooseX::Exception::Base' );
use_ok( 'MooseX::Exception::Autodie' );
use_ok( 'MooseX::Exception::Moose' );
use_ok( 'MooseX::Exception::TryCatch' );
use_ok( 'MooseX::Exception::Feature::Autodie' );
use_ok( 'MooseX::Exception::Feature::Define' );
use_ok( 'MooseX::Exception::Feature::Moose' );
use_ok( 'MooseX::Exception::Feature::TryCatch' );
use_ok( 'MooseX::Exception::Role::Location' );
use_ok( 'MooseX::Exception::Role::ProcessInfo' );
use_ok( 'MooseX::Exception::Role::Trace' );
