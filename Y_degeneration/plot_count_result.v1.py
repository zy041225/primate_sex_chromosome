#!/usr/bin/env python3

import sys
from ete3 import Tree, faces, TreeStyle
from collections import defaultdict

if len(sys.argv) != 5:
	sys.exit('python3 %s <nwk> <mcl.out.tab.add.add.curate.XY.filt.zero.parsimony.tab> <mcl.out.tab.add.add.curate.XY.filt.zero.parsimony.presence.ancestor> <mcl.out.tab.add.add.curate.XY.filt.zero.parsimony.tab.pdf>' % (sys.argv[0]))

nwkFile = sys.argv[1]
tabFile = sys.argv[2]
ancFile = sys.argv[3]
outFile = sys.argv[4]

t = Tree(nwkFile, quoted_node_names=True, format=1)

dic = defaultdict(lambda: defaultdict(lambda: ''))

ancID = ''
ancContent = ''

with open(ancFile) as f:
	for line in f:
		line = line.rstrip()
		tmp = line.split('\t')
		ancID = tmp[0]
		famID = tmp[1]
		ancContent += '%s, ' % (famID)
		if ancContent.count(',') % 3 == 0:
			ancContent += '\n'
ancContent = ancContent[:-2]	

with open(tabFile) as f:
	for line in f:
		line = line.rstrip()
		tmp = line.split('\t')
		famID = tmp[0]
		branch = tmp[1]
		tag = tmp[2]
		parent = branch.split('->')[0]
		child = branch.split('->')[1]
		if(tag == 'gain'):
			dic[child]['gain'] += ' +' + famID + ','
			if dic[child]['gain'].count(',') % 3 == 0:
				dic[child]['gain'] += '\n'
		if tag == 'loss':
			dic[child]['loss'] += ' -' + famID + ','
			if dic[child]['loss'].count(',') % 3 == 0:
				dic[child]['loss'] += '\n'

'''
note = {}
for node in t.iter_descendants("postorder"):
	if node.is_root(): continue
	dic[node.name] = dic[node.name][:-1]
	print(node.name)
	print(type(node.name))
'''

nameFace = faces.AttrFace("name", fsize=20, fgcolor="#000000")
#sys.exit(dic)


def mylayout(node):
	#faces.add_face_to_node(nameFace, node, column = 0)

	if node.name == ancID:
		for i, name in enumerate(set(node.get_leaf_names())):
			col = 0
			print('##' + name)
			if i>0 and i%2 == 0:
				col += 1
		descFace = faces.TextFace(ancContent, fsize=10, fgcolor='#000000', ftype='Arial', fstyle='italic')
		faces.add_face_to_node(descFace, node, column=col)
		print('##' + ancID)
		print('##' + ancContent)
		print('##' + str(col))

	for i, name in enumerate(set(node.get_leaf_names())):
		col = 0
		if i>0 and i%2 == 0:
			col += 1
	print('node: ' + node.name)
	if 'gain' in dic[node.name]:
		dic[node.name]['gain'] = dic[node.name]['gain'][1:-1]
		print(dic[node.name]['gain'])
		descFace = faces.TextFace(dic[node.name]['gain'], fsize=10, fgcolor='#ff0000', ftype='Arial', fstyle='italic')
		#descFace.margin_top = 1
		#descFace.margin_bottom = 1
		#descFace.border.margin = 1
		#faces.add_face_to_node(descFace, node, column=0, aligned=True)
		faces.add_face_to_node(descFace, node, column=col)
	if 'loss' in dic[node.name]:
		dic[node.name]['loss'] = dic[node.name]['loss'][1:-1]
		print(dic[node.name]['loss'])
		descFace = faces.TextFace(dic[node.name]['loss'], fsize=10, fgcolor='#0000ff', ftype='Arial', fstyle='italic')
		#descFace.margin_top = 1
		#descFace.margin_bottom = 1
		#descFace.border.margin = 1
		#faces.add_face_to_node(descFace, node, column=0, aligned=True)
		faces.add_face_to_node(descFace, node, column=col)
	print('col: %i' % (col))
	print('#')

	#for i, name in enumerate(set(node.get_leaf_names())):
	#	print(i, name)
	#sys.exit()
	'''
	if node.is_leaf():
		# Add an static face that handles the node name
		faces.add_face_to_node(nameFace, node, column=0)
		# We can also create faces on the fly
		longNameFace = faces.TextFace(code2name[node.name])
		faces.add_face_to_node(longNameFace, node, column=0)

		# text faces support multiline. We add a text face
		# with the whole description of each leaf.
		descFace = faces.TextFace(code2desc[node.name], fsize=10)
		descFace.margin_top = 10
		descFace.margin_bottom = 10
		descFace.border.margin = 1

		# Note that this faces is added in "aligned" mode
		faces.add_face_to_node(descFace, node, column=0, aligned=True)

		# Sets the style of leaf nodes
		node.img_style["size"] = 12
		node.img_style["shape"] = "circle"
		#If node is an internal node
	else:
		# Sets the style of internal nodes
		node.img_style["size"] = 6
		node.img_style["shape"] = "circle"
		node.img_style["fgcolor"] = "#000000"
	'''

ts = TreeStyle()
ts.layout_fn = mylayout
t.render(outFile, w=600, tree_style = ts)

