#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my $f ||= 'include';

GetOptions(
	"f:s"=>\$f,
	);

die "perl $0 <heatmap.matrix> -f [include|exclude]" unless @ARGV == 1 and ($f eq 'include' or $f eq 'exclude');

open(IN, $ARGV[0]) or die $!;
while(<IN>){
	chomp;
	my @tmp = split /\t/;
	if(/^#/){
		$tmp[0] = 'tid';
		my $out = join("\t", @tmp);
		print "$out\n";
	}
	else{
		for(my $i=1;$i<@tmp;$i++){
			if($f eq 'exclude'){
				$tmp[$i] = 0 if($tmp[$i] < 0);
			}
			elsif($f eq 'include'){
				$tmp[$i] = 1 if($tmp[$i] < 0);
			}
			else{
				die "error in parameter: $f\n";
			}
			$tmp[$i] = 1 if($tmp[$i] != 0);
		}
		my $out = join("\t", @tmp);
		print "$out\n";
	}
}
close IN;

