package Ledger::Role::HaveMetadata;
use Moose::Role;
use Ledger::Role::InTransactionMetadata;

has 'metadata' => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Ledger::Role::InTransactionMetadata]',
    default  => sub { [] },
    required => 1,
    handles  => {
	all_metadata    => 'elements',
	_add_metadata   => 'push',
	_map_metadata   => 'map',
	filter_metadata => 'grep',
	#find_element   => 'first',
	get_metadata    => 'get',
	#join_elements  => 'join',
	count_metadata  => 'count',
	#has_options    => 'count',
	has_no_metadata => 'is_empty',
	#sorted_options => 'sort',
    },
    init_arg => undef,
    );

1;

