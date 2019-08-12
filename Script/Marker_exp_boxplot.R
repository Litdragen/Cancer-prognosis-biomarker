# Rscript Marker_exp_boxplot.R All_sample_normalized_count.deseq.mat Lasso_marker_exp.txt Sample_info.txt [outdir]
args = commandArgs(T)
library(ggpubr)
library(reshape2)
#all_exp <- read.table("/disk/zxl/projects/Lasso_marker/TCGA_Liver_Cancer/1.DEG/All_sample_normalized_count.deseq.mat", header = T, row.names = 1)
#marker_exp <- read.table("/disk/zxl/projects/Lasso_marker/TCGA_Liver_Cancer/2.OS/2.Marker_extract/Lasso_marker_exp.txt", header = T, row.names = 1)
#anno <- read.table("/disk/zxl/projects/Lasso_marker/TCGA_Liver_Cancer/1.DEG/Sample_info.txt", header = T)
all_exp <- read.table(args[1], header = T, row.names = 1)
marker_exp <- read.table(args[2], header = T, row.names = 1)
anno <- read.table(args[3], header = T)
if(is.na(args[4])){
  outdir = "."
}else{
  outdir = args[4]
}

exp = t(all_exp[rownames(marker_exp),])
exp2 = cbind(exp, anno)
exp_melt = melt(exp2)
exp_melt$value_log = log2(exp_melt$value+1)

pdf(paste(outdir, "/Marker_exp_boxplot.pdf", sep = ""), height = 7, width = 7)
ggboxplot(exp_melt, x = "variable", y = "value_log", color = "Type", palette = "jco",
          add = "jitter", xlab = F, ylab = "log2(RPM + 1)") +
  theme(axis.text.x  = element_text(angle=45, vjust = 0.9, hjust = 1)) +
  stat_compare_means(aes(group = Type), label = "p.format")
dev.off()
