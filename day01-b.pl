#!/usr/bin/perl

use v5.30;
use warnings;

my @list1 = <>;
my @window = map { $list1[$_] + $list1[$_+1] + $list1[$_+2] } 0..$#list1-2;

say scalar grep { $window[$_] > $window[$_-1] } 1..$#window;
