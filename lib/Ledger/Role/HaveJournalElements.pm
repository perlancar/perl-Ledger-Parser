package Ledger::Role::HaveJournalElements;
use Moose::Role;
use namespace::sweep;

with 'Ledger::Role::HaveElements';

sub _validateElements {
    my $self = shift;

    $self->_map_elements(sub { $_->validate(@_); })
}

1;
