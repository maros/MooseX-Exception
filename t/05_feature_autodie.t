# -*- perl -*-

# t/04_feature_moose.t - autodie exception handling

use Test::Most tests => 4 + 1;
use Test::NoWarnings;

use MooseX::Exception qw(Autodie);

eval {
    my $fh;
    open $fh,'/unknown/file';
    close $fh;
};
if ($@) {
    isa_ok($@,'MooseX::Exception::Autodie');
    isa_ok($@,'MooseX::Exception::Base');
    is($@,q[No such file or directory],'error message ok');
} else {
    fail('No exception');
}

no MooseX::Exception;

lives_ok {
    my $fh;
    open $fh,'/unknown/file';
    close $fh;
} 'Autodie unloaded';