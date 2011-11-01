# -*- perl -*-

# t/trytiny/basic.t - Try::Tiny tests

use strict;
use warnings;
 
use Test::Most tests => 27+1;
use Test::NoWarnings;

use MooseX::Exception qw(TryCatch);

sub _eval {
    local $@;
    local $Test::Builder::Level = $Test::Builder::Level + 2;
    return ( scalar(eval { $_[0]->(); 1 }), $@ );
}

my $prev;

lives_ok {
    try {
        die "foo";
    };
} "basic try";
 
throws_ok {
    try {
        die "foo";
    } catch { die $_ };
} qr/foo/, "rethrow";

{
    local $@ = "magic";
    is( try { 42 }, 42, "try block evaluated" );
    is( $@, "magic", '$@ untouched' );
}

{
    local $@ = "magic";
    is( try { die "foo" }, undef, "try block died" );
    is( $@, "magic", '$@ untouched' );
}

{
    local $@ = "magic";
    like( (try { die "foo" } catch { $_ }), qr/foo/, "catch block evaluated" );
    is( $@, "magic", '$@ untouched' );
}

is( scalar(try { "foo", "bar", "gorch" }), "gorch", "scalar context try" );
is_deeply( [ try {qw(foo bar gorch)} ], [qw(foo bar gorch)], "list context try" );

is( scalar(try { die } catch { "foo", "bar", "gorch" }), "gorch", "scalar context catch" );
is_deeply( [ try { die } catch {qw(foo bar gorch)} ], [qw(foo bar gorch)], "list context catch" );

{
    my ($sub) = catch { my $a = $_; };
    isa_ok($sub, 'MooseX::Exception::Feature::TryCatch::Catch', 'Checking catch subroutine scalar reference is correctly blessed');
}
 
{
    my ($sub) = finally { my $a = $_; };
    isa_ok($sub, 'MooseX::Exception::Feature::TryCatch::Finally', 'Checking finally subroutine scalar reference is correctly blessed');
}

{
    my ($sub) = where 'X';
    isa_ok($sub, 'MooseX::Exception::Feature::TryCatch::Where', 'Checking where subroutine scalar reference is correctly blessed');
}
 
lives_ok {
    try {
        die "foo";
    } catch {
        my $err = shift;
        like $err, qr/foo/;
        try {
            like $err, qr/foo/;
        } catch {
            fail("shouldn't happen");
        };
        pass "got here";
    }
} "try in try catch block";

throws_ok {
    try {
        die "foo";
    } catch {
        my $err = shift;
 
        try { } catch { };
 
        die "rethrowing $err";
    }
} qr/rethrowing foo/, "rethrow with try in catch block";

sub Evil::DESTROY {
    eval { "oh noes" };
}
 
sub Evil::new { bless { }, $_[0] }
 
{
    local $@ = "magic";
    local $_ = "other magic";
 
    try {
        my $object = Evil->new;
        die "foo";
    } catch {
        pass("catch invoked");
        local $TODO = "i don't think we can ever make this work sanely, maybe with SIG{__DIE__}";
        like($_, qr/foo/);
    };
 
    is( $@, "magic", '$@ untouched' );
    is( $_, "other magic", '$_ untouched' );
}
 
{
    my ( $caught, $prev );
 
    {
        local $@;
 
        eval { die "bar\n" };
 
        is( $@, "bar\n", 'previous value of $@' );
 
        try {
            die {
                prev => $@,
            }
        } catch {
            $caught = $_;
            $prev = $@;
        }
    }
 
    is_deeply( $caught, { prev => "bar\n" }, 'previous value of $@ available for capture' );
    is( $prev, "bar\n", 'previous value of $@ also available in catch block' );
}