### Introduction

This file contains the commands used to generate a reference-guided, de novo assembly of Testudo graeca from paired-end short reads. Reads and the obtained reference genome are part of the BioProject PRJNA1086345.
Most of these commands are contained in bash scripts (.sh) that can be submitted on a HPC cluster. It is important to inspect the files to perform a few minor edits, depending on which combinations of k-mers or input files you need.
Pay particular attention to the number of job arrays, memory, number of cores, and think to add or edit the names of the queues, which will almost certainly differ.
Below are a few links to the Github pages of the methods used here. 

**SOAPec**
https://sourceforge.net/projects/soapdenovo2/files/ErrorCorrection/

**SOAPdenovo2**
https://github.com/aquaskyline/SOAPdenovo2

**ntJoin**
https://github.com/bcgsc/ntJoin

**RepeatModeler/RepeatMasker**
https://github.com/Dfam-consortium
https://www.repeatmasker.org/

**BRAKER** (note that the latest version is easier to use, there is no need for a key for GENEMARK anymore).
https://github.com/Gaius-Augustus/BRAKER

**FreeBayes**
https://github.com/freebayes/freebayes

**MSMC2**
https://github.com/stschiff/msmc2

**MitoZ**
https://github.com/linzhi2013/MitoZ

You can install most of them through anaconda/mamba, by creating an environment. Below is an example for ntJoin:

```
conda create --name ntjoin
conda activate ntjoin
conda install -c bioconda -c conda-forge ntjoin=1.0.8
```
Just think to activate the relevant environment before launching the commands.

### About the data.

The FASTQC reports (included in AllGenetics results) show a very high quality: almost no adapters, quality drops marginally at the end of the reads.
There are several genomes available, but the best one (though only second-closest relative after *Chelonoidis abingdonii*) is the chromosome-level assembly of Gopherus evgoodei, available here:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/007/399/415/GCF_007399415.2_rGopEvg1_v1.p/

### Read cleaning.

Before assembly, we need to trim the reads and remove adapters. We also need to merge overlapping reads. We use PEAR for this.
First, we divide the initial sequence reads into five smaller pairs of files for forward and reverse reads. We use biopet-fastqsplitter, which can be installed through conda in a local environment.

```
conda install -c bioconda biopet-fastqsplitter
biopet-fastqsplitter -I ./Raw_Data/TestuSeq_R1.fastq -o Read_1_aa.fastq -o Read_1_ab.fastq -o Read_1_ac.fastq -o Read_1_ad.fastq -o Read_1_ae.fastq
biopet-fastqsplitter -I ./Raw_Data/TestuSeq_R2.fastq -o Read_2_aa.fastq -o Read_2_ab.fastq -o Read_2_ac.fastq -o Read_2_ad.fastq -o Read_2_ae.fastq

```
We then launch an array job on a HPC cluster. We assume that you have a SLURM scheduler. The script is found in the trim_and_merge_reads.sh. 
You also need a config file (tab delimited) for the array script, containing in the first column the identifier of the array (from 1 to 5 here). It is named file_for_array_trim.txt.


```
sbatch trim_and_merge_reads.sh

```

### Read correction.

We now correct reads with SOAPEc. Even after filtering, there are errors remaining, which can slow down SOAPdenovo2 quite a lot. SOAPEc looks at rare k-mers ("words") and assigns them to the closest frequent one.
A tutorial on SOAPEc can be found here: http://gaap.hallym.ac.kr/Gaap02



```
sbatch read_correction_script_SOAPEC.sh

```


### Assembly with short reads (SOAPdenovo2).


We unzip the fastq files listed in config

```
ls *fq.gz -d | nl -w2 > list_fastqgz.txt
sbatch unzip_fastq.sh

```


There is a file with the list of kmer values to test in kmer_list_array.txt. The SOAPdenovo configuration file is config_soap.txt.
We can launch the SOAPdenovo script over these k-mer values. Note that we set the -d parameter to delete all kmers with frequency 2 or below

