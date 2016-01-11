package Ledger::Role::HaveReadableElementsFromParent;
use Moose::Role;

with (
    'Ledger::Role::HaveParent',
    'Ledger::Role::HaveReadableElements',
    );

sub _listElementKinds {
    my $self = shift;
    return $self->parent->_listElementKinds;
}

1;
