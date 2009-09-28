package Orochi::Injection::Constructor;
use Moose;
use namespace::clean -except => qw(meta);

with 'Orochi::Injection';

has class => (
    is => 'ro',
    isa => 'ClassName',
    required => 1
);

has args => (
    is => 'ro',
    isa => 'HashRef | ArrayRef',
    predicate => 'has_args',
);

has deref_args => (
    is => 'ro',
    isa => 'Bool',
    required => 1,
    default => 1
);

sub expand {
    my ($self, $c) = @_;

    my @args;
    if ($self->has_args) {
        my $x = $self->args;
        if ($self->deref_args) {
            my $ref = ref $x;
            @args = 
                $ref eq 'HASH' ? %$x :
                $ref eq 'ARRAY' ? @$x :
                confess "Don't know how to dereference $ref"
            ;
        } else {
            push @args, $x;
        }
    }

    $self->expand_all_injections($c, \@args);

    return $self->class->new(@args);
}

1;