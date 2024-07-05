#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=bwa
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --nodes=1                    
#SBATCH --output=bwa.%J.out
#SBATCH --error=bwa.%J.err
module load bwa-mem2/2.1
bwa-mem2 index Tgraeca.final.assembly_scaf_more_1kb.fa
#####I merged all trimmed paired fastq files
bwa-mem2 mem -M -t 12 Tgraeca.final.assembly_scaf_more_1kb.fa ./TestuSeq_R1_trimmed.fastq ./TestuSeq_R2_trimmed.fastq | samtools sort -@12 -o Alignment_on_Tgraeca.bam
