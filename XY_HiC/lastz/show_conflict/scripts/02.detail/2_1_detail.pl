#! /usr/bin/perl -w
use strict;

=head1 Usage

 perl 2_detail.pl 2.info lastz.maf >2.detail

=cut

my $info = shift;
my $maf = shift;

my %last;
my @pairs;
my @present;

my %tgt_fs; #fs = first start
my %tgt_le; #le = last end
my %qry_fs;
my %qry_le;
my %qry_src;
my %detail;

open(INFO,$info)||die"$!\n";
while (<INFO>){
	chomp;
	my @line = split /\t/;
	push @pairs, "$line[0]\t$line[1]";
	$last{"$line[0]\t$line[1]"} = "$line[2]";
}
close INFO;

open(MAF,$maf)||die"$!\n";
$/ = "a score=";<MAF>; #chomp head
while (<MAF>){
	my @line = split /\n/;	
	my @target = split /\s+/, $line[1];
	my @query = split /\s+/, $line[2];
	my $pair = "$target[1]\t$query[1]"; $qry_src{$pair} = $query[5];
	my $tgt_end = $target[2] + $target[3] - 1; my $qry_end = $query[2] + $query[3] - 1;
	if ($query[4] eq "-"){ $query[2] = $query[5] - 1 - $query[2]; $qry_end = $query[2] - $query[3] + 1;}
	if ($pair ~~ @pairs && !($pair ~~ @present)){ push @present, $pair;}
	map{ 
		if ( defined($_)){
			if ($target[2] > $last{$_}){ $_ = undef;}
			else{ $detail{$_}{$target[2]} = "$query[1]\t$target[2]\t$tgt_end\t$target[3]\t$query[2]\t$qry_end\t$query[3]";}
		}
	} @present;
	if ($pair ~~ @pairs){
		#if old pair
		if ( exists $tgt_fs{$pair}){ 
			if ($target[2] < $tgt_fs{$pair}){ $tgt_fs{$pair} = $target[2];}
			if ($tgt_end > $tgt_le{$pair}){ $tgt_le{$pair} = $tgt_end;}
			if ($query[2] < $qry_fs{$pair}){ $qry_fs{$pair} = $query[2];}
			if ($qry_end > $qry_le{$pair}){ $qry_le{$pair} = $qry_end;}
		}
		#if new pair
		else{
			$tgt_fs{$pair} = $target[2]; $tgt_le{$pair} = $tgt_end;
			$qry_fs{$pair} = $query[2]; $qry_le{$pair} = $qry_end;
		}
	}
}
close MAF;

map{ 
	print ">$_\t$tgt_fs{$_}\t$tgt_le{$_}\t$qry_fs{$_}\t$qry_le{$_}\t$qry_src{$_}\n"; 
	my $pair = $_; my @starts = sort {$a <=> $b} keys %{$detail{$pair}}; map{ print "$detail{$pair}{$_}\n";} @starts;
} @pairs;
