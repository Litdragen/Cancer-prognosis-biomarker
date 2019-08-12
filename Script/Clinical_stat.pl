#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Clinical_stat.pl Selected_clinic_info.txt
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
my %hash;
my $header = <IN>;
chomp $header;
my @G = split /\t/, $header;

while(<IN>){
	chomp;
	my @F = split /\t/;
	for(1..$#F){
		$hash{$G[$_]}{$F[$_]} ++;
	}
}

for my $k1(@G[1..$#G]){
	print "$k1\n";
	for my $k2(sort keys %{$hash{$k1}}){
		print "\t$k2\t$hash{$k1}{$k2}\n";
	}
}
