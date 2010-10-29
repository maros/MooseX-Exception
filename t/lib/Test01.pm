package Test01;

use Moose;
use MooseX::Exception qw(Define);

exception 'X' => sub{
    # calls extends('MooseX::Exception::Base') implicitly
    description('basic exception');
};

exception 'X2' => sub{
    extends('X');
    description('slightly advanced exception');
    has 'test' => (is => 'rw');
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;