# Download the CSV of protein data for a given set of PDBIDs and download the
# pdb ent files from wwpdb
# Author: Sam Pollard
# Last Modified: May 18, 2014

import urllib2
from ftplib import FTP
import os.path
import csv
from Bio import SeqIO
from Bio.SeqUtils import ProtParam

# Wraps the input string in double quotes. E.g. wrapdblq("s") returns '"s"''
def quote(s):
	return '"'+s+'"' 

# Get the CSV custom report and save it
PDBDir = '/home/sam/school/cs474/pdb/'
reportName = 'report.csv'
customRptStart = "http://www.rcsb.org/pdb/rest/customReport?pdbids="
PDBIDListFile = open('protein_list.txt', 'r')
PDBIDList = PDBIDListFile.read()
PDBIDListFile.close()
PDBIDList = PDBIDList.rstrip() # Remove all whitespace (including \n)
customRptColumns = "&customReportColumns=structureTitle,experimentalTechnique"+\
		",releaseDate,classification,structureMolecularWeight,chainLength," +\
		"secondaryStructure,ALL,crystallizationMethod,crystallizationTempK," +\
		"phValue,densityMatthews,densityPercentSol,pdbxDetails"
customRptColumns = "&customReportColumns="+\
		"structureTitle,experimentalTechnique,classification,compound,"+\
		"expressionHost,"+\
		"structureMolecularWeight,residueCount,chainLength,"+\
		"ALL,crystallizationTempK,phValue,densityMatthews,densityPercentSol,pdbxDetails,"+\
		"crystallizationMethod,spaceGroup,macromoleculeType,secondaryStructure"
customRptEnd = "&service=wsdisplay&format=csv&ssa=n"
reporturl = customRptStart + PDBIDList + customRptColumns + customRptEnd
reporturlfile = open("reportURL.txt", 'w')
reporturlfile.write(reporturl)
reporturlfile.close()
print "Query URL used to generate report saved to \"reportURL.txt\""

reqReport = urllib2.Request(reporturl)
print "Getting custom report from RCSB..."
reportResponse = urllib2.urlopen(reqReport)
results = reportResponse.read()
results = results.replace('<br />', '\n')
results = results.replace('""', '"NA"') # So R can read empty entries
resultlist = results.split('\n')

# Remove all duplicate entries (only keep one chainId)
prevPDBID = None # So the first PDB line always gets added
trimmedresults = [resultlist[0]]
for line in resultlist[1:len(resultlist)]:
	columnlist = line.split(',')
	if len(columnlist) < 2:
		break
	if columnlist[0] != prevPDBID: # We've found a new ID to add
		prevPDBID = columnlist[0]
		trimmedresults.append(line)
resultlist = trimmedresults

# Create custom report
print "Writing custom report to " + quote(reportName)
resultlistcsv = csv.reader(resultlist, delimiter=',', quotechar='"')
outfile = open(reportName, 'w')
resultcsv = csv.writer(outfile, \
		delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
atHeader = True
hsindex = 9 # Index for helix (sheet is hsindex+1)

# Open fasta file and use it as a dictionary
fasta_index = SeqIO.index(PDBDir+'pdb_seqres.txt', 'fasta')
pIindex = 15 # Index for isoelectric point

for row in resultlistcsv:
	# Reset the reader
	helix_sheetfile = open('helix_sheet.txt', 'r')
	helix_sheetcsv = csv.reader(helix_sheetfile, delimiter=',', quotechar='"')
	# Add extra columns in header
	if atHeader:
		row.insert(hsindex, "percentAlphaHelices")
		row.insert(hsindex+1, "percentBetaSheets")
		row.insert(pIindex, "isoelectricPoint")
		row.insert(pIindex+1, "instabilityIndex")
		atHeader = False
	else: # Insert the data into the specified columns
		# Helix and Sheet data
		found = False
		for hsrow in helix_sheetcsv:
			if row[0] == hsrow[0]:
				row.insert(hsindex, hsrow[1])
				row.insert(hsindex+1, hsrow[2])
				found = True;
				break
		if found == False:
			print "No helix or sheet data found for", row[0]
			row.insert(hsindex, 'NA')
			row.insert(hsindex+1, 'NA')
		found = False # Reset for next entry
		# Isoelectric Point
		if (row[0].lower()+"_A") in fasta_index:
			seq_data = ProtParam.ProteinAnalysis(str(
					fasta_index[row[0].lower()+"_A"].seq))
			row.insert(pIindex, seq_data.isoelectric_point())
			row.insert(pIindex+1, seq_data.instability_index())
		else:
			print "No pI data found for", row[0]
			row.insert(pIindex, 'NA')
	resultcsv.writerow(row)
	helix_sheetfile.close()
fasta_index.close()
outfile.close()

# Check to see if PDB's need to be downloaded before connecting to wwpdb.org
needfiles = False
for pdbid in PDBIDList.split(','):
	pdbid = pdbid.lower()
	if not os.path.isfile(PDBDir+pdbid+'.pdb.gz') and not \
			os.path.isfile(PDBDir+pdbid+'.pdb'):
		needfiles = True
		print PDBDir+pdbid+'.pdb Not found'

# Download the PDB files via FTP
if needfiles == True:
	wwpdbftp = FTP('ftp.wwpdb.org') # Connect to host, default port
	wwpdbftp.login() # Login using anonymous username, passwd anonymous@
	wwpdbftp.getwelcome()
	FTPStart = "/pub/pdb/data/structures/divided/pdb/"
	wwpdbftp.cwd(FTPStart)
	print "Connected to WWPDB FTP"
	print "Downloading...",
	counter = 0
	for pdbid in PDBIDList.split(','):
		pdbid = pdbid.lower()
		if not os.path.isfile(PDBDir+pdbid+'.pdb.gz') and not \
				os.path.isfile(PDBDir+pdbid+'.pdb'):
			counter = counter + 1
			print pdbid,
			wwpdbftp.cwd(FTPStart+pdbid[1:3]+'/')
			wwpdbftp.retrbinary('RETR pdb'+pdbid+'.ent.gz', \
					open(PDBDir+pdbid+'.pdb.gz', 'wb').write)
	print "\nFile transfer complete.", str(counter), "files downloaded.",
	print "Closing connection"
	wwpdbftp.quit()
else:
	print "Local directory is up to date."
