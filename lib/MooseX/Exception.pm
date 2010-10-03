# ============================================================================
package MooseX::Exception;
# ============================================================================

use Moose::Exporter;
use Moose qw(inner);

use version;
our $AUTHORITY = 'cpan:MAROS';
our $VERSION = version->new("1.00");

use Carp 'confess';
use Scalar::Util 'blessed';

our $EXCEPTION_CLASS;
our $EXCEPTION_BASE = 'MooseX::Exception::Base';

Moose::Exporter->setup_import_methods(
    #with_caller => [qw(has description extends method with requires excludes before after around override inner super)],
    with_caller => [qw(description method)],
    as_is       => [qw(exception blessed confess)],
);

sub init_meta {
    shift;
    my %params = @_;
    
    warn('INIT META WITH '.join ',',map { defined $_ ? $_ : 'undef'}@_);
    my $meta_class = Moose->init_meta( @_ );
    foreach my $method_name (qw(has extends with requires excludes before after around override inner super)) {
        my $fq_name = $params{for_class} . '::' . $method_name;
        $meta_class->add_package_symbol('&'.$method_name,sub {
            my $meta = $EXCEPTION_CLASS || $meta_class;
            my $method_fqn = 'Moose::'.$method_name;
            no strict 'refs';
            &{$method_fqn}($meta,@_);
        });
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

sub caught {
    my $exception = $@;
    
    return $exception 
        unless $_[1];
    
    return unless blessed($exception) && $exception->isa( $_[1] );
    return $exception;

}

sub exception ($&) {
    my ($class,$code) = @_;
    my $meta = Moose::Meta::Class->create($class);
    $meta->add_method( meta => sub { $meta } );
    
    # Run code
    {
        local $EXCEPTION_CLASS = $meta;
        $code->($meta);
    }
    
    unless (grep { $_ eq $EXCEPTION_BASE } $meta->linearized_isa()) {
        my @superclasses = $meta->superclasses;
        push(@superclasses,$EXCEPTION_BASE);
        $meta->superclasses(@superclasses);
    }

    $meta->make_immutable();
}

sub description {
    my ($caller,$description) = @_;
    
    confess "'description' may not be used outside of the exception blocks"
        unless defined $EXCEPTION_CLASS;
    
    $EXCEPTION_CLASS->add_method('description',sub { return $description })
}

sub method {
    my ($caller,$name,$body) = @_;
    my $meta = $EXCEPTION_CLASS || Class::MOP::class_of($caller);
    my $method = $meta->method_metaclass->wrap(
        package_name => $caller,
        name         => $name,
        body         => $body,
    );
    $meta->add_method($name => $method);
}

exception 'MooseX::Exception::Exception::Base' => sub{
    description('Internal MooseX::Exception');
};

#sub super {
#    return unless $Moose::SUPER_BODY;
#    $Moose::SUPER_BODY->(@Moose::SUPER_ARGS);
#}

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