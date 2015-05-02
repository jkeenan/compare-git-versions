# perl
use strict;
use warnings;
use 5.10.1;
use Data::Dumper;$Data::Dumper::Indent=1;
use Carp;
use Data::Dump;
use Test::More qw( no_plan );
use Benchmark qw( timethis );
use Getopt::Long;
#use lib ( '/home/perlhacker/gitwork/list-compare/blib/lib' );
use List::Compare::Functional qw( is_LdisjointR );
use List::Compare;


=pod

Objective: Measurably reduce running time of is_LdisjointR for > 2 lists in
both functional and object-oriented interfaces.

=cut

my ($tests_only, $benchmarks_only, $verbose) = (0,0,0);

=pod

    perl benchmark_and_tests.pl \
        --tests-only \
        --benchmarks-only \
        --verbose

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
my $klm      = [ qw(kappa lambda mu) ];

my $large   = [ 1501 .. 120000 ];
my $mixed   = [ @{$bcddefgh}, @{$large} ];

my ($args, $disj);

say "List::Compare::Functional version: ", sprintf("%.5f" => $List::Compare::Functional::VERSION);
say "";


say "I. 2 lists of strings, each small";
unless ($benchmarks_only) {

    $disj = is_LdisjointR( { lists => [ $aabcdefg, $bcddefgh ] } );
    ok(! $disj, "Got expected disjoint relationship");

    $disj = is_LdisjointR( { lists => [ $aabcdefg, $klm ] } );
    ok($disj, "Got expected disjoint relationship");

}
unless ($tests_only) {
    say "List::Compare::Functional::is_LdisjointR: lists interface, 2 lists";
    timethis( 100_000, sub { is_LdisjointR( { lists => [ $aabcdefg, $bcddefgh ] } ) } );
    timethis( 100_000, sub { is_LdisjointR( { lists => [ $aabcdefg, $klm      ] } ) } );
}

say "";
say "II. 2 lists of strings, one large";
unless ($benchmarks_only) {

    $disj = is_LdisjointR( { lists => [ $bcddefgh, $mixed ] } );
    ok(! $disj, "Got expected disjoint relationship");

    $disj = is_LdisjointR( { lists => [ $bcddefgh, $large ] } );
    ok($disj, "Got expected disjoint relationship");
}
unless ($tests_only) {
    say "List::Compare::Functional::is_LdisjointR: lists interface, 2 lists";
    timethis( 50, sub { is_LdisjointR( { lists => [ $bcddefgh, $mixed ] } ) } );
    timethis( 50, sub { is_LdisjointR( { lists => [ $bcddefgh, $large ] } ) } );
}

say "";
say "III. 6 lists of strings, each small";

unless ($benchmarks_only) {

    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $klm ];
    $disj = is_LdisjointR( $args );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = is_LdisjointR( $args, [ 2,3 ] );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = is_LdisjointR( $args, [ 4,5 ] );
    ok($disj, "Got expected disjoint relationship");
}
unless ($tests_only) {
    say "List::Compare::Functional::is_LdisjointR: 6 lists, each small";
    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $klm ];
    timethis( 1000, sub { is_LdisjointR( $args ) } );
    timethis( 1000, sub { is_LdisjointR( $args, [ 2,3 ] ) } );
    timethis( 1000, sub { is_LdisjointR( $args, [ 4,5 ] ) } );
}

say "";
say "IV. 6 lists of strings, 1 large";

unless ($benchmarks_only) {

    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];
    $disj = is_LdisjointR( $args );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = is_LdisjointR( $args, [ 2,3 ] );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = is_LdisjointR( $args, [ 4,5 ] );
    ok(! $disj, "Got expected disjoint relationship");
}
unless ($tests_only) {
    say "List::Compare::Functional::is_LdisjointR: 6 lists, 1 large";
    # count of 50 is too many for v0.38, but too few for latest
    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];
    timethis( 10, sub { is_LdisjointR( $args ) } );
    timethis( 10, sub { is_LdisjointR( $args, [ 2,3 ] ) } );
    timethis( 10, sub { is_LdisjointR( $args, [ 4,5 ] ) } );
}


say "";
say "List::Compare version: ", sprintf("%.5f" => $List::Compare::VERSION);
say "";
my $lcmu;

say "";
say "V. 6 lists of strings, each small";

unless ($benchmarks_only) {

    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $klm ];
    $lcmu = List::Compare->new(
        { unsorted => 1, accelerated => 1, lists => $args }
    );
    $disj = $lcmu->is_LdisjointR();
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = $lcmu->is_LdisjointR( 2,3 );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = $lcmu->is_LdisjointR( 4,5 );
    ok($disj, "Got expected disjoint relationship");
}
unless ($tests_only) {
    say "List::Compare::is_LdisjointR: 6 lists, each small";

    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $klm ];
    $lcmu = List::Compare->new(
        { unsorted => 1, accelerated => 1, lists => $args }
    );
    timethis( 1000, sub { $lcmu->is_LdisjointR() } );
    timethis( 1000, sub { $lcmu->is_LdisjointR( 2,3 ) } );
    timethis(  200, sub { $lcmu->is_LdisjointR( 4,5 ) } );
}

say "";
say "VI. 6 lists of strings, 1 large";

unless ($benchmarks_only) {
    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];
    $lcmu = List::Compare->new(
        { unsorted => 1, accelerated => 1, lists => $args }
    );
    $disj = $lcmu->is_LdisjointR();
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = $lcmu->is_LdisjointR( 2,3 );
    ok(! $disj, "Got expected disjoint relationship");
    
    $disj = $lcmu->is_LdisjointR( 4,5 );
    ok(! $disj, "Got expected disjoint relationship");
}
unless ($tests_only) {
    say "List::Compare::is_LdisjointR: 6 lists, 1 large";

    $args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];
    $lcmu = List::Compare->new(
        { unsorted => 1, accelerated => 1, lists => $args }
    );
    timethis( 10, sub { $lcmu->is_LdisjointR() } );
    timethis( 10, sub { $lcmu->is_LdisjointR(2,3) } );
    timethis( 10, sub { $lcmu->is_LdisjointR(4,5) } );
}
