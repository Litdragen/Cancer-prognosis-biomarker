# Rscript Model_group_sepration.R Exp.mat Surv_data cox_model.Rdata out_pre 
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
predict_mat[high_risk_group, "risk"] = "High_risk"
predict_mat[low_risk_group, "risk"] = "Low_risk"

sample_info = data.frame(Type = predict_mat$risk, row.names = rownames(predict_mat))

write.table(sample_info, file = args[4], quote = F, sep = "\t", col.names = NA)