#!/usr/bin/perl -w
use strict;

die "perl $0 <mcl.out>" unless @ARGV == 1;

open(IN, $ARGV[0]) or die $!;
my $fam = 1;
while(<IN>){
	chomp;
	my ($n, $gene, $info) = (split /\t/)[1,2,3];
	my @tmp = split /,/, $info;
	foreach my $gene (@tmp){
		my $spe = (split /_/, $gene)[0];
		print "$fam\t$spe\t$gene\n";
	}
	$fam += 1;
}
close IN;

