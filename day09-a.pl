#!env perl
use warnings;
use strict;
use List::Util qw(sum0);

my @map;
while(my $line = <>) {
    chomp($line);
    my @str = split "", $line;
    push @map, \@str;
}

sub dump_map {
    print @$_,"\n" for @map;
}

my $width = scalar @{$map[0]};
my $height = @map;

my @neighbours = grep { abs($_->[0]) + abs($_->[1]) == 1 }
                 map { my $i = $_; map {[$i, $_]} (-1..1) }
                 (-1..1);

my @lows;

for my $i (0..$height-1) {
    for my $j (0..$width-1) {
        my $lows = grep {
            $map[$_->[0]][$_->[1]] <= $map[$i][$j]
        }
        grep {
            $_->[0] >= 0 && $_->[0] < $height
            &&
            $_->[1] >= 0 && $_->[1] < $width
        } map {
            [$i + $_->[0], $j + $_->[1]]
        } @neighbours;

        if (!$lows) {
            push @lows, [$i, $j];
        }
    }
}

my $result = sum0 map { $map[$_->[0]][$_->[1]] + 1 } @lows;

print $result, "\n";



