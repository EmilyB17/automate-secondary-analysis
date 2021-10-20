# Automating secondary sequence analysis with the ROAR clusters

You've learned how to connect to NCBI's Sequence Read Archive and download metagenomics data. What if you wanted to do this on a bigger scale using more than one accession number, or what if you wanted to make your analysis fully reproducible?

Here's a few tips to make your workflow easy for you and easy for others:

## Start with a "change me" section

In your workflow, some variables may change (i.e. accession number) and some may stay the same (i.e. the number of spots to download). At the start of the script, list your variables that change. This makes them easy to access and helps to reduce typo errors if you have a long workflow.

```
### ---- CHANGE THESE VARIABLES ----

# accession number
ACC=PRJEB1220

# working directory
DIR=/path/to/my/working/directory

# name of the project
OUTNAME=projectname

# set prefix (European is ERR, American is SRR)
PREF=ERR
```

## Refer to these variables throughout the script

Here's the rest of the analysis that we learned earlier. Here's the key: if we only change the variables above, this script runs all by itself and we don't need to go into the actual code each time.

```
### ---- workflow ----
# get runinfo
esearch -db sra -query $ACC | efetch -format runinfo > $DIR/runinfo_$OUTNAME.csv

# get runids
cat $DIR/runinfo_$OUTNAME.csv | cut -f 1 -d ',' | grep $PREF > $DIR/runids_$OUTNAME.txt

# get one sample with 10,000 reads to test connection
cat $DIR/runids_$OUTNAME.txt | head -1 | parallel /storage/work/epb5360/miniconda3/envs/bioinfo/bin/fastq-dump -X 10000 --split-files --outdir $DIR {}

# print stats for the reads
seqkit stat $DIR/*.fastq

# print finished message
echo "done!"

```

## Put it together

Here's what the whole script looks like (this is [get-runinfo.sh](get-runinfo.sh)

```
# activate the conda environment
conda activate bioinfo

# catch errors
set -uex

### ---- CHANGE THESE VARIABLES ----

# accession number
ACC=PRJEB1220

# working directory
DIR=/path/to/my/working/directory

# name of the project
OUTNAME=projectname

# set prefix (European is ERR, American is SRR)
PREF=ERR

### ---- workflow ----
# get runinfo
esearch -db sra -query $ACC | efetch -format runinfo > $DIR/runinfo_$OUTNAME.csv

# get runids
cat $DIR/runinfo_$OUTNAME.csv | cut -f 1 -d ',' | grep $PREF > $DIR/runids_$OUTNAME.txt

# get one sample with 10,000 reads to test connection
cat $DIR/runids_$OUTNAME.txt | head -1 | parallel /storage/work/epb5360/miniconda3/envs/bioinfo/bin/fastq-dump -X 10000 --split-files --outdir $DIR {}

# print stats for the reads
seqkit stat $DIR/*.fastq

# print finished message
echo "done!"

```

## Get fancier with outside variables

What if you don't even want to open the script each time you run this code for a new accession number? 

```
## --- CHANGE THESE VARIABLES ----

# accession number
ACC=$1

# working directory
DIR=/path/to/my/working/directory

# name of the project
OUTNAME=projectname

# set prefix (European is ERR, American is SRR)
PREF=$2
```

We tell bash these variables when we run the script: `bash myscript.sh PRJEB1220 SRR`



