# ============================================================================
package MooseX::Exception::Role::ProcessInfo;
# ============================================================================

use Moose::Role;
requires qw(message throw rethrow);

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

=encoding utf8

=head1 NAME

MooseX::Exception::Role::ProcessInfo - Adds process info to an exception

=head1 SYNOPSIS

 package MyException;
 use Moose;
 extends qw(MooseX::Exception::Base)
 with qw(MooseX::Exception::Role::ProcessInfo);
 1;

=head1 DESCRIPTION

This exception class role adds various process-related informations to an
exception.

=head1 METHODS

=head3 time

Timestamp of the exception

=head3 uid

User ID of the process that generated this exception

=head3 pid

Process ID of the process that generated this exception

=head3 gid

Group ID of the process that generated this exception

=head3 egid

Effective group ID of the process that generated this exception

=head3 euid

Effective user ID of the process that generated this exception

=head1 SEE ALSO

L<MooseX::Exception::Base>