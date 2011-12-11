# ============================================================================
package MooseX::Exception::Base;
# ============================================================================

use Moose;
use MooseX::Exception;

has 'message'  => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);

use overload
    bool        => sub {1}, 
    '""'        => 'full_message', 
    fallback    => 1;

sub error {
    my $self = shift;
    $self->message(@_);
}

sub throw {
    my ($class,@args) = @_;
    
    if (blessed $class) {
        $class->rethrow(@args)
    } else {
        my $args = MooseX::Exception::_process_args(@args);
        die $class->new($args);
    }
}

sub BUILDARGS {
    my $class = shift;
    my $args = MooseX::Exception::_process_args(@_);
    return $class->SUPER::BUILDARGS($args);
}

sub description {
    return "An exception";
}

sub rethrow {
    my ($self,@args) = @_;
    my $args = MooseX::Exception::_process_args(@args);
    
    my $meta = $self->meta;
    
    foreach my $attribute (keys %$args) {
        if (my $meta_attribute = $meta->find_attribute_by_name($attribute)) {
            $meta_attribute->set_value($self,$args->{$attribute});
        } else {
            die('Not valid args '); # TODO throw some exception
        }
    }
    
    die $self;
}

sub rethrow_as {
    my ($self,$class,@args) = @_;
    my $args = MooseX::Exception::_process_args(@args);

    my $meta_new = $class->meta;
    
    foreach my $attribute (keys %$args) {
        unless ($meta_new->find_attribute_by_name($attribute)) {
            die('Not valid args '); # TODO throw some exception
        }
    }
    
    foreach my $attribute ($meta_new->get_all_attributes) {
        if (! exists $args->{$attribute->name}
            && $attribute->has_value($self)) {
            $args->{$attribute->name} = $attribute->get_value($self);
        }
    }
    
    die $class->new($args);
}

sub as_string {
    my ($self) = @_;
    return $self->full_message;
}

sub isa {
    my ($self,$class) = @_;
    return ($self->CORE::isa($class) || $class->CORE::isa($self)) ? 1:0;
}

sub full_message {
    my ($self) = @_;
    return $self->message;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;