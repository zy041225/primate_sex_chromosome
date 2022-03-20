#! /usr/bin/perl -w
use strict;

=head1 Usage

 perl generate_info.pl lastz.maf >info

=cut

my %start;
my @contigs;

my $maf = shift;
open (MAF, $maf)||die "$!\n";

$/ = "a score=";<MAF>; #chomp head
while(<MAF>){
	chomp;
	my @line = split /\n/;	
	my @target = split /\s+/, $line[1];
	#if chromosome
	if($target[1] =~ /chr[XY]/){
#		$target[1] =~ s/target.//; 
		my @query = split /\s+/, $line[2]; 
		if(!($query[1] ~~ @contigs)){ push @contigs, $query[1];}
#		$query[1] =~ s/query.//;
#		my $value = "$line[2]\n$line[1]";
		my $value = "$query[1]\t$query[2]\t$query[3]\t$query[4]\t$query[5]\t$target[1]\t$target[2]\t$target[3]";
		$start{$query[1]}{$query[2]} = $value;
	}
}
close MAF;

=pod

my $key1; my $key2;
foreach $key1 (sort keys %start) {    	
        foreach $key2 (sort {$a<=>$b} keys %{$start{$key1}})   #对key2按照数字大小进行排序
	{ print $start{$key1}->{$key2}."\n";}	
}

=cut

map { my $contig = $_; my @starts = sort {$a <=> $b} keys %{$start{$contig}}; map { print "$start{$contig}{$_}\n";} @starts;} @contigs;
