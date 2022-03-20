#!/usr/bin/perl -w
use strict;

die "perl $0 <nonPARY.pep>" unless @ARGV == 1;

my %hash;
open(IN, $ARGV[0]) or die $!;
while(<IN>){
	chomp;
	if(/^>/){
		my $id = (split /\s+/)[0];
		$id =~ s/^>//;
		my $spe = (split /_/, $id)[0];
		push @{$hash{$spe}}, $id;
	}
}
close IN;

foreach my $spe (sort keys %hash){
	my $out = join(" ", @{$hash{$spe}});
	print "$spe: $out\n";
}

