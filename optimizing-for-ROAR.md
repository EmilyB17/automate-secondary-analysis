# Optimize batch scripts for submission to the PSU ROAR clusters

Check out these resources:
[ROAR User's Guide](https://www.icds.psu.edu/computing-services/roar-user-guide/)

## Step 0: Optimize your script in an interactive session

You can work on the RHEL7 interactive desktop or on a terminal. If you're in a terminal, start an interactive session by first logging onto ACI-B:
```
ssh YOURUSERNAME@submit.aci.ics.psu.edu
```

Then, start an interactive session with `qsub -I`. You will need to specify all the normal parameters (memory, walltime, nodes... see below!)

## Step 1: Resource allocation

If you are not working in parallel, you do not need to request multiple nodes. If you're parallel computing, you know more than I do and you should be writing this tutorial.
```
# request only one node
#PBS -l nodes=1:ppn=1
```

Most of us (me) request way too much memory simply because we can, but this is a waste of resources and can cause your job to sit in the queue. Run a small subset of your pipeline in an interactive session and use `qstat -f JOBID` while it's running to gauge the memory that it's using in real time. 
Then, request an appropriate amount of RAM:
```
#PBS -l pmem=4gb
```
*Pro tip: if your job is terminated with Kill signal 9, that is almost always because it's run out of memory allocation and needs more RAM*

### RAM in multiple nodes
The total amount of RAM is the pmem * ppn * nodes. If you request `pmem=4gb` and `nodes=1:ppn=1`, your total amount of memory is 4GB. If you request `pmem=4gb` and `nodes=1:ppn=10`, your total amount of memory is 40GB.

## Step 2: Pick an allocation

Most of us work on the open queue, simply:
```
#PBS -A open
```
If you work in an allocation, use ```#PBS -A your-allocation-name```

### Step 3: Pick a walltime (time limit for your job to run)

Similarly to deciding how much memory to request, run a small subset of your data to determine an appropriate walltime. I always add a buffer to make sure it won't run out of time, but keep in mind that asking for more walltime can cause your job to sit in the queue for longer.
This would request 3 hours of walltime:
```
#PBS -l walltime=3:00:00
```

### Step 4: Choose your notification and log settings

PBS has several options for email notifications. Common options are a for abort, b for begin, and e for end. The following code chunk would email me when a job ends (or is terminated) and sends an email to the address.
```
#PBS -m e
#PBS -M MYEMAIL@email.com
```

Each script will maintain a log of sterr and stout. You can choose to receive the sterr and stout messages separately or concatenated into one logfile, and you can also set the output file of the log. If you don't specify an output file, the log will write to `$PBS_O_WORKDIR` (the directory that you submitted the job from).

This script writes one log of both error and output:
```
#PBS -j oe
```
While this writes a separate file with a path:
```
#PBS -o myoutput.log
#PBS -e myerror.log
```

### Step 5: Put it all together

Here's what a job submission script might look like! Can you tell what each line is requesting?
```
#!/bin/bash

#PBS -N myscriptname
#PBS -A open
#PBS -l walltime=3:00:00
#PBS -l nodes=1:ppn=1
#PBS -l pmem=2gb
#PBS -j oe
#PBS -m e
#PBS -M myemail@email.com

## START MY SCRIPT
conda activate r_env
Rscript my-script.R
```

### Get it running

To submit your job to the job scheduler, use `qsub`:
```
# you can submit a PBS script
qsub MYJOB.pbs

# or a shell script
qsub MYJOB.sh
```

After you submit the job use `qstat` to check in on the status:
```
qstat -u YOURUSERNAME
```

Or, use `qstat` to get information about the job once it's running:
```
qstat -f JOBID
```

