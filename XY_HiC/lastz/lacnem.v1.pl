#!/usr/bin/perl
=head1 Description

 lastz, chain, net & maf pipeline;

=head1 Version

 Yongli Zeng, zengyongli@genomics.cn
 Version 0.9, 2011-07-11

=head1 Options

 --direction <str>    direction for output files,
                        default "./output";
 --mode <str>         mode selection, "multi" or "single",
                        default "multi";
 --num <int>          split the task into <int> files,
                        default 20;
 --parasuit <str>     easily set parameters suit to define --lpara and --apara.
                        "chimp": for human vs chimp, gorilla, rhesus, marmoset and so on; (near)
                        "chick": for human vs chicken, zebra finch and so on; (far)
                        *** chimp ********************************************************************************
                        * --lpara:
                        *   --hspthresh=4500 --gap=600,150 --ydrop=15000 --notransition
                        *   --scores=$Bin/chimpMatrix --format=axt
                        * --apara:
                        *   -minScore=5000 -linearGap=$Bin/medium
                        ******************************************************************************************

                        *** chick ********************************************************************************
                        * --lpara:
                        *   --step=19 --hspthresh=2200 --inner=2000 --ydrop=3400 --gappedthresh=10000
                        *   --scores=$Bin/birdMatrix --format=axt
                        * --apara:
                        *   -minScore=5000 -linearGap=$Bin/loose
                        ******************************************************************************************
 --lpara <str>        parameters for lastz,
                        default "--format=axt";
 --apara <str>        parameters for axtChain,
                        default "-linearGap=$Bin/medium";
 --tn <str>           name for target in maf,
                        default as filename of target.fa;
 --qn <str>           name for query in maf,
                        default as filename of query.fa;
 --step <str>         1:initial; 2:split; 3:lastz; 4:chain; 5:net; 6:maf, 7:reciprocal best hit;
                        default: "123456";
 --qsub               use qsub-sge.pl to run lastz & chain;

 --qpara <str>        parameters for qsub-sge.pl,
                        default " --maxjob 50 --resource vf=1.5g --reqsub --convert no";
 --help               show this page;

=head1 Usage

 nohup perl lacnem.pl target.fa query.fa &

=cut


use strict;
use FindBin qw($Bin);
use File::Basename;
use Getopt::Long;
use Cwd;

my ($direction, $mode, $num, $parasuit, $lpara, $apara, $tn, $qn, $step, $qsub, $qpara, $help);
GetOptions(
	"direction:s"	=> \$direction,
	"mode:s"		=> \$mode,
	"num:i"			=> \$num,
	"parasuit:s"    => \$parasuit,
	"lpara:s"    	=> \$lpara,
	"apara:s"       => \$apara,
	"tn:s"			=> \$tn,
	"qn:s"			=> \$qn,
	"step:s"		=> \$step,
	"qsub"			=> \$qsub,
	"qpara:s"	    => \$qpara,
	"help"			=> \$help,
)or die "Unknown option!\n";

my $fasta_target =shift;
my $fasta_query =shift;

die `pod2text $0` if (!($fasta_target && $fasta_query) || $help);
die "$fasta_target not found!\n" unless (-e $fasta_target);
die "$fasta_query not found!\n" unless (-e $fasta_query);

$direction ||= "./output";
$direction =~ s/\/$//;
$mode ||= "multi";
$num ||= 20;
if ($parasuit eq "chimp"){
	$lpara = "--hspthresh=4500 --gap=600,150 --ydrop=15000 --notransition --scores=$Bin/chimpMatrix --format=axt";
	$apara = "-minScore=5000 -linearGap=$Bin/medium";
}elsif ($parasuit eq "chick"){
	$lpara = "--step=19 --hspthresh=2200 --inner=2000 --ydrop=3400 --gappedthresh=10000 --scores=$Bin/birdMatrix --format=axt"; #/panfs/ANIMAL/GROUP/group003/zengyl/0.software/lastz/birdMatrix --format=axt";
	$apara = "-minScore=5000 -linearGap=$Bin/loose";# /panfs/ANIMAL/GROUP/group003/zengyl/0.software/lastz/loose";
}elsif ($parasuit eq 'XY'){
	$lpara = "--step=19 --hspthresh=2200 --inner=2000 --ydrop=3400 --gappedthresh=10000 --scores=$Bin/birdMatrix --format=axt"; #/panfs/ANIMAL/GROUP/group003/zengyl/0.software/lastz/birdMatrix --format=axt";
	$apara = "-minScore=5000 -linearGap=$Bin/medium";
}elsif ($parasuit ne ""){
	die "error --parasuit option value: $parasuit\n";
}
$lpara ||= "--format=axt";
$apara ||= "-linearGap=$Bin/medium";
#my $n1 = basename($fasta_target);
#my $n2 = basename($fasta_query);
#$n1 =~ s/\..*$//;
#$n2 =~ s/\..*$//;
#$tn ||= $n1;
#$qn ||= $n2;
$tn ||= "target";
$qn ||= "query";
$step ||= "123456";
$qpara ||= " --maxjob 100 --resource vf=1.5g,num_proc=1 --reqsub --convert no --queue st.q --pro_code F16ZQSB1SY2984 ";
$tn .= ".";
$qn .= ".";

#die "$qsub_para\n";
# step1: initial
my $time = time();
if ($step =~ /1/){
	testmkdir("$direction/1.target");

	`$Bin/faToTwoBit $fasta_target $direction/target.2bit`;
	`$Bin/faToTwoBit $fasta_query $direction/query.2bit`;

	`$Bin/faSize $fasta_target -detailed > $direction/target.sizes`;
	`$Bin/faSize $fasta_query -detailed > $direction/query.sizes`;
	
}

#step2: split
if ($step =~ /2/){
	if ($mode eq "single"){
		`$Bin/split_fasta.pl $fasta_target $direction/1.target 999999999 avg yes`;
	}else{
		`$Bin/split_fasta.pl $fasta_target $direction/1.target $num avg yes`;
	}
}

# step3: run lastz
if ($step =~ /3/){
	testmkdir("$direction/2.lastz");
#	testmkdir("$direction/3.chain");
	my $path =getcwd();
	if ($direction =~ /^\//){
		$path = "";
	}
	$path .= "/";

	if ($qsub){
		open SH, ">$direction/lastzshell.sh" or die "can't open lastzshell.sh\n";
	}

	my @tdir = `ls $direction/1.target/*.2bit`;

	my $du = 0;
	foreach my $tt(@tdir){
		my $fa = $tt;
		chomp($fa);
		$fa =~ s/2bit$/fasta/;
		my $size = -s "$fa";
		$du += $size;
	}
	my $seg = int($du / $num);
	my $count = 0;
	my $i = 1;

	foreach my $tt(@tdir){
		chomp($tt);
		my $tinput = $path . "$tt";
		my $tinput_raw = $tinput;
		if ($mode eq "multi"){
			my $fa = $tt;
			chomp($fa);
			$fa =~ s/2bit$/fasta/;
			my $faline = `grep -c ">" $fa`;
			chomp($faline);
			$tinput .= "[multi]" if ($faline != 1);
		}
		my $qinput = $path . "$direction/query.2bit";
		my $nameaxt = basename($tt);
		$nameaxt =~ s/2bit$/axt/;
		$nameaxt = $path . "$direction/2.lastz/$nameaxt";
#		my $namechain = basename($nameaxt);
#		$namechain =~ s/axt$/chain/;
#		$namechain = $path. "$direction/3.chain/$namechain";
		if ($qsub){
			if ($mode eq "multi"){
				print SH "$Bin/lastz $tinput $qinput $lpara > $nameaxt;\n";
				#print SH "$Bin/axtChain -linearGap=$pathway/medium $nameaxt $tinput_raw $qinput $namechain\n";
			}else{
				my $fa = $tt;
				$fa =~ s/2bit$/fasta/;
				my $size = -s "$fa";
				print SH "$Bin/lastz $tinput $qinput $lpara > $nameaxt; ";
				#print SH "$Bin/axtChain -linearGap=$pathway/medium $nameaxt $tinput_raw $qinput $namechain; ";
				$count += $size;
				if ($count >= $seg || $count / $seg > 0.95){
					print SH "\n";
					$i++;
					$count = 0;
				}
			}
		}else{
			#warn "lastz!\n";
			`$Bin/lastz $tinput $qinput $lpara > $nameaxt`;
			#`$Bin/axtChain -linearGap=$pathway/medium $nameaxt $tinput_raw $qinput $namechain`;
		}
	}
	if ($qsub){
		close SH;
		#die "over!\n";
		`$Bin/qsub-sge.pl $direction/lastzshell.sh $qpara`;
	}
}

# step4: chain
if ($step =~ /4/){
	testmkdir("$direction/3.chain");
	
	my $path =getcwd();
	if ($direction =~ /^\//){
		$path = "";
	}
	$path .= "/";
	
	my @chr_lastz = `ls $direction/2.lastz`;
	if ($qsub){
		open SH, ">$direction/chainshell.sh" or die "can't open chainshell.sh\n";
	}
	foreach (@chr_lastz){
		chomp;
		my $name = basename($_);
		my $tname = $name;
		$tname =~ s/axt$/2bit/;
		if ($qsub){
			print SH "$Bin/axtChain $apara $path/$direction/2.lastz/$_ $path/$direction/1.target/$tname $path/$direction/query.2bit $path/$direction/3.chain/$name.chain\n";
		}
		else{
			`$Bin/axtChain $apara $direction/2.lastz/$_ $direction/1.target/$tname $direction/query.2bit $direction/3.chain/$name.chain`;
		}
	}
	if ($qsub){
		close SH;
		`$Bin/qsub-sge.pl $direction/chainshell.sh $qpara`;
	}
}

# step5: net
if ($step =~ /5/){
	testmkdir("$direction/4.prenet");
	testmkdir("$direction/5.net");
	`$Bin/chainMergeSort $direction/3.chain/*.chain > $direction/4.prenet/all.chain`;
	`$Bin/chainPreNet $direction/4.prenet/all.chain $direction/target.sizes $direction/query.sizes $direction/4.prenet/all_sort.chain`;
	`$Bin/chainNet $direction/4.prenet/all_sort.chain $direction/target.sizes $direction/query.sizes $direction/5.net/temp $direction/5.net/query.net`;
	`$Bin/netSyntenic $direction/5.net/temp $direction/5.net/target.net`;
}

# step6: maf
if ($step =~ /6/){
	testmkdir("$direction/6.net_to_axt");
	testmkdir("$direction/7.maf");
	`$Bin/netToAxt $direction/5.net/target.net $direction/4.prenet/all_sort.chain $direction/target.2bit $direction/query.2bit $direction/6.net_to_axt/all.axt`;
	`$Bin/axtSort $direction/6.net_to_axt/all.axt $direction/6.net_to_axt/all_sort.axt`;
	`$Bin/axtToMaf -tPrefix=$tn -qPrefix=$qn $direction/6.net_to_axt/all_sort.axt $direction/target.sizes $direction/query.sizes $direction/7.maf/all.maf`;
}

# step7: reciprocal best hit
## ref: http://genomewiki.ucsc.edu/index.php/HowTo:_Syntenic_Net_or_Reciprocal_Best
if ($step =~ /7/){
	testmkdir("$direction/8.reciprocal_best");
	testmkdir("$direction/9.axtRBestNet");
	testmkdir("$direction/10.mafRBestNet");
	`$Bin/chainStitchId $direction/4.prenet/all.chain stdout | $Bin/chainSwap stdin stdout | $Bin/chainSort stdin $direction/8.reciprocal_best/query_target.chain`;
	`$Bin/chainPreNet $direction/8.reciprocal_best/query_target.chain $direction/query.sizes $direction/target.sizes stdout | $Bin/chainNet -minSpace=1 -minScore=0 stdin $direction/query.sizes $direction/target.sizes stdout /dev/null | $Bin/netSyntenic stdin stdout | gzip -c > $direction/8.reciprocal_best/query_target.rbest.net.gz`;
	`$Bin/netChainSubset $direction/8.reciprocal_best/query_target.rbest.net.gz $direction/8.reciprocal_best/query_target.chain stdout | $Bin/chainStitchId stdin stdout | gzip -c > $direction/8.reciprocal_best/query_target.rbest.chain.gz`;
	`$Bin/chainSwap $direction/8.reciprocal_best/query_target.rbest.chain.gz stdout | $Bin/chainSort stdin stdout | gzip -c > $direction/8.reciprocal_best/target_query.rbest.chain.gz`;
	`$Bin/chainPreNet $direction/8.reciprocal_best/target_query.rbest.chain.gz $direction/target.sizes $direction/query.sizes stdout | $Bin/chainNet -minSpace=1 -minScore=0 stdin $direction/target.sizes $direction/query.sizes stdout /dev/null | $Bin/netSyntenic stdin stdout | gzip -c > $direction/8.reciprocal_best/target_query.rbest.net.gz`;
	`$Bin/netToAxt $direction/8.reciprocal_best/target_query.rbest.net.gz $direction/8.reciprocal_best/target_query.rbest.chain.gz $direction/target.2bit $direction/query.2bit stdout | $Bin/axtSort stdin stdout | gzip -c > $direction/9.axtRBestNet/target_query.rbest.axt.gz`;
	`$Bin/axtToMaf -tPrefix=$tn -qPrefix=$qn $direction/9.axtRBestNet/target_query.rbest.axt.gz $direction/target.sizes $direction/query.sizes $direction/10.mafRBestNet/target_query.rbest.maf`;
}

$time = time() - $time;
my $hour = int($time / 3600);
my $minute = int(($time - $hour * 3600) / 60);
my $second = int($time % 60);
print "\nTotal time cost: $hour h $minute m $second s.\n";

#################
sub testmkdir(){
	my $dir = shift;
	if (-e $dir){
		warn "Warning: Folder ($dir) exists! all files in it will be deleted!\n";
		`rm -r $dir`;
	}
	`mkdir -p $dir`;
}

