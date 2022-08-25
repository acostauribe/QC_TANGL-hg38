#!/bin/bash
# Copyright Juliana Acosta-Uribe. University of California Santa Barbara
# ReDLat 2022

# This script is an overview of the quality control preocesses that were done for the ReD-Lat Exomes. But it can be manipulated to fit any other dataset

# STEP 0: SET UP DATA AND VARIABLES 
# STEP 1: GENERAL REPORT OF PRE QC STATISTICS
# STEP 2: CHROMOSOMAL SEX CHECK
# STEP 3: SITE QUALITY FILTERING 
# STEP 4: INDIVIDUAL QUALITY FILTERING 
# STEP 5: GENERATE PLINK FILES 
# STEP 6: RELATIONSHIP INFERENCE AND MENDEL ERRORS
# STEP 7: STRINGENT MISSINGNESS QC 
# STEP 8: GENERAL REPORT OF POST QC STATISTICS
# STEP 9: PRINCIPAL COMPONENT ANALYSIS TO DETECT BATCH EFFECTS


## STEP 0: SET UP DATA AND VARIABLES=========================================================

## Files with the data you want to QC
RAW_dataset = 'ADFTD.vqsr.snp.indel' #PREFIX of the raw dataset. Should be a vcf.gz
PREFIX = 'ReDLat' #PREFIX of the name you want to use from now on

## Path to the 1000GP data file
1000GPfile = "path" 

## Information for plink .fam file
new_sex = 'RedLat_sex.txt' #txt file, each line has three fields 'vcf-id', 'vcf-id', 'Sex code' ('1' = male, '2' = female, '0' = unknown)
new_id = 'RedLat_id.txt' #txt file, each line has four fields 'vcf-id', 'vcf-id', Family ID ('FID'), Within-family ID ('IID'; cannot be '0')
new_pheno = 'RedLat_pheno.txt' #txt file, each line has three fields 'FID', 'IID', phenotype ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data)
new_parents = 'RedLat_parents.txt' #txt file, each line has four fields 'FID', 'IID', New paternal within-family ('PID'), New maternal within-family ('MID')

## Files that need to be generated manually and will be needed for individual QC
flagged_samples_vcf = 'ReDLat_flagged_vcf.txt' #txt file, each line has the VCF id of the sample that failed a QC step in STEP 1
'Failed-relatedness.txt'

## Extract the exome targets from the raw sequencing data (.bed file dowloaded from IDT website for xGen™ Exome Hybridization Panel v2)
vcftools --gzvcf $RAW_dataset.vcf.gz --bed xgen-exome-research-panel-v2-targets-hg38.bed --recode --recode-INFO-all --out $PREFIX
mv $PREFIX.recode.vcf $PREFIX.vcf
bgzip $PREFIX.vcf

mkdir 0.Raw_data
mv $RAW_dataset.* ./0.Raw_data
mv xgen-exome-research-panel-v2-targets-hg38.bed ./0.Raw_data


## STEP 1: GENERAL REPORT OF PRE QC STATISTICS=========================================================

### a. Data description 
bcftools stats $PREFIX.vcf.gz > $PREFIX.vchk
# General distribution of depth, missingness, heterozygosity

vcftools --gzvcf $PREFIX.vcf.gz --FILTER-summary --out $PREFIX.PRE-QC
# Generate a summary of the number of SNPs and Ts/Tv ratio for each FILTER category. 
# The output file has the suffix ".FILTER.summary"

### b. Site missingness 
vcftools --gzvcf $PREFIX.vcf.gz --missing-site --out $PREFIX.PRE-QC
# Generate a file reporting the missingness on a per-site basis. 
# The file has the suffix ".lmiss".

### c. Individual missingness
vcftools --gzvcf $PREFIX.vcf.gz --missing-indv --out $PREFIX.PRE-QC
# Generate a file reporting the missingness on a per-individual basis. 
# The output file has the suffix ".imiss".
# Individuals whose mean depth is > should be added to 'flagged_samples' file

