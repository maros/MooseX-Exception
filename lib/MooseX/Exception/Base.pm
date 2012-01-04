# ============================================================================
package MooseX::Exception::Base;
# ============================================================================

use Moose;

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
        my $args = MooseX::Exception::Base::_process_args(@args);
        die $class->new($args);
    }
}

sub BUILDARGS {
    my $class = shift;
    my $args = MooseX::Exception::Base::_process_args(@_);
    return $class->SUPER::BUILDARGS($args);
}

sub description {
    return "An exception";
}

sub rethrow {
    my ($self,@args) = @_;
    my $args = MooseX::Exception::Base::_process_args(@args);
    
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
    my $args = MooseX::Exception::Base::_process_args(@args);

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

sub _process_args {
    my $return = {};
    if (scalar @_) {
        if (scalar @_ == 1) {
            if (ref($_[0]) eq 'HASH') {
                # Shalow copy so that we do not alter anything
                $return = { %{$_[0]} };
            } else {
                $return = { message => $_[0] };
            }
        } elsif (scalar(@_) % 2 == 0) {
            $return = { @_ };
        } else {
            $return = { message => shift, @_ };
        }
    }
    $return->{message} ||= delete $return->{error}
        if exists $return->{error};
    return $return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=encoding utf8

=head1 NAME

MooseX::Exception::Base - Basic exception class

=head1 SYNOPSIS

 package MyException;
 use Moose;
 extends qw(MooseX::Exception::Base)
 1;

Somewhere else

 eval {
     ...
     MyException->throw("A fatal error happened")
        if $is_error;
     ...
 };
 if (my $error = $@) {
     say "An error happened: ".$error->message;
     $error->rethrow();
 };

=head1 DESCRIPTION

This class acts as the basic exception class for all MooseX::Exception
exceptions. By 

=head1 METHODS

=head3 throw

=head3 rethrow

=head3 rethrow_as

=head3 message

=head3 isa

=head3 as_string

=head3 full_message

=head3 description

=head3 error

=head1 EXTENDING

