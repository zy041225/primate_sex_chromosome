#! /usr/bin/perl -w
use strict;
my $info = shift;
open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ = "\n";
while(<INFO>){
	my $general = $_; chomp($general); $/ = ">";
	my $detail = <INFO>; chomp($detail); $/ = "\n";
	my ($tgt_fs, $tgt_le, $qry_fs, $qry_le) = (0,0,0,0);
	my @g_info = split /\t/, $general;  my @lines = split /\n/, $detail; 
	map {
		my @info = split /\t/, $_;
		#if old pair
		if ($tgt_fs != 0){
			if ($info[0] < $tgt_fs){ $tgt_fs = $info[0];}
			if ($info[1] > $tgt_le){ $tgt_le = $info[1];}
			if ($info[3] < $qry_fs){ $qry_fs = $info[3];}
			if ($info[4] > $qry_le){ $qry_le = $info[4];}
		}
		#if new pair
		else{
			$tgt_fs = $info[0]; $tgt_le = $info[1]; $qry_fs = $info[3]; $qry_le = $info[4];
		}	
	} @lines;
	print ">$g_info[0]\t$g_info[1]\t$tgt_fs\t$tgt_le\t$qry_fs\t$qry_le\t$g_info[2]\n";
	map { print "$_\n";} @lines;
}
close INFO;
