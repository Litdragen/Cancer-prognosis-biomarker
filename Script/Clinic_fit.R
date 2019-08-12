# Rscript Clinic_fit.R Exp.mat Clin_data Surv_data cox_model.Rdata out_pre 
args = commandArgs(T)
library("survival")
library("survminer")
library("riskRegression")

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
clindata = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[3], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
load(file = args[4])
outdir = args[5]

rownames(clindata) = gsub("-", ".", rownames(clindata))
rownames(traitData) = gsub("-", ".", rownames(traitData))
colnames(traitData) = c("time", "status")
clindata2 = clindata[colnames(expdata),]
traitData2 = traitData[colnames(expdata),]

exp_sig = t(expdata)
surv_data = na.omit(traitData2)
test_gene = cbind(surv_data, exp_sig)

# Multivariate Cox regression analysis
high_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) > 0)])
low_risk_group = names(predict(res.cox,test_gene)[which(predict(res.cox,test_gene) < 0)])
predict_mat = cbind(traitData2, clindata2)
predict_mat[high_risk_group, "Classfier"] = "High risk"
predict_mat[low_risk_group, "Classfier"] = "Low risk"
predict_mat2 = predict_mat
predict_mat$Classfier = factor(predict_mat$Classfier, levels = c("Low risk", "High risk"))
cox_form = as.formula(paste("Surv(time, status)", paste("`", paste(colnames(predict_mat)[3:ncol(predict_mat)], collapse = "` + `"), "`", sep = ""), sep = " ~ "))
res.cox.all = coxph(cox_form, data = predict_mat, x = TRUE)
pdf(paste(outdir, "/Clinical_multivariate_cox_regression_forest.pdf", sep = ""), height = 6, width = 8)
ggforest(res.cox.all, data = predict_mat)
dev.off()
multivariate_test = summary(res.cox.all)$coefficients
write.table(multivariate_test, file = paste(outdir, "/Clinical_multivariate_cox_regression.txt", sep = ""), quote = F, sep = "\t", col.names = NA)

high_risk_group = names(predict(res.cox.all,predict_mat)[which(predict(res.cox.all,predict_mat) > 0)])
low_risk_group = names(predict(res.cox.all,predict_mat)[which(predict(res.cox.all,predict_mat) < 0)])
predict_mat[high_risk_group, "Nomogram"] = "High risk"
predict_mat[low_risk_group, "Nomogram"] = "Low risk"
predict_mat$Nomogram = as.factor(predict_mat$Nomogram)

# Single variate Cox regression ROC comparation
res.cox.lst = NULL
predict_mat_for_single = predict_mat[,c(1,2,ncol(predict_mat),(ncol(predict_mat)-1),3:(ncol(predict_mat)-2))]
predict_mat_for_single = na.omit(predict_mat_for_single)
for (i in 3:(ncol(predict_mat_for_single))){
  test_mat_single = predict_mat_for_single[,c(1,2,i)]
  cox_form = as.formula(paste("Surv(time, status)", paste("`", colnames(predict_mat_for_single)[i], "`", sep = ""), sep = " ~ "))
  cox.res.test = coxph(cox_form, data = predict_mat_for_single, x = TRUE)
  if(is.null(res.cox.lst)){
    res.cox.lst = list(cox.res.test)
  }else{
    res.cox.lst = c(res.cox.lst, list(cox.res.test))
  }
}
names(res.cox.lst) = c(colnames(predict_mat_for_single)[3:ncol(predict_mat_for_single)])
xs <- Score(res.cox.lst, Hist(time,status)~1,data=predict_mat_for_single, plots="roc",metrics="auc")
pdf(paste(outdir, "/Clinical_ROC.pdf", sep = ""), height = 7, width = 7)
plotROC(xs, xlab = "False negative rate", ylab = "Ture negative rate", legend = TRUE, auc.in.legend = TRUE)
dev.off()

# Classification evaluation in each subgroup
predict_mat3 = predict_mat[,1:(ncol(predict_mat)-1)]
pdf(paste(outdir, "/Clinical_subgroup_surv_curve.pdf", sep = ""), height = 8, width = 7)
result = data.frame()
for (i in 3:(ncol(predict_mat2)-1)){
  for (j in 1:length(levels(predict_mat2[,i]))){
    Term = colnames(predict_mat2)[i]
    Type = levels(predict_mat2[,i])[j]
    test_mat = predict_mat2[predict_mat2[,i]==levels(predict_mat2[,i])[j],]
    test_mat = na.omit(test_mat)
    All = nrow(test_mat)
    All_pos = length(which(test_mat$status == 1))
    Low = length(which(test_mat$Classfier == "Low risk"))
    Low_pos = length(which(test_mat$Classfier == "Low risk" & test_mat$status == 1))
    High = length(which(test_mat$Classfier == "High risk"))
    High_pos = length(which(test_mat$Classfier == "High risk" & test_mat$status == 1))
    if (length(levels(as.factor(test_mat$Classfier))) > 1){
      fit<-survfit(Surv(time, status) ~ Classfier, data = test_mat)
      fit_md = surv_median(fit)
      print(ggsurvplot(fit, data = test_mat, pval = TRUE, 
                       xlab = "Time in days", conf.int = TRUE,
                       risk.table.y.text.col = T, risk.table.height = 0.25, 
                       risk.table.y.text = FALSE, ncensor.plot.height = 0.25,
                       legend.labs = levels(as.factor(test_mat[,"Classfier"])), 
                       title = paste(Term, Type, sep = " : ") ,conf.int.style = "step"))
    }
    
    test_mat2 = predict_mat3[predict_mat3[,i]==levels(predict_mat3[,i])[j],]
    test_mat2 = na.omit(test_mat2)
    if (length(levels(as.factor(test_mat2$Classfier))) == 1){
      test_result = data.frame("coef"="NA", "exp(coef)"="NA", "se(coef)"="NA", "z"="NA", "Pr(>|z|)"="NA", check.names = F)
    }else{
      res.cox_test = coxph(Surv(time, status) ~ Classfier, data = test_mat2, x = TRUE)
      test_result = as.data.frame(summary(res.cox_test)$coefficients)
    }
    rownames(test_result)[1] = paste(Term, Type, sep = " : ")
    test_result$`All patients` = paste(All_pos, All, sep = "/")
    test_result$`Low risk` = paste(Low_pos, Low, sep = "/")
    test_result$`High risk` = paste(High_pos, High, sep = "/")
    result = rbind(result, test_result)
  }
}
dev.off()
write.table(result, file = paste(outdir, "/Clinical_subgroup_surv_stat.txt", sep = ""), quote = F, sep = "\t", col.names = NA)




