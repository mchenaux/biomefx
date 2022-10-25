#!/bin/bash

# Cutadapt

# source conda
source /z/home/lvn/miniconda3/etc/profile.d/conda.sh

# activate cutadapt environment
conda activate /z/home/lvn/miniconda3/envs/cutadapt

raw_fastq_dir="/z/datasets/ds_microbiomics_oh/BiomeFX_MVP/data/biomefx_May2021"
cutadapt_outputdir="/z/datasets/ds_microbiomics_oh/BiomeFX_MVP/analyses/cutadapt/biomefx_May2021"
mkdir $cutadapt_outputdir

echo "raw fastqs" $raw_fastq_dir
echo "cutadapt out" $cutadapt_outputdir

cutadapt -a CTGTCTCTTATACACATCT -g AGATGTGTATAAGAGACAG -j 1 -q 20,20 --max-n 0 -m 50 --max-ee 1 -o $cutadapt_outputdir/`basename $1 .fastq.gz`_trimmed.fastq.gz $raw_fastq_dir/$1

# Humann3.6

# activate humann environment
conda activate /z/home/lvn/miniconda3/envs/humann3.6

humann_outputdir="/z/datasets/ds_microbiomics_oh/BiomeFX_MVP/analyses/humann3.6/biomefx_May2021"

mkdir $humann_outputdir
echo "humann out" $humann_outputdir

humann -i $cutadapt_outputdir/`basename $1 .fastq.gz`_trimmed.fastq.gz -o $humann_outputdir \
--threads 8 --memory-use maximum --input-format 'fastq.gz' \
--metaphlan-options "--bowtie2db /z/datasets/ds_mbiomics_databases/metaphlan4/ --index mpa_vJan21_CHOCOPhlAnSGB_202103 --stat_q 0.1 --add_viruses --unclassified_estimation --biom $1.biom"

#humann_rename_table

for FILE in $humann_outputdir/*genefamilies.tsv; do
	if test -f "$FILE"; then
		NAMEFILE=$(sed 's/.tsv/_named.tsv/g' <<< $FILE)
        echo $NAMEFILE
         humann_rename_table --input $FILE  --names uniref90 --output $NAMEFILE
     fi   
done  

#humann_renorm_table

for FILE in $humann_outputdir/*genefamilies_named.tsv; do
      if test -f "$FILE"; then
        NORMFILE=$(sed 's/.tsv/_norm.tsv/g' <<< $FILE)
        echo $FILE 
        echo $NORMFILE
         humann_renorm_table --input $FILE  --output $NORMFILE  --units relab  
     fi   
done

for FILE in $humann_outputdir/*pathabundance.tsv; do
      if test -f "$FILE"; then
        NORMFILE=$(sed 's/.tsv/_norm.tsv/g' <<< $FILE)
        echo $NORMFILE
         humann_renorm_table --input $FILE  --output $NORMFILE  --units relab  
     fi   
    done

