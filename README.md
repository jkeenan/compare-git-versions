# compare-git-versions
Test and/or benchmark functions in different git commits via simple command-line program
```perl
    perl compare-git-versions \
        --workdir=/home/perlhacker/gitwork/list-compare \
        --program=/home/perlhacker/learn/perl/lc/getcomp.pl \
        --before=v0.38 \
        --after=master \
        --tests-only \
        --verbose
   # or, instead of 'tests-only':

        --benchmarks-only
```
