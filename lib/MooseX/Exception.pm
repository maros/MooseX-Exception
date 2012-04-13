# ============================================================================
package MooseX::Exception;
# ============================================================================

use strict;
use warnings;

our $AUTHORITY = 'cpan:MAROS';
our $VERSION = '1.00';

use Moose::Exporter;

my ($IMPORT,$UNIMPORT,$INIT_META) = Moose::Exporter->build_import_methods(
    install             => [qw(init_meta)],
);

my %PLUGIN_SPEC;

sub import {
    my ( $class, @plugins ) = @_;
    
    # Get caller
    my ($caller_class) = caller();
    
    # Loop all requested plugins
    my (%plugin_classes,$last_plugin);
    foreach my $element (@plugins) {
        if (ref $element) {
            if (defined $last_plugin) {
                $plugin_classes{$last_plugin} = $element;
            } else {
                croak('Something is wrong here');
            }
        } else {
            my $plugin_class = 'MooseX::Exception::Feature::'.$element;
            
            Class::Load::load_class($plugin_class);
            
            $plugin_classes{$plugin_class} = [];
            $last_plugin = $element;
        }
    }
    
    # Store plugin spec
    $PLUGIN_SPEC{$caller_class} = \%plugin_classes;
    
    # Call Moose-Exporter generated importer
    $class->$IMPORT( { into => $caller_class } );
    
    # Call importer foll all feature classes
    foreach my $plugin_class (keys %plugin_classes) {
        $plugin_class->import( { into => $caller_class, params => $plugin_classes{$plugin_class} } );
    }
}

sub unimport {
    my ( $class, @plugins ) = @_;


    # Get caller
    my ($caller_class) = caller();
    
warn "UNIMPORT $class FROM $caller_class";
    
    unless (scalar @plugins) {
        @plugins = keys %{$PLUGIN_SPEC{$caller_class}};    
    }
    
    # Loop all requested plugins
    foreach my $element (@plugins) {
        my $plugin_class = 'MooseX::Exception::Feature::'.$element;
        
        if (delete $PLUGIN_SPEC{$caller_class}{$plugin_class}) {
            $plugin_class->unimport($caller_class);
        }
    }
    
    if (scalar keys %{$PLUGIN_SPEC{$caller_class}} == 0) {
        $class->$UNIMPORT($caller_class);
        delete $PLUGIN_SPEC{$caller_class};
    }
}
#
#
#sub unimport {
#    my ($proto,@features_requested) = @_;
#    
#    # Get caller and class
#    my( $package, undef, undef) = caller(0);
#    
#    # Get symbol
#    my $features_loaded = _get_caller_symbols($package);
#    
#    # Try to get list of features to unload
#    if (scalar @features_requested) {
#        @features_requested = map { 'MooseX::Exception::Feature::'.$_ } @features_requested;
#    } else {
#        @features_requested = keys %{$features_loaded}
#    }
#    
#    # Loop all features that should be unloaded
#    foreach my $feature_class (@features_requested) {
#        next
#            unless defined $features_loaded->{$feature_class};
#        
#        $package->moosex_exception_caller($feature_class,'unimport');
#        
#        delete $features_loaded->{$feature_class};
#    }
#    
#    
#    # Unload our symbols if all features have been unloaded
#    if (scalar keys %{$features_loaded} == 0) {
#        my $stash = Package::Stash->new($package);
#        $stash->remove_symbol('%moosex_exception_features_loaded');
#        $stash->remove_symbol('&moosex_exception_caller');
#    }
#}
#
#sub import {
#    my ($proto,@args) = @_;
#    
#    # Get caller and class
#    my( $package ) = caller();
#    
#    # Get symbol
#    my $features_loaded = _get_caller_symbols($package);
#    
#    my (%features_toload,$feature_toload_last);
#    
#    # Determine which features to load
#    foreach my $element (@args) {
#        # Extra arguments
#        if (ref $element) {
#            if (defined $feature_toload_last) {
#                $features_toload{$feature_toload_last} = $element;
#            }
#        # Feature
#        } else {
#            my $feature_class = 'MooseX::Exception::Feature::'.ucfirst($element); # TODO camel case
#            $features_toload{$feature_class} ||= {};
#            $feature_toload_last = $feature_class;
#        }
#    }
#    
#    # Load all selected features
#    foreach my $feature_class (keys %features_toload) {
#        # Check if feature is already loaded
#        next
#            if (exists $features_loaded->{$feature_class});
#        
#        $features_loaded->{$feature_class} = $features_toload{$feature_class};
#        Class::Load::load_class($feature_class);
#        
#        $package->moosex_exception_caller($feature_class,'import',$features_toload{$feature_class});
#    }
#}
#
#sub _get_caller_symbols {
#    my ($package) = @_;
#    
#    my $stash = Package::Stash->new($package);
#    
#    # Check if our symbols already exist
#    unless ($stash->has_symbol('%moosex_exception_features_loaded')) {
#        my($filename);
#        for my $level (0..10) {
#            my ($caller_package,$caller_filename) = caller($level);
#            if ($caller_package eq $package) {
#                $filename = $caller_filename;
#                last;
#            }
#        }
#        
#        #TODO: Die if $filename is empty
#        
#        unless ($stash->has_symbol('&moosex_exception_caller')) {
#            # ugly hack to ensure correct caller
#            my $exception_callback = 'package '.$package.' {
#                sub moosex_exception_caller {
##line 1 "'.$filename.'"
#                    my $self = shift;
#                    my $class = shift;
#                    my $method = shift;
#                    $class->$method(@_);
#                }
#            }';
#            eval($exception_callback);
#        }
#        $stash->add_symbol('%moosex_exception_features_loaded',{ });
#    }
#    
#    return $stash->get_symbol('%moosex_exception_features_loaded');
#}



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

Will upgrade all exceptions originationg from the current class to 
L<MooseX::Exception::Die> if possible.

see <MooseX::Exception::Feature::Die>

=back

=head1 EXTENDING

There are multiple ways how to extend MooseX::Exception

=over

=item * Extend the exception hierarchy by adding your own exceptions classes

=item * Implement reusable roles for exception classes

=item * Implement an exception feature

=back

The first two options are pretty straightforward: Just write a class/role that
extends or augments L<MooseX::Exception::Base> or any of its subclasses.
The "Define" (L<MooseX::Exception::Feature::Define>) feature helps you to 
write exception clasesses in a very concise way. Exception roles should reside
in the C<MooseX::Exception::Role::*> namespace.

When you are writing exception classes there are already few useful reusable 
exception roles that you can use:

=over

=item * L<MooseX::Exception::Role::Counter>

=item * L<MooseX::Exception::Role::Location>

=item * L<MooseX::Exception::Role::ProcessInfo>

=item * L<MooseX::Exception::Role::Trace>

=back

Exception features are a little bit trickier to write since you need
to implement an import and unimport function. L<Moose::Exporter> certainly 
makes this task much easier.

=head1 CAVEATS 

=head1 SEE ALSO

Most concepts and even some code parts are borrowed from other distributions 
such as L<Try-Tiny>, L<TryCatch>, L<Exception-Class>, L<autodie>.

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