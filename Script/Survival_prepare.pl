#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Survival_prepare.pl clinicalMatrix 
#
#  DESCRIPTION: 
#
#  INPUT FILES: 
#
# REQUIREMENTS:
#        NOTES: None
#       AUTHOR: Xiaolong Zhang, zhangxiaol1@sysucc.org.cn
# ORGANIZATION: Bioinformatics Center, Sun Yat-sen University Cancer Center
#      VERSION: 1.0
#      CREATED: //2017
#     REVISION: ---
#===============================================================================
=cut
die `pod2text $0` unless @ARGV == 1;
use strict;

open IN, shift or die $!;
open OUT1, ">0.data/OS.txt" or die $!;
open OUT2, ">0.data/RFS.txt" or die $!;

my $header = <IN>;
chomp $header;
my %index;
my @G = split /\t/, $header;
for(0..$#G){
	$index{$G[$_]} = $_;
}
print OUT1 "sampleID\tOS.time\tOS.status\n";
print OUT2 "sampleID\tRFS.time\tRFS.status\n";

while(<IN>){
	chomp;
	my @F = split /\t/;
	print OUT1 "$F[0]A\t".$F[$index{"OS.time"}]."\t".$F[$index{"OS"}]."\n";
	print OUT2 "$F[0]A\t".$F[$index{"RFS.time"}]."\t".$F[$index{"RFS"}]."\n";
}
