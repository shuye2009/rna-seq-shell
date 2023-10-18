# rna-seq-shell

The main program for this pipeline is 'STARandRSEM_pipeline.sh'.

First run './STARandRSEM_pipeline.sh' to get information about all the arguments. 
The first argument specify what operation will be performed. 
Each operation has to be run separately. 
Usually start with 'fastqc', if the results are okay, then run 'job'. If not, then run 'trim', followed by 'trimqc', if the results look good, then run 'trimjob', otherwise adjust trim parameters (you have to modify the 'trim_adapt()' function of the script), and run 'trimqc', followed by 'trimjob'.
