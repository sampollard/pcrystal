#!/usr/bin/R

# the PDB file's HELIX and SHEET records.
# Author: Clinton Burkhart
# Modifed By Sam Pollard on May 13, 2014

# Load the Bio3D library that makes it easy for us to parse
library("bio3d")

# Infile.  A list of protein IDs separated by newlines or spaces.
infile  <- "protein_list.txt"

# Outfile.  Will be recreated on every run.
outfile <- "helix_sheet.txt"

# Delete and recreate the output file.
if (file.exists(file = outfile))
{
    file.remove(file = outfile)
}

file.create(file = outfile)

# Get a list of protein IDS from infile.
# We are using a comma-separated file with no spaces between each PID
pids <- strsplit(readLines(infile), ",", fixed = TRUE) #"[[:space:]]+"
pids <- pids[[1]]
# Write the header to the outfile.
cat("Protein,% alpha helix,% beta sheet\n", file = outfile, append = TRUE)

# Iterate over every protein ID in infile.

for (pid in pids)
{
    # Get the PDB entry for this protein online.
    pdb <- read.pdb(pid)

    # Print the % alpha helix and % beta sheet values based on the number and
    # lengths of the structures compared to the number of residues in the 
    # sequence.
    helixpct <- sum(pdb$helix$end - pdb$helix$start) / length(pdb$seqres) * 100
    sheetpct <- sum(pdb$sheet$end - pdb$sheet$start) / length(pdb$seqres) * 100

    formatted <- sprintf("%s,%.2f,%.2f\n", pid, helixpct, sheetpct)
    cat(formatted, file = outfile, sep = "", append = TRUE)
}
