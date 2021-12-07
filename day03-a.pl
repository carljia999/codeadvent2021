#!/usr/bin/perl

use v5.30;
use warnings;

my @list1 = grep(/[10]/, map {chomp;$_} <>);

my @gamma;
for my $num (@list1) {
    my @digits = split //, $num;
    for my $i (0..$#digits) {
        $gamma[$i] += $digits[$i];
    }
}

@gamma = map {$_ > @list1/2 ? 1 : 0} @gamma;
my @epsilon = map {$_ ? 0 : 1} @gamma;

my $gamma = oct('0b' . join '', @gamma);
my $epsilon = oct('0b' . join '', @epsilon);

say $gamma;
say $epsilon;
say $gamma * $epsilon;
