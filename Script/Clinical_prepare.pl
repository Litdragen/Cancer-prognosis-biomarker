#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Survival_prepare.pl clinicalMatrix [outdir]
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
die `pod2text $0` unless @ARGV == 1 or @ARGV == 2;
use strict;

open IN, shift or die $!;
my $outdir;
if (@ARGV == 1){
	$outdir = shift;
}else{
	$outdir = ".";
}
open OUT1, ">$outdir/Selected_clinic_1.txt" or die $!;
open OUT2, ">$outdir/Selected_clinic_2.txt" or die $!;

my $header = <IN>;
chomp $header;
my %index;
my @G = split /\t/, $header;
for(0..$#G){
	$index{$G[$_]} = $_;
}

#print "Sample_ID\tSex\tAge\tAge_status\tStage\tGrade\tTumor_morphology_percentage\tNew_tumor_event_after_initial_treatment\n";
print OUT1 "Sample_ID\tSex\tAge\tStage\tGrade\tTumor_morphology_percentage\tNew_tumor_event_after_initial_treatment\n";
print OUT2 "Sample_ID\tSex\tAge\tStage\tGrade\tTumor_morphology_percentage\tNew_tumor_event_after_initial_treatment\n";

while(<IN>){
	chomp;
	my @F = split /\t/;
	$F[$index{"gender"}] = "NA" unless $F[$index{"gender"}];
	my $age;
	if ($F[$index{"age_at_initial_pathologic_diagnosis"}]){
		$age = ($F[$index{"age_at_initial_pathologic_diagnosis"}]<60? "<60":">=60");
	}else{
		$age = "NA";
		$F[$index{"age_at_initial_pathologic_diagnosis"}] = "NA";
	}
	my $stage = "NA";
	if (exists $index{"pathologic_stage"}){
		$F[$index{"pathologic_stage"}] = "NA" unless $F[$index{"pathologic_stage"}];
		$F[$index{"pathologic_stage"}] = "NA" if $F[$index{"pathologic_stage"}] eq "[Discrepancy]";
		if($F[$index{"pathologic_stage"}] ne "NA"){
			$F[$index{"pathologic_stage"}] =~ s/Stage //;
			$F[$index{"pathologic_stage"}] =~ s/[a|b|c]$//i;
		}
		$stage = $F[$index{"pathologic_stage"}];
	}elsif(exists $index{"clinical_stage"}){
		$F[$index{"clinical_stage"}] = "NA" unless $F[$index{"clinical_stage"}];
		$F[$index{"clinical_stage"}] = "NA" if $F[$index{"clinical_stage"}] eq "[Discrepancy]";
		if($F[$index{"clinical_stage"}] ne "NA"){
			$F[$index{"clinical_stage"}] =~ s/\d+$//g;
			$F[$index{"clinical_stage"}] =~ s/Stage //;
			$F[$index{"clinical_stage"}] =~ s/[a|b|c]$//i;
		}
		$stage = $F[$index{"clinical_stage"}];
	}else{
		$stage = "NA";
	}
	my $stage2 = "NA";
	$stage2 = "I/II" if $stage =~ /^I$/ or $stage =~ /^II$/;
	$stage2 = "III/IV" if $stage =~ /^III$/ or $stage =~ /^IV$/;
	my $grade = "NA";
	if (exists $index{"neoplasm_histologic_grade"}){
		$F[$index{"neoplasm_histologic_grade"}] = "NA" unless $F[$index{"neoplasm_histologic_grade"}] and $F[$index{"neoplasm_histologic_grade"}] =~ /G\d/;
		$grade = $F[$index{"neoplasm_histologic_grade"}];
	}
	my $grade2 = "NA";
	$grade2 = "G1/G2" if $grade eq "G1" or $grade eq "G2";
	$grade2 = "G3/G4" if $grade eq "G3" or $grade eq "G4";
	my $percent = "NA";
	if (exists $index{"tumor_morphology_percentage"}){
		$F[$index{"tumor_morphology_percentage"}] = "NA" unless $F[$index{"tumor_morphology_percentage"}];
		$percent = $F[$index{"tumor_morphology_percentage"}];
	}
	my $new_tumor = "NA";
	if (exists $index{"new_tumor_event_after_initial_treatment"}){
		$F[$index{"new_tumor_event_after_initial_treatment"}] = "NA" unless $F[$index{"new_tumor_event_after_initial_treatment"}];
		$F[$index{"new_tumor_event_after_initial_treatment"}] = "Yes" if $F[$index{"new_tumor_event_after_initial_treatment"}] eq "1";
		$F[$index{"new_tumor_event_after_initial_treatment"}] = "No" if $F[$index{"new_tumor_event_after_initial_treatment"}] eq "0";
		$new_tumor = $F[$index{"new_tumor_event_after_initial_treatment"}];
	}
	print OUT1 join "\t", "$F[0]A", $F[$index{"gender"}], $age, $stage2, $grade2, $percent, $new_tumor;
	print OUT1 "\n";
	print OUT2 join "\t", "$F[0]A", $F[$index{"gender"}], $F[$index{"age_at_initial_pathologic_diagnosis"}], $stage, $grade, $percent, $new_tumor;
	print OUT2 "\n";
}
