#! /usr/bin/perl -w
use strict;

my $info = shift;
my $detail = shift;
my $direction = shift;

#my ($svg_width, $svg_height) = (400,400);
my $width = 20;
my $svg_width = 400;
my $svg_height = 2000; 
my $text_size = 5;
my $gap = 50;

my $color_set = "127,201,127 190,174,212 253,192,134 255,255,153 56,108,176 240,2,127";
my @array = split /\s+/, $color_set;
my @color = map{ "RGB(" . $_ . ")" } @array;

my %pair;
my %d_fs;
my %d_le;

open(INFO,$info)||die"$!\n";
$/ = ">"; <INFO>; $/ = "\n";
while(<INFO>){
	my $general = $_; chomp($general); $/ = ">";
	my $detail = <INFO>; chomp($detail); my @lines = split /\n/, $detail; $/ = "\n";
	my @items = split /\t/, $general;
	map{ 
		my @info = split /\t/, $_; $pair{"$items[0]\t$items[1]"} .= "$info[0]\t";
		$d_fs{"$items[0]\t$items[1]"}{$info[0]} = $info[1];
		$d_le{"$items[0]\t$items[1]"}{$info[0]} = $info[2];
	} @lines;
}
close INFO;

open(DETAIL,$detail)||die"$!\n";
$/ = ">"; <DETAIL>; $/ = "\n";
while(<DETAIL>){
        my $general = $_; chomp($general); $/ = ">";
        my $detail = <DETAIL>; chomp($detail); my @d_lines = split /\n/, $detail; $/ = "\n";
        my @g_info = split /\t/, $general; 
	my $id_pair = "$g_info[0]\t$g_info[1]"; my @array = split /\t/, $pair{$id_pair};
	$g_info[0] =~ s/target.//; $g_info[1] =~ s/query.//;
	open(SVG,">$direction/${g_info[0]}_${g_info[1]}.svg")||die"$!\n";
	#create svg and draw rectangle
	print SVG "<?xml version=\"1.0\" standalone=\"no\"?>\n";
        print SVG "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n";
        print SVG "\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n";
        print SVG "\n";
        print SVG "<svg width=\"$svg_width\" height=\"$svg_height\" version=\"1.1\"\n";
        print SVG "xmlns=\"http://www.w3.org/2000/svg\">\n";
        print SVG "\n";
	my $y = 0.191 * $svg_width; my $scale = 10e4;
	my $h_tgt = ($g_info[3] - $g_info[2] + 1)/$scale * 0.618;
	my $start = $g_info[2]/1e6; my $end = $g_info[3]/1e6; $start = sprintf("%.2f", $start); $end = sprintf("%.2f", $end);
	my $y_start = $y + $text_size; my $y_end = $y + $h_tgt;
	print SVG "<rect x=\"100\" y=\"$y\" width=\"$width\" height=\"$h_tgt\" style=\"fill:$color[0]\"/>\n";
	print SVG "<text x=\"90\" y=\"60\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:15pt\">$g_info[0]</text>\n";
	print SVG "<text x=\"125\" y=\"$y_start\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$start Mb</text>\n";
        print SVG "<text x=\"125\" y=\"$y_end\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$end Mb</text>\n";
	my $count = 1; my $y_text = 60; my %y_coord;
	map{ 
		my $h_qry = ($d_le{$id_pair}{$_} - $d_fs{$id_pair}{$_} + 1)/$scale * 0.618;
		$start = $d_fs{$id_pair}{$_}/1e6; $end = $d_le{$id_pair}{$_}/1e6; $start = sprintf("%.2f", $start); $end = sprintf("%.2f", $end);
		$y_start = $y + $text_size; $y_end = $y + $h_qry; $y_coord{$_} = $y;
		my $name = $_; $name  =~ s/query.//;
		print SVG "<rect x=\"200\" y=\"$y\" width=\"$width\" height=\"$h_qry\" style=\"fill:$color[$count]\"/>\n";
		print SVG "<text x=\"170\" y=\"$y_text\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:15pt\">$name</text>\n";
		print SVG "<text x=\"225\" y=\"$y_start\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$start Mb</text>\n";
        	print SVG "<text x=\"225\" y=\"$y_end\" fill=\"black\" style =\"font-family:arial;font-weight:bold;font-size:${text_size}pt\">$end Mb</text>\n";
		$count += 1; $y += $gap + $h_qry; $y_text += $gap + $h_qry;
	} @array;
	#draw in detail
	map{
		my @d_info = split /\t/, $_;
		my ($h1, $y1, $y11, $h2, $y2, $y22);
		$h1 = $d_info[3]/$scale * 0.618;
		$y1 = 0.191 * $svg_width + ($d_info[1] - $g_info[2])/$scale * 0.618; $y11 = $y1 + $h1;
		$h2 = $d_info[6]/$scale * 0.618;
		if ($d_info[4] < $d_info[5]){ #if positive strand
			$y2 = $y_coord{$d_info[0]} + ($d_info[4] - $d_fs{$id_pair}{$d_info[0]})/$scale * 0.618;
			$y22 = $y2 + $h2;
			print SVG "<line x1=\"120\" y1=\"$y1\" x2=\"200\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
                        print SVG "<line x1=\"120\" y1=\"$y11\" x2=\"200\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
		}
		else{ #if minus strand
			$y2 = $y_coord{$d_info[0]} + ($d_info[5] - $d_fs{$id_pair}{$d_info[0]})/$scale * 0.618;
			$y22 = $y2 + $h2;
			print SVG "<line x1=\"120\" y1=\"$y1\" x2=\"200\" y2=\"$y22\" style=\"stroke:red;stroke-width:0.01\"/>\n";
                        print SVG "<line x1=\"120\" y1=\"$y11\" x2=\"200\" y2=\"$y2\" style=\"stroke:red;stroke-width:0.01\"/>\n";
		}
		print SVG "<rect x=\"100\" y=\"$y1\" width=\"$width\" height=\"$h1\" style=\"fill:red\"/>\n";
                print SVG "<rect x=\"200\" y=\"$y2\" width=\"$width\" height=\"$h2\" style=\"fill:red\"/>\n";
	} @d_lines;
	print SVG "\n";
        print SVG "</svg>\n";
        close SVG;
}
close DETAIL;