### d. Site depth
vcftools --gzvcf $PREFIX.vcf.gz --site-mean-depth --out $PREFIX.PRE-QC
# Generate a file containing the mean depth per site across all individuals. 
# This output file has the suffix ".ldepth.mean"

### e. Individual depth 
vcftools --gzvcf $PREFIX.vcf.gz --depth --out $PREFIX.PRE-QC
# Generate a file containing the mean depth per individual. 
# This file has the suffix ".idepth".
# Individuals whose mean depth is <20 should be added to 'flagged_samples' file

### f. Individual heterozygosity 
vcftools --gzvcf $PREFIX.vcf.gz --het --out $PREFIX.PRE-QC
# Inbreeding coefficient, F, is estimated for each individual using a method of moments. 
# The resulting file has the suffix ".het"
# Individuals whose heterozygosity deviated more than 3 SD from the man should be added to 'flagged_samples' file

#### CHECKPOINT #At the end of the "General report" you should have  at least the 7 following files:
#$PREFIX.vchk
#$PREFIX.FILTER.summary
#$PREFIX.lmiss
#$PREFIX.ldepth
#$PREFIX.imiss
#$PREFIX.het
#$PREFIX.idepth

### Store the files of this step on a directory of their own
mkdir 1.General_Report
mv $PREFIX* ./1.General_Report/
mv ./1.General_Report/$PREFIX.vcf.gz ./


## STEP 2: CHROMOSOMAL SEX CHECK =========================================================

### Given that the coding regions of X and Y chromosome did not allow the same filtering used for Whole Genome Sequencing, we analyzed these chromosomes independently and compared to the AMR cohort of the 1000GP

### Extract chrX and chrY
vcftools --gzvcf $PREFIX.vcf.gz --chr chrX --recode --out $PREFIX.chrX
mv $PREFIX.chrX.recode.vcf $PREFIX.chrX.vcf

vcftools --gzvcf $PREFIX.vcf.gz --chr chrY --recode --out $PREFIX.chrY
mv $PREFIX.chrY.recode.vcf $PREFIX.chrY.vcf

### a. Data description 

### General report
bcftools stats $PREFIX.chrX.vcf > $PREFIX.chrX.vchk

vcftools --vcf $PREFIX.chrX.vcf --FILTER-summary --out $PREFIX.chrX
vcftools --vcf $PREFIX.chrY.vcf --FILTER-summary --out $PREFIX.chrY
 
### Site missingness .lmiss
vcftools --vcf $PREFIX.chrX.vcf --missing-site --out $PREFIX.chrX
vcftools --vcf $PREFIX.chrY.vcf --missing-site --out $PREFIX.chrY

### Individual missingness .imiss
vcftools --vcf $PREFIX.chrX.vcf --missing-indv --out $PREFIX.chrX
vcftools --vcf $PREFIX.chrY.vcf --missing-indv --out $PREFIX.chrY

### Site depth .ldepth
vcftools --vcf $PREFIX.chrX.vcf --site-depth --out $PREFIX.chrX
vcftools --vcf $PREFIX.chrY.vcf --site-depth --out $PREFIX.chrY

### Individual depth .idepth
vcftools --vcf $PREFIX.chrX.vcf --depth --out $PREFIX.chrX
vcftools --vcf $PREFIX.chrY.vcf --depth --out $PREFIX.chrY

### Individual heterozygosity of chromosome X
vcftools --vcf $PREFIX.chrX.vcf --het --out $PREFIX.chrX

#### CHECKPOINT #At the end of the stats you should have the 14 following files:
#$PREFIX.chrX.vchk
#$PREFIX.chrX.FILTER.summary
#$PREFIX.chrX.lmiss
#$PREFIX.chrX.ldepth
#$PREFIX.chrX.imiss
#$PREFIX.chrX.het
#$PREFIX.chrX.idepth
#$PREFIX.chrY.vchk
#$PREFIX.chrY.FILTER.summary
#$PREFIX.chrY.lmiss
#$PREFIX.chrY.ldepth
#$PREFIX.chrY.imiss
#$PREFIX.chrY.het
#$PREFIX.chrY.idepth

