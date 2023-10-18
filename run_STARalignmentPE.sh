#!/bin/bash

function trim_adapt(){

	local infiles=$1
	local prefix=$2

	 submitjob -c 10 -m 20 cutadapt \
                        -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
                        -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
			-j 10 \
			-q 20 \
			-m 25 \
                        -o trimmed.${prefix}.R1.fastq.gz -p trimmed.${prefix}.R2.fastq.gz \
                        $infiles
}

function run_job(){

	local wd=$1
	local prefix=$2
	local star=$3
	local rsem=$4
	local index=$5
	local gtf=$6
	local rsemrf=$7
	local infiles=$8
	
       	if [ ! -s "$wd/$prefix/ReadsPerGene.out.tab" ]; then
                echo "$wd/$prefix alignment results does not exist!"
                submitjob -w 100 -c 10 -m 40 $star "$infiles" $prefix $wd $index $gtf
        else
                echo "$wd/$prefix alignment succeeded"
                if [ ! -s "$wd/$prefix/rsem_out/${prefix}.genes.results" ]; then
                        echo "$wd/$prefix RSEM results does not exist!"
                       submitjob -w 50 -c 10 -m 40  $rsem $prefix $wd $rsemrf
                else
                        rm $wd/$prefix/rsem_out/*.bam*
                        rm $wd/$prefix/*.bam*
                        echo "$wd/$prefix RSEM succeeded"
                fi
        fi

}


function main(){

	local wd=$1
        local star=$2
        local rsem=$3
        local index=$4
        local gtf=$5
        local rsemrf=$6
	local trim=$7
	local Nlane=$8
   	local postfix=($9)

	cd $wd

	if [[ -z $Nlane ]]; then $Nlane=1; fi

	if [[ $Nlane == 2 ]]; then
   	for f11 in *_${postfix[0]}; do #L001_R1_001.fastq.gz
		prefix=$(basename $f11 _${postfix[0]})
		f21=${prefix}_${postfix[1]} #L002_R1_001.fastq.gz
		f12=${prefix}_${postfix[2]} #L001_R2_001.fastq.gz
		f22=${prefix}_${postfix[3]} #L002_R2_001.fastq.gz

		infiles="$f11,$f21 $f12,$f22"

		echo "prefix: $prefix"
		echo "infiles: $infiles"
		echo "working directory: $wd"

		if [[ $prefix != "*" ]]; then
			if [[ $trim == "qc" ]]; then
                                mkdir -p fastqc_result
                                submitjob -m 10 fastqc $f11 $f21 -o fastqc_result
                                submitjob -m 10 fastqc $f21 $f22 -o fastqc_result
                        elif [[ $trim == "job" ]]; then
                                run_job "$wd" "$prefix" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$infiles"
                        else
                                echo "trim option only takes 'qc', 'trim', 'job', 'trimqc' and 'trimjob'"
                                exit 1
                        fi

		else
			echo "matching files do not exist"
		fi 		
   	done
	fi

	if [[ $Nlane == 1 ]]; then
	for f1 in *_${postfix[0]}; do #1.fastq.gz or R1_001.fastq.gz
                prefix=$(basename $f1 _${postfix[0]})
                f2=${prefix}_${postfix[1]} #2.fastq.gz or R2_001.fastq.gz

                infiles="$f1 $f2"
		
		echo "prefix: $prefix"
                echo "infiles: $infiles"
                echo "working directory: $wd"

		if [[ $prefix != "*" ]]; then
                	if [[ $trim == "qc" ]]; then
                                mkdir -p fastqc_result
                                submitjob -m 10 fastqc $f1 -o fastqc_result
                                submitjob -m 10 fastqc $f2 -o fastqc_result
                        elif [[ $trim == "trim" ]]; then
                                trim_adapt "$infiles" "$prefix"
                        elif [[ $trim == "job" ]]; then
                                run_job "$wd" "$prefix" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$infiles"
                        elif [[ $trim == "trimqc" ]]; then
                                mkdir -p fastqc_result
                                submitjob -m 10 fastqc trimmed.${prefix}.R1.fastq.gz -o fastqc_result
                                submitjob -m 10 fastqc trimmed.${prefix}.R2.fastq.gz -o fastqc_result
                        elif [[ $trim == "trimjob" ]]; then
                                run_job "$wd" "$prefix" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "trimmed.${prefix}.R1.fastq.gz trimmed.${prefix}.R2.fastq.gz"
                        else
                                echo "trim option only takes 'qc', 'trim', 'job', 'trimqc' and 'trimjob'"
                                exit 1
                        fi

		else
                        echo "matching files do not exist"

		fi
        done
	fi	
}

star=$HOME/RNAseq_scripts/STARalignmentPE.sh
rsem=$HOME/RNAseq_scripts/RSEM_analysisPE.sh
index=$HOME/GRCH38_gencode/STARindex
gtf=$HOME/GRCH38_gencode/gencode.v35.primary_assembly.annotation.gtf
rsemrf=$HOME/GRCH38_gencode/RSEM_ref
#wd=$HOME/Nujhat/RNAseq/GSE85331_download
#wd=$HOME/Ernest/RNAseq
#wd=$HOME/Nabeel/RNAseq/Aug2022/GREENBLATT
wd=$HOME/Zuyao/RNA_seq/Nonstranded/oneLane
#wd=$HOME/Zuyao/RNA_seq/Stranded
#wd=$HOME/Nabeel/RNAseq/Nov28_2022/GREENBLATT

trim=$1
Nlane=$2
postfix=$3

if [[ $# -lt 3 ]]; then
                echo "Enter: 'fastqc', 'trim', 'job', 'trimqc' or 'trimjob' for the first argument"
		echo "Enter: '1' or '2' for the second argument (number of lanes)"
		echo "Enter: 'R1_001.fastq.gz R2_001.fastq.gz' for the third argument (postfix)"
                exit 1
fi

main "$wd" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$trim" "$Nlane" "$postfix"

##END
