package Orochi;
use Moose;
use namespace::clean -except => qw(meta);
use Orochi::Injection::BindValue;
use Orochi::Injection::Constructor;
use Orochi::Injection::Literal;
use Path::Router;
use constant DEBUG => ($ENV{OROCHI_DEBUG});

with 'MooseX::Traits';

has '+_trait_namespace' => (
    default => __PACKAGE__
);

has prefix => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_prefix',
);

has router => (
    is         => 'ro',
    isa        => 'Path::Router',
    lazy_build => 1,
);

sub _build_router {
    return Path::Router->new();
}

sub get {
    my ($self, $path) = @_;

    $path = $self->mangle_path( $path );
    my $matched = $self->router->match( $path );
    if ( $matched ) {
        return $matched->target->expand( $self );;
    }
    return ();
}

sub mangle_path {
    my ($self, $path) = @_;
    if ( my $prefix = $self->prefix ) {
        if ($path !~ /^\//) {
            if ($prefix !~ /\/$/) {
                $prefix .= '/';
            }
            $path = $prefix . $path;
        }
    }
    return $path;
}
        
sub inject {
    my ($self, $path, $injection) = @_;

    confess "no path specified" unless $path;

    $path = $self->mangle_path($path);

    if (DEBUG()) {
        print STDERR "Injecting $path\n";
    }
    $self->router->insert_route($path => (target => $injection));
}

sub bind_value {
    my ($self, $path) = @_;

    my $value;
    if (blessed $path) {
        if (! $path->isa('Orochi::Injection::BindValue')) {
            confess "inject_vind_value requires a Orochi::Injection::BindValue object";
        }
        $value = $path;
    } else {
        $value = Orochi::Injection::BindValue->new(bind_to => $path);
    }
    return $value;
}

sub inject_constructor {
    my ($self, $path, @args) = @_;

    my $injection;
    if (@args == 1) {
        if (! blessed $args[0] || ! $args[0]->isa('Orochi::Injection::Constructor') ) {
            confess "inject_constructor requires a Orochi::Injection::Constructor object";
        }
        $injection = $args[0];
    } else {
        $injection = Orochi::Injection::Constructor->new(@args);
    }
    $self->inject($path, $injection);
    return $injection;
}

sub inject_literal {
    my ($self, $path, @args) = @_;

    my $injection;
    if (@args == 1) {
        if (blessed $args[0] && $args[0]->isa('Orochi::Injection::Literal') ) {
            $injection = $args[0];
        }
    };

    if (! $injection) {
        $injection = Orochi::Injection::Literal->new(@args);
    }
    $self->inject($path, $injection);
    return $injection;
}

sub inject_class {
    my ($self, $class) = @_;

    if (! Class::MOP::is_class_loaded($class)) {
        Class::MOP::load_class($class);
    }

    my $meta = Moose::Util::find_meta($class);
    if (! Moose::Util::does_role($meta, 'MooseX::Orochi::Meta::Class')) {
        # Silently drop?
        # confess "$class does not implement MooseX::Orochi";
        return;
    }

    if (! $meta->bind_path ) {
        Carp::cluck( "No bind_path specified for $class. Did you specify it via bind_constructor?" );
        return;
    } 

    if (! $meta->bind_injection ) {
        Carp::cluck( "No bind_injection specified for $class. Did you specify it via bind_constructor?" );
        return;
    } 

    $self->inject( $meta->bind_path, $meta->bind_injection );

    my $injections = $meta->injections;
    while ( my($path, $injection) = each %$injections) {
        $self->inject( $path, $injection );
    }
}

sub inject_namespace {
    my ($self, $namespace) = @_;

    my $mpo = Module::Pluggable::Object->new(
        search_path => $namespace,
    );
    $self->inject_class($_) for $mpo->plugins;
}


__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Orochi - A DI Container For Perl

=head1 SYNOPSIS

    use Orochi;

    my $c = Orochi->new();
    $c->inject_constructor('/myapp/foo' => (
        class     => 'SomeClass',
        bind_args => {
            bar => $c->bind_value('/myapp/bar')
        }
    );
    $c->inject_literal( '/myapp/bar' => [ 'a', 'b', 'c' ] );

=head1 USAGE WITH MOOSE CLASSES

Please see L<MooseX::Orochi|MooseX::Orochi>.

=head1 SEE ALSO

L<Bread::Board|Bread::Board>

=cut