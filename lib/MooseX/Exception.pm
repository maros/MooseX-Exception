# ============================================================================
package MooseX::Exception;
# ============================================================================

use strict;
use warnings;

our $AUTHORITY = 'cpan:MAROS';
our $VERSION = '1.00';

use Class::MOP;

use Module::Pluggable 
    search_path => ['MooseX::Exception::Feature'],
    sub_name => 'features_available';

sub unimport {
    my ($proto,@features_requested) = @_;
    my $features_loaded = _process_caller($proto);
    
    if (scalar @features_requested) {
        @features_requested = map { 'MooseX::Exception::Feature::'.$_ } @features_requested;
    } else {
        @features_requested = keys %{$features_loaded}
    }
    
    foreach my $feature_requested (@features_requested) {
        next
            unless defined $features_loaded->{$feature_requested};
            
        @_ = ($feature_requested);
        goto &{$feature_requested.'::unimport'};
        
        delete $features_loaded->{$feature_requested};
    }
}

sub import {
    my ($proto,@features_requested) = @_;
    my $features_loaded = _process_caller($proto);
    
    my (%features_toload,$feature_toload_last);
    
    # Determine which features to load
    foreach my $feature_requested (@features_requested) {
        if (ref $feature_requested eq 'HASH') {
            if (defined $feature_toload_last) {
                $features_toload{$feature_toload_last} = $feature_requested;
            }
        } else {
            if ($feature_requested eq ':all') {
                foreach my $feature_all (__PACKAGE__->features_available) {
                    $features_toload{$feature_all} = {};
                }
            } else {
                my $feature_class = 'MooseX::Exception::Feature::'.ucfirst($feature_requested); # TODO camel case
                $features_toload{$feature_class} = {};
                $feature_toload_last = $feature_class;
            }
        }
    }
    
    # Load all selected features
    foreach my $feature_toload (keys %features_toload) {
        next
            if (exists $features_loaded->{$feature_toload});
        
        $features_loaded->{$feature_toload} = $features_toload{$feature_toload};
        
        Class::MOP::load_class($feature_toload);
        
        # Reset arguments for goto
        @_ = ($feature_toload,%{$features_toload{$feature_toload}});
        goto &{$feature_toload.'::import'};
    }
}

sub _process_caller {
    my ($proto) = @_;
    
    # Get caller and class
    my $class = ref $proto || $proto;
    my( $package, undef, undef) = caller(1);
    
    my $export_name = $package."::moosex_exception_features_loaded";
    
    # Generate symbol in caller package
    no strict 'refs';
    unless (defined ${$export_name}) {
        ${$export_name} = {};
    }
    
    return ${$export_name};
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

=encoding utf8

=head1 NAME

MooseX::Exception - Extendable exception framework based on Moose

=head1 SYNOPSIS

 use MooseX::Exception qw(Define MyFeature);

=head1 DESCRIPTION

MooseX::Exception provides a convinient way of handling exceptions in a
convinient, modern an extedable way. It does so by defining a simple and 
unified exception hierarchy and a mechanism to lexically add (and remove) 
exception handling features to your code.

In your code you simply load MooseX::Exception and specify which features
to load. (Note: You class does not have to use Moose itself)

 package MyClass;
 use MooseX::Exception 'Define', 'MyFeature' => { some_arg => 1 };

Later you can also unload selected features

 no MooseX::Exception qw(Define);

All exceptions thrown by any of the MooseX::Exception features is based
on L<MooseX::Exception::Base>, thus providing an unified exception
hierarchy.

MooseX::Exception currently implements five convinient exception features.

=over

=item * Autodie

Enables L<autodie> in the current scope, however if an exception occurs it
will throw a L<MooseX::Exception::Autodie> exception instead of an 
L<autodie::exception> exception.

see <MooseX::Exception::Feature::Autodie>

=item * Define

This feature lets you define exception classes in a very compact way, 
just like L<Exception::Class>. You can use almost all Moose functions like
has, with and method modifiers in your exception class definitions.

 use MooseX::Exception qw(Define);
 
 exception "X" => define {
    # calls extends('MooseX::Exception::Base') implicitly
    with('Location');
    description('basic exception');
 };
 
 exception "X2" => define {
    extends('X');
    description('slightly advanced exception');
    has 'test' => (is => 'rw');
    method 'some_method' => sub { ... };
 };

see <MooseX::Exception::Feature::Define>

=item * Moose

The 'Moose' feature tells Moose to throw L<MooseX::Exception::Moose>
if an error occurs in your metaclass (eg. constraints not satisfied, 
required value missing, ...)

This feature can only be used if the calling package is using Moose. 

see <MooseX::Exception::Feature::Moose>

=item * TryCatch

Enables a slightly extended version of L<Try-Tiny> in your package that allows
conditional catch blocks. Furthermore all exceptions thrown inside a try
block will be upgraded to L<MooseX::Exception::TryCatch> exceptions if
possible.

 use MooseX::Exception qw(TryCatch);
 
 try {
     X1->throw(message => 'Exception X');
 }
 where "X2" => catch {
     say "Caught X2 exception";
 }
 where "X1" => catch {
     say "Caught X1 exception";
 }
 catch {
     say "Caught some exception";
 }
 finally {
     say "This will be always run";
 };
 
see <MooseX::Exception::Feature::TryCatch>

=item * Die



=back

=head1 EXTENDING



=head1 CAVEATS 

=head1 SEE ALSO

Most idead and concepts are borrowed from other distributions such as 
L<Try-Tiny>, L<Exception-Class>, L<Autodie> and many more.

=head1 SUPPORT

Please report any bugs or feature requests to 
C<bug-moosex-exception@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=MooseX-Exception>.
I will be notified, and then you'll automatically be notified of progress on 
your report as I make changes.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=head1 COPYRIGHT

MooseX::Exception is Copyright (c) 2011-12 Maroš Kollár.

This library is free software and may be distributed under the same terms as 
perl itself.

The full text of the license can be found in the LICENSE file included with 
this module.

=cut

1;