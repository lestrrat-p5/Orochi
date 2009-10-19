use strict;
use Test::More;
use Orochi;

my $c = Orochi->new();
$c->inject_literal( foo => "123" );
$c->inject( bar => $c->bind_value( ['baz', 'foo'] ) );

is($c->get('foo'), 123);
is($c->get('baz'), undef);
is($c->get('bar' ), '123' );

done_testing();