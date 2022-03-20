#!/usr/bin/perl -w
use strict;

die "perl $0 <axt> <breakage>" unless @ARGV == 2;

my %hash;
open(IN, $ARGV[1]) or die $!;
while(<IN>){
	chomp;
	my ($chr, $pos) = (split /\t/)[0,1];
	$hash{$chr} = $pos;
}
close IN;

open(IN, $ARGV[0]) or die $!;
while(<IN>){
	if(/^\d+/){
		my @tmp = split /\s+/;
		if($tmp[4] =~ s/_1//){
		}
		elsif($tmp[4] =~ s/_2//){
			$tmp[5] += $hash{$tmp[4]};
			$tmp[6] += $hash{$tmp[4]};
		}
		else{
			print $_;
			next;
		}
		my $out = join ' ', @tmp;
		print "$out\n";
	}
	else{
		print $_;
	}
}
close IN;
