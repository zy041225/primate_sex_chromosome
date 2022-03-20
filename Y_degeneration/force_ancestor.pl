#!/usr/bin/perl -w
use strict;

die "perl $0 <ancestral_gametolog.id> <outgroupID> <count.matrix>" unless @ARGV == 3;

my %hash;
open(IN, $ARGV[0]) or die $!;
while(<IN>){
	chomp;
	my $id = (split /\t/)[0];
	$hash{$id} = 1;
}
close IN;

open(IN, $ARGV[2]) or die $!;
my $index;
my $h = <IN>;
chomp($h);
my @h = split /\t/, $h;
for(my $i=1;$i<@h;$i++){
	if($h[$i] eq $ARGV[1]){
		$index = $i;
		last;
	}
}
print "$h\n";
while(<IN>){
	chomp;
	my @tmp = split /\t/;
	if(exists $hash{$tmp[0]}){
		$tmp[$index] = 1;
		my $out = join("\t", @tmp);
		print "$out\n";
	}
	else{
		print "$_\n";
	}
}
close IN;

