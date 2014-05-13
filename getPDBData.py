# Download the CSV of protein data for a given set of PDBIDs and download the
# pdb ent files from wwpdb
# Author: Sam Pollard
# Last Modified: May 13, 2014

import urllib2
import subprocess
from ftplib import FTP
import os.path

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
print "Query URL used to generate report saved to \'reportURL.txt\'"

reqReport = urllib2.Request(reporturl)
print "Getting custom report from RCSB..."
reportResponse = urllib2.urlopen(reqReport)
results = reportResponse.read()
results = results.replace('<br />', '\n')

# Remove all duplicate entries (only keep one chainId)
resultlist = results.split('\n')
trimmedresults = []
trimmedresults.append(resultlist[0]) # Add the header
prevPDBID = None # So the first PDB line always gets added
for line in resultlist[1:len(resultlist)]:
	columnlist = line.split(',')
	if len(columnlist) < 2:
		break
	if columnlist[0] != prevPDBID: # We've found a new ID to add
		prevPDBID = columnlist[0]
		trimmedresults.append(line)
results = "\n".join(trimmedresults)

print "Writing custom report to "+ PDBDir + reportName
outfile = open(PDBDir+reportName, 'w')
outfile.write(results)
outfile.close()

# Check to see if the need to be downloaded before connecting to wwpdb.org
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
	print "Downloading..."
	counter = 0
	for pdbid in PDBIDList.split(','):
		pdbid = pdbid.lower()
		if not os.path.isfile(PDBDir+pdbid+'.pdb.gz') and not \
				os.path.isfile(PDBDir+pdbid+'.pdb'):
			counter = counter + 1
			print pdbid+",",
			wwpdbftp.cwd(FTPStart+pdbid[1:3]+'/')
			wwpdbftp.retrbinary('RETR pdb'+pdbid+'.ent.gz', \
					open(PDBDir+pdbid+'.pdb.gz', 'wb').write)
	print "\nFile transfer complete." + counter + "files downloaded.",
	print "Closing connection"
	wwpdbftp.quit()
else:
	print "Local directory is up to date."
