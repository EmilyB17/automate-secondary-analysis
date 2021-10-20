# Quality control with KneadData
## this is run as a JOB ARRAY; the PBS submission variables are different
# each sample will run as its own job
# this requires a ROAR allocation

# Get started
echo " "
echo "Job started on `hostname` at `date`"
echo " "

# activate conda environment
conda activate bioinfo

# catch errors
set -uex

# output directory
OUTDIR=/path/to/directory

# Define environment setup
DATADIRECTORY=/path/to/files/to/run

# create list of file names
arrayoffiles=( $(ls $DATADIRECTORY | awk -F _ '{print $1}' | sort | uniq) )

# do kneaddata
/usr/bin/time -v kneaddata --input $DATADIRECTORY/${arrayoffiles[${PBS_ARRAYID}]}_rename_1.fastq --input $DATADIRECTORY/${arrayoffiles[${PBS_ARRAYID}]}_rename_2.fastq -db /refs/hg37dec_v0.1 -o $OUTDIR --run-trim-repetitive --bypass-trf --run-fastqc-end --trimmomatic binary/executable/Trimmomatic-0.33 --fastqc binary/executable/FastQC

# Finish up
echo " "
echo "Job Ended at `date`"
echo " "
