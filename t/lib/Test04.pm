package Test04;

use Moose;
use MooseX::Exception qw(Moose);

has 'test01' => (
    is          => 'rw',
    isa         => 'Int',
);

has 'test02' => (
    is          => 'ro',
);

1;