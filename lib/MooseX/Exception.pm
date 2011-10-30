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

sub import {
    my ($proto,@features_requested) = @_;
    
    # Get caller and class
    my $class = ref $proto || $proto;
    my( $package, undef, undef) = caller;
    
    my $export_name = $package."::moosex_exception_features_loaded";
    
    {
        no strict 'refs';
        unless (defined ${$export_name}) {
            *{$export_name} = {};
        }
    }
    my (%features_toload,$feature_toload_last);
    
    # Determine which features to load
    GET_FEATURE:
    foreach my $feature_requested (@features_requested) {
        if (ref $feature_requested eq 'ARRAY') {
            if (defined $feature_toload_last) {
                $features_toload{$feature_toload_last} = $feature_requested;
            }
        } else {
            if ($feature_requested eq ':all') {
                foreach my $feature_all (__PACKAGE__->features_available) {
                    $features_toload{$feature_all} = [];
                }
            } else {
                my $feature_class = 'MooseX::Exception::Feature::'.ucfirst($feature_requested);
                $features_toload{$feature_class} = [];
                $feature_toload_last = $feature_class;
            }
        }
    }
    
    # Load all selected features
    LOAD_FEATURE: 
    foreach my $feature_toload (keys %features_toload) {
        no strict 'refs';
        next LOAD_FEATURE
            if (exists ${$export_name}->{$feature_toload});
        ${$export_name}->{$feature_toload} = 1;
        
        Class::MOP::load_class($feature_toload);
        
        # Reset arguments for goto
        @_ = ($feature_toload,@{$features_toload{$feature_toload}});
        
        goto &{$feature_toload.'::import'};
    }
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

package MooseX::Exception;


=encoding utf8

=head1 NAME

TEMPLATE - Description

=head1 SYNOPSIS

  use TEMPLATE;

=head1 DESCRIPTION

=head1 METHODS

=head2 Constructors

=head2 Accessors 

=head2 Methods

=head1 EXAMPLE

=head1 CAVEATS 

=head1 SEE ALSO

=head1 SUPPORT

Please report any bugs or feature requests to 
C<bug-TEMPLATE@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=TEMPLATE>.  
I will be notified, and then you'll automatically be notified of progress on 
your report as I make changes.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=head1 COPYRIGHT

TEMPLATE is Copyright (c) 2010 Maroš Kollár.

This library is free software and may be distributed under the same terms as 
perl itself.

The full text of the license can be found in the LICENSE file included with 
this module.

=cut

1;