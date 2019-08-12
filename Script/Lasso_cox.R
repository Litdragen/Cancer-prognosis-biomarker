# Rscript Lasso_cox.R Exp.mat Surv.mat [out_dir]
args = commandArgs(T)
library(ggplot2)
source("/disk/zxl/tools/lassoBag/R/lassoBagAddGPD.R")
expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)

if(is.na(args[3])){
  outdir = "."
}else{
  outdir = args[3]
}

expdata = t(expdata)
surv_data = na.omit(traitData)
m<-Lasso.bag(expdata,surv_data,bootN=1000,permutation = F,boot.rep = T,a.family = "cox",n.cores = 20,plot.freq = F)
pdf(paste(outdir, "/Lasso_gene_dist.pdf", sep = ""), height = 5, width = 7)
ggplot(m, aes(reorder(variate, -Frequency), Frequency)) + 
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(axis.text.x  = element_text(angle=45, vjust = 0.9, hjust = 1)) +
  xlab(label = NULL)
dev.off()
m.sort = m[order(m$Frequency, decreasing = T),]
m.sort
write.table(m.sort, file = paste(outdir, "/Lasso_bootstrap_out.txt", sep = ""), 
            quote = F, sep = "\t", col.names = NA)