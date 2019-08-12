### Usage: sh Step1.sh Cancer_exp.mat Survival.txt
### Single-factor cox analysis
mkdir -p 2.Marker_extract
perl /disk/zxl/tools/Cancer_survival_biomarker/Script/Check_name.pl $1 $2 2.Marker_extract
Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Split_discovery_validation.R 2.Marker_extract/Exp.mat 2.Marker_extract/Surv.mat 0.7 2.Marker_extract
perl /disk/zxl/tools/RNA-seq-Pipe/Script/Filt_gene_by_exp_proportion.pl 2.Marker_extract/Training_exp.mat 0.66 > 2.Marker_extract/Training_exp.filt.mat
Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Single_factor_cox.R 2.Marker_extract/Training_exp.filt.mat 2.Marker_extract/Training_surv.txt 2.Marker_extract
### Lasso test
Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Lasso_cox.R 2.Marker_extract/Single_cox_sig_exp.mat 2.Marker_extract/Training_surv.txt 2.Marker_extract

