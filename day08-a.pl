#!env perl
use warnings;
use strict;
use List::Util qw(sum0);

my @digits = map {
    chomp;
    my @str = split /[|]/, $_, 2;
    $str[1] =~ /([a-z]+)/g;
} <>;

#print join(",", @digits), "\n";

my $result = grep {length =~ /2|3|4|7/} @digits;

print $result, "\n";



