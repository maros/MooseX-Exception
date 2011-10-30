# ============================================================================
package MooseX::Exception::Feature::TryCatch;
# ============================================================================
use utf8;

use Moose::Exporter;
use MooseX::Exception::TryCatch;

use Scalar::Util qw(blessed);

Moose::Exporter->setup_import_methods(
    as_is       => [qw(try catch where finally)],
);

sub try(&;@) {
    my ($try,@parts) = @_;
    
    # Store requested context
    my $wantarray = wantarray;
    
    my ( @catch_where, $catch_all, @finally, $current_where_condition );
    
    # Get all defined parts
    foreach my $part (@parts) {
        next 
            unless $part;
        
        my $reference = ref($part);
        
        if ( $reference eq 'MooseX::Exception::Feature::TryCatch::Where' ) {
            if (defined $current_where_condition) {
                MooseX::Exception::TryCatch->throw('Detected unbalanced where/catch blocks');
            }
            $current_where_condition = $$part;
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Catch' ) {
            if (defined $current_where_condition) {
                push(@catch_where,[ $current_where_condition,$$part ]);
                undef $current_where_condition;
            } elsif (defined $catch_all) {
                MooseX::Exception::TryCatch->throw('Detected multiple catch blocks');
            } else {
                $catch_all = $$part
            }
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Finally' ) {
           push(@finally,$$part);
        } else {
            MooseX::Exception::TryCatch->throw("Unknown part given '$reference'");
        }
    }
    
    # Store previous error
    my $previous_error = $@;
    
    my ( @ret, $failed, $error );
    
    {
        local $@;
        
        $failed = not eval {
            $@ = $previous_error;
            
            # evaluate the try block in the correct context
            if ( $wantarray ) {
                @ret = $try->();
            } elsif ( defined $wantarray ) {
                $ret[0] = $try->();
            } else {
                $try->();
            };
            
            return 1; # properly set $fail to false
        };
        $error = $@;
    }
    
    # Handle error
    if ($failed) {
        unless (ref $error)  {
            $error = MooseX::Exception::X::TryCatch->new( 
                error   => $error,
            );
        }
        foreach ($error) {
            if (blessed $error) {
                foreach my $catch_where (@catch_where) {
                    if ($error->isa($catch_where->[0])) {
                        _run_block($catch_where->[1],@finally);
                        return;
                    }
                }
            }
            if ($catch_all) {
                _run_block($catch_all);
            }
            _run_block(@finally);
            return;
        }
    }
    
    _run_block(@finally);
    return $wantarray ? @ret : $ret[0];
}

sub catch(&;@) {
    my ($code,@rest) = @_;
    return (
        bless(\$code, 'MooseX::Exception::Feature::TryCatch::Catch'),
        @rest,
    );
}

sub finally(&;@) {
    my ($code,@rest) = @_;
    return (
        bless(\$code, 'MooseX::Exception::Feature::TryCatch::Finally'),
        @rest,
    );
}

sub where($;@) {
    my ($where,@rest) = @_;
    return (
        bless(\$where, 'MooseX::Exception::Feature::TryCatch::Where'),
        @rest,
    );
}

sub _run_block {
    my (@code_blocks) = @_;
    
    foreach my $code (@code_blocks) {
        $code->();
    }
}

1;


#sub try (&;@) {
#    my ($code,@e) = @_;
#}
#
#sub catch (&;$) {
#    my ($code) = @_;
#}
#
#sub finally (&;$) {
#    my ($code) = @_;
#}


#
#try {
#    die('XXX');
#}
#catch {
#    #do something
#}
#finally {
#    # cleanup
#}
#
#try {
#    die('XXX');
#}
#catch {
#    isa($_)
#}
#finally {
#    # cleanup
#}



#my ( $error, $failed, @ret );
#
#my $wantarray = wantarray;
#
#{
#    local $@;
#
#    $failed = not eval {
#
#        # note code duplication
#        if ( $wantarray ) {
#            @ret = ...;
#        } elsif ( defined $wantarray ) {
#            $ret[0] = ...;
#        } else {
#            ...;
#        }
#  
#        return 1;
#    };
#
#    $error = $@;
#}
#
#if ( $failed ) {
#    warn $error;
#} else {
#    return $wantarray ? @value : $ret[0];
#}

1;