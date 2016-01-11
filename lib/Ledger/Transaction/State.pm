package Ledger::Transaction::State;

use constant DEFAULT => "Default";
use constant CLEARED => "Cleared";
use constant PENDING => "Pending";

sub toSymbol {
    my $self=shift;
    my $state=shift;

    if ($state eq DEFAULT) {
	return " ";
    } elsif ($state eq CLEARED) {
	return "*";
    } elsif ($state eq PENDING) {
	return "!";
    } else {
	die 'Invalid state $state';
    }
}

sub fromSymbol {
    my $self=shift;
    my $symb=shift;

    if ($symb =~ /^\s*$/) {
	return DEFAULT;
    } elsif ($symb =~ /^\s*[*]\s*$/) {
	return CLEARED;
    } elsif ($symb =~ /^\s*[!]\s*$/) {
	return PENDING;
    } else {
	die "Invalid symbol state $symb";
    }
}

sub isSymbol {
    my $self=shift;
    my $symb=shift;

    return $symb =~ /^\s*[*!]?\s*$/;
}

use Exporter qw(import);
my @list = qw(DEFAULT CLEARED PENDING);
our @EXPORT_OK = (@list, qw(toSymbol fromSymbol));
our %EXPORT_TAGS = ( 'constants' => \@list, 'all' => \@EXPORT_OK );


1;
