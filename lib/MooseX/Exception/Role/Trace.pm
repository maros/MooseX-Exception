# ============================================================================
package MooseX::Exception::Role::Trace;
# ============================================================================

use Moose::Role;
use Devel::StackTrace;

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

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = MooseX::Exception::_process_args(@_);
    
    my $ok = 0;
    $args->{trace} = Devel::StackTrace->new(
        frame_filter    => sub {
            my ($args) = @_;
            my $caller_package = $args->{caller}[0];
            if ($caller_package->isa('MooseX::Exception::Base')) {
                $ok = 1;
            }
            return $ok;
        }
    );
    return $self->$orig($args);
};

#sub throw {
#    my ($class,@args) = @_;
#    my $args = MooseX::Exception::_process_args(@args);
#    
#    $class = $class->rethrow($args)
#        if blessed $class && $class->isa(__PACKAGE__);
#    
#    $args->{build_trace} = 1
#        unless exists $args->{build_trace};
#    my $build_trace = delete $args->{build_trace};
#    
#    if ($build_trace) {
#        my @ignore_class   = (__PACKAGE__);
#        my @ignore_package = qw(MooseX::Exception );
#        
#        if ( my $i = delete $args->{ignore_class} ) {
#            push @ignore_class, ( ref($i) eq 'ARRAY' ? @$i : $i );
#        }
#        if ( my $i = delete $args->{ignore_package} ) {
#            push @ignore_package, ( ref($i) eq 'ARRAY' ? @$i : $i );
#        }
#        
#        $args->{trace} = Devel::StackTrace->new(
#            ignore_class     => \@ignore_class,
#            ignore_package   => \@ignore_package,
##            no_refs          => $self->NoRefs,
##            respect_overload => $self->RespectOverload,
##            max_arg_length   => $self->MaxArgLength,
#        );
#    }
#    
#    die $class->SUPER::throw($args);
#}

sub as_string {
    my ($self) = @_;
    
    my $str = $self->as_string;
    $str .= "\n\n" . $self->trace->as_string
        if $self->show_trace && $self->has_trace;
    
    return $str;
}

no Moose::Role;
1;