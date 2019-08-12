# Rscript Lasso_cox.R Exp.mat Surv.mat [out_dir]
args = commandArgs(T)
library(glmnet)
library(survival)
exp_mat = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)

if(is.na(args[3])){
  outdir = "."
}else{
  outdir = args[3]
}

expdata = as.matrix(t(exp_mat))
rownames(traitData) = gsub("-", ".", rownames(traitData))
surv_data = as.matrix(na.omit(traitData))


cvfit = cv.glmnet(expdata, surv_data, family = "cox")
pdf(paste(args[3], "/Lasso_cross_validation.pdf", sep = ""), height = 7, width = 7)
plot(cvfit)
dev.off()
coef(cvfit, s = "lambda.min")
c(cvfit$lambda.min, cvfit$lambda.1se)
pdf(paste(args[3], "/Lasso_marker_selection.pdf", sep = ""), height = 7, width = 7)
par(mar=c(4.5,4.5,4,4))
plot(cvfit$glmnet.fit,xvar ="lambda") 
abline(v=log(c(cvfit$lambda.min,cvfit$lambda.1se)),lty=2)
axis(4, at=coef(cvfit,s = 0)[1:ncol(expdata)],line=-.5,label=colnames(expdata),las=1,tick=FALSE, cex.axis=0.5)
dev.off()
markers = names(which(coef(cvfit, s = "lambda.min")[,1]!=0))
marker_exp = exp_mat[markers,]
write.table(marker_exp, file = paste(args[3], "/Lasso_marker_exp.txt", sep = ""), quote = F, sep = "\t", col.names = NA)

n_markers = length(markers)
warning(paste("-------", n_markers, " markers are detected!-------", sep = ""))
#predict(cvfit, newx = expdata, type='link')
#predict(cvfit, newx = expdata, type='response')
#predict(cvfit, newx = expdata, type="class")
