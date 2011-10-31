# ============================================================================
package MooseX::Exception::Role::Counter;
# ============================================================================

use Moose::Role;

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