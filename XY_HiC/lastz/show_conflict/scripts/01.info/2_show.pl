#! /usr/bin/perl -w
use strict;

=head1 Description

 show conflicts between one chromosome and several contigs

=head1 Usage

 perl 2_show_conflict.pl lastz.maf >conflict2.info

=cut

my %status;
my %last;
my $last_id_pair = "0\t0";
$status{$last_id_pair} = 1;

my $maf = shift;
open(MAF, $maf)||die "$!\n";
$/ = "a score=";<MAF>; #chomp head

while(<MAF>){
	chomp;
	my @line = split /\n/;	
	my @target = split /\s+/, $line[1];
	#if chrX
	if($target[1] =~ /chr[XY]/){
#		$target[1] =~ s/target.//; 
		my @query = split /\s+/, $line[2];
#		$query[1] =~ s/query.//;
		my $id_pair = "$target[1]\t$query[1]";
		$last{$id_pair} = $target[2];
		#if new pair
		if(!(exists $status{$id_pair})){ 
			$status{$id_pair} = 1; 
			if($status{$last_id_pair} == 1){ $status{$last_id_pair} = 2;}
			$last_id_pair = $id_pair;
		}
		#if present pair
		elsif($id_pair eq $last_id_pair){ next;}
		#if old pair appears again
		else{
			if($status{$id_pair} == 2){ $status{$id_pair} = 3;} 
			if($status{$last_id_pair} == 1){$status{$last_id_pair} = 2;}
			$last_id_pair = $id_pair;
		} 
	}
}
close MAF;

my $key;
foreach $key (sort keys %status){ if($status{$key} == 3){ print "$key\t$last{$key}\n";} }
