package Orochi::Declare;
use strict;
use Sub::Exporter -setup => {
    exports => [ qw( bind_value container inject_constructor inject_literal ) ],
    groups  => [ default => [':all'] ]
};

sub unimport {
    my $package = caller(0);
    foreach my $name qw( as container depends_on service wire_names ) {
        no strict 'refs';

        if ( defined &{ $package . '::' . $name } ) {
            my $sub = \&{ $package . '::' . $name };
            next unless \&{$name} == $sub;

            delete ${ $package . '::' }{$name};
        }
    }
}

our $__CONTAINER;
sub container(&) {
    my $c = Orochi->new();
    {
        local $__CONTAINER = $c;
        $_[0]->();
    }
    return $c;
}

sub inject_constructor ($@) {
    return $__CONTAINER->inject_constructor(@_);
}

sub inject_literal ($$) {
    return $__CONTAINER->inject_literal(@_);
}

sub bind_value ($) {
    return $__CONTAINER->bind_value(@_);
}

1;

__END__

    my $c = container {
        inject_constructor '/myapp' => (
            class => 'MyApp',
            args  => {
                foo => inject_constructor('/myapp/foo' 
        )
    }

    my $myapp = $c->get('/myapp');