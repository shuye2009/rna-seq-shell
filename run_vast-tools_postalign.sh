#!/bin/bash

tf=$1
ctl=$2 # control sample name, like siNT or WT
#wd=$HOME/Nabeel/RNAseq/Jul06_2021/GREENBLATT_16RNA
wd=$HOME/Nabeel/RNAseq/Nov28_2022/GREENBLATT
outd=$wd/vast_results/$tf
Rcmd=$HOME/RNAseq_scripts/VAST-TOOLS_postprocessing.R

if [ 1 -eq 0 ]; then
echo "merge"
vast-tools merge --sp hg19 -o $outd -g  ${outd}/${tf}_grouping.txt
mkdir -p $outd/to_combine/to_merge
mv $outd/to_combine/*_L001.* $outd/to_combine/to_merge
mv $outd/to_combine/*_L002.* $outd/to_combine/to_merge
## before calling combine, make a new directory 'to_merge' in to_combine, move all files before merge to 'to_merge',
## so that these file will not be used in combine, only  the results of merge are used instead.
fi

if [ 1 -eq 0 ]; then
echo "combine"
vast-tools combine -sp hg19 --cores 4 -o $outd --add_version
fi

if [ 1 -eq 0 ]; then
echo "cleaning"
Rscript $Rcmd $outd clean
fi

if [ 1 -eq 0 ]; then
echo "diff"
vast-tools diff -i "CLEANED_" -a ${tf}_S1,${tf}_S2 -b ${ctl}_S1,${ctl}_S2 --sampleNameA=${tf} --sampleNameB=${ctl} -d DIFF_${tf}_vs_${ctl} --cores 4 -o $outd
fi

if [ 1 -eq 1 ]; then
echo "GO enrichment analysis"
Rscript $Rcmd $outd GOyes
fi

## matt commands, did not work out at cmpr_exon
if [ 1 -eq 0 ]; then
gtf=$HOME/genomic_feature/Ensembl.GRCh37.87.gtf
fasta=$HOME/genomic_feature/GRCh37.p13.genome.fa

cp $outd/Exon_inclusion_regulated_events.tab $outd/Exon_inclusion_regulated_events_cp.tab

matt rm_cols $outd/Exon_inclusion_regulated_events_cp.tab $tf ${ctl}  E.dPsi. MV.dPsi._at_0.95 GROUP > $outd/Exon_inclusion_regulated_events_rm_cols.tab
matt get_vast $outd/Exon_inclusion_regulated_events_cp.tab -a ${tf}_S1,${tf}_S2 -b ${ctl}_S1,${ctl}_S2 -gtf $gtf -f gene_id > $outd/matt_out_exon.tab 
matt add_cols $outd/matt_out_exon.tab $outd/Exon_inclusion_regulated_events_rm_cols.tab
matt get_rows $outd/matt_out_exon.tab '!GENE][' '!GENEID]NA[' > $outd/matt_out_exon_GENEID_noNA.tab
#not necessay awk 'OFS="\t" {$47="\x22" $47 "\x22"; print}' $outd/matt_out_exon_GENEID_noNA.tab > $outd/matt_out_exon_GENEIDq.tab
awk 'OFS="\t" {gsub("Exon_inclusion_", ""); print}' $outd/matt_out_exon_GENEID_noNA.tab > $outd/matt_out_exon_GENEIDq.tab
matt cmpr_exons $outd/matt_out_exon_GENEIDq.tab START END SCAFFOLD STRAND GENEID $gtf $fasta Hsap 150 GROUP $outd/cmpr_exons_output -f gene_id -colors:darkblue,darkred,cyan
fi
