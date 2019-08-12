#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Good_luck.pl Cancer_exp.mat Survival.txt
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
die `pod2text $0` unless @ARGV == 2;
use strict;

my $input1 = shift or die $!;
my $input2 = shift or die $!;

my $i = 1;
while ($i < 2){
	`mkdir -p 2.Marker_extract`;
	`perl /disk/zxl/tools/Cancer_survival_biomarker/Script/Check_name.pl $input1 $input2 2.Marker_extract`;
	`Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Split_discovery_validation.R 2.Marker_extract/Exp.mat 2.Marker_extract/Surv.mat 0.7 2.Marker_extract`;
	`perl /disk/zxl/tools/RNA-seq-Pipe/Script/Filt_gene_by_exp_proportion.pl 2.Marker_extract/Training_exp.mat 0.66 > 2.Marker_extract/Training_exp.filt.mat`;
	`Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Single_factor_cox.R 2.Marker_extract/Training_exp.filt.mat 2.Marker_extract/Training_surv.txt 2.Marker_extract`;
	`Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Lasso_cox2.R 2.Marker_extract/Single_cox_sig_exp.mat 2.Marker_extract/Training_surv.txt 2.Marker_extract`;
	`Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Multi_factor_cox.R 2.Marker_extract/Lasso_marker_exp.txt 2.Marker_extract/Training_surv.txt 2.Marker_extract 2.Marker_extract/Validation_exp.mat 2.Marker_extract/Validation_surv.txt`;
	
	open IN2, "2.Marker_extract/Muti_factor_report.txt" or die $!;
	my $ok = 0;
	while(<IN2>){
		print $_;
		chomp;
		$ok ++ if (s/Training data survival curve P-value: //g and $_ < 0.01) or (s/Validation data survival curve P-value: //g and $_ < 0.01) or (s/Training data AUC: //g and $_ > 0.7) or (s/Validation data AUC: //g and $_ > 0.69);
	}
	my $a = `wc -l 2.Marker_extract/Lasso_marker_exp.txt`;
	my $b = (split /\s/,$a)[0];
	$ok ++ if $b > 2 and $b <= 15;
	$i ++ if $ok == 5;
}
`cat 2.Marker_extract/Muti_factor_report.txt`;
