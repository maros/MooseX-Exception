# -*- perl -*-

# t/01_basic.t - basic tests

use Test::Most tests => 32 + 1;

our @test_args;

{
    package test::12test::01;
#    sub moosex_exception_caller {
#        my ($self,$class,$args) = @_;
#        $class->import($args);
#    }
    use MooseX::Exception qw(Test);
    
}

{
    package test::12test::02;
    use MooseX::Exception::Feature::Test;
}