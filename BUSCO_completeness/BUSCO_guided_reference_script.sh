#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --job-name=busco
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1                     
#SBATCH --output=busco.%J.out
#SBATCH --error=busco.%J.err
module load busco/5.3.0   ###again, think to edit this to suit your HPC.
busco -f -c 8 -m genome -i Tgraeca.final.assembly_scaf_more_1kb.fa -o BUSCO_analysis -l tetrapoda_odb10