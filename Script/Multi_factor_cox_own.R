# Rscript Multi_factor_cox.R Exp.mat Surv_data [outdir] [Exp_validation_data Surv_validation_data]
args = commandArgs(T)
library("survival")
library("survminer")
library("riskRegression")

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)

if(is.na(args[3])){
  outdir = "."
}else{
  outdir = args[3]
}

exp_sig = t(expdata)
surv_data = na.omit(traitData)
test_gene = cbind(surv_data, exp_sig)

# Modeling
cox_form = as.formula(paste("Surv(time, status)", paste("`", paste(colnames(test_gene)[3:ncol(test_gene)], collapse = "` + `"), "`", sep = ""), sep = " ~ "))
res.cox = coxph(cox_form, data = test_gene, x = TRUE)
save(res.cox, file = paste(outdir,"/Multi_factor_cox.RData",sep=""))
#predict(res.cox,test_gene)
pdf(paste(outdir, "/Multi_factor_cox_marker_forest.pdf", sep = ""), height = 8, width = 7)
ggforest(res.cox, data = test_gene)
dev.off()
res.cox.sum = summary(res.cox)
write.table(res.cox.sum$coefficients, file = paste(outdir, "/Multi_factor_cox_model.txt", sep = ""), quote = F, sep = "\t", col.names = NA)
#res.cox.test = data.frame(row.names = c("Likelihood ratio test", "Wald test", "Score (logrank) test"))
res.cox.test = t(data.frame("Logrank test" = res.cox.sum$sctest, "Wald test" = res.cox.sum$waldtest, "Likelihood ratio test" = res.cox.sum$logtest))
write.table(res.cox.test, file = paste(outdir, "/Multi_factor_cox_model.test.txt", sep = ""), quote = F, sep = "\t", col.names = NA)

# Fitting --- Discovery group
#predict(res.cox,test_gene)
high_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) > 0)])
low_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) < 0)])
predict_mat = surv_data
predict_mat$risk = "NA"
predict_mat[high_risk_group, "risk"] = "High risk"
predict_mat[low_risk_group, "risk"] = "Low risk"
fit<-survfit(Surv(predict_mat[,1], predict_mat[,2]) ~ predict_mat[,3])
fit_md = surv_median(fit)
write.table(fit_md, file = paste(outdir, "/Multi_factor_cox_surv_median_training.txt", sep = ""), quote = F, sep = "\t", col.names = NA)
print(paste("Training data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat))$sctest[3]))
cat(paste("Training data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat))$sctest[3], "\n"), 
    file = paste(outdir, "/Muti_factor_report.txt", sep = ""))
pdf(paste(outdir, "/Multi_factor_cox_surv_curve_training.pdf", sep = ""), height = 10, width = 7)
ggsurv <- ggsurvplot(fit, data = predict_mat,  risk.table = TRUE, pval = TRUE,conf.int = TRUE,
                     palette = c("#E7B800", "#2E9FDF"),xlab = "Time in months",ggtheme = theme_light(),
                     risk.table.y.text.col = T,risk.table.height = 0.25,risk.table.y.text = FALSE,
                     ncensor.plot = TRUE,ncensor.plot.height = 0.25,legend.labs = levels(as.factor(predict_mat[,3])))
# Labels for Risk Table 
ggsurv$table <- ggsurv$table + labs(
  title    = "Note the risk set sizes",          
  subtitle = "and remember about censoring."
)
# Labels for ncensor plot 
ggsurv$ncensor.plot <- ggsurv$ncensor.plot + labs( 
  title    = "Number of censorings", 
  subtitle = "over the time."
)
print(ggsurv)
dev.off()
xs <- Score(list(model=res.cox),Hist(time,status)~1,data=test_gene,
            plots="roc",metrics="auc")
print(paste("Training data AUC:", xs$AUC$score$AUC))
cat(paste("Training data AUC:", xs$AUC$score$AUC, "\n"), 
    file = paste(outdir, "/Muti_factor_report.txt", sep = ""), append = T)
pdf(paste(outdir, "/Multi_factor_cox_ROC_training.pdf", sep = ""), height = 7, width = 7)
plotROC(xs, xlab = "False negative rate", ylab = "Ture negative rate", legend = TRUE, auc.in.legend = TRUE)
dev.off()
# Fitting --- Validation group
if(!is.na(args[4])){
  expdata2 = read.csv(args[4], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
  traitData2 = read.table(args[5], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
  
  exp_sig2 = t(expdata2[rownames(expdata),])
  surv_data2 = na.omit(traitData2)
  test_gene2 = cbind(surv_data2, exp_sig2)
  #  predict(res.cox,test_gene2)
  high_risk_group = names(predict(res.cox,test_gene2)[which(predict(res.cox,test_gene2) > 0)])
  low_risk_group = names(predict(res.cox,test_gene2)[which(predict(res.cox,test_gene2) < 0)])
  predict_mat2 = surv_data2
  predict_mat2$risk = "NA"
  predict_mat2[high_risk_group, "risk"] = "High risk"
  predict_mat2[low_risk_group, "risk"] = "Low risk"
  fit<-survfit(Surv(predict_mat2[,1], predict_mat2[,2]) ~ predict_mat2[,3])
  fit_md = surv_median(fit)
  write.table(fit_md, file = paste(outdir, "/Multi_factor_cox_surv_median_validation.txt", sep = ""), quote = F, sep = "\t", col.names = NA)
  print(paste("Validation data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat2))$sctest[3]))
  cat(paste("Validation data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat2))$sctest[3], "\n"), 
      file = paste(outdir, "/Muti_factor_report.txt", sep = ""), append = T)
  pdf(paste(outdir, "/Multi_factor_cox_surv_curve_validation.pdf", sep = ""), height = 10, width = 7)
  ggsurv <- ggsurvplot(fit, data = predict_mat2,  risk.table = TRUE, pval = TRUE,conf.int = TRUE,
                       palette = c("#E7B800", "#2E9FDF"),xlab = "Time in months",ggtheme = theme_light(),
                       risk.table.y.text.col = T,risk.table.height = 0.25,risk.table.y.text = FALSE,
                       ncensor.plot = TRUE,ncensor.plot.height = 0.25,legend.labs = levels(as.factor(predict_mat2[,3])))
  # Labels for Risk Table 
  ggsurv$table <- ggsurv$table + labs(
    title    = "Note the risk set sizes",          
    subtitle = "and remember about censoring."
  )
  # Labels for ncensor plot 
  ggsurv$ncensor.plot <- ggsurv$ncensor.plot + labs( 
    title    = "Number of censorings", 
    subtitle = "over the time."
  )
  print(ggsurv)
  dev.off()
  xs <- Score(list(model=res.cox),Hist(time,status)~1,data=test_gene2,
              plots="roc",metrics="auc")
  print(paste("Validation data AUC:", xs$AUC$score$AUC))
  cat(paste("Validation data AUC:", xs$AUC$score$AUC, "\n"), 
      file = paste(outdir, "/Muti_factor_report.txt", sep = ""), append = T)
  pdf(paste(outdir, "/Multi_factor_cox_ROC_validation.pdf", sep = ""), height = 7, width = 7)
  plotROC(xs, xlab = "False negative rate", ylab = "Ture negative rate", legend = TRUE, auc.in.legend = TRUE)
  dev.off()
}

