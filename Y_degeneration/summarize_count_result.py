#!/usr/bin/env python3

import sys
from ete3 import Tree

if len(sys.argv) != 4:
	sys.exit('python3 %s <nwk> <ancestral_node.id> <mcl.out.tab.add.add.curate.XY.filt.zero.parsimony>' % (sys.argv[0]))

nwkFile = sys.argv[1]
idFile = sys.argv[2]
parFile = sys.argv[3]

t = Tree(nwkFile, quoted_node_names=True, format=1)

dic = {}
with open(idFile) as f:
	for line in f:
		line = line.rstrip()
		tmp = line.split('\t')
		if(len(tmp) < 2): continue
		id1 = tmp[0] #ID in the count output
		id2 = tmp[1] #ID in the original tree
		dic[id1] = id2

header = {}
with open(parFile) as f:
	for line in f:
		line = line.rstrip()
		if(line.startswith('#|')): continue
		tmp = line.split('\t')
		if(line.startswith('# Family')):
			for i in range(0, len(tmp)):
				if(tmp[i] == '# Family' or tmp[i] == 'Gains' or tmp[i] == 'Losses' or tmp[i] == 'Expansions' or tmp[i] == 'Contractions'): continue
				header[i] = tmp[i]
		else:
			famID = tmp[0]
			num = {}
			for i in sorted(header.keys()):
				if(header[i] in dic): # header[i] is the ID in the count output
					num[dic[header[i]]] = int(tmp[i]) # dic[header[i]] is the ID in the original tree
				else:
					num[header[i]] = int(tmp[i])
			#sys.exit(num)
			for node in t.iter_descendants("postorder"):
				if node.is_root(): continue
				parent = node.up
				if parent.is_root(): continue
				#print(parent.name, node.name)
				if parent.name in dic:
					pName = dic[parent.name]
				else:
					pName = parent.name
				if node.name in dic:
					nName = dic[node.name]
				else:
					nName = node.name

				if(num[parent.name] != num[node.name]):
					tag = ''
					#print(type(num[parent.name]), type(num[node.name]))
					if(num[parent.name] > num[node.name]): tag = 'loss'
					if(num[parent.name] < num[node.name]): tag = 'gain'
					print('%s\t%s->%s\t%s\t%i\t%i' % (famID, parent.name, node.name, tag, num[parent.name], num[node.name]))


