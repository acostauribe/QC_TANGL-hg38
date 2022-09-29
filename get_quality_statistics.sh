#!/bin/bash
# Basic statistics of a VCF file using VCFtools and BCFtools
# Copyright Juliana Acosta-Uribe. University of California Santa Barbara

# Specify the prefix of your RAW data file
# e.g. for file.vcf.gz use PREFIX=file

PREFIX=file

## a. Data description 
bcftools stats $PREFIX.vcf.gz > $PREFIX.vchk
# General distribution of depth, missingness, heterozygosity

vcftools --gzvcf $PREFIX.vcf.gz --FILTER-summary --out $PREFIX.PRE-QC
# Generate a summary of the number of SNPs and Ts/Tv ratio for each FILTER category. 
# The output file has the suffix ".FILTER.summary"

## b. Site missingness 
vcftools --gzvcf $PREFIX.vcf.gz --missing-site --out $PREFIX.PRE-QC
# Generate a file reporting the missingness on a per-site basis. 
# The file has the suffix ".lmiss".

## c. Individual missingness
vcftools --gzvcf $PREFIX.vcf.gz --missing-indv --out $PREFIX.PRE-QC
# Generate a file reporting the missingness on a per-individual basis. 
# The file has the suffix ".imiss".

## d. Site depth
vcftools --gzvcf $PREFIX.vcf.gz --site-mean-depth --out $PREFIX.PRE-QC
# Generate a file containing the mean depth per site across all individuals. 
# This output file has the suffix ".ldepth.mean"

## e. Individual depth 
vcftools --gzvcf $PREFIX.vcf.gz --depth --out $PREFIX.PRE-QC
# Generate a file containing the mean depth per individual. 
# This file has the suffix ".idepth".

## f. Individual heterozygosity 
vcftools --gzvcf $PREFIX.vcf.gz --het --out $PREFIX.PRE-QC
# Inbreeding coefficient, F, is estimated for each individual using a method of moments. 
# The resulting file has the suffix ".het"


#### CHECKPOINT #At the end of the "Quality report" you should have the 7 following files:
#$PREFIX.vchk
#$PREFIX.FILTER.summary
#$PREFIX.lmiss
#$PREFIX.imiss
#$PREFIX.ldepth.mean
#$PREFIX.idepth
#$PREFIX.het
