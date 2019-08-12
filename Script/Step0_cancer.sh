### Usage: sh Step0_cancer.sh mirna.tsv
colname $1 | cut -f2 | grep -v "\-11" | grep -v miRNA_ID > 0.data/Cancer_sample.lst
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Sort_matrix_by_column.pl $1 0.data/Cancer_sample.lst > 0.data/Cancer_exp.mat
#perl /disk/zxl/tools/RNA-seq-Pipe/Script/Ensem2Symbol.pl /disk/database/human/hg38/Gencode/GRCh38_gencode_v24_CTAT_lib_Mar292017/EnsID2Symbol.txt 0.data/Cancer_exp.mat > 0.data/Cancer_exp.symbol.mat
#perl /disk/zxl/tools/RNA-seq-Pipe/Script/Gene_exp_stat.pl 0.data/Cancer_exp.symbol.mat | perl -wanle'@F=split /\t/;print join "\t", $F[0], @F[7..$#F] if /^\t/ or $F[1]>0' > 0.data/Cancer_exp_all_0.symbol.mat
