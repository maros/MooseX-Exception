# ============================================================================
package MooseX::Exception::Feature::Die;
# ============================================================================
use utf8;

use strict;
use warnings;

use MooseX::Exception::Die;
use Moose::Exporter;

sub exception_class { return "MooseX::Exception::Die" }; # TODO customize

sub die {
    my (@args) = @_;
    
    my $message;
    if (scalar @args > 1) {
        $message = join('',@args);
    } else {
        $message = $args[0];
    }

    if (ref $message) {
        die($message);
    } else {
        my $exception_class = exception_class();
        $exception_class->new($message)->throw;
    }
}

Moose::Exporter->setup_import_methods(
    as_is     => [ 'die' ],
);

1;