# ============================================================================
package MooseX::Exception::Role::Location;
# ============================================================================

use Moose::Role;
requires qw(message throw rethrow);

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
    my $args = MooseX::Exception::Base::_process_args(@_);
    
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
            for (1..15) {
                my ($package_test) = caller($_);
                last
                    unless defined $package_test;
                next
                    if $package_test eq '';
                if ($package_test->isa('MooseX::Exception::Base')
                    || $package_test =~ m/^MooseX::Exception::Feature::/) {
                    my ($package, $file, $line) = caller($_ + 1);
                    if ($package eq 'Moose::Exporter') {
                        ($package, $file, $line) = caller($_ + 2);
                    }
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

=encoding utf8

=head1 NAME

MooseX::Exception::Role::Location - Information about the origin of the exception

=head1 SYNOPSIS

 package MyException;
 use Moose;
 extends qw(MooseX::Exception::Base)
 with qw(MooseX::Exception::Role::Location);
 1;

=head1 DESCRIPTION

This exception class role adds basic information about the origin (package,
file, line) of the exception to the exception class.

=head1 METHODS

=head3 package

Origin package

=head3 line

Origin linenumber

=head3 file

Origin filename

=head1 SEE ALSO

L<MooseX::Exception::Base>