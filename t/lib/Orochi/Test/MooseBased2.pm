package Orochi::Test::MooseBased2;
use Moose;
use MooseX::Orochi;

bind_to '/orochi/test/MooseBased2';
inject   Constructor => (
    args => {
        foo => bind_value '/orochi/test/MooseBased1',
    }
);

has foo => (
    is => 'ro',
    isa => 'Orochi::Test::MooseBased1',
    required => 1
);

__PACKAGE__->meta->make_immutable();

1;