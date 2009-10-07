package Orochi::Injection;
use Moose::Role;
use namespace::clean -except => qw(meta);

use Data::Visitor::Callback;

requires 'expand';

our $VISITOR;

sub expand_all_injections {
    my ($self, $c, $thing) = @_;

    $VISITOR ||= Data::Visitor::Callback->new(
        object_final => sub {
            my ($visitor, $object) = @_;
            my $DOES = $object->can('DOES');
            if ($DOES && $DOES->($object, 'Orochi::Injection')) {
                return $_ = $object->expand( $visitor->{OROCHI} );
            }
            return $object;
        }
    );
    local $VISITOR->{OROCHI} = $c;
    $VISITOR->visit($thing);
}

1;