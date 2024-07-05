#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=cov
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --nodes=1                    
#SBATCH --output=cov.%J.out
#SBATCH --error=cov.%J.err
module load bedtools/intel/2.29.2
bedtools genomecov -ibam Alignment_on_Tgraeca.bam -bg > depth_of_coverage_T_graeca.bedgraph
awk '{ if ($4 < 10) { print } }' depth_of_coverage_T_graeca.bedgraph > low_depth_regions_Tgraeca.bedgraph
