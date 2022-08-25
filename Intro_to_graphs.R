#Visualization of a PCA with ggplot2
#Juliana Acosta-Uribe 2022

setwd("~/Documents/Kosik Lab -UCSB/ReD-Lat/Training/Week_17")


#0. Start by installing the ggplot2 package if you dont have it
install.packages("ggplot2")


#1. Load the dataframe we are going to plot
eigenvec <- read.delim("1000G.toy.maf.ld.pca.eigenvec", sep='\t', header=FALSE)
#Notice that in our file the field separator is a tab '\t', and that it doesn't have a header header=FALSE.

#Since our dataframe doesn't have a header, we can assign the names of the columns with the 'colnames' function:
colnames(eigenvec) <- c('Population', 'ID', 'PC1', 'PC2','PC3','PC4','PC5','PC6','PC7','PC8','PC9',
                        'PC10', 'PC11', 'PC12','PC13','PC14','PC15','PC16','PC17','PC18','PC19', 'PC20')

#We also need to add the correspondent continent to each population using the continent_lookup.txt dataframe.

lookup_dataframe <- read.delim("continent_lookup.txt", header = TRUE )

#using the "match" function, we will create a new column in 'eigenvec' called 'Continent' according to the identity of the Population column
eigenvec$Continent <- lookup_dataframe$Continent[match(eigenvec$Population, lookup_dataframe$Population)]


#2. Load the library(ggplot2) and the 'eigenvec' dataset using ggplot
library(ggplot2)
ggplot(eigenvec)

#This command does not plot anything but a gray canvas. 
#It defines the dataset for the plot and creates an empty base on top of which we can add additional layers.
#ggplot2 uses the concept of aesthetics, which map dataset attributes to the visual features of the plot. 
#The aesthetics are mapped within the aes() function to construct the final mappings.
#You will have to specify which are the values that you want to use for each axis
#In this example we want PC1 on the x-axis and PC2 on the y-axis

ggplot(eigenvec, aes(x=PC1, y=PC2))

#A blank ggplot is drawn. Even though the x and y are specified, there are no points or lines in it. 
#This is because, ggplot doesn't assume that you meant a scatterplot or a line chart to be drawn. 
#I have only told ggplot what dataset to use and what columns should be used for X and Y axis. 
#I haven't explicitly asked it to draw any points.

 
#3. Add a geometric layer to define the shapes to be plotted. In case of scatter plots, use geom_point().
#To specify a layer of points which plots the PC1 on the x-axis and PC2 on the y-axis we need to add "+ geom_point()" 
#Each geometric layer (or geoms) requires a different set of aesthetic mappings 
#The geom_point() function uses the aesthetics x and y to determine the x- and y-axis coordinates of the points to plot. 
#To link the geometric layer with a ggplot object we need to use the + operator

ggplot(eigenvec, aes(x=PC1, y=PC2)) + geom_point()

#you can also write your function in different lines
ggplot(eigenvec, aes(x=PC1, y=PC2)) + 
       geom_point()

#The basic structure of a ggplot2 scatterplot graph is:
#ggplot(___, aes(x = ___, y = ___) ) + 
#       geom_point( )


#4. Specify additional aesthetics for points

#Adjust the point size of a scatter plot using the size parameter
#Change the point color of a scatter plot using the color parameter
#Set a parameter alpha to change the transparency of all points

#ggplot(___,aes(x = ___, y = ___, )) + 
#  geom_point(color = ___, 
#             size  = ___,
#             alpha = ___)


ggplot(eigenvec, aes(x=PC1, y=PC2)) + 
      geom_point( color="blue",
                  size=3,
                  alpha=0.3) #scale from 0-1, 1 being no transparency

#If we want to color the points according to a column value in our dataframe, we need to add it as a variable in the aesthethics (aes)function
ggplot(eigenvec, aes(x=PC1, y=PC2, 
                     shape=Continent)) + 
        geom_point( color="blue",
                    size=3,
                    alpha=0.3)

#This creates a label automatically

#You can mix shapes ans colors according to different columns
ggplot(eigenvec, aes(x=PC1, y=PC2, 
                     shape=Continent,
                     color=Population)) + 
        geom_point( size=3,
                    alpha=0.8)

#Or use one of the multiple themes for fun colors and styles https://ggplot2.tidyverse.org/reference/ggtheme.html
ggplot(eigenvec, aes(x=PC1, y=PC2, 
                     shape=Continent,
                     color=Population)) + 
          geom_point( size=3,
                      alpha=0.8) +
          theme_classic()

# Add Title and Labels
ggplot(eigenvec, aes(x=PC1, y=PC2, 
                     shape=Continent,
                     color=Population)) + 
          geom_point(size=3,
                     alpha=0.8) +
          theme_classic() + 
          labs(title="Principal Component Analysis", 
                  subtitle="Subset of the 1000GP",
                  caption="Made by Juliana Acosta-Uribe")



  
  

  