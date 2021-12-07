#!/usr/bin/perl

use v5.30;
use warnings;

my @list1 = grep(/[10]/, map {chomp;$_} <>);

sub find_rating {
    my ($list, $target) = @_;
    # $target is 1 or 0,
    # 1 -> oxygen generator rating
    # 0 -> CO2 scrubber rating

    # convert string to array
    my @array_list = map { [split //] } @$list;
    my $index = 0;

    while (@array_list > 1) {
        # determine number of ones at $index position
        my $ones = grep { $_->[$index] } @array_list;

        # filter
        @array_list = grep { $ones >= @array_list/2 && $_->[$index] == $target || $ones < @array_list/2 && $_->[$index] != $target } @array_list;
        $index ++;
    }
    return $array_list[0]->@*;
}

my $oxygen = oct('0b' . join '', find_rating(\@list1, 1));
my $co2 = oct('0b' . join '', find_rating(\@list1, 0));

say $oxygen;
say $co2;
say $oxygen * $co2;
