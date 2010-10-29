# ============================================================================
package MooseX::Exception::Role::Trace;
# ============================================================================

use Moose::Role;

has 'trace' => (
    is          => 'rw',
    isa         => 'Devel::StackTrace',
    predicate   => 'has_trace',
);
has 'show_trace' => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 1,
);

sub as_string {
    my ($self) = @_;
    
    my $str = $self->as_string;
    $str .= "\n\n" . $self->trace->as_string
        if $self->show_trace && $self->has_trace;
    
    return $str;
}

no Moose::Role;
1;