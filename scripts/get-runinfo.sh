# Step 1: Get run info from SRA and test the connection 
# the conda environment for this script is available at biostarhandbook.com

## run locally (does not need to submit to ROAR)

## script to get runinfo and test accession number

# activate conda
conda activate bioinfo

# catch errors
set -uex

## ---- CHANGE THESE VARIABLES ----

# accession number
ACC=YOUR-ACCESSION-NUMBER

# input directory
DIR=YOUR-WORKING-DIRECTORY

# general output name
OUTNAME=YOUR-PROJECT-NAME

# set prefix (European is ERR, American is SRR)
PREF=ERR

## ---- workflow: get runinfo and test accession ----

# get runinfo
esearch -db sra -query $ACC | efetch -format runinfo > $DIR/runinfo_$OUTNAME.csv

# get runids
cat $DIR/runinfo_$OUTNAME.csv | cut -f 1 -d ',' | grep $PREF > $DIR/runids_$OUTNAME.txt

# get one sample with 10,000 reads to test connection
cat $DIR/runids_$OUTNAME.txt | head -1 | parallel path-to-executeable/fastq-dump -X 10000 --split-files --outdir $DIR {}

# print stats for the reads
seqkit stat $DIR/*.fastq

# print finished message
echo "done!"

