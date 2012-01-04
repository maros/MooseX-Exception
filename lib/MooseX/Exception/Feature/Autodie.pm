# ============================================================================
package MooseX::Exception::Feature::Autodie;
# ============================================================================

use strict;
use warnings;

use base qw(autodie);

our %EXCEPTION_CLASS;

use MooseX::Exception::Autodie;

sub throw {
    my ($class, @args) = @_;

    my $exception_class = "MooseX::Exception::Autodie";
    my ($package) = caller(0);
    if (defined $EXCEPTION_CLASS{$package}) {
        $exception_class = $EXCEPTION_CLASS{$package};
    }

    return $exception_class->new(@args);
}

sub import {
    my ($class,$params) = @_;
    
    # Calculate args
    $params->{exception_class} ||= "MooseX::Exception::Autodie";
    $params->{args} ||= [];
    
    # Get caller
    my ($package,undef,undef) = caller(0);
    
    $EXCEPTION_CLASS{$package} = $params->{exception_class};
    
    # Modify @_ for goto
    @_ = ($class,@{$params->{args}});
    
    goto &autodie::import;
}

sub unimport {
    my ($class) = @_;
    
    goto &autodie::unimport;
}

1;

=encoding utf8

=head1 NAME

MooseX::Exception::Feature::Autodie - Enable autodie behaviour

=head1 SYNOPSIS

 use MooseX::Exception qw(Autodie);
 
 eval {
    my $fh;
    open $fh,'/unknown/file';
    close $fh;
 };
 if (my $error = $@) {
    print 'An error occured while opening a file '.$error->message;
 }

=head1 DESCRIPTION

This exception feature enabled autodie in the current package scope. In 
cotrast to vanilla autodie, this implementation will throw
L<MooseX::Exception::Autodie> objects as exceptions.

=head1 SEE ALSO

L<autodie>, L<MooseX::Exception::Autodie>

=cut