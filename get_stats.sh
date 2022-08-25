#!/bin/bash
# Basic statistics of a VCF file using VCFtools

PREFIX=toy.1000GP

# 1. generate a general report of the VCF statistics
bcftools stats $PREFIX.vcf > $PREFIX.vcf-stats.vchk

# 2. Generates a file reporting the missingness on a per-individual basis. The file has the suffix ".imiss".
vcftools --vcf $PREFIX.vcf --missing-indv --out $PREFIX

# 3. Generates a file reporting the missingness on a per-site basis. The file has the suffix ".lmiss".
vcftools --vcf $PREFIX.vcf --missing-site --out $PREFIX

# 4. Generate a summary of the number of SNPs and Ts/Tv ratio for each FILTER category. The output file has the suffix ".FILTER.summary"
vcftools --vcf $PREFIX.vcf --FILTER-summary --out $PREFIX

# 5. Generate a file containing the mean depth per individual. This file has the suffix ".idepth".
vcftools --vcf $PREFIX.vcf --depth --out $PREFIX

# 6. Generate a file containing the mean depth per site averaged across all individuals. This output file has the suffix ".ldepth.mean".
vcftools --vcf $PREFIX.vcf --site-mean-depth --out $PREFIX

# 7. Calculates a measure of heterozygosity on a per-individual basis. Specfically, the inbreeding coefficient, F, is estimated for each individual using a method of moments. The resulting file has the suffix ".het"
vcftools --vcf $PREFIX.vcf --het --out $PREFIX
