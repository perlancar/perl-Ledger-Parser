package Ledger::Role::HaveReadableElements;
use Moose::Role;
use namespace::sweep;

with ('Ledger::Role::Readable');

requires '_readEnded';

sub load_from_reader {
    my $self = shift;
    my $reader = shift;
    my @elementKinds = $self->_listElementKinds;

  LINE:
    for(;;) {
	#print "Trying all kinds in ".$self->meta->name."\n";
	last LINE if not defined($reader->next_line);
	last LINE if $self->_readEnded($reader);
	for my $kind (@elementKinds) {
	    #print "Trying kind $kind\n";
	    my $elem = "$kind"->new_from_reader(
		parent => $self,
		reader => $reader);
	    if (defined($elem)) {
		$self->_add_element($elem);
		next LINE;
	    }
	}
	die $reader->error_prefix." in ".$self->meta->name.", cannot interpret the following line:\n".$reader->next_line;
    }
}

1;
