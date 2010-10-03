# -*- perl -*-

# t/02_extended.t - extended tests

use Test::Most tests => 21 + 1;
use Test::NoWarnings;

use lib 't/lib/';
use Test02;

# 1st test
{
    eval {
        X->throw('test');
    };
    my $e1 = $@;
    
    isa_ok($e1,'X');
    isa_ok($e1,'MooseX::Exception::Base');
    isa_ok($e1,'MooseX::Exception::Extended');
    
    is($e1->message,'test','Message ok');
    is($e1->description,'An exception','Description ok');
    ok($e1->has_trace,'Has trace');
    isa_ok($e1->trace,'Devel::StackTrace');
    is($e1->trace->frame(0)->line,$e1->line,'Lines match');
    is($e1->trace->frame(0)->filename,$e1->filename,'Filename match');
}

# 2nd test
{
    eval {
        X2->throw('test', test => 'hase');
    };
    my $e2 = $@;
    
    isa_ok($e2,'X');
    isa_ok($e2,'X2');
    
    isa_ok($e2,'MooseX::Exception::Base');
    isa_ok($e2,'MooseX::Exception::Extended');
    
    is($e2->message,'test','Message ok');
    is($e2->error,'test','Error ok');
    is($e2->test,'hase','Test attribute ok');
    is($e2->description,'An exception','Description ok');
    is($e2->as_string,'hase:test','as_string ok');
}

# test if ordinary moose still works
{
    my $test = Test02->new(test => 'hase');
    is($test->test,'hase','Basic Moose accessor ok');
    is($test->some_method,'2','Basic Moose method modifier ok');
    isa_ok($test->meta,'Moose::Meta::Class','Has meta class');
}
