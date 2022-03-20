# Y gene heatmap

## Input

- gene family tab (`mcl.out.tab.add.famName`), tab-delimited format: gene family ID, gene family name (should contain the keyword of the gene family)

for example

```
81	DDX3Y
81	DDX3X
2	SRY
82	EIF1AX
82	EIF1AY
```

- species table (`species.tab`), tab-delimited format

for example

```
Ateles_geoffroyi	ATEGEO
Callithrix_jacchus	CALJAC
Saguinus_midas	SAGMID
Cebus_albifrons	CEBALB
```

- gene family clustered result (`mcl.out.tab.add`), tab-delimited format: geneID, scafID, strand, start (start from 1), end (start from 1), geneName, description

- fragmented gene directory `frag.dir/`, store in species

for example

```
|-- ATEGEO
|   |-- fragmented_gene.final.tab.filt
|   |-- fragmented_gene.final.tab.filt.cds
|   |-- fragmented_gene.final.tab.filt.gff
|   |-- fragmented_gene.final.tab.filt.pep
|-- CALJAC
|   |-- fragmented_gene.final.tab.filt
|   |-- fragmented_gene.final.tab.filt.cds
|   |-- fragmented_gene.final.tab.filt.gff
|   |-- fragmented_gene.final.tab.filt.pep
```

among them, `fragmented_gene.final.tab.filt` is in the format (tab-delimited): geneID, scafID, strand, start (start from 1), end (start from 1), geneName, description

## How to run

```
perl summarize_Y_family.v2.curate.pl mcl.out.tab.add.famName species.tab mcl.out.tab.add frag.dir/ > mcl.out.tab.add.famName.count
perl prepare_for_heatmap.pl mcl.out.tab.add.famName.count > mcl.out.tab.add.famName.count.heatmap
Rscript Yfamily_heatmap.all.r mcl.out.tab.add.famName.count.heatmap mcl.out.tab.add.famName.count.heatmap.pdf
```

## Note

`mcl.out.tab.add.famName.count` would use the name of the first record of each gene family in `mcl.out.tab.add.famName`


