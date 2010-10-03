package Test02;

use Moose;
use MooseX::Exception;

exception 'X' => sub{
    extends('MooseX::Exception::Extended');
};

exception 'X2' => sub{
    extends('X');
    has 'test' => (is => 'rw');
    method 'as_string' => sub {
        my ($self) = @_;
        return $self->test .':'.$self->message;
    };
};

1;