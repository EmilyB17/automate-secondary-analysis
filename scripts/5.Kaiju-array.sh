# Run Kaiju on the nonredundant eukaryotic database
## this takes a LOT of RAM and has to run on the ROAR himem nodes
## this also runs in an array; the PBS submission variables are different


## KAIJU NR-EUK

# activate conda environment
conda activate bioinfo

# catch errors
set -uex

## ---- SET VARIABLES ----

# general output name
OUTNAME=projectname

# directory to input files
# (these files have been trimmed and filtered for quality control)
INDIR=/input/files

# output directory for renamed files
## this step is necessary because KneadData needs paired end reads to have a specific sequence identifier but Kaiju requires that they match
REDIR=/rename/path

# make directory if it doesn't exist
mkdir -p $REDIR

# path to kaiju database
KAIJUDB=/refs/kaiju-nr-euk-2021-02-24

# output directory for kaiju results
KAIOUT=/path/to/output

# make directory if it doesn't exist
mkdir -p $KAIOUT

# output directory for kaiju tables
KAITAB=/path/to/output/tables

# make directory if it doesn't exist
mkdir -p $KAITAB

### ---- ARRAY SETUP ----

# Define environment setup -- this is a directory with file names
DATADIRECTORY=/path/to/directory

# create list of file names
arrayoffiles=( $(ls $DATADIRECTORY | awk -F _ '{print $1}' | sort | uniq) )

## ---- rename forward and reverse samples ----

cat $INDIR/${arrayoffiles[${PBS_ARRAYID}]}_rename_1_kneaddata_paired_1.fastq | seqkit replace -p '\\1' -r '' -o $REDIR/${arrayoffiles[${PBS_ARRAYID}]}_1.fastq
cat $INDIR/${arrayoffiles[${PBS_ARRAYID}]}_rename_1_kneaddata_paired_2.fastq | seqkit replace -p '\\2' -r '' -o $REDIR/${arrayoffiles[${PBS_ARRAYID}]}_2.fastq

## ---- RUN KAIJU ----

# run kaiju on nr-euk database
/usr/bin/time -v location/to/kaiju -v -t $KAIJUDB/nodes.dmp -f $KAIJUDB/kaiju_db_nr_euk.fmi -i $REDIR/${arrayoffiles[${PBS_ARRAYID}]}_1.fastq -j $REDIR/${arrayoffiles[${PBS_ARRAYID}]}_2.fastq -o $KAIOUT/${arrayoffiles[${PBS_ARRAYID}]}_$OUTNAME.txt

echo " "
echo "kaiju run complete"
echo " "

# make a table from kaiju results
/location/to/kaiju2table -t $KAIJUDB/nodes.dmp -n $KAIJUDB/names.dmp -r species -l superkingdom,kingdom,phylum,class,order,family,genus,species -v -o $KAITAB/${arrayoffiles[${PBS_ARRAYID}]}_$OUTNAME.table.txt $KAIOUT/${arrayoffiles[${PBS_ARRAYID}]}_$OUTNAME.txt

echo " "
echo "kaiju table complete"
echo " " 

# Finish up
echo " "
echo "Job Ended at `date`"
echo " "
