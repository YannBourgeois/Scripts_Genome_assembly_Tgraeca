#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=genmap
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --nodes=1                    
#SBATCH --output=genmap.%J.out
#SBATCH --error=genmap.%J.err
cut -f1 -d " " Tgraeca.final.assembly_scaf_more_1kb.fa > Tgraeca.final.assembly_scaf_more_1kb_for_genmap.fa
genmap index -F Tgraeca.final.assembly_scaf_more_1kb_for_genmap.fa -I index_genmap
##around one hour and ten minutes to complete. Max 2 mismatches/read.
genmap map -E 2 -K 151 -I index_genmap -T 16 -O output_genmap -t -w -b
