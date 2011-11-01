# -*- perl -*-

# t/06_exception_basic.t - test exception classes

use Test::Most tests => 18 + 1;
use Test::NoWarnings;

{
    package X1;
    use Moose;
    extends qw(MooseX::Exception::Base);
}

{
    package X2;
    use Moose;
    extends qw(X1);
    
    has 'test' => ( is => 'rw' );
    
    sub full_message {
        my ($self) = @_;
        return $self->test.':'.$self->error;
    }
}


{
    my $x1 = X1->new('some error');
    isa_ok($x1,'MooseX::Exception::Base');
    isa_ok($x1,'X1');
    is($x1->error,'some error','Error ok');
    is($x1->description,'An exception','Description ok');
    is($x1->full_message,'some error','aull_message ok');
    is($x1->as_string,'some error','as_string ok');
    is("$x1",'some error','Overload ok');
    ok($x1->isa('X1'),'Isa X1');
    
    eval {
        $x1->rethrow();
    };
    isa_ok($@,'X1','Throws ok');
}

{
    my $x2 = X2->new(error => 'some error', test => 'test');
    isa_ok($x2,'MooseX::Exception::Base');
    isa_ok($x2,'X2');
    isa_ok($x2,'X1');
    is($x2->error,'some error','Error ok');
    is($x2->description,'An exception','Description ok');
    is($x2->full_message,'test:some error','aull_message ok');
    is($x2->as_string,'test:some error','as_string ok');
    is("$x2",'test:some error','Overload ok');
    
    eval {
        $x2->rethrow_as('X1');
    };
    is(ref($@),'X1','Throws ok');
}