message = "#=========================================================================================
#        USAGE: Rscript Limma_microarray.R <Exp_count.mat> <Sample_info.txt> <oudir> [Design.txt]
#
#  DESCRIPTION: Analysis differential expression genes among different groups
#               PS: Normalization first, then paired-wised DEG analysis
#
#       INPUTS: <Exp_count.mat> : Reads count matrix (integral)
#               <Sample_info.txt> : Sample annotation file (Header: \"\tType\")
#               <outdir> : Output derectory.
#               <Design.txt> : Compairision design (eg: A_vs_B\nA_vs_C) [Optional]
#
# REQUIREMENTS: [R Packages] : limma ggplot2
#       AUTHOR: Xiaolong Zhang, zhangxiaol1@sysucc.org.cn
# ORGANIZATION: Bioinformatics Center, Sun Yat-sen University Cancer Center
#      VERSION: 1.0
#      CREATED: 08/16/2017
#     REVISION: ---
#================================================================================================"

#if (length(args)<2){
#  stop(message)
#}

args = commandArgs(T)
library("limma")
library("ggplot2")
library("pheatmap")
#args[1]="/disk/zxl/projects/zzl_wyn_rora_seq/6.Further_analysis/3.DEG/RORA/DESeq/Exp_count.round_off.mean_1.mat"
#args[2]="/disk/zxl/projects/zzl_wyn_rora_seq/6.Further_analysis/3.DEG/RORA/Sample_info"
#args[1]="/disk/zxl/projects/BLCA_stem/6.Further_analysis/3.DEG/Merged_sample/Exp_count.merged.round_off.mat"
#args[2]="/disk/zxl/projects/BLCA_stem/tmp/Sample_info.merge.txt"
countData <- read.table(args[1], header = T, row.names = 1, sep = "\t")
colData <- read.table(args[2], header = T, row.names = 1, sep = "\t")
outdir <- args[3]

fc = 2
lfc = log2(fc)
pval = 0.05

vocano_plot = function(Sample_1 = "A", Sample_2 = "B", lfc = 0, pval = 0.05){
  par(mar = c(5, 6, 5, 5))
  tab = data.frame(logFC = res$logFC, negLogPval = -log10(res$adj.P.Val)) 
  #  res$baseMean[res$baseMean>5000]=5000
  #  res$baseMean[res$baseMean<10]=10
  nosigGene = (abs(tab$logFC) < lfc | tab$negLogPval < -log10(pval))
  signGenes_up = (tab$logFC > lfc & tab$negLogPval > -log10(pval))
  signGenes_down = (tab$logFC < -lfc & tab$negLogPval > -log10(pval))
  up_count = length(which(signGenes_up))
  down_count = length(which(signGenes_down))
  gap = max(sort(tab[signGenes_up, ]$negLogPval, decreasing = T)[1], sort(tab[signGenes_down, ]$negLogPval, decreasing = T)[1])/50
  plot(tab, pch = 21, xlab = expression(log[2]~fold~change), ylab = expression(-log[10]~pvalue), cex.lab = 1.5, col = alpha("black", 0))
  points(tab[nosigGene, ], pch = 21, xlab = expression(log[2]~fold~change), ylab = expression(-log[10]~pvalue), col = "black", bg = "grey")
  if (length(unique(signGenes_up)) > 1){
    points(tab[signGenes_up, ], pch = 21, col = "black", bg = "red") 
  }
  if (length(unique(signGenes_down)) > 1){
    points(tab[signGenes_down, ], pch = 21, col = "black", bg = "cornflowerblue") 
  }
  abline(h = -log10(pval), col = "green3", lty = 2) 
  abline(v = c(-lfc, lfc), col = "orange", lty = 2) 
  if (length(unique(signGenes_up)) > 1){
    text(tab[signGenes_up, ]$logFC, tab[signGenes_up, ]$negLogPval+gap, row.names(res[signGenes_up,]), cex = 0.5, col = "red")
  }
  if (length(unique(signGenes_down)) > 1){
    text(tab[signGenes_down, ]$logFC, tab[signGenes_down, ]$negLogPval+gap, row.names(res[signGenes_down,]), cex = 0.5, col = "blue")
  }
  mtext(paste("padj =", pval), side = 4, at = -log10(pval), cex = 0.8, line = 0.5, las = 1) 
  mtext(c(paste("-", fc, "fold"), paste("+", fc, "fold")), side = 3, at = c(-lfc, lfc), cex = 0.8, line = 0.5)
  mtext(c(Sample_1, Sample_2), side = 3, at = c(3*lfc, -3*lfc), cex = 1, line=2)
  mtext(c(paste(up_count,"genes",sep = " "), paste(down_count,"genes",sep = " ")), side = 3, at = c(3*lfc, -3*lfc), cex = 1, line=0.5)
  legend("top",legend = c("Upregulate","Downregulate"),pch = c(16, 16), col = c("red", "cornflowerblue"))
}

