use strict;
use inc::Module::Install;

name('Orochi');

all_from 'lib/Orochi.pm';

requires 'namespace::clean';
requires 'Data::Visitor';
requires 'Moose' => '0.90';
requires 'Path::Router';
requires 'Sub::Exporter';
test_requires 'Test::More' => 0.88;

auto_set_repository;

WriteAll;