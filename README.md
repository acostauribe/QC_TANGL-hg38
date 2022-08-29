# Quality control for whole-genome sequencing data

This repository compiles a series of scripts to perform thorough quality control (QC) on whole-genome sequencing data in a VCF format. 


This pipeline builds on the initial QC methods used in the paper:
Acosta-Uribe, J., Aguillón, D., Cochran, J.N. et al. A neurodegenerative disease landscape of rare mutations in Colombia due to founder effects. Genome Med 14, 27 (2022). https://doi.org/10.1186/s13073-022-01035-9


## Description

The TANGL dataset presented in our Genome Medicine paper was aligned to hg19 and processed as follows:

"Genome sequencing (WGS) was performed at the HudsonAlpha Institute for Biotechnology on either the Illumina HiSeq X platform, or the Illumina NovaSeq platform. A subset of individuals was sequenced at the Human Longevity Institute on the Illumina HiSeq X platform (119 samples). The combined dataset had a mean read depth of 34X and an average of 92% of bases covered at 20X. Sequencing libraries at HudsonAlpha were prepared by Covaris shearing, end repair, adapter ligation, and PCR using standard protocols. Library concentrations were normalized using KAPA qPCR prior to sequencing. Sequencing reads from both centers were aligned to the hg19 reference genome with bwa-0.7.12 BAMs were sorted and duplicates were marked with Sambamba 0.5.4  Indels were realigned, bases were recalibrated, and gVCFs were generated with GATK 3.3 Variants were called across all samples in a single batch with GATK 3.8 using the -newQual flag to minimize false negative singleton calls. The recall rate for GATK against truth sets is between 93-99%  for single nucleotide variants and 85 and 98% for small (less than 50 bp) indel events. Genome annotation was performed using SnpEff 4.3 after splitting multi-allelic sites with Vt. The genome was annotated with the gene definitions from human genome build Ensembl GRCh37.75. All single nucleotide variants and indels were annotated with CADD v1.3. Population database frequency annotations included 1000 Genomes Phase 3 (1000GP), TOPMed Bravo (lifted over from hg38 to hg19 using CrossMap 0.2.7), and several population database sets annotated using WGSA 0.7 including ExAC, gnomAD, ESP, and UK10K. Variants were also annotated with dbSNP release 151. Calls were filtered with vcftools (v0.1.12b)  to retain sites with quality scores equal or greater than 20 and mean read depth scores equal or greater than 30. KING (v2.2.4)  was used to verify disclosed familiar relationships and pedigree structures, and individuals with unexplained relatedness were removed. For duplicate samples and monozygotic twin pairs, only one genome was kept. PLINK v.1.90 was used to identify and exclude individuals with discordant X-chromosome sex and those with more than 5% missing data. Mendel errors were set to missing before removing autosomal variants withCalls were filtered with vcftools (v0.1.12b) to retain sites with quality scores equal or greater than 20 and mean read depth scores equal or greater than 30. KING (v2.2.4) was used to verify disclosed familiar relationships and pedigree structures, and individuals with unexplained relatedness were removed. For duplicate samples and monozygotic twin pairs, only one genome was kept. PLINK v.1.90 was used to identify and exclude individuals with discordant X-chromosome sex and those with more than 5% missing data. Mendel errors were set to missing before removing autosomal variants with missingness > 5% obtaining a total of 41,123,431 variants and 900 individuals from 566 families available for analysis.  missingness > 5% obtaining a total of 41,123,431 variants and 900 individuals from 566 families available for analysis." 


This quality control pipeline was developed for the TANGL dataset aligned to hg38 and processed as follows:

{waiting for jared}


## Getting Started

### Dependencies

* bcftools https://samtools.github.io/bcftools/bcftools.html
* vcftools https://vcftools.github.io/man_latest.html
* plink https://www.cog-genomics.org/plink2/
* King https://www.kingrelatedness.com/


### Installing

* The scripts presented here are provided as a QC pipeline guide, rather than a plug and play script. There are steps that require a 'manual evaluation', and as many scripts, it needs to be tuned according to the user needs.

## Authors

Juliana Acosta-Uribe
acostauribe@ucsb.edu

Ada Madejska
amadejska@ucsb.edu


## Version History

* 0.1
    * Initial Release

## Acknowledgments

This pipeline integrated multiple workflows for quality control. 
Some of our resources were:

* Broad Institute gnomAD 

   [gnomAD v3.1](https://gnomad.broadinstitute.org/news/2020-10-gnomad-v3-1-new-content-methods-annotations-and-data-availability/#sample-and-variant-quality-control/)
   
   [gnomAD v3.0](https://gnomad.broadinstitute.org/news/2019-10-gnomad-v3-0/)

* Anderson, C. A., Pettersson, F. H., Clarke, G. M., Cardon, L. R., Morris, A. P., & Zondervan, K. T. (2010). Data quality control in genetic case-control association studies. Nature protocols, 5(9), 1564-1573.

* Panoutsopoulou, K., & Walter, K. (2018). Quality control of common and rare variants. Chapter in: Genetic Epidemiology: Methods and Protocols, Methods in Molecular Biology, vol. 1793, (https://doi.org/10.1007/978-1-4939-7868-7_3), Springer Science Business Media, LLC, part of Springer Nature 2018
