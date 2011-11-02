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
                MooseX::Exception::TryCatch->throw('Detected unbalanced where/catch blocks'); # TODO customize
            }
            $current_where_condition = $$part;
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Catch' ) {
            if (defined $current_where_condition) {
                push(@catch_where,[ $current_where_condition,$$part ]);
                undef $current_where_condition;
            } elsif (defined $catch_all) {
                MooseX::Exception::TryCatch->throw('Detected multiple catch blocks'); # TODO customize
            } else {
                $catch_all = $$part
            }
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Finally' ) {
           push(@finally,$$part);
        } else {
            MooseX::Exception::TryCatch->throw("Unknown part given '$reference'"); # TODO customize
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
    
    @finally = map { MooseX::Exception::Feature::TryCatch::ScopeGuard->_new($_,$failed ? $error:()) } @finally;
    
    # Handle error
    if ($failed) {
        unless (ref $error)  {
            $error = MooseX::Exception::TryCatch->new( 
                error   => $error,
            ); # TODO customize
        }
        foreach ($error) {
            if (blessed $error) {
                foreach my $catch_where (@catch_where) {
                    if ($error->isa($catch_where->[0])) {
                        return $catch_where->[1]->($error);
                    }
                }
            }
            if ($catch_all) {
               return  $catch_all->($error);
            }
            return;
        }
    }
    
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

{
    package # hide from PAUSE
        MooseX::Exception::Feature::TryCatch::ScopeGuard;
    
    sub _new {
        shift;
        bless [ @_ ];
    }
    
    sub DESTROY {
        my ($self) = @_; 
        my $code = shift(@{$self});
        $code->(@$self);
    }
}

1;