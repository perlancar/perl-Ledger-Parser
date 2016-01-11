package Ledger::Posting::Note;
use Moose;
use namespace::sweep;

with (
    'Ledger::Role::IsNote',
    );

extends 'Ledger::Posting::Element';

1;
