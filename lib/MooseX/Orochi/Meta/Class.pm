package MooseX::Orochi::Meta::Class;
use Moose::Role;

has bind_to => (
    is => 'rw',
    isa => 'Str'
);

has injection => (
    is => 'rw',
    does => 'Orochi::Injection',
);

1;