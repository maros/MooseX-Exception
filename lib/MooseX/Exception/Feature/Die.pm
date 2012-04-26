# ============================================================================
package MooseX::Exception::Feature::Die;
# ============================================================================
use utf8;

use strict;
use warnings;

use MooseX::Exception::Die;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => [ 'die' ],
);

sub die(@) {
    my ($caller,@args) = @_;
    
    my $message;
    if (scalar @args > 1) {
        $message = join('',@args);
    } else {
        $message = $args[0];
    }

    if (ref $message) {
        die($message);
    } else {
        my $exception_class = MooseX::Exception->_exception_settings_for($caller,__PACKAGE__)->{exception_class} || "MooseX::Exception::Die";
        $exception_class->new($message)->throw;
    }
}

1;