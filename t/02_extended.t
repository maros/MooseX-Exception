# -*- perl -*-

# t/02_extended.t - extended tests

use Test::Most tests => 24 + 1;
#use Test::NoWarnings;

use lib 't/lib/';
use Test02;

# 1st test
{
    eval {
        X->throw('test');
    };
    my $e = $@;
    
    warn($e);
    isa_ok($e,'X');
    isa_ok($e,'MooseX::Exception::Base');
    isa_ok($e,'MooseX::Exception::Extended');
    
    is($e->message,'test','Message ok');
    is($e->description,'An exception','Description ok');
    ok($e->has_trace,'Has trace');
    isa_ok($e->trace,'Devel::StackTrace');
    is($e->trace->frame(0)->line,$e->line,'Lines match');
    warn $e->line;
    warn $e->filename;
    warn $e->trace->as_string;
}
