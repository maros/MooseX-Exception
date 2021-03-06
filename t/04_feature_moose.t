# -*- perl -*-

# t/04_feature_moose.t - moose exception handling

use Test::Most tests => 8 + 1;
use Test::NoWarnings;

{
    package t::test04;
    
    use Moose;
    use MooseX::Exception qw(Moose);
    
    has 'test01' => (
        is          => 'rw',
        isa         => 'Int',
    );
    
    has 'test02' => (
        is          => 'ro',
    );
    __PACKAGE__->meta->make_immutable;
}

eval {
    t::test04->new( test01 => 'h' );
};
if ($@) {
    isa_ok($@,'MooseX::Exception::Moose');
    isa_ok($@,'MooseX::Exception::Base');
    is($@,q[Attribute (test01) does not pass the type constraint because: Validation failed for 'Int' with value h],'error message ok');
} else {
    fail('No exception');
}

eval {
    my $test = t::test04->new( test01 => '1' );
    $test->test02('2');
};
if ($@) {
    my $error = $@;
    isa_ok($error,'MooseX::Exception::Moose');
    isa_ok($error,'MooseX::Exception::Base');
    is($error,q[Cannot assign a value to a read-only accessor],'error message ok');
    is($error->file,'t/04_feature_moose.t','File ok');
    is($error->package,'main','Package ok');
    
} else {
    fail('No exception');
}