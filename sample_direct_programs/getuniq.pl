# perl
use strict;
use warnings;
use 5.10.1;
use Carp;
use Data::Dump;
use Test::More qw( no_plan );
use Benchmark qw( timethis );
use Getopt::Long;
use List::Compare;
use List::Compare::Functional qw(
    get_unique
    get_unique_ref
    get_unique_all
);

my ($tests_only, $benchmarks_only, $verbose) = (0,0,0);

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

my $large   = [ 1501 .. 120000 ];
my $mixed   = [ @{$bcddefgh}, @{$large} ];

my (@unique, $unique_ref, $unique_all_ref);
my ($args, $expect, @seen);
my $lcmu;

say "LCF version: ", sprintf("%.5f" => $List::Compare::Functional::VERSION);
say "";

say "I. 5 lists of strings, each small";
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi ];

unless ($benchmarks_only) {
    $expect = { map {$_ => 1} qw( jerky ) };
    
    @unique = get_unique( '-u', $args, [ 2 ] );
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "get_unique (unsorted):  got expected unique");
    
    $unique_ref = get_unique_ref( '-u', $args, [ 2 ] );
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "get_unique_ref (unsorted):  got expected unique");
}
timethis( 100_000, sub { get_unique_ref( '-u', $args, [ 2 ] ) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = { map {$_ => 1} qw( abel ) };
    
    @unique = get_unique( '-u', $args );
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "get_unique (unsorted, no index specified):  got expected unique");
    
    $unique_ref = get_unique_ref( '-u', $args, );
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "get_unique_ref (unsorted, no index specified):  got expected unique");
}
timethis( 100_000, sub { get_unique_ref( '-u', $args ) } ) unless $tests_only;

# get_unique_all
unless ($benchmarks_only) {
    $expect = [
        { map { $_ => 1 } ( qw| abel | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } ( qw| jerky | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } () },
    ];
    $unique_all_ref = get_unique_all( '-u', $args );
    @seen = ();
    for my $aref (@{$unique_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "get_unique_all (unsorted):  got expected list of unique");
}
timethis( 100_000, sub { get_unique_all( '-u', $args ) } ) unless $tests_only;

# object-oriented interface, Adlerian, unsorted accelerated
unless ($benchmarks_only) {
    $expect = { map {$_ => 1} qw( jerky ) };
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    @unique = $lcmu->get_unique(2);
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "List::Compare::get_unique: got expected uniques");
    $unique_ref = $lcmu->get_unique_ref(2);
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "List::Compare::get_unique_ref: got expected uniques");
}
timethis( 100_000, sub { List::Compare->new( { unsorted => 1, accelerated => 1, lists => $args, } )->get_unique_ref(2) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = [
        { map { $_ => 1 } ( qw| abel | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } ( qw| jerky | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } () },
    ];
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    $unique_all_ref = $lcmu->get_unique_all();
    @seen = ();
    for my $aref (@{$unique_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "List::Compare::get_unique_all (unsorted, accelerated):  got expected list of uniques");
}
timethis( 100_000, sub { List::Compare->new( { unsorted => 1, accelerated => 1, lists => $args, } )->get_unique_all() } ) unless $tests_only;


say "";
say "II. 5 lists of strings, each small, plus 1 large list";
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];

unless ($benchmarks_only) {
    $expect = { map {$_ => 1} @{$large} };
    
    @unique = get_unique( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "get_unique (unsorted):  got expected unique");
    
    $unique_ref = get_unique_ref( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "get_unique_ref (unsorted):  got expected unique");
}
timethis( 50, sub { get_unique_ref( '-u', $args, [ 5 ] ) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = { map {$_ => 1} qw( abel ) };
    
    @unique = get_unique( '-u', $args );
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "get_unique (unsorted, no index specified):  got expected unique");
    
    $unique_ref = get_unique_ref( '-u', $args );
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "get_unique_ref (unsorted, no index specified):  got expected unique");
}
timethis( 50, sub { get_unique_ref( '-u', $args ) } ) unless $tests_only;



# get_unique_all
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];

unless ($benchmarks_only) {
    $expect = [
        { map { $_ => 1 } ( qw| abel | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } ( qw| jerky | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } () },
        { map { $_ => 1 } @{$large} },
    ];
    $unique_all_ref = get_unique_all( '-u', $args );
    @seen = ();
    for my $aref (@{$unique_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "get_unique_all (unsorted):  got expected list of unique");
}
timethis( 50, sub { get_unique_all( '-u', $args ) } ) unless $tests_only;

# object-oriented interface, Adlerian, unsorted accelerated
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];

unless ($benchmarks_only) {
    $expect = { map {$_ => 1} qw( jerky ) };
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    @unique = $lcmu->get_unique(2);
    is_deeply({ map { $_ => 1 } @unique }, $expect,
        "List::Compare::get_unique: got expected uniques");
    $unique_ref = $lcmu->get_unique_ref(2);
    is_deeply({ map { $_ => 1 } @{$unique_ref} }, $expect,
        "List::Compare::get_unique_ref: got expected uniques");
}
timethis( 50, sub { List::Compare->new( { unsorted => 1, accelerated => 1, lists => $args, } )->get_unique_ref(2) } ) unless $tests_only;

$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];
unless ($benchmarks_only) {
    $expect = [
        { map { $_ => 1 } ( qw| abel | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } ( qw| jerky | ) },
        { map { $_ => 1 } () },
        { map { $_ => 1 } () },
        { map { $_ => 1 } @{$large} },
    ];
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    $unique_all_ref = $lcmu->get_unique_all();
    @seen = ();
    for my $aref (@{$unique_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "List::Compare::get_unique_all (unsorted, accelerated):  got expected list of uniques");
}
timethis( 50, sub { List::Compare->new( { unsorted => 1, accelerated => 1, lists => $args, } )->get_unique_all() } ) unless $tests_only;
