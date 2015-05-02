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
use List::Compare;
use List::Compare::Functional qw(
    get_complement
    get_complement_ref
    get_complement_all
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

my (@complement, $complement_ref, $complement_all_ref);
my ($args, $expect, @seen);
my $lcmu;

say "LCF version: ", sprintf("%.5f" => $List::Compare::Functional::VERSION);
say "";

say "I. 5 lists of strings, each small";
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi ];

unless ($benchmarks_only) {
    $expect = { map {$_, 1} qw( abel icon jerky ) };
    
    @complement = get_complement( '-u', $args, [ 1 ] );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args, [ 1 ] );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted):  got expected complement");
}
timethis( 100_000, sub { get_complement_ref( '-u', $args, [ 1 ] ) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = { map {$_, 1} qw( hilton icon jerky ) };
    
    @complement = get_complement( '-u', $args );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted, no index specified):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args, );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted, no index specified):  got expected complement");
}
timethis( 100_000, sub { get_complement_ref( '-u', $args ) } ) unless $tests_only;

# get_complement_all
unless ($benchmarks_only) {
    $expect = [ 
        { map { $_ => 1 } ( qw|                                hilton icon jerky | ) },
        { map { $_ => 1 } ( qw| abel                                  icon jerky | ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward | ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward             jerky | ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward             jerky | ) },
    ];
    $complement_all_ref = get_complement_all( '-u', $args );
    @seen = ();
    for my $aref (@{$complement_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "get_complement_all (unsorted):  got expected list of complement");
}
timethis( 100_000, sub { get_complement_all( '-u', $args ) } ) unless $tests_only;

# object-oriented interface, Adlerian, unsorted accelerated
unless ($benchmarks_only) {
    $expect = { map {$_, 1} qw( abel icon jerky ) };
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    @complement = $lcmu->get_complement(1);
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "List::Compare::get_complement: got expected complements");
    $complement_ref = $lcmu->get_complement_ref(1);
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "List::Compare::get_complement_ref: got expected complements");
}
timethis( 100_000, sub { List::Compare->new( {
    unsorted => 1,
    accelerated => 1,
    lists => $args,
} )->get_complement_ref(1) } ) unless $tests_only;

say "";
say "II. 5 lists of strings, each small, plus 1 large list";
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $large ];

unless ($benchmarks_only) {
    $expect = { map {$_, 1} (qw( abel icon jerky ), @{$large}) };
    
    @complement = get_complement( '-u', $args, [ 1 ] );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args, [ 1 ] );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted):  got expected complement");
}
timethis( 50, sub { get_complement_ref( '-u', $args, [ 1 ] ) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = { map {$_, 1} (qw( hilton icon jerky ), @{$large}) };
    
    @complement = get_complement( '-u', $args );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted, no index specified):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted, no index specified):  got expected complement");
}
timethis( 50, sub { get_complement_ref( '-u', $args ) } ) unless $tests_only;

unless ($benchmarks_only) {
    $expect = { map {$_, 1} ( qw| abel baker camera delta edward fargo golfer hilton icon jerky | ) };
    
    @complement = get_complement( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted):  got expected complement");
}
timethis( 50, sub { get_complement_ref( '-u', $args, [ 5 ] ) } ) unless $tests_only;

$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $mixed ];

unless ($benchmarks_only) {
    $expect = { map {$_, 1} qw( abel icon jerky ) };
    
    @complement = get_complement( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "get_complement (unsorted):  got expected complement");
    
    $complement_ref = get_complement_ref( '-u', $args, [ 5 ] );
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "get_complement_ref (unsorted):  got expected complement");
}
timethis( 50, sub { get_complement_ref( '-u', $args, [ 5 ] ) } ) unless $tests_only;

# get_complement_all
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $large ];

unless ($benchmarks_only) {
    $expect = [ 
        { map { $_ => 1 } ( qw|                                hilton icon jerky |, @{$large} ) },
        { map { $_ => 1 } ( qw| abel                                  icon jerky |, @{$large} ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward |, @{$large} ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward             jerky |, @{$large} ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward             jerky |, @{$large} ) },
        { map { $_ => 1 } ( qw| abel baker camera delta edward fargo golfer hilton icon jerky | ) },
    ];
    $complement_all_ref = get_complement_all( '-u', $args );
    @seen = ();
    for my $aref (@{$complement_all_ref}) {
        push @seen, { map { $_ => 1 } @{$aref} };
    }
    is_deeply(\@seen, $expect,
        "get_complement_all (unsorted):  got expected list of complement");
}
timethis( 50, sub { get_complement_all( '-u', $args ) } ) unless $tests_only;

# object-oriented interface, Adlerian, unsorted accelerated
$args = [ $aabcdefg, $bcddefgh, $fghiij, $fghii, $ffghi, $large ];

unless ($benchmarks_only) {
    $expect = { map {$_, 1} (qw( abel icon jerky ), @{$large}) };
    $lcmu   = List::Compare->new( {
        unsorted => 1,
        accelerated => 1,
        lists => $args,
    } );
    ok($lcmu, "List::Compare constructor returned true value");
    @complement = $lcmu->get_complement(1);
    is_deeply({ map { $_ => 1 } @complement }, $expect,
        "List::Compare::get_complement: got expected complements");
    $complement_ref = $lcmu->get_complement_ref(1);
    is_deeply({ map { $_ => 1 } @{$complement_ref} }, $expect,
        "List::Compare::get_complement_ref: got expected complements");
}
timethis( 50, sub { List::Compare->new( {
    unsorted => 1,
    accelerated => 1,
    lists => $args,
} )->get_complement_ref(1) } ) unless $tests_only;

