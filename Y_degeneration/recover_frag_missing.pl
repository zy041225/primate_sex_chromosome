#!/usr/bin/perl -w
use strict;

die "perl $0 <heatmap> <count.parsimony>" unless @ARGV == 2;

my (%hash, %index);
open(IN, $ARGV[0]) or die $!;
my $h = <IN>; chomp($h);
my @h = split /\t/, $h;
for(my $i=1;$i<@h;$i++){
	$index{$i} = $h[$i];
}
while(<IN>){
	chomp;
	my @tmp = split /\t/;
	for(my $i=1;$i<@tmp;$i++){
		if($tmp[$i] < 0){
			$hash{$tmp[0]}{$index{$i}} = 1;
		}
	}
}
close IN;

my %index1;
open(IN, $ARGV[1]) or die $!;
while(<IN>){
	chomp;
	my @tmp = split /\t/;
	if(/^#\|/){
		print "$_\n";
	}
	elsif(/^# Family/){
		for(my $i=1;$i<@tmp;$i++){
			$index1{$tmp[$i]} = $i;
		}
		print "$_\n";
	}
	else{
		if(exists $hash{$tmp[0]}){
			foreach my $spe (sort keys %{$hash{$tmp[0]}}){
				$tmp[$index1{$spe}] = 0;
			}
			my $out = join("\t", @tmp);
			print "$out\n";
		}
		else{
			print "$_\n";
		}
	}
}
