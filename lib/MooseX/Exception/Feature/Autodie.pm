# ============================================================================
package MooseX::Exception::Feature::Autodie;
# ============================================================================
use utf8;

use strict;
use warnings;

use MooseX::Exception::Autodie;

use autodie ();
our @ISA = qw(autodie);

sub exception_class { return "MooseX::Exception::Autodie" }; # TODO customize

sub import {
    goto &autodie::import;
}

sub unimport {
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