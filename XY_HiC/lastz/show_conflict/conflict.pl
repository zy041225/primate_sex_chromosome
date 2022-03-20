#! /usr/bin/perl -w

=head1 Description

 show conflicts between query contigs and target chromosomes

=head1 Version

 Yuncong Geng, 2016-7-29

=head1 Options

 --direction <str>	direction for output files,
			 default "./output";
 --help			show this page;

=head1 Usage

 perl conflict.pl --direction out lastz.maf 

=cut

use strict;
use FindBin qw($Bin);
use Getopt::Long;

my ($direction, $help);
GetOptions(
        "direction:s"   => \$direction,
        "help"                  => \$help,
)or die "Unknown option!\n";

my $maf = shift;
die `pod2text $0` if (!($maf) || $help);
die "$maf not found!\n" unless (-e $maf);

$direction ||= "./output";
$direction =~ s/\/$//;
mkdir $direction;

#step 1: extract info
mkdir "$direction/01.info";
`perl $Bin/scripts/01.info/1_show.pl $maf > $direction/01.info/1.info`;
`perl $Bin/scripts/01.info/2_show.pl $maf > $direction/01.info/2.info`;
#`perl $Bin/scripts/01.info/3_set_in_order.pl $maf > $direction/01.info/qry_in_order`;
#`perl $Bin/scripts/01.info/3_show.pl $direction/01.info/qry_in_order > $direction/01.info/3.info`;

#step 2: display in detail
mkdir "$direction/02.detail";
`perl $Bin/scripts/02.detail/1_detail.pl $direction/01.info/1.info > $direction/02.detail/1.detail`;
`perl $Bin/scripts/02.detail/2_1_detail.pl $direction/01.info/2.info $maf > $direction/02.detail/2.raw`;
`perl $Bin/scripts/02.detail/2_2_correct.pl $direction/02.detail/2.raw > $direction/02.detail/2.cor`;
`perl $Bin/scripts/02.detail/2_3_stat.pl $direction/02.detail/2.cor > $direction/02.detail/2.cor.stat`;
`perl $Bin/scripts/02.detail/2_4_filter.pl $direction/02.detail/2.cor.stat 3 > $direction/02.detail/2.cor.stat.filter`;
`perl $Bin/scripts/02.detail/2_5_info.pl $direction/02.detail/2.cor.stat.filter $direction/02.detail/2.cor > $direction/02.detail/2.info`;
`perl $Bin/scripts/02.detail/2_6_detail.pl $direction/02.detail/2.cor.stat.filter $direction/02.detail/2.cor > $direction/02.detail/2.detail`;
#`perl $Bin/scripts/02.detail/3_detail.pl $direction/01.info/3.info $direction/01.info/qry_in_order > $direction/02.detail/3.detail`;

#step 3: draw svg
mkdir "$direction/03.draw";
mkdir "$direction/03.draw/1.out";
mkdir "$direction/03.draw/2.out";
`perl $Bin/scripts/03.draw/1_draw.pl $direction/02.detail/1.detail $direction/03.draw/1.out`;
`perl $Bin/scripts/03.draw/2_draw.pl $direction/02.detail/2.info $direction/02.detail/2.detail $direction/03.draw/2.out`;
