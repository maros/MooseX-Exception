# ============================================================================
package MooseX::Exception::Feature::Moose;
# ============================================================================
use utf8;

use Moose::Exporter;
use MooseX::Exception::Moose;

Moose::Exporter->setup_import_methods();

sub init_meta {
    my ($class, %args) = (shift, @_);
    
    my $meta = Moose->init_meta(%args);
    $meta->error_class("MooseX::Exception::Moose");
    
    return $meta;
}

1;