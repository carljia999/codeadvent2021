#/usr/bin/perl

use v5.30;
use warnings;

my @list1 = <>;

my ($x, $y);

for (@list1) {
    my ($di, $u) = split / /;
    $x += $u if $di eq 'forward';
    $y += $u if $di eq 'down';
    $y -= $u if $di eq 'up';
}

say $x * $y;
