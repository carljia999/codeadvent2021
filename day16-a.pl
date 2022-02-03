#!env perl
use warnings;
use strict;
use v5.16;

package Steam {
    use Moo;
    use Types::Standard qw( ScalarRef Str );
    use namespace::autoclean;

    has buff => (
        is => 'ro',
        isa => ScalarRef[Str],
        required => 1,
    );

    sub read_bits {
        my ($self, $n) = @_;
        return substr $self->buff->$*, 0, $n, '';
    }

    sub eof {
        my ($self) = @_;
        !($self->buff->$* && $self->buff->$* =~ /1/)
    }

    sub read_value {
        my ($self, $n) = @_;
        my $v = $self->read_bits($n);
        return oct('0b'.$v);
    }

    sub read_packet {
        my ($self, $walker) = @_;

        return 0 if $self->eof;

        my ($ver, $type) = ($self->read_value(3), $self->read_value(3));
        say "ver: $ver";
        $walker->($ver);
        if ($type == 4) {
            # literal value
            my ($flag, $group, $value);
            do {
                ($flag, $group) = ($self->read_bits(1), $self->read_bits(4));
                $value .= $group;
            } while ($flag eq '1');
            say "literal value: $value";
        } else {
            # operator
            my $mode = $self->read_bits(1);
            if ($mode == 0) {
                my $total_length = $self->read_value(15);
                say "total length: $total_length";
                my $nsbin = $self->read_bits($total_length);
                (ref $self)->new(buff => \$nsbin)->read_all($walker);
            } else {
                my $num_packages = $self->read_value(11);
                say "num of packages: $num_packages";
                $self->read_packet($walker) for 0..$num_packages-1;
            }
        }
        return 1;
    }

    sub read_all {
        my ($self, $walker) = @_;
        while ($self->read_packet($walker)) {}
    }
}

package main;

use List::Util qw(sum0 min);

sub to_bin {
    join "", map { sprintf "%04b", oct('0x'.$_) } split //, shift;
}

chomp(my $input = <>);
my $bin_input = to_bin($input);

my $sum = 0;
Steam->new(buff => \$bin_input)->read_all(sub {
    $sum += $_[0];
});

say "sum of ver: $sum";

