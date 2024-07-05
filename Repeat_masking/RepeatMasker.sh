#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --job-name=repmod
#SBATCH --time=48:00:00
#SBATCH --nodes=1                      
#SBATCH --output=repmod.%J.out
#SBATCH --error=repmod.%J.err

module load repeatmasker/4.1.2 
famdb.py -i /share/apps/repeatmasker/4.1.2/Libraries/RepeatMaskerLib.h5 families --format fasta_name --ancestors --descendants Tetrapoda --include-class-in-name > Tetrapoda_existing_repeats.fa
cat RM_3239870.TueMar290742142022/consensi.fa.classified Tetrapoda_existing_repeats.fa > Tgraeca_combined_libs_repeatmasker.fa

####Had to create a new configuration for RepeatMasker to avoid using HMMR. See this issue: https://github.com/nextgenusfs/funannotate/issues/25 . Copied and pasted from the module and ran ./configure. Also downloaded RMBLAST executables from http://www.repeatmasker.org/RMBlast.html
./4.1.2/RepeatMasker -pa 16 -lib Tgraeca_combined_libs_repeatmasker.fa -gff -xsmall -dir ./Tgraeca_TE_prediction ./Tgraeca.final.assembly_scaf_more_1kb.fa

####After annotation, examining the repeat divergence landscape (old or new TEs?)

./4.1.2/RepeatMasker -pa 16 -a -nolow -no_is -lib Tgraeca_combined_libs_repeatmasker.fas -dir ./Tgraeca_TE_prediction_RepeatLandscape ./Tgraeca.final.assembly_scaf_more_1kb.fa
calcDivergenceFromAlign.pl -s ./Tgraeca_TE_prediction_RepeatLandscape/Tgraeca.final.assembly_scaf_more_1kb.fa.divsum ./Tgraeca_TE_prediction_RepeatLandscape/Tgraeca.final.assembly_scaf_more_1kb.fa.align
createRepeatLandscape.pl -div ./Tgraeca_TE_prediction_RepeatLandscape/Tgraeca.final.assembly_scaf_more_1kb.fa.divsum -g 2332507406 > ./Tgraeca_TE_prediction_RepeatLandscape/Tgraeca.final.assembly_scaf_more_1kb.fa.html
