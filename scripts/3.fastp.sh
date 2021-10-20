# Script to check for adapter content with fastp and rename sequence identifiers in preparation for KneadData
# This is run on the cluster

## --- quality control steps: fastp and rename for kneaddata (downstream)

conda activate bioinfo

set -uex

## ---- CHANGE THESE VARIABLES ----

# general output name
OUTNAME=NAME

# working directory
DIR=/path/to/working/directory

# input directory to raw reads
RAWDIR=/path/to/raw/reads

# output directory for fastp
TRIMDIR=/path/to/trimmed/reads

# output directory for renaming
OUTDIR=/path/to/renamed/reads

## ---- perform quality control with fastp ----

# make directory if it doesn't exist
mkdir -p $TRIMDIR/$OUTNAME

# perform quality control
cat $DIR/runids_$OUTNAME.txt | parallel -j10 /path/to/executable/fastp -i $RAWDIR/{}_1.fastq -I $RAWDIR/{}_2.fastq -o $TRIMDIR/$OUTNAME/{}_1_trim.fastq -O $TRIMDIR/$OUTNAME/{}_2_trim.fastq --detect_adapter_for_pe

# print finished message
echo "fastp complete!"

## ---- rename sequence identifiers for kneaddata ----

# make directory
mkdir -p $OUTDIR/$OUTNAME

# rename forward reads 
cat $DIR/runids_$OUTNAME.txt | parallel -j10 path/to/executable/seqkit replace $TRIMDIR/$OUTNAME/{}_1_trim.fastq -p "' length=[[:digit:]]*'" -r "'\1'" -o $OUTDIR/$OUTNAME/{}_rename_1.fastq

# rename reverse reads 
cat $DIR/runids_$OUTNAME.txt |  parallel -j10 path/to/executable/seqkit replace $TRIMDIR/$OUTNAME/{}_2_trim.fastq -p "' length=[[:digit:]]*'" -r "'\2'" -o $OUTDIR/$OUTNAME/{}_rename_2.fastq

# print finished message
echo "renaming complete"

