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

#exception 'MooseX::Exception::Exception::Base' => sub{
#    description('Internal MooseX::Exception');
#};
#
#sub super {
#    return unless $Moose::SUPER_BODY;
#    $Moose::SUPER_BODY->(@Moose::SUPER_ARGS);
#}

1;