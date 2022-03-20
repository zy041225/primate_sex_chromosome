#! /usr/bin/perl
use strict;

my $info = shift;
my $direction = shift;

#my ($svg_width, $svg_height) = (400,400);
my $width = 20;
my $svg_width = 400;
my $svg_height = 2000; 
my $text_size = 5;

my $color_set = "127,201,127 190,174,212 253,192,134";
my @array = split /\s+/, $color_set;
my @color = map{ "RGB(" . $_ . ")" } @array;

open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ = "\n";
while(<INFO>){
	my $general = $_; chomp($general); $/ = ">";
	my $detail = <INFO>; chomp($detail); my @d_lines = split /\n/, $detail; $/ = "\n";
	my @g_info = split /\t/, $general; $g_info[0] =~ s/target.//; $g_info[1] =~ s/query.//;
	open(SVG,">$direction/${g_info[0]}_${g_info[1]}.svg")||die"$!\n";
	#create svg and draw rectangle
	print SVG "<?xml version=\"1.0\" standalone=\"no\"?>\n";
	print SVG "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n";
	print SVG "\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n";
	print SVG "\n";
	print SVG "<svg width=\"$svg_width\" height=\"$svg_height\" version=\"1.1\"\n";
	print SVG "xmlns=\"http://www.w3.org/2000/svg\">\n";
	print SVG "\n";
	my $y = 0.191 * $svg_width; 
	my $scale= 10e4;
	my $h_tgt = ($g_info[3] - $g_info[2] + 1)/$scale * 0.618;
	my $h_qry = ($g_info[5] - $g_info[4] + 1)/$scale * 0.618;
	print SVG "<rect x=\"100\" y=\"$y\" width=\"$width\" height=\"$h_qry\" style=\"fill:$color[0]\"/>\n";
	print SVG "<rect x=\"200\" y=\"$y\" width=\"$width\" height=\"$h_tgt\" style=\"fill:$color[1]\"/>\n";
	print SVG "<rect x=\"300\" y=\"$y\" width=\"$width\" height=\"$h_qry\" style=\"fill:$color[2]\"/>\n";
	#draw in detail
	map{
		my @d_info = split /\t/, $_; 
		my ($h1, $h2, $y1, $y2, $y3, $y11, $y22, $y33);
		$h1 = $d_info[5]/($g_info[5] - $g_info[4] + 1) * $h_qry; $h2 = $d_info[2]/($g_info[3] - $g_info[2] + 1) * $h_tgt;
		$y2 = $y + ($d_info[0] - $g_info[2])/($g_info[3] - $g_info[2] + 1) * $h_tgt; $y22 = $y2 + $h2;
		if ($d_info[3] < $d_info[4]){ #if positive strand
			$y1 = $y + ($d_info[3] - $g_info[4])/($g_info[5] - $g_info[4] + 1) * $h_qry; $y11 = $y1 + $h1;
			$y3 = $y - ($d_info[4] - $g_info[4])/($g_info[5] - $g_info[4] + 1) * $h_qry + $h_qry; $y33 = $y3 + $h1;
			print SVG "<line x1=\"120\" y1=\"$y1\" x2=\"200\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"120\" y1=\"$y11\" x2=\"200\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"300\" y1=\"$y33\" x2=\"220\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"300\" y1=\"$y3\" x2=\"220\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
		}
		else{ #minus strand
			$y1 = $y + ($d_info[4] - $g_info[4])/($g_info[5] - $g_info[4] + 1) * $h_qry; $y11 = $y1 + $h1;
			$y3 = $y - ($d_info[3] - $g_info[4])/($g_info[5] - $g_info[4] + 1) * $h_qry + $h_qry; $y33 = $y3 + $h1;
			print SVG "<line x1=\"120\" y1=\"$y11\" x2=\"200\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"120\" y1=\"$y1\" x2=\"200\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"300\" y1=\"$y3\" x2=\"220\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
			print SVG "<line x1=\"300\" y1=\"$y33\" x2=\"220\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
		}
		print SVG "<rect x=\"100\" y=\"$y1\" width=\"$width\" height=\"$h1\" style=\"fill:red\"/>\n";
		print SVG "<rect x=\"200\" y=\"$y2\" width=\"$width\" height=\"$h2\" style=\"fill:red\"/>\n";
		print SVG "<rect x=\"300\" y=\"$y3\" width=\"$width\" height=\"$h1\" style=\"fill:red\"/>\n";
	} @d_lines;
	#draw legend
	print SVG "<text x=\"60\" y=\"60\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:15pt\">$g_info[1] +</text>\n";
        print SVG "<text x=\"190\" y=\"60\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:15pt\">$g_info[0]</text>\n";
        print SVG "<text x=\"260\" y=\"60\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:15pt\">$g_info[1] -</text>\n";
	my $y_start = $y + $text_size; my $y_end1 = $y + $h_qry; my $y_end2 = $y + $h_tgt; 
        my $start_coord1 = $g_info[4]/1e6; my $end_coord1 = $g_info[5]/1e6; $start_coord1 = sprintf("%.2f", $start_coord1); $end_coord1 = sprintf("%.2f", $end_coord1);
        my $start_coord2 = $g_info[2]/1e6; my $end_coord2 = $g_info[3]/1e6; $start_coord2 = sprintf("%.2f", $start_coord2); $end_coord2 = sprintf("%.2f", $end_coord2);
        my $start_coord3 = ($g_info[6] - 1 - $g_info[4])/1e6; my $end_coord3 = ($g_info[6] - 1 - $g_info[5])/1e6; $start_coord3 = sprintf("%.2f", $start_coord3); $end_coord3 = sprintf("%.2f", $end_coord3);
	if ($start_coord1 ne "10000.00"){
                print SVG "<text x=\"125\" y=\"$y_start\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$start_coord1 Mb</text>\n";
                print SVG "<text x=\"125\" y=\"$y_end1\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$end_coord1 Mb</text>\n";
        }
        if ($start_coord3 ne "10000.00"){
                print SVG "<text x=\"325\" y=\"$y_start\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$start_coord3 Mb</text>\n";
                print SVG "<text x=\"325\" y=\"$y_end1\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$end_coord3 Mb</text>\n";
        }
        print SVG "<text x=\"225\" y=\"$y_start\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$start_coord2 Mb</text>\n";
        print SVG "<text x=\"225\" y=\"$y_end2\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$end_coord2 Mb</text>\n";
	print SVG "\n";
	print SVG "</svg>\n";
	close SVG;
}
close INFO;
