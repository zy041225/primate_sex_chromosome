#!/usr/bin/perl -w
use strict;

die "perl $0 <keep.id.tab.count>" unless @ARGV == 1;

open(IN, $ARGV[0]) or die $!;
my $h = <IN>;
chomp($h);
my @h = split /\t/, $h;
my %spe;
my $o = '#fam';
my %hash;
for(my $i=2;$i<@h;$i+=2){
	my $spe = (split /_/, $h[$i])[0];
	$hash{$i} = $spe;
	$o .= "\t$spe";
}
print "$o\n";

while(<IN>){
	chomp;
	my @tmp = split /\t/;
	my $flag = 0;
	my @out;
	push @out, $tmp[1];
	for(my $i=2;$i<@tmp;$i+=2){
		if($tmp[$i] eq 'NA'){
			push @out, 'NA';
		}
		elsif($tmp[$i] > 0){
			$flag = 1;
			push @out, $tmp[$i];
		}
		else{
			$flag = 1;
			if($tmp[$i+1] > 0){
				push @out, "-$tmp[$i+1]";
			}
			else{
				push @out, 0;
			}
		}
	}
	next if($flag == 0);
	my $out = join("\t", @out);
	print "$out\n";
}
close IN;

