package Ledger::Role::HaveParent;
use Moose::Role;

has 'parent' => (
    is        => 'ro',
    isa       => 'Ledger::Role::HaveElements',
    required  => 1,
    weak_ref  => 1,
    );

sub journal {
    my $self = shift;
    return $self->parent->journal;
}

sub config {
    my $self = shift;
    return $self->journal->config;
}

1;

