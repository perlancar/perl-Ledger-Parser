package Ledger::Posting::Kind;

use constant REAL => "Real";
use constant VIRTUALBALANCED => "VirtualBalanced";
use constant VIRTUALUNBALANCED => "VirtualUnbalanced";

sub formatAccount {
    my $class=shift;
    my $kind=shift;
    my $account=shift;

    if ($kind eq REAL) {
	return $account;
    } elsif ($kind eq VIRTUALBALANCED) {
	return '['.$account.']';
    } elsif ($kind eq VIRTUALUNBALANCED) {
	return '('.$account.')';
    } else {
	die "Invalid kind $kind";
    }
}

use Exporter qw(import);
my @list = qw(REAL VIRTUALBALANCED VIRTUALUNBALANCED);
our @EXPORT_OK = (@list, qw(formatAccount));
our %EXPORT_TAGS = ( 'constants' => \@list, 'all' => \@EXPORT_OK );

1;
