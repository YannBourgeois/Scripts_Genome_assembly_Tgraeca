#!/bin/bash 
#SBATCH --mem=100GB
#SBATCH --job-name=trim
#SBATCH --time=48:00:00
#SBATCH --output=trim.%J.out
#SBATCH --error=trim.%J.err
#SBATCH --array=1-5       # You may also need to specify a queue with SBATCH --partition

module load trimmomatic/0.39

config=file_for_array_trim.txt

i=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

java -jar $TRIMMOMATIC_JAR PE Read_1_${i} Read_2_${i} \
trimmed_Read_1_${i} \
trimmed_unpaired_Read_1_${i} \
trimmed_Read_2_${i} \
trimmed_unpaired_Read_2_${i} ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:1 LEADING:5 TRAILING:5 MINLEN:40 AVGQUAL:28
./pear -f trimmed_Read_1_${i} -r trimmed_Read_2_${i} -o merged_reads_${i}

