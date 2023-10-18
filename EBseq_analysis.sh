#!/bin/sh

exps=$(ls *.fastq.gz)
prefix=$(echo ${exps//.fastq.gz})

cout_files=()
iso_files=()

for p in $prefix; do
	cout_files+=("$p/rsem_out/$p.genes.results")
	iso_files+=("$p/rsem_out/$p.isoforms.results")
done

echo ${cout_files[@]}

if [ 1 -eq 0 ]; then
## differential analysis at gene level
rsem-generate-data-matrix ${cout_files[@]} > GeneMat.txt
rsem-run-ebseq GeneMat.txt 2,2,2,2 GeneMat.results
rsem-control-fdr GeneMat.results 0.05 GeneMat.de.txt

## differential analysis at isoform level
rsem-generate-ngvector $HOME/GRCH38_gencode/RSEM_ref.transcripts.fa RSEM_ref
rsem-generate-data-matrix ${iso_files[@]} > IsoMat.txt
rsem-run-ebseq --ngvector $HOME/GRCH38_gencode/RSEM_ref.ngvec IsoMat.txt 2,2,2,2 IsoMat.results
rsem-control-fdr IsoMat.results 0.05 IsoMat.de.txt

for f in *.fastq.gz; do
        h=$(basename $f, .fastq.gz)
        rsem-plot-model $h/rsem_out/$h $h/rsem_out/$h_diagnostic.pdf
done

fi

# test N and GFP separately
cut -f1-5 GeneMat.txt > N_Ar_noAr_GeneMat.txt
cut -f1,6-9 GeneMat.txt > GFP_Ar_noAr_GeneMat.txt
cut -f1-3,6,7 GeneMat.txt > N_GFP_Ar_GeneMat.txt
cut -f1,4,5,8,9 GeneMat.txt > N_GFP_noAr_GeneMat.txt

rsem-run-ebseq N_Ar_noAr_GeneMat.txt 2,2 N_Ar_noAr_GeneMat.results
rsem-control-fdr N_Ar_noAr_GeneMat.results 0.05 N_Ar_noAr_GeneMat.de.txt

rsem-run-ebseq GFP_Ar_noAr_GeneMat.txt 2,2 GFP_Ar_noAr_GeneMat.results
rsem-control-fdr GFP_Ar_noAr_GeneMat.results 0.05 GFP_Ar_noAr_GeneMat.de.txt

rsem-run-ebseq N_GFP_Ar_GeneMat.txt 2,2 N_GFP_Ar_GeneMat.results
rsem-control-fdr N_GFP_Ar_GeneMat.results 0.05 N_GFP_Ar_GeneMat.de.txt

rsem-run-ebseq N_GFP_noAr_GeneMat.txt 2,2 N_GFP_noAr_GeneMat.results
rsem-control-fdr N_GFP_noAr_GeneMat.results 0.05 N_GFP_noAr_GeneMat.de.txt
