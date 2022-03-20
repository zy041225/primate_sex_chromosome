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
my $net = shift;
die `pod2text $0` if (!($net && $X[0] && $X[1] && $X[2] && $X[3] && $X[4] && $X[5] && $genome) || $help); 
die "$genome not found!\n" unless (-e $genome);
map { die "$_ not found!\n" unless (-e $_)} @X;
die "$net not found!\n" unless (-e $net);

$width ||= 100;
#$height ||= 600;
#$ratio ||= 20;
$font ||= 20;

#step1: sort chromosome
my %chr_order;
my $max_size = 0;
my $order = 1;
open(INFO, $genome)||die"$!\n";
while (<INFO>){
	chomp;
	my ($id, $size) = (split /\s+/)[0,1];
	$chr_order{$id} = $order;
	$order += 1;
	if($size > $max_size){ $max_size = $size;}
}
close INFO;


#step2: extract info
my %which; ##contig_id => $i

$i = 0;
while ($i < 6){
	open(INFO, $X[$i])||die"$!\n";
	while (<INFO>){ chomp; my @array = split /\s+/; $which{$array[0]} = $i;}
	close INFO; $i += 1;
}


#step3: create svg
my $svg_width = $order * $width;
my $base_height = $max_size/150000000 * 300 + 80;
my $svg_height = $base_height + 40 * 8;
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
my $rect_x = $width - 10; my $rect_y = $base_height + 30;
my $rect_w = 50; my $rect_h = 20;
my $text_x = $rect_x + $rect_w + 30;
$i = 0;
my @name = ("X1","X2","X3","X4","X5","Xun","A");
while ($i < 7){
	print "<rect x=\"$rect_x\" y=\"$rect_y\" width=\"$rect_w\" height=\"$rect_h\" style=\"fill:$color[$i]\" stroke=\"black\" stroke-width=\"1\"/>\n"; $rect_y += 20;
	print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$text_x\" y=\"$rect_y\">chr$name[$i]</text>\n"; $rect_y += 20;
	$i += 1;
}


#step5: draw rectangle
my $chr_width = 20;
open (FA, $net)||die "$!\n";
$/ = "net"; <FA>; $/ = "\n";
while(<FA>){
	chomp;
	my $chr = $_; chomp($chr); $/ = "net";
	my $info = <FA>; chomp($info); $/ = "\n";
	my $chr_size;
	($chr, $chr_size) = (split /\s+/, $chr)[1,2];
	#if chromosome
	if(exists $chr_order{$chr}){
		my $rect_h = $chr_size/150000000 * 300; my $h2 = $rect_h + 2;
		my $rect_x = $chr_order{$chr} * $width - 0.5 * $chr_width; my $text_x = $rect_x - 15; my $x2 = $rect_x - 1;
		my $rect_y = $base_height - 35 - $rect_h; my $text_y = $base_height; my $y2 = $rect_y - 1;
		my $chr_width2 = $chr_width + 2;
		#draw whole chromosoem
		print "<rect x=\"$x2\" y=\"$y2\" width=\"$chr_width2\" height=\"$h2\" style=\"fill:black\"/>\n";
		print "<rect x=\"$rect_x\" y=\"$rect_y\" width=\"$chr_width\" height=\"$rect_h\" style=\"fill:white\"/>\n";
		print "<text style=\"fill:black;font-family:arial;font-weight:bold;font-size:${font}pt\" x=\"$text_x\" y=\"$text_y\">$chr</text>\n";
		my @line = split /\n/, $info;
		map{
			my ($block_y, $block_h, $block_color);
			my ($start, $length, $qry_id) = (split /\s+/, $_)[1,2,3];
			$block_y = $rect_y + $rect_h * $start/$chr_size;
			$block_h = $length/$chr_size * $rect_h;				
			if(exists $which{$qry_id}){
				$block_color = $color[$which{$qry_id}];
			}
			else{ $block_color = $color[6];}			
			print "<rect x=\"$rect_x\" y=\"$block_y\" width=\"$chr_width\" height=\"$block_h\" style=\"fill:$block_color\"/>\n";
		} @line;

	}
}
close FA;
print "\n";
print "</svg>\n";

