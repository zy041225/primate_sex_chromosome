#! /usr/bin/perl -w
use strict;
die "perl $0 <len.info> <maf> <species>\n" unless @ARGV == 3;

my ($len, $aln, $aln_filtered) = (0, 0, 0);
open(INFO,$ARGV[0])||die"$!\n";
while(<INFO>){
	chomp;
	my @array = split /\s+/;
	$len += $array[1];
}
close INFO;

open(MAF,$ARGV[1])||die"$!\n";
$/ = "a score=";<MAF>; #chomp head
while(<MAF>){
	my @line = split /\n/;
#	my $tgt_id = (split /\s+/, $line[1])[1];
	my $aln_len = (split /\s+/, $line[1])[3];
	$aln += $aln_len;
	if($aln_len >= 500){ $aln_filtered += $aln_len;}
}
close MAF;

my $aln_rate = $aln/$len * 100;
my $aln_filtered_rate = $aln_filtered/$len * 100;
printf "$ARGV[2]\t$len\t$aln\t%.1f\t$aln_filtered\t%.1f\n", $aln_rate, $aln_filtered_rate;
