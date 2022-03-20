# Y degeneration

## Input

- Y gene family cluster matrix (`mcl.out.tab.add.famName.count.heatmap`), see "Y_gene_heatmap" how to generate the file
- ancestral gene ID tab (`geneID.lst`)

```
SRY
KDM5D
XKRY
```

- species tree (`tree.nwk`), newick format. Note that the internal node ID is required. Branch length is not required for Dollo model.

```
((((((((HYLPIL,(SYMSYN,HOOLEU)'1')'2',NOMSIK)'3',(PONABE,(GORGOR,(HOMSAP,(PANPAN,PANTRO)'4')'5')'6')'7')'8',(((ERYPAT,(CHLSAB,CHLAET)'9')'10',((MACSIL,(MACMUL,MACASS)'11')'12',(MANLEU,(PAPANU,PAPHAM)'13')'14')'15')'16',(COLGUE,((PYGNIG,RHIROX)'17',NASLAR)'18')'19')'20')'21',(ATEGEO,((SAPAPE,CEBALB)'22',(CALJAC,SAGMID)'23')'24')'25')'26',(DAUMAD,NYCPYG)'27')'28',TUPBEL)'29',MUSMUS)'30';
```

- one-to-one relationship of the internal node between the input tree and the `Count` output `ancestral_node.id`. Usually they are the same but should double-check

```
1	1
2	2
3	3
```

## How to run

```
perl heatmap2count.pl mcl.out.tab.add.famName.count.heatmap > mcl.out.tab.add.famName.count.heatmap.count
perl force_ancestor.pl geneID.lst outgroup mcl.out.tab.add.famName.count.heatmap.count > mcl.out.tab.add.famName.count.heatmap.count.forceAnc # outgroup is the outgroup species name in mcl.out.tab.add.famName.count.heatmap.count
java -jar Count.jar # output file named mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo
perl recover_frag_missing.pl mcl.out.tab.add.famName.count.heatmap.count mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo > mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec
python3 correct_ancestral_node.py tree.nwk ancestral_node.id mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec > mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor
python3 summarize_count_result.py tree.nwk ancestral_node.id mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor > mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.tab
python3 summarize_count_result.node.py tree.nwk ancestral_node.id mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor > mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.presence
awk '$1==29' mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.presence > mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.presence.ancestor # 29 here means the MRCA node of primates and treeshrew
python3 plot_count_result.v1.py tree.nwk mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.tab mcl.out.tab.add.famName.count.heatmap.count.forceAnc.dollo.rec.cor.presence.ancestor count.heatmap.count.forceAnc.dollo.rec.cor.tab.pdf
```