if (is.na(args[4])){
  # List all possible pared comparision
  type_level <- levels(as.factor(colData$Type))
  comb <- combn(type_level,2)
  #i = 1
  for (i in 1:length(comb[1,])){
    # Extract specific info for comparision
    colData1 <- subset(colData, Type == comb[1,i] | Type == comb[2,i])
    countData1 <- countData[,row.names(colData1)]
    # Limma
#    keep <- rowSums(countData1 > log2(200)) >= 3
#    countData1 <- countData1[keep,]
    design <- model.matrix(~0+factor(colData1$Type))
    colnames(design)=levels(factor(colData1$Type))
    rownames(design)=colnames(countData1)
    fit <- lmFit(countData1,design)
    cont.matrix<-makeContrasts(paste0(unique(colData1$Type),collapse = "-"),levels = design)
    fit2=contrasts.fit(fit,cont.matrix)
    fit2 <- eBayes(fit2)
    tempOutput = topTable(fit2,coef=1,n=Inf,adjust="BH")
    res <- as.data.frame(tempOutput)
    if (levels(factor(colData1$Type))[1] == comb[1,i]){
      res$logFC = -res$logFC
    }
    write.table(res, file = paste(outdir,"/", comb[2,i], "_vs_", comb[1,i], ".deseq.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_up <- subset(res, logFC > lfc & adj.P.Val < pval)
    write.table(res_up, file = paste(outdir,"/", comb[2,i], "_vs_", comb[1,i], ".deseq.up_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_down <- subset(res, logFC < -lfc & adj.P.Val < pval)
    write.table(res_down, file = paste(outdir,"/", comb[2,i], "_vs_", comb[1,i], ".deseq.down_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    # Plot
    pdf(file = paste(outdir,"/", comb[2,i], "_vs_", comb[1,i], ".deseq.Plot.pdf", sep=""))
    vocano_plot(Sample_1 = comb[2,i], Sample_2 = comb[1,i], lfc = lfc, pval = pval)
    deg <- subset(res, abs(logFC) > lfc & adj.P.Val < pval)
    if (nrow(deg) > 2){
      #      colData1 <- subset(colData, Type == comb[1,i] | Type == comb[2,i])
      countData1 <- countData1[row.names(deg), ]
      select <- order(rowMeans(countData1), decreasing = TRUE)
      #      countData1 = log2(countData1+1)
      pheatmap(countData1[select,order(colData1$Type)], cluster_rows=FALSE, show_rownames=T, cluster_cols=FALSE, annotation_col=colData1, scale = "row")
      pheatmap(countData1[select,], cluster_rows=TRUE, show_rownames=T, cluster_cols=TRUE, annotation_col=colData1, scale = "row")
      pcaData <- as.data.frame(prcomp(countData1[select,])$rotation)
      pca_plot <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_point(size=3) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot)
      pca_plot_text <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_text(aes(label = row.names(pcaData))) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot_text)
    }
    dev.off()
    # Reverse diff exp analysis of pair-wised comparision
    res$logFC = -res$logFC
    write.table(res, file = paste(outdir,"/", comb[1,i], "_vs_", comb[2,i], ".deseq.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_up <- subset(res, logFC > lfc & adj.P.Val < pval)
    write.table(res_up, file = paste(outdir,"/", comb[1,i], "_vs_", comb[2,i], ".deseq.up_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_down <- subset(res, logFC < -lfc & adj.P.Val < pval)
    write.table(res_down, file = paste(outdir,"/", comb[1,i], "_vs_", comb[2,i], ".deseq.down_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    # Plot
    pdf(file = paste(outdir,"/", comb[1,i], "_vs_", comb[2,i], ".deseq.Plot.pdf", sep=""))
    vocano_plot(Sample_1 = comb[1,i], Sample_2 = comb[2,i], lfc = lfc, pval = pval)
    deg <- subset(res, abs(logFC) > lfc & adj.P.Val < pval)
    if (nrow(deg) > 2){
      select <- order(rowMeans(countData1), decreasing = TRUE)
      pheatmap(countData1[select,order(colData1$Type)], cluster_rows=FALSE, show_rownames=T, cluster_cols=FALSE, annotation_col=colData1, scale = "row")
      pheatmap(countData1[select,], cluster_rows=TRUE, show_rownames=T, cluster_cols=TRUE, annotation_col=colData1, scale = "row")
      pcaData <- as.data.frame(prcomp(countData1[select,])$rotation)
      pca_plot <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_point(size=3) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot)
      pca_plot_text <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_text(aes(label = row.names(pcaData))) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot_text)
    }
    dev.off()
  }
}else{
  des = read.table(args[4], header = F)
  for(i in 1:nrow(des)){
    comb = strsplit(as.character(des[i, 1]), "_vs_")[[1]]
    colData1 <- subset(colData, Type == comb[1] | Type == comb[2])
    countData1 <- countData[,row.names(colData1)]
    # Limma
#    keep <- rowSums(countData1 > log2(200)) >= 3
#    countData1 <- countData1[keep,]
    design <- model.matrix(~0+factor(colData1$Type))
    colnames(design)=levels(factor(colData1$Type))
    rownames(design)=colnames(countData1)
    fit <- lmFit(countData1,design)
    cont.matrix<-makeContrasts(paste0(unique(colData1$Type),collapse = "-"),levels = design)
    fit2=contrasts.fit(fit,cont.matrix)
    fit2 <- eBayes(fit2)
    tempOutput = topTable(fit2,coef=1,n=Inf,adjust="BH")
    res <- as.data.frame(tempOutput)
    if (levels(factor(colData1$Type))[1] == comb[2]){
      res$logFC = -res$logFC
    }
    write.table(res, file = paste(outdir,"/", comb[1], "_vs_", comb[2], ".deseq.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_up <- subset(res, logFC > lfc & adj.P.Val < pval)
    write.table(res_up, file = paste(outdir,"/", comb[1], "_vs_", comb[2], ".deseq.up_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    res_down <- subset(res, logFC < -lfc & adj.P.Val < pval)
    write.table(res_down, file = paste(outdir,"/", comb[1], "_vs_", comb[2], ".deseq.down_regulate.xls",sep = ""),
                sep = "\t", quote = FALSE, row.names = T, col.names = NA)
    # Plot
    pdf(file = paste(outdir,"/", comb[1], "_vs_", comb[2], ".deseq.Plot.pdf", sep=""))
    vocano_plot(Sample_1 = comb[1], Sample_2 = comb[2], lfc = lfc, pval = pval)
    deg <- subset(res, abs(logFC) > lfc & adj.P.Val < pval)
    if (nrow(deg) > 2){
      countData1 <- countData1[row.names(deg), ]
      countData1 = countData1[rowMeans(countData1)!=0,]
      select <- order(rowMeans(countData1), decreasing = TRUE)
      countData1 = log2(countData1+1)
      pheatmap(countData1[select,order(colData1$Type)], cluster_rows=FALSE, show_rownames=T, cluster_cols=FALSE, annotation_col=colData1, scale = "row")
      pheatmap(countData1[select,], cluster_rows=TRUE, show_rownames=T, cluster_cols=TRUE, annotation_col=colData1, scale = "row")
      pcaData <- as.data.frame(prcomp(countData1[select,])$rotation)
      pca_plot <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_point(size=3) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot)
      pca_plot_text <- ggplot(pcaData, aes(PC1, PC2, color=colData1$Type)) +
        geom_text(aes(label = row.names(pcaData))) +
        xlab("PC1") +
        ylab("PC2") +
        scale_colour_hue("Type") +
        #  coord_fixed() +
        theme_bw()
      print(pca_plot_text)
    }
    dev.off()
  }
}

