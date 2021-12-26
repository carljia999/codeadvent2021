#!env perl
use warnings;
use strict;

use Graph::Undirected;

sub build_graph {
    my $g = Graph::Undirected->new;
    while (my $line = <>) {
        chomp($line);
        next unless $line;
        my ($va, $vb) = split /-/, $line, 2;
        $g->add_edge($va, $vb);
    }

    return $g;
}

my $graph = build_graph;
my @paths;

sub find_path {
    my ($path, $seen) = @_;
    my $u = $path->[-1];

    for my $v ($graph->neighbors($u)) {
        # skip
        next if $seen->{$v} && $v =~ /[a-z]/;

        my @np = (@$path, $v);
        my %ns = (%$seen, $v => 1);

        if ($v eq "end") {
            push @paths, \@np;
            #print join(",", @np), "\n";
            next;
        }

        find_path(\@np, \%ns);
    }
}

find_path(["start"], {start => 1});

print "# of paths: ", scalar @paths, "\n";


