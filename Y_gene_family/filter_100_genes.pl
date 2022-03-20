#!/usr/bin/perl -w
use strict;

my $input = shift;
my $lists = shift;

open IN,$lists;
my %hash;
while(<IN>){
    chomp;
    my @a = split/\s+/;
    my @b = split/,/;
    for(my $i=0;$i<=$#b;$i++){
#        if($b[$i]=~/_R/){$hash{$b[$i]}=1;}
        $hash{$b[$i]}=1;
    }
}close IN;

open IN,$input;
while(<IN>){
    chomp;
    my $line = $_;
    my @a = split(/\s+/,$line);
    unless(exists $hash{$a[0]} or exists $hash{$a[1]}){
        print "$line\n";
    }
}close IN;

