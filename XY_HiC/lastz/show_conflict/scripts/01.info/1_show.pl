#! /usr/bin/perl -w
use strict;
my $maf = shift;
my %last_start;
my %detail;
my %general;
my %src;
my @conflict;
my @pairs;
open(MAF, $maf)||die "$!\n";
$/ = "a score="; <MAF>; #chomp head
while(<MAF>){
        chomp;
        my @line = split /\n/;  
        my @target = split /\s+/, $line[1];
        #if chrX
        if ($target[1] =~ /chr[XY]/){
#		$target[1] =~ s/target.//; 
		my @query = split /\s+/, $line[2];
#       	$query[1] =~ s/query.//;
		my $id_pair = "$target[1]\t$query[1]";
		my $tgt_end = $target[2] + $target[3] - 1; my $qry_end = $query[2] + $query[3] - 1; 
		if ($query[4] eq "-"){ $query[2] = $query[5] - 1 - $query[2]; $qry_end = $query[2] - $query[3] + 1;}
		$detail{$id_pair}{$target[2]} = "$target[2]\t$tgt_end\t$target[3]\t$query[2]\t$qry_end\t$query[3]";
        	#if old pair
        	if ($id_pair ~~ @pairs && !($id_pair ~~ @conflict)){
			if ($query[2] > $last_start{$id_pair}){ $last_start{$id_pair} = $query[2];} 
			else { push @conflict, $id_pair; $src{$id_pair} = $query[5];}
		}
		#if new pair
		else{ push @pairs, $id_pair; $last_start{$id_pair} = $query[2]; }
	}
}
close MAF;
map{ print ">$_\t$src{$_}\n"; my $id_pair = $_; my @starts = sort {$a <=> $b} keys %{$detail{$_}}; map{ print"$detail{$id_pair}{$_}\n";} @starts;} @conflict;

