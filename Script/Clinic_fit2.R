# Rscript Clinic_fit2.R Exp.mat Marker_exp.mat Clin_data Surv_data ourdir 
args = commandArgs(T)
library("survival")
library("survminer")
library("riskRegression")

all_expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
mark_expdata = read.csv(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
clindata = read.table(args[3], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[4], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
outdir = args[5]

expdata = all_expdata[rownames(mark_expdata),]
rownames(clindata) = gsub("-", ".", rownames(clindata))
rownames(traitData) = gsub("-", ".", rownames(traitData))
colnames(traitData) = c("time", "status")
clindata2 = clindata[colnames(expdata),]
traitData2 = traitData[colnames(expdata),]
exp_sig = t(expdata)

#Nomogram
predict_mat_all = na.omit(cbind(traitData2, clindata2, exp_sig))
cox_form = as.formula(paste("Surv(time, status)", paste("`", paste(colnames(predict_mat_all)[3:ncol(predict_mat_all)], collapse = "` + `"), "`", sep = ""), sep = " ~ "))
res.cox.all = coxph(cox_form, data = predict_mat_all, x = TRUE)
res.cox.lst = list(res.cox.all)

#Classifier
predict_mat_classifier = cbind(traitData2, exp_sig)[rownames(predict_mat_all),]
cox_form = as.formula(paste("Surv(time, status)", paste("`", paste(colnames(predict_mat_classifier)[3:ncol(predict_mat_classifier)], collapse = "` + `"), "`", sep = ""), sep = " ~ "))
res.cox.classifier = coxph(cox_form, data = predict_mat_classifier, x = TRUE)
res.cox.lst = c(res.cox.lst, list(res.cox.classifier))

# Single variate Cox regression ROC comparation
predict_mat_tmp = cbind(traitData2, clindata2)[rownames(predict_mat_all),]
predict_mat_tmp$Nomogram = predict(res.cox.all,predict_mat_all)
predict_mat_tmp$Classifier = predict(res.cox.classifier,predict_mat_classifier)
predict_mat_for_single = predict_mat_tmp[,c(1:2,ncol(predict_mat_tmp)-1,ncol(predict_mat_tmp),3:(ncol(predict_mat_tmp)-2))]
res.cox.lst = NULL
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
pdf(paste(outdir, "/Clinical_ROC_2.pdf", sep = ""), height = 7, width = 7)
plotROC(xs, xlab = "False negative rate", ylab = "Ture negative rate", legend = TRUE, auc.in.legend = TRUE)
dev.off()
