#!/usr/bin/R
# Clusters the protein crystallization data in two areas:
# Protein physical properties and crystallization conditions
# Author: Sam Pollard (sam.d.pollard@gmail.com)
# Last Modifed: May 18, 2014

library("cluster")
table <- read.csv("/home/sam/school/cs474/pdb/report.csv", header = TRUE,
        sep=",")
# 8 -> Molecular weight
# 10 -> % alpha helix; 11 -> % beta sheet; 13 -> crystallization temp
# 14 -> pH;
crystal_data <- cbind(table[10], table[11], table[13], table[14])

# agnes: average is UPGMA, "complete" is complete linkage, "ward", "weighted"
crystal <- agnes(crystal_data, diss = FALSE, metric = "euclidean",
      stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)
# plot(crystal)

# physical <- agnes(physical_data, diss = FALSE, metric = "euclidean",
#       stand = TRUE, method = "average", keep.diss = TRUE, keep.data = TRUE)
# plot(physical)