package Orochi::Injection::BindValue;
use Moose;
use namespace::clean -except => qw(meta);

with 'Orochi::Injection';

has bind_to => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

sub BUILDARGS {
    my $class = shift;

    return @_ == 1 ? { bind_to => $_[0] } : { @_ };
}

sub expand {
    my ($self, $c) = @_;

    return $c->get($self->bind_to);
}

__PACKAGE__->meta->make_immutable();

1;
