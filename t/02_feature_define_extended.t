# -*- perl -*-

# t/02_extended.t - extended tests

use Test::Most tests => 19 + 1;
use Test::NoWarnings;

{
    package t::test02;
    
    use Moose;
    use MooseX::Exception qw(Define);
    
    exception 'X' => sub{
        with qw(Location);
    };
    
    exception 'X2' => sub{
        extends('X');
        with qw(Trace);
        has 'test' => (is => 'rw',required => 1);
        method 'as_string' => sub {
            my ($self) = @_;
            return $self->test .':'.$self->message;
        };
    };
    
    # Combine with moose to see if it interfers
    
    has 'test' => (
        is          => 'rw',
    );
    
    sub some_method {
        return 1;
    }
    
    sub as_string {
        return 1;
    }
    
    around 'some_method' => sub {
        return 2;
    };
    
    __PACKAGE__->meta->make_immutable;
}

# 1st test
{
    eval {
        X->throw('test');
    };
    my $e1 = $@;
    
    isa_ok($e1,'X');
    isa_ok($e1,'MooseX::Exception::Base');
    
    is($e1->message,'test','Message ok');
    is($e1->description,'An exception','Description ok');
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
    
    ok($e2->has_trace,'Has trace');
    isa_ok($e2->trace,'Devel::StackTrace');
    is($e2->trace->frame(0)->line,$e2->line,'Lines match');
    is($e2->trace->frame(0)->filename,$e2->file,'Filename match');
    is($e2->message,'test','Message ok');
    is($e2->error,'test','Error ok');
    is($e2->test,'hase','Test attribute ok');
    is($e2->description,'An exception','Description ok');
    is($e2->as_string,'hase:test','as_string ok');
}

# test if ordinary moose still works
{
    my $test = t::test02->new(test => 'hase');
    is($test->test,'hase','Basic Moose accessor ok');
    is($test->some_method,'2','Basic Moose method modifier ok');
    isa_ok($test->meta,'Moose::Meta::Class','Has meta class');
}
