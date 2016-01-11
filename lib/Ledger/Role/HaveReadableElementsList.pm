package Ledger::Role::HaveReadableElementsList;
use Moose::Role;
use namespace::sweep;
use MooseX::ClassAttribute;

with ('Ledger::Role::HaveReadableElements');

requires '_doElementKindsRegistration';

class_has '_elementKinds' => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    default  => sub { [] },
    handles  => {
	_registerElementKind   => 'push',
	_listElementKinds      => 'elements',
	_elementKindsRegistrationRequired  => 'is_empty',
    },
    init_arg => undef,
    );

use UNIVERSAL::require;
before '_registerElementKind' => sub {
    my $self = shift;
    my @kinds = @_;
    #print "Registering ", join(", ", @kinds), "\n";
    for my $kind (@kinds) {
	$kind->require or die $@;
    }
};

sub BUILD {}

before 'BUILD' => sub {
    my $self = shift;
    if ($self->_elementKindsRegistrationRequired) {
	$self->_doElementKindsRegistration();
    }
};

1;
