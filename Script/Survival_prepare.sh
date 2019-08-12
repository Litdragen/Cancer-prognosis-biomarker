### Usage: sh Survival_prepare.sh clinicalMatrix
less $1 | perl -wanle'@F=split /\t/;print "$F[0]A\t$F[3]\t$F[4]"' > 0.data/OS.txt
less $1 | perl -wanle'@F=split /\t/;print "$F[0]A\t$F[7]\t$F[8]"' > 0.data/RFS.txt
