# perl
use strict;
use warnings;
use 5.10.1;
use Data::Dumper;$Data::Dumper::Indent=1;
use Data::Dump;
use Carp;
use File::Spec;
use Getopt::Long;

my ($workdir, $program, $before, $after, $benchmarks_only, $tests_only, $verbose);
my ($blib_lib_dir, $cmd);

=pod

    perl compare_git_versions.pl \
        --workdir=/home/jkeenan/gitwork/list-compare \
        --program=/home/jkeenan/learn/perl/lc/getcomp.pl \
        --before=v0.38 \
        --after=master \
        --tests-only \  # or --benchmarks-only
        --verbose

=cut
     
GetOptions(
    "workdir=s"         => \$workdir,
    "program=s"         => \$program,
    "before=s"          => \$before,
    "after=s"           => \$after,
    "benchmarks-only"   => \$benchmarks_only,
    "tests-only"        => \$tests_only,
    "verbose"           => \$verbose,
) or croak("Error in command line arguments");
croak("Select either 'tests-only' or 'benchmarks-only' -- but not both!")
    if ($tests_only && $benchmarks_only);
my $reduction = $tests_only ? '--tests-only' :
                $benchmarks_only ? '--benchmarks-only' :
                '';
croak("Cannot locate git checkout directory '$workdir'") unless (-d $workdir);
croak("Cannot locate benchmarking program '$program'") unless (-f $program);

chdir $workdir or croak "Unable to change to $workdir";
my $makefile = File::Spec->catfile($workdir, 'Makefile');
if (-f $makefile) {
    system("make -s clean") and croak "Unable to 'make -s clean'";
}
system("git checkout $before") and croak "Unable to checkout version '$before'";
system("$^X Makefile.PL && make -s") and croak "Unable to make -s";
$blib_lib_dir = File::Spec->catdir($workdir, 'blib', 'lib');
croak("Cannot locate blib/lib directory '$blib_lib_dir'") unless (-d $blib_lib_dir);

# benchmark using 'before' version of List-Compare
$cmd = "$^X -I$blib_lib_dir $program $reduction --verbose";
if ($verbose) { say $cmd }
system($cmd) and croak "Unable to run 'before' version";

system("make -s clean") and croak "Unable to 'make -s clean'";
system("git checkout $after") and croak "Unable to checkout version '$after'";
system("$^X Makefile.PL && make -s") and croak "Unable to make -s";
$blib_lib_dir = File::Spec->catdir($workdir, 'blib', 'lib');
croak("Cannot locate blib/lib directory '$blib_lib_dir'") unless (-d $blib_lib_dir);

# benchmark using 'after' version of List-Compare
$cmd = "$^X -I$blib_lib_dir $program $reduction --verbose";
if ($verbose) { say $cmd }
system($cmd) and croak "Unable to run 'after' version";

system("make -s clean") and croak "Unable to 'make -s clean'";
