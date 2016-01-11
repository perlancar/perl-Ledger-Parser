package Ledger::Parser;
use Moose;
use namespace::sweep;
use Ledger::Util::Reader;
use Ledger::Journal;

with (
    'Ledger::Role::Config',
    );

# DATE
# VERSION

use 5.010001;
use utf8;
use Carp;

has 'validate' => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 1,
    );

sub read_file {
    my ($self, $filename) = @_;
    my $journal=Ledger::Journal->new(
	'config' => $self,
	'reader' => Ledger::Util::Reader->new(
	    'file' => $filename,
	),
	);
    $journal->validate if $self->validate;
    return $journal;
}

sub read_string {
    my ($self, $str) = @_;
    my $journal=Ledger::Journal->new(
	'config' => $self,
	'reader' => Ledger::Util::Reader(
	    'string' => $str,
	),
	);
    $journal->validate if $self->validate;
    return $journal;
}

1;
# ABSTRACT: Parse Ledger journals

=head1 SYNOPSIS

 use Ledger::Parser;
 my $ledgerp = Ledger::Parser->new(
     # year              => undef,        # default: current year
     # input_date_format => 'YYYY/MM/DD', # or 'YYYY/DD/MM',
 );

 # parse a file
 my $journal = $ledgerp->read_file("$ENV{HOME}/money.dat");

 # parse a string
 $journal = $ledgerp->read_string(<<EOF);
 ; -*- Mode: ledger -*-
 09/06 dinner
 Expenses:Food          $10.00
 Expenses:Tips         5000.00 IDR ; 5% tip
 Assets:Cash:Wallet

 2013/09/07 opening balances
 Assets:Mutual Funds:Mandiri  10,305.1234 MFEQUITY_MANDIRI_IAS
 Equity:Opening Balances

 P 2013/08/01 MFEQUITY_MANDIRI_IAS 1,453.8500 IDR
 P 2013/08/31 MFEQUITY_MANDIRI_IAS 1,514.1800 IDR
 EOF

See L<Ledger::Journal> for available methods for the journal object.


=head1 DESCRIPTION

This module parses Ledger journal into L<Ledger::Journal> object. See
http://ledger-cli.org/ for more on Ledger, the command-line double-entry
accounting system software.

Ledger 3 can be extended with Python, and this module only supports a subset of
Ledger syntax, so you might also want to take a look into the Python extension.
However, this module can also modify/write the journal, so it can be used e.g.
to insert transactions programmatically (which is my use case and the reason I
first created this module).

This is an inexhaustive list of things that are not currently supported:

=over

=item * Costs & prices

For example, things like:

 2012-04-10 My Broker
    Assets:Brokerage            10 AAPL @ $50.00
    Assets:Brokerage:Cash

=item * Automated transaction

=item * Periodic transaction

=item * Expression

=item * Various commands

Including but not limited to: assert, C (currency conversion), ...

=back


=head1 ATTRIBUTES

=head2 input_date_format => str ('YYYY/MM/DD' or 'YYYY/DD/MM')

Ledger accepts dates in the form of yearless (e.g. 01/02, 3-12) or with 4-digit
year (e.g. 2015/01/02, 2015-3-12). Month and day can be single- or
double-digits. Separator is either C<-> or C</>.

When year is omitted, year will be retrieved from the C<year> attribute.

The default format is month before day (C<YYYY/MM/DD>), but you can also use day
before month (C<YYYY/DD/MM>).

=head2 year => int (default: current year)

Only used when encountering a date without year.

=head2


=head1 METHODS

=head2 new(%attrs) => obj

Create a new parser instance.

=head2 $ledgerp->read_file($filename) => obj

=head2 $ledgerp->read_string($str) => obj

=cut
