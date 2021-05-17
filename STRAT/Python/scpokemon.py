# -*- coding=utf8 -*- 
###############################################################################
# Main Pokémon class.
# Part of Pokémon STRAT, by StCooler. 
# 
# Contains the main class storing the data of Pokémons. 
###############################################################################


# import form_handler as fh
import type_handler as th 




# =============================================================================
# Main class. Contains the data of Pokémon for the generation of movesets. 
# =============================================================================

class SCPokemon:
	
	def __init__(self, lines, skip_stat_ordering = False):
		# lines = the whole section defining a Pokémon, from the PBS file. 
		self.name = ""
		self.base_form_id = ""
		self.bs = []
		self.ordered_stats = []
		self.types = []
		self.moves = []
		self.evolutions = []
		self.pre_evolutions = []
		self.abilities = []
		self.hidden_ability = [] 
		self.id = ""
		# To be changed manually later for form handling. 
		self.form = 0 
		self.unmega = -1 
		self.required_item = ""
		self.gender = "" # 0 == male and 1 == female, leave empty if we don't care. 
		self.total_bs = 0 
		self.required_ability = "" # string 0 or 1 or 2. 
		self.required_move = "" # string 0 or 1 or 2. 
		self.evolution_stage = 1
		self.evolution_stage_max = 1
		self.form_exists_in_team = True # True if the form is maintained in the team. Mega-evolutions, and Mimikyu, typically aren't maintained in the team, so they should have False here
		
		self.update_data(lines)
		
		if not skip_stat_ordering:
			self.orderStats()
	
	
	
	def orderStats(self):
		# Orders the stats of the Pokémon; Will be useful when determining 
		# which movesets suit it better.
		stats = [0,1,2,3,4,5] # HP / Atk / Def / Speed / SpA / SpD 
		
		# For example, use Snorlax: 
		# bs = [160, 110, 65, 65, 110, 30]
		
		try:
			# Bubble sort, because it's only for a complexity of ~7*6/2 = 21. 
			for j in range(5,0,-1):
				for i in range(0, j):
					if self.bs[stats[i]] < self.bs[stats[i+1]]:
						temp = stats[i]
						stats[i] = stats[i+1]
						stats[i+1] = temp 
		except:
			print(self.bs)
			
		# On Snorlax: 
		# stats = [0,1,5,2,4,3] 
		# In order: HP / Atk / SpD / Def / SpA / Speed 
		
		self.ordered_stats = [ [ stats[0] ] ]
		j = 0
		
		# On Snorlax, the expected result is: 
		# [ [0], [1, 5], [2, 4], [3]]
		# That is: [ [HP], [Atk, SpD], [Def, SpA], [Speed] ]
		# Mew would have: [ [0,1,2,3,4,5] ] (all stats equal)
		for i in range(1,6):
			if self.bs[stats[i]] == self.bs[self.ordered_stats[j][0]]:
				self.ordered_stats[j].append(stats[i])
			else:
				self.ordered_stats.append([stats[i]])
				j += 1
	
	
	
	def update_data(self, lines):
		# Used for defining a form this Pokémon. 
		# Just extract the data we need : internal name, base stats, and moves. 
		for line in lines:
			line = line.replace(" = ", "=")
			
			if line.startswith("["):
				# It can be a [number] OR [NAME,form]
				temp = line.replace("[", "")
				temp = temp.replace("]", "")
				
				if "," in temp:
					temp = temp.split(",")
					self.name = temp[0]
					self.form = int(temp[1])
				else:
					self.id = int(temp)
				
			elif line.startswith("InternalName="):
				self.name = line.replace("InternalName=", "")
				
			elif line.startswith("Type1="):
				# self.types.append(line.replace("Type1=", ""))
				self.types = [line.replace("Type1=", "")]
				
			elif line.startswith("Type2="):
				self.types.append(line.replace("Type2=", ""))
				
			elif line.startswith("BaseStats="):
				temp = line.replace("BaseStats=", "")
				temp = temp.split(",")
				self.bs = [int(t) for t in temp]
				self.total_bs = sum(self.bs)
				
			elif line.startswith("Moves="):
				temp = line.replace("Moves=", "")
				temp = temp.split(",")
				# temp contians a list of levels + moves.
				# temp[0] = level 
				# temp[1] = move
				# and so on. 
				
				self.moves = []
				is_level = True 
				for t in temp:
					if not is_level:
						self.moves.append(t)
					is_level = not is_level
				self.base_form_id = None 
				
			elif line.startswith("EggMoves="):
				temp = line.replace("EggMoves=", "")
				self.moves += temp.split(",")
				
			elif line.startswith("Evolutions="):
				temp = line.replace("Evolutions=", "")
				self.evolutions = []
				
				if temp != "" and "None" not in temp:
					temp = temp.split(",")
					counter = 3
					
					for t in temp:
						if counter == 3:
							self.evolutions.append(t)
							counter = 0
						counter += 1
					
			elif line.startswith("Abilities="):
				temp = line.replace("Abilities=", "")
				self.abilities = temp.split(",")
				
			elif line.startswith("HiddenAbility="):
				temp = line.replace("HiddenAbility=", "")
				self.hidden_ability = temp.split(",")
				
			elif line.startswith("MegaMove="):
				self.required_move = line.replace("MegaMove=", "")
				if self.unmega == -1:
					self.unmega = 0 
				self.moves.append(self.required_move)
				
			elif line.startswith("MegaStone="):
				self.required_item = line.replace("MegaStone=", "")
				if self.unmega == -1:
					self.unmega = 0 
					
			elif line.startswith("UnmegaForm="):
				self.unmega = int(line.replace("UnmegaForm=", ""))
		
		self.stabs = list(self.types)
	
	
	
	def canLearnMove(self, move):
		return move in self.moves
	
	
	
	def hasType(self, tp):
		return tp in self.types 
	
	
	
	def isFinalEvol(self):
		return self.evolution_stage_max == self.evolution_stage
	
	
	
	def isAirBalloonCandidate(self):
		# Give AirBalloon only to Pokmeons that would be OHKO by Earthquake
		# Only to Pokémons that are weak to GROUND + have a low defense, 
		# or to Pokemons that are very weak to GROUND. 
		if "LEVITATION" in self.abilities:
			return False 
		
		if self.hasType("FLYING") or self.hasType("GRASS") or self.hasType("BUG"):
			# Resisting types 
			return False 
		
		if self.required_item != "":
			return False 
		
		
		# Then, the Pokemon has no ground-resisting type. 
		# Chekc if it takes x1, x2 or x4 the damage from ground moves. 
		weak_types = ["ROCK", "FIRE", "ELECTRIC", "POISON", "STEEL"]
		
		num_weak = 0
		
		for t in weak_types:
			if self.hasType(t):
				num_weak += 1
		
		
		if num_weak == 1:
			# Then give Air Balloon only if the Pokemon is very "frail". 
			return self.bs[2] < 70 
		
		# Otherwise, give the Balloon only if the POkemon is very weak. 
		return num_weak == 2
	
	
	
	def isHeavyDutyBootsCandidate(self):
		# The most common Entry Hazards will be Stealth Rock. 
		# So first, check this. Because, really, almost everybody 
		# is weak to the statuses...
		if self.required_item != "":
			return False 
			
		if "MAGICGUARD" in self.abilities:
			return False 
		
		
		# Then, the Pokemon has no rock-resisting type. 
		# Chekc if it takes x1, x2 or x4 the damage from ground moves. 
		coeff = 1 
		
		if len(self.types) == 2:
			coeff = th.TYPE_HANDLER.coeff("ROCK", self.types[0], self.types[1])
		else:
			coeff = th.TYPE_HANDLER.coeff("ROCK", self.types[0])
			
		
		
		# Otherwise, give the Balloon only if the POkemon is very weak. 
		return coeff > 1 
	
	
	
	def hasMeteoAbility(self):
		# Checks if the Pokémon has an ability that changes meteo. 
		for i in range(len(self.abilities)):
			if self.abilities[i] == "SNOWWARNING":
				return i 
			elif self.abilities[i] == "SANDSTREAM":
				return i 
			elif self.abilities[i] == "DROUGHT":
				return i 
			elif self.abilities[i] == "DRIZZLE":
				return i 
		
		if "SNOWWARNING" in self.hidden_ability:
			return 2
		elif "SANDSTREAM" in self.hidden_ability:
			return 2 
		elif "DROUGHT" in self.hidden_ability:
			return 2 
		elif "DRIZZLE" in self.hidden_ability:
			return 2 
		
		return -1 
	
	
	
	def hasTerrainAbility(self):
		# Checks if the Pokémon has an ability that changes terrain.
		for i in range(len(self.abilities)):
			if self.abilities[i] == "GRASSYSURGE":
				return i 
			elif self.abilities[i] == "ELECTRICSURGE":
				return i 
			elif self.abilities[i] == "MISTYSURGE":
				return i 
			elif self.abilities[i] == "PSYCHICSURGE":
				return i 
		
		if "GRASSYSURGE" in self.hidden_ability:
			return 2
		elif "ELECTRICSURGE" in self.hidden_ability:
			return 2 
		elif "MISTYSURGE" in self.hidden_ability:
			return 2 
		elif "PSYCHICSURGE" in self.hidden_ability:
			return 2 
		
		return -1 
	
	
	
	def indexOfAbility(self, ab):
		# Returns the stupid index of the ability. 
		for i in range(len(self.abilities)):
			if self.abilities[i] == ab:
				return i
		
		if ab in self.hidden_ability:
			return 2
		
		return -1 
	
	
	
	def requireAbility(self, ab):
		# In the case when Pokémon forms can only happen if the Pokémon has 
		# a given ability (e.g. Power Construct for Zygarde).
		self.required_ability = self.indexOfAbility(ab)
		if self.required_ability == -1:
			raise Exception(self.toTiersStr() + " requires ability " + ab + ", that it doesn't have")
	
	
	
	def copy(self, lines = []):
		# Clones this Pokémon; generally for forms. 
		new_poke = SCPokemon([], skip_stat_ordering = True)
		
		new_poke.name = self.name
		new_poke.bs = list(self.bs)
		new_poke.ordered_stats = list(self.ordered_stats)
		new_poke.types = list(self.types)
		new_poke.moves = list(self.moves)
		new_poke.evolutions = list(self.evolutions)
		new_poke.pre_evolutions = list(self.pre_evolutions)
		new_poke.abilities = list(self.abilities)
		new_poke.hidden_ability = list(self.hidden_ability)
		new_poke.id = self.id
		new_poke.form = self.form
		new_poke.gender = self.gender
		new_poke.required_item = self.required_item
		new_poke.required_ability = self.required_ability
		new_poke.base_form_id = self.name
		
		new_poke.update_data(lines)
		
		new_poke.calcTotal()
		new_poke.orderStats()
		
		return new_poke
	
	
	
	def calcTotal(self):
		self.total_bs = sum(self.bs)
	
	
	
	def toTiersStr(self):
		# Returns the fspecies.
		s = self.name
		
		if self.form > 0:
			s += "_" + str(self.form)
		
		# if self.required_item != "":
			# s += "@item=" + str(self.required_item)
			
		# if self.gender != "":
			# s += "@gender=" + str(self.gender)
			
		# if self.gender != "":
			# s += "@gender=" + str(self.gender)
			
		return s 
	
	
	
	def baseFormID(self):
		# if self.unmega == -1:
			# return self.name
		# elif self.unmega == 0:
			# return self.name
		# else: 
			# return self.name + "_" + str(self.unmega)
		return self.name
	
	
	
	def convertMoveType(self, type, ab_num):
		# Changes the type of some moves, depending on the ability. 
		if ab_num < 0:
			return type 
		
		ate_abilities = ["NORMALIZE", "AERILATE", "INTOXICATE", "PIXILATE", "GALVANIZE", "REFRIGERATE", "FOUNDRY"]
		ind_abilities = [ self.indexOfAbility(ab) for ab in ate_abilities ]
		
		if sum(ind_abilities) == - len(ate_abilities):
			return type 
		
		for i in range(len(ate_abilities)):
			if ab_num == ind_abilities[i]:
				if i == 0: 
					# Normalize
					return "NORMAL"
					
				elif i == 1 and type == "NORMAL":
					# Aerilate 
					return "FLYING"
					
				elif i == 2 and type == "NORMAL":
					# Intoxicate 
					return "POISON"
					
				elif i == 3 and type == "NORMAL":
					# Pixilate 
					return "FAIRY"
					
				elif i == 4 and type == "NORMAL":
					# Galvanize 
					return "ELECTRIC"
					
				elif i == 5 and type == "NORMAL":
					# Refrigerate 
					return "ICE"
					
				elif i == 6 and type == "ROCK":
					# Foundry 
					return "FIRE"
		
		return type 
	
	
	
	def __str__(self):
		s = []
		
		# form 
		if self.form > 0:
			s.append(self.name + "," + str(self.form))
		else:
			s.append(self.name)
		
		# base stats :
		s.append("BaseStats = " + ",".join([str(b) for b in self.bs]))
		
		# Types :
		s.append("Types = " + ",".join(self.types))
		# Abilities :
		s.append("Abilities = " + ",".join(self.abilities))
		# HiddenAbility :
		s.append("HiddenAbility = " + ",".join(self.hidden_ability))
		# Moves :
		if self.form > 0 and not self.form_exists_in_team:
			s.append("Moves = Same as base form")
		else:
			s.append("Moves = " + ",".join(self.moves))
		# Evolutions
		s.append("Pre-evolutions = " + ",".join(self.pre_evolutions))
		s.append("Evolutions = " + ",".join(self.evolutions))
		
		return "\n".join(s)
	
	
	
	def to_id(self):
		if self.form == 0:
			return self.name
		else:
			return self.name + "_" + str(self.form)





if __name__ == "__main__":
	
	print("Lol, nothing to show")
	# th = SCTypeHandler()
	
	# print(th.findBestHPCoverage(POKEMONS["DRAGONITE"]))
	
	# all_forms = load_all_forms()
	
	# for form in all_forms:
		# if form.name == "VIVILLON":
			# print(form)
	
	
	
	
