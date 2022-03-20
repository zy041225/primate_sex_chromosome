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
idx = {}
with open(parFile) as f:
	for line in f:
		line = line.rstrip()
		if(line.startswith('#|')): continue
		tmp = line.split('\t')
		if(line.startswith('# Family')):
			for i in range(0, len(tmp)):
				if(tmp[i] == '# Family' or tmp[i] == 'Gains' or tmp[i] == 'Losses' or tmp[i] == 'Expansions' or tmp[i] == 'Contractions'): continue
				header[i] = tmp[i]
				if(header[i] in dic):
					idx[dic[header[i]]] = i
				else:
					idx[header[i]] = i
			print(line)
		else:
			famID = tmp[0]
			num = {}
			out = {}
			Out = famID
			for i in sorted(header.keys()):
				if(header[i] in dic): # header[i] is the ID in the count output
					num[dic[header[i]]] = int(tmp[i]) # dic[header[i]] is the ID in the original tree
				else:
					num[header[i]] = int(tmp[i])
			#sys.exit(num)
			for node in t.iter_descendants("postorder"):
				out[int(idx[node.name])] = num[node.name]
				#print(node.name, idx[node.name], num[node.name], out[idx[node.name]])
				if node.is_leaf(): 
					continue
				else:
					flag = 0
					for node1 in node.iter_descendants("postorder"):
						if node1.is_leaf():
							#print('#', node1.name, num[node1.name], flag)
							if num[node1.name] > 0: flag = 1
					#print(node.name, 'flag', flag)
					if flag == 0:
						#print('#', node.name)
						out[int(idx[node.name])] = 0
				#print(node.name, out[idx[node.name]])
			#print(num)
			flag = 0
			out[int(idx[t.name])] = num[t.name]
			for node in t.iter_descendants("postorder"):
				if node.is_leaf() and num[node1.name] > 0:
					flag = 1
			if flag == 0:
				out[int(idx[t.name])] = 0

			for i in sorted(out.keys()):
				Out += "\t%i" % (out[i])
			print(Out)
			#print('#'+line)
