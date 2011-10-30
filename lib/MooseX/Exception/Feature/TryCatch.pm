# ============================================================================
package MooseX::Exception::Feature::TryCatch;
# ============================================================================
use utf8;

use Moose::Exporter;
#use MooseX::Exception;
use MooseX::Exception::TryCatch;

Moose::Exporter->setup_import_methods(
    as_is       => [qw(try catch where finally)],
);
#
#exception 'MooseX::Exception::Exception::TryCatch' => sub{
#    extends('Internal MooseX::Exception::Base');
#    description('Wrong TryCatch usage');
#};

sub try(&;@) {
    my ($code,@parts) = @_;
    
    my $wantarray = wantarray;
    
    my ( @catch_where, $catch_all, $finally, $where_condition );
    
    foreach my $part (@parts) {
        next 
            unless $part;
        
        my $reference = ref($part);
        
        if ( $reference eq 'MooseX::Exception::Feature::TryCatch::Where' ) {
            if (defined $where_condition) {
                MooseX::Exception::Exception::TryCatch->throw('Detected unbalanced where/catch blocks');
            }
            $where_condition = $part;
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Catch' ) {
            if (defined $where_condition) {
                push(@catch_where,[ $where_condition,$part ]);
                undef $where_condition;
            } elsif (defined $catch_all) {
                MooseX::Exception::Exception::TryCatch->throw('Detected multiple catch blocks');
            } else {
                $catch_all = $part
            }
        } elsif ( $reference eq 'MooseX::Exception::Feature::TryCatch::Finally' ) {
            if (defined $finally) {
                MooseX::Exception::Exception::TryCatch->throw('Detected multiple finally blocks');
            }
            warn('SET FINALLY');
            $finally = $part;
        } else {
            MooseX::Exception::Exception::TryCatch->throw("Unknown part given '$reference'");
        }
    }
    
    use Data::Dumper;
    warn Dumper {
        try         => $code,
        catch_where => \@catch_where,
        catch_all   => $catch_all,
        finally     => $finally,
    };
    
    warn 'CALLED TRY WITH '."\n".join "\n",@_;
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