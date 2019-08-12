### Usage: sh Step2.sh marker_num
Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Lasso_sigGene_extract.R 2.Marker_extract/Single_cox_sig_exp.mat 2.Marker_extract/Lasso_bootstrap_out.txt $1 2.Marker_extract
### Multi-factor cox analysis
Rscript /disk/zxl/tools/Cancer_survival_biomarker/Script/Multi_factor_cox.R 2.Marker_extract/Lasso_marker_exp.txt 2.Marker_extract/Training_surv.txt 2.Marker_extract 2.Marker_extract/Validation_exp.mat 2.Marker_extract/Validation_surv.txt

