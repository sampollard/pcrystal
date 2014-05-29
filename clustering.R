#!/usr/bin/R
# Clusters the protein crystallization data in two areas:
# Protein physical properties and crystallization conditions
# Author: Sam Pollard (sam.d.pollard@gmail.com)
# Last Modifed: May 28, 2014
#
# Source code taken from Ellyn Ayton
# (https://github.com/EllynAyton/Proteins/blob/master/colorTree.R)
#
# Note: For each report generated, there must be at least two entries for each
# data point (i.e. PID) where the value is not NA, or else the dissimilarity
# matrix will have NAs in it (which is not allowed).
#
# This script generates dendrograms. Others may be generated using similar
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
pdf('trees/physical_cluster_basic.pdf')
par(plotsettings)
# which.plots is 1 for banner, 2 for dendrogram
plot(physical_basic, which.plots = 2, main = paste(ptitlestr_b, " (agnes)"),
        sub = psubtitlestr_b)
exitval <- dev.off()

# Make a tree with colored leaves
dnaColor <- "red"
membraneColor <- "orange"
enzymeColor <- "purple"
signalColor <- "green"
transportColor <- "blue"
dnaBinding <- c("3G73", "3CO6", "1VDE", "1AF5", "1EVX", "2OST", "3U9J", "1GX6", "1QQC")
membrane <- c("1KN9", "3BF0", "4GWM", "3VMT", "2XCI", "2OLV", "4HHS", "1CX2", "4COX", "3N7P")
enzymes <- c("4GYR", "3I27", "3P1Z", "3V8J", "2HIV", "3L2P", "2NSF", "1FW1", "2Z6W", "4J4N")
signaling <- c("2WXW", "1A28", "1ET1", "3TH5", "3TVD", "2CLS", "3KKV", "4FG7", "3RP9", "3RDJ")
transport <- c("1PV6", "1PW4", "3O7Q", "3QS5", "3QS4", "3G61", "4PE6", "4FI3", "1F30", "1F2T")

proteinGroups <- list(dnaBinding, membrane, enzymes, signaling, transport)
colors <- c(dnaColor,membraneColor,enzymeColor,signalColor,transportColor)
names(proteinGroups) <- colors

# This function takes as input a node (that is, to be used with dendrapply) and
# a list of groups whose names are the color they are to be
colorLabels <<- function(n, groups) {
    if(is.leaf(n)) {
        a <- attributes(n)
        # Check the label
        leafcolor <- "#000000" # default color is black
        for (i in 1:length(groups)) {
            if (a$label %in% groups[[i]]) {
                leafcolor <- names(groups[i])
                break
            }
        }
        attr(n, "nodePar") <-
                c(a$nodePar, list(lab.col = leafcolor))
    }
    n # I don't know what this does but it's in all the examples
}
hc <- hclust(physical_basic$diss, method = "average")
hcd <- as.dendrogram(hc, hang = 0.05) # Hang so leaves are at different levels
prettyTree <- dendrapply(hcd, colorLabels, proteinGroups)
plot(prettyTree, main = ptitlestr_b, sub = psubtitlestr_b)
# One can call str(prettytree) to see the heights of the trees
# methods(class = class(prettytree)) to get the methods on a dendrogram

## Plotting other trees:
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
pdf('trees/physical_cluster.pdf')
par(plotsettings)
plot(physical, which.plots = 2, main = paste(ptitlestr, " (agnes)"),
        sub = psubtitlestr)
exitval <- dev.off()

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
pdf('trees/crystal_cluster.pdf')
par(plotsettings)
plot(crystal, which.plots = 2, main = ctitlestr, sub = csubtitlestr)
exitval <- dev.off()

# Alternative method of plotting using hclust
#phc <- hclust(physical$diss, method = "average")
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
pdf('trees/exploratory_1.pdf')
par(plotsettings)
plot(explore_1, which.plots = 2, main = explore_1title, sub = explore_1sub)
exitval <- dev.off()

# Exploratory (Experimental) plot(s)
explore_2cols <- c(1,10,11,14,18,21,23)
# Data:
explore_2data <- data.frame(cbind(table[explore_2cols]),
        row.names = 1, check.rows = TRUE)
explore_2 <- agnes(explore_2data, diss = FALSE, metric = "euclidean",
        stand = TRUE, method = "average", keep.diss = FALSE, keep.data = TRUE)

# Plot:
explore_2title <- 
        "Clustering of Various Proteins, Exploratory Table 2"
explore_2sub <-  paste("Using ",
        paste(datacols[explore_2cols[2:length(explore_2cols)]],
                collapse = ", "),
        "(AC = ", round(explore_2$ac, digits = 2), ")")
pdf('trees/exploratory_2.pdf')
par(plotsettings)
plot(explore_2, which.plots = 2, main = explore_2title, sub = explore_2sub)
exitval <- dev.off()