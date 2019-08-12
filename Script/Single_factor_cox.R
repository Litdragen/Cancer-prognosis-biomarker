# Rscript Single_factor_cox.R Exp.mat Surv_data [outdir]
args = commandArgs(T)
library("survival")
library("survminer")
library("matrixStats")

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)

if(is.na(args[3])){
  outdir = "."
}else{
  outdir = args[3]
}

exp = t(expdata[which(rowMedians(as.matrix(expdata))>0),])
surv_data = na.omit(traitData)

# Single factor cox test for each gene
sig_col = c()
direction = c()
pvalue = c()
for(i in 1:ncol(exp)){
  test_gene = surv_data
  test_gene$gene = exp[,i]
  test_gene[,3][which(exp[,i] <= summary(exp[,i])[[3]])] = "Low expression"
  test_gene[,3][which(exp[,i] >= summary(exp[,i])[[3]])] = "High expression"
  res.cox = coxph(Surv(test_gene[,1], test_gene[,2])~test_gene[,3], data = test_gene)
  pval = summary(res.cox)$sctest[3]
  if (res.cox$coefficients > 0){
    relation = "Possitive"
  }else{
    relation = "Negtive"
  }
  if(pval < 0.05){
    sig_col = c(sig_col, i)
    direction = c(direction, relation)
    pvalue = c(pvalue, pval)
  }
}
exp_sig = exp[,sig_col]
write.table(t(exp_sig), file = paste(outdir, "/Single_cox_sig_exp.mat", sep = ""), quote = F, sep = "\t", col.names = NA)
exp_outcome = data.frame("Gene" = colnames(exp)[sig_col], "Corelation" = direction, "P value" = pvalue)
write.table(exp_outcome, file = paste(outdir, "/Single_cox_sig_outcome_corelation.mat", sep = ""), quote = F, sep = "\t", row.names = F)


# Survival curves
if (!is.null(colnames(exp_sig))) {
  ggsurv = list()
  for(i in 1:ncol(exp_sig)){
    test_gene = surv_data
    test_gene$gene = exp_sig[,i]
    test_gene[,3][which(exp_sig[,i] <= summary(exp_sig[,i])[[3]])] = "Low expression"
    test_gene[,3][which(exp_sig[,i] >= summary(exp_sig[,i])[[3]])] = "High expression"
    fit<-survfit(Surv(test_gene[,1],test_gene[,2])~test_gene[,3],data=test_gene)
    ggsurv[[i]] <- ggsurvplot(fit, pval = TRUE, linetype = "strata", xlab = "Time in months", 
                              risk.table.y.text.col = T, risk.table.height = 0.25, 
                              risk.table.y.text = FALSE, ncensor.plot.height = 0.25,
                              legend.labs = levels(as.factor(test_gene[,3])), 
                              title = colnames(exp_sig)[i])
  }
  
  pdf(paste(outdir, "/Single_cox_curve.pdf", sep = ""), height = 8, width = 12)
  arrange_ggsurvplots(ggsurv, nrow = 2, ncol = 4)
  dev.off()
  print(paste("-------", ncol(exp_sig), " significant factors detected!-------", sep = ""))
  warning(paste("-------", ncol(exp_sig), " significant factors detected!-------", sep = ""))
}else{
  print("-------No significant factor detected!-------")
  warning("-------No significant factor detected!-------")
}

