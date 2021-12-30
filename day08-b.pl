#!env perl
use warnings;
use strict;
use Algorithm::Permute;
use Set::Tiny qw(set);
use List::Util qw(sum0 first all);

my %patterns = (
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg",
);

my @order = qw(1 7 4 8 6 9 0 2 3 5);

sub str_to_set {
    return set(split "", $_[0]);
}

sub entry {
    my ($left, $right) = @_;
    my $p = Algorithm::Permute->new(['a'..'g']);

    my @ten = map { str_to_set($_) } @$left;
    my @four = map { str_to_set($_) } @$right;

    while (my @res = $p->next) {
        my $seq = join "", @res;
        my %set_to_digit;
        my $matched = all {
            my $d = $_;
            my $s = $patterns{$d};
            eval "tr/abcdefg/$seq/" for ($s);
            my $sd = str_to_set($s);
            $set_to_digit{$sd->as_string} = $d;
            first { $sd->is_equal($_) } @ten;
        } @order;
        next unless $matched;

        # found it
        return join "", map { $set_to_digit{$_->as_string} } @four;
    }
}

my @decded;
while (<>) {
    chomp;
    my @parts = map {; [ /([a-z]+)/g ] } split /[|]/, $_, 2;
    my $r = entry(@parts);
    push @decded, $r;
    print $r, "\n";
}

my $result = sum0 @decded;

print $result, "\n";



