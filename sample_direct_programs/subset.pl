# perl
use strict;
use warnings;
use 5.10.1;
use Test::More qw( no_plan );
use Benchmark qw( timethis );
use Getopt::Long;
use Carp;
use lib ( '/home/jkeenan/gitwork/list-compare/blib/lib' );
use List::Compare::Functional qw( is_LsubsetR );

my ($tests_only, $benchmarks_only, $verbose) = (0,0,0);

=pod

    perl subset.pl [--tests-only] [--benchmarks-only] [--verbose]

    # Choose one of --tests-only or --benchmarks-only but not both

=cut

GetOptions(
    "tests-only"        => \$tests_only,
    "benchmarks-only"   => \$benchmarks_only,
    "verbose"           => \$verbose,
) or croak("Error in command line arguments");
croak("Select either 'tests-only' or 'benchmarks-only' -- but not both!")
    if ($tests_only && $benchmarks_only);
if ($benchmarks_only) { pass("Running benchmarks only") };
if ($tests_only) { pass("Running tests only") };

my $aabcdefg = [ qw(abel abel baker camera delta edward fargo golfer) ];
my $bcddefgh = [ qw(baker camera delta delta edward fargo golfer hilton) ];
my $fghiij   = [ qw(fargo golfer hilton icon icon jerky) ];
my $fghii    = [ qw(fargo golfer hilton icon icon) ];
my $ffghi    = [ qw(fargo fargo golfer hilton icon) ];

my ($args, $result);

$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi ];

unless ($benchmarks_only) {
    $result = is_LsubsetR( $args, [ 3,2 ] );
    ok($result, "Got expected subset relationship");

    $result = is_LsubsetR( $args, [ 2,3 ] );
    ok(! $result, "Got expected subset relationship");

    $result = is_LsubsetR( $args );
    ok(! $result, "Got expected subset relationship");
}

unless ($tests_only) {
    timethis( 20_000, sub { is_LsubsetR( $args, [ 3,2 ] ) } );
    timethis( 20_000, sub { is_LsubsetR( $args, [ 2,3 ] ) } );
    timethis( 20_000, sub { is_LsubsetR( $args          ) } );
}
