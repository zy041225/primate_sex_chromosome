#! /usr/bin/perl -w 
use strict;
my $info = shift;
open(INFO,$info)||die"$!\n";
$/= ">"; <INFO>; $/ = "\n";
while(<INFO>){
	my $general = $_; chomp ($general); print ">$general\n"; $/ = ">";
	my $detail = <INFO>; chomp ($detail); my @lines = split /\n/, $detail; $/ = "\n";
	my $count = 0; my $length = 0; my %num; my %len;
        map{ 
                my @info = split /\t/, $_;
		if (exists $num{$info[0]}){ $num{$info[0]} += 1;}else{ $num{$info[0]} = 1;}
                if (exists $len{$info[0]}){ $len{$info[0]} += $info[6];}else{ $len{$info[0]} = $info[6];}
                $count += 1; $length += $info[6];
        } @lines;
        my @ids = sort {$num{$b} <=> $num{$a}} keys %num;
        map{
                my $num_ratio = $num{$_}/$count * 100; my $len_ratio = $len{$_}/$length * 100;
                print "$_\t$num{$_}\t$num_ratio\t$len{$_}\t$len_ratio\n";
        } @ids;
}
close INFO;	