### b. Comparison with the 1000GP AMR cohort

### Files from the 1000GP cohort are in plink format
### Extracting X and Y chdomosomes of AMR cohorts from 1000GP(Plink)
### 'AMR_cohorts' contains the IDs for individuals from PEL, MXL, CLM, PUR cohorts. Each line is 'FamID' 'IndID'
plink --bfile $1000GPfile --keep 'AMR_cohorts' --mac 1 --chr X --make-bed --out 1000GP.X
plink --bfile $1000GPfile --keep 'AMR_cohorts' --mac 1 --chr Y --make-bed --out 1000GP.Y

# Get missingness rate reports for 1000GP
plink --bfile 1000GP.X --missing --out 1000GPfile.X.miss
plink --bfile 1000GP.Y --missing --out 1000GPfile.Y.miss

# 1000GP X chrom have 26,324 variants
# 1000GP Y chrom have 309 variants

# ReDLat X chrom have 9671 variants
# ReDLat Y chrom have 83 variants

### C. Chromosomal sex designation according to F statistic in X chromosome

# Files need to be in plink format. If necessary use: 
plink --vcf $PREFIX.chrX.vcf --keep-allele-order --vcf-half-call m --make-bed --out $PREFIX.chrX.plink
plink --bfile $PREFIX.chrX.plink --update-sex $new_sex --make-bed --out $PREFIX.chrX.plink.sex

# Remove X pseudoautosomal region (if your data is hg19, use 'hg19')
plink --bfile $PREFIX.chrX.plink.sex --split-x hg38 --make-bed --out $PREFIX.chrX.plink.sex.split-x

# Check if variants have an id in the second column of the bim file.
# Assign IDs to variants if they dont have it
plink --bfile $PREFIX.chrX.plink.sex.split-x --set-missing-var-ids '@:#' --make-bed --out $PREFIX.chrX.plink.sex.split-x.id

# Prune for Linkage Disequilibrium (make sure that the variants have an ID in the bim file)
plink --bfile $PREFIX.chrX.plink.sex.split-x.id --indep-pairphase 20000 2000 0.5
# this produces plink.prune.in and plink.prune.out

# Retain independent markers (in linkage equilibrium)
plink --bfile $PREFIX.chrX.plink.sex.split-x.id --extract plink.prune.in --make-bed --out $PREFIX.chrX.plink.sex.split-x.id.LD

# Check sex 
plink --bfile $PREFIX.chrX.plink.sex.split-x.id.LD --check-sex 0.3 0.7 --out $PREFIX.chrX.plink.sex.split-x.id.LD.Xsex

##output: split males vs. females and plot F values
##Repeat and compare with 1000gp.AMR
##try to make a single plot with the 4 groups redlat males, redlat females, 1000gp.amr males 1000g.amr females
# Individuals that fail sex check should be added to 'flagged_samples' file

### Store the files of this step on a directory of their own
mkdir 2.Check_sex
mv $PREFIX.* ./2.Check_sex/
mv 1000GPfile.* ./2.Check_sex/
mv ./2.Check_sex/$PREFIX.vcf.gz ./


## STEP 3: SITE QUALITY FILTERING =========================================================

### a. Depth >= 30
vcftools --gzvcf $PREFIX.vcf.gz --min-meanDP 30 --recode --recode-INFO-all --out $PREFIX.DP30
mv $PREFIX.DP30.recode.vcf $PREFIX.DP30.vcf
bgzip $PREFIX.DP30.vcf
# result: kept 393,942 out of a possible 410,452 sites, removed 16,510 variants'
# Creates file $PREFIX.DP30.vcf.gz

### b. Quality >= 20
vcftools --gzvcf $PREFIX.DP30.vcf.gz --minQ 20 --recode --recode-INFO-all --out $PREFIX.DP30.Q20
mv $PREFIX.DP30.Q20.recode.vcf $PREFIX.DP30.Q20.vcf
bgzip $PREFIX.DP30.Q20.vcf
# result: kept 393,942 out of a possible 393,942 sites, removed 0 variants
# Creates file $PREFIX.DP30.Q20.vcf.gz

### c. Missingness >= 10% ( --max-missing float is a 0-1range. 0 allows sites that are completely missing and 1 indicates no missing data allowed)
vcftools --gzvcf $PREFIX.DP30.vcf.gz --max-missing 90 --recode --recode-INFO-all --out $PREFIX.DP30.Q20.miss
mv $PREFIX.DP30.Q20.miss.recode.vcf $PREFIX.DP30.Q20.miss.vcf
bgzip $PREFIX.DP30.Q20.miss.vcf
# result: 
# Creates file file.DP30.Q20.miss.vcf.gz

### Store the files of this step on a directory of their own
mv $PREFIX.vcf.gz ./1.General_Report #place the initial file in the first directory we created
mkdir 3.Site_quality
mv $PREFIX.* 3.Site_quality


## STEP 4: INDIVIDUAL QUALITY FILTERING =========================================================

vcftools --gzvcf ./3.Site_quality/$PREFIX.DP30.Q20.miss.vcf.gz --exclude $flagged_samples_vcf --recode --recode-INFO-all --out $PREFIX.DP30.Q20.miss.indQC
mv $PREFIX.DP30.Q20.miss.indQC.recode.vcf $PREFIX.DP30.Q20.miss.indQC.vcf
bgzip $PREFIX.DP30.Q20.miss.indQC.vcf
# result: 
# Creates file $PREFIX.DP30.Q20.miss.indQC.vcf.gz


### Store the files of this step on a directory of their own
mkdir 4.Individual_quality
mv $PREFIX.* 4.Individual_quality


## STEP 5: GENERATE PLINK FILES =========================================================

### a. Import data from vcf and exclude flagged samples 
plink --vcf ./4.Individual_quality/$PREFIX.DP30.Q20.miss.indQC.vcf.gz  --keep-allele-order --vcf-half-call m  --make-bed --out $PREFIX.vcftoolsQC
# WARNING: half calls will be set to missing. Multiallelic variants will only keep the first two alternates 

#### CHECKPOINT
# Check the .bim file that was generated. If column 1 is formatted as 'chr1' instead of '1' do the following:

# Save the unformatted .bim file 
#mv $PREFIX.depth30.Q20.bim $PREFIX.depth30.Q20.bim.original #Save the unformatted .bim file 
#sed 's/chr//' $PREFIX.depth30.Q20.bim.original > $PREFIX.depth30.Q20.bim #Removes the 'chr' prefix of the chromosomes in column 1

### b. Update .fam file with family Sex, ID, and Phenotype

## Update sex. $new_sex file is defined at the begginign of the script
plink --bfile $PREFIX.vcftoolsQC --update-sex $new_sex --make-bed --out $PREFIX.vcftoolsQC.sex

## Update id. $new_id file is defined at the begginign of the script
plink --bfile $PREFIX.vcftoolsQC.sex --update-ids $new_id --make-bed --out $PREFIX.vcftoolsQC.sex.id

## Assign a phenotype. $new_pheno file is defined at the begginign of the script
plink --bfile $PREFIX.vcftoolsQC.sex.id --make-pheno $new_pheno --make-bed --out $PREFIX.vcftoolsQC.sex.id.pheno

mkdir 5.Generate_plink_files
mv $PREFIX.* ./5.Generate_plink_files


## STEP 6: RELATIONSHIP INFERENCE AND MENDEL ERRORS =========================================================

king -b ./5.Generate_plink_files/$PREFIX.vcftoolsQC.sex.id.pheno.bed --related --degree 4 --prefix $PREFIX.vcftoolsQC.sex.id.pheno.related

#$PREFIX.vcftoolsQC.sex.id.pheno.related.king0
#$PREFIX.vcftoolsQC.sex.id.pheno.related.kin
#$PREFIX.vcftoolsQC.sex.id.pheno.related.kinX

#'results from 5/4 26 MZ 0 PO 4 FS 739 2nd'
#'results: 26 MZ, 0 PO, 1 FS, 675 2nd'

# make a new list with the samples that we want to remove in our file .fam. Edit the 'fail_relatedness' variable

plink --bfile ./5.Generate_plink_files/$PREFIX.vcftoolsQC.sex.id.pheno --remove $fail_relatedness --make-bed --out $PREFIX.vcftoolsQC.sex.id.pheno.rel

#### CHECKPOINT:
## If the dataset contains DUOS or TRIOS check for Mendel errors

plink --bfile $PREFIX.vcftoolsQC.sex.id.pheno.rel --set-me-missing --mendel-duos --make-bed --out $PREFIX.vcftoolsQC.sex.id.pheno.rel.mendel

mkdir 6.Relationship_inference
mv $PREFIX.* ./6.Relationship_inference
mv Fail-relatedness.txt ./6.Relationship_inference


## STEP 7: STRINGENT MISSINGNESS QC =========================================================

plink --bfile ./6.Relationship_inference/$PREFIX.vcftoolsQC.sex.id.pheno.rel.mendel --geno 0.05 --mind 0.05 --make-bed --out $PREFIX.vcftoolsQC.sex.id.pheno.rel.mendel.mind-geno

mkdir 7.Stringent_missingness
mv $PREFIX.* ./7.Stringent_missingness

plink --bfile ./7.Stringent_missingness/$PREFIX.vcftoolsQC.sex.id.pheno.rel.mendel.mind-geno --make-bed --out $PREFIX.fullQC


## STEP 8: GENERAL REPORT OF POST QC STATISTICS=========================================================

# Generate a file reporting the missingness on a per-site basis and missingness on a per-individual basis. 
# The file has the suffix ".lmiss" and  ".imiss".
plink --bfile  $PREFIX.fullQC --missing --out $PREFIX.fullQC.missingness 
# Generates $PREFIX.fullQC.missingness.imiss and $PREFIX.fullQC.missingness.lmiss
# $PREFIX.fullQC.missingness.imiss: FID, IID , MISS_PHENO, N_MISS (number of missing calls), N_GENO (number of valid calls), F_MISS (missing call rate)
# $PREFIX.fullQC.missingness.lmiss: CHR, SNP, N_MISS (Number of missing calls), N_CLST	(Only present with --within/--family), N_GENO (number of valid calls) F_MISS (Missing call rate)

plink --bfile  $PREFIX.fullQC --het --out $PREFIX.fullQC.heterozygosity
# Generates $PREFIX.fullQC.heterozygosity.het
# $PREFIX.fullQC.heterozygosity.het: 'FID', 'IID' , 'O(HOM)' Observed number of homozygotes, 'E(HOM)' Expected number of homozygotes, 'N(NM)' Number of observations, 'F'	F coefficient


## STEP 8: PRINCIPAL COMPONENT ANALYSIS TO DETECT BATCH EFFECTS=========================================================

# Retain variants with MAF > 10% 
plink --bfile $PREFIX.fullQC --maf 0.1 --make-bed --out $PREFIX.fullQC.maf10

# Calculate LD
plink --bfile $PREFIX.fullQC.maf10 --indep-pairwise 50 10 0.2 

# Prune for Linkage Disequilibrium (make sure that the variants have an ID in the bim file)
plink --bfile $PREFIX.fullQC.maf10 --extract plink.prune.in --make-bed --out $PREFIX.fullQC.maf10.LD
# NOTE: a dataset for a PCA should be > 100.000 variants

# Perform a simple PCA using plink (plink default settings will calculate top 20 principal components)
plink --bfile $PREFIX.fullQC.maf10.LD --pca header tabs --out $PREFIX.fullQC.maf10.LD.pca
