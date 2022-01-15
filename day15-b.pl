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

    around BUILDARGS => sub {
        my ( $orig, $class, @args ) = @_;

        if (@args == 1 && !ref $args[0]) {
            my ($x, $z) = split /,/, $args[0], 2;
            return +{ x => $x, z=> $z };
        }

        return $class->$orig(@args);
    };

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
}

package Map {
    use Moo;
    use Types::Standard qw( ArrayRef Int );
    use namespace::autoclean;

    has md => (
        is => 'ro',
        isa => ArrayRef[ArrayRef[Int]],
        required => 1,
    );

    has width => (
        is => 'ro',
        isa => Int,
        required => 0,
        lazy => 1,
        default => sub {
            my ($self) = @_;
            return 5 * scalar @{$self->md->[0]};
        },
    );

    has height => (
        is => 'ro',
        isa => Int,
        required => 0,
        lazy => 1,
        default => sub {
            my ($self) = @_;
            return 5 * scalar @{$self->md};
        },
    );

    sub level {
        my ($self, $p) = @_;
        my ($x, $z) = ($p->x, $p->z);
        my $more = int($x / @{$self->md->[0]}) + int($z / @{$self->md});
        $x = $x % @{$self->md->[0]};
        $z = $z % @{$self->md};
        my $v = $self->md->[$z][$x] + $more;
        while($v>9) {$v -= 9}

        return $v;
    }

    sub dump_map {
        my ($self) = @_;
        print @$_,"\n" for @{$self->md};
    }

    sub on_map {
        my ($self, $p) = @_;
        return 
            $p->x >= 0 && $p->x < $self->width
            &&
            $p->z >= 0 && $p->z < $self->height;
    }
}

package Step {
    use Moo;
    use Types::Standard qw( Any Int );
    use namespace::autoclean;

    has heap => (
        is => 'rw',
        isa => Any,
        required => 0,
    );
    has path => (
        is => 'ro',
        isa => Any,
        required => 1,
    );
    has cost => (
        is => 'ro',
        isa => Int,
        required => 1,
    );

    sub cmp { $_[0]->{cost} <=> $_[1]->{cost} }
}

package main;

use List::Util qw(sum0 min);
use Heap::Fibonacci;

sub build_map {
    my @map;
    while(my $line = <>) {
        chomp($line);
        my @str = split "", $line;
        push @map, \@str;
    }

    return Map->new(md => \@map);
}

my $map = build_map;
my $start = Loc->new(x =>0, z => 0);
my $end   = Loc->new(x =>$map->width-1, z => $map->height-1);

sub find_shortest_path_bfs {
    my $steps = Heap::Fibonacci->new;

    $steps->add(Step->new(
        path => $start,
        cost => 0,
    ));

    my %seen;

    while (my $step = $steps->extract_top) {
        my $p = $step->{path};
        my $cost = $step->{cost};

        # prune
        next if $seen{$p->stringify};
        $seen{$p->stringify} = 1;

        # found exit now
        if ($p->stringify eq $end->stringify) {
            return $cost;
        }

        # find next steps
        $steps->add(Step->new(
            path => $_,
            cost => $cost + $map->level($_),
        )) for grep {
            $map->on_map($_)
        } $p->neighbours;
    }

    die "did not find anything!";
}

my ($result) = find_shortest_path_bfs();

print "$result \n";

