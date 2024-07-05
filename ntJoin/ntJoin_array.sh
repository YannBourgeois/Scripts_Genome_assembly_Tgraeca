#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --partition sciama2.q   ###Edit this for your own HPC (queue's ID)
#SBATCH --nodes=1
#SBATCH --job-name=ntjoin
#SBATCH --cpus-per-task=8
#SBATCH --array=1-224           ###Edit depending on the number of combinations listed in  list_combinations_ntjoin.txt
#SBATCH --nodes=1 
#SBATCH --time=12:00:00
#SBATCH --output=ntjoin.%J.out
#SBATCH --error=ntjoin.%J.err
## ***Commands starts here***

config=list_combinations_ntjoin.txt
genome=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
k=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $config)
w=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $4}' $config)

ntJoin assemble t=8 target=${genome} target_weight=1 reference_config=config_file_ntJoin k=${k} w=${w} n=2
stats.sh ${genome}.k${k}.w${w}.n2.all.scaffolds.fa > summary_stats/${genome}.k${k}.w${w}_ntjoin_.stats    ###You need BBMAP installed.
rm *.k${k}.w${w}*
