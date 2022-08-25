# Plotting scripts developed by Juliana Acosta-Uribe. University of California Santa Barbara
# Quality control process. 
# ReDLat July 28 2022

# These are the plotting scripts that accompany the bash script to perform quality control. 

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


# STEP 0: SET UP DATA AND VARIABLES

# Install and load required packages
#install.packages("psych")
library(psych)
#install.packages("ggplot2")
library(ggplot2)
# install.packages('BiocManager')
# BiocManager::install('snpStats')
library(snpStats)

#Give path to working directory
setwd("/home/acostauribe/")

#Give the prefix of your files
PREFIX = "ReDLat"
print (PREFIX)  


## STEP 1: GENERAL REPORT OF PRE QC STATISTICS

### a. Data description 
# The file obtained with 'bcftools stats' is useful as a general glimpse at the data distribution and quality. However, its format is not ideal for plotting.
# One of the most useful metrics in here is the transition/transversion ratio (ts/tv) it should be close to 2 for genome seq and close to 3 for exomes
# The ".FILTER.summary" file is useful if the dataset was recalibrated (VQSR) and the samples were classified with PASS, or tranches

### b. Site missingness 
lmiss = read.csv((paste0(PREFIX,".lmiss")), header = T, sep = "")
hist(lmiss$F_MISS,
        xlab="Missingness rate",
        ylab="Number of sites", 
        main="Missingness rate per site - Raw dataset", 
        col="gray",
        breaks=50)

boxplot(lmiss$F_MISS,
        ylab="Missingness rate",
        xlab="Raw dataset", 
        main="Missingness rate per site", 
        col="gray")

### c. Individual missingness
imiss = read.csv((paste0(PREFIX,".imiss")), header = T, sep = "")
hist(imiss$F_MISS,
     xlab="Missingness rate",
     ylab="Samples", 
     main="Missingness rate per sample - Raw dataset", 
     col="gray")

### d. Site depth
ldepth.mean = read.csv((paste0(PREFIX,".ldepth.mean")), header = T, sep = "")
# Use the describe function from the "Psych" package to get basic stats
describe(ldepth.mean$MEAN_DEPTH)

### e. Individual depth 
idepth = read.csv((paste0(PREFIX,".idepth")), header = T, sep = "")
hist(idepth$MEAN_DEPTH,
     xlab="Mean Depth ",
     ylab="Samples", 
     main="Mean Depth per Sample - Raw dataset", 
     col="gray",
     breaks=50)

### f. Individual heterozygosity 
het = read.delim((paste0(PREFIX,".het")), header = T, sep = "")
hist(het$F,  
     freq=TRUE, 
     xlab="Heterozygosity",  
     ylab="Samples", 
     main="Heterozygosity rate per Sample - Raw dataset",
     col="gray",
     breaks=50)
abline(v=(mean(het$F) - (3*(sd(het$F)))), col="red")
abline(v=(mean(het$F) + (3*(sd(het$F)))), col="red")
abline(v=(mean(het$F)), col="blue") 

###heterozygosity vs missigness
##TO DO


## STEP 2: CHROMOSOMAL SEX CHECK


## STEP 3: SITE QUALITY FILTERING (OPTIONAL PLOTS)

### a. Depth >= 30
DP30.lmiss <- read.delim((paste0(PREFIX,".DP30.lmiss")), header = T)
DP30.imiss <- read.delim((paste0(PREFIX,".DP30.imiss")), header = T)
DP30.ldepth.mean <- read.delim((paste0(PREFIX,".DP30.ldepth.mean")), header = T)
DP30.idepth <- read.delim((paste0(PREFIX,".DP30.idepth")), header = T)
DP30.het <- read.delim((paste0(PREFIX,".DP30.het")), header = T)

### b. Quality >= 20
DP30.Q20.lmiss <- read.delim((paste0(PREFIX,".DP30.Q20.lmiss")), header = T)
DP30.Q20.imiss <- read.delim((paste0(PREFIX,".DP30.Q20.imiss")), header = T)
DP30.Q20.ldepth.mean <- read.delim((paste0(PREFIX,".DP30.Q20.ldepth.mean")), header = T)
DP30.Q20.idepth <- read.delim((paste0(PREFIX,".DP30.Q20.idepth")), header = T)
DP30.Q20.het <- read.delim((paste0(PREFIX,".DP30.Q20.het")), header = T)


## Compare metrics along QC
### b. Site missingness 
boxplot(lmiss$F_MISS, 
        DP30.lmiss$F_MISS,
        DP.30.Q20.lmiss$F_MISS,
        col = c("gray"), 
        border = "black",  
        ylab="Proportion of missing data", 
        names=c("Raw Data", "DP30", "DP30-Q20"),
        main="Data Missingness per site", 
        horizontal = FALSE, 
        notch = FALSE)
### c. Individual missingness        
boxplot(imiss$F_MISS, 
        DP30.imiss$F_MISS,
        DP.30.Q20.imiss$F_MISS,
        col = c("gray"), 
        border = "black",  
        ylab="Proportion of missing data", 
        names=c("Raw Data", "DP30", "DP30-Q20"),
        main="Data Missingness per sample", 
        horizontal = FALSE, 
        notch = FALSE)
### d. Site depth
boxplot(idepth$MEAN_DEPTH,  
        DP30.idepth$MEAN_DEPTH,
        DP30.Q20.idepth$MEAN_DEPTH,
        col = c("gray"), 
        border = "black",  
        ylab="Mean depth per Sample", 
        names=c("Raw Data", "DP30", "DP30-Q20"),
        main="Data Depth", 
        horizontal = FALSE, 
        notch = FALSE)
### e. Individual depth         
boxplot(idepth$MEAN_DEPTH,  
        DP30.idepth$MEAN_DEPTH,
        DP30.Q20.idepth$MEAN_DEPTH,
        col = c("gray"), 
        border = "black",  
        ylab="Mean depth per Sample", 
        names=c("Raw Data", "DP30", "DP30-Q20"),
        main="Data Depth", 
        horizontal = FALSE, 
        notch = FALSE)
### f. Individual heterozygosity 
boxplot(het$F,
        DP30.het$F,
        DP30.Q20.het$F,
        col = c("gray"), 
        border = "black",  
        ylab="Heterozygosity per Sample", 
        names=c("Raw Data", "DP30", "DP30-Q20"),
        main="Heterozygosity rate", 
        horizontal = FALSE, 
        notch = FALSE)

## STEP 4: INDIVIDUAL QUALITY FILTERING 
## STEP 5: GENERATE PLINK FILES 
## STEP 6: RELATIONSHIP INFERENCE AND MENDEL ERRORS
#plots are made through KING
## STEP 7: STRINGENT MISSINGNESS QC 

## STEP 8: GENERAL REPORT OF POST QC STATISTICS

fullQC.lmiss <- read.delim((paste0(PREFIX,".fullQC.missingness.lmiss")), header = T)
fullQC.imiss <- read.delim((paste0(PREFIX,".fullQC.missingness.imiss")), header = T)
fullQC.het <- read.delim((paste0(PREFIX,".fullQC.heterozygosity.het")), header = T)

### b. Site missingness 
boxplot(lmiss$F_MISS, 
        fullQC.lmiss$F_MISS,
        col = c("gray"), 
        border = "black",  
        ylab="Proportion of missing data", 
        names=c("Raw Data", "QC Data"),
        main="Data Missingness per site", 
        horizontal = FALSE, 
        notch = FALSE)
### c. Individual missingness        
boxplot(imiss$F_MISS, 
        fullQC.imiss$F_MISS,
        col = c("gray"), 
        border = "black",  
        ylab="Proportion of missing data", 
        names=c("Raw Data", "QC Data"),
        main="Data Missingness per sample", 
        horizontal = FALSE, 
        notch = FALSE)
### f. Individual heterozygosity 
boxplot(het$F,
        fullQC.het$F,
        col = c("gray"), 
        border = "black",  
        ylab="Heterozygosity per Sample", 
        names=c("Raw Data", "QC Data"),
        main="Heterozygosity rate", 
        horizontal = FALSE, 
        notch = FALSE)


# STEP 9: PRINCIPAL COMPONENT ANALYSIS TO DETECT BATCH EFFECTS

# Load the dataframe we are going to plot
eigenvec = read.delim((paste0(PREFIX,".fullQC.maf10.LD.pca.eigenvec")), sep='\t', header=TRUE)
# Pair each sample with the batch in which it was sequenced
lookup_dataframe = read.delim("batch_lookup.txt", header = TRUE )
# Using the "match" function, we will create a new column in 'eigenvec' called 'Continent' according to the identity of the Population column
eigenvec$Batch = lookup_dataframe$Batch[match(eigenvec$IID, lookup_dataframe$IID)]
# plot
PCA = ggplot(eigenvec, aes(x=PC1, y=PC2, 
                     color=Batch)) + 
          geom_point(size=3,
                     alpha=0.8) +
          theme_classic() + 
          labs(title="Principal Component Analysis")
print(PCA)
ggsave("Batch_effect_PCA.png")

# There is additional code for plotting PCA in "intro_to_graphs.R"
