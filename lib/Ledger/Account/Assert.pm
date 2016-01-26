package Ledger::Account::Assert;
use Moose;
use namespace::sweep;

extends 'Ledger::Account::Element';

with (
    'Ledger::Role::SubDirective::IsAssert',
    );

1;
