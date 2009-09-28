package Orochi::Injection;
use Moose::Role;
use namespace::clean -except => qw(meta);

use Data::Visitor::Callback;

requires 'expand';

has visitor => (
    is => 'ro',
    isa => 'Data::Visitor::Callback',
    lazy_build => 1,
);

sub _build_visitor {
    return Data::Visitor::Callback->new(
        object_final => sub {
            my ($visitor, $object) = @_;
            my $DOES = $object->can('DOES');
            if ($DOES && $DOES->($object, 'Orochi::Injection')) {
                return $_ = $object->expand( $visitor->{OROCHI} );
            }
            return $object;
        }
    );
}

sub expand_all_injections {
    my ($self, $c, $thing) = @_;

    my $visitor = $self->visitor;
    local $visitor->{OROCHI} = $c;
    $visitor->visit($thing);
}

1;