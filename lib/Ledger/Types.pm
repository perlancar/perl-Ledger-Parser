package Ledger::Types;
use Moose::Util::TypeConstraints;
use namespace::sweep;
use Ledger::Posting::Kind ':constants';
use Ledger::Transaction::State ':constants';

subtype 'Ledger::Type::Amount',
    as 'Num',
    message { "$_ is not a number!" };
    
coerce 'Ledger::Type::Amount',
    from 'Str',
    via { 0+$_ };

enum 'Ledger::Type::Posting::Kind', [REAL, VIRTUALBALANCED, VIRTUALUNBALANCED];

enum 'Ledger::Type::Transaction::State', [DEFAULT, CLEARED, PENDING];

1;

