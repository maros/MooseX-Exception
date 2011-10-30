# ============================================================================
package MooseX::Exception::Feature::Autodie;
# ============================================================================
use utf8;

use strict;
use warnings;

use MooseX::Exception::Autodie;

use autodie ();
our @ISA = qw(autodie);

sub exception_class { return "MooseX::Exception::Autodie" };

sub import {
    goto &autodie::import;
}

sub unimport {
    goto &autodie::unimport;
}

1;