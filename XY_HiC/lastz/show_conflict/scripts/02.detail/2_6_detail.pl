#! /usr/bin/perl -w
use strict;
my $filter = shift;
my $raw = shift;
my %pair;
open(FILTER,$filter)||die"$!\n";
$/ = ">"; <FILTER>; $/ = "\n";
while (<FILTER>){
        my $general = $_; chomp ($general); $/ = ">"; 
        my $detail = <FILTER>; chomp ($detail); my @lines = split /\n/, $detail; $/ = "\n"; 
        my @items = split /\t/, $general;
	map{ my @info = split /\t/, $_; $pair{"$items[0]\t$items[1]"} .= "$info[0]\t";} @lines;
}
close FILTER;
open(RAW,$raw)||die"$!\n";
$/ = ">"; <RAW>; $/ = "\n";
while (<RAW>){
	my $general = $_; chomp ($general); $/ = ">";
	my $detail = <RAW>; chomp ($detail); $/ = "\n";
	my @items = split /\t/, $general; 
	if (exists $pair{"$items[0]\t$items[1]"}){
		my %d_fs; my %d_le;
		print ">$general\n";
		my @array = split /\t/, $pair{"$items[0]\t$items[1]"};
		my @lines = split /\n/, $detail;
		map{ my @info = split /\t/, $_; if ($info[0] ~~ @array){ print "$_\n";}} @lines;
	}
}
close RAW;
