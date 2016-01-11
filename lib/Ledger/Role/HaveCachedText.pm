package Ledger::Role::HaveCachedText;
use Moose::Role;

with 'Ledger::Role::IsPrintable';

requires 'compute_text';

has '_cached_text' => (
    is        => 'rw',
    isa       => 'Str',
    clearer   => '_clear_cached_text',
    predicate => '_text_cached',
    );

sub as_string {
    my $self = shift;
    if (!$self->_text_cached) {
	$self->_cached_text($self->compute_text);
    }
    return $self->_cached_text;
}

before 'cleanup' => sub {
    my $self = shift;
    $self->_clear_cached_text;
};

1;

