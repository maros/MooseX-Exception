# ============================================================================
package MooseX::Exception::Extended;
# ============================================================================

use Moose;
extends qw(MooseX::Exception::Base);

use Devel::StackTrace 1.20;

has 'uid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $< },
);
has 'pid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $$ },
);
has 'euid' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { $> },
);
has 'gid' => (
    is          => 'rw',
    default     => sub { $( },
);
has 'egid' => (
    is          => 'rw',
    default     => sub { $) },
);
has 'time' => (
    is          => 'rw',
    isa         => 'Int',
    default     => sub { CORE::time() }
);
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

sub throw {
    my ($class,@args) = @_;
    my $args = MooseX::Exception::_process_args(@args);
    
    $class = $class->rethrow($args)
        if blessed $class && $class->isa(__PACKAGE__);
    
    $args->{build_trace} = 1
        unless exists $args->{build_trace};
    my $build_trace = delete $args->{build_trace};
    
    if ($build_trace) {
        my @ignore_class   = (__PACKAGE__);
        my @ignore_package = qw(MooseX::Exception );
        
        if ( my $i = delete $args->{ignore_class} ) {
            push @ignore_class, ( ref($i) eq 'ARRAY' ? @$i : $i );
        }
        if ( my $i = delete $args->{ignore_package} ) {
            push @ignore_package, ( ref($i) eq 'ARRAY' ? @$i : $i );
        }
        
        warn('-----------------------------');
        warn(join ',',@ignore_class);
        warn('-----------------------------');
        $args->{trace} = Devel::StackTrace->new(
            ignore_class     => \@ignore_class,
            ignore_package   => \@ignore_package,
#            no_refs          => $self->NoRefs,
#            respect_overload => $self->RespectOverload,
#            max_arg_length   => $self->MaxArgLength,
        );
    }
    
    die $class->SUPER::throw($args);
}

sub as_string {
    my ($self) = @_;
    
    my $str = $self->full_message;
    $str .= "\n\n" . $self->trace->as_string
        if $self->show_trace && $self->has_trace;
    
    return $str;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;