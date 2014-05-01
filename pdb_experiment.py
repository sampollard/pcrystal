# Query RCSB for protein information
# Author: Sam Pollard
# Last Modified: May 1, 2014

# Relevant information for proteins:
# EXPERIMENT TYPE                : X-RAY DIFFRACTION
# TEMPERATURE           (KELVIN) : 100                                
# PH                             : 7.5                                
# NUMBER OF CRYSTALS USED        : 1
# CRYSTALLIZATION CONDITIONS:
# More to come...

# How to see what methods an object can call
# [method for method in dir(object) if callable(getattr(object, method))]

from Bio.PDB import *
import urllib2
import PCrystal

# Parse one protein to get its structure and stuff
parser = PDBParser()
pdbstruct = parser.get_structure('3VNG', '/home/sam/school/cs474/pdb/3VNG.pdb')
print dir(pdbstruct) # Prints out methods or something with this instance

pcrystal_test = PCrystal.PCrystal('3VNG')

query_pdb = False

# Find all proteins whose structure has been determined by X-RAY Deffraction
# Sample query from http://www.rcsb.org/pdb/software/rest.do
if query_pdb == True:
	url = 'http://www.rcsb.org/pdb/rest/search'
	queryText = """
	<?xml version="1.0" encoding="UTF-8"?>
	<orgPdbQuery>
	<queryType>org.pdb.query.simple.ExpTypeQuery</queryType>
	<description>Experimental Method Search : Experimental Method=X-RAY, Has Experimental Data=Y</description>
	<mvStructure.expMethod.value>X-RAY</mvStructure.expMethod.value>
	<mvStructure.hasExperimentalData.value>Y</mvStructure.hasExperimentalData.value>
	</orgPdbQuery>
	"""

	print "query:\n", queryText
	print "querying PDB...\n"

	req = urllib2.Request(url, data=queryText)
	pdata = urllib2.urlopen(req)
	result = pdata.read()

	if result:
	    print "Found number of PDB entries:", result.count('\n')
	else:
	    print "Failed to retrieve results" 