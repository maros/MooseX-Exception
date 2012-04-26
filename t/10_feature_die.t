# -*- perl -*-

# t/10_feature_die.t - handle die

use Test::Most tests => 15 + 1;
use Test::NoWarnings;

my ($x1,$x2,$x3,$x5,$x6,$x7);
{
    package test::10die::01;
    use MooseX::Exception qw(Die);
    
    eval {
        die('test')
    };
    $x1 = $@;
    
    eval {
        CORE::die('test')
    };
    $x2 = $@;
    
    eval {
        die({ some => 'test'});
    };
    $x3 = $@;
}

isa_ok($x1,'MooseX::Exception::Die');
is($x1->message,'test','message ok');
is($x1->file,'t/10_feature_die.t','file ok');
is($x1->line,'14','line ok');

is(ref($x2),'','Not an object - called core');
like($x2,qr/test/,'Die ok');

is(ref($x3),'HASH','Not an object - called ref');
is($x3->{some},'test','Exception ok');

eval {
    die('no test')
};
my $x4 = $@;
is(ref($x4),'','Not an object - not in scope');

{
    package test::10die::02;
    use MooseX::Exception qw(Die);
    
    eval {
        die('test');
    };
    $x5 = $@;
    
    no MooseX::Exception qw(Die);
    
    eval {
        die('test')
    };
    $x6 = $@;
}

isa_ok($x5,'MooseX::Exception::Die');
is($x5->message,'test','Exception ok');

{
    local $TODO = 'No local scoping yet';   
    is(ref($x6),'','Not an object - unimport');
    like($x6,qr/test/,'Die ok');
}

{
    package t::test10::die;
    use Moose;
    extends qw(MooseX::Exception::Die);
}

{
    package test::10die::03;
    use MooseX::Exception 'Die' => { exception_class => 't::test10::die' };
    
    eval {
        die('test');
    };
    $x7 = $@;
}

isa_ok($x7,'t::test10::die');
is($x7->message,'test','Exception ok');

