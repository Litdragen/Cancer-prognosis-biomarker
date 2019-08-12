#!/usr/bin/perl -w
=head1 #===============================================================================
#        USAGE: perl Family_info_extract.pl miRNA.lst miR_Family_Info.txt [header] | uniq > miR_Family_Info.new.txt
#===============================================================================
=cut
die `pod2text $0` unless @ARGV == 2;
use strict;

open IN, shift or die $!;
open IN2, shift or die $!;

my %hash;
if ($ARGV[0]){
        <IN>;
}
while(<IN>){
        chomp;
        my @F = split /\t/;
	$hash{$F[0]} = ();
}

<IN2>;
while(<IN2>){
	chomp;
	my @F = split /\t/;
	$F[0] =~ s/miR-//g;
	$F[0] =~ s/-3p//g;
	$F[0] =~ s/-5q//g;
	my @G = split /\//, $F[0];
	for (@G){
		my $id = "hsa-mir-".$_;
		print "$id\t$F[1]\t$F[2]\n" if exists $hash{$id};
	}		
}