```
sbatch SOAPdenovo_array.sh
```


### ntJoin (guided scaffolding).

Once we have these draft assemblies, we use the software ntJoin, which will map back the scaffolds to the Gopherus evgoodei reference and order them

```
ls Cluster_* -d | > list_alignments.txt ###generates the list with a column with task ids and a column with the files to align.


for genome in Tgraeca.k*.scafSeq
do
for w in 100 250 500 1000
do
for k in 16 24 32 40 48 56 64
do
echo -e $genome"\t"$k"\t"$w >> list_combinations_ntjoin.txt
done
done
done
nl -w2 list_combinations_ntjoin.txt > list_combinations_ntjoin.txt2;mv list_combinations_ntjoin.txt2 list_combinations_ntjoin.txt

```

We can now launch ntJoin over a range of work sizes and k-mer values.

```
mkdir summary_stats 
sbatch ntJoin_array.sh

```

This will be relatively quick (a few minutes/hours). We collect assembly statistics with stats.sh from the bbmap suite. All results are in a file named statistics_genomes_scaffolded.txt, found in a summary_stats folder.
The following script can collect a few statistics such as GC content, or N/L50.

```
for stats in summary_stats/*
do
echo $stats >> col1
grep gap $stats >> col2
grep -A1 GC_stdev $stats | tail -n1 >> col3
grep " contig N/L50" $stats >> col4
done

paste col1 col2 col3 col4 | sed "s:%::" > summary_stats.txt

rm col*
for stats in summary_stats/*
do
echo $stats >> col1
grep -w "All" $stats  |  cut -f5,6 | sed "s:%::"  | sed "s:,::g" >> col2
done

sed "s:summary_stats/Tgraeca.k::" col1 | sed "s:.kmer.scafSeq.k:\t:" | sed "s:\.w:\t:" | sed "s:_ntjoin_.stats::" | paste - col2 > summary_stats_contiglength.txt

```

### Gap closing

First we reformat the assembly to remove the shortest scaffolds (shorter than 1000bp).We use the reformat.sh script from BBMAP.

```
reformat.sh -Xmx32G in=Tgraeca.k87.kmer.scafSeq.k24.w100.n2.all.scaffolds.fa out=Tgraeca_ntJoin_to_close.fa minlength=1000
sbatch script_GapCloser.sh

```
  
### BUSCO analysis

We use the set of conserved tetrapoda genes to evaluate contiguity for the ntJoin and raw SOAPdenovo assemblies.

```
sbatch BUSCO_guided_reference_script.sh
sbatch BUSCO_soap_reference_script.sh

```


### Mask repeats in the genome (RepeatModeler/Masker)

We launch two scripts here. The first one launches RepeatModeler to identify repeats and transposable elements (TEs) de novo. 
The second one launches RepeatMasker to mask the genome for the repeats identified at the first step, as well as known repeats identified in other taxa.

```
sbatch RepeatModeler.sh

sbatch RepeatMasker.sh

```
This will also produce a graphic with the Repeat landscape and the Kimura divergence, an approximation of TEs age.

More info about generating a repeat landscape:: https://littlebioinformatician.wordpress.com/scripts/repeat-landscape/


### Gene annotation

We need the masked genome for this. We also need a database of vertebrates proteins since we do not have any information for our species of interest. 
The masked genome from previous steps is in Tgraeca_TE_prediction/Tgraeca.final.assembly_scaf_more_1kb.fa.masked

We can use proteins from the high quality Gopherus genome in addition to vertebrate prots, and apply BRAKER pipeline #C

