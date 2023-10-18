#!/bin/sh

## align single end or paired end RNAseq data with STAR alignment tool

infiles=$1
prefix=$2
wd=$3
index=$4 # $HOME/GRCH38_gencode/STARindex
gtf=$5 # $HOME/GRCH38_gencode/gencode.v35.primary_assembly.annotation.gtf
cd $wd
mkdir -p $prefix
STAR	--runThreadN 10 \
	--runMode alignReads \
	--genomeDir $index \
	--sjdbGTFfile $gtf \
	--sjdbOverhang 100 \
	--sjdbGTFfeatureExon exon \
	--sjdbGTFtagExonParentTranscript transcript_id \
	--sjdbGTFtagExonParentGene gene_id \
	--readFilesIn $infiles \
	--readFilesCommand zcat \
	--outFileNamePrefix $wd/$prefix/ \
	--outSAMtype BAM Unsorted \
	--outFilterMismatchNmax 2 \
	--quantMode GeneCounts TranscriptomeSAM \
	--twopassMode Basic \
	--limitIObufferSize 50000000 \
        --limitSjdbInsertNsj 1000000 \
	--limitBAMsortRAM 10000000000

## unused options
 #--outWigType wiggle read1_5p \ 
