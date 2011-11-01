# -*- perl -*-

# t/02_extended.t - extended tests

use Test::Most tests => 15 + 1;
use Test::NoWarnings;

use MooseX::Exception qw(TryCatch);

{
    package t::test01;

    use Moose;
    use MooseX::Exception qw(Define);
    
    exception "X";
    
    exception "X2" => define {
        extends('X');
    };
    
    __PACKAGE__->meta->make_immutable;
    no Moose;
}

# Test 1 - basic try
lives_ok {
    try {
        die('hase1');
    };
} 'Simple exception';

# Test 2 - basic try/catch
try {
    die('hase2');
} catch {
    my $msg = $_;
    isa_ok($msg,'MooseX::Exception::TryCatch');
    like($msg->message,qr/^hase2\s/,'Message ok');
};

# Test 3 - catch exception class
try {
    X->throw(message => 'Exception X');
}
where "X2" => catch {
    fail('Shoud not catch X');
}
where "X" => catch {
    my $msg = $_;
    pass('Caught X');
    isa_ok($msg,'X');
}
catch {
    fail('Shoud not catch fallback');
}
finally {
    pass('Run finally 1');
}
finally {
    pass('Run finally 2');
};

# Test 4 - catch exception class
try {
    X2->throw(message => 'Exception X');
}
where "X2" => catch {
    my $msg = $_;
    pass('Caught X2');
    isa_ok($msg,'X2');
    isa_ok($msg,'X');
}
where "X" => catch {
    fail('Shoud not catch X');
}
catch {
    fail('Shoud not catch fallback');
}
finally {
    pass('Run finally 1');
}
finally {
    pass('Run finally 2');
};

# Test 5 - wrong setup
throws_ok {
    try {
        die('XX');
    }
    where "X" => 
    where "X2" =>
    catch {};
} qr/Detected unbalanced where\/catch blocks/;

# Test 6 - wrong setup
throws_ok {
    try {
        die('XX');
    }
    catch {}
    catch {}
    ;
} qr/Detected multiple catch blocks/;

# Test 7 - nested
try {
    try {
        die('xxx');
    } catch {
        pass('Should catch');
    };
} catch {
    fail('Should not catch')
};
