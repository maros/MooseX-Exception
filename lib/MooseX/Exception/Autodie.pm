# ============================================================================
package MooseX::Exception::Autodie;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);
with qw(MooseX::Exception::Role::Location);

use autodie::exception;
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

sub matches {
    my ($self,$that) = @_;
    
    autodie::exception::matches($self,$that);
}
 
sub _expand_tag {
    my ($self, @args) = @_;
    
    autodie::exception::_expand_tag($self,@args);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=encoding utf8

=head1 NAME

MooseX::Exception::Autodie - An autodie exception

=head1 DESCRIPTION

Exceptions of this class are thrown if the "Autodie" exception featue 
(L<MooseX::Exception::Feature::Autodie>) is loaded.

=head1 METHODS

This exception class extends the L<MooseX::Exception::Base> class.
This exception consumes the L<MooseX::Exception::Role::Location> role.

=head3 function

=head3 context

=head3 eval_error

=head3 return

=head3 args

=head3 matches

=head1 SEE ALSO

L<autodie>