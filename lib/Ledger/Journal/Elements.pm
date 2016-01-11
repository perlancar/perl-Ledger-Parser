package Ledger::Journal::Elements;
use Moose;
use namespace::sweep;


with (
    #'Ledger::Role::HaveParsableElementsList',
    'Ledger::Role::HaveJournalElements'
    );

extends 'Ledger::Journal::Element';

has '+elements' => (
    isa      => 'ArrayRef[Ledger::Journal::Element]',
    );

override 'validate' => sub {
    my $self=shift;
    super();
    $self->_validateElements;
};

1;
