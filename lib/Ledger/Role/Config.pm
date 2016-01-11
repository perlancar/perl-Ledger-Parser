package Ledger::Role::Config;
use Moose::Role;
use namespace::sweep;
use Moose::Util::TypeConstraints;

has 'input_date_format' => (
    is          => 'rw',
    isa         => enum([qw[ YYYY/MM/DD YYYY/DD/MM ]]),
    default     => "YYYY/MM/DD",
    );

has 'date_format' => (
    is          => 'rw',
    isa         => 'Str',
    default     => '%Y-%m-%d',
    );

has 'year' => (
    is          => 'rw',
    isa         => 'Num',
    default     => (localtime)[5] + 1900,
    );

has 'transaction_format' => (
    is          => 'rw',
    isa         => 'Str',
    default     => '@{date:%s}@{auxdate:=%s:%s} @{state:%s }@{code:(%s) :%s}'.
    '@{description:%s}@{note:  %s:%s}',
    );

has 'posting_format' => (
    is          => 'rw',
    isa         => 'Str',
    default     => '    @{account:%-35s}  @{amount:%10.2f:%10s:%7d   }'.
    '@{commodity: %-3s} @{note:%s}',
    );

1;

