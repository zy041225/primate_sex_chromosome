## Y gene family clustering

### Input

- Protein sequence of all genes (`in.pep`), fasta format
- Protein sequence BLASTP result (`in.pep.m8`), m8 format
- Gene coordinate (`in.gff.pos.add`), tab-delimited format: geneID, scafID, strand, start (start from 1), end (start from 1), geneName, description

Please note that geneID should have species name prefix (seperated by "_", e.g. HOMSAP_geneA)

### How to run

```
perl orthoMCL.step1.prepare.pl in.pep > in.pep.gg
cut -f1,6 in.gff.pos.add > in.gff.pos.add.cut
python3 02.homolog_group_typing.clmInfo.py in.pep.m8 in.gff.pos.add.cut > mcl.out 2> mcl.log
perl format_mlcOut.v1.pl mcl.out > mcl.out.tab
perl AddColumn.v2.pl  mcl.out.tab in.gff.pos.add 3 > mcl.out.tab.add
```

### Output

The final output is: `mcl.out.tab.add`

```
familyID	species	geneID	scafID	strand	start	end	geneName	description
```


