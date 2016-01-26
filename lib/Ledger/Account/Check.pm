package Ledger::Account::Check;
use Moose;
use namespace::sweep;

extends 'Ledger::Account::Element';

with (
    'Ledger::Role::SubDirective::IsCheck',
    );

1;
