## STEP 2: DOWNLOAD ALL DATA FROM SRA
# the conda environment used in this script is available from biostarhandbook.com


# activate conda environment
conda activate bioinfo

# catch errors
set -uex

## ---- CHANGE THESE VARIABLES ----

# general output name
OUTNAME=YOUR-NAME

# input working directory
DIR=YOUR-WORKING-DIRECTORY

# output directory for raw reads
## THIS WILL NEED TO HAVE LOTS OF STORAGE
RAWDIR=YOUR-SCRATCH-DIRECTORY

# output directory for fastqc and multiqc quality
QUALOUT=YOUR-OUTPUT-DIRECTORY

## ---- get reads from SRA with fastq-dump ---

# make output directory if it doesn't exist
mkdir -p $RAWDIR

# fastq-dump
cat $DIR/runids_$OUTNAME.txt | parallel -j10 path-to-executable/fastq-dump {} --split-files --outdir $RAWDIR

echo "read dump complete"

## ---- run fastqc and multiqc for quality ----

# make output directory if it doesn't exist
mkdir -p $QUALOUT/$OUTNAME

# run fastqc on forward reads 
cat $DIR/runids_$OUTNAME.txt | parallel -j10 path-to-executable/fastqc $RAWDIR/{}_1.fastq -o $QUALOUT/$OUTNAME

# run fastqc on reverse reads 
cat $DIR/runids_$OUTNAME.txt | parallel -j10 path-to-executable/fastqc $RAWDIR/{}_2.fastq -o $QUALOUT/$OUTNAME

# run multiqc on all reads
multiqc $QUALOUT/$OUTNAME/* -o $QUALOUT -n $OUTNAME.multiqc

echo "quality check complete"
