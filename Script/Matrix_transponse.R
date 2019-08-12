#USAGE: Rscript Matrix_transponse.R input.mat output.mat P-value_thre
args = commandArgs(T)
mat <- read.table(args[1], header = T, row.names = 1, sep = "\t")
mat2 = mat[mat$P.value<args[3],]
mat_t = t(mat2)
write.table(mat_t, file = args[2], 
            sep = "\t", quote = FALSE, row.names = T, col.names = NA)
