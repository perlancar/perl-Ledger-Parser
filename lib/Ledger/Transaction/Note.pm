package Ledger::Transaction::Note;
use Moose;
use namespace::sweep;

with (
    'Ledger::Role::IsNote',
    );

extends 'Ledger::Transaction::Element';

1;

