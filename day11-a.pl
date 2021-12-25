#!env perl
use warnings;
use strict;

package Loc {
    use Moo;
    use Types::Standard qw( Int );
    use namespace::autoclean;

    my @neighbours = grep { $_->[0] != 0 || $_->[1] != 0 }
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
            return scalar @{$self->md->[0]};
        },
    );

    has height => (
        is => 'ro',
        isa => Int,
        required => 0,
        lazy => 1,
        default => sub {
            my ($self) = @_;
            return scalar @{$self->md};
        },
    );

    sub level {
        my ($self, $p, $v) = @_;
        return $self->md->[$p->x][$p->z] unless defined $v;
        $self->md->[$p->x][$p->z] = $v;
        return $v;
    }

    sub dump_map {
        my ($self) = @_;
        print @$_,"\n" for @{$self->md};
    }

    sub on_map {
        my ($self, $p) = @_;
        return 
            $p->x >= 0 && $p->x < $self->height
            &&
            $p->z >= 0 && $p->z < $self->width;
    }

    sub walk {
        my ($self, $coderef) = @_;

        for my $i (0..$self->height-1) {
            for my $j (0..$self->width-1) {
                my $p = Loc->new(x => $i, z => $j);
                $coderef->($p);
            }
        }
    }

    sub increase {
        my ($self, $p) = @_;

        if ($p) {
            $self->md->[$p->x][$p->z] ++;
            return;
        }

        for my $i (0..$self->height-1) {
            for my $j (0..$self->width-1) {
                $self->md->[$i][$j] ++;
            }
        }
    }
}

package main;

use List::Util qw(sum0 product);

sub build_map {
    my @map;
    while(my $line = <>) {
        chomp($line);
        my @str = split "", $line;
        push @map, \@str;
    }

    return Map->new(md => \@map);
}

sub step {
    my ($map) = @_;
    # increase by 1
    $map->increase;

    # find flash points
    my @next;
    my %flashes;
    $map->walk(sub {
        my ($p) = @_;
        if ($map->level($p) > 9) {
            push @next, $p;
            $flashes{$p->stringify} = 1;
        };
    });

    # propagate
    while (my $p = shift @next) {
        for my $n ($p->neighbours) {
            next unless $map->on_map($n);
            next if $flashes{$n->stringify};
            $map->increase($n);

            if ($map->level($n) > 9) {
                push @next, $n;
                $flashes{$n->stringify} = 1;
            }
        }
    }

    # reset
    for my $p (keys %flashes) {
        $map->level(Loc->new($p), 0);
    }

    return scalar keys %flashes;
}


my $map = build_map;

my $result = sum0 map { step($map) } (1..100);

print "$result \n";

