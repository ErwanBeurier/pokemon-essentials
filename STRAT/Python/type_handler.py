# -*- coding=utf8 -*- 
###############################################################################
# Type handler
# Part of Pokémon STRAT, by StCooler. 
# 
# Contains the way Pokémon types are handled in my Python scripts + hidden 
# power choice. 
###############################################################################



# =============================================================================
# Main class. Contains all the types and their interactions. 
# =============================================================================

class SCTypeHandler:
	
	types = ["NORMAL", "FIGHTING", "FLYING", "POISON", 
			"GROUND", "ROCK", "BUG", "GHOST", "STEEL", 
			"FIRE", "WATER", "GRASS", "ELECTRIC", 
			"PSYCHIC", "ICE", "DRAGON", "DARK", "FAIRY"]
	
	ignored = ["QMARKS", "SHADOW", "BIRD", "CRYSTAL"]
	
	def __init__(self):
		# Initialise empty matrix: 
		self.types_matrix = {}
		self.types_interactions = {}
		
		for t in SCTypeHandler.types:
			self.types_matrix[t] = {}
			self.types_interactions[t] = [ [], [], [], []]
			# Indices: 
			# 0: t hits super effective on the list of types
			# 1: t hits normal
			# 2: t is resisted by the list of types
			# 3: the list of types is immune. 
			
			for t2 in SCTypeHandler.types: 
				self.types_matrix[t][t2] = 1.0
		
		
		# Reads from the PBS file defining the types. 
		types_file = "..\\..\\PBS\\types.txt"
		
		with open(types_file, "r") as f:
			type_name = "" 
			for l in f:
				l = l.replace("\r", "")
				l = l.replace("\n", "")
				l = l.replace(" ", "")
				
				if l.startswith("InternalName="):
					type_name = l.replace("InternalName=", "")
					
					if type_name in SCTypeHandler.ignored:
						type_name = "" 
					
				elif type_name != "" and (l.startswith("Weaknesses=") or l.startswith("Resistances=") or l.startswith("Immunities=")):
					self.change_coeff(type_name, l)
					
		# List the neutral types:
		for tp in SCTypeHandler.types:
			self.types_interactions[tp][1] = [t for t in SCTypeHandler.types 
												if t not in self.types_interactions[tp][0] 
													and t not in self.types_interactions[tp][2] 
													and t not in self.types_interactions[tp][3]]	
	
	
	
	def change_coeff(self, type_name, line):
		# Updates the matrix of coefficients depending on the content of the 
		# line.
		coeff = 1.0
		index = 1
		
		if line.startswith("Weaknesses="):
			coeff = 2.0
			index = 0
			
		elif line.startswith("Resistances="):
			coeff = 0.5 
			index = 2
			
		elif line.startswith("Immunities="):
			coeff = 0.0
			index = 3
		
		line = line.replace("Weaknesses=", "")
		line = line.replace("Resistances=", "")
		line = line.replace("Immunities=", "")
		
		list_types = line.split(",")
		
		for t in list_types:
			if t not in SCTypeHandler.ignored:
				self.types_matrix[t][type_name] = coeff 
				self.types_interactions[t][index].append(type_name)
	
	
	
	def coeff(self, att_type, def_type1, def_type2 = None):
		# Coeff of the att_type attacking the other two types. 
		if def_type2 is None:
			return self.types_matrix[att_type][def_type1]
		
		return self.types_matrix[att_type][def_type1] * self.types_matrix[att_type][def_type2]
	
	
	
	def findBestHPCoverage(self, pokemon):
		# Assuming the pokemon has all his STABs, find the best Hidden Power
		# for an optimal covergae.
		max_types = []
		max_coverage = [ [], [], [], [] ]
		stab_coverage = [ [], [], [], [] ]
		
		
		for a_type in pokemon.types:
			for i in range(len(stab_coverage)):
				stab_coverage[i] += self.types_interactions[a_type][i]
		
		# print("Types:" + str(pokemon.types))
		# input(self.types_interactions)
		
		has_high_coverage = pokemon.hasType("GROUND") or pokemon.hasType("FIRE") or pokemon.hasType("ROCK") or pokemon.hasType("FIGHTING")
		
		for a_type in SCTypeHandler.types:
			if a_type in ["NORMAL", "FAIRY"]:
				continue 
			elif a_type in SCTypeHandler.ignored:
				continue 
			elif a_type in pokemon.types:
				continue 
			
			combined_coverage = self.combineCoverage(stab_coverage, a_type)
			# print(max_coverage)
			# print(combined_coverage)
			# input("-")
			
			res = self.compareCoverage(max_coverage, combined_coverage, has_high_coverage)
			
			if res == 0:
				# Same coverage 
				max_types.append(a_type)
				
			elif res == 1:
				#Better coverage 
				for i in range(len(max_coverage)):
					max_coverage[i] = list(combined_coverage[i])
				
				max_types = [a_type]
				
			# elif res == -1: coverage1 is better than coverage2
		# input(max_types)
		return max_types 
	
	
	
	def combineCoverage(self, coverage1, a_type):
		# Combines the given coverage, with that of the given a_type. 
		coverage = [ [], [], [], [] ]
		coverage2 = [ [], [], [], [] ]
		
		for i in range(len(coverage2)):
			coverage2[i] += self.types_interactions[a_type][i]
		
		
		for i in range(len(coverage)):
			coverage[i] = list(dict.fromkeys(coverage1[i] + coverage2[i]))
		
		for i in range(len(coverage)):
			for j in range(i+1, len(coverage)):
				coverage[j] = [ t for t in coverage[j] if t not in coverage[i] ]
		
		return coverage
	
	
	
	def compareCoverage(self, coverage1, coverage2, has_high_coverage):
		# -1 = coverage1 is better than coverage2
		# 0 = same coverage
		# 1 = coverage2 is better than coverage1 
		res = [0, 0, 0, 0]
		
		for i in range(len(coverage1)):
			if i == 0 and not has_high_coverage:
				if len(coverage1[i]) + 1 < len(coverage2[i]):
					res[i] = 1
				elif len(coverage1[i]) > len(coverage2[i]) +1 :
					res[i] = -1
			else:
				if len(coverage1[i]) < len(coverage2[i]):
					res[i] = 1
				elif len(coverage1[i]) > len(coverage2[i]):
					res[i] = -1
		
		
		# 0: t hits super effective on the list of types
		# if res[0] == 0:
			# return 0
		# 1: t hits normal
		# 2: t is resisted by the list of types
		# 3: the list of types is immune. 

		# For now, res[0] (comparison of super-effectiveness) is the only that matters. 
		
		return res[0]
	
	
	


TYPE_HANDLER = SCTypeHandler()
