#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Edit_phynotype.pl Selected_phynotype.txt > Selected_phynotype.edit.txt
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
my $header = <IN>;
print $header;
while(<IN>){
	chomp;
	my @F = split /\t/;
	$F[0] =~ s/-/./g;
	for (1..$#F){
		next unless $F[$_];
		$F[$_] =~ s/[ia|ib|ic]$/i/;
		$F[$_] =~ s/[Ia|Ib|Ic]$/I/;
		$F[$_] =~ s/[va|vb|vc]$/v/;
		$F[$_] =~ s/[Va|Vb|Vc]$/V/;
		$F[$_] =~ s/iiii/iv/;
		$F[$_] =~ s/IIII/IV/;
		$F[$_] = "Stage I/II" if $F[$_] eq "Stage I" or $F[$_] eq "Stage II" or $F[$_] eq "stage i" or $F[$_] eq "stage ii";
		$F[$_] = "Stage III/IV" if $F[$_] eq "Stage III" or $F[$_] eq "Stage IV" or $F[$_] eq "stage iii" or $F[$_] eq "stage iv";
		$F[$_] = "T1/T2" if $F[$_] =~ /T1|T2/;
		$F[$_] = "T3/T4" if $F[$_] =~ /T3|T4/;
		$F[$_] = "N1/N2" if $F[$_] =~ /N1|N2/;
		$F[$_] = "" if $F[$_] =~ /TX|MX|NX|not reported/;
	}
	print join "\t", @F;
	print "\n";
}
