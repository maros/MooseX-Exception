# ============================================================================
package MooseX::Exception::Role::Location;
# ============================================================================

use Moose::Role;

has 'package'   => (
    is              => 'rw',
    isa             => 'Str',
);
has 'line'      => (
    is              => 'rw',
    isa             => 'Int',
);
has 'file'      => (
    is              => 'rw',
    isa             => 'Str',
);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = MooseX::Exception::_process_args(@_);
    
    # Build basic exception info
    unless (exists $args->{line}
        && exists $args->{file}
        && exists $args->{package}) {

        if (exists $args->{trace}
            && ref($args->{trace}) eq 'Devel::StackTrace') {
            my $trace_frame = $args->{trace}->frame(0);
            $args->{package} ||= $trace_frame->package;
            $args->{file} ||= $trace_frame->filename;
            $args->{line} ||= $trace_frame->line;
        } else {
            for (1..10) {
                my ($package_test) = caller($_);
                last
                    unless defined $package_test;
                if ($package_test->isa('MooseX::Exception::Base')
                    || $package_test =~ m/^MooseX::Exception::Feature::/) {
                    my ($package, $file, $line) = caller($_ + 1);
                    $args->{package} ||= $package;
                    $args->{file} ||= $file;
                    $args->{line} ||= $line;
                    last;
                }
            }
        }
    }
    
    
    return $self->$orig($args);
};

no Moose::Role;
1;