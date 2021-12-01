#/usr/bin/perl

use v5.30;
use warnings;

my @list1 = <>;
my ($x, @list2) = @list1;

say scalar grep { $list2[$_] > $list1[$_] } 0..$#list2;
