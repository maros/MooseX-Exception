# ============================================================================
package MooseX::Exception::Die;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);
with qw(MooseX::Exception::Role::Location);

sub description {
    return "Signalhandler exception";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;