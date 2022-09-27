#!/bin/bash
# Copyright Juliana Acosta-Uribe, Ada Madejska. University of California Santa Barbara

# This script is an overview of the pre-quality control commands used to analyze the dataset. 

# STEP 0: SET UP DATA AND VARIABLES 
# STEP 1: SOFT QC
# STEP 2: GENERAL REPORT OF PRE QC STATISTICS


## STEP 0: SET UP DATA AND VARIABLES===================================================================

## Files with the data you want to QC
PREFIX_raw = 'joint_colombia_annotated.hg38' #PREFIX of the raw dataset. Should be a vcf.gz
PREFIX_autosomes = 'joint_colombia_annotated.hg38.autosomes' #PREFIX of the dataset with only autosome data. 

## Separate the raw dataset into autosomes and sex chromosomes

### Extract autosomes
vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chr1 --chr chr2 --chr chr3 --chr chr4 --chr chr5 --chr chr6 --chr chr7 --chr chr8 --chr chr9 --chr chr10 --chr chr11 --chr chr12 --chr chr13 --chr chr14 --chr chr15 --chr chr16 --chr chr17 --chr chr18 --chr chr19 --chr chr20 --chr chr21 --chr chr22 --recode --out $PREFIX_autosomes
bgzip $PREFIX_autosomes.recode.vcf
mv $PREFIX_autosomes.recode.vcf.gz $PREFIX_autosomes.vcf.gz

### Extract chrX and chrY
vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chrX --recode --out $PREFIX_raw.chrX
mv $PREFIX_raw.chrX.recode.vcf $PREFIX_raw.chrX.vcf
bgzip $PREFIX_raw.chrX.vcf

vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chrY --recode --out $PREFIX_raw.chrY
mv $PREFIX_raw.chrY.recode.vcf $PREFIX_raw.chrY.vcf
bgzip $PREFIX_raw.chrY.vcf

## STEP 1: SOFT QC=====================================================================================
### Get rid of any extreme outliers before we make a decision about QC thresholds.
### Missingness >= 10% ( --max-missing float is a 0-1range. 0 allows sites that are completely missing 
###                      and 1 indicates no missing data allowed)

vcftools --gzvcf $PREFIX_autosomes.vcf.gz --max-missing 0.9 --recode --recode-INFO-all --out $PREFIX_autosomes.vcf.gz.miss
mv $PREFIX_autosomes.vcf.gz.miss $PREFIX_autosomes.miss.vcf
bgzip $PREFIX_autosomes.miss.vcf

## STEP 2: GENERAL REPORT OF PRE QC STATISTICS OF AUTOSOMES============================================

### a. Data description 
bcftools stats $PREFIX_autosomes.miss.vcf.gz > $PREFIX_autosomes.miss.vchk
# General distribution of depth, missingness, heterozygosity

vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --FILTER-summary --out $PREFIX_autosomes.miss.PRE-QC
# Generate a summary of the number of SNPs and Ts/Tv ratio for each FILTER category. 
# The output file has the suffix ".FILTER.summary"

### b. Site missingness 
vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --missing-site --out $PREFIX_autosomes.miss.PRE-QC
# Generate a file reporting the missingness on a per-site basis. 
# The file has the suffix ".lmiss".

### c. Individual missingness
vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --missing-indv --out $PREFIX_autosomes.miss.PRE-QC
# Generate a file reporting the missingness on a per-individual basis. 
# The output file has the suffix ".imiss".

### d. Site depth
vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --site-mean-depth --out $PREFIX_autosomes.miss.PRE-QC
# Generate a file containing the mean depth per site across all individuals. 
# This output file has the suffix ".ldepth.mean"

### e. Individual depth 
vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --depth --out $PREFIX_autosomes.miss.PRE-QC
# Generate a file containing the mean depth per individual. 
# This file has the suffix ".idepth".

### f. Individual heterozygosity 
vcftools --gzvcf $PREFIX_autosomes.miss.vcf.gz --het --out $PREFIX_autosomes.miss.PRE-QC
# Inbreeding coefficient, F, is estimated for each individual using a method of moments. 
# The resulting file has the suffix ".het"