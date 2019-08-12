#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Check_name.pl exp.mat surv.mat 
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
die `pod2text $0` unless @ARGV == 2 or  @ARGV == 3;
use strict;

my $outdir;
if (@ARGV == 3){
	$outdir = $ARGV[2];
}else{
	$outdir = ".";
}
open IN, shift or die $!;
open IN2, shift or die $!;

open OUT1, ">$outdir/Exp.mat" or die $!;
open OUT2, ">$outdir/Surv.mat" or die $!;

my %hash;
my $header2 = <IN2>;
while(<IN2>){
	chomp;
	my @F = split;
	if ($F[1]){
		$hash{$F[0]} = $_;
	}
}

my $header = <IN>;
chomp $header;
my @G = split /\t/, $header;
my @mark;
my @id;
for (1..$#G){
	if (exists $hash{$G[$_]}){
#		$count{$G[$_]} = ();
		push @id, $G[$_];
		push @mark, $_;
	}
}

print OUT1 join "\t", @G[0, @mark];
print OUT1 "\n";
while(<IN>){
	chomp;
	my @F = split /\t/;
	print OUT1 join "\t", @F[0, @mark];
	print OUT1 "\n";
}

print OUT2 "\ttime\tstatus\n";
for my $k(@id){
	print OUT2 "$hash{$k}\n";
}
