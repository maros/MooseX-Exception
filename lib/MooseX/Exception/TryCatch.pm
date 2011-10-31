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