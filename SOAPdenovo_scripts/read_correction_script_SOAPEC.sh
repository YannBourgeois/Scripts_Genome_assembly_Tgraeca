#!/bin/bash 
#SBATCH --mem=100GB
#SBATCH --job-name=kmerfreq
#SBATCH --time=48:00:00
#SBATCH --output=kmer.%J.out
#SBATCH --error=kmer.%J.err
module load trimmomatic/0.39  ###Edit/adjust this before using on yout own cluster

###list fastq reads in working directory after PEAR (remove initial trimmed reads and empty fastq)

ls *fastq > list_all_reads.txt

####default overlap in PEAR is 10bp, so max length of merged reads should be something like 151+151-10=292
./SOAPec_bin_v2.03/bin/KmerFreq_HA -k 27 -l list_all_reads.txt -p Tgraeca -t 32 -L 292 

#### Paired-end error corrector (reads not merged by PEAR)
ls *unassembled*fastq > PE_reads_list.txt 
./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 Tgraeca.freq.gz PE_reads_list.txt

### Single-end error corrector:  (j 0)
###List of SE reads in SE_reads_list.txt
./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -j 0 -l 3 -t 32 Tgraeca.freq.gz SE_reads_list.txt 


#####The correction step can also be parallelized if needed.

## ls *aa*unassembled*fastq > PE_reads_list_subsetaa
## ls *ab*unassembled*fastq > PE_reads_list_subsetab
## ls *ac*unassembled*fastq > PE_reads_list_subsetac
## ls *ad*unassembled*fastq > PE_reads_list_subsetad
## ls *ae*unassembled*fastq > PE_reads_list_subsetae
## 
## ./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 ./Tgraeca.freq.gz PE_reads_list_subsetaa
## ./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 ./Tgraeca.freq.gz PE_reads_list_subsetab
## ./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 ./Tgraeca.freq.gz PE_reads_list_subsetac
## ./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 ./Tgraeca.freq.gz PE_reads_list_subsetad
## ./SOAPec_bin_v2.03/bin/Corrector_HA -k 27 -l 3 -t 32 ./Tgraeca.freq.gz PE_reads_list_subsetae