```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/007/399/415/GCF_007399415.2_rGopEvg1_v1.p/GCF_007399415.2_rGopEvg1_v1.p_protein.faa.gz
gunzip GCF_007399415.2_rGopEvg1_v1.p_protein.faa.gz
###vertebrates proteins
wget https://v100.orthodb.org/download/odb10_vertebrata_fasta.tar.gz
cat vertebrate/Rawdata/*  GCF_007399415.2_rGopEvg1_v1.p_protein.faa > all_vertebrate_proteins_with_Gopherus.fa
git clone https://github.com/Gaius-Augustus/BRAKER.git
wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_FO3MM/gmes_linux_64_4.tar.gz
```

For the version of BRAKER we used, GENEMARK needed a key.
It changed recently, the key is not needed anymore. If you are reusing these scripts, it should be much easier.

```
sbatch BRAKER_script.sh

```

Annotation with EggNog https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.1.5-to-v2.1.7
This gives us a file where each BRAKER gene associated with a protein gets a list of GO terms and an annotation (e.g. gene name)

```
download_eggnog_data.py --data_dir /scratch/yb24/EGGNOG_DATA
sbatch Eggnog_annotation_GOterms.sh

```



### Demographic analysis (MSMC2)

We first need to realign the reads to the reference genome before running MSMC, so we can call heterozygous sites which are needed by the algorithm.

First we align the short reads to the reference genome we just generated:
```
sbatch Alignment_BWA.sh
```

Next, we obtain the depth of coverage along the genome, to exclude regions with poor mapping.
```
sbatch Obtain_depth_coverage.sh
```

We mask repetitive regions from the genome with genmap (https://github.com/cpockrandt/genmap)

```
sbatch genmap.sh
```

At last, we obtain SNP variants with Freebayes, and filter them.

```
sbatch SNP_calling_freebayes.sh
```

What follows is an example of MSMC2 inference on chromosome 1.
First we generate the mask files to exclude regions of poor mappability/low depth.
```
vcftools --vcf Filtered_calls_Tgraeca.recode.vcf --chr ntJoin0 --out ntJoin --recode --recode-INFO-all
grep -w ntJoin0 output_genmap.bed | awk '{ if ($5 == 1) { print } }' | cut -f1,2,3 > genmap_ntJoin0.mask

awk '{ if ($4 < 10) { print } }' depth_of_coverage_T_graeca.bedgraph > low_depth_regions_Tgraeca.bedgraph
grep -w ntJoin0 low_depth_regions_Tgraeca.bedgraph > ntJoin0.negative.mask

./msmc-tools/generate_multihetsep.py --negative_mask=ntJoin0.negative.mask.gz --mask=genmap_ntJoin0.mask.gz ntJoin.recode.vcf.gz > input_MSMC_ntJoin0.txt
```

The command for MSMC2 inference. For multiple chromosomes, just provide the other chromosome files after ntJoin0_MSMC2 input_MSMC_ntJoin0.txt.

```

./msmc2_linux64bit --fixedRecombination -o ntJoin0_MSMC2 input_MSMC_ntJoin0.txt -t 12

```
We can obtain confidence intervals with bootstrapping. Consider using an array SLURM job to speed up inference.

```
./msmc-tools/multihetsep_bootstrap.py -n 100 bootstrap_ntJoin0 --nr_chromosomes 1 input_MSMC_ntJoin0.txt

for i in bootstrap_ntJoin0_*
do
./msmc2_linux64bit --fixedRecombination -o $i $i/bootstrap_multihetsep.chr1.txt -t 12 
done
split -l5 tosplit_MSMC_boot.sh boot_MSMC.sh

```

### Obtain the mitogenome

We use MitoZ. We use singularity to download a container for v3.4. We only take a subset of 10 million reads (subset1.fastq and subset2.fastq).


```

head -n 40000000 ./TestuSeq_R1.fastq > subset1.fastq
head -n 40000000 ./TestuSeq_R2.fastq > subset2.fastq

singularity pull MitoZ_v3.4.sif docker://guanliangmeng/mitoz:3.4
sbatch MitoZ_job.sh
```




