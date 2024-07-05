#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=freebayes
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --nodes=1                    
#SBATCH --output=freebayes.%J.out
#SBATCH --error=freebayes.%J.err

module load vcflib/intel/20210217
module load vcftools/intel/0.1.16
./freebayes -f Tgraeca.final.assembly_scaf_more_1kb.fa Alignment_on_Tgraeca.bam -g 500 --genotype-qualities > Raw_calls_Tgraeca.vcf
vcfallelicprimitives -kg Raw_calls_Tgraeca.vcf | vcftools --vcf - --max-alleles 2 --remove-indels --minQ 300 --minDP 50 --maxDP 200 --minGQ 30 --mac 1 --recode --recode-INFO-all --out Filtered_calls_Tgraeca
