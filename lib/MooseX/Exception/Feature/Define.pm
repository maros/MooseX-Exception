# ============================================================================
package MooseX::Exception::Feature::Define;
# ============================================================================
use utf8;

use Moose::Exporter;
use Moose qw(inner);

use Carp 'confess';
use Scalar::Util 'blessed';

our $EXCEPTION_CLASS;
our $EXCEPTION_BASE = 'MooseX::Exception::Base';

Moose::Exporter->setup_import_methods(
    #with_caller => [qw(has description method with requires excludes before after around override inner super)],
    with_caller => [qw(description method)],
    as_is       => [qw(exception blessed confess with)],
);

sub init_meta {
    shift;
    my %params = @_;
    
    warn('INIT META WITH '.join ',',map { defined $_ ? $_ : 'undef'}@_);
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

sub with {
    my ($caller,@c)
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