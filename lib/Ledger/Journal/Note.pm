package Ledger::Journal::Note;
use Moose;
use namespace::sweep;

with (
    'Ledger::Role::IsNote',
    );

extends 'Ledger::Journal::Element';

1;
