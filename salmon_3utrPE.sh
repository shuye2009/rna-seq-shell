#!/bin/bash

## quantify last exon with salmon quant directly from reads

infile1=$1
infile2=$2
prefix=$3
wd=$4
salmon_index=$5 #$HOME/Salmon-1.3.0_linux_x86_64/data/output_sequences_salmonIndex_3UTR_hg38
cd $wd
mkdir -p salmon_3utr_result/${prefix}_3utr

salmon quant \
	-p 4 \
	-i ${salmon_index} \
	-o $wd/salmon_3utr_result/${prefix}_3utr \
	-l A \
	-1 $infile1 \
	-2 $infile2
				

