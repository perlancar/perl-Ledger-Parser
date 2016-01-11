package Ledger::Journal::Element;
use Moose;
use namespace::sweep;

with 'Ledger::Role::HaveParent';

sub validate {
    return 1;
}

1;

