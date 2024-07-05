#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=eggnog
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1                     
#SBATCH --time=72:00:00                   
#SBATCH --output=eggnog.%J.out
#SBATCH --error=eggnog.%J.err
conda activate environmentYann  ###As usual, think to change this to match your HPC specs.
export EGGNOG_DATA_DIR=/scratch/yb24/EGGNOG_DATA/
export PATH=/scratch/yb24/eggnog-mapper/:$PATH
eggnog-mapper/emapper.py -i braker_restart_3/augustus.hints.aa --cpu 8 -o annotation_genes_braker_eggnog --override


