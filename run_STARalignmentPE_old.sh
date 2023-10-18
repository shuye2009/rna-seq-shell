#!/bin/bash

star=$HOME/Nabeel/RNAseq/scripts/STARalignmentPE.sh
rsem=$HOME/Nabeel/RNAseq/scripts/RSEM_analysisPE.sh

## Nabeel Tetrahymena samples
if [ 1 -eq 1 ]; then
index=$HOME/Tetrahymena/STARindex
gtf=$HOME/Tetrahymena/2-Genome_GFF3.gtf
rsemrf=/home/greenblattlab/shuyepu/Tetrahymena/RSEM_ref/RSEM_ref
wd1=/home/greenblattlab/shuyepu/Nabeel/RNAseq/Tetrahymena/GREENBLATT_17RNA
fi


## Nabeel and Kristie samples
if [ 1 -eq 0 ]; then
wd1=/home/greenblattlab/shuyepu/Nabeel/RNAseq/Jul06_2021/GREENBLATT_16RNA
wd2=/home/greenblattlab/shuyepu/Nabeel/RNAseq/Jul06_2021/GREENBLATT_17RNA
fi

## Nujhat samples
if [ 1 -eq 0 ]; then
wd1=/home/greenblattlab/shuyepu/Nabeel/nujhat/RNAseq/GREENBLATT
fi

for wd in $wd1; do
   cd $wd

   for f11 in *_L001_R1_001.fastq.gz; do
	prefix=$(basename $f11 _L001_R1_001.fastq.gz)
	f21=${prefix}_L002_R1_001.fastq.gz
	f12=${prefix}_L001_R2_001.fastq.gz
	f22=${prefix}_L002_R2_001.fastq.gz

	infiles="$f11,$f21 $f12,$f22"
	#echo $prefix
	#echo $infiles
	#echo $wd

	if [ ! -s "$wd/$prefix/ReadsPerGene.out.tab" ]; then
		echo "$wd/$prefix alignment results does not exist!"
		submitjob 100 -m 60 $star "$infiles" $prefix $wd $index $gtf
	else
		echo "$wd/$prefix alignment succeeded"
		if [ ! -s "$wd/$prefix/rsem_out/${prefix}.genes.results" ]; then
	                echo "$wd/$prefix RSEM results does not exist!"
        	       submitjob -m 20  $rsem $prefix $wd $rsemrf
        	else
			rm $wd/$prefix/rsem_out/*.bam*
			rm $wd/$prefix/*.bam*
                	echo "$wd/$prefix RSEM succeeded"
        	fi
	fi

   done
done 
