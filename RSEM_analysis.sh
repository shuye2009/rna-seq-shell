#!/bin/sh

## quantitate read count for genes and transcripts

prefix=$1
wd=$2
rsemrf=$3 # $HOME/GRCH38_gencode/RSEM_ref/RSEM_ref 
paired=$4
stranded=$5
ncore=$6

op="-p $ncore"
if $paired; then op="-p $ncore --paired-end"; fi

cd $wd/$prefix
mkdir -p rsem_out

rsem-calculate-expression $op \
			--alignments \
			--estimate-rspd \
			--append-names \
			--no-bam-output \
			--strandedness $stranded \
			Aligned.toTranscriptome.out.bam \
			$rsemrf \
			rsem_out/$prefix 

# not used options
#	--temporary-folder /dev/shm/shuye \
#	--output-genome-bam \
#	--sort-bam-by-coordinate \

