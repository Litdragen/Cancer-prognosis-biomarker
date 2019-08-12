#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: 
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
#die `pod2text $0` unless @ARGV == 3;
use strict;
open IN, "/disk/zxl/database/miRanda/Database/miRNA_target.default.lst";
open IN2, "/disk/zxl/database/miRDB/miRNA_target.default.lst";
open IN3, "/disk/zxl/database/miRNA_target/miRNA_target.default.lst";

my %hash;
while(<IN>){
	chomp;
	my @F = split /\t/;
	$hash{$F[0]}{$F[1]} ++;
}
while(<IN2>){
        chomp;
        my @F = split /\t/;
        $hash{$F[0]}{$F[1]} ++;
}
while(<IN3>){
        chomp;
        my @F = split /\t/;
        $hash{$F[0]}{$F[1]} ++;
}

for my $k1(keys %hash){
	for my $k2(keys %{$hash{$k1}}){
		print "$k1\t$k2\n" if $hash{$k1}{$k2} > 1;
	}
}
