#!/usr/bin/perl -w 
use strict;

## get synteny_info from lastz result
die "Usage:perl $0 <netFile>" unless @ARGV==1;
my $file=shift;

open (IN,"<$file") or die "fail open $file\n";
chomp(my $first=<IN>);
my @array=split /\s+/,$first;
my $flag=$array[0];

#print "#ref\tref_sequence\tref_st\tref_ed\tseq_len\tquery\tquery_seq\tquery_st\tquery_ed\tquery_len\tstrand\n";
while (<IN>) {
    next if /^#/;
    chomp;
    my @line=split;
    if ($flag eq 'net' && $line[0] eq 'fill' ) {
        my $ref_st=$line[1]+1;
        my $ref_ed=$line[1]+$line[2];
        my $qur_st=$line[5]+1;
        my $qur_ed=$line[5]+$line[6];
		my $score = $line[10];
		#print "$array[1]\t$ref_st\t$ref_ed\t$array[2]\t$line[3]\t$qur_st\t$qur_ed\t$size{$line[3]}\t$line[4]\n";
		print "$array[1]\t+\t$ref_st\t$ref_ed\t$line[3]\t$line[4]\t$qur_st\t$qur_ed\t$score\n";
    }elsif ($flag eq 'net' && $line[0] eq 'net') {
        $array[1]=$line[1];
        $array[2]=$line[2];
    }
}
close IN;
