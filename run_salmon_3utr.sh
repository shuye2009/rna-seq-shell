#!/bin/bash

cmd=/home/greenblattlab/shuyepu/Nabeel/RNAseq/scripts/salmon_3utr.sh

wd=/home/greenblattlab/shuyepu/Nabeel/RNAseq/Jul06_2021/ ## need adjust

cd $wd
mkdir -p salmon_3utr_result

for f11 in *_R1_001.fastq.gz; do
        prefix=$(basename $f11 _R1_001.fastq.gz)

 	submitjob -m 20 $cmd $f11 $prefix $wd
done				
				

