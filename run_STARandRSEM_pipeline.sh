#!/usr/bin/bash

cmd=$HOME/RNAseq_scripts/STARandRSEM_pipeline.sh

#wd=$HOME/Nujhat/RNAseq/GSE85331_download
#wd=$HOME/Ernest/RNAseq
#Dec16, 2022
wd=$HOME/Nabeel/RNAseq/Aug2022/GREENBLATT
	#$cmd trimjob 1 "R1_001.fastq.gz R2_001.fastq.gz" true $wd none

#wd=$HOME/Zuyao/RNA_seq/Nonstranded/oneLane
#wd=$HOME/Zuyao/RNA_seq/Stranded
#Dec13, 2022
wd=$HOME/Nabeel/RNAseq/Nov28_2022/GREENBLATT
	#$cmd job 1 "R1_001.fastq.gz R2_001.fastq.gz" true $wd none

#Dec14, 2022
wd=$HOME/Nabeel/RNAseq/Alexandra_15_03_2022/GREENBLATT
	#$cmd job 1 "R1_001.fastq.gz" false $wd none

#Sep20, 2023
wd=$HOME/Nujhat/RNAseq/GSE179630_download
        #$cmd trim 1 "fastq.gz" false $wd none
	$cmd trimjob 1 "fastq.gz" false $wd reverse

wd=$HOME/Nujhat/RNAseq/E-MTAB-2682
        #$cmd trim 1 "1.fastq.gz 2.fastq.gz" true $wd reverse
        $cmd trimjob 1 "1.fastq.gz 2.fastq.gz" true $wd reverse

wd=$HOME/Nujhat/RNAseq/E-MTAB-6010
        #$cmd trim 1 "1.fastq.gz 2.fastq.gz" true $wd reverse
        $cmd trimjob 1 "1.fastq.gz 2.fastq.gz" true $wd reverse
