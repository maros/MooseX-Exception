# -*- perl -*-

# t/04_feature_moose.t - autodie exception handling

use Test::Most tests => 19 + 1;
use Test::NoWarnings;

{
    package t::test05::01;
    use Test::Most;
    
    use MooseX::Exception qw(autodie);
    
    eval {
        my $fh;
        open $fh,'/unknown/file';
        close $fh;
    };
    if (my $error = $@) {
        isa_ok($error,'MooseX::Exception::Autodie');
        isa_ok($error,'MooseX::Exception::Base');
        is($error.'',q[No such file or directory],'error message ok');
        ok($error->matches('open'),'Match open ok');
        ok($error->matches(':io'),'Match :io ok');
        ok($error->matches(':all'),'Match :all ok');
        ok(! $error->matches(':system'),'Does not match :system');
        ok(! $error->matches('exec'),'Does not match exec');
    } else {
        fail('No exception');
    }
    
    
    eval {
        chdir('/no/such/directory');
    };
    if (my $error = $@) {
        isa_ok($error,'MooseX::Exception::Autodie');
        isa_ok($error,'MooseX::Exception::Base');
        is($error.'',q[No such file or directory],'error message ok');
        ok($error->matches('chdir'),'Match open ok');
        ok($error->matches(':io'),'Match :io ok');
        ok($error->matches(':all'),'Match :all ok');
        ok(! $error->matches(':system'),'Does not match :system');
        ok(! $error->matches('exec'),'Does not match exec');
    } else {
        fail('No exception');
    }
    
    no MooseX::Exception;
    
    lives_ok {
        my $fh;
        open $fh,'/unknown/file';
        close $fh;
    } 'Autodie unloaded';
}

{
    package t::test05::autodie;
    use Moose;
    extends qw(MooseX::Exception::Autodie);
}

{
    package t::test05::02;
    use Test::Most;
    use MooseX::Exception 'Autodie' => {
        exception_class => 't::test05::autodie',
        args            => [qw(open close)],
    };
    
    eval {
        my $fh;
        open $fh,'/unknown/file';
        close $fh;
    };
    if (my $error = $@) {
        isa_ok($error,'t::test05::autodie');
        isa_ok($error,'MooseX::Exception::Autodie');
    }
    
    eval {
        chdir('/unknown/dir');
    };
    if (my $error = $@) {
        is(ref($error),'','Is no autodie exception')
    }
}

