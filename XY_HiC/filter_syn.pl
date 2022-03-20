#!/usr/bin/perl -w
use strict;

die "perl $0 <Xref.net.aln> <min_len> <ratio>" unless @ARGV == 3;

open(IN, $ARGV[0]) or die $!;
my $idx = 1;
while(<IN>){
	chomp;
	my ($scaf1, $str1, $bg1, $ed1, $scaf2, $str2, $bg2, $ed2) = (split /\t/)[0,1,2,3,4,5,6,7];
	$bg1--; $bg2--;
	my $l1 = $ed1-$bg1;
	my $l2 = $ed2-$bg2;
	if($l1 >= $ARGV[1] and $l2 >= $ARGV[1]){
		my $ratio = $l1 > $l2 ? $l1/$l2 : $l2/$l1;
		if($ratio < $ARGV[2] and $ratio > 1/$ARGV[2]){
			print "$scaf1\t$bg1\t$ed1\t$scaf2\t$bg2\t$ed2\t$idx\t.\t$str1\t$str2\n";
			$idx++;
		}
	}
}
close IN;

