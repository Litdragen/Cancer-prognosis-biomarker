# Rscript Split_discovery_validation.R Exp.mat Surv.mat out_dir
args = commandArgs(T)
#library(caret)

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
traitData = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
prop = as.numeric(args[3])

if(is.na(args[4])){
  outdir = "."
}else{
  outdir = args[4]
}


#set.seed(1024)
# 随机切分为训练集和测试集，其中66%的数据用于训练模型，剩下的34%的数据用于测试。
count = round(nrow(traitData) * prop)
train_index <- sort(sample(1:nrow(traitData),count))
test_index <- setdiff(1:nrow(traitData), train_index)
#train_index <- createDataPartition(y=traitData$time, p=0.75, list=FALSE)
#each group has the same proportion
train_exp <- expdata[,train_index]
train_surv <- traitData[train_index,]
test_exp <- expdata[,test_index]
test_surv <- traitData[test_index,]
write.table(train_exp, file = paste(outdir, "/Training_exp.mat", sep = ""), 
            quote = F, sep = "\t", col.names = NA)
write.table(train_surv, file = paste(outdir, "/Training_surv.txt", sep = ""), 
            quote = F, sep = "\t", col.names = NA)
write.table(test_exp, file = paste(outdir, "/Validation_exp.mat", sep = ""), 
            quote = F, sep = "\t", col.names = NA)
write.table(test_surv, file = paste(outdir, "/Validation_surv.txt", sep = ""), 
            quote = F, sep = "\t", col.names = NA)
