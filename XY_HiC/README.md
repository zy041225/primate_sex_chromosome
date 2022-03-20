# XY Hi-C configuration change

## Input

- X softmasked sequence (`X.sm.fasta`)
- Y softmasked sequence (`Y.sm.fasta`)
- Hi-C matrix (`MACMUL.bsorted.pairs.gz.20000.cool.h5.KR.h5`), in h5 format

## How to run

```
perl lastz/lacnem.v1.pl --parasuit XY --direction Y_as_qry.XY --step 1234567--num 50 --qsub --qpara " --maxjob 50 --resource vf=6g,num_proc=1 --reqsub --convert no --queue QUEUE_CODE --pro_code PROJECT_CODE " X.sm.fasta Y.sm.fasta
zcat Y_as_qry.XY/8.reciprocal_best/target_query.rbest.net.gz | netSyntenic stdin stdout | netFilter -syn stdin | awk '!/^#/' | awk '/^net/ || /^ fill/' | perl net2aln.includeScore.pl - > Xref.netFilter.aln
perl filter_syn.pl Xref.netFilter.aln 200000 5 > Xref.netFilter.aln.syn.txt
awk '$3-$2>=500000 && $6-$5>=500000' Xref.netFilter.aln.syn.txt > Xref.netFilter.aln.syn.txt.500K

conda activate hicexplorer
hicAdjustMatrix -m MACMUL.bsorted.pairs.gz.20000.cool.h5.KR.h5 --chromosomes chrX chrY -a keep -o target.bed.h5 # only keep X and Y to speed up chess
hicConvertFormat --matrices target.bed.h5 --inputFormat h5 --outputFormat cool -o target.bed.h5.cool
chess sim -p 10 target.bed.h5.cool target.bed.h5.cool Xref.netFilter.aln.syn.txt.500K Xref.netFilter.aln.syn.txt.500K.out

```

