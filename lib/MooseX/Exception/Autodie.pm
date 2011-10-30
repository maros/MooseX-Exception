# ============================================================================
package MooseX::Exception::Autodie;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);
with qw(MooseX::Exception::Role::Location);

$INC{'MooseX/Exception/X/Autodie.pm'} = 1;

has [qw(function context eval_error return)] => (
    is              => 'rw',
);
has 'args' => (
    is              => 'rw',
    isa             => 'ArrayRef',
);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = MooseX::Exception::_process_args(@_);
    
    $args->{message} = delete $args->{errno};
    
    return $self->$orig($args);
};

sub description {
    return "Autodie exception";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;