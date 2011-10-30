package Test01;

use Moose;
use MooseX::Exception qw(Define);

exception "X" => define {
    # calls extends('MooseX::Exception::Base') implicitly
    with('Location');
    description('basic exception');
};

exception "X2" => define {
    extends('X');
    description('slightly advanced exception');
    has 'test' => (is => 'rw');
};

exception "X3";

__PACKAGE__->meta->make_immutable;
no Moose;

1;