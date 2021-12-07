#!/usr/bin/perl

use v5.30;
use warnings;

my @list1 = <>;

my ($x, $y, $aim) = (0, 0, 0);

for (@list1) {
    my ($di, $u) = split / /;
    if ($di eq 'forward') {
        $x += $u;
        $y += $aim * $u;
    }
    $aim += $u if $di eq 'down';
    $aim -= $u if $di eq 'up';
}

say $x * $y;
