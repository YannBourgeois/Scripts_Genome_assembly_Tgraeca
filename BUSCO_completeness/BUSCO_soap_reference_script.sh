#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --job-name=busco
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1                      # requests 3 compute servers            # runs 2 tasks on each server
#SBATCH --output=gapclo.%J.out
#SBATCH --error=gapclo.%J.err
module load busco/5.3.0
busco -f -c 8 -m genome -i Tgraeca.k87.kmer.scafSeq -o BUSCO_analysis_fragmented -l tetrapoda_odb10
