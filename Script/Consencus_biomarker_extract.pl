#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Consencus_biomarker_extract.pl Single_cox_sig_exp.mat Single_cox_sig_outcome_corelation.mat DEG.txt > Single_cox_sig_exp.filt.mat 
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
die `pod2text $0` unless @ARGV == 3;
use strict;

open IN, shift or die $!;
open IN2, shift or die $!;
open IN3, shift or die $!;

my %surv;
<IN2>;
while(<IN2>){
	chomp;
	my @F = split /\t/;
	$surv{$F[0]} = $F[1];
}

my %extract;
<IN3>;
while(<IN3>){
	chomp;
	my @F = split /\t/;
	next unless exists $surv{$F[0]};
	$extract{$F[0]} = () if ($surv{$F[0]} eq "Possitive" and $F[2] < 0) or ($surv{$F[0]} eq "Negtive" and $F[2] > 0);
}

my $header = <IN>;
print $header;
while(<IN>){
	chomp;
	my @F = split /\t/;
	print $_."\n" if exists $extract{$F[0]};
}
