#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=bwa
#SBATCH --time=12:00:00
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1                      # requests 3 compute servers            # runs 2 tasks on each server
#SBATCH --output=bwa.%J.out
#SBATCH --error=bwa.%J.err
module load singularity/3.7.4

./MitoZ_v3.4.sif mitoz all  \
--outprefix Tgraeca \
--thread_number 8 \
--clade Chordata \
--genetic_code 2 \
--species_name "Testudo graeca" \
--fq1 subset1.fastq \
--fq2 subset2.fastq \
--fastq_read_length 151 \
--data_size_for_mt_assembly 0 \
--assembler megahit \
--kmers_megahit 59 79 99 119 141 \
--memory 64 \
--requiring_taxa Chordata