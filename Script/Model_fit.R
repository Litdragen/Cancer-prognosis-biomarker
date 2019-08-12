# Rscript Model_fit.R Exp.mat Surv_data cox_model.Rdata out_pre 
args = commandArgs(T)
library("survival")
library("survminer")
library("riskRegression")

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)

exp_sig = t(expdata)
surv_data = na.omit(traitData)
test_gene = cbind(surv_data, exp_sig)
load(file =args[3])

high_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) > 0)])
low_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) < 0)])
predict_mat = surv_data
predict_mat$risk = "NA"
predict_mat[high_risk_group, "risk"] = "High risk"
predict_mat[low_risk_group, "risk"] = "Low risk"
fit<-survfit(Surv(predict_mat[,1], predict_mat[,2]) ~ predict_mat[,3])
fit_md = surv_median(fit)
write.table(fit_md, file = paste(args[4], "_surv_median.txt", sep = ""), quote = F, sep = "\t", col.names = NA)
print(paste("Test data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat))$sctest[3]))
cat(paste("Test data survival curve P-value:", summary(coxph(Surv(time, status)~risk, data = predict_mat))$sctest[3], "\n"), 
    file = paste(args[4], "_Muti_factor_report.txt", sep = ""))
pdf(paste(args[4], "_surv_curve.pdf", sep = ""), height = 7, width = 7)
ggsurvplot(fit, data = predict_mat, pval = TRUE, 
           xlab = "Time in months", conf.int = TRUE,
           risk.table.y.text.col = T, risk.table.height = 0.25, 
           risk.table.y.text = FALSE, ncensor.plot.height = 0.25,
           legend.labs = levels(as.factor(predict_mat[,3])), 
           title = NULL ,conf.int.style = "step")
dev.off()
xs <- Score(list(model=res.cox),Hist(time,status)~1,data=test_gene,
            plots="roc",metrics="auc")
print(paste("Test data AUC:", xs$AUC$score$AUC))
cat(paste("Test data AUC:", xs$AUC$score$AUC, "\n"), 
    file = paste(args[4], "_Muti_factor_report.txt", sep = ""), append = T)
pdf(paste(args[4], "_ROC.pdf", sep = ""), height = 7, width = 7)
plotROC(xs, xlab = "False negative rate", ylab = "Ture negative rate", legend = TRUE, auc.in.legend = TRUE)
dev.off()