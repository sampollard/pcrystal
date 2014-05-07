# Download the CSV of protein data for a given set of PDBIDs and download the
# pdb ent files from wwpdb
# Author: Sam Pollard
# Last Modified: May 7, 2014

import urllib2
import subprocess
from ftplib import FTP
import time
import os.path

# Get the CSV custom report and save it
PDBDir = '/home/sam/school/cs474/pdb/'
reportName = 'report.csv'
customRptStart = "http://www.rcsb.org/pdb/rest/customReport?pdbids="
PDBIDListFile = open('protein_list.txt', 'r')
PDBIDList = PDBIDListFile.read()
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
print reporturl
# Run this only when needed
if True:
	reqReport = urllib2.Request(reporturl)
	print "Getting custom report from RCSB..."
	reportResponse = urllib2.urlopen(reqReport)
	results = reportResponse.read()
	results = results.replace('<br />', '\n')
	print "Writing custom report to "+ PDBDir + reportName
	outfile = open(PDBDir+reportName, 'w')
	outfile.write(results)

# Download the PDB files via FTP
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
	if not os.path.isfile(PDBDir+pdbid+'.pdb.gz'):
		counter = counter + 1
		print pdbid+",",
		wwpdbftp.cwd(FTPStart+pdbid[1:3]+'/')
		wwpdbftp.retrbinary('RETR pdb'+pdbid+'.ent.gz', \
				open(PDBDir+pdbid+'.pdb.gz', 'wb').write)
if counter == 0:
	print "Local directory is up to date. Closing connection"
else:
	print "\nFile transfer complete." + counter + "files downloaded.",
	print "Closing connection"
wwpdbftp.quit()