package Orochi::Assembler::Moose;
use Moose::Role;
use namespace::clean -except => qw(meta);

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

    $self->inject( $meta->bind_to, $meta->injection );
}

sub inject_namespace {
    my ($self, $namespace) = @_;

    my $mpo = Module::Pluggable::Object->new(
        search_path => $namespace,
    );
    $self->inject_class($_) for $mpo->plugins;
}

1;

__END__

=head1 NAME

Orochi::Assembler::Moose - Add MooseX::Orochi Bridge To Orochi

=head1 SYNOPSIS

    use Orochi;

    my $c = Orochi->new_with_traits(
        traits => [ 'Assembler::Moose' ]
    );

    $c->inject_class( 'MyApp::MooseClass1' );
    $c->inject_class( 'MyApp::MooseClass2' );
    # or $c->inject_namespace( 'MyApp' );

    $c->get( '/path/to/MooseClass1' );

=head1 SEE ALSO

L<MooseX::Orochi|MooseX::Orochi>

=cut