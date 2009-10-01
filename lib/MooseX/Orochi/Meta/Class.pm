package MooseX::Orochi::Meta::Class;
use Moose::Role;
use MooseX::AttributeHelpers;

has bind_path => (
    is => 'rw',
    isa => 'Str'
);

has bind_injection => (
    is => 'rw',
    does => 'Orochi::Injection',
);

has injections => (
    metaclass => 'Collection::Hash',
    is => 'rw',
    isa => 'HashRef',
    provides => {
        set => 'add_injection',
    }
);

1;