#! /usr/bin/perl -w
use strict;
use Cwd;
use Cwd 'abs_path';

my $lst = shift;
my $genome = shift;
my $dir = shift; $dir = abs_path($dir); $dir =~ s/\/$//;
my $prog = shift; $prog= abs_path($prog);

open(INFO,$lst)||die"$!\n";
while(<INFO>){
	chomp;
	my $file_path = $_;
	my $file_name = (split /\//)[-1];
	$file_name = (split /\./, $file_name)[0];
#	print "$file_name\n";
	mkdir "$dir/$file_name";
	mkdir "$dir/$file_name/lastz_as_target";
	open(SH,">$dir/$file_name/lastz_as_target/lastz_as_target.sh")||die"$!\n";
	print SH "date\n";
	print SH "perl $prog --parasuit chick --direction lastz_as_target --num 30 --qsub $genome $file_path\n";
	print SH "date\n";
	close SH;
	mkdir "$dir/$file_name/lastz_as_query";
	open(SH,">$dir/$file_name/lastz_as_query/lastz_as_query.sh")||die"$!\n";
	print SH "date\n";
	print SH "perl $prog --parasuit chick --direction lastz_as_query --num 30 --qsub $file_path $genome\n";
	print SH "date\n";
	close SH;
}
close INFO;
