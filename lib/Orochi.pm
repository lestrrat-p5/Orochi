package Orochi;
use Moose;
use namespace::clean -except => qw(meta);
use Orochi::Injection::BindValue;
use Orochi::Injection::Constructor;
use Orochi::Injection::Literal;
use Path::Router;

with 'MooseX::Traits';

has '+_trait_namespace' => (
    default => __PACKAGE__
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

    my $matched = $self->router->match( $path );
    if ( $matched ) {
        return $matched->target->expand( $self );;
    }
    return ();
}

sub inject {
    my ($self, $path, $injection) = @_;
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

=cut