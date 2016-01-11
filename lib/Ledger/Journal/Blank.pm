package Ledger::Journal::Blank;
use Moose;
use namespace::sweep;

with (
    'Ledger::Role::HaveCachedText',
    'Ledger::Role::Readable',
    );

extends 'Ledger::Journal::Element';

sub new_from_reader {
    my $class = shift;
    my %attr = @_;
    my $reader = $attr{'reader'};
    
    my $line = $reader->next_line;
    if ($line !~ /\S/) {
	return $class->new(@_);
    }
    
    return undef;
}

sub load_from_reader {
    my $self = shift;
    my $reader = shift;

    my $line = $reader->pop_line;
    if ($line !~ /\S/) {
	$self->_cached_text($line);
    } else {
	$reader->give_back_next_line($line);
	die $reader->error_prefix." cannot read a blank here";
    }
};

sub compute_text {
    my $self = shift;
    return "\n";
}

1;
