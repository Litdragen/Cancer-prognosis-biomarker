# Usage: Rscript Immune_dist.R CIBERSORT.Output.txt Immune_dist.pdf
args = commandArgs(T)
library(ggplot2)
library(reshape2)
#data = read.table("/disk/zxl/projects/Immu_lasso/TCGA_Kidney_Clear_Cell_Carcinoma_OK/1.cibersort/CIBERSORT.Output.txt", header = T, sep = "\t")
data = read.table(args[1], header = T, sep = "\t")
data[data<0] = 0
data2 = data
for(i in 1:nrow(data2)){
  for(j in 2:ncol(data2)){
    data2[i,j] = data2[i,j] / sum(data[i,2:ncol(data2)])
  }
}
data3 = melt(data2)

pdf(args[2], height = 7, width = 21)

ggplot(data=data3, aes(x=Input.Sample, y=value, fill=variable)) +
  geom_bar(stat="identity", colour = "black", size = 0.1, width = 1) +
  xlab("Sample") + ylab("Progression model possibility (%)") + 
  theme_bw() +
  theme(panel.border = element_blank(),panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"),
        axis.text.x  = element_text(angle=45, vjust = 0.9, hjust = 1),
        legend.title = element_blank()) 

dev.off()






