# -*- perl -*-

# t/04_feature_moose.t - autodie exception handling

use Test::Most tests => 9 + 1;
use Test::NoWarnings;

use MooseX::Exception qw(Autodie);
#use autodie qw(system);

eval {
    my $fh;
    open $fh,'/unknown/file';
    close $fh;
};
if ($@) {
    my $error = $@;
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


#eval {
#    system('things_go_wrong');
#};
#if ($@) {
#    my $error = $@;
#    isa_ok($error,'MooseX::Exception::Autodie');
#    isa_ok($error,'MooseX::Exception::Base');
#    is($error.'',q[No such file or directory],'error message ok');
#    ok($error->matches(':system'),'Match :system ok');
#} else {
#    fail('No exception');
#}

no MooseX::Exception;

lives_ok {
    my $fh;
    open $fh,'/unknown/file';
    close $fh;
} 'Autodie unloaded';



