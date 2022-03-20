#! /usr/bin/perl -w
use strict;
use List::Util qw/max min/;

my $info = shift;
open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ = "\n";
my ($l_cl, $s_cl, $l_pl, $s_pl, $l_ml, $s_ml) = (0,10e10,0,10e10,0,10e10);
my ($whole_max, $whole_min) = (0, 10e10);
while(<INFO>){
	chomp; my $general = $_; my @items = split /\t/, $general; $/ = ">"; <INFO>; $/ = "\n";
	if ($items[2] eq "01"){
	my $chr_len = $items[4] - $items[3];
	my $p_len = $items[6] - $items[5]; if ($p_len < 0){ $p_len = 0;}
	my $m_len = $items[8] - $items[7]; if ($m_len < 0){ $m_len = 0;}
	if ($chr_len > $l_cl){ $l_cl = $chr_len;} if ($chr_len < $s_cl){ $s_cl = $chr_len;}
	if ($p_len == 0){if ($p_len > $l_pl){ $l_pl = $p_len;} if ($p_len < $s_pl){ $s_pl = $p_len;}}
	if ($m_len == 0){if ($m_len > $l_ml){ $l_ml = $m_len;} if ($m_len < $s_ml){ $s_ml = $m_len;}}
	my @array = ($chr_len, $p_len, $m_len);
	my $max = max @array;
	if ($max > $whole_max){ $whole_max = $max;}
	if ($max < $whole_min){ $whole_min = $max;}
	print "$chr_len\t$p_len\t$m_len\t$max\n";
	}
}
close INFO;
print "whole max: $whole_max\n";
print "whole min: $whole_min\n";

=pod

print "largest chr_len: $l_cl\n";
print "smallest chr_len: $s_cl\n";
print "largest p_len: $l_pl\n";
print "smallest p_len: $s_pl\n";
print "largest m_len: $l_ml\n";
print "smallest m_len: $s_ml\n";

=cut

