# ============================================================================
package MooseX::Exception::Role::Location;
# ============================================================================

use Moose::Role;


before 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = MooseX::Exception::_process_args(@_);
    

    
    return $self->$orig()
        unless @_;

    my $size = shift;
    $size = $size / 2
        if $self->likes_small_things();

    return $self->$orig($size);
};



no Moose::Role;
1;