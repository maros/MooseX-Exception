# -*- perl -*-

# t/01_basic.t - basic tests

use Test::Most tests => 32 + 1;
use Test::NoWarnings;

our @test_args;

{
    package MooseX::Exception::Feature::Test;
    sub import {
        push(@test_args,@_);
    }
    sub unimport {
        push(@test_args,@_);
    }
}