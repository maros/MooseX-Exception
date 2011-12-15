# ============================================================================
package MooseX::Exception::TryCatch;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);
with qw(MooseX::Exception::Role::Location);

sub description {
    return "try-catch exception";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=encoding utf8

=head1 NAME

MooseX::Exception::Moose - A try-catch exception

=head1 DESCRIPTION

Exceptions generated via the "TryCatch" exception featue 
(L<MooseX::Exception::Feature::TryCatch>) are of this exception class.

=head1 METHODS

This exception class extends the L<MooseX::Exception::Base> class.
This exception consumes the L<MooseX::Exception::Role::Location> role.

=head3 metaclass

=head3 attr

=head3 sub_name

=head3 has_args

=head3 wantarray

=head3 evaltext

=head3 data

=head3 instance

=head3 depth

=head3 last_error

=head3 sub

=head3 is_require

=head1 SEE ALSO

L<Try-Tiny>