# Download the CSV of protein data for a given set of PDBIDs and download the
# pdb ent files from wwpdb
# Author: Sam Pollard
# Last Modified: May 6, 2014

import urllib2
import subprocess
from ftplib import FTP
import time
import os.path

# Get the CSV custom report and save it
PDBDir = '/home/sam/school/cs474/pdb/'
reportName = 'report.csv'
customRptStart = "http://www.rcsb.org/pdb/rest/customReport?pdbids="
PDBIDList = "3G73,3L2C,3CO6,1VDE,1AF5,1EVX,2OST,1I50,4C2M,1QQC," +\
			"1KN9,3BF0,4GWM,3VMT,2XCI,2OLV,4HHS,1CX2,1PRH,2LNL," +\
			"4J5F,3I27,3P1Z,2HIV,2E2W,3L2P,2NSF,1FW1,2Z6W,4J4N," +\
			"2WXW,4EXO,1ET1,3TH5,3TVD,2CLS,3KKV,4FG7,3RP9,3RDJ," +\
			"1PV6,1PW4,3O7Q,3QS5,3QS4,3G61,3B5W,4FI3,1F30,1KJU"
customRptColumns = "&customReportColumns=structureTitle,experimentalTechnique"+\
		",releaseDate,classification,structureMolecularWeight,chainLength," +\
		"secondaryStructure,ALL,crystallizationMethod,crystallizationTempK," +\
		"phValue,densityMatthews,densityPercentSol,pdbxDetails"
customRptEnd = "&service=wsdisplay&format=csv&ssa=n"
reporturl = customRptStart + PDBIDList + customRptColumns + customRptEnd
# Run this only when needed
if False:
	reqReport = urllib2.Request(reporturl)
	print "Getting custom report from RCSB..."
	reportResponse = urllib2.urlopen(reqReport)
	results = reportResponse.read()
	results.replace('<br />', '\n')
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
print "Downloading"
for pdbid in PDBIDList.split(','):
	pdbid = pdbid.lower()
	if not os.path.isfile(PDBDir+pdbid+'.pdb.gz'):
		print pdbid+",",
		wwpdbftp.cwd(FTPStart+pdbid[1:3]+'/')
		wwpdbftp.retrbinary('RETR pdb'+pdbid+'.ent.gz', \
				open(PDBDir+pdbid+'.pdb.gz', 'wb').write)
		# time.sleep(1) # Slow things down a bit
print "\nFile transfer complete. Closing connection"
wwpdbftp.quit()