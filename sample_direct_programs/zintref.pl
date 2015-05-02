# perl
use strict;
use warnings;
use 5.10.1;
use Data::Dumper;$Data::Dumper::Indent=1;
use Carp;
use Data::Dump;
use Test::More qw( no_plan );
use Benchmark qw( timethese timethis );
use lib '/home/perlhacker/gitwork/list-compare/blib/lib';
use List::Compare::Functional qw( get_intersection get_intersection_ref );

my $fg      = [ qw( fargo golfer ) ];
my $fgh     = [ qw( fargo golfer hilton ) ];
my $fghi    = [ qw( edward fargo golfer hilton icon ) ];
my $bcdefg  = [ qw( baker camera delta edward fargo golfer ) ];
my $large   = [ 1501 .. 120000 ];
my $medium  = [ 1001 ..   4000 ];
my $small   = [ 1481 ..   1510 ];
my $huge    = [ @{$fg}, @{$large} ];
my $xlarge   = [   1501 .. 120000 ];
my $xmedium  = [ 121001 .. 124000 ];
my $xsmall   = [ 123996 .. 124005 ];

my (@i, $i_ref, $expect);
my $args;

say "LCF version: ", sprintf("%.5f" => $List::Compare::Functional::VERSION);

say "";
say "I. 5 lists of strings, each small";
$args =  [ $fg, $fghi, $fgh, $bcdefg, $fghi ];
$expect = { map { $_ => 1 } ( qw| fargo golfer | ) };

@i     = get_intersection($args);
is_deeply( { map { $_ => 1 } @i }, $expect,
    "List::Compare::Functional::get_intersection() gave expected results");

$i_ref = get_intersection_ref($args);
is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
    "List::Compare::Functional::get_intersection_ref() gave expected results");

timethis( 100_000, sub { get_intersection_ref($args) } );

#####

say "";
say "II. 5 lists of strings, each small, plus 1 large list";
$args = [ $fg, $fghi, $fgh, $huge, $bcdefg, $fghi ];
$expect = { map { $_ => 1 } ( qw| fargo golfer | ) };

@i     = get_intersection( $args );
is_deeply( { map { $_ => 1 } @i }, $expect,
    "List::Compare::Functional::get_intersection() gave expected results");

$i_ref = get_intersection_ref( $args );
is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
    "List::Compare::Functional::get_intersection_ref() gave expected results");

timethis( 50, sub { get_intersection_ref( $args ) } );

#####

say "";
say "III. 3 lists of integer sequences, mixed size";
$args = [ $small, $large, $medium ];
$expect = { map { $_ => 1 } ( 1501 .. 1510 ) };

@i     = get_intersection( $args );
is_deeply( { map { $_ => 1 } @i }, $expect,
    "List::Compare::Functional::get_intersection() gave expected results");

$i_ref = get_intersection_ref( $args );
is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
    "List::Compare::Functional::get_intersection_ref() gave expected results");

timethis( 50, sub { get_intersection_ref( $args ) } );

#####

#say "";
#say "IV. 3 lists of integer sequences, mixed size, but no intersection";
#$args = [ $xsmall, $xlarge, $xmedium ];
#$expect = {};
#
#@i     = get_intersection( $args );
#is_deeply( { map { $_ => 1 } @i }, $expect,
#    "List::Compare::Functional::get_intersection() gave expected results");
#
#$i_ref = get_intersection_ref( $args );
#is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
#    "List::Compare::Functional::get_intersection_ref() gave expected results");
#
#timethis( 50, sub { get_intersection_ref( $args ) } );

#####

say "";
say "V. 5 lists of integer sequences, mixed size";
$args = [ $small, $large, $medium, [1486 .. 1515 ], [1400 .. 1600] ];
$expect = { map { $_ => 1 } ( 1501 .. 1510 ) };

@i     = get_intersection( $args );
is_deeply( { map { $_ => 1 } @i }, $expect,
    "List::Compare::Functional::get_intersection() gave expected results");

$i_ref = get_intersection_ref( $args );
is_deeply( { map { $_ => 1 } @{$i_ref} }, $expect,
    "List::Compare::Functional::get_intersection_ref() gave expected results");

timethis( 50, sub { get_intersection_ref( $args ) } );

#####

