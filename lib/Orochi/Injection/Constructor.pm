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
    isa => 'Orochi::Injection | HashRef | ArrayRef',
    predicate => 'has_args',
);

has deref_args => (
    is => 'ro',
    isa => 'Bool',
    required => 1,
    default => 1
);

has block => (
    is => 'ro',
    isa => 'CodeRef',
    predicate => 'has_block'
);

has constructor => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => 'new',
);

sub expand {
    my ($self, $c) = @_;

    my @args;
    if ($self->has_args) {
        my $x = $self->args;

use Data::Dumper;
print STDERR Dumper($x);

        if (blessed $x && Moose::Util::does_role($x, 'Orochi::Injection')) {
            $x = $x->expand($c);
        }
        
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
    my $constructor = $self->constructor;

    return $self->has_block ?
        $self->block->( $self->class, @args ) :
        $self->class->$constructor(@args)
    ;
}

1;