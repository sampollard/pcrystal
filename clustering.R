#!/usr/bin/R
# Clusters the protein crystallization data in two areas:
# Protein physical properties and crystallization conditions
# Author: Sam Pollard (sam.d.pollard@gmail.com)
# Last Modifed: May 26, 2014
#
# Note: For each report generated, there must be at least two entries for each
# data point (i.e. PID) where the value is not NA, or else the dissimilarity
# matrix will have NAs in it (which is not allowed).
library("cluster")
table <- read.csv("/home/sam/school/cs474/pcrystal/report_handmade.csv",
    header = TRUE, sep = ",")

# Data columns:
# 1 -> Protein ID (row name); 8 -> Molecular weight;
# 10 -> % alpha helix; 11 -> % beta sheet; 13 -> crystallization temp; 14 -> pH;
# 15 -> densityMatthews; 16 -> pI; 17 -> Instability Index; 18 -> density%sol;
# 19 -> PEG #; 20 -> PEG %; 21 -> Ionic Strength; 22 -> PEG# * PEG% / 100

# NOTE: This may be done with the physical$diss which gives the dissimilarity
# matrix, which in turn may be passed in to hclust adn then tweaked using
# methods outlined in
# http://rstudio-pubs-static.s3.amazonaws.com/1876_df0bf890dd54461f98719b461d987c3d.html
# Setting colors for individual data poitns:
# http://stackoverflow.com/questions/8774002/setting-the-color-for-an-individual-data-point

# Physical Data:
physical_data <- data.frame(
    cbind(table[1], table[8], table[10], table[11], table[15]),
        row.names = 1, check.rows = TRUE)
physical <- agnes(physical_data, diss = FALSE, metric = "euclidean",
      stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)
ptitlestr <- "Clustering of Various Proteins from their Physical Properties"
psubtitlestr <- paste("Using Molecular Weight, % helix, % sheet, ",
        "Matthews Density. ",
        "AC = ", round(physical$ac, digits = 2))
pdf('physical_cluster.pdf')
# Change the plot parameters
par(cex = 0.8, cex.main = 1.6, cex.sub = 1.25, cex.lab = 1.25, cex.axis = 1.25,
        cex.sub = 1.25, col = "brown", col.main = "blue", bg = "white")
# which.plots is 1 for banner, 2 for dendrogram
plot(physical, which.plots = 2, main = ptitlestr, sub = psubtitlestr)
dev.off()

# Crystallization Data:
crystal_data <- data.frame(
        cbind(table[1], table[13], table[14],table[16], table[17], table[22]),
        row.names = 1, check.rows = TRUE)

# agnes: average is UPGMA, "complete" is complete linkage, "ward", "weighted"
crystal <- agnes(crystal_data, diss = FALSE, metric = "euclidean",
        stand = TRUE, method = "average", keep.diss = FALSE, keep.data = TRUE)
ctitlestr <- 
        "Clustering of Various Proteins from their Crystallization Conditions"
csubtitlestr <- paste("Using Temperature, pH, pI, Instability Index, # & % PEG.",
        "AC = ", round(crystal$ac, digits = 2))
# Plot and save the dendrogram
pdf('crystal_cluster.pdf')
par(cex = 0.8, cex.main = 1.6, cex.sub = 1.25, cex.lab = 1.25, cex.axis = 1.25,
        cex.sub = 1.25, col = "brown", col.main = "blue", bg = "white")
plot(crystal, which.plots = 2, main = ctitlestr, sub = csubtitlestr)
dev.off()