#! /usr/bin/perl -w
use strict;
my $info = shift;
open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ ="\n";
while(<INFO>){
	my $general = $_; chomp($general); $/ = ">"; 
	my $detail = <INFO>; chomp($detail); $/ = "\n";
	my @g_info = split /\t/, $general;
	my @lines = split /\n/, $detail; 
	print ">$general\n";
	map{ my @d_info = split /\t/, $_; if($d_info[1] >= $g_info[2]){ print "$_\n";}} @lines;
}
close INFO;
