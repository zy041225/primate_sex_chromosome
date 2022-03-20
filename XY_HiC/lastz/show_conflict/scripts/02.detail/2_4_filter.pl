#! /usr/bin/perl -w
use strict;
my $info = shift; #2.stat
my $filter = shift;
$filter ||= 5;
open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ = "\n";
while (<INFO>){
	my $general = $_; chomp ($general); my $flag = 0; $/ = ">"; 
	my $detail = <INFO>; chomp ($detail); my @lines = split /\n/, $detail; $/ = "\n"; 
	my @items = split /\t/, $general; 
	########
#	map{ my @info = split /\t/, $_; if ($info[0] eq $items[1]){ if ($info[2] > $filter){ print ">$general\n"; $flag = 1;}}} @lines;
#	if ($flag == 1){ map{ my @info = split /\t/, $_; if ($info[2] > $filter){ print "$_\n";}} @lines;}
	########
	my $count = 0; my $f = $filter; if (@lines < $filter){ $f = @lines;}
	while ($count < $f){ my @info = split /\t/, $lines[$count]; $count += 1; if ($info[0] eq $items[1]){ print ">$general\n"; $flag = 1;}}
	if ($flag == 1){ $count = 0; while($count < $f){ print "$lines[$count]\n"; $count += 1;}}	
	########
}
close INFO;
