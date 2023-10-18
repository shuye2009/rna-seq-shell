#!/bin/bash

function trim_adapt(){

	local infiles=$1
	local prefix=$2
	local paired=$3

	if $paired; then
	 submitjob -c 10 -m 20 cutadapt \
                        -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
                        -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
			-j 10 \
			-q 20 \
			-m 25 \
                        -o trimmed.${prefix}_R1.fastq.gz -p trimmed.${prefix}_R2.fastq.gz \
                        $infiles
 	else
	 submitjob -c 10 -m 20 cutadapt \
                        -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
                        -j 10 \
                        -q 20 \
                        -m 25 \
                        -o trimmed.${prefix}_R1.fastq.gz \
                        $infiles
	fi
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
	local paired=$9
	local stranded=${10}
	
       	if [ ! -s "$wd/$prefix/ReadsPerGene.out.tab" ]; then
                echo "$wd/$prefix alignment results does not exist!"
                submitjob -w 100 -c 10 -m 40 $star "$infiles" $prefix $wd $index $gtf
        else
                echo "$wd/$prefix alignment succeeded"
                if [ ! -s "$wd/$prefix/rsem_out/${prefix}.genes.results" ]; then
                        echo "$wd/$prefix RSEM results does not exist!"
                       submitjob -w 50 -c 10 -m 40  $rsem $prefix $wd $rsemrf $paired $stranded
                else
                        #rm $wd/$prefix/rsem_out/*.bam*
                        rm $wd/$prefix/*.bam*
                        echo "$wd/$prefix RSEM succeeded"
                fi
        fi

}

function cat_fastq(){
	local paired=$1
	local postfix=$2

	for f11 in *_${postfix[0]}; do #L001_R1_001.fastq.gz
                prefix=$(basename $f11 _${postfix[0]})
                f21=${prefix}_${postfix[1]} #L002_R1_001.fastq.gz
                zcat $f11 $f21 | gzip > ${prefix}_R1.fastq.gz
                if $paired; then
                        f12=${prefix}_${postfix[2]} #L001_R2_001.fastq.gz
                        f22=${prefix}_${postfix[3]} #L002_R2_001.fastq.gz

                        zcat $f12 $f22 | gzip > ${prefix}_R2.fastq.gz
                fi
	done
 
	if [[ $paired ]]; then
		suffix=("R1.fastq.gz" "R2.fastq.gz")
	else
		suffix=("R1.fastq.gz")
	fi

	return $suffix
}


function perform_operation(){

	local wd=$1
        local star=$2
        local rsem=$3
        local index=$4
        local gtf=$5
        local rsemrf=$6
	local operation=$7
   	local postfix=($8)
	local paired=${9}
	local stranded=${10}

	cd $wd

	for f1 in *_${postfix[0]}; do #1.fastq.gz or R1_001.fastq.gz
                prefix=$(basename $f1 _${postfix[0]})
		infiles="$f1"
		if $paired; then
                	f2=${prefix}_${postfix[1]} #2.fastq.gz or R2_001.fastq.gz

                	infiles="$f1 $f2"
		fi
	
		echo "operation: $operation"
		echo "number of lanes: $Nlane"
		echo "paired end? $paired"	
		echo "prefix: $prefix"
		echo "postfix: ${postfix[*]}"
                echo "infiles: $infiles"
                echo "working directory: $wd"

		if [[ $prefix != "*" ]]; then
                	if [[ $operation == "qc" ]]; then
                                mkdir -p fastqc_result
                                submitjob -m 10 fastqc $f1 -o fastqc_result
                                if $paired; then submitjob -m 10 fastqc $f2 -o fastqc_result; fi
			elif [[ $operation == "job" ]]; then
                                run_job "$wd" "$prefix" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$infiles" $paired $stranded
                        elif [[ $operation == "trim" ]]; then
                                trim_adapt "$infiles" "$prefix" $paired
                        elif [[ $operation == "trimqc" ]]; then
                                mkdir -p fastqc_result
                                submitjob -m 10 fastqc trimmed.${prefix}_R1.fastq.gz -o fastqc_result
                                if $paired; then submitjob -m 10 fastqc trimmed.${prefix}_R2.fastq.gz -o fastqc_result; fi
                        elif [[ $operation == "trimjob" ]]; then
				infiles="trimmed.${prefix}_R1.fastq.gz"
				if $paired; then infiles="trimmed.${prefix}_R1.fastq.gz trimmed.${prefix}_R2.fastq.gz"; fi
                                run_job "$wd" "$prefix" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$infiles" $paired $stranded
                        else
                                echo "operation option only takes 'qc', 'trim', 'job', 'trimqc' and 'trimjob'"
                                exit 1
                        fi

		else
                        echo "matching files do not exist"

		fi
        done
}

function main(){

        local wd=$1
        local star=$2
        local rsem=$3
        local index=$4
        local gtf=$5
        local rsemrf=$6
        local operation=$7
        local Nlane=$8
        local postfix=($9)
        local paired=${10}
        local stranded=${11}

	cd $wd

        if [[ -z $Nlane ]]; then $Nlane=1; fi
	if [[ $Nlane == 2 ]]; then postfix=$(cat_fastq $paired $postfix); fi

	perferm_operation "$wd" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$operation" "$postfix" $paired $stranded
}
operation=$1
Nlane=$2
postfix=$3
paired=$4
wd=$5
stranded=$6

star=$HOME/RNAseq_scripts/STARalignment.sh
rsem=$HOME/RNAseq_scripts/RSEM_analysis.sh
index=$HOME/GRCH38_gencode/STARindex
gtf=$HOME/GRCH38_gencode/gencode.v35.primary_assembly.annotation.gtf
rsemrf=$HOME/GRCH38_gencode/RSEM_ref/RSEM_ref


if [[ $# -lt 6 ]]; then
                echo "Enter: 'fastqc', 'trim', 'job', 'trimqc' or 'trimjob' for the first argument"
		echo "Enter: '1' or '2' for the second argument (number of lanes)"
		echo "Enter: 'R1_001.fastq.gz R2_001.fastq.gz' for the third argument (postfix)"
		echo "Enter: 'true' for paired-end or 'false' for single-end"
		echo "Enter: working directory"
		echo "Enter: 'none', 'forward' or 'reverse'. For Illumina TruSeq Stranded protocols, please use 'reverse'"
                exit 1
fi

main "$wd" "$star" "$rsem" "$index" "$gtf" "$rsemrf" "$operation" "$Nlane" "$postfix" $paired $stranded

##END
