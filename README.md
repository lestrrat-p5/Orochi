# NAME

Orochi - A DI Container For Perl

# SYNOPSIS

    use Orochi;

    my $c = Orochi->new();
    $c->inject_constructor('/myapp/foo' => (
        class  => 'SomeClass',
        args   => {
            bar => $c->bind_value('/myapp/bar')
        }
    );
    $c->inject_literal( '/myapp/bar' => [ 'a', 'b', 'c' ] );

# BEFORE YOU USE THIS MODULE

WARNING: I'd rather use Bread::Board, but I have a need for a particular
kind of DI _NOW_, and Bread::Board currently doesn't have those features.
Therefore here's my version of it.

If/When Bread::Board becomes suitable for my needs, this module may simply 
be replaced / deleted from CPAN. You've been warned.

# DESCRIPTION

Orochi is a simple Dependency Injection -ish system. Orochi in itself is just
a big Key/Value store, with a bit of runtime lazy expansion / instantiation of
objects mixed in.

# USAGE WITH MOOSE CLASSES

This is probably how you'd want to use this module.
Please see [MooseX::Orochi](https://metacpan.org/pod/MooseX::Orochi) for details

# METHODS

## new(%args)

You may specify the following arguments:

- prefix

    If specified, adds a prefix to the given path through `mangle_path()`.

## get($path)

Retrieves the value associated with the given $path. If the value needs to be
expanded (i.e., create an object), then it will be done automatically.

## mangle\_path($path)

Fixes the given path, if necessary. This adds the prefix specified in the
Orochi constructor, for example

## inject($path, $injection\_object)

Injects a Orochi::Injection object.

## bind\_value($path) or bind\_value(\\@paths)

Creates a BindValue injection, which is a lazy evaluation based on a 
Orochi key.

If given a list, will cascade through the given paths until one returns a
defined value

## inject\_constructor($path => %injection\_args)

Injects an object constructor. Setter injection also uses this

## inject\_literal($path => %injection\_args)

Injects a literal value.

## inject\_class($class)

Injects a MooseX::Orochi based class. The class that is being injected
does NOT have to use MooseX::Orochi, as long as one of the meta classes in the
inheritance hierarchy does so.

## inject\_namespace($namespace)

Looks for modules in the given namespace, and calls inject\_class on each class.

# SEE ALSO

[Bread::Board](https://metacpan.org/pod/Bread::Board)

# TODO

Documentation. Samples. Tests.

# AUTHOR

Daisuke Maki `<daisuke@endeworks.jp>`

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html
