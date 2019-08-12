# Rscript Lasso_sigGene_extract.R Exp.mat Lasso_bootstrap_out.txt Count [out_dir]
args = commandArgs(T)

expdata = read.csv(args[1], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
lasso_fre = read.table(args[2], header=TRUE, row.names = 1, sep = "\t", fill = TRUE)
count = args[3]

if(is.na(args[4])){
  outdir = "."
}else{
  outdir = args[4]
}

markers = rownames(lasso_fre)[1:count]
expdata_marker = expdata[markers,]
write.table(expdata_marker, file = paste(outdir, "/Lasso_marker_exp.txt", sep = ""), 
            quote = F, sep = "\t", col.names = NA)