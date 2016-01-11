package Ledger::Role::Readable;
use Moose::Role;

requires 'load_from_reader';

sub BUILD {}

after 'BUILD' => sub {
    my $self = shift;
    my $args = shift;

    if (exists($args->{'reader'})) {
	$self->load_from_reader($args->{'reader'});
    }
};

1;

