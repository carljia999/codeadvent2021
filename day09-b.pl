#!env perl
use warnings;
use strict;

package Loc {
    use Moo;
    use Types::Standard qw( Int );
    use namespace::autoclean;

    my @neighbours = grep { abs($_->[0]) + abs($_->[1]) == 1 }
                map { my $i = $_; map {[$i, $_]} (-1..1) }
                (-1..1);

    has x => (
        is => 'ro',
        isa => Int,
        required => 1,
    );
    has z => (
        is => 'ro',
        isa => Int,
        required => 1,
    );

    sub stringify {
        my ($self) = @_;
        return $self->x. ",". $self->z;
    }

    sub neighbours {
        my ($self) = @_;
        map {
            ref($self)->new(x => $self->x + $_->[0], z => $self->z + $_->[1])
        } @neighbours;
    }

    sub height {
        my ($self, $map) = @_;
        return $map->[$self->x][$self->z];
    }
}

package main;

use List::Util qw(sum0 product);

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

my @lows;

for my $i (0..$height-1) {
    for my $j (0..$width-1) {
        my $me = Loc->new(x => $i, z => $j);
        my $lows = grep {
            $map[$_->x][$_->z] <= $map[$i][$j]
        }
        grep {
            $_->x >= 0 && $_->x < $height
            &&
            $_->z >= 0 && $_->z < $width
        } $me->neighbours;

        if (!$lows) {
            push @lows, $me;
        }
    }
}

sub find_area {
    my ($l) = @_;
    my @next = ($l);
    my %basin;

    do {
        my $p = shift @next;
        $basin{$p->stringify} = 1;
        #print "checking ", $p->stringify, "\n";

        for my $n ($p->neighbours) {
            next unless
            $n->x >= 0 && $n->x < $height
            &&
            $n->z >= 0 && $n->z < $width;
            next if $basin{$n->stringify};

            #print "testing ", $n->stringify, "\n";

            if ($n->height(\@map) < 9) {
                #print "enqueue: ", $n->stringify, "\n";
                push @next, $n;
            }
        }
    } while @next;

    return scalar keys %basin;
}

my @areas = sort {$b <=> $a} map { find_area($_) } @lows;

#find_area($lows[2]);
print product(@areas[0..2]), "\n";



