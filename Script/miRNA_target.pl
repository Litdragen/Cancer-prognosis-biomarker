#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl miRNA_target.pl miRNA.lst miRNA_target.lst [header] > target.txt 
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
die `pod2text $0` unless @ARGV == 2 or @ARGV == 3;
use strict;

open IN, shift or die $!;
open IN2, shift or die $!;

my %hash;
my %hash2;
if ($ARGV[0]){
	<IN>;
}
while(<IN>){
	chomp;
	my @F = split /\t/;
	$hash{$F[0]} = ();
	my $tmp = $F[0];
	$tmp =~ s/-[1|2]$//g;
	$hash2{$tmp} = $F[0];
}

while(<IN2>){
	chomp;
	my @F = split /\t/;
	$F[0] =~ s/miR/mir/g;
	if (exists $hash{$F[0]}){
		print "$F[1]\t$F[0]\n";
	}elsif(exists $hash2{$F[0]}){
		print "$F[1]\t$hash2{$F[0]}\n";
	}
}
