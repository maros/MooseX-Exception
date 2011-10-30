# ============================================================================
package MooseX::Exception::Moose;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);
with qw(MooseX::Exception::Role::Location);

has 'metaclass' => (
    is              => 'rw',
    isa             => 'Moose::Meta::Class',
);
has 'attr' => (
    is              => 'rw',
    isa             => 'Moose::Meta::Attribute',
);
has [qw(sub_name has_args wantarray evaltext data instance depth last_error sub is_require)] => (
    is              => 'rw',
);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = MooseX::Exception::_process_args(@_);
    
    $args->{package} = delete $args->{pack};
    
    return $self->$orig($args);
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;