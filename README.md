# Automating access to SRA for secondary analysis

### Welcome!

In this workshop we will complete the following learning objectives:
1. Access NCBI's SRA through the command line and download metagenomics data
2. Examine our downloaded data and perform basic quality control
3. Learn to optimize these scripts for batch submission to PSU's high-powered computing clusters

### Acknowledgements

This workshop was made possible by Dr. Jasna Kovac, the fall 2021 workshop coordinator, and by Dr. Justin Petucci of ICDS RISE program. These scripts are adapted from Dr. Istvan Albert's *[Biostar Handbook](https://www.biostarhandbook.com/)*. This is a great resource that I highly recommend!

***

# Getting Started

## Find an accession number on NCBI's Sequence Read Archive

Today, we will use data from a 2018 *Nature Medicine* paper, [Gut microbiota and FXR mediate the clinical benefits of metformin](https://www.nature.com/articles/s41591-018-0222-4). Navigate to the online version of this paper and search for the accession code to their shotgun metagenomics data. (You should see the accession number: PRJNA486795)

Copy the accession number into the search bar for NCBI's [Sequence Read Archive](https://www.ncbi.nlm.nih.gov/sra). If the data was uploaded correctly (which from personal experience, is easier said than done!) a webpage will appear that looks like this: 

I like to use the **Run Selector** webpage. Spend a few minutes poking around; what kind of information is available on this page?

## Log onto ROAR

1. Log onto [PSU's Open OnDemand website](portal.aci.ics.psu.edu) and log in with your PSU username and password.  
2. Start a session and choose our environment (PENDING)
3. Launch the session (it may take a few minutes)

## Set up our environment

For this workshop we will use a software management program called **miniconda**. We have a pre-made environment for today's workshop and the full environment and conda install instructions can be found in the [Biostar Handbook](https://www.biostarhandbook.com/).

Run the following command to make a working directory and activate the conda environment. We are working in the scratch directory and we'll talk about the reason below.

```
# make a working directory in your scratch directory
mkdir -p ~/scratch/seq-workshop2021
cd ~/scratch/seq-workshop2021

# activate our conda environment
source /gpfs/group/RISE/training/2021_microbiome/fall/scripts/setup-env
```

Let's do a sanity check to make sure that the conda environment is working. Run `fastqc` in your command line. You should see a message like this:

# Connect to SRA and get run info

We are using a software called [sra-tools](https://github.com/ncbi/sra-tools). 

Start by saving your accession number as a variable so we don't have to retype it. We'll call the variable "ACC":
```
ACC=PRJNA486795
```

Next, use `esearch` and `efetch` to find and download the Run Information into a CSV

```
esearch -db sra -query $ACC | efetch -format runinfo > runinfo.csv
```

Runinfo.csv contains a lot of information. We can copy it over to our local machines to look at it in spreadsheet format like Excel. *Note: if you work on Windows you will need to download a Linux subshell, so skip this step for now*

**Run this code from your local terminal***
```
scp YOURUSERNAME@submit.aci.ics.psu.edu:~/seq-workshop2021/runinfo.csv ~/Downloads
```

There are 44 samples in this dataset. To avoid running into problems down the road, we want to get a list of the exact sample ID's that we want. These are called "Runs" in SRA. 
```
cat runinfo.csv | cut -f 1 -d ',' | grep SRR > runids_$ACC.txt
```

*Note that we named the runids with the accession number so if we are working with multiple accessions we can keep them organized*

Let's do a sanity check. How many run IDs do we have?
```
cat runids_$ACC.txt | wc -l
```

# Download metagenomics data

Finally, we are ready for the fun part! Now that we have (1) an accession number, and (2) a list of run IDs, we can download the fastq file from SRA. To streamline this process, we will use [GNU parallel](https://www.gnu.org/software/parallel/). This is an interesting tool that can do a LOT for you. Here, we will use it in it's most basic form.

**PRO TIP: Metagenomics files are BIG. If you're working with more than a few files, you will want to work in your scratch directory, which has unlimited storage space. Be cautious: Files in your scratch directory that are not used for 30 days are permanantly deleted**.

First, let's make a directory to write our files into. To make our lives easier and avoid typo errors, we'll save the directory path to a variable.
```
mkdir -p ~/scratch/seq-workshop2021/rawreads

# save the path to a variable
RAWDIR=~/scratch/seq-workshop2021/rawreads
```

To test our connection, we will download 1,000 "spots" (reads) from one file using `fastq-dump`:
```
cat runids_$ACC.txt | head -1 | parallel /gpfs/group/RISE/sw7/anaconda/anaconda3/envs/seq-sra/bin/fastq-dump -X 1000 --split-files --outdir $RAWDIR {}
```
*Note: GNU parallel and conda don't play nicely together. It will force you to include the path to the software executable*

If this is successful, we will see two files (one forward and one reverse) in our `rawreads` directory:
```
# change into our raw reads directory
cd $RAWDIR

# list the files in the directory with their size
ls -lh

# print the first 20 lines of the first file
# (replace "FILE" with the name of the file)
cat FILE_1.fastq | head -20
```

Sanity check: let's get to know our data. `seqkit stat` from the [seqkit](https://bioinf.shenwei.me/seqkit/) software is a tool that I use at every step of analysis, and you'll soon see why:
```
seqkit stat FILE_1.fastq
```

For today's workshop we'll download 5 full-sized files using similar code:
```
# move back one directory
cd ..

# download data
cat runids_$ACC.txt | head -5 | parallel /gpfs/group/RISE/sw7/anaconda/anaconda3/envs/seq-sra/bin/fastq-dump --split-files --outdir $RAWDIR {}
```

# Do basic quality checks

We're working with someone else's data, so let's take some time to get to know each other.
```
# list the files in the rawreads directory
ls -lh $RAWDIR

# print the first 20 lines of a file
cat FILE_1.fastq | head -20

# print the last 20 lines of a file
cat FILE_1.fastq | tail -20

# run seqkit stat on all files
seqkit stat $RAWDIR/*.fastq
```

[FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) is a tool that will help us to assess the quality of our data using multiple metrics. They have a great tutorial in addition to examples of good and bad quality Illumina data.

*Note: FastQC assumes that your data is shotgun metagenomics sequencing from Illumina. If you're working with amplicon sequences some of the quality metrics may not be applicable.*

FastQC makes several output files for each sample, so we'll create another folder to store them in.
```
# make a new directory
mkdir -p ~/scratch/seq-workshop2021/quality

# save this directory to a variable
QUALDIR=~/scratch/seq-workshop2021/quality

# run FastQC on all files
fastqc $RAWDIR/*.fastq -o $QUALDIR
```
*If you're working with many files this step can also be executed in GNU parallel*

Let's look at what FastQC produced:
``` 
ls $QUALDIR
```
There is a zip file and html file for each sample that contains information about the sample's quality. If we're working with tens or hundreds of samples, it would be really tedious to examine them all one by one!

Good news for us - there is a tool called [MultiQC](https://multiqc.info/) that aggregates all FastQC output files into one tidy HTML report.

MultiQC is easy to run: you point it to the directory with all FastQC output files and let 'er rip:
```
multiqc $QUALDIR -o . -n multiqc_$ACC
```

We're working on a secure cluster so we need to move the HTML report to a local machine to view in a web browser.
**RUN ON YOUR LOCAL TERMINAL (Windows users, skip this step)*
```
# copy to your local machine
scp YOURUSERNAME@submit.aci.ics.psu.edu:~/scratch/seq-workshop2021/multiqc_PRJNA486795.html ~/Downloads

# open in a web brower
open multiqc_PRJNA486795.html
```



