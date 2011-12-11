# -*- perl -*-

# t/10_feature_die.t - handle die

use Test::Most tests => 13 + 1;
use Test::NoWarnings;

my ($x1,$x2,$x3,$x5,$x6);
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

is(ref($x6),'','Not an object - unimport');
like($x6,qr/test/,'Die ok');