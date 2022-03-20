args = commandArgs(T)

library("pheatmap")

data <- read.table(args[1],header=F, comment.char = '')
pdf(args[2], w=10, h=5)

rownames(data) = data[,1]
colnames(data) = data[1,]
data = data[,-1]
data = data[-1,]

geneName = rownames(data)

data = as.data.frame(sapply(data, as.numeric))
#flag = apply(data, 1, function(x){sum(x!=0, na.rm=T)>0})
#data = data[flag,]
rownames(data) = geneName

data_label <- data
data_label[data_label<0] <- "X"
data_label[data_label!='X'] <- ''
data_label[is.na(data_label)] = ''

data1 = data
data1[data1>0] = 1
data1[data1==0] = 0
data1[data1<0] = -1

#pdf(args[2], w=10, h=5)
pheatmap(t(data1),cluster_cols=F,cluster_rows=F,fontsize=6,
	display_numbers=t(data_label),
	cellwidth=5,cellheight=5,
	color=colorRampPalette(c("#deebf7", "white", "#3182bd"))(3),border_color="white")

