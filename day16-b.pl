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

        return if $self->eof;

        my ($ver, $type) = ($self->read_value(3), $self->read_value(3));
        #$walker->($ver);
        if ($type == 4) {
            # literal value
            my ($flag, $group, $value);
            do {
                ($flag, $group) = ($self->read_bits(1), $self->read_bits(4));
                $value .= $group;
            } while ($flag eq '1');
            say "literal value: $value";
            return oct('0b'.$value);
        } else {
            # operator
            my $mode = $self->read_bits(1);
            my @subs;
            if ($mode == 0) {
                my $total_length = $self->read_value(15);
                say "total length: $total_length";
                my $nsbin = $self->read_bits($total_length);
                @subs = (ref $self)->new(buff => \$nsbin)->read_all($walker);
            } else {
                my $num_packages = $self->read_value(11);
                say "num of packages: $num_packages";
                @subs = map {$self->read_packet($walker)} (0..$num_packages-1);
            }
            return $walker->($type, @subs);
        }
    }

    sub read_all {
        my ($self, $walker) = @_;
        my (@packages, $p);
        while (defined($p = $self->read_packet($walker))) {
            push @packages, $p;
        }
        return @packages;
    }
}

package main;

use List::Util qw(sum0 min max product);

sub to_bin {
    join "", map { sprintf "%04b", oct('0x'.$_) } split //, shift;
}

chomp(my $input = <>);
my $bin_input = to_bin($input);

my ($first) = Steam->new(buff => \$bin_input)->read_all(sub {
    my ($op, @subs) = @_;

    my %ops = (
        0 => sub {sum0 @_},
        1 => sub {product @_},
        2 => sub {min @_},
        3 => sub {max @_},
        5 => sub {$_[0] > $_[1] ? 1 : 0},
        6 => sub {$_[0] < $_[1] ? 1 : 0},
        7 => sub {$_[0] == $_[1] ? 1 : 0},
    );

    return $ops{$op}->(@_);
});

say "value: $first";

