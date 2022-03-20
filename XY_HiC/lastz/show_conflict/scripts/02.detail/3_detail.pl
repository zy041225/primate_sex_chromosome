#! /usr/bin/perl -w
use strict;

=head1 Usage

 perl 3_detail.pl 3.info contig_in_order.maf >3.detail

=cut

my $info = shift;
my $maf = shift;

my %last;
my @pairs;
my @present;

my %tgt_fs; #fs = first start
my %tgt_le; #le = last end
my %qry_p_fs;
my %qry_p_le;
my %qry_m_fs;
my %qry_m_le;
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
while (<MAF>){
	my @array = split /\t/;	
	my $pair = "$array[5]\t$array[0]";
	if (!($pair ~~ @present)){ push @present, $pair;}
	map{ 
		if ( defined($_)){
			if ($array[6] > $last{$_}){ $_ = undef;}
			else{ $detail{$_}{$array[6]} = "$array[5]\t$array[6]\t$array[7]\t$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]";}
		}
	} @present;
	#if old pair
	if ( exists $tgt_fs{$pair}){ 
		if ($array[6] < $tgt_fs{$pair}){ $tgt_fs{$pair} = $array[6];}
		if ($array[6] + $array[7] - 1 > $tgt_le{$pair}){ $tgt_le{$pair} = $array[6] + $array[7] - 1;}
		if ($array[3] eq "+"){
			if ($array[1] < $qry_p_fs{$pair}){ $qry_p_fs{$pair} = $array[1];}
			if ($array[1] + $array[2] - 1 > $qry_p_le{$pair}){ $qry_p_le{$pair} = $array[1] + $array[2] - 1;}
		}
		else{
			if ($array[1] < $qry_m_fs{$pair}){ $qry_m_fs{$pair} = $array[1];}
			if ($array[1] + $array[2] - 1 > $qry_m_le{$pair}){ $qry_m_le{$pair} = $array[1] + $array[2] - 1;}
		}
	}
	#if new pair
	else{
		$tgt_fs{$pair} = $array[6]; $tgt_le{$pair} = $array[6] + $array[7] - 1;
		if ($array[3] eq "+"){ $qry_p_fs{$pair} = $array[1]; $qry_p_le{$pair} = $array[1] + $array[2] - 1; $qry_m_fs{$pair} = 10e10; $qry_m_le{$pair} = -1;}
		if ($array[3] eq "-"){ $qry_m_fs{$pair} = $array[1]; $qry_m_le{$pair} = $array[1] + $array[2] - 1; $qry_p_fs{$pair} = 10e10; $qry_p_le{$pair} = -1;}
	}
}
close MAF;

map{ 
	print ">$_\t$tgt_fs{$_}\t$tgt_le{$_}\t$qry_p_fs{$_}\t$qry_p_le{$_}\t$qry_m_fs{$_}\t$qry_m_le{$_}\n"; 
	my $pair = $_; my @starts = sort {$a <=> $b} keys %{$detail{$pair}}; map{ print "$detail{$pair}{$_}\n";} @starts;
} @pairs;
