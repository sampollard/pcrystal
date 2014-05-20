#!/usr/bin/R
# Clusters the protein crystallization data in two areas:
# Protein physical properties and crystallization conditions
# Author: Sam Pollard (sam.d.pollard@gmail.com)
# Last Modifed: May 20, 2014
#
# Note: For each report generated, there must be at least two entries for each
# data point (i.e. PID) where the value is not NA, or else the dissimilarity
# matrix will have NAs in it (which is not allowed).
library("cluster")
table <- read.csv("/home/sam/school/cs474/pdb/report.csv", header = TRUE,
        sep = ",")

# Data columns:
# 1 -> Protein ID (row name); 8 -> Molecular weight;
# 10 -> % alpha helix; 11 -> % beta sheet; 13 -> crystallization temp; 14 -> pH;
# 15 -> densityMatthews; 16 -> pI; 17 -> Instability Index

# Physical Data:
physical_data <- data.frame(
    cbind(table[1], table[8], table[10], table[11], table[15]),
        row.names = 1, check.rows = TRUE)
physical <- agnes(physical_data, diss = FALSE, metric = "euclidean",
      stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)
ptitlestr <- "Clustering of Various Proteins from their Physical Properties"
psubtitlestr <- paste("Using Molecular Weight, % alpha helix, % beta sheet, ",
        "Matthews Density. ",
        "AC = ", round(physical$ac, digits = 2))
pdf('physical_cluster.pdf')
plot(physical, which.plots = 2, main = ptitlestr, sub = psubtitlestr)
dev.off()

# Crystallization Data:
# TODO: Add PEG, ionic strength, viscosity
crystal_data <- data.frame(
        cbind(table[1], table[13], table[14],table[16], table[17]),
        row.names = 1, check.rows = TRUE)

# agnes: average is UPGMA, "complete" is complete linkage, "ward", "weighted"
crystal <- agnes(crystal_data, diss = FALSE, metric = "euclidean",
        stand = TRUE, method = "average", keep.diss = FALSE, keep.data = TRUE)
# which.plots is 1 for banner, 2 for dendogram
ctitlestr <- 
        "Clustering of Various Proteins from their Crystallization Conditions"
csubtitlestr <- paste("Using Temperature, pH, pI, Instability Index. ",
        "AC = ", round(crystal$ac, digits = 2))
# Plot and save the dendogram
pdf('crystal_cluster.pdf')
plot(crystal, which.plots = 2, main = ctitlestr, sub = csubtitlestr)
dev.off()