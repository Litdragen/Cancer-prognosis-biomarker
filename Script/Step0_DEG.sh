### Usage: sh Step0_DEG.sh mirna.tsv
## DEG analysis
mkdir -p 1.DEG
colname $1 | cut -f2 | grep -v miRNA_ID | perl -wanle'next if /^$/;$a++;print "\tType" if $a==1;if (/-11A$/){print "$_\tNormal"}else{print "$_\tTumor"}' | sed 's/-/./g'> 1.DEG/Sample_info.txt
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Anti_log_mat.pl $1 > 1.DEG/Gene_exp_norm_count.txt
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Round_off_matrix.pl 1.DEG/Gene_exp_norm_count.txt > 1.DEG/Gene_exp_norm_count.round_off.txt
Rscript /disk/zxl/tools/RNA-seq-Pipe/Script/DESeq2.R 1.DEG/Gene_exp_norm_count.round_off.txt 1.DEG/Sample_info.txt 1.DEG /disk/zxl/tools/Cancer_survival_biomarker/Data/Design.txt
Merge_file 1.DEG/Tumor_vs_Normal.deseq.up_regulate.xls 1.DEG/Tumor_vs_Normal.deseq.down_regulate.xls > 1.DEG/DEG.txt
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Specific_gene_extract.pl $1 1.DEG/DEG.txt > 1.DEG/DEG_exp.mat
colname $1 | cut -f2 | grep -v "\-11" | grep -v miRNA_ID > 1.DEG/Cancer_sample.lst
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Sort_matrix_by_column.pl 1.DEG/DEG_exp.mat 1.DEG/Cancer_sample.lst > 1.DEG/DEG_exp.cancer.mat

