#! /usr/bin/perl -w
use strict;

=head1 Description

 show conflicts between one contig and several chromosomes

=head1 Usage

 perl 3_show_conflict.pl info >conflict3.info

=cut

my $info = shift;

my %status;
my %last;
my $last_id_pair = "0\t0";
$status{$last_id_pair} = 1;

open(INFO, $info)||die "$!\n";

while(<INFO>){
	chomp;
	my @array = split /\s+/;	
#	$array[5] =~ s/target.//; 
#	$query[0] =~ s/query.//;
	my $id_pair = "$array[5]\t$array[0]";
	$last{$id_pair} = $array[6];
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

my $key;
foreach $key (sort keys %status){ if($status{$key} == 3){ print "$key\t$last{$key}\n";} }
close INFO;
