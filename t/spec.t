#!perl

use 5.010;
use strict;
use warnings;

use File::ShareDir::Tarball qw(dist_dir);
use File::Slurper 'read_text';
use Ledger::Parser;
#use Test::Differences;
use Test::Exception;
use Test::More 0.98;
use Test::LongString;

my $dir = dist_dir('Ledger-Examples');
diag ".dat files are at $dir";

my $parser = Ledger::Parser->new;

my @files = glob "$dir/examples/*.dat";
diag explain \@files;

plan tests => scalar(@files);

for my $file (@files) {
  SKIP: {
    skip "TODO files not handled", 1 if $file =~ /TODO-/;
    subtest "file $file" => sub {
      SKIP: {
        if ($file =~ /invalid-/) {
	    plan tests => 1;
            dies_ok { $parser->read_file($file) } "$file should die";
        } else {
	    plan tests => 3;
            my $orig_content = read_text($file);
            my $journal;
            lives_ok { $journal = $parser->read_file($file) } "$file should lives";
	    skip "Skipping reminded test for unloadable file", 2
		if not defined($journal);
	    is_string($journal->as_string, $orig_content, "same as original");
	    $journal->cleanup;
	    $orig_content =~ s,^([0-9]+)[/]([0-9]+)[/]([0-9]+\s),$1-$2-$3,mg;
	    $orig_content =~ s,^([0-9]+)/([0-9]+\s),$1-$2,mg;
	    skip "Rewrite after cleanup is different by design", 1
		if $file =~ /(tx|floating-rouding|amount-symbol-before-and-after)\.dat/;
	    is_string_nows($journal->as_string, $orig_content, "nearly same after cleanup");
            #eq_or_diff $journal->as_string, $orig_content, "round-trip";
        };
      }
    }
  }
}

#DONE_TESTING:
#done_testing;
