#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Good_luck.pl Cancer_exp.mat Survival.txt Bootstrap_thre
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

my $input1 = shift or die $!;
my $input2 = shift or die $!;
my $thre = shift or die $!;

my $i = 1;
while ($i < 2){
	`sh /disk/zxl/tools/Cancer_survival_biomarker/Script/Step1.sh $input1 $input2`;
	open IN, "2.Marker_extract/Lasso_bootstrap_out.txt" or die $!;
	my $j = 0;
	<IN>;
	while(<IN>){
		chomp;
		my @F = split /\t/;
		$j ++ if $F[2] > $thre;
	}
	`sh /disk/zxl/tools/Cancer_survival_biomarker/Script/Step2.sh $j`;
	open IN2, "2.Marker_extract/Muti_factor_report.txt" or die $!;
	my $ok = 0;
	while(<IN2>){
		print $_;
		chomp;
		$ok ++ if (s/Training data survival curve P-value: //g and $_ < 0.01) or (s/Validation data survival curve P-value: //g and $_ < 0.01) or (s/Training data AUC: //g and $_ > 0.7) or (s/Validation data AUC: //g and $_ > 0.65);
	}
	$i ++ if $ok == 4;
}
`cat 2.Marker_extract/Muti_factor_report.txt`;
