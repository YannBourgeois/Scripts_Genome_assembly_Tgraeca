#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --job-name=repmod
#SBATCH --time=48:00:00
#SBATCH --nodes=1                      
#SBATCH --output=repmod.%J.out
#SBATCH --error=repmod.%J.err
# database for the ref genome
singularity run docker://dfam/tetools:latest BuildDatabase -name Tgraeca Tgraeca.final.assembly_scaf_more_1kb.fa
# repeatmodeler to discover TEs de novo
singularity run docker://dfam/tetools:latest RepeatModeler -pa 16 -database Tgraeca
