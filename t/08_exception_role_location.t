# -*- perl -*-

# t/08_exception_role_location.t - check error location

use Test::Most tests => 15 + 1;
use Test::NoWarnings;

{
    package X1;
    use Moose;
    extends qw(MooseX::Exception::Base);
    with qw(MooseX::Exception::Role::Location)
}

{
    package X2;
    use Moose;
    extends qw(MooseX::Exception::Base);
    with qw(MooseX::Exception::Role::Location
        MooseX::Exception::Role::Trace)
}

{
    eval {
        package test::08exception::01;
#line 42
        X1->throw('some error');
    };
    my $x1 = $@;
    isa_ok($x1,'X1');
    like($x1->file, qr/t\/08_exception_role_location\.t$/,'File ok');
    is($x1->package, 'test::08exception::01','Package ok');
    is($x1->line, '42','Line ok');
}

{
    eval {
        package test::08exception::02;
        X1->throw( message => 'some error', line => 1000, file => 'nosuchfile.pm');
    };
    my $x2 = $@;
    isa_ok($x2,'X1');
    is($x2->file,'nosuchfile.pm','File ok');
    is($x2->package, 'test::08exception::02','Package ok');
    is($x2->line, '1000','Line ok');
}

{
    eval {
        package test::08exception::03;
#line 42
        X2->throw('some error');
    };
    my $x3 = $@;
    isa_ok($x3,'X2');
    like($x3->file, qr/t\/08_exception_role_location\.t$/,'File ok');
    is($x3->package, 'test::08exception::03','Package ok');
    is($x3->line, '42','Line ok');
    isa_ok($x3->trace,'Devel::StackTrace');
    is($x3->as_string,'some error

Trace begun at t/08_exception_role_location.t line 42
eval {...} at t/08_exception_role_location.t line 43
','Error message ok');
    $x3->show_trace(0);
    is($x3->as_string,'some error','Error message ok');
}