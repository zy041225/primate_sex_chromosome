#for i in human mouse chick opossum
#do
#	awk '/^net/ || /^ fill/' /ifs5/NGB_UN/USER/gengyuncong/02.monotreme_analysis/01.platypus/02.chrAX_other_species/*$i*/out/5.net/target.net |awk '{print $1 " " $2 " " $3 " " $4 " " $5 " "}' >$i.filter
#	awk '/net/' $i.filter |awk '{print $2}' |awk '/chr|LG/&&!/chrMT/' |sort -t $"r" -n -k2,2 >$i.lst
#done
for i in anolis_carolinensis gallus_gallus homo_sapiens monodelphis_domestica mus_musculus
do
	awk '/^net/ || /^ fill/' /szhwfs1/ST_DIVERSITY/GROUP4/F16ZQSB1SY2984/USER/gengyuncong/04.lastz/Oana/$i/lastz_as_query/lastz_as_query/5.net/target.net |awk '{print $1 " " $2 " " $3 " " $4 " " $5 " "}' >$i.filter

done
