# -*- perl -*-

# t/07_exception_role_counter.t - rethrow counter

use Test::Most tests => 7 + 1;
use Test::NoWarnings;

{
    package X1;
    use Moose;
    extends qw(MooseX::Exception::Base);
    with qw(MooseX::Exception::Role::Counter)
}

{
    package X2;
    use Moose;
    extends qw(X1);
}

{
    eval {
        X1->throw('some error');
    };
    my $x1 = $@;
    isa_ok($x1,'X1');
    is($x1->counter,0,'Counter is 0');
    
    eval {
        $x1->rethrow();
    };
    my $x2 = $@;
    isa_ok($x2,'X1');
    is($x1->counter,1,'Counter is 1');
    is($x2->counter,1,'Counter is 1');
    
    eval {
        $x2->rethrow_as('X2');
    };
    my $x3 = $@;
    isa_ok($x3,'X2');
    is($x3->counter,2,'Counter is 2');
}