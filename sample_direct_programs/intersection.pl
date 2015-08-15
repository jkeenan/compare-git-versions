# perl
use strict;
use warnings;
use 5.10.1;
use Carp;
use Test::More qw( no_plan );
use Benchmark qw( timethese timethis );
use lib '/home/jkeenan/gitwork/list-compare/blib/lib';
use List::Compare::Functional qw( get_intersection_ref );

my $fg      = [ qw( fargo golfer ) ];
my $fgh     = [ qw( fargo golfer hilton ) ];
my $fghi    = [ qw( edward fargo golfer hilton icon ) ];
my $bcdefg  = [ qw( baker camera delta edward fargo golfer ) ];

my ($i_ref, $expect);
my $args;

say "LCF version: ", sprintf("%.5f" => $List::Compare::Functional::VERSION);

say "";
say "I. 5 lists of strings, each small";
$args =  [ $fg, $fghi, $fgh, $bcdefg, $fghi ];
$expect = { map { $_ => 1 } ( qw| fargo golfer | ) };

$i_ref = get_intersection_ref($args);
is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
    "List::Compare::Functional::get_intersection_ref() gave expected results");

timethis( 100_000, sub { get_intersection_ref($args) } );
