# ============================================================================
package MooseX::Exception::Role::Trace;
# ============================================================================

use Moose::Role;
requires qw(message throw rethrow);

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
                return 0;
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
    
    my $str = $self->full_message;
    $str .= "\n\n" . $self->trace->as_string
        if $self->show_trace && $self->has_trace;
    
    return $str;
}

no Moose::Role;
1;

=encoding utf8

=head1 NAME

MooseX::Exception::Role::Trace - Adds a full stacktrace to an exception class

=head1 SYNOPSIS

 package MyException;
 use Moose;
 extends qw(MooseX::Exception::Base)
 with qw(MooseX::Exception::Role::Trace);
 1;

=head1 DESCRIPTION

This exception class role adds a full stacktrace via L<Devel::StackTrace> 
to an exception class.

=head1 METHODS

=head3 trace

Stacktrace object. L<Devel::StackTrace>

=head3 show_trace

Boolean value that defines if the stacktrace should be included in a
human-readable errormessage.

=head1 SEE ALSO

L<Devel::StackTrace>, L<MooseX::Exception::Base>