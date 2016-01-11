package Ledger::Posting;
use Moose;
use namespace::sweep;
use Ledger::Types;
use Math::Decimal qw(dec_mul);
use Ledger::Util;
use utf8;


with (
    'Ledger::Role::HaveCachedText' => {
	-alias => { as_string => '_as_string_main' },
	-excludes => 'as_string',
    },
    'Ledger::Role::Readable',
    'Ledger::Role::HaveMetadata',
    'Ledger::Role::HaveReadableElementsList' => { -excludes => 'BUILD', },
    'Ledger::Role::HaveElements' => {
	-alias => { as_string => '_as_string_elements' },
	-excludes => [ 'as_string' ],
    },
    );

extends 'Ledger::Transaction::Element';

has '+elements' => (
    isa      => 'ArrayRef[Ledger::Posting::Element]',
    );


# note: $RE_xxx is capturing, $re_xxx is non-capturing
our $re_date = qr!(?:\d{4}[/-])?\d{1,2}[/-]\d{1,2}!;
our $RE_date = qr!(?:(\d{4})[/-])?(\d{1,2})[/-](\d{1,2})!;

our $re_account_part = qr/(?:
                              [^\s:\[\(;]+?[ \t]??[^\s:\[\(;]*?
                          )+?/x; # don't allow double whitespace
our $re_account = qr/$re_account_part(?::$re_account_part)*/;
our $re_commodity = qr/[A-Z_]+[A-Za-z_]*|[\$£€¥]/;
our $re_amount = qr/(?:-?)
                    (?:$re_commodity)?
                    \s* (?:-?[0-9,]+\.?[0-9]*)
                    \s* (?:$re_commodity)?
                   /x;
our $RE_amount = qr/(-?)
                    ($re_commodity)?
                    (\s*) (-?[0-9,]+\.?[0-9]*)
                    (\s*) ($re_commodity)?
                   /x;

has 'account' => (
    is       => 'rw',
    isa      => 'Str',
    trigger  => \&_clear_cached_text,
    clearer   => 'clear_account',
    predicate => 'has_account',
    );

has 'amount' => (
    is       => 'rw',
    isa      => 'Ledger::Type::Amount',
    trigger  => \&_clear_cached_text,
    clearer   => 'clear_amount',
    predicate => 'has_amount',
    coerce   => 1,
    );

has 'commodity' => (
    is       => 'rw',
    isa      => 'Str',
    default  => '',
    trigger  => \&_clear_cached_text,
    clearer   => 'clear_commodity',
    predicate => 'has_commodity',
    );

has 'note' => (
    is       => 'rw',
    isa      => 'Str',
    trigger  => \&_clear_cached_text,
    clearer   => 'clear_note',
    predicate => 'has_note',
    );

around 'note' => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig()
	unless @_;

    my $msg = shift;
    $msg =~ s/\s*$//;
    return $self->$orig($msg);
};

has 'kind' => (
    is       => 'rw',
    isa      => 'Ledger::Type::Posting::Kind',
    default  => Ledger::Posting::Kind::REAL,
    );

sub _readEnded {
    my $self = shift;
    my $reader = shift;
    my $line = $reader->next_line;

    return ($line !~ /^\s+;/);
}

sub _doElementKindsRegistration {
    my $self = shift;
    #print "registering\n";
    $self->_registerElementKind('Ledger::Posting::Note');#, 'Ledger::Posting');
};

sub new_from_reader {
    my $class = shift;
    my %attr = @_;
    my $reader = $attr{'reader'};
    
    my $line = $reader->next_line;
    if ($line =~ /^\s/) {
	return $class->new(@_);
    }
    
    return undef;
}

sub _parse_amount {
    my ($self, $str) = @_;
    return [400, "Invalid amount syntax '$str'"]
        unless $str =~ /\A(?:$RE_amount)\z/;

    my ($minsign, $commodity1, $ws1, $num, $ws2, $commodity2) =
        ($1, $2, $3, $4, $5, $6);
    if ($commodity1 && $commodity2) {
        return [400, "Invalid amount '$str' (double commodity)"];
    }
    $num =~ s/,//g;
    $num = dec_mul($num, -1) if $minsign;
    return [200, "OK", [
        $num, # raw number
        ($commodity1 || $commodity2) // '', # commodity
        $commodity1 ? "B$ws1" : "A$ws2", # format: B(efore)|A(fter) + spaces
    ]];
}

before 'load_from_reader' => sub {
    my $self = shift;
    my $reader = shift;

    my $line = $reader->pop_line;
    if ($line !~ m!
	^(\s+)                       # 1) ws1
	(\[|\()?                     # 2) oparen
	($re_account)                # 3) account
	(\]|\))?                     # 4) cparen
	(?: (\s{2,})($re_amount) )?  # 5) ws2 6) amount
	(?: (\s*) ;(.*?))?           # 7) ws 8) note
	(\R?)\z                      # 9) nl
                      !x) {
	$reader->give_back_next_line($line);
	die $reader->error_prefix."Invalid posting line syntax\n";
    }
    $self->account($3);
    
    # brace must match
    my ($oparen, $cparen) = ($2 // '', $4 // '');
    unless (!$oparen && !$cparen ||
	    $oparen eq '[' && $cparen eq ']' ||
	    $oparen eq '(' && $cparen eq ')') {
	$self->_err("Parentheses/braces around account don't match");
    }
    if ($oparen eq '') {
	$self->kind(Ledger::Posting::Kind::REAL);
    } elsif ($oparen eq '[') {
	$self->kind(Ledger::Posting::Kind::VIRTUALBALANCED);
    } elsif ($oparen eq '(') {
	$self->kind(Ledger::Posting::Kind::VIRTUALUNBALANCED);
    } else {
	die "Argh, what happens?";
    }
	
    if (defined($6)) {
	my $parse_amount = $self->_parse_amount($6);
	if ($parse_amount->[0] != 200) {
	    $self->_cached_text($line);
	    $self->_err($parse_amount->[1]);
	}
	if (defined($parse_amount->[2]->[0])) {
	    $self->amount($parse_amount->[2]->[0]);
	}
	if (defined($parse_amount->[2]->[1])) {
	    $self->commodity($parse_amount->[2]->[1]);
	}
    }
    $self->note($8) if defined($8);
    $self->_cached_text($line);
};

sub compute_text {
    my $self = shift;
    my $postingFormat = $self->config->posting_format;
    my @formatParams=();

    push @formatParams, Ledger::Util->buildFormatParam(
	'account',
	'object' => $self,
	'value' => Ledger::Posting::Kind->formatAccount(
	    $self->kind, $self->account
	),
	);
    push @formatParams, Ledger::Util->buildFormatParam(
	'amount',
	'object' => $self,
	'type' => 'Num',
	);
    push @formatParams, Ledger::Util->buildFormatParam(
	'commodity',
	'object' => $self,
	);
    push @formatParams, Ledger::Util->buildFormatParam(
	'note',
	'object' => $self,
	'value' => ";".($self->note // ""),
	);

    my $str=Ledger::Util->format(
	$postingFormat => {@formatParams}
	);
    if ($str->[0] != 200) {
	$self->_err($str->[1]);
    }
    $str->[1] =~ s/\s+$//;
    return $str->[1]."\n";
}

sub as_string {
    my $self = shift;
    return $self->_as_string_main
	.$self->_as_string_elements;
}

use Carp;
sub _err {
    my ($self, $msg) = @_;
    croak join(
        "",
        #@{ $self->{_include_stack} } ? "$self->{_include_stack}[0] " : "",
        #"line $self->{_linum}: ",
        $msg." in\n".$self->as_string,
	"from transaction\n",
	$self->parent->as_string,
    );
}

1;
