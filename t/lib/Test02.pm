package Test02;

use Moose;
use MooseX::Exception qw(Define);

exception 'X' => sub{
    with('MooseX::Exception::Extended');
};

exception 'X2' => sub{
    extends('X');
    has 'test' => (is => 'rw',required => 1);
    method 'as_string' => sub {
        my ($self) = @_;
        return $self->test .':'.$self->message;
    };
};

# Combine with moose to see if if it interfers

has 'test' => (
    is          => 'rw',
);

sub some_method {
    return 1;
}

around 'some_method' => sub {
    return 2;
};

__PACKAGE__->meta->make_immutable;
1;