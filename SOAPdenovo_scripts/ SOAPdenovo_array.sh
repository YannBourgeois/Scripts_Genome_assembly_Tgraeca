#!/bin/bash
#SBATCH --mem=200GB
#SBATCH --job-name=soap
#SBATCH --time=96:00:00
#SBATCH --ntasks-per-node=9
#SBATCH --nodes=2         # requests 2 nodes, 9 tasks per node, 18 threads (-p 18)
#SBATCH --array=1-11          
#SBATCH --output=soap.%J.out
#SBATCH --error=soap.%J.err

config=kmer_list_array.txt
KMER=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

./SOAPdenovo-127mer all -s config_soap.txt -o Tgraeca.k${KMER}.kmer -d 2 -K ${KMER} -N 2500000000 -p 18