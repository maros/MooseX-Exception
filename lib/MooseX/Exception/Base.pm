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
    my $args = MooseX::Exception::_process_args(@args);
    
    # Build basic exception info
    unless (exists $args->{line}
        && exists $args->{filename}
        && exists $args->{package}) {
        # TODO refactor to role or some other class 
        # Reuse existing stack trace
        if (exists $args->{trace}
            && ref($args->{trace}) eq 'Devel::StackTrace') {
            my $trace_frame = $args->{trace}->frame(0);
            $args->{package} ||= $trace_frame->package;
            $args->{filename} ||= $trace_frame->filename;
            $args->{line} ||= $trace_frame->line;
        } else {
            # TODO ignore caller if it is from this package ...
            my ($package, $filename, $line) = caller;
            $args->{package} ||= $package;
            $args->{filename} ||= $filename;
            $args->{line} ||= $line;
        }
    }
    
    $class = $class->rethrow($args)
        if blessed $class && $class->isa(__PACKAGE__);
    
    die $class->new($args);
}

sub description {
    return "An exception";
}

#sub has_trace {
#    return 0;
#}

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