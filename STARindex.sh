#!/bin/sh

## make STAR index, the options --sjdbGTFfeatureExon and --sjdbGTFtagExonParentTranscript
## are customized for Tetrahymena, usually they are not required for model organisms
indexdir=$HOME/Tetrahymena/STARindex
fasta=$HOME/Tetrahymena/1-Genome_assembly.fasta
gtf=$HOME/Tetrahymena/2-Genome_GFF3.gtf
mkdir -p $indexdir
STAR	--runThreadN 4 \
	--runMode genomeGenerate \
	--genomeDir $indexdir \
	--genomeFastaFiles $fasta \
	--sjdbGTFfile $gtf \
	--sjdbOverhang 100 \
	--sjdbGTFfeatureExon exon \
	--sjdbGTFtagExonParentTranscript transcript_id \
	--genomeSAindexNbases 12 \
	--genomeSAsparseD 3 \
	--limitGenomeGenerateRAM 40000000000 \
	--limitIObufferSize 50000000 \
	--limitSjdbInsertNsj 390000
 
