#! /usr/bin/perl -w

=head1 Description

 illustrate how contigs are aligned to target chromosomes using svg

=head1 Version

 Yuncong Geng, 2016-07-26

=head1 Options

 --width<int>		width of a unit
			 default 100
 --height<int>		height of a unit
			 default 400
 --ratio<int>		chromosome height:width
			 default 20
 --font<int>		font size
			 default 20pt
 --help			show this page;

=head1 Usage

 nohup perl new_draw_svg.pl target.info X1.info X2.info X3.info X4.info X5.info Xun.info lastz.maf >out.svg&

=cut


use strict;
use Getopt::Long;

my ($width, $height, $ratio, $font, $help);
GetOptions(
	"width:i" => \$width,
	"height:i" => \$height,
	"ratio:i" => \$ratio,
	"font:i" => \$font,
	"help" => \$help,
)or die "unknown option!\n";

my $genome = shift;
my @X; my $i = 0;
while ($i <6 ){ $X[$i] = shift; $i += 1;}
my $maf = shift;
die `pod2text $0` if (!($maf && $X[0] && $X[1] && $X[2] && $X[3] && $X[4] && $X[5] && $genome) || $help); 
die "$genome not found!\n" unless (-e $genome);
map { die "$_ not found!\n" unless (-e $_)} @X;
die "$maf not found!\n" unless (-e $maf);

$width ||= 100;
$height ||= 400;
$ratio ||= 20;
$font ||= 20;

#step1: sort chromosome
my %chr_order;
my $order = 0;
my $count = 0;

open(INFO, $genome)||die"$!\n";
while (<INFO>){
	chomp;
	my $id = (split /\s+/)[0];
	if ($id =~ /chr/ && $id ne "chrMT"){
		$count += 1;
		my $chr_name = $id; $chr_name =~ s/chr//; if ($chr_name =~ /[A-Za-z]/){ $chr_name = ord($chr_name);} else { $chr_name = $chr_name + 0;}
		$chr_order{$id} = $chr_name;
	}
}
close INFO;

my @final_chr = sort { $chr_order{$a} <=> $chr_order{$b} } keys %chr_order;
foreach (@final_chr){
	$order += 1;
	$chr_order{$_} = $order;
}

#step2: extract info
my %which; ##contig_id => $i

$i = 0;
while ($i < 6){
	open(INFO, $X[$i])||die"$!\n";
	while (<INFO>){ chomp; my @array = split /\s+/; $which{$array[0]} = $i;}
	close INFO; $i += 1;
}


#step3: create svg
my $svg_width = ($count + 1) * $width;
my $svg_height = $height + 40 * 8;
print "<?xml version=\"1.0\" standalone=\"no\"?>\n";
print "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n";
print "\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n";
print "\n";
print "<svg width=\"$svg_width\" height=\"$svg_height\" version=\"1.1\"\n";
print "xmlns=\"http://www.w3.org/2000/svg\">\n";
print "\n";


#step4: set color
#my $color_set = "166,206,227 31,120,180 178,223,138 51,160,44 251,154,153 227,26,28 253,191,111"; ##qualitative 3
my $color_set = "215,48,39 252,141,89 254,224,144 255,255,191 224,243,248 145,191,219 69,117,180"; ##diverging 7
#my $color_set = "237,248,251 204,236,230 153,216,201 102,194,164 65,174,118 35,139,69 0,88,36"; ##sequential 1
my @array = split /\s+/, $color_set;
my @color = map{ "RGB(" . $_ . ")" } @array;
my $x = $width; my $y = $height + 10;
my $w = 70; my $h = 25;
my $x1 = $x + $w + 30;
$i = 0;
while ($i < 5){
	print "<rect x=\"$x\" y=\"$y\" width=\"$w\" height=\"$h\" style=\"fill:$color[$i]\"/>\n"; $y += 20; $i += 1;
	print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$x1\" y=\"$y\">chrX$i</text>\n"; $y += 20;
}
print "<rect x=\"$x\" y=\"$y\" width=\"$w\" height=\"$h\" style=\"fill:$color[$i];\"/>\n"; $y += 20; $i += 1;
print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$x1\" y=\"$y\">chrXun</text>\n"; $y += 20;
print "<rect x=\"$x\" y=\"$y\" width=\"$w\" height=\"$h\" style=\"fill:$color[$i];\"/>\n"; $y += 20;
print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$x1\" y=\"$y\">target chr</text>\n";

#step5: draw rectangle
my $chr_width = 0.618 * $height / $ratio;
my $last_chr = "chr0";

open (MAF, $maf)||die "$!\n";
$/ = "a score=";<MAF>; #chomp head

while(<MAF>){
	chomp;
	my @line = split /\n/;	
	my @target = split /\s+/, $line[1];
	#if chromosome
	if ($target[1] =~ /chr/ && !($target[1] =~ /MT/)){
		$target[1] =~ s/target.//; 
		my @query = split /\s+/, $line[2]; $query[1] =~ s/query.//;		
		my $h = $target[5]/250000000 * 0.618 * $height;
		my $x = $chr_order{$target[1]} * $width - 0.5 * $chr_width;
		my $x1 = $x - 20;
		my $y1 = 0.875 * $height;
		my $y = 0.809 * $height - $h;
		#if new chromosome
		if ($target[1] ne $last_chr){
			$last_chr = $target[1];
			#draw whole chromosoem
			print "<rect x=\"$x\" y=\"$y\" width=\"$chr_width\" height=\"$h\" style=\"fill:$color[6]\"/>\n";
			print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$x1\" y=\"$y1\">$target[1]</text>\n";
		}
		#if target contig 
		if (exists $which{$query[1]}){
			$y = $y + $h * $target[2]/$target[5];
			$h = $target[3]/$target[5] * $h;
			#draw a small rectangle
			print "<rect x=\"$x\" y=\"$y\" width=\"$chr_width\" height=\"$h\" style=\"fill:$color[$which{$query[1]}]\"/>\n";
		}
	}
}
close MAF;
print "\n";
print "</svg>\n";

