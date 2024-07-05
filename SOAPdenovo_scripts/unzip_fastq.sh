#!/bin/bash
#SBATCH --mem=6GB
#SBATCH --job-name=gunzip
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --array=1-30           
#SBATCH --output=gunzip.%J.out
#SBATCH --error=gunzip.%J.err
config=list_fastqgz.txt
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
gunzip $SAMPLE