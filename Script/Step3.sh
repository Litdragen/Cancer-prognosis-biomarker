### Usage: sh Step3.sh Context_Scores_threshold
### Target pridiction
mkdir -p 3.Targets_analysis
#perl /disk/zxl/tools/Cancer_survival_biomarker/Script/miRNA_target.pl 2.Marker_extract/Lasso_marker_exp.txt /disk/zxl/database/miRNA_target/Summary_Counts.all_predictions.human.txt 0 header > 3.Targets_analysis/miRNA_target.pair.all.txt
#perl /disk/zxl/tools/Cancer_survival_biomarker/Script/miRNA_target.pl 2.Marker_extract/Lasso_marker_exp.txt /disk/zxl/database/miRNA_target/Summary_Counts.all_predictions.human.txt $1 header > 3.Targets_analysis/miRNA_target.pair.txt
perl /disk/zxl/tools/Cancer_survival_biomarker/Script/miRNA_target.pl 2.Marker_extract/Lasso_marker_exp.txt /disk/zxl/tools/Cancer_survival_biomarker/Data/miRNA_target.default_2.lst header > 3.Targets_analysis/miRNA_target.pair.txt
perl /disk/zxl/tools/Cancer_survival_biomarker/Script/miRNA_target.pl 2.Marker_extract/Lasso_marker_exp.txt /disk/zxl/tools/Cancer_survival_biomarker/Data/miRNA_target.default_3.lst header > 3.Targets_analysis/miRNA_target.pair.restrict.txt
### Functional enrichment
cut -f1 3.Targets_analysis/miRNA_target.pair.txt | sort | uniq > 3.Targets_analysis/target_gene.lst
mkdir -p 3.Targets_analysis/Function_enrich
Rscript /disk/zxl/tools/RNA-seq-Pipe/Script/GO_KEGG_Reactome_Hallmark_gene_set_enrich.R 3.Targets_analysis/target_gene.lst 3.Targets_analysis/Function_enrich

