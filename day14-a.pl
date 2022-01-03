#!env perl
use warnings;
use strict;

use List::Util qw(max min);

my (%rules, $tpl, $result);
while (<>) {
    chomp;
    next unless length;
    if (/([A-Z]{2}) \-> ([A-Z])/) {
        $rules{$1} = $2;
    } else {
        $tpl = $_;
    }
}

sub step {
    my $seq = shift;

    my @output;
    for my $i (0..@$seq-2) {
        push @output, $seq->[$i];
        my $p = $seq->[$i] . $seq->[$i+1];
        push @output, $rules{$p} if exists $rules{$p};
    }
    push @output, $seq->[-1];
    return \@output;
}

$result = [split "", $tpl];
for (0..9) {
    $result = step($result);
}

my %letter;

for my $c (@$result) {
    $letter{$c} ++;
}

my ($min, $max);
$min = min(values %letter);
$max = max(values %letter);

print join(",", $min, $max, $max - $min), "\n";




