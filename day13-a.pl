#!env perl
use warnings;
use strict;

package Loc {
    use Moo;
    use Types::Standard qw( Int );
    use namespace::autoclean;

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
}

package Map {
    use Moo;
    use Types::Standard qw( ArrayRef Any );
    use namespace::autoclean;

    has dots => (
        is => 'rw',
        isa => ArrayRef[Any],
        required => 1,
    );

    sub foldup {
        my ($self, $pos) = @_;
        my %dots = map {
            $_->stringify => 1
        } map {
            if ($_->z > $pos) {
                Loc->new(x => $_->x, z => $pos - ($_->z - $pos))
            } else {
                $_
            }
        } $self->dots->@*;

        $self->dots([ map { Loc->new($_) } keys %dots ]);
    }

    sub foldleft {
        my ($self, $pos) = @_;
        my %dots = map {
            $_->stringify => 1
        } map {
            if ($_->x > $pos) {
                Loc->new(z => $_->z, x => $pos - ($_->x - $pos))
            } else {
                $_
            }
        } $self->dots->@*;

        $self->dots([ map { Loc->new($_) } keys %dots ]);
    }
}

package main;
use warnings;
use strict;

my @dots;
my $map = Map->new(dots => \@dots);
while (<>) {
    chomp;
    next unless length;
    if (/,/) {
        push @dots, Loc->new($_);
    } elsif (/([xy])=(\d+)/) {
        $map->foldup($2) if $1 eq 'y';
        $map->foldleft($2) if $1 eq 'x';
        last;
    }
}

my $result = $map->dots->@*;

print $result, "\n";



