package MooseX::Orochi;
use Moose qw(confess);
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_meta => [ qw(bind_constructor bind_inherited inject) ],
    as_is     => [ qw(bind_value) ],
);

sub init_meta {
    shift;
    my %args = @_;

    my $meta = Moose::Util::find_meta( $args{for_class} );

    if ($meta->isa('Moose::Meta::Role')) {
        $meta = Moose::Meta::Role
            ->initialize('MooseX::Orochi::Meta::Class')
            ->apply( $meta )
        ;
    } else {
        Moose::Util::MetaRole::apply_metaclass_roles(@_,
            metaclass_roles => [ 'MooseX::Orochi::Meta::Class' ]
        );
    }
    $meta;
}

sub bind_constructor ($;%) {
    my ($meta, $path, %args) = @_;
    $meta->bind_path($path);

    my $class = $args{injection_class} || 'Constructor';
    if ($class !~ s/^\+//) {
        $class = "Orochi::Injection::$class";
    }

    if (! Class::MOP::is_class_loaded( $class ) ) {
        Class::MOP::load_class($class);
    }

    if (! $class->isa('Orochi::Injection::Constructor')) {
        confess "$class is not a Orochi::Injection::Constructor subclass";
    }
    $meta->bind_injection( $class->new(%args, class => $meta->name) );
}

sub bind_value ($) {
    my ($path) = @_;
    return Orochi::Injection::BindValue->new(bind_to => $path);
}

sub bind_inherited (;$) {
    my ($meta, $class) = @_;

    my $from_meta;
    if ($class) {
        $from_meta = Moose::Util::find_meta($class);
    } else {
        foreach my $p ( $meta->linearized_isa ) {
            next if $p eq $meta->name;
            if ( Moose::Util::does_role( $p->meta, 'MooseX::Orochi::Meta::Class' ) ) {
                $from_meta = $p->meta;
                last;
            }
        }
    }

    foreach my $attr qw(bind_path bind_injection injections) {
        my $value = $from_meta->$attr();
        $meta->$attr( $value ) if defined $value;
    }
}

sub inject ($$) {
    my ($meta, $path, $inject) = @_;
    $meta->add_injections( $path => $inject );
}

1;

__END__

=head1 NAME

MooseX::Orochi - Annotated Your Moose Classes With Orochi

=head1 SYNOPSIS

    package MyApp::MyClass;
    use Moose;
    use MooseX::Orochi;

    bind_constructor '/myapp/myclass' => (
        args => {
            arg1 => bind_value '/myapp/some/dep1',
            arg2 => bind_value '/myapp/some/dep2',
        }
    );

    # you can also inject random things
    inject '/foo/bar/baz' => Orochi::Injection::Constructor->new(
        class => 'FooBar',
        args  => { ... }
    );

    has arg1 => (...);
    has arg2 => (...);

    # Then, somewhere in your main code...

    my $c = Orochi->new_with_traits(
        traits => [ 'Assembler::Moose' ],
    );
    $c->inject_class( 'MyApp::MyClass' );

    my $object = $c->get( '/myapp/myclass' );

=cut
