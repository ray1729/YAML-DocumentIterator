#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use File::Temp ':seekable';
use YAML::Syck;

die_on_fail;

use_ok 'YAML::DocumentIterator';

my $tmp = File::Temp->new();
$tmp->print( <DATA> );
$tmp->seek( 0, 0 );

{
    ok my $it = YAML::DocumentIterator->new( $tmp ), 'construct YAML::DocumentIterator from handle';
    test_it( $it );
}

{
    ok my $it = YAML::DocumentIterator->new( $tmp->filename ), 'construct YAML::DocumentIterator from filename';
    test_it( $it );
}

done_testing;

sub test_it {
    my $it = shift;

    ok $it->isnt_exhausted, "iterator isn't exhausted";
    is_deeply $it->value(), { a => 1, b => 2 }, 'read first value';
    ok $it->isnt_exhausted, "iterator isn't exhausted";
    is_deeply $it->value(), { c => 3, d => 4 }, 'read second vaule';
    ok $it->isnt_exhausted, "iterator isn't exhausted";
    is_deeply $it->value(), { e => [ 5, 6 ]  }, 'read third value';
    ok $it->isnt_exhausted, "iterator isn't exhausted";
    is $it->value(), "Root block scalar\n", 'read fourth value';
    ok $it->is_exhausted, 'iterator is exhausted';
}

__DATA__
### leading comment
---
a: 1
b: 2
... comment
# commenty comment
# comment
---
c: 3
d: 4
---
e:
  - 5
  - 6
--- !!str >
  Root block
  scalar
