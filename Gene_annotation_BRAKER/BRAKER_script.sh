#!/bin/bash
#SBATCH --mem=128GB
#SBATCH --job-name=braker
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1                      
#SBATCH --time=96:00:00                     
#SBATCH --output=braker.%J.out
#SBATCH --error=braker.%J.err

### Below are some comments to set up the Augustus configuration, this is shown here for information, but is very likely to be different or not needed on your system. Lots of trials and errors here.

conda activate environmentYann
export PATH=/scratch/yb24/Augustus/bin:/scratch/yb24/Augustus:$PATH
export AUGUSTUS_CONFIG_PATH=/scratch/yb24/Augustus/config/
###Diamond
export DIAMOND_PATH=/scratch/yb24/Augustus/
export PATH="/home/yb24/.conda/envs/environmentYann/bin/perl:$PATH"
module load lp_solve/intel/5.5.2.9
module load gsl/intel/2.6
module load boost/intel/1.74.0
module load suitesparse/intel/5.8.1
module load mysqlplusplus/intel/3.2.5
rm -r /scratch/yb24/braker/



####Run BRAKER for gene prediction 
./BRAKER/scripts/braker.pl --PYTHON3_PATH=/home/yb24/.conda/envs/environmentYann/bin/ --GENEMARK_PATH=/scratch/yb24/gmes_linux_64_4/ --PROTHINT_PATH=/scratch/yb24/ProtHint/bin --genome=Tgraeca_TE_prediction/Tgraeca.final.assembly_scaf_more_1kb.fa.masked --prot_seq=all_vertebrate_proteins_with_Gopherus.fa --softmasking
