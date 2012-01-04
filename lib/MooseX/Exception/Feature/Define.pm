# ============================================================================
package MooseX::Exception::Feature::Define;
# ============================================================================
use utf8;

use Moose::Exporter;
use Moose qw(inner);

use Carp 'confess';
use Scalar::Util 'blessed';

our $EXCEPTION_CLASS; # TODO customize
our @EXCEPTION_ROLES;
our $EXCEPTION_BASE = 'MooseX::Exception::Base'; # TODO customize

Moose::Exporter->setup_import_methods(
    #with_caller => [qw(has description method  requires excludes before after around override inner super)],
    with_caller => [qw(description method with)],
    as_is       => [qw(define exception blessed confess)],
);

sub init_meta {
    shift;
    my %params = @_;
    
    #warn('INIT META WITH '.join ',',map { defined $_ ? $_ : 'undef'}@_);
    my $meta_class = Moose->init_meta( @_ );
    foreach my $method_name (qw(has extends requires excludes before after around override inner super)) {
        my $fq_name = $params{for_class} . '::' . $method_name;
        $meta_class->add_package_symbol('&'.$method_name,sub {
            my $meta = $EXCEPTION_CLASS || $meta_class;
            my $method_fqn = 'Moose::'.$method_name;
            no strict 'refs';
            &{$method_fqn}($meta,@_);
        });
    }
    return $meta_class;
}

sub exception ($;$) {
    my ($class,$code) = @_;
    
    my $meta = Moose::Meta::Class->create($class);
    $meta->add_method( meta => sub { $meta } );
    
    # Run code
    if (defined $code) {
        local @EXCEPTION_ROLES = ();
        local $EXCEPTION_CLASS = $meta;
        $code->($meta);
        unless (grep { $_ eq $EXCEPTION_BASE } $meta->linearized_isa()) {
            my @superclasses = $meta->superclasses;
            push(@superclasses,$EXCEPTION_BASE);
            $meta->superclasses(@superclasses);
        }
        if (scalar @EXCEPTION_ROLES) {
#            warn join "::::",@EXCEPTION_ROLES;
            Moose::Util::apply_all_roles($meta,@EXCEPTION_ROLES);
        }
    } else {
        $meta->superclasses($EXCEPTION_BASE);
    }
    
    $meta->make_immutable();
}

sub define (&;@) {
    my ($code) = @_;
    return $code;
}

sub description {
    my ($caller,$description) = @_;
    
    confess "'description' may not be used outside of the exception blocks"
        unless defined $EXCEPTION_CLASS;
    
    $EXCEPTION_CLASS->add_method('description',sub { return $description })
}

sub with {
    my ($caller,@roles) = @_;
    
    if (defined $EXCEPTION_CLASS) {
        foreach my $element (@roles) {
            unless (ref $element) {
                if ($element =~ m/^\+(.+)$/) {
                    push(@EXCEPTION_ROLES,$1);
                } elsif ($element !~ /.+::.+/) {
                    push(@EXCEPTION_ROLES,'MooseX::Exception::Role::'.$element);
                } else {
                    push(@EXCEPTION_ROLES,$element);
                }
            } else {
                push(@EXCEPTION_ROLES,$element);
            }
        }
    } else {
        Moose::Util::apply_all_roles($caller,@roles);
    }
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

1;

=encoding utf8

=head1 NAME

MooseX::Exception::Feature::Define - Define exception classes in a consise way

=head1 SYNOPSIS

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
 
 exception "X3";

=head1 DESCRIPTION

This feature lets you define exception classes in a very compact way, 
just like L<Exception::Class>. You can use almost all Moose functions like
has, with and method modifiers in your exception class definitions.

=head1 EXPORTED FUNCTIONS

=head3 exception

 exception $name;
 OR
 exception $name => define { ... };

Defines an exception class. If not stated otherwise all exception classes
generated this way will inherit from L<MooseX::Exception::Base> and be
immutable.

=head1 FUNCTIONS WITHIN EXCEPTION CLASSES

L<Moose> functions like has, extends, requires, excludes, before, after,
around, override, inner and super works just as they do in an ordinary 
Moose class.

=head3 with

This function loads roles into exception classes - just like in vanilla 
Moose - however 'MooseX::Exception::Role::' is prepended to the role
name unless you use a fully quallified package name or add a plus sign
at the begining of the role name (eg. 'MooseX::Exception::Role::Location' or 
'+MyExceptionRole')

=head3 method

 method 'some_method' => sub { ... };

Unfortunately you cannot add method with the standard syntax 
(C<sub { ... }>). Therefore if you want to use this special sytax if you 
want to add custom methods to your exception classs.

=head3 description

Lets you add a description of the exception class.

=head1 SEE ALSO

L<Exception::Class>, L<MooseX::Exception::Base>

=cut