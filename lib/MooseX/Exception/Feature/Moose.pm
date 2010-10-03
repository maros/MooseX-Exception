# ============================================================================
package MooseX::Exception::Feature::Moose;
# ============================================================================
use utf8;

use Moose ();
use Moose::Exporter;
#use Moose::Util::MetaRole;
#
#Moose::Exporter->setup_import_methods();
#
#sub init_meta {
#    my ($class, %args) = (shift, @_);
#    
#    Moose->init_meta(%args);
#    
#    Moose::Util::MetaRole::apply_metaroles(
#        for             => $args{for_class},
#        class_metaroles => {
#            attribute => ['DBIx::Class::MooseColumns::Meta::Attribute'],
#        },
#    );
#    
#    return $args{for_class}->meta;
#}
#
#use MooseX::Exception(
#    'MooseX::Exception::Moose'  => {
#        description   => 'Class error',
#        fields        => [qw(method depth evaltext sub_name last_error sub is_require has_args)],
#    },
#); 
#
#sub new {
#    my ( $self, %params ) = @_;
#    
#    my $exception = MooseX::Exception::Moose->new( 
#        error       => $params{message},
#        method      => $params{method},
#        depth       => $params{depth},
#        evaltext    => $params{evaltext},
#        sub_name    => $params{sub_name},
#        last_error  => $params{last_error},
#        sub         => $params{sub},
#        is_require  => $params{is_require},
#        has_args    => $params{has_args},
#    );
#    $exception->{line} = $params{line};
#    $exception->{package} = $params{pack};
#    $exception->{filename} = $params{file};
#    
#    $exception->rethrow();
#}

1;