#!/bin/bash
# Copyright Juliana Acosta-Uribe & Ada Madejska. University of California Santa Barbara
# 2022

# This script is an overview of the soft quality control steps

## Files with the data you want to QC
PREFIX_raw = 'joint_colombia_annotated.hg38' #PREFIX of the raw dataset. Should be a vcf.gz
PREFIX_autosomes = 'joint_colombia_annotated.hg38.autosomes' #PREFIX of the dataset with only autosome data. 


## STEP 1.a: SOFT QC=====================================================================================

### Get rid of any sites and individuals with high missing data before we make a decision about QC thresholds.

###Indentify individuals with missingness >10%
awk '{$5>0.1 print$1}' $PREFIX_raw.imiss > individuals_highmissingness.txt

### Missingness >= 10% ( --max-missing float is a 0-1range. 0 allows sites that are completely missing 
### and 1 indicates no missing data allowed)

vcftools --gzvcf $PREFIX_autosomes.vcf.gz --remove individuals_highmissingness.txt --max-missing 0.9 \
--recode --recode-INFO-all --stdout | gzip -c > $PREFIX_autosomes.miss.vcf.gz


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




## Separate the raw dataset into autosomes and sex chromosomes

### Extract autosomes
vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chr1 --chr chr2 --chr chr3 \
--chr chr4 --chr chr5 --chr chr6 --chr chr7 --chr chr8 --chr chr9 --chr \
chr10 --chr chr11 --chr chr12 --chr chr13 --chr chr14 --chr chr15 --chr chr16 \
--chr chr17 --chr chr18 --chr chr19 --chr chr20 --chr chr21 --chr chr22 \
--recode --recode-info-all --stdout | gzip -c > $PREFIX_autosomes.vcf.gz

### Extract chrX and chrY
vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chrX --recode --recode-info-all --stdout | gzip -c > $PREFIX_raw.chrX.vcf.gz
vcftools --gzvcf $PREFIX_raw.vcf.gz --chr chrY --recode-info-all --stdout | gzip -c > $PREFIX_raw.chrY.vcf.gz
