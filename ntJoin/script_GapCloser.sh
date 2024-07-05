#!/bin/bash
#SBATCH --mem=100GB
#SBATCH --job-name=gapcloser
#SBATCH --time=72:00:00
#SBATCH --ntasks-per-node=9
#SBATCH --nodes=2                      
#SBATCH --output=gapclo.%J.out
#SBATCH --error=gapclo.%J.err
conda activate environmentYann
GapCloser -a Tgraeca_ntJoin_to_close.fa -b config_gapcloser.txt -o Tgraeca.final.assembly.gaps.closed.fa -l 151 -t 16
