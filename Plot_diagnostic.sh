#!/bin/sh

# plot diagnotics and isoform profiles in transcript coordinates for selected genes
# generate a wiggle file for plot on genomic coordinates (to be used with IGV)
mkdir -p plots
for f in *.fastq.gz; do
        h=$(basename $f .fastq.gz) 
#        submitjob -m 20 rsem-plot-model $h/rsem_out/$h plots/${h}_diagnostic.pdf
	submitjob -m 20 rsem-plot-transcript-wiggles --gene-list --show-unique \
					$h/rsem_out/$h gene_ids.txt plots/${h}_transcript_wiggle.pdf
#	submitjob -m 20 rsem-bam2wig $h/rsem_out/$h.genome.bam $h/rsem_out/$h.wig $h/rsem_out/$h
done


