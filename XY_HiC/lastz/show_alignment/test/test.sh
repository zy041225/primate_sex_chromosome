X1=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrX1.info
X2=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrX2.info
X3=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrX3.info
X4=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrX4.info
X5=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrX5.info
Xun=/szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/01.identification/04.X1-X5/Oana_old/data/lst/Oana_v2.1.nonPARX.chrXun.info
script=test.pl
for i in anolis_carolinensis gallus_gallus homo_sapiens monodelphis_domestica mus_musculus
do
	perl $script $i.lst $X1 $X2 $X3 $X4 $X5 $Xun $i.filter >$i.svg 
done

