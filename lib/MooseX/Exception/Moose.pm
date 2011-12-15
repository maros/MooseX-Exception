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


=encoding utf8

=head1 NAME

MooseX::Exception::Moose - A moose exception

=head1 DESCRIPTION

Exceptions of this class are thrown if the "Moose" exception featue 
(L<MooseX::Exception::Feature::Moose>) is loaded.

=head1 METHODS

This exception class extends the L<MooseX::Exception::Base> class.
This exception class consumes the L<MooseX::Exception::Role::Location> role.

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