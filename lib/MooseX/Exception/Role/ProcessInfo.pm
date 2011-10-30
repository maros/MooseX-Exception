# ============================================================================
package MooseX::Exception::Role::ProcessInfo;
# ============================================================================

use Moose::Role;

has 'uid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $< },
);
has 'pid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $$ },
);
has 'euid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $> },
);
has 'gid' => (
    is          => 'rw',
    default     => sub { $( },
);
has 'egid' => (
    is          => 'rw',
    default     => sub { $) },
);
has 'time' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { CORE::time() }
);

no Moose::Role;

1;