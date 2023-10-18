# rna-seq-shell

The main program for this pipeline is 'STARandRSEM_pipeline.sh'.

First run './STARandRSEM_pipeline.sh' to get information about all the arguments:
 
Enter: 'fastqc', 'trim', 'job', 'trimqc' or 'trimjob' for the first argument \
Enter: '1' or '2' (number of lanes) for the second argument\
Enter: something like 'R1_001.fastq.gz R2_001.fastq.gz' for the third argument, depending on file name pattern \
Enter: 'true' for paired-end library or 'false' for single-end library \
Enter: path to working directory \
Enter: 'none', 'forward' or 'reverse' for library type. For Illumina TruSeq Stranded protocols, please use 'reverse'

The first argument specify what operation will be performed. 

Each operation has to be run separately. 

Usually start with 'fastqc', if the results are okay, then run 'job'. If not, then run 'trim' followed by 'trimqc', if the results look good, then run 'trimjob', otherwise adjust trim parameters (you have to modify the 'trim_adapt()' function of the script), and run 'trimqc' followed by 'trimjob'.

The 'job' or 'trimjob' have to be run at least twice, the first time is for STAR alignment, the second time for RSEM. Or if some cluster job fails due to exceeding resources limits, run again by increasing memory or wall time in the script.

When 'job' or 'trimjob' are re-run, only failed ones are re-run, successfully finished jobs will not be re-run to save time and resources.
