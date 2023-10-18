#!/bin/bash

infile=$1
prefix=$2
wd=$3

cd $wd
mkdir -p salmon_3utr_result/${prefix}_3utr

salmon quant \
	-p 8 \
	-i $HOME/Salmon-1.3.0_linux_x86_64/data/output_sequences_salmonIndex_3UTR_hg38 \
	-o salmon_3utr_result/${prefix}_3utr \
	-l A \
	-r $infile
				
				

