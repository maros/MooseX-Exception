# ============================================================================
package MooseX::Exception::Role::Counter;
# ============================================================================

use Moose::Role;
requires qw(message throw rethrow);

has 'counter'   => (
    is              => 'rw',
    isa             => 'Int',
    default         => 0,
    traits          => ['Counter'],
    handles         => {
        inc_counter     => 'inc',
        reset_counter   => 'reset',
    },
);

before 'rethrow' => sub {
    shift->inc_counter;
};

before 'rethrow_as' => sub {
    shift->inc_counter;
};

no Moose::Role;
1;

=encoding utf8

=head1 NAME

MooseX::Exception::Role::Counter - Counts rethrows

=head1 SYNOPSIS

 package MyException;
 use Moose;
 extends qw(MooseX::Exception::Base)
 with qw(MooseX::Exception::Role::Counter);
 1;

=head1 DESCRIPTION

This exception class role keeps track how many times this exception has been
retrown

=head1 METHODS

=head3 counter

Returns/sets the rethrow counter

=head3 reset_counter

Resets the rethrow counter to zero

=head3 inc_counter

Increments the rethrow counter

=head1 SEE ALSO

L<MooseX::Exception::Base>