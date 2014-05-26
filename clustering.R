#!/usr/bin/R
# Clusters the protein crystallization data in two areas:
# Protein physical properties and crystallization conditions
# Author: Sam Pollard (sam.d.pollard@gmail.com)
# Last Modifed: May 26, 2014
#
# Note: For each report generated, there must be at least two entries for each
# data point (i.e. PID) where the value is not NA, or else the dissimilarity
# matrix will have NAs in it (which is not allowed).
#
# This script generates three dendrograms. Others may be generated using similar
# methods.

library("cluster")
table <- read.csv("/home/sam/school/cs474/pcrystal/report_handmade.csv",
    header = TRUE, sep = ",")

# Data columns:
datacols <- colnames(table)
# 1 -> Protein ID (row name); 8 -> Molecular weight;
# 10 -> % alpha helix; 11 -> % beta sheet; 13 -> crystallization temp; 14 -> pH;
# 15 -> densityMatthews; 16 -> pI; 17 -> Instability Index; 18 -> density%sol;
# 19 -> PEG #; 20 -> PEG %; 21 -> Ionic Strength; 22 -> PEG# * PEG% / 100
# 23 -> GRAVY

# NOTE: This may be done with the physical$diss which gives the dissimilarity
# matrix, which in turn may be passed in to hclust and then tweaked using
# methods outlined in
# http://rstudio-pubs-static.s3.amazonaws.com/1876_df0bf890dd54461f98719b461d987c3d.html
# Setting colors for individual data poitns:
# http://stackoverflow.com/questions/8774002/setting-the-color-for-an-individual-data-point

# Change the plot parameters
plotsettings <- par(cex = 0.8, cex.main = 1.4, cex.sub = 0.9, cex.lab = 1.25,
        cex.axis = 1.25, col.main = "blue", bg = "white",
        col = "black")

# Basic Physical Data:
basic_cols <- c(1,8,10,11,16)
physical_data_basic <- data.frame(cbind(table[basic_cols]),
        row.names = 1, check.rows = TRUE)
# agnes: average is UPGMA, "complete" is complete linkage, "ward", "weighted"
physical_basic <- agnes(physical_data_basic, diss = FALSE, metric = "euclidean",
      stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)

# Basic Physical Plot
ptitlestr_b <- "Clustering of Various Proteins from Simple Physical Properties"
psubtitlestr_b <- paste("Using ",
        paste(datacols[basic_cols[2:length(basic_cols)]], collapse = ", "),
        "(AC = ", round(physical_basic$ac, digits = 2), ")")
pdf('physical_cluster_basic.pdf')
par(plotsettings)
# which.plots is 1 for banner, 2 for dendrogram
plot(physical_basic, which.plots = 2, main = paste(ptitlestr_b, " (agnes)"),
        sub = psubtitlestr_b)
dev.off()

# Physical Data:
physical_cols <- c(1,8,15,16,17,23)
physical_data <- data.frame(cbind(table[physical_cols]),
        row.names = 1, check.rows = TRUE)
physical <- agnes(physical_data, diss = FALSE, metric = "euclidean",
      stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)

# Physical Plot
ptitlestr <- "Clustering of Various Proteins from Physical Properties"
psubtitlestr <- paste("Using ",
        paste(datacols[physical_cols[2:length(physical_cols)]],
        collapse = ", "), "(AC = ", round(physical$ac, digits = 2), ")")
pdf('physical_cluster.pdf')
par(plotsettings)
plot(physical, which.plots = 2, main = paste(ptitlestr, " (agnes)"),
        sub = psubtitlestr)
dev.off()

# Crystallization Data:
crystal_cols <- c(1,13,14,21,22)
crystal_data <- data.frame(cbind(table[crystal_cols]),
        row.names = 1, check.rows = TRUE)
crystal <- agnes(crystal_data, diss = FALSE, metric = "euclidean",
        stand = TRUE, method = "average", keep.diss = FALSE, keep.data = TRUE)

# Crystallization Plot
ctitlestr <- 
        "Clustering of Various Proteins from their Crystallization Conditions"
csubtitlestr <-  paste("Using ",
        paste(datacols[crystal_cols[2:length(crystal_cols)]], collapse = ", "),
        "(AC = ", round(crystal$ac, digits = 2), ")")
pdf('crystal_cluster.pdf')
par(plotsettings)
plot(crystal, which.plots = 2, main = ctitlestr, sub = csubtitlestr)
dev.off()

# Alternative method of plotting using hclust
phc <- hclust(physical$diss, method = "average")
# plot(phc, main = paste(ptitlestr, " (hclust)"),
#         sub = "Using Molecular Weight, % helix, % sheet, Matthews Density.")
# phcd <- as.dendrogram(phc)
# plot(phcd, main = "Experimental Physical Dendrogram")

# Exploratory (Experimental) plot(s)
explore_1cols <- c(1,13,14,16,17,23)
# Data:
explore_1data <- data.frame(cbind(table[explore_1cols]),
        row.names = 1, check.rows = TRUE)
explore_1 <- agnes(explore_1data, diss = FALSE, metric = "euclidean",
        stand = TRUE, method = "average", keep.diss = FALSE, keep.data = TRUE)

# Plot:
explore_1title <- 
        "Clustering of Various Proteins, Exploratory Table 1"
explore_1sub <-  paste("Using ",
        paste(datacols[explore_1cols[2:length(explore_1cols)]],
                collapse = ", "),
        "(AC = ", round(explore_1$ac, digits = 2), ")")
pdf('exploratory_1.pdf')
par(plotsettings)
plot(explore_1, which.plots = 2, main = explore_1title, sub = explore_1sub)
dev.off()