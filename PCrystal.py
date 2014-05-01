# Protein Crystallization Information Class
# This keeps all of the information relevant to a single protein and the 
# methods that can be used to gain information about a protein.
# Author: Sam Pollard
# Last Modified: May 1, 2014


class PCrystal(object):
	# Class-wide attribute
	# Where the protein data is stored 
	PDBDir = '/home/sam/school/cs474/pdb/'

	# Methods
	# Given a 4-character string representing the PID, try to open the file
	# in the current directory with the same name, or else query the RCSB PDB
	# to get the information about the protein
	def __init__(self, PID):
		self.PID = PID
		try:
			PDB_file = open(self.PDBDir + PID + '.pdb', 'r')
		except IOError: # Download the file from RCSB PDB (somehow)
			print "We haven't done that yet"
			return
		# Parse the data from the PID.pdb file
		# Right now it just prints out the first five lines
		for ir in range(5):
			thisline = PDB_file.readline()
			print(thisline)