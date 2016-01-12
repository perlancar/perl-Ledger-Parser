package Ledger::Journal;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;
use Carp;

sub new {
    my ($class, %attrs) = @_;

    if (!$attrs{_parsed}) {
        $attrs{_parsed} = [];
    }
    if (!$attrs{_parser}) {
        require Ledger::Parser;
        $attrs{_parser} = Ledger::Parser->new;
    }

    bless \%attrs, $class;
}

sub empty {
    my $self = shift;
    #$self->_discard_cache;
    $self->{_parsed} = [];
}

sub as_string {
    my $self = shift;
    $self->{_parser}->_parsed_as_string($self->{_parsed});
}

use overload '""' => \&as_string;

1;
# ABSTRACT: Represent Ledger journal

=head1 SYNOPSIS

Obtain a journal object C<$journal> from parsing a Ledger file/string using
L<Ledger::Parser>'s C<read_file> or C<read_string> method. Or, to produce an
empty journal:

 $journal = Ledger::Journal->new;

Empty journal:

 $journal->empty;

Dump journal into Ledger string:

 print $journal->as_string;

 # or just:
 print $journal;


=head1 ATTRIBUTES


=head1 METHODS

=head2 new(%attrs) => obj

=head2 $journal->as_string => str

Return journal object rendered as string. Automatically used for
stringification.


=head2 $journal->empty()

Empty journal.


=head1 SEE ALSO

L<Ledger::Parser>
