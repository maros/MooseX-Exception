# ============================================================================
package MooseX::Exception::Feature::Die;
# ============================================================================
use utf8;

use strict;
use warnings;

use MooseX::Exception::Die;
use Moose::Exporter;

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
        MooseX::Exception::Die->new($message)->throw;
    }
}

Moose::Exporter->setup_import_methods(
    as_is     => [ 'die' ],
);

1;