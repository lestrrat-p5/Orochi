package MooseX::Orochi;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_meta => [ qw(bind_to inject) ],
    as_is     => [ qw(bind_value) ],
);

sub init_meta {
    shift;
    my $meta = Moose->init_meta(@_);
    Moose::Util::MetaRole::apply_metaclass_roles(@_,
        metaclass_roles => [ 'MooseX::Orochi::Meta::Class' ]
    );
    $meta;
}

sub bind_to ($) {
    my ($meta, $path) = @_;
    $meta->bind_to($path);
}

sub bind_value ($) {
    my ($path) = @_;
    return Orochi::Injection::BindValue->new(bind_to => $path);
}

sub inject ($%) {
    my ($meta, $class, %args) = @_;

    if ($class !~ s/^\+//) {
        $class = "Orochi::Injection::$class";
    }

    if (! Class::MOP::is_class_loaded( $class ) ) {
        Class::MOP::load_class($class);
    }

    if ($class->isa('Orochi::Injection::Constructor') ||
        $class->isa('Orochi::Injection::Constructor') ) {
        $args{class} ||= $meta->name;
    }

    $meta->injection( $class->new(%args) );
}
        
1;
