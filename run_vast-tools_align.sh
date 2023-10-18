#!/bin/bash

tf=$1

## Nabeel ZBTB7A
if [[ 1 -eq 0 ]]; then
wd=$HOME/Nabeel/RNAseq/Jul06_2021/GREENBLATT_16RNA
mkdir -p $wd/vast_results
outd=$wd/vast_results/$tf
mkdir -p $outd
cd $wd

if [ -e ${outd}/${tf}_grouping.txt ]; then rm ${outd}/${tf}_grouping.txt; fi
for S in S1 S2; do
	for L in L001 L002; do
		submitjob -w 100 -m 20 vast-tools align --sp hg19 -c 4 -o $outd -n ${tf}_${S}_${L} *_${tf}_${S}_*_${L}_R1_001.fastq.gz *_${tf}_${S}_*_${L}_R2_001.fastq.gz 
		submitjob -w 100 -m 20 vast-tools align --sp hg19 -c 4 -o $outd -n siNT_${S}_${L} *_siNT_${S}_*_${L}_R1_001.fastq.gz *_siNT_${S}_*_${L}_R2_001.fastq.gz
		
		echo -e "${tf}_${S}_${L}\t${tf}_${S}" >> ${outd}/${tf}_grouping.txt
		echo -e "siNT_${S}_${L}\tsiNT_${S}" >>  ${outd}/${tf}_grouping.txt
	done
done
fi

## Gio ZNF121, May 04, 2023
wd=$HOME/Nabeel/RNAseq/Nov28_2022/GREENBLATT
mkdir -p $wd/vast_results
outd=$wd/vast_results/$tf
mkdir -p $outd
cd $wd

if [ -e ${outd}/${tf}_grouping.txt ]; then rm ${outd}/${tf}_grouping.txt; fi
for S in S1 S2; do
	submitjob -w 100 -m 10 vast-tools align --sp hg19 -c 4 -o $outd -n ${tf}_${S} *_${tf}_${S}_*_R1_001.fastq.gz *_${tf}_${S}_*_R2_001.fastq.gz
        submitjob -w 100 -m 10 vast-tools align --sp hg19 -c 4 -o $outd -n WT_${S} *_WT_${S}_*_R1_001.fastq.gz *_WT_${S}_*_R2_001.fastq.gz

        echo -e "${tf}_${S}\t${tf}_${S}" >> ${outd}/${tf}_grouping.txt
        echo -e "WT_${S}\tWT_${S}" >>  ${outd}/${tf}_grouping.txt
done


