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