#!/usr/bin/perl -w
use strict;

die "perl $0 <mcl.out.tab.add.curate.summary.add.famName.over_2_spe.forCheck> <species.v1.tab> <mcl.out.tab.add.curate> <fragDir>" unless @ARGV == 4;

my (%spe, %fam);

open(IN, $ARGV[1]) or die $!;
while(<IN>){
	chomp;
	my ($full, $short) = (split /\t/)[0,1];
	$spe{$short} = 1;
}
close IN;

open(IN, $ARGV[0]) or die $!;
while(<IN>){
	chomp;
	my ($fam, $gene) = (split /\t/)[0,1];
	next if($gene eq 'NA');
	push @{$fam{$fam}}, $gene;
}
close IN;

my $h = "#fam\tgene";
foreach my $short (sort keys %spe){
	$h .= "\t$short\_present\t$short\_miss";
}
print "$h\n";

foreach my $fam (sort {$a<=>$b} keys %fam){
	my $dir = "$ARGV[2]/$fam/check_missing.curate/";
	my $gene = $fam{$fam}[0];
	my $out = "$fam\t$gene";
	foreach my $short (sort keys %spe){
		if(!-e "$ARGV[3]/$short/fragmented_gene.final.tab.filt"){
			die "$fam\t$gene\t$short\tmissing: $ARGV[3]/$short/fragmented_gene.final.tab.filt\n";
			next;
		}
		my $present_num = `awk '\$1==$fam && \$2=="$short"' $ARGV[2] | wc -l`;
		chomp($present_num);
		my $miss_num = 0;
		foreach my $keyword (@{$fam{$fam}}){
			my $tmp = `awk -F '\\t' '{IGNORECASE = 1} \$7~/$keyword/' $ARGV[3]/$short/fragmented_gene.final.tab.filt | wc -l`;
			chomp($tmp);
			$miss_num += $tmp;
		}
		$out .= "\t$present_num\t$miss_num";
	}
	print "$out\n";
}

