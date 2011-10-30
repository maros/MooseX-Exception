# -*- perl -*-

# t/01_basic.t - basic tests

use Test::Most tests => 29 + 1;
use Test::NoWarnings;

use lib 't/lib/';
use Test01;

# 1st test
{
    eval {
        X->throw('test');
    };
    my $e = $@;
    
    isa_ok($e,'X');
    isa_ok($e,'MooseX::Exception::Base');
    is($e->message,'test','Message ok');
    is($e->description,'basic exception','Description ok');
}

# 2nd test
{
    eval {
#line 1000
        X2->throw(message =>'test', test => '2');
    };
    my $e1 = $@;
    
    isa_ok($e1,'X2');
    isa_ok($e1,'X');
    isa_ok($e1,'MooseX::Exception::Base');
    is($e1->message,'test','Message ok');
    is($e1->test,2,'Attribute test ok');
    is($e1->line,1000,'Line ok');
    is($e1->package,'main','Package ok');
    is($e1->description,'slightly advanced exception','Description ok');
    
    eval {
        $e1->throw();
    };
    my $e2 = $@;
    
    isa_ok($e2,'X2');
    is($e2->message,'test','Message still ok');
    is($e2->test,2,'Attribute test still ok');
    is($e2->line,1000,'Line still ok');
    
    eval {
        $e2->rethrow(line => 100);
    };
    my $e3 = $@;
    
    isa_ok($e3,'X');
    is(ref($e3),'X2','Is blessed to X2');
    is($e3->message,'test','Message still ok');
    is($e3->test,2,'Attribute test still ok');
    is($e2->line,100,'Line is changes');
    
    eval {
        $e3->rethrow_as('X',line => 100);
    };
    my $e4 = $@;
    
    isa_ok($e4,'X');
    is(ref($e4),'X','Is blessed to X');
    
    is($e4->message,'test','Message ok');
    is($e4->line,100,'Line is changes');
}

# 3rd test
{
    eval {
#line 1000
        X3->throw(message =>'test3');
    };
    my $e1 = $@;
    isa_ok($e1,'X3');
    isa_ok($e1,'MooseX::Exception::Base');
    is($e1->message,'test3','Message ok');
    ok(! $e1->can('line'),'No location available');
}