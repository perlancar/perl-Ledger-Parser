package Ledger::Util;
use strict;
use warnings;
use List::Util qw(min);
use Math::Decimal qw(dec_round);

sub format {
    my $class = shift;
    my $format = shift;
    my $args = shift;
    my @values=();

    while($format =~ /(^|[^@])@\{([^:]+):([^}]+)\}/) {
	my $name=$2;
	my @subformats=split(':',$3);
	if (not exists($args->{$name})) {
	    return [400, "Invalid variable '$name' in format string '$format'" ];
	}
	my $avail_values=$args->{$name};
	my $nb=min(scalar(@subformats), scalar(@{$avail_values}))-1;
	for (;$nb>=0; $nb--) {
	    if ($subformats[$nb] ne "" && defined($avail_values->[$nb])) {
		push @values, $avail_values->[$nb];
		my $f=$subformats[$nb];
		my $param=scalar(@values).'$';
		$f =~ s/%/%$param/;
		$format =~ s/(^|[^@])@\{([^:]+):([^}]+)\}/$1$f/;
		last;
	    }
	}
	if ($nb < 0) {
	    return [400, "No format for '$name' to apply in format string '$format'" ];
	}
    }
    return [200, sprintf($format, @values)];
}

sub buildFormatParam {
    my $class = shift;
    my $name = shift,
    my %info = @_;

    my $type='string';
    $type=$info{'type'} if exists($info{'type'});

    my $obj=undef;
    $obj=$info{'object'} if exists($info{'object'});
    
    my $attr=$name;
    $attr=info{'attribute'} if exists($info{'attribute'});
    
    my $pred='has_'.$attr;
    $pred=$info{'predicate'} if exists($info{'predicate'});
    
    my $value;
    if (exists($info{'value'})) {
	$value=$info{'value'};
    } else {
	$value=$obj->$attr;
    }
    my $has_value=1;
    if (exists($info{'has_value'})) {
	$has_value=$info{'has_value'};
    } elsif (defined($obj)) {
	$has_value=$obj->$pred;
    }

    my @fpar=();
    if ($has_value) {
	push @fpar, $value;
	if ($type eq 'Num') {
	    if (dec_round("TWZ", $value, 1)==$value) {
		push @fpar, undef, $value;
	    }
	}
    } else {
	push @fpar, "", "";
    }
    return $name, \@fpar;
}

1;
