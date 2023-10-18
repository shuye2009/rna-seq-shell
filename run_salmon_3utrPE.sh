#!/bin/bash

cmd=/home/greenblattlab/shuyepu/RNAseq_scripts/salmon_3utrPE.sh

## Nabeel PUF60
if [ 1 -eq 1 ]; then
        wd=/home/greenblattlab/shuyepu/Nabeel/PUF60/ESC
	index=/home/greenblattlab/shuyepu/qapa/data/mm10/mm10_3utr_library
        cd $wd
        mkdir -p salmon_3utr_result

        for f1 in *_1.fastq.gz; do
                prefix=$(basename $f1 _1.fastq.gz)
                f2=${prefix}_2.fastq.gz

                submitjob -m 20 $cmd $f1 $f2 $prefix $wd $index
        done
fi


## Nuhjet
if [ 1 -eq 0 ]; then
        wd=/home/greenblattlab/shuyepu/Nujhat/RNAseq/GSE85331_download

        cd $wd
        mkdir -p salmon_3utr_result

        for f1 in *_1.fastq.gz; do
                prefix=$(basename $f1 _1.fastq.gz)
                f2=${prefix}_2.fastq.gz
 
                $cmd $f1 $f2 $prefix $wd
        done
fi


if [ 1 -eq 0 ]; then
        wd=/home/greenblattlab/shuyepu/Nabeel/nujhat/RNAseq/GREENBLATT

        cd $wd
        mkdir -p salmon_3utr_result

        for f11 in *_L001_R1_001.fastq.gz; do
                prefix=$(basename $f11 _L001_R1_001.fastq.gz)
                f21=${prefix}_L002_R1_001.fastq.gz
                f12=${prefix}_L001_R2_001.fastq.gz
                f22=${prefix}_L002_R2_001.fastq.gz


                submitjob -m 20 $cmd "$f11 $f21" "$f12 $f22" $prefix $wd
        done
fi

## For Nabeel
if [ 1 -eq 0 ]; then
	wd=/home/greenblattlab/shuyepu/Nabeel/RNAseq/Jul06_2021/GREENBLATT_16RNA

	cd $wd
	mkdir -p salmon_3utr_result

	for f11 in *_L001_R1_001.fastq.gz; do
        	prefix=$(basename $f11 _L001_R1_001.fastq.gz)
        	f21=${prefix}_L002_R1_001.fastq.gz
        	f12=${prefix}_L001_R2_001.fastq.gz
        	f22=${prefix}_L002_R2_001.fastq.gz
	

 		submitjob -m 20 $cmd "$f11 $f21" "$f12 $f22" $prefix $wd
	done				
fi


if [ 1 -eq 0 ]; then
        wd=/home/greenblattlab/shuyepu/Jingwen/RNAseq/july170713/Greenblatt

        cd $wd
        mkdir -p salmon_3utr_result

        for f11 in *_siMock_*_R1_001.fastq.gz; do
                prefix=$(basename $f11 _R1_001.fastq.gz)
                
                f12=${prefix}_R2_001.fastq.gz
		echo $f11

                submitjob -m 20 $cmd $f11 $f12 $prefix $wd
        done
fi
			

