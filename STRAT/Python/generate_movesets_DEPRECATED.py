# -*- coding=utf8 -*- 



import random 
import shutil 
import os 
import re 
import pkutils as pku 
from generate_tiers import * 
import form_handler as fh 



# TM_DATA = pku.TM_DATA
# TM_DATA_TRANSPOSE = pku.TM_DATA_TRANSPOSE
# ALL_FORMS = fh.load_all_forms()
# TYPE_HANDLER = pku.TYPE_HANDLER



class SCUsefulMoves:
	
	PHYSICAL = {
		"BUG": ["MEGAHORN", "LUNGE", "LEECHLIFE", "ATTACKORDER", "XSCISSOR"],
		"DARK": ["WICKEDBLOW", "DARKESTLARIAT", "HYPERSPACEFURY", "JAWLOCK", "THROATCHOP", "CRUNCH", "KNOCKOFF", "NIGHTSLASH"],
		"DRAGON": ["OUTRAGE", "DRAGONDARTS", "DRAGONHAMMER", "DRAGONCLAW"],
		"ELECTRIC": ["AURAWHEEL", "BOLTBEAK", "BOLTSTRIKE", "FUSIONBOLT", "PLASMAFISTS", "VOLTTACKLE", "ZINGZAP", "WILDCHARGE", "THUNDERPUNCH"],
		"FAIRY": ["PLAYROUGH"],
		"FIGHTING": ["SACREDSWORD", "CLOSECOMBAT", "FLYINGPRESS", "DRAINPUNCH", "HIJUMPKICK", "SUPERPOWER"],
		"FIRE": ["VCREATE", "SACREDFIRE", "PYROBALL", "FLAREBLITZ", "FIRELASH", "FIREPUNCH"],
		"FLYING": ["DRAGONSASCENT", "BRAVEBIRD", "AEROBLAST", "DRILLPECK"],
		"GHOST": ["SPECTRALTHIEF", "GHOSTGALLOP", "ZOMBIESTRIKE", "SHADOWBONE", "SPIRITSHACKLE", "PHANTOMFORCE", "SHADOWFORCE", "SHADOWCLAW"],
		"GRASS": ["GRAVAPPLE", "POWERWHIP", "WOODHAMMER", "DRUMBEATING", "PETALBLIZZARD", "LEAFBLADE", "SEEDBOMB", "HORNLEECH"],
		"GROUND": ["PRECIPICEBLADES", "THOUSANDARROWS", "EARTHQUAKE", "HIGHHORSEPOWER", "BONEMERANG", "BONERUSH", "LANDSWRATH"],
		"ICE": ["ICICLECRASH", "ICEHAMMER", "ICEPUNCH", "AVALANCHE"],
		"NORMAL": ["DOUBLEEDGE", "RETURN", "BODYSLAM", "FACADE"],
		"POISON": ["GUNKSHOT", "POISONJAB"],
		"PSYCHIC": ["ZENHEADBUTT", "PSYCHICFANGS"],
		"ROCK": ["DIAMONDSTORM", "PALEODRAIN", "HEADSMASH", "STONEEDGE"],
		"STEEL": ["SUNSTEELSTRIKE", "BEHEMOTHBLADE", "BEHEMOTHBASH", "DOUBLEIRONBASH", "METEORMASH", "GEARGRIND", "ANCHORSHOT", "IRONHEAD", "SMARTSTRIKE"],
		"WATER": ["CRABHAMMER", "FISHIOUSREND", "WATERFALL", "LIQUIDATION", "AQUATAIL"]
	}

	SPECIAL = {
		"BUG": ["BUGBUZZ", "POLLENPUFF", "SIGNALBEAM"],
		"DARK": ["FALSESURRENDER", "FIERYWRATH", "NIGHTDAZE", "DARKPULSE"],
		"DRAGON": ["CLANGINGSCALES", "DYNAMAXCANNON", "SPACIALREND", "DRAKONVOICE", "ANCIENTROAR", "DEVOUR", "COREENFORCER", "DRAGONPULSE", "DRAGONENERGY", "DRACOMETEOR"],
		"ELECTRIC": ["OVERDRIVE", "THUNDERBOLT", "DISCHARGE", "PARABOLICCHARGE"],
		"FAIRY": ["LIGHTOFRUIN", "STRANGESTEAM", "MOONBLAST", "DRAININGKISS", "DAZZLINGGLEAM", "SPIRITBREAK"],
		"FIGHTING": ["SECRETSWORD", "AURASPHERE", "FOCUSBLAST"],
		"FIRE": ["BLUEFLARE", "MAGMASTORM", "FUSIONFLARE", "MINDBLOWN", "ERUPTION", "FIREBLAST", "SEARINGSHOT", "FLAMETHROWER", "OVERHEAT"],
		"FLYING": ["OBLIVIONWING", "AIRSLASH", "HURRICANE"],
		"GHOST": ["MOONGEISTBEAM", "SHADOWBALL"],
		"GRASS": ["APPLEACID", "SEEDFLARE", "GIGADRAIN", "GRASSKNOT", "PETALDANCE", "ENERGYBALL", "LEAFSTORM"],
		"GROUND": ["EARTHPOWER"],
		"ICE": ["ICEBEAM", "FREEZEDRY"],
		"NORMAL": ["BOOMBURST", "JUDGMENT", "MULTIATTACK", "RELICSONG", "TRIATTACK", "HYPERVOICE"],
		"POISON": ["SHELLSIDEARM", "SLUDGEWAVE", "SLUDGEBOMB", "CORRODE"],
		"PSYCHIC": ["FREEZINGGLARE", "PSYCHOBOOST", "PSYSTRIKE", "PSYSHOCK", "PSYCHIC"],
		"ROCK": ["POWERGEM"],
		"STEEL": ["FLEURCANNON", "STEELBEAM", "FLASHCANNON"],
		"WATER": ["SURGINGSTRIKES", "STEAMERUPTION", "ORIGINPULSE", "WATERSHURIKEN", "HYDROPUMP", "SCALD", "SURF", "WATERSPOUT", "SNIPESHOT"]
	}

	PHYSICALPRIORITY = {
		"BUG": ["FIRSTIMPRESSION"],
		"DARK": ["SUCKERPUNCH", "PURSUIT"],
		"DRAGON": ["DRACOJET"],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": ["MACHPUNCH"],
		"FIRE": [],
		"FLYING": [],
		"GHOST": ["SHADOWSNEAK"],
		"GRASS": [],
		"GROUND": [],
		"ICE": ["ICESHARD"],
		"NORMAL": ["EXTREMESPEED", "FAKEOUT", "QUICKATTACK"],
		"POISON": [],
		"PSYCHIC": [],
		"ROCK": ["CRYSTALRUSH", "ACCELEROCK"],
		"STEEL": ["BULLETPUNCH"],
		"WATER": ["AQUAJET"]
	}

	SPECIALPRIORITY = {
		"BUG": [],
		"DARK": [],
		"DRAGON": [],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": ["VACUUMWAVE"],
		"FIRE": [],
		"FLYING": [],
		"GHOST": [],
		"GRASS": [],
		"GROUND": [],
		"ICE": [],
		"NORMAL": [],
		"POISON": [],
		"PSYCHIC": ["WORMHOLE"],
		"ROCK": [],
		"STEEL": [],
		"WATER": []
	}
	
	
	# Just for coverage.
	PHYSICALCOVERAGE = {
		"BUG": ["ATTACKORDER", "BUGBITE", "PINMISSILE"],
		"DARK": [],
		"DRAGON": ["DUALCHOP", "BREAKINGSWIPE"],
		"ELECTRIC": ["THUNDERFANG"],
		"FAIRY": [],
		"FIGHTING": ["CROSSCHOP", "HAMMERARM", "THUNDEROUSKICK", "JUMPKICK", "SKYUPPERCUT", "LOWSWEEP", "LOWKICK"],
		"FIRE": ["FIREFANG", "FLAMEWHEEL", "FLAMECHARGE"],
		"FLYING": ["AERIALACE", "FLY", "BOUNCE"],
		"GHOST": ["SHADOWPUNCH"],
		"GRASS": ["BULLETSEED"],
		"GROUND": ["THOUSANDWAVES", "DRILLRUN", "BULLDOZE", "DIG"],
		"ICE": ["ICEFANG", ],
		"NORMAL": ["HEADBUTT", "HEADCHARGE", "HYPERFANG", "SLASH"],
		"POISON": ["CROSSPOISON", "POISONTAIL"],
		"PSYCHIC": ["PSYCHOCUT"],
		"ROCK": ["ROCKSLIDE", "ROCKTOMB"],
		"STEEL": ["GYROBALL", "STEELWING", "IRONTAIL"],
		"WATER": ["RAZORSHELL"]
	}
	
	
	SPECIALCOVERAGE = {
		"BUG": [],
		"DARK": [],
		"DRAGON": [],
		"ELECTRIC": ["THUNDER"],
		"FAIRY": [],
		"FIGHTING": [],
		"FIRE": ["HEATWAVE", "FIERYDANCE", "LAVAPLUME", "MYSTICALFIRE"],
		"FLYING": [],
		"GHOST": ["HEX", "OMINOUSWIND"],
		"GRASS": [],
		"GROUND": [],
		"ICE": ["AURORABEAM", "BLIZZARD"],
		"NORMAL": [],
		"POISON": ["CLEARSMOG"],
		"PSYCHIC": ["EXTRASENSORY", "MISTBALL"],
		"ROCK": ["ANCIENTPOWER"],
		"STEEL": [],
		"WATER": []
	}
	
	
	PHYSICALMULTIHIT = {
		"BUG": ["PINMISSILE"],
		"DARK": [],
		"DRAGON": [],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": [],
		"FIRE": [],
		"FLYING": [],
		"GHOST": [],
		"GRASS": ["BULLETSEED"],
		"GROUND": [],
		"ICE": ["ICICLESPEAR"],
		"NORMAL": ["TAILSLAP", "SPIKECANNON", "FURYSWIPES", "DOUBLESLAP", "FURYATTACK"],
		"POISON": [],
		"PSYCHIC": [],
		"ROCK": ["ROCKBLAST"],
		"STEEL": [],
		"WATER": []
	}
	
	
	PULSES = {
		"BUG": [],
		"DARK": ["DARKPULSE"],
		"DRAGON": ["DRAGONPULSE"],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": ["AURASPHERE"],
		"FIRE": [],
		"FLYING": [],
		"GHOST": [],
		"GRASS": [],
		"GROUND": [],
		"ICE": [],
		"NORMAL": [],
		"POISON": [],
		"PSYCHIC": [],
		"ROCK": [],
		"STEEL": [],
		"WATER": ["ORIGINPULSE", "WATERPULSE"]
	}
	
	
	
	HEALING = [
		"RECOVER", "SLACKOFF", "SOFTBOILED", "HEALORDER", "MILKDRINK", "FLORALHEALING", "ROOST", "SYNTHESIS", "MOONLIGHT", "MORNINGSUN", "SHOREUP", "STRENGTHSAP", "PAINSPLIT", "WISH", "AQUARING", "LUNARDANCE", "HEALINGWISH", "RENAISSANCE", "JUNGLEHEALING", "LIFEDEW"
	] # Rest is not there because almost all Pokémon can learn Rest. 

	SUPPORTOFFENSIVE = [
		"FOULPLAY", "DRAGONTAIL", "CIRCLETHROW", "SEISMICTOSS", "EXPLOSION", "MIRRORCOAT", "COUNTER"
	]
	
	VOLTTURN = [
		"UTURN", "VOLTSWITCH", "PARTINGSHOT"
	]

	SUPPORT = [
		"TAUNT", "DEFOG", "DESTINYBOND", "AROMATHERAPY", "LEECHSEED", "HAZE", "ENCORE", "HEALBELL", "ROAR", "WHIRLWIND", "RAPIDSPIN", "COURTCHANGE"
	]
	
	STATUS = [
		"SPORE", "DARKVOID", "WILLOWISP", "TOXIC", "YAWN", "GLARE", "SLEEPPOWDER", "STUNSPORE", "THUNDERWAVE"
	]

	PROTECT = [
		"BANEFULBUNKER", "KINGSSHIELD", "SPIKYSHIELD", "OBSTRUCT", "PROTECT", "DETECT", "SUBSTITUTE"
	]

	HAZARDS = [
		"STEALTHROCK", "STICKYWEB", "TOXICSPIKES", "SPIKES"
	]
	
	FULLSUPPORTNOHEALING = HAZARDS + STATUS + SUPPORT + SUPPORTOFFENSIVE 
	
	FULLSUPPORT = FULLSUPPORTNOHEALING + HEALING
	
	@staticmethod
	def convertSingle(s):
		if s == "P":
			return SCUsefulMoves.PHYSICAL
		elif s == "S":
			return SCUsefulMoves.SPECIAL
		elif s == "PP":
			return SCUsefulMoves.PHYSICALPRIORITY
		elif s == "SP":
			return SCUsefulMoves.SPECIALPRIORITY
		elif s == "PC":
			return SCUsefulMoves.PHYSICALCOVERAGE
		elif s == "SC":
			return SCUsefulMoves.SPECIALCOVERAGE
		elif s == "PMH":
			return SCUsefulMoves.PHYSICALMULTIHIT
		elif s == "PU":
			return SCUsefulMoves.PULSES
		elif s == "H":
			return SCUsefulMoves.HEALING
		elif s == "SO":
			return SCUsefulMoves.SUPPORTOFFENSIVE
		elif s == "V":
			return SCUsefulMoves.VOLTTURN
		elif s == "SU":
			return SCUsefulMoves.SUPPORT
		elif s == "ST":
			return SCUsefulMoves.STATUS
		elif s == "PR":
			return SCUsefulMoves.PROTECT
		elif s == "HZ":
			return SCUsefulMoves.HAZARDS
		elif s == "FSNH":
			return SCUsefulMoves.FULLSUPPORTNOHEALING
		else: # s == "FS"
			return SCUsefulMoves.FULLSUPPORT
	
	@staticmethod
	def shouldCheckSTABs(move_specs):
		if isinstance(move_specs, dict):
			return move_specs == SCUsefulMoves.PHYSICAL or move_specs == SCUsefulMoves.SPECIAL or move_specs == SCUsefulMoves.PHYSICALMULTIHIT
		
		return False 
	
	




	
class SCPattern:
	
	# Roles : 
	LEAD = 1
	OFFENSIVE = 2
	DEFENSIVE = 3
	SUPPORT = 4
	PHYSICAL = 1 
	SPECIAL = 2
	MIXED = 3
	
	
	
	def __init__(self, move_spec1, move_spec2, move_spec3, move_spec4, main_stats):
		# array of Move IDs, a Move ID, or one of the dictionaries. 
		self.move_specs = [move_spec1, move_spec2, move_spec3, move_spec4]
		
		# Which stats are supposed to be high for this pattern.
		self.main_stats = main_stats
		
		# Specific evs for this pattern. Order : HP Atk Def Spe SpA SpD 
		self.ev = [0, 0, 0, 0, 0, 0]
		self.iv = [31, 31, 31, 31, 31, 31]
		
		# Specific ability for this pattern. For example Mega-Launcher
		self.ability = [] 
		
		# Specific items for this pattern. 
		self.items = []
		
		self.potential_items = []
		
		# Specific nature for this pattern. 
		self.nature = []
		
		# The result of the filtering of the moves.
		self.filtered_moves = [] 
		self.filtered_moves_types = [] 
		self.is_for_physical_offensive = True 
		self.is_for_special_offensive = True 
		self.maximum_speed = 255
		
		# Mostly for debug. 
		self.name = ""
		
		# Avoid curse if Ghost + avoid Curse if too fast
		self.no_curse = True 
		self.allow_sc_crystals = False 
		self.allow_sc_coats = False 
		
		# For some movesets, don't check if a stab was given. 
		self.dont_check_stabs = False # If false: DO CHECK stabs
		
		# Allow the coverage to be a STAB. 
		self.allow_coverage_stab = False 
		self.stab_given = False
		self.required_stabs = []
		
		# Checks if the Pokémon will have the room for two STABs of different types. 
		# If False, then both STABs could be possible as xth move. 
		self.room_for_double_stabs = False 
		
		# For Choice bancs/scraf and such, don't give personal items. 
		self.allow_personal_items = True 
		self.allow_heavy_duty_boots = True 
		
		# Hidden power. 
		self.hidden_power = []
		
		# Only for type 
		self.for_type = ""
		
		# Role of the moveset 
		self.role = 0
		
		# Only for Pokemon (should also specify item). 
		self.for_pokemons = []
	
	
	
	def checkDoubleOffense(self):
		
		if self.dont_check_stabs:
			self.room_for_double_stabs = False 
		
		num_offensive_moves = 0
		
		for m in range(4):
			if SCUsefulMoves.shouldCheckSTABs(self.move_specs[m]) \
				or (self.allow_coverage_stab and self.move_specs[m] == SCUsefulMoves.PHYSICALCOVERAGE) \
				or (self.allow_coverage_stab and self.move_specs[m] == SCUsefulMoves.SPECIALCOVERAGE):
				num_offensive_moves += 1
				
		self.room_for_double_stabs = (num_offensive_moves > 1)

	
	
	def filterMoves(self, pokemon, take_all_moves = False):
		filtered_moves = [ [] for i in range(4) ]
		filtered_moves_types = [ [] for i in range(4) ]
		self.stab_given = False or self.dont_check_stabs
		self.required_stabs = [] if self.dont_check_stabs else [t for t in pokemon.types]
		
		self.checkDoubleOffense()
		
		self.hidden_power = TYPE_HANDLER.findBestHPCoverage(pokemon) if self.room_for_double_stabs else []
		
		
		for m in range(4):
			if isinstance(self.move_specs[m], str):
				# It's a move id (capital name) or an addition of arrays. 
				
				if "+" in self.move_specs[m]:
					all_specs = self.move_specs[m].split("+")
					
					for s in all_specs:
						m_specs = SCUsefulMoves.convertSingle(s)
						# m_specs can be Array or Hash. 
						
						if isinstance(m_specs, list):
							f1, f2 = self.filterMovesFromArray(m_specs, pokemon)
							filtered_moves[m] += f1 
							filtered_moves_types[m] += f2 
						elif isinstance(m_specs, dict):
							f1, f2 = self.filterMovesFromHash(m_specs, pokemon, take_all_moves)
							filtered_moves[m] += f1 
							filtered_moves_types[m] += f2 
				
				elif pokemon.canLearnMove(self.move_specs[m]):
					filtered_moves[m] = [self.move_specs[m]]
					filtered_moves_types[m] = [""]
				else:
					# If the Pokemon cannot learn the specified move, 
					# then this Pattern doesn't fit. 
					return [], []
			elif isinstance(self.move_specs[m], list):
				# It's a list of move ids (strings)
				
				f1, f2 = self.filterMovesFromArray(self.move_specs[m], pokemon)
				filtered_moves[m] += f1 
				filtered_moves_types[m] += f2
				
			elif isinstance(self.move_specs[m], dict):
				# It's a dictionary PBTypes::enum -> Array
				
				f1, f2 = self.filterMovesFromHash(self.move_specs[m], pokemon, take_all_moves)
				filtered_moves[m] += f1 
				filtered_moves_types[m] += f2 
			
			if not filtered_moves[m]:
				# If no move remains, then this Pattern doesn't fit the pokemon. 
				return [], []
		
		# If the Pokémon cannot learn any STAB for that moveset, then it is not valid. 
		if not self.stab_given:
			return [], [] 
		
		return filtered_moves, filtered_moves_types
	
	
	
	def filterMovesFromArray(self, move_specs_array, pokemon):
		f_moves = []
		f_moves_types = []
		
		for mv in move_specs_array:
			
			if mv == "CURSE" and self.no_curse:
				if pokemon.hasType("GHOST") or pokemon.bs[3] > 70:
					# Avoid Curse as a setup if Ghost; or avoid giving Curse to a somwhat fast Pokemon. 
					continue 
			
			if pokemon.canLearnMove(mv):
				f_moves.append(mv)
				f_moves_types.append("")
				
		return f_moves, f_moves_types
	
	
	
	def filterMovesFromHash(self, move_specs_hash, pokemon, take_all_moves = False):
		f_moves = []
		f_moves_types = [] 
		
		# ORICORIO's special case:
		revelation_dance = self.giveRevelationDance(pokemon) if move_specs_hash == SCUsefulMoves.SPECIAL else "" 
		hidden_power_given = False 
		
		for tp in move_specs_hash.keys():
			# Do not give normal type attacks to a Pokémon that's not Normal. 
			if tp == "NORMAL" and not tp in self.required_stabs:
				continue 
			
			# First, check if tp is a STAB. If it is and we already gave STABs, then skip this type. 
			# If it is not a STAB and no STAB was given, then skip this type.
			if SCUsefulMoves.shouldCheckSTABs(move_specs_hash) \
				or (self.allow_coverage_stab and move_specs_hash == SCUsefulMoves.PHYSICALCOVERAGE) \
				or (self.allow_coverage_stab and move_specs_hash == SCUsefulMoves.SPECIALCOVERAGE):
				if len(self.required_stabs) > 0 and not tp in self.required_stabs:
					# Give only stabs at first 
					continue 
				elif len(self.required_stabs) == 0 and self.stab_given and pokemon.hasType(tp):
					# Do not give another STAB 
					continue 
			
			# else: we are in one of those two cases: 
			# Either tp is a STAB that was not given yet, in which case we will give a move of type tp 
			# Or tp is not a STAB and the Pokémon already has STABs, in which case we just give moves. 
			
			moves_for_type = 0
			
			# Oricorio
			if revelation_dance != "" and revelation_dance == tp:
				moves_for_type += 1 
				f_moves.append("REVELATIONDANCE")
				f_moves_types.append(tp)
				revelation_dance = "" 
				
			
			# Increment by 1 everytime a move of type "tp" is learnable. 
			for mv in move_specs_hash[tp]:
				if pokemon.canLearnMove(mv):
					f_moves.append(mv)
					moves_for_type += 1
					
					if SCUsefulMoves.shouldCheckSTABs(move_specs_hash):
						f_moves_types.append(tp)
						
					elif self.allow_coverage_stab:
						if move_specs_hash == SCUsefulMoves.PHYSICALCOVERAGE:						
							f_moves_types.append(tp)
							
						elif move_specs_hash == SCUsefulMoves.SPECIALCOVERAGE:
							f_moves_types.append(tp)	
						
						else:
							f_moves_types.append("")
							
					else:
						f_moves_types.append("")
				
				if not take_all_moves and moves_for_type > 1:
					# No more than 2 moves per type ; in general we do 
					# not need to go through the whole spectrum of what 
					# a pokemon can learn; the proposed movesets 
					# generally have a choice between two moves of the 
					# same type. If we added two moves of a given type, 
					# stop the loop and continue with another type. 
					# The moves are ordered by decreasing 
					# usefulness / importance / strength.
					# Only allow lots of moves of the same type if the 
					# Pokémon does not have any coverage (e.g. Lilligant)
					break 
			
			# If no move for the given type, then check the coverage!
			if self.allow_coverage_stab and tp in self.required_stabs and moves_for_type == 0:
				if move_specs_hash == SCUsefulMoves.PHYSICAL:
					for mv in SCUsefulMoves.PHYSICALCOVERAGE[tp]:
						if pokemon.canLearnMove(mv):
							f_moves.append(mv)
							moves_for_type += 1
							f_moves_types.append(tp)
						
						if not take_all_moves and moves_for_type > 1:
							break 
						
				elif move_specs_hash == SCUsefulMoves.SPECIAL:
					for mv in SCUsefulMoves.SPECIALCOVERAGE[tp]:
						if pokemon.canLearnMove(mv):
							f_moves.append(mv)
							moves_for_type += 1
							f_moves_types.append(tp)
						
						if not take_all_moves and moves_for_type > 1:
							break 
			
			
			# For example, Gyarados is Water/ Flying. But Gyarados doesn't have a Flying STAB. 
			# However, it's still a great Pokemon ! This is because the Flying type doesn't 
			# have Physical moves that non-birds can learn (Gyarados, Dragonite, Aerodactyl)
			if moves_for_type == 0 and tp == "FLYING" and pokemon.hasType("FLYING"):
				if move_specs_hash == SCUsefulMoves.PHYSICAL:
					self.required_stabs.remove(tp)
			
			# Check if a STAB was given. If no STAB given, then the moveset is not valid. 
			if SCUsefulMoves.shouldCheckSTABs(move_specs_hash) or self.allow_coverage_stab:
				if pokemon.hasType(tp) and moves_for_type > 0 and tp in self.required_stabs:
					self.stab_given = True 
					self.required_stabs.remove(tp)
					
					if len(self.required_stabs) == 0:
						break
					elif not self.dont_check_stabs and not self.room_for_double_stabs:
						# if room for double stabs, then break, because there will be another slot for the other STAB
						continue 
					else:
						break 
			
			# Hidden Power, only in the extreme cases with special moves. 
			if moves_for_type == 0 and pokemon.canLearnMove("HIDDENPOWER"):
				if move_specs_hash == SCUsefulMoves.SPECIAL and self.stab_given:
					if tp in self.hidden_power:
						f_moves.append("HIDDENPOWER" + tp)
						f_moves_types.append(tp)
						hidden_power_given = True 
		
		if hidden_power_given:
			self.hidden_power = []
		
		return f_moves, f_moves_types
	
	
	
	def hasTrick(self):
		return "TRICK" in self.move_specs
	
	
	
	def checkStats(self, pokemon):
		# Checks if the POkemon has the right profile for the Pattern. 
		# For example, do not give a Calm Mind pattern to Golem or Pinsir. 
		
		# On Snorlax, the expected ordered_stats is: 
		# [ [0], [1, 5], [2, 4], [3]]
		# That is: [ [HP], [Atk, SpD], [Def, SpA], [Speed] ]
		# Mew would have: [ [0,1,2,3,4,5] ] (all stats equal)
		# Kingdra would have: [ [1,2,4,5], [3], [0] ]
		
		if pokemon.bs[3] > self.maximum_speed:
			return False 
			
		# for ms in self.main_stats:
			# if len(ms) == 6:
				# return True 
		
		if len(pokemon.ordered_stats) == 1:
			# This means: all the stats of this Pokemon are equal. 
			# This Pattern suits it. 
			return True
		else:
			# At least two different stats. 
			
			oms = pokemon.ordered_stats[0] 
			
			if len(oms) == 1:
				oms += pokemon.ordered_stats[1]
				# For example, does not apply to Kingdra.
			
			# Minimum length of oms is 2
			# Normally the SCPattern should have several options. 
			
			for ms in self.main_stats:
				intersection = [stat for stat in oms if stat in ms]
				
				if len(ms) == len(intersection):
					# Then ms is subset of oms. 
					return True 
		
		return False 
	
	
	
	def isValid(self, pokemon, check_stats = True):
		# Checks if the pokemon has the right stats for the given Pattern.
		
		# Cheks if the Pokemon is made for using physical or special moves.
		if self.is_for_physical_offensive and not self.is_for_special_offensive and pokemon.bs[4] > pokemon.bs[1] + 10:
			return False 
		elif self.is_for_special_offensive and not self.is_for_physical_offensive and pokemon.bs[1] > pokemon.bs[4] + 10:
			return False 
		
		
		if len(self.for_pokemons) > 0 and pokemon.to_id() not in self.for_pokemons:
			return False 
		
		
		if not self.checkAbilities(pokemon):
			return False 
		
		# Check types. 
		if self.for_type != "" and not self.for_type in pokemon.types:
			return False
		
		self.filtered_moves = []
		self.filtered_moves_types = [] 
		
		if check_stats and not self.checkStats(pokemon):
			return False
		
		
		# First: filter all the moves. 
		self.filtered_moves, self.filtered_moves_types = self.filterMoves(pokemon)
		
		
		if len(self.filtered_moves) == 0:
			return False 
		
		
		if not self.atLeastFourMoves(self.filtered_moves):
			# Adds more moves. 
			self.filtered_moves, self.filtered_moves_types = self.filterMoves(pokemon, True)
		
		
		return self.atLeastFourMoves(self.filtered_moves) #and self.moreThanTwoMovesInSlots(self.filtered_moves)
	
	
	
	def checkAbilities(self, pokemon):
		if self.ability:
			for ab in pokemon.abilities:
				if ab in self.ability:
					return True
			return False 
		else:
			return True 
	
	
	
	
	def chooseItem(self, pokemon):
		# First, check if the Pokemon has a specific item, in which case it has priority.
		
		if pokemon.required_item != "":
			self.potential_items = [pokemon.required_item]
			return [pokemon.required_item]
		
		# I called them "Mega" but there are some specific item that are 
		# not mega-stone (e.g. the armors)
		# Note : here, I commented all the Mega-Stones that already appear in form_handler.
		# That means, all the Mega-Stones whose Mega-evolutions are "different" to the original Pokémon.
		# Different means: different typing, different stats (for example, Pidgeot is physical 
		# while mega-pidgeot is special)
		# mega_species = ["VENUSAUR", 
			# # "CHARIZARD", 
			# # "CHARIZARD",
			# # "BLASTOISE",
			# "ALAKAZAM", 
			# "GENGAR", 
			# "KANGASKHAN", 
			# # "PINSIR",
			# # "GYARADOS", 
			# "AERODACTYL", 
			# # "MEWTWO", 
			# "MEWTWO",
			# # "AMPHAROS", 
			# "SCIZOR", 
			# # "HERACROSS", 
			# "HOUNDOOM",
			# # "TYRANITAR", 
			# "BLAZIKEN", 
			# "GARDEVOIR", 
			# # "MAWILE",
			# "AGGRON", 
			# # "MEDICHAM", 
			# "MANECTRIC", 
			# "BANETTE",
			# "ABSOL", 
			# "GARCHOMP", 
			# "LUCARIO",
			# "ABOMASNOW", 
			# "SLOWBRO", 
			# # "SCEPTILE", 
			# # "SWAMPERT",
			# # "SABLEYE", 
			# # "ALTARIA", 
			# # "SALAMENCE", 
			# "METAGROSS",
			# "LATIOS", 
			# "LATIAS", 
			# # "LOPUNNY", 
			# # "AUDINO",
			# # "DIANCIE",
			# # "MAGCARGO",
			# # "MEGANIUM", 
			# "TYPHLOSION", 
			# "FERALIGATR", 
			# "BISHARP",
			# # "CACTURNE",
			# "CRAWDAUNT", 
			# # "MILOTIC", 
			# # "EEVEE", 
			# # "MAROWAK",
			# "DONPHAN", 
			# "REUNICLUS", 
			# # "GIRAFARIG",
			# "DELTAVENUSAUR", 
			# # "DELTACHARIZARD", 
			# # "DELTABLASTOISE",
			# # "SUNFLORA", 
			# "CRYOGONAL", 
			# # "JIRACHI",
			# "ZOROARK", 
			# "DELTABISHARP", 
			# # "STUNFISK",
			# # "ZEBSTRIKA", 
			# "DELTAGARDEVOIR", 
			# # "DELTAPIDGEOT",
			# "CAMERUPT", 
			# "SHARPEDO", 
			# "RAYQUAZA", 
			# # "PIDGEOT", 
			# "BEEDRILL", 
			# # "GLALIE", 
			# "DELTAGALLADE",
			# "GALLADE", 
			# # "FLYGON", 
			# "SHIFTRY", 
			# "DELTASCIZOR", 
			# # "GOTHITELLE", 
			# # "SPIRITOMB", 
			# "MILTANK",
			# # "DELTASUNFLORA", 
			# "CHATOT", 
			# # "HAXORUS", 
			# "POLIWRATH", 
			# "DELTAMETAGROSS1", 
			# "DELTAMETAGROSS2",
			# "POLITOED", 
			# # "DELTAMILOTIC", 
			# "DELTALUCARIO", 
			# # "DELTAFROSLASS", 
			# # "FROSLASS",
			# # "DELTAGIRAFARIG", 
			# # "DELTALOPUNNY", 
			# # "DELTASABLEYE", 
			# "DELTACAMERUPT",
			# "DELTATYPHLOSION", 
			# # "SUDOWOODO", 
			# # "DELTAGLALIE", 
			# "STEELIX", 
			# # "STEELIX",
			# "HYDREIGON", 
			# # "DELTAMAWILE", 
			# # "DELTAMEDICHAM", 
			# "DELTAMETAGROSS2",
			# # Not Mega
			# # "GIRATINA",
			# # "ARCEUS",
			# "GROUDON", 
			# "KYOGRE",
			# # "MAROWAK", 
			# # "AMAROWAK", 
			# # "MAROWAKSC1", 
			# "LATIAS", 
			# "LATIOS", 
			# "DIALGA",
			# "PALKIA", 
			# "MEWTWO", 
			# # "ZEKROM", 
			# # "TYRANITAR", 
			# # "LEAVANNY", 
			# # "FLYGON", 
			# # "DELTAVOLCARONA", 
			# # Mega for variants 
			# "BEEDRILLSC1", 
			# # "PIDGEOTSC1", 
			# # "PIDGEOTSC2", 
			# "GENGARSC1", 
			# "MAROWAKSC1", 
			# "GYARADOSSC1", 
			# "GYARADOSSC2", 
			# "GYARADOSSC3", 
			# "GYARADOSSC4", 
			# "AERODACTYLSC1", 
			# # "FLYGONSC1", 
			# # "ALTARIASC1", 
			# "MILOTICSC1", 
			# "GLALIESC1", 
			# "AUDINOSC1"]
			# #"FLYGONSC1"]
			
			
		# mega_stones = ["VENUSAURITE", 
			# # "CHARIZARDITEX", 
			# # "CHARIZARDITEY",
			# # "BLASTOISITE",
			# "ALAKAZITE", 
			# "GENGARITE", 
			# "KANGASKHANITE", 
			# # "PINSIRITE",
			# # "GYARADOSITE", 
			# "AERODACTYLITE", 
			# # "MEWTWONITEX", 
			# "MEWTWONITEY",
			# # "AMPHAROSITE", 
			# "SCIZORITE", 
			# # "HERACROSSITE", 
			# "HOUNDOOMITE",
			# # "TYRANITARITE", 
			# "BLAZIKENITE", 
			# "GARDEVOIRITE", 
			# # "MAWILITE",
			# "AGGRONITE", 
			# # "MEDICHAMITE", 
			# "MANECTRITE", 
			# "BANNETITE",
			# "ABSOLITE", 
			# "GARCHOMPITE", 
			# "LUCARIONITE",
			# "ABOMASITE", 
			# "SLOWBRONITE", 
			# # "SCEPTITE", 
			# # "SWAMPERTITE",
			# # "SABLITE", 
			# # "ALTARITE", 
			# # "SALAMENCITE", 
			# "METAGRONITE",
			# "LATIOSITE", 
			# "LATIASITE", 
			# # "LOPUNNITE", 
			# # "AUDINITE",
			# # "DIANCITE",
			# # "MAGCARGONITE",
			# # "MEGANIUMITE", 
			# "TYPHLOSIONITE", 
			# "FERALIGATITE", 
			# "BISHARPITE",
			# # "CACTURNITE",
			# "CRAWDITE", 
			# # "MILOTITE", 
			# # "EEVITE", 
			# # "MAROWITE",
			# "DONPHANITE", 
			# "REUNICLITE", 
			# # "GIRAFARIGITE",
			# "DELTAVENUSAURITE", 
			# # "DELTACHARIZARDITE", 
			# # "DELTABLASTOISINITE",
			# # "SUNFLORITE", 
			# "CRYOGONITE", 
			# # "JIRACHITE",
			# "ZORONITE", 
			# "DELTABISHARPITE", 
			# # "STUNFISKITE",
			# # "ZEBSTRIKITE", 
			# "DELTAGARDEVOIRITE", 
			# # "DELTAPIDGEOTITE",
			# "CAMERUPTITE", 
			# "SHARPEDONITE", 
			# "RAYQUAZITE", 
			# # "PIDGEOTITE", 
			# "BEEDRITE", 
			# # "GLALITITE", 
			# "DELTAGALLADITE",
			# "GALLADITE", 
			# # "FLYGONITE", 
			# "SHIFTRITE", 
			# "DELTASCIZORITE", 
			# # "GOTHITITE", 
			# # "SPIRITOMBITE", 
			# "MILTANKITE",
			# # "DELTASUNFLORITE", 
			# "CHATOTITE", 
			# # "HAXORITE", 
			# "POLIWRATHITE", 
			# "DELTAMETAGROSSITE1", 
			# "DELTAMETAGROSSITE2",
			# "POLITOEDITE", 
			# # "DELTAMILOTICITE", 
			# "DELTALUCARIONITE", 
			# # "DELTAFROSLASSITE", 
			# # "FROSLASSITE",
			# # "DELTAGIRAFARIGITE", 
			# # "DELTALOPUNNITE", 
			# # "DELTASABLENITE", 
			# "DELTACAMERUPTITE",
			# "DELTATYPHLOSIONITE", 
			# # "SUDOWOODITE", 
			# # "DELTAGLALITITE", 
			# "STEELIXITE", 
			# # "STEELIXITE2",
			# "HYDREIGONITE", 
			# # "DELTAMAWILITE", 
			# # "DELTAMEDICHAMITE",
			# "CRYSTALFRAGMENT", 
			# # Not Mega 
			# # "CRYSTALPIECE",
			# # "CRYSTALPIECE",
			# "REDORB", 
			# "BLUEORB",
			# # "THICKCLUB", 
			# # "THICKCLUB", 
			# # "THICKCLUB", 
			# "SOULDEW", 
			# "SOULDEW", 
			# "ADAMANTORB", 
			# "LUSTROUSORB", 
			# "MEWTWOMACHINE", 
			# # "ZEKROMMACHINE", 
			# # "TYRANITARMACHINE", 
			# # "LEAVANNYMACHINE", 
			# # "FLYGONMACHINE", 
			# # "DVOLCARONAARMOR", 
			# # Mega for Variants
			# "BEEDRITE", 
			# # "PIDGEOTITE", 
			# # "PIDGEOTITE", 
			# "GENGARITE", 
			# "MAROWITE", 
			# "GYARADOSITE", 
			# "GYARADOSITE", 
			# "GYARADOSITE", 
			# "GYARADOSITE", 
			# "AERODACTYLITE", 
			# # "FLYGONITE", 
			# # "ALTARITE", 
			# "MILOTITE", 
			# "GLALITITE", 
			# "AUDINITE"]
			# # "FLYGONMACHINE"]

		
		personal_items = []
		
		
		# if not self.hasTrick() and self.allow_personal_items:
			# # Trick doesn't work with Mega-Stones or Armors, so if the given Moveset uses Trick, then don't use Mega-Stones. 
			# for i in range(len(mega_species)):
				# if pokemon.name == mega_species[i]:
					# personal_items.append(mega_stones[i])
			
		
		self.potential_items = [i for i in self.items if i != "EVIOLITE" and i != "SCNORMALMAXER"] + personal_items
		
		if pokemon.hasType("POISON"):
			# Give Black Sludge instead
			for i in range(len(self.potential_items)):
				if self.potential_items[i] == "LEFTOVERS":
					self.potential_items[i] = "BLACKSLUDGE"
		
		if pokemon.hasType("NORMAL") and self.allow_sc_coats:
			sc_coats = ["SCELEMENTALCOAT", "SCMINERALCOAT", 
							"SCSWAMPCOAT", "SCFANTASYCOAT", 
							"SCMINDCOAT", "SCMATERIALCOAT", 
							"SCFORESTCOAT", "SCDEMONICCOAT", 
							"SCAQUATICCOAT"]
			self.potential_items += sc_coats
			
		if pokemon.hasType("NORMAL") and self.allow_sc_crystals:
			sc_crystals = ["SCNORMALCRYSTAL", "SCELECTRICCRYSTAL", 
							"SCFIGHTINGCRYSTAL", "SCFLYINGCRYSTAL", 
							"SCROCKCRYSTAL", "SCDARKCRYSTAL", 
							"SCFIRECRYSTAL", "SCGRASSCRYSTAL", 
							"SCPOISONCRYSTAL", "SCPSYCHICCRYSTAL", 
							"SCSTEELCRYSTAL", "SCWATERCRYSTAL", 
							"SCICECRYSTAL", "SCGROUNDCRYSTAL", 
							"SCBUGCRYSTAL", "SCDRAGONCRYSTAL", 
							"SCFAIRYCRYSTAL", "SCNORMALMAXER"]
			self.potential_items += sc_crystals
		
		if pokemon.isAirBalloonCandidate():
			# Give Air Balloon to a Pokemon that needs it. 
			self.potential_items.append("AIRBALLOON")
			
		if pokemon.isHeavyDutyBootsCandidate():
			self.potential_items.append("HEAVYDUTYBOOTS")
			
		if "EVIOLITE" in self.items and len(pokemon.evolutions) > 0:
			self.potential_items.append("EVIOLITE")
	
	
	
	def giveMeteoItem(self, ability):
		# Meteo rocks. 
		if ability == "SNOWWARNING":
			return "ICYROCK"
		elif ability == "SANDSTREAM":
			return "SMOOTHROCK"
		elif ability == "DROUGHT":
			return "HEATROCK"
		elif ability == "DRIZZLE":
			return "DAMPROCK"
		else:
			return ""
		
		# return self.potential_items
	
	
	
	def generateMovesets(self, pokemon):
		# Returns non-deterministic movesets. 
		# Returns nil or 0 if the pokemon cannot have this pattern. 
		
		
		# POKEMON_ID, Level, ITEM_ID, MOVE1_ID, MOVE2_ID, MOVE3_ID, MOVE4_ID, 
		# 	Ability num, Gender, Form, Shiny, Nature, IV_HP, IV_Atk, IV_Def, 
		# 	IV_Speed, IV_SpA, IV_SpD, EV_HP, EV_Atk, EV_Def, EV_Speed, EV_SpA, 
		# 	EV_SpD, Happiness, Nickname, Shadow or not, Role. (on the same line!)
		
		s_moves = ""
		s_natures = ""
		s_evs = ""
		s_ivs = ""
		s_abilities = ""
		s_items = ""
		
		
		
		if self.filtered_moves:
			# Give moves 
			# types_given = [] 
			# Stores the types of the given offensive moves. 
			
			# Moves 
			for m in range(4):
				s_moves += "+".join(self.filtered_moves[m]) + ","
			
			self.chooseItem(pokemon)
			
			# corresponding EVs if applicable. 
			if isinstance(self.ev[0], list):
				# Then we have a list of EV spreads. 
				# So the nature will be paired with the EVs. 
				s_evs = ""
				for i in range(len(self.ev[0])):
					ev_spread = [ str(self.ev[j][i]) for j in range(len(self.ev))]
					s_evs += "+".join(ev_spread) + ","
			else:
				ev_spread = [ str(self.ev[j]) for j in range(len(self.ev))]
				s_evs = ",".join(ev_spread) + ","
				
			# Natures
			s_natures = "+".join(self.nature)
			
			
			iv_spread = [ str(self.iv[j]) for j in range(len(self.iv))]
			s_ivs = ",".join(iv_spread)
			
			
			# Give abilities if specified 
			for ab in self.ability:
				s_abilities = str(pokemon.indexOfAbility(ab)) 
				
			# Items 
			s_items = "+".join(self.potential_items)
			
		
		
		moveset = pokemon.toTiersStr() + ",120," + s_items + "," + s_moves
		moveset += s_abilities + ","
		# Gender, Form, Shiny
		moveset += pokemon.gender + ","
		moveset += "" if pokemon.form == 0 else str(pokemon.form) 
		moveset += ",,"
		moveset += s_natures + "," + s_ivs + "," + s_evs
		# Happiness, nickname, shadow
		moveset += "255,,"
		# Role 
		moveset += "," + str(self.role)
		
		return moveset 
	
	
	
	def reset(self):
		self.filtered_moves = []
	
	def isPnotS(self):
		self.is_for_physical_offensive = True 
		self.is_for_special_offensive = False 
	
	def isSnotP(self):
		self.is_for_physical_offensive = False 
		self.is_for_special_offensive = True 
		
	def isSandP(self):
		self.is_for_physical_offensive = True 
		self.is_for_special_offensive = True 
	
	
	def giveRevelationDance(self, pokemon):
		if pokemon.name == "ORICORIO":
			t = pokemon.types
			t2 = [tp for tp in t if tp != "FLYING"]
			return t2[0]
		else:
			return "" 
	
	
	def atLeastFourMoves(self, filtered_moves):
		for i in range(4):
			if len(filtered_moves[i]) >= 4:
				return True 
		
		# Otherwise check!!!!!!
		all_moves = []
		for i in range(4):
			all_moves += filtered_moves[i]
		
		all_moves = list(dict.fromkeys(all_moves))
		
		if len(all_moves) < 4:
			return False 
		else:
			return len(set(all_moves)) > 4 
	
	
	
	def moreThanTwoMovesInSlots(self, filtered_moves):
		all_good = True 
		for i1 in range(2):
			for i2 in range(i1,3):
				for i3 in range(i2, 4):
					all_moves = filtered_moves[i1] + filtered_moves[i2] + filtered_moves[i3]
					all_moves = list(dict.fromkeys(all_moves))
					all_good = all_good and len(all_moves) > 2 
					if not all_good:
						return False 
		
		
		return True 
	
	
	def clone(self, new_evs, new_natures):
		der_clone = SCPattern(self.move_specs[0], self.move_specs[1], self.move_specs[2], 
						self.move_specs[3], [m for m in self.main_stats])
		der_clone.ev = new_evs
		der_clone.nature = new_natures
		
		der_clone.iv = [i for i in self.iv]
		der_clone.ability = [a for a in self.ability]
		der_clone.items = [i for i in self.items]
		der_clone.is_for_physical_offensive = self.is_for_physical_offensive 
		der_clone.is_for_special_offensive = self.is_for_special_offensive 
		der_clone.maximum_speed = self.maximum_speed
		der_clone.name = self.name
		der_clone.no_curse = self.no_curse
		der_clone.allow_sc_crystals = self.allow_sc_crystals 
		der_clone.allow_sc_coats = self.allow_sc_coats 
		
		# For some movesets, don't check if a stab was given. 
		der_clone.dont_check_stabs = self.dont_check_stabs # If false: DO CHECK stabs
		
		# Allow the coverage to be a STAB. 
		der_clone.allow_coverage_stab = self.allow_coverage_stab 
		der_clone.stab_given = self.stab_given
		
		# Checks if the Pokémon will have the room for two STABs of different types. 
		# If False, then both STABs could be possible as xth move. 
		der_clone.room_for_double_stabs = self.room_for_double_stabs 
		
		# For Choice bancs/scraf and such, don't give personal items. 
		der_clone.allow_personal_items = self.allow_personal_items 
		der_clone.allow_heavy_duty_boots = self.allow_heavy_duty_boots 
		
		# Only for type 
		der_clone.for_type = self.for_type
		
		return der_clone

	
	def checkRole(self):
		# EVs :
		# 0 = Hp 
		# 1 = Atk 
		# 2 = Def 
		# 3 = Speed 
		# 4 = SpA
		# 5 = SpD 
		if self.role == 0:
			# Speed and HP are not that meaningful in terms of Moveset role. 
			if self.ev[1] == 252 and self.ev[4] == 0:
				self.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
			elif self.ev[4] == 252 and self.ev[1] == 0:
				self.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
				
			if self.ev[2] == 252 and self.ev[5] <= 6:
				self.setRole(SCPattern.DEFENSIVE, SCPattern.PHYSICAL)
			elif self.ev[5] == 252 and self.ev[2] <= 6:
				self.setRole(SCPattern.DEFENSIVE, SCPattern.SPECIAL)
			
			if self.role == 0:
				print(self.ev)
				print(self.nature)
				print(self.items)
				raise Exception("Could not determine the role of this moveset")
	
	
	def setRole(self, big_role, cat):
		# big_role = Lead, Offensive, Defensive
		# cat = Physical, Special or Mixed 
		self.role = big_role * 10 + cat 
	
	
	
	



class SCStatPatterns:
	HP = [0]
	ATK = [1]
	DEF = [2]
	SPE = [3]
	SPA = [4]
	SPD = [5]
	HP_ATK = [0, 1]
	HP_DEF = [0, 2]
	HP_SPE = [0, 3]
	HP_SPA = [0, 4]
	HP_SPD = [0, 5]
	HP_ATK_SPD = [0, 1, 5]
	HP_ATK_DEF = [0, 1, 2]
	HP_SPA_DEF = [0, 2, 4]
	HP_ATK_SPA = [0, 1, 4]
	ATK_SPA_SPE = [3, 1, 4]
	ATK_SPE = [1, 3]
	SPA_SPE = [4, 3]
	DEF_SPD = [2, 5]
	ATK_DEF = [1, 2]
	ATK_SPD = [1, 5]
	SPA_DEF = [4, 2]
	SPA_SPD = [4, 5]
	ATK_SPA = [1, 4]



	
class SCSpecificPatterns:
	# For these Patterns, do not check the stats. 
	
	ALL = []
	
	
	
	#-----------------------------------
	# Geomancer 
	#-----------------------------------
	
	GEOMANCER = SCPattern(
		"GEOMANCY",
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		"FS+S+SP+SC",
		[SCStatPatterns.HP, SCStatPatterns.SPA])
	GEOMANCER.ev = [252, 0, 0, 6, 252, 0]
	GEOMANCER.nature = ["MODEST"]
	GEOMANCER.items = ["POWERHERB"]
	GEOMANCER.isSnotP()
	ALL.append(GEOMANCER)
	
	
	
	#-----------------------------------
	# Mega-Launcher
	#-----------------------------------
	
	MEGALAUNCHER = SCPattern(
		SCUsefulMoves.PULSES,
		SCUsefulMoves.PULSES,
		"PU+S",
		"S+SP+SU+SO", 
		[SCStatPatterns.SPA]) # DEF for Blastoise. 
	MEGALAUNCHER.ev = [6,0,0,252,252,0]
	MEGALAUNCHER.nature = ["TIMID", "MODEST"]
	MEGALAUNCHER.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES"]
	MEGALAUNCHER.isSnotP()
	MEGALAUNCHER.ability = ["MEGALAUNCHER"]
	ALL.append(MEGALAUNCHER)
	
	
	
	#-----------------------------------
	# Prankster
	#-----------------------------------
	
	PRANKSTER = SCPattern(
		SCUsefulMoves.SPECIAL,
		"FSNH+S",
		SCUsefulMoves.FULLSUPPORTNOHEALING + ["LIGHTSCREEN", "REFLECT"],
		SCUsefulMoves.FULLSUPPORT + ["LIGHTSCREEN", "REFLECT"],
		[SCStatPatterns.DEF, SCStatPatterns.SPA])
	PRANKSTER.ev = [6,0,0,252,252,0]
	PRANKSTER.nature = ["TIMID", "MODEST"]
	PRANKSTER.items = ["LEFTOVERS", "LIFEORB"]
	PRANKSTER.isSnotP()
	PRANKSTER.ability = ["PRANKSTER"]
	ALL.append(PRANKSTER)
	
	PRANKSTER2 = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"FSNH+P",
		SCUsefulMoves.FULLSUPPORTNOHEALING + ["LIGHTSCREEN", "REFLECT"],
		SCUsefulMoves.FULLSUPPORT + ["LIGHTSCREEN", "REFLECT"],
		[SCStatPatterns.DEF, SCStatPatterns.SPA])
	PRANKSTER2.ev = [6,252,0,252,0,0]
	PRANKSTER2.nature = ["JOLLY", "ADAMANT"]
	PRANKSTER2.items = ["LEFTOVERS", "LIFEORB"]
	PRANKSTER2.isPnotS()
	PRANKSTER2.ability = ["PRANKSTER"]
	ALL.append(PRANKSTER2)
	
	
	
	#-----------------------------------
	# Arceus
	#-----------------------------------
	
	MULTITYPESPECIAL = SCPattern(
		"JUDGMENT",
		"RECOVER",
		"S+FSNH",
		"S+FSNH",
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Arceus.
	MULTITYPESPECIAL.ev = [[252,0,0,252,6,0], [6,0,0,252,252,0]]
	MULTITYPESPECIAL.nature = ["TIMID", "MODEST"]
	MULTITYPESPECIAL.items = ["FLAMEPLATE", "SPLASHPLATE", "ZAPPLATE", "MEADOWPLATE", "ICICLEPLATE", "FISTPLATE", "TOXICPLATE", "EARTHPLATE", "SKYPLATE", "MINDPLATE", "INSECTPLATE", "STONEPLATE", "SPOOKYPLATE", "DRACOPLATE", "DREADPLATE", "IRONPLATE", "PIXIEPLATE"]
	MULTITYPESPECIAL.isSnotP()
	MULTITYPESPECIAL.dont_check_stabs = True 
	MULTITYPESPECIAL.ability = ["MULTITYPE"]
	MULTITYPESPECIAL.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(MULTITYPESPECIAL)
	
	MULTITYPESPECIAL2 = SCPattern(
		"JUDGMENT",
		"RECOVER",
		SCUsefulMoves.SPECIAL,
		["CALMMIND","NASTYPLOT","QUIVERDANCE"],
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Arceus.
	MULTITYPESPECIAL2.ev = [[252,0,0,252,6,0], [6,0,0,252,252,0]]
	MULTITYPESPECIAL2.nature = ["TIMID", "MODEST"]
	MULTITYPESPECIAL2.items = ["FLAMEPLATE", "SPLASHPLATE", "ZAPPLATE", "MEADOWPLATE", "ICICLEPLATE", "FISTPLATE", "TOXICPLATE", "EARTHPLATE", "SKYPLATE", "MINDPLATE", "INSECTPLATE", "STONEPLATE", "SPOOKYPLATE", "DRACOPLATE", "DREADPLATE", "IRONPLATE", "PIXIEPLATE"]
	MULTITYPESPECIAL2.isSnotP()
	MULTITYPESPECIAL2.dont_check_stabs = True 
	MULTITYPESPECIAL2.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	MULTITYPESPECIAL2.ability = ["MULTITYPE"]
	ALL.append(MULTITYPESPECIAL2)
	
	MULTITYPEPHYSICAL = SCPattern(
		"SWORDSDANCE",
		"RECOVER",
		"EXTREMESPEED",
		SCUsefulMoves.PHYSICAL,
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Arceus.
	MULTITYPEPHYSICAL.ev = [[6,252,0,252,0,0], [240,252,0,16,0,0], [252,6,0,252,0,0], [6,252,0,252,0,0]]
	MULTITYPEPHYSICAL.nature = ["ADAMANT", "ADAMANT", "JOLLY", "JOLLY"]
	MULTITYPEPHYSICAL.items = ["LIFEORB", "LEFTOVERS", "MUSCLEBAND", "SHELLBELL", "SCNORMALMAXER"]
	MULTITYPEPHYSICAL.isPnotS()
	MULTITYPEPHYSICAL.allow_sc_coats = True 
	MULTITYPEPHYSICAL.allow_sc_crystals = True 
	MULTITYPEPHYSICAL.dont_check_stabs = True 
	MULTITYPEPHYSICAL.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	MULTITYPEPHYSICAL.ability = ["MULTITYPE"]
	ALL.append(MULTITYPEPHYSICAL)
	
	
	
	#-----------------------------------
	# Silvally
	#-----------------------------------
	
	RKSSYSTEM = SCPattern(
		"SWORDSDANCE",
		"MULTIATTACK",
		SCUsefulMoves.PHYSICAL,
		"P+FS",
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Arceus.
	RKSSYSTEM.ev = [[6,252,0,252,0,0], [240,252,0,16,0,0], [252,6,0,252,0,0], [6,252,0,252,0,0]]
	RKSSYSTEM.nature = ["ADAMANT", "ADAMANT", "JOLLY", "JOLLY"]
	RKSSYSTEM.items = ["FIGHTINGMEMORY", "FLYINGMEMORY", "POISONMEMORY", "GROUNDMEMORY", "ROCKMEMORY", "BUGMEMORY", "GHOSTMEMORY", "STEELMEMORY", "FIREMEMORY", "WATERMEMORY", "GRASSMEMORY", "ELECTRICMEMORY", "PSYCHICMEMORY", "ICEMEMORY", "DRAGONMEMORY", "DARKMEMORY", "FAIRYMEMORY"]
	RKSSYSTEM.isPnotS()
	RKSSYSTEM.dont_check_stabs = True 
	RKSSYSTEM.ability = ["RKSSYSTEM"]
	RKSSYSTEM.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	ALL.append(RKSSYSTEM)
	
	
	
	#-----------------------------------
	# Skill link
	#-----------------------------------
	
	# Skill link
	SKILLLINK1 = SCPattern(
		["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "SHELLSMASH"],
		SCUsefulMoves.PHYSICALMULTIHIT,
		SCUsefulMoves.PHYSICALMULTIHIT,
		"P+PMH+FS+PP",
		[SCStatPatterns.SPE, SCStatPatterns.ATK])
	SKILLLINK1.ev = [6,252,0,252,0,0]
	SKILLLINK1.nature = ["ADAMANT", "JOLLY"]
	SKILLLINK1.items = ["LEFTOVERS", "LIFEORB", "MUSCLEBAND"]
	SKILLLINK1.isPnotS()
	SKILLLINK1.ability = ["SKILLLINK"]
	ALL.append(SKILLLINK1)
	
	# Skill link
	SKILLLINK2 = SCPattern(
		SCUsefulMoves.PHYSICALMULTIHIT,
		SCUsefulMoves.PHYSICALMULTIHIT,
		"PMH+P",
		"P+PMH+PP+V",
		[SCStatPatterns.SPE, SCStatPatterns.ATK])
	SKILLLINK2.ev = [6,252,0,252,0,0]
	SKILLLINK2.nature = ["ADAMANT", "JOLLY"]
	SKILLLINK2.items = ["CHOICEBAND", "LIFEORB", "MUSCLEBAND"]
	SKILLLINK2.isPnotS()
	SKILLLINK2.ability = ["SKILLLINK"]
	ALL.append(SKILLLINK2)
	
	
	
	#-----------------------------------
	# Toxtricity  
	#-----------------------------------
	
	PUNKROCK = SCPattern(
		"BOOMBURST",
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		"S+SP+V",
		[SCStatPatterns.SPA])
	PUNKROCK.ev = [6, 0, 0, 252, 252, 0]
	PUNKROCK.nature = ["MODEST", "TIMID"]
	PUNKROCK.items = ["CHOICESPECS", "LIFEORB", "THROATSPRAY", "LEFTOVERS", "WISEGLASSES"]
	PUNKROCK.ability = ["PUNKROCK"]
	PUNKROCK.isSnotP()
	ALL.append(PUNKROCK)
	
	
	
	
def adapt_pattern_for_pokemon(pokemon, pattern, wanted_role, wanted_cat, species_list, required_item, required_ability):
	
	if len(species_list) > 0 and pokemon.name not in species_list:
		return [] 
	if required_ability != "" and required_ability not in pokemon.abilities:
		return []
	if len(pattern.ability) > 0 and required_ability not in pattern.ability:
		return []
	if pattern.role != wanted_role * 10 + wanted_cat:
		return [] 
	if pokemon.required_item != "" and pokemon.required_item != required_item:
		return []
	# Then, ignore the stats,
	
	
	movesets = []
	
	req_item = pokemon.required_item
	pokemon.required_item = required_item
	req_ability = pattern.ability
	
	if required_ability != "":
		pattern.ability = [required_ability]
	
	if pattern.isValid(pokemon, False):
		movesets.append(pattern.generateMovesets(pokemon))
	
	pokemon.required_item = req_item 
	pattern.ability = req_ability
	
	return movesets
	
	
	
	
class SCAllPatterns:
	
	ALL = []
	# ALLPATTERNS = [] # Only the most useful
	# ALLPATTERNSINCASE = [] # To be used only if the POkémon has not many movesets. 
	# SPECIFICPATTERNS = [] # Priority patterns for Pokémons with special abilities or moves. 
	
	
	
	#-----------------------------------
	# Stored power for the lol 
	#-----------------------------------
	
	COSMICPOWER = SCPattern(
		"STOREDPOWER",
		["BODYPRESS", "CALMMIND"],
		["COSMICPOWER", "DEFENDORDER", "STOCKPILE"],
		SCUsefulMoves.HEALING,
		[SCStatPatterns.HP, SCStatPatterns.DEF, SCStatPatterns.SPD])
	COSMICPOWER.ev = [[252, 0, 0, 252, 6, 0],[252, 0, 252, 0, 6, 0],[252, 0, 0, 0, 6, 252]]
	COSMICPOWER.nature = ["TIMID", "BOLD", "CALM"]
	COSMICPOWER.items = ["LEFTOVERS"]
	COSMICPOWER.allow_sc_coats = True 
	COSMICPOWER.allow_sc_crystals = False 
	COSMICPOWER.for_type = "PSYCHIC"
	COSMICPOWER.isPnotS()
	COSMICPOWER.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(COSMICPOWER)
	
	
	
	#-----------------------------------
	# Offensive support 
	#-----------------------------------
	
	OFFENSIVESUPPORTPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.HEALING,
		[SCStatPatterns.ATK, SCStatPatterns.ATK_SPE])
	OFFENSIVESUPPORTPHYSICAL.ev = [[252, 6, 0, 252, 0, 0],[6, 252, 0, 252, 0, 0]]
	OFFENSIVESUPPORTPHYSICAL.nature = ["JOLLY", "JOLLY"]
	OFFENSIVESUPPORTPHYSICAL.items = ["LEFTOVERS", "LIFEORB"]
	OFFENSIVESUPPORTPHYSICAL.allow_sc_coats = True 
	OFFENSIVESUPPORTPHYSICAL.allow_sc_crystals = True 
	OFFENSIVESUPPORTPHYSICAL.isPnotS()
	OFFENSIVESUPPORTPHYSICAL.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	ALL.append(OFFENSIVESUPPORTPHYSICAL)
	
	
	OFFENSIVESUPPORTSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.HEALING,
		[SCStatPatterns.SPA, SCStatPatterns.SPA_SPE])
	OFFENSIVESUPPORTSPECIAL.ev = [[252, 0, 0, 252, 6, 0],[6, 0, 0, 252, 252, 0]]
	OFFENSIVESUPPORTSPECIAL.nature = ["TIMID", "TIMID"]
	OFFENSIVESUPPORTSPECIAL.items = ["LEFTOVERS", "LIFEORB"]
	OFFENSIVESUPPORTSPECIAL.allow_sc_coats = True 
	OFFENSIVESUPPORTSPECIAL.allow_sc_crystals = True 
	OFFENSIVESUPPORTSPECIAL.isSnotP()
	OFFENSIVESUPPORTSPECIAL.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(OFFENSIVESUPPORTSPECIAL)
	
	
	
	#-----------------------------------
	# Leads 
	#-----------------------------------
	
	LEADPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.VOLTTURN,
		SCUsefulMoves.STATUS + SCUsefulMoves.SUPPORT + SCUsefulMoves.SUPPORTOFFENSIVE,
		[SCStatPatterns.HP, SCStatPatterns.SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.HP_SPE])
	LEADPHYSICAL.ev = [252, 6, 0, 252, 0, 0]
	LEADPHYSICAL.nature = ["JOLLY"]
	LEADPHYSICAL.items = ["LEFTOVERS", "FOCUSSASH", "LIFEORB"]
	LEADPHYSICAL.isPnotS()
	LEADPHYSICAL.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	ALL.append(LEADPHYSICAL)
	
	LEADSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.VOLTTURN,
		SCUsefulMoves.STATUS + SCUsefulMoves.SUPPORT + SCUsefulMoves.SUPPORTOFFENSIVE,
		[SCStatPatterns.HP, SCStatPatterns.SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.HP_SPE])
	LEADSPECIAL.ev = [252, 0, 0, 252, 6, 0]
	LEADSPECIAL.nature = ["TIMID"]
	LEADSPECIAL.items = ["LEFTOVERS", "FOCUSSASH", "LIFEORB"]
	LEADSPECIAL.isSnotP()
	LEADSPECIAL.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(LEADSPECIAL)
	
	
	#-----------------------------------
	# Defensive movesets
	#-----------------------------------
	
	DEFENSIVEPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"P+V",
		"V+FSNH",
		SCUsefulMoves.HEALING,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	DEFENSIVEPHYSICAL.ev = [252, 0, 252, 0, 0, 6]
	DEFENSIVEPHYSICAL.nature = ["IMPISH"]
	DEFENSIVEPHYSICAL.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	DEFENSIVEPHYSICAL.isPnotS()
	DEFENSIVEPHYSICAL.allow_sc_coats = True 
	ALL.append(DEFENSIVEPHYSICAL)
	
	DEFENSIVEPHYSICAL2 = SCPattern(
		SCUsefulMoves.SPECIAL,
		"S+V",
		"V+FSNH",
		SCUsefulMoves.HEALING,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	DEFENSIVEPHYSICAL2.ev = [252, 0, 252, 0, 0, 6]
	DEFENSIVEPHYSICAL2.nature = ["BOLD"]
	DEFENSIVEPHYSICAL2.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	DEFENSIVEPHYSICAL2.isSnotP()
	DEFENSIVEPHYSICAL2.allow_sc_coats = True 
	ALL.append(DEFENSIVEPHYSICAL2)
	
	DEFENSIVESPECIAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"P+V",
		"V+FSNH",
		SCUsefulMoves.HEALING,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	DEFENSIVESPECIAL.ev = [252, 0, 6, 0, 0, 252]
	DEFENSIVESPECIAL.nature = ["CAREFUL"]
	DEFENSIVESPECIAL.items = ["LEFTOVERS", "EVIOLITE"]
	DEFENSIVESPECIAL.isPnotS()
	DEFENSIVESPECIAL.allow_sc_coats = True 
	ALL.append(DEFENSIVESPECIAL)
	
	DEFENSIVESPECIAL2 = SCPattern(
		SCUsefulMoves.SPECIAL,
		"S+V",
		"V+FSNH",
		SCUsefulMoves.HEALING,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	DEFENSIVESPECIAL2.ev = [252, 0, 6, 0, 0, 252]
	DEFENSIVESPECIAL2.nature = ["CALM"]
	DEFENSIVESPECIAL2.items = ["LEFTOVERS", "EVIOLITE"]
	DEFENSIVESPECIAL2.isSnotP()
	DEFENSIVESPECIAL2.allow_sc_coats = True 
	ALL.append(DEFENSIVESPECIAL2)
	
	
	
	#-----------------------------------
	# Support movesets:
	#-----------------------------------
	
	SUPPORTPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	SUPPORTPHYSICAL.ev = [252, 0, 252, 0, 0, 6]
	SUPPORTPHYSICAL.nature = ["IMPISH"]
	SUPPORTPHYSICAL.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	SUPPORTPHYSICAL.isPnotS()
	SUPPORTPHYSICAL.allow_sc_coats = True 
	ALL.append(SUPPORTPHYSICAL)
	
	SUPPORTPHYSICAL2 = SCPattern(
		SCUsefulMoves.SPECIAL,
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	SUPPORTPHYSICAL2.ev = [252, 0, 252, 0, 0, 6]
	SUPPORTPHYSICAL2.nature = ["BOLD"]
	SUPPORTPHYSICAL2.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	SUPPORTPHYSICAL2.isSnotP()
	SUPPORTPHYSICAL2.allow_sc_coats = True 
	ALL.append(SUPPORTPHYSICAL2)
	
	SUPPORTSPECIAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	SUPPORTSPECIAL.ev = [252, 0, 6, 0, 0, 252]
	SUPPORTSPECIAL.nature = ["CAREFUL"]
	SUPPORTSPECIAL.items = ["LEFTOVERS", "EVIOLITE"]
	SUPPORTSPECIAL.isPnotS()
	SUPPORTSPECIAL.allow_sc_coats = True 
	ALL.append(SUPPORTSPECIAL)
	
	SUPPORTSPECIAL2 = SCPattern(
		SCUsefulMoves.SPECIAL,
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	SUPPORTSPECIAL2.ev = [252, 0, 6, 0, 0, 252]
	SUPPORTSPECIAL2.nature = ["CALM"]
	SUPPORTSPECIAL2.items = ["LEFTOVERS", "EVIOLITE"]
	SUPPORTSPECIAL2.isSnotP()
	SUPPORTSPECIAL2.allow_sc_coats = True 
	ALL.append(SUPPORTSPECIAL2)
	
	
	
	#-----------------------------------
	# Wish support 
	#-----------------------------------
	WISHSUPPORT = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.FULLSUPPORT + SCUsefulMoves.VOLTTURN,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD])
	WISHSUPPORT.ev = [252, 0, 252, 0, 0, 6]
	WISHSUPPORT.nature = ["BOLD"]
	WISHSUPPORT.items = ["LEFTOVERS"]
	WISHSUPPORT.isSnotP()
	ALL.append(WISHSUPPORT)
	
	# Clone for special defense
	ALL.append(WISHSUPPORT.clone([252, 0, 6, 0, 0, 252], ["CALM"]))
	
	WISHSUPPORT2 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORT + SCUsefulMoves.VOLTTURN,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD])
	WISHSUPPORT2.ev = [252, 0, 252, 0, 0, 6]
	WISHSUPPORT2.nature = ["IMPISH"]
	WISHSUPPORT2.items = ["LEFTOVERS"]
	WISHSUPPORT2.isPnotS()
	ALL.append(WISHSUPPORT2)
	
	# Clone for special defense
	ALL.append(WISHSUPPORT2.clone([252, 0, 6, 0, 0, 252], ["CAREFUL"]))
	
	
	WISHSUPPORT3 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		"V+S+SP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WISHSUPPORT3.ev = [252, 0, 0, 252, 0, 6]
	WISHSUPPORT3.nature = ["TIMID"]
	WISHSUPPORT3.items = ["LEFTOVERS"]
	WISHSUPPORT3.isSnotP()
	WISHSUPPORT3.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(WISHSUPPORT3)
	
	WISHSUPPORT4 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		"V+P+PP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WISHSUPPORT4.ev = [252, 0, 0, 252, 0, 6]
	WISHSUPPORT4.nature = ["JOLLY"]
	WISHSUPPORT4.items = ["LEFTOVERS"]
	WISHSUPPORT4.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	WISHSUPPORT4.isPnotS()
	ALL.append(WISHSUPPORT4)
	
	
	#-----------------------------------
	# Agility sweeper 
	#-----------------------------------
	AGILITYSWEEPERPHYSICAL = SCPattern(
		["AGILITY", "ROCKPOLISH", "SHIFTGEAR", "AUTOTOMIZE"],
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+FS+PC", 
		[SCStatPatterns.HP_ATK, SCStatPatterns.ATK])
	AGILITYSWEEPERPHYSICAL.ev = [252,252,0,6,0,0]
	AGILITYSWEEPERPHYSICAL.nature = ["JOLLY", "ADAMANT"]
	AGILITYSWEEPERPHYSICAL.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "MUSCLEBAND", "SCNORMALMAXER"]
	AGILITYSWEEPERPHYSICAL.isPnotS()
	AGILITYSWEEPERPHYSICAL.allow_sc_coats = True 
	AGILITYSWEEPERPHYSICAL.allow_sc_crystals = True 
	AGILITYSWEEPERPHYSICAL.maximum_speed = 70
	ALL.append(AGILITYSWEEPERPHYSICAL)
	
	AGILITYSWEEPERSPECIAL = SCPattern(
		["AGILITY", "ROCKPOLISH", "AUTOTOMIZE"],
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"S+FS+SC", 
		[SCStatPatterns.HP_ATK, SCStatPatterns.ATK])
	AGILITYSWEEPERSPECIAL.ev = [252,0,0,6,252,0]
	AGILITYSWEEPERSPECIAL.nature = ["TIMID", "MODEST"]
	AGILITYSWEEPERSPECIAL.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER"]
	AGILITYSWEEPERSPECIAL.isSnotP()
	AGILITYSWEEPERSPECIAL.allow_sc_coats = True 
	AGILITYSWEEPERSPECIAL.allow_sc_crystals = True 
	AGILITYSWEEPERSPECIAL.maximum_speed = 70
	ALL.append(AGILITYSWEEPERSPECIAL)
	
	
	#-----------------------------------
	# Choice Band/Specs/Scarf
	#-----------------------------------
	CHOICEPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+SO+PP+PC",
		"P+V",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK])
	CHOICEPHYSICAL.ev = [6,252,0,252,0,0]
	CHOICEPHYSICAL.nature = ["JOLLY", "ADAMANT"]
	CHOICEPHYSICAL.items = ["CHOICEBAND", "CHOICESCARF"]
	CHOICEPHYSICAL.isPnotS()
	CHOICEPHYSICAL.allow_personal_items = False 
	ALL.append(CHOICEPHYSICAL)
	
	
	CHOICESPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"SP+S+SO+SC", 
		"V+S", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA])
	CHOICESPECIAL.ev = [6,0,0,252,252,0]
	CHOICESPECIAL.nature = ["TIMID", "MODEST"]
	CHOICESPECIAL.items = ["CHOICESPECS", "CHOICESCARF"]
	CHOICESPECIAL.allow_personal_items = False 
	CHOICESPECIAL.isSnotP()
	ALL.append(CHOICESPECIAL)
	
	#-----------------------------------
	# Life Orbs  
	#-----------------------------------
	LIFEORBPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+SO+PP+PC",
		"P+V+FS",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK])
	LIFEORBPHYSICAL.ev = [6,252,0,252,0,0]
	LIFEORBPHYSICAL.nature = ["JOLLY", "ADAMANT"]
	LIFEORBPHYSICAL.items = ["LIFEORB"]
	LIFEORBPHYSICAL.isPnotS()
	ALL.append(LIFEORBPHYSICAL)
	
	LIFEORBSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"S+SO+SP+SC",
		"S+V+FS",
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA])
	LIFEORBSPECIAL.ev = [6,0,0,252,252,0]
	LIFEORBSPECIAL.nature = ["TIMID", "MODEST"]
	LIFEORBSPECIAL.items = ["LIFEORB"]
	LIFEORBSPECIAL.isSnotP()
	ALL.append(LIFEORBSPECIAL)
	
	#-----------------------------------
	# Life Orb mixed 
	#-----------------------------------
	LIFEORBMIXED = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"P+S+FSH",
		[SCStatPatterns.ATK_SPA, SCStatPatterns.ATK_SPA_SPE])
	LIFEORBMIXED.ev = [0,96,0,252,160,0]
	LIFEORBMIXED.nature = ["NAIVE", "HASTY"]
	LIFEORBMIXED.items = ["LIFEORB"]
	LIFEORBMIXED.isSandP()
	LIFEORBMIXED.setRole(SCPattern.OFFENSIVE, SCPattern.MIXED)
	ALL.append(LIFEORBMIXED)
	
	
	LIFEORBMIXED2 = SCPattern(
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		"P+S+FSH",
		[SCStatPatterns.ATK_SPA, SCStatPatterns.ATK_SPA_SPE])
	LIFEORBMIXED2.ev = [0,160,0,252,96,0]
	LIFEORBMIXED2.nature = ["NAIVE", "HASTY"]
	LIFEORBMIXED2.items = ["LIFEORB"]
	LIFEORBMIXED2.isSandP()
	LIFEORBMIXED2.setRole(SCPattern.OFFENSIVE, SCPattern.MIXED)
	ALL.append(LIFEORBMIXED2)
	
	
	#-----------------------------------
	# Shell Smash
	#-----------------------------------
	SETUPSHELLSMASHPHYSICAL2 = SCPattern(
		"SHELLSMASH",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO+PC", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK])
	SETUPSHELLSMASHPHYSICAL2.ev = [6,252,0,252,0,0]
	SETUPSHELLSMASHPHYSICAL2.nature = ["JOLLY", "ADAMANT"]
	SETUPSHELLSMASHPHYSICAL2.items = ["WHITEHERB"]
	SETUPSHELLSMASHPHYSICAL2.isPnotS()
	ALL.append(SETUPSHELLSMASHPHYSICAL2)
	
	SETUPSHELLSMASHSPECIAL = SCPattern(
		"SHELLSMASH",
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SO+SC", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA])
	SETUPSHELLSMASHSPECIAL.ev = [6,0,0,252,252,0]
	SETUPSHELLSMASHSPECIAL.nature = ["JOLLY", "ADAMANT"]
	SETUPSHELLSMASHSPECIAL.items = ["WHITEHERB"]
	SETUPSHELLSMASHSPECIAL.isSnotP()
	ALL.append(SETUPSHELLSMASHSPECIAL)
	
	
	#-----------------------------------
	# Clangorous Souls
	#-----------------------------------
	CLANGOROUSSOUL = SCPattern(
		"CLANGOROUSSOUL",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK])
	CLANGOROUSSOUL.ev = [6,252,0,252,0,0]
	CLANGOROUSSOUL.nature = ["JOLLY", "ADAMANT"]
	CLANGOROUSSOUL.items = ["THROATSPRAY"]
	CLANGOROUSSOUL.isPnotS()
	ALL.append(CLANGOROUSSOUL)
	
	
	CLANGOROUSSOUL1 = SCPattern(
		"CLANGOROUSSOUL",
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SO", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA])
	CLANGOROUSSOUL1.ev = [6,0,0,252,252,0]
	CLANGOROUSSOUL1.nature = ["TIMID", "MODEST"]
	CLANGOROUSSOUL1.items = ["THROATSPRAY"]
	CLANGOROUSSOUL1.isPnotS()
	ALL.append(CLANGOROUSSOUL1)
	
	
	#-----------------------------------
	# Belly drum
	#-----------------------------------
	SETUPBELLYDRUM = SCPattern(
		"BELLYDRUM",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO+PC", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK])
	SETUPBELLYDRUM.ev = [6,252,0,252,0,0]
	SETUPBELLYDRUM.nature = ["JOLLY", "ADAMANT"]
	SETUPBELLYDRUM.items = ["SITRUSBERRY"]
	SETUPBELLYDRUM.isPnotS()
	ALL.append(SETUPBELLYDRUM)
	
	
	#-----------------------------------
	# Physical bulky setup heal 
	#-----------------------------------
	SETUPPHYSICALBULKY = SCPattern(
		["COIL", "BULKUP", "CURSE"], 
		SCUsefulMoves.PHYSICAL, 
		"P+PP", 
		"PP+P+SU+H+ST+HZ",
		[SCStatPatterns.HP_ATK, SCStatPatterns.HP_ATK_SPD, SCStatPatterns.ATK_SPD, SCStatPatterns.ATK])
	SETUPPHYSICALBULKY.ev = [[252,252,0,0,0,6], [252,252,0,0,0,6], [252,6,0,0,0,252]]
	SETUPPHYSICALBULKY.nature = ["BRAVE", "ADAMANT", "CAREFUL"]
	SETUPPHYSICALBULKY.items = ["LEFTOVERS", "SHELLBELL"]
	SETUPPHYSICALBULKY.isPnotS()
	SETUPPHYSICALBULKY.allow_sc_coats = True 
	SETUPPHYSICALBULKY.allow_sc_crystals = True 
	SETUPPHYSICALBULKY.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	ALL.append(SETUPPHYSICALBULKY)
	
	
	#-----------------------------------
	# Setup Physical Sweeper 
	#-----------------------------------
	SETUPPHYSICALSWEEPER = SCPattern(
		["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "NORETREAT"],
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SU+H+ST+PC",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK])
	SETUPPHYSICALSWEEPER.ev = [6,252,0,252,0,0]
	SETUPPHYSICALSWEEPER.nature = ["JOLLY", "ADAMANT"]
	SETUPPHYSICALSWEEPER.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "MUSCLEBAND", "SCNORMALMAXER"]
	SETUPPHYSICALSWEEPER.isPnotS()
	SETUPPHYSICALSWEEPER.allow_sc_crystals = True 
	ALL.append(SETUPPHYSICALSWEEPER)
	
	
	#-----------------------------------
	# Special bulky setup heal support
	#-----------------------------------
	SETUPSPECIALBULKY = SCPattern(
		["CALMMIND", "QUIVERDANCE"], 
		SCUsefulMoves.SPECIAL, 
		"SU+HZ+ST",
		"S+H",
		[SCStatPatterns.HP_DEF, SCStatPatterns.HP_SPD, SCStatPatterns.HP_SPA_DEF, SCStatPatterns.DEF_SPD])
	SETUPSPECIALBULKY.ev = [252,0,252,0,6,0]
	SETUPSPECIALBULKY.nature = ["BOLD"]
	SETUPSPECIALBULKY.items = ["LEFTOVERS", "EVIOLITE"]
	SETUPSPECIALBULKY.isSnotP()
	SETUPSPECIALBULKY.allow_sc_coats = True 
	SETUPSPECIALBULKY.allow_sc_crystals = True 
	ALL.append(SETUPSPECIALBULKY)
	
	
	#-----------------------------------
	# Leads 
	#-----------------------------------
	# Special bulky setup
	SETUPSPECIALBULKY2 = SCPattern(
		["CALMMIND"], 
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SU+H+ST+SC", 
		[SCStatPatterns.HP_SPA, SCStatPatterns.HP_SPA_DEF])
	SETUPSPECIALBULKY2.ev = [[252,0,6,0,252,0], [252,0,6,0,252,0], [252,0,252,0,6,0]]
	SETUPSPECIALBULKY2.nature = ["QUIET", "MODEST", "BOLD"]
	SETUPSPECIALBULKY2.items = ["LEFTOVERS", "SHELLBELL", "EVIOLITE"]
	SETUPSPECIALBULKY2.isSnotP()
	SETUPSPECIALBULKY2.allow_sc_coats = True 
	SETUPSPECIALBULKY2.allow_sc_crystals = True 
	SETUPSPECIALBULKY2.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(SETUPSPECIALBULKY2)
	
	
	#-----------------------------------
	# Special bulky + physical setup
	#-----------------------------------
	SETUPSPECIALBULKY3 = SCPattern(
		["CALMMIND", "QUIVERDANCE"], 
		"IRONDEFENSE",
		SCUsefulMoves.SPECIAL, 
		"FS+S+SP", 
		[SCStatPatterns.DEF_SPD, SCStatPatterns.HP_SPD])
	SETUPSPECIALBULKY3.ev = [[252,0,6,0,252,0], [252,0,6,0,252,0], [252,0,252,0,6,0]]
	SETUPSPECIALBULKY3.nature = ["QUIET", "MODEST", "BOLD"]
	SETUPSPECIALBULKY3.items = ["LEFTOVERS", "SHELLBELL", "EVIOLITE"]
	SETUPSPECIALBULKY3.isSnotP()
	SETUPSPECIALBULKY3.allow_sc_coats = True 
	SETUPSPECIALBULKY3.allow_sc_crystals = True 
	SETUPSPECIALBULKY3.setRole(SCPattern.DEFENSIVE, SCPattern.PHYSICAL)
	ALL.append(SETUPSPECIALBULKY3)
	
	
	#-----------------------------------
	# Setup Special Sweeper 
	#-----------------------------------
	SETUPSPECIALSWEEPER = SCPattern(
		["QUIVERDANCE", "CALMMIND", "TAILGLOW", "NASTYPLOT"],
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SU+H+ST+HZ+SC",
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA])
	SETUPSPECIALSWEEPER.ev = [6,0,0,252,252,0]
	SETUPSPECIALSWEEPER.nature = ["TIMID", "MODEST"]
	SETUPSPECIALSWEEPER.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER"]
	SETUPSPECIALSWEEPER.isSnotP()
	SETUPSPECIALSWEEPER.allow_sc_crystals = True 
	ALL.append(SETUPSPECIALSWEEPER)
	



class SCPatternsInCase:
	
	ALL = []
	
	# Assault vest - Physical
	ASSAULTVESTPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"V+P",
		"P+PP+SO+PC", 
		[SCStatPatterns.ATK, SCStatPatterns.HP_ATK, SCStatPatterns.HP_ATK_SPD])
	ASSAULTVESTPHYSICAL.ev = [252,252,6,0,0,0]
	ASSAULTVESTPHYSICAL.nature = ["ADAMANT"]
	ASSAULTVESTPHYSICAL.items = ["ASSAULTVEST"]
	ASSAULTVESTPHYSICAL.isPnotS()
	ASSAULTVESTPHYSICAL.allow_sc_coats = True 
	ASSAULTVESTPHYSICAL.allow_sc_crystals = True 
	ALL.append(ASSAULTVESTPHYSICAL)
	
	ASSAULTVESTPHYSICAL2 = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"V+P",
		"P+PP+SO+PC", 
		[SCStatPatterns.HP, SCStatPatterns.HP_ATK_SPD, SCStatPatterns.HP_SPD, SCStatPatterns.SPD])
	ASSAULTVESTPHYSICAL2.ev = [252,6,252,0,0,0]
	ASSAULTVESTPHYSICAL2.nature = ["IMPISH"]
	ASSAULTVESTPHYSICAL2.items = ["ASSAULTVEST"]
	ASSAULTVESTPHYSICAL2.isPnotS()
	ASSAULTVESTPHYSICAL2.allow_sc_coats = True 
	ASSAULTVESTPHYSICAL2.allow_sc_crystals = True 
	ASSAULTVESTPHYSICAL2.allow_personal_items = False 
	ALL.append(ASSAULTVESTPHYSICAL2)
	
	ASSAULTVESTSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"V+S", 
		"S+SP+SO+SC", 
		[SCStatPatterns.SPA, SCStatPatterns.HP_SPA, SCStatPatterns.HP_SPA_DEF])
	ASSAULTVESTSPECIAL.ev = [252,0,6,0,252,0]
	ASSAULTVESTSPECIAL.nature = ["MODEST"]
	ASSAULTVESTSPECIAL.items = ["ASSAULTVEST"]
	ASSAULTVESTSPECIAL.isSnotP()
	ASSAULTVESTSPECIAL.allow_sc_coats = True 
	ASSAULTVESTSPECIAL.allow_sc_crystals = True 
	ALL.append(ASSAULTVESTSPECIAL)
	
	ASSAULTVESTSPECIAL2 = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"V+S", 
		"S+SP+SO", 
		[SCStatPatterns.HP, SCStatPatterns.HP_SPA_DEF, SCStatPatterns.HP_SPD, SCStatPatterns.SPD])
	ASSAULTVESTSPECIAL2.ev = [252,0,252,0,6,0]
	ASSAULTVESTSPECIAL2.nature = ["BOLD"]
	ASSAULTVESTSPECIAL2.items = ["ASSAULTVEST"]
	ASSAULTVESTSPECIAL2.isSnotP()
	ASSAULTVESTSPECIAL2.allow_personal_items = False 
	ASSAULTVESTSPECIAL2.allow_sc_coats = True 
	ASSAULTVESTSPECIAL2.allow_sc_crystals = True 
	ALL.append(ASSAULTVESTSPECIAL2)
	
	
	
	# Rest + Sleep Talk + 1 move + Support 
	RESTDEFENSIVE = SCPattern(
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.FULLSUPPORTNOHEALING, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD])
	RESTDEFENSIVE.ev = [252,0,6,0,0,252]
	RESTDEFENSIVE.nature = ["CAREFUL"]
	RESTDEFENSIVE.items = ["LEFTOVERS", "EVIOLITE"]
	RESTDEFENSIVE.isPnotS()
	RESTDEFENSIVE.allow_sc_coats = True 
	ALL.append(RESTDEFENSIVE)
	
	RESTDEFENSIVE2 = SCPattern(
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.FULLSUPPORTNOHEALING, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD])
	RESTDEFENSIVE2.ev = [252,0,6,0,0,252]
	RESTDEFENSIVE2.nature = ["CALM"]
	RESTDEFENSIVE2.items = ["LEFTOVERS", "EVIOLITE"]
	RESTDEFENSIVE2.isSnotP()
	RESTDEFENSIVE2.allow_sc_coats = True 
	ALL.append(RESTDEFENSIVE2)
	
	RESTDEFENSIVE3 = SCPattern(
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.FULLSUPPORTNOHEALING, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD])
	RESTDEFENSIVE3.ev = [252,0,252,0,0,6]
	RESTDEFENSIVE3.nature = ["IMPISH"]
	RESTDEFENSIVE3.items = ["LEFTOVERS", "EVIOLITE"]
	RESTDEFENSIVE3.isPnotS()
	RESTDEFENSIVE3.allow_sc_coats = True 
	ALL.append(RESTDEFENSIVE3)
	
	RESTDEFENSIVE4 = SCPattern(
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.FULLSUPPORTNOHEALING, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD])
	RESTDEFENSIVE4.ev = [252,0,252,0,0,6]
	RESTDEFENSIVE4.nature = ["BOLD"]
	RESTDEFENSIVE4.items = ["LEFTOVERS", "EVIOLITE"]
	RESTDEFENSIVE4.isSnotP()
	RESTDEFENSIVE4.allow_sc_coats = True 
	ALL.append(RESTDEFENSIVE4)
	
	# Choice with Trick. 
	CHOICEPHYSICALTRICK = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+PP+V+PC", 
		"TRICK", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK])
	CHOICEPHYSICALTRICK.ev = [6,252,0,252,0,0]
	CHOICEPHYSICALTRICK.nature = ["JOLLY"]
	CHOICEPHYSICALTRICK.items = ["CHOICESCARF"]
	CHOICEPHYSICALTRICK.isPnotS()
	ALL.append(CHOICEPHYSICALTRICK)
	
	CHOICESPECIALTRICK = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"S+SP+V+SC", 
		"TRICK", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA])
	CHOICESPECIALTRICK.ev = [6,0,0,252,252,0]
	CHOICESPECIALTRICK.nature = ["TIMID"]
	CHOICESPECIALTRICK.items = ["CHOICESCARF"]
	CHOICESPECIALTRICK.isSnotP()
	ALL.append(CHOICESPECIALTRICK)
	
	
	# CRO (Bulk Up + Rest + Sleep Talk + 1 move)
	CROPHYSICAL = SCPattern(
		["COIL", "BULKUP", "CURSE"], 
		SCUsefulMoves.PHYSICAL, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD])
	CROPHYSICAL.ev = [252,6,0,0,0,252]
	CROPHYSICAL.nature = ["CAREFUL"]
	CROPHYSICAL.items = ["LEFTOVERS"]
	CROPHYSICAL.isPnotS()
	ALL.append(CROPHYSICAL)
	
	
	# CRO (CM + Rest + Sleep Talk + 1 move)
	CROSPECIAL = SCPattern(
		["CALMMIND", "QUIVERDANCE"], 
		SCUsefulMoves.SPECIAL, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD])
	CROSPECIAL.ev = [252,0,252,0,6,0]
	CROSPECIAL.nature = ["BOLD"]
	CROSPECIAL.items = ["LEFTOVERS"]
	CROSPECIAL.isSnotP()
	ALL.append(CROSPECIAL)
	
	
	
	# Support movesets:
	SUPPORTPHYSICAL = SCPattern(
		"P+PC",
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	SUPPORTPHYSICAL.ev = [252, 0, 252, 0, 0, 6]
	SUPPORTPHYSICAL.nature = ["IMPISH"]
	SUPPORTPHYSICAL.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	SUPPORTPHYSICAL.isPnotS()
	SUPPORTPHYSICAL.allow_sc_coats = True 
	ALL.append(SUPPORTPHYSICAL)
	
	SUPPORTPHYSICAL2 = SCPattern(
		"S+SC",
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD, SCStatPatterns.DEF])
	SUPPORTPHYSICAL2.ev = [252, 0, 252, 0, 0, 6]
	SUPPORTPHYSICAL2.nature = ["BOLD"]
	SUPPORTPHYSICAL2.items = ["LEFTOVERS", "ROCKYHELMET", "EVIOLITE"]
	SUPPORTPHYSICAL2.isSnotP()
	SUPPORTPHYSICAL2.allow_sc_coats = True 
	ALL.append(SUPPORTPHYSICAL2)
	
	SUPPORTSPECIAL = SCPattern(
		"P+PC",
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	SUPPORTSPECIAL.ev = [252, 0, 6, 0, 0, 252]
	SUPPORTSPECIAL.nature = ["CAREFUL"]
	SUPPORTSPECIAL.items = ["LEFTOVERS", "EVIOLITE"]
	SUPPORTSPECIAL.isPnotS()
	SUPPORTSPECIAL.allow_sc_coats = True 
	ALL.append(SUPPORTSPECIAL)
	
	SUPPORTSPECIAL2 = SCPattern(
		"S+SC",
		"V+FSNH",
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_SPD, SCStatPatterns.DEF_SPD, SCStatPatterns.SPD])
	SUPPORTSPECIAL2.ev = [252, 0, 6, 0, 0, 252]
	SUPPORTSPECIAL2.nature = ["CALM"]
	SUPPORTSPECIAL2.items = ["LEFTOVERS", "EVIOLITE"]
	SUPPORTSPECIAL2.isSnotP()
	SUPPORTSPECIAL2.allow_sc_coats = True 
	ALL.append(SUPPORTSPECIAL2)
	



	
	

SPECIFIC_MOVESETS = [
"SMEARGLE,120,FOCUSSASH,STICKYWEB+STEALTHROCK+TOXICSPIKES+SPIKES,NUZZLE+SPORE+GLARE+DARKVOID,TAUNT,WHIRLWIND,0,,,,JOLLY,31,31,31,31,31,31,252,0,6,252,0,0,,,,42",
"SMEARGLE,120,FOCUSSASH,STICKYWEB+TOXICSPIKES+SPIKES,NUZZLE+GLARE+DESTINYBOND,STEALTHROCK,SPORE+DARKVOID,0,,,,JOLLY,31,31,31,31,31,31,0,0,252,252,0,6,,,,42",
"SMEARGLE,120,SITRUSBERRY,BELLYDRUM,EXTREMESPEED,CLOSECOMBAT,SPORE+DARKVOID,1,,,,JOLLY,31,31,31,31,31,31,0,252,0,252,0,6,,,,42",
"SMEARGLE,120,FOCUSSASH,SHELLSMASH,BATONPASS,HYPERVOICE,SPORE+DARKVOID,1,,,,TIMID,31,31,31,31,31,31,6,0,0,252,252,0,,,,42",
"DITTO,120,CHOICESCARF,TRANSFORM,,,,2,,,,JOLLY,31,31,31,31,31,31,252,0,6,252,0,0,,,,12",
"WOBBUFFET,120,LEFTOVERS,ENCORE,MIRRORCOAT,COUNTER,DESTINYBOND+SAFEGUARD,0,,,,BOLD,31,31,31,31,31,31,252,0,252,0,0,6,,,,20",
"WOBBUFFET,120,LEFTOVERS,ENCORE,MIRRORCOAT,COUNTER,DESTINYBOND+SAFEGUARD,0,,,,CALM,31,31,31,31,31,31,252,0,6,0,0,252,,,,21",
"WYNAUT,120,LEFTOVERS,ENCORE,MIRRORCOAT,COUNTER,DESTINYBOND+SAFEGUARD,0,,,,BOLD,31,31,31,31,31,31,252,0,252,0,0,6,,,,20",
"WYNAUT,120,LEFTOVERS,ENCORE,MIRRORCOAT,COUNTER,DESTINYBOND+SAFEGUARD,0,,,,CALM,31,31,31,31,31,31,252,0,6,0,0,252,,,,21",
"PYUKUMUKU,120,LEFTOVERS,BLOCK,RECOVER,SPITE+SOAK,REST+TAUNT+TOXIC,,,,,BOLD,31,31,31,31,31,31,252,0,252,0,0,6,,,,20",
"PYUKUMUKU,120,LEFTOVERS,BLOCK,RECOVER,SPITE+SOAK,REST+TAUNT+TOXIC,,,,,CALM,31,31,31,31,31,31,252,0,6,0,0,252,,,,21"
]

POKEMONS_WITH_SPECCIFIC_MOVESETS = [mvst.split(",")[0] for mvst in SPECIFIC_MOVESETS]

POKEMONS_WITH_NO_MOVESET = ["CATERPIE", "METAPOD", "WEEDLE", "KAKUNA", "MAGIKARP", "UNOWN", "WURMPLE", "SILCOON", "CASCOON", "BELDUM", "KRICKETOT", "BURMY", "COMBEE", "TYNAMO", "SCATTERBUG", "SPEWPA", "COSMOG", "COSMOEM", "BLIPBUG", "NICKIT", "APPLIN", "DREEPY"]


	
def moveset_to_str(moveset, pokemon):
	
	# Pokemon name
	s = pokemon.to_id() + ","
	
	# Level (default level)
	s += "120,"
	
	# Item:
	s += moveset[18] + ","
	
	# Moves:
	s += moveset[0] + ","
	s += moveset[1] + ","
	s += moveset[2] + ","
	s += moveset[3] + ","
	
	# Ability:
	if moveset[17] == -1:
		s += ","
	else:
		s += str(moveset[17]) + ","
	
	# Gender:
	s += pokemon.gender + ","
	
	# Form:
	s += str(pokemon.form) + ","
	
	# Shininess:
	s += ","
	
	# Nature:
	s += moveset[10] + ","
	
	# IVs:
	for i in range(11, 17):
		s += str(moveset[i]) + ","
	
	# EVs:
	for i in range(4, 10):
		s += str(moveset[i]) + ","
	
	# Happiness:
	s += "255,"
	
	# Nickname + Shadow
	s += ",false\r\n"
	
	
	return s




def generate_all_movesets(pokemon):
	movesets = []
	
	
	for pattern in SCSpecificPatterns.ALL:
		if pattern.isValid(pokemon, False):
			movesets.append(pattern.generateMovesets(pokemon))
			
		pattern.reset()
	
	
	
	if not movesets:
		# If the Pokémon doesn't have a specific moveset, then 
		# chekc the normal / usual movesets.
		for pattern in SCAllPatterns.ALL:
			# Because it's set to True later, if the Pokémon doesn't get any moveset. 
			pattern.allow_coverage_stab = False 
			pattern.dont_check_stabs = False
			if pattern.isValid(pokemon):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
	
	
	
	for pattern in SCAllPatterns.ALL:
		# Attempt: specific patterns for items. 
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, ["CUBONE", "MAROWAK", "MAROWAK_1", "MAROWAK_2"], "THICKCLUB", "")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, [], "", "HUGEPOWER")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, [], "", "PUREPOWER")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.SPECIAL, [], "", "ATHENIAN")
		
		pattern.reset()
	
	
	
	if not movesets:
		# Very last chance : allow no "powerful" stab to be given!
		for pattern in SCAllPatterns.ALL:
			pattern.allow_coverage_stab = True 
			# pattern.dont_check_stabs = True 
			if pattern.isValid(pokemon, False):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
			
			
	if not movesets:
		# If no moveset were generated for that Pokemon, retry 
		# again, but don't check the stats. Sometimes a good 
		# Pokémon for a given role doesn't have the right stats for it.
		for pattern in SCAllPatterns.ALL:
			pattern.allow_coverage_stab = False 
			if pattern.isValid(pokemon, False):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
	
	
	
	if not movesets:
		# If no moveset were generated for that Pokemon, give it 
		# crappy, annoying movesets. 
		for pattern in SCPatternsInCase.ALL:
			pattern.allow_coverage_stab = True 
			if pattern.isValid(pokemon):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
	
	
	
	if not movesets:
		# This one is for desperate cases. 
		for pattern in SCAllPatterns.ALL:
			pattern.allow_coverage_stab = True  
			pattern.dont_check_stabs = True 
			if pattern.isValid(pokemon, False):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
	
	
	
	return movesets




def main_generate_movesets(pokemon_list, all_forms):
	scmovesets = "..\\..\\PBS\\scmovesets.txt"
	
	num_poke = 0
	num_movesets = 0 
	no_moveset_given_while_should = [] 
	
	with open(scmovesets, "w", encoding="utf-8") as f:
		f.write("# Generate by generate_movesets.py\n")
		for mvst in SPECIFIC_MOVESETS:
			f.write(mvst + "\n")
			num_movesets += 1
	
	
	# Some preprocessing:
	for pattern in SCAllPatterns.ALL:
		pattern.checkRole()
	for pattern in SCSpecificPatterns.ALL:
		pattern.checkRole()
	for pattern in SCPatternsInCase.ALL:
		pattern.checkRole()
	
	
	for poke_list in [pokemon_list, all_forms]:
		for pks in poke_list.keys():
			num_poke += 1 
			if pks in fh.FORBIDDENFORMS:
				continue 
			
			if pks in POKEMONS_WITH_SPECCIFIC_MOVESETS:
				continue 
			
			# input(pks)
			pokemon = poke_list[pks]
			
			movesets = generate_all_movesets(pokemon)
		
			if movesets:
				# input(moveset)
				with open(scmovesets, "a") as f:
					f.write("#-------------------------------\n")
					for moveset in movesets:
						f.write(moveset + "\n")
						num_movesets += 1
			else:
				with open(scmovesets, "a") as f:
					f.write("#-------------------------------\n")
					f.write(pks + ",120\n")
					num_movesets += 1
				
				if pks not in POKEMONS_WITH_NO_MOVESET:
					no_moveset_given_while_should.append(pks)
					no_moveset_given_while_should.append(len(pokemon.moves))
			
			print("(" + str(num_poke) + "/" + str(len(poke_list)) + "). Generated " + str(len(movesets)) + " movesets for " + pks, end="         \r")
	
	print()
	print("Pokémons with no moveset: ")
	print(no_moveset_given_while_should)




def main_generate_learned_moves(pokemon_list, all_forms):
	
	sclearned = "..\\..\\PBS\\sclearned.txt"
	
	with open(sclearned, "w", encoding="utf-8") as f:
		f.write("# Generated by generate_movesets.py\n")
	
	num_poke = 0 
	
	
	for poke_list in [pokemon_list, all_forms]:
		for pks in poke_list.keys():
			# input(pks)
			num_poke += 1
			if pks in fh.FORBIDDENFORMS:
				continue 
			
			form = "" 
			
			pokemon = poke_list[pks]

			with open(sclearned, "a") as f:
				pokemon.moves.sort()
				f.write(pks + "," + form + "," + ",".join(pokemon.moves) + "\n")
			
			print("(" + str(num_poke) + "/" + str(len(poke_list)) + "). Procesed moves learned by " + pks, end="              \r")
	
	print()
	print("Done getting all learned moves.")




def main_generate_trainers(pokemon_list, all_forms):
	sctrainersrand = "..\\..\\PBS\\sctrainersrand.txt"
	# POKEMONS = pku.POKEMONS if pokemon_list is None else pokemon_list
	
	fully_evolved = [pokemon_list[pk] for pk in pokemon_list.keys() if len(pokemon_list[pk].evolutions) == 0 and pk not in fh.FORBIDDENFORMS]
	fully_evolved += [all_forms[pk] for pk in all_forms.keys() if len(all_forms[pk].evolutions) == 0 and pk not in fh.FORBIDDENFORMS]
	
	
	
	
	list_trainers = [
		"SWIMMER_F,Lola, ",
		"PARASOLLADY,Cara, ",
		"BEAUTY,Kate Rich, ",
		"AROMALADY,Sophie, ",
		"LADY,Anastasia, ",
		"PARASOLLADY,Rachel, ",
		"SCIENTIST_F,Rebeka, ",
		"ACETRAINER_F,Evita, ",
		"LASS,Debora, ",
		"POKEMONRANGER_F,Sandy, ",
		"PSYCHIC_F,Lelida, ",
		"SWIMMER_F,Pam, ",
		"ATHLETE_F,Polly, ",
		"NURSE,Gloria, ",
		"CYCLIST_F,Niece Waidhofer, ", 
		"BATTLEGIRL,Velana, ",
		"WAITRESS,Melisa Mendiny, ",
		"MAID,Krysta Kaos, ",
		"SWIMMER_F,Shirin, ",
		"PARASOLLADY,Angela, ",
		"BEAUTY,Chiara, ",
		"AROMALADY,Jewel, ",
		"LADY,Nela, ",
		"PARASOLLADY,Amaliya, ",
		"SCIENTIST_F,Samara, ",
		"ACETRAINER_F,Emiliana, ",
		"LASS,Edeline, ",
		"POKEMONRANGER_F,Monique, ",
		"PSYCHIC_F,Kimmy, ",
		"SWIMMER_F,Iwona, ",
		"ATHLETE_F,Laura, ",
		"SOCIALITE,Beatrice, ",
		"CYCLIST_F,Rebecca, ", 
		"BATTLEGIRL,Milana, ",
		"WAITRESS,Celeste, ",
		"SOCIALITE,Tina, ",
		"BUGCATCHER,Jean-John, ", 
		"BIRDKEEPER,Felix, ",
		"BURGLAR,Carson, ",
		"BIKER,Jackson, ",
		"GENTLEMAN,Basil, ",
		"HIKER,Vladimir, ",
		"JUGGLER,Jarod, ",
		"RUINMANIAC,Yves Coppens, ",
		"SCIENTIST_M,Stephen, ",
		"BLACKBELT,Connor, ",
		"ACETRAINER_M,Axel, ",
		"PSYCHIC_M,Randall, ",
		"DRAGONTAMER,Weston, ",
		"ATHLETE_M,Usain, "
	]
	
	num_poke = 50
	
	
	with open(sctrainersrand, "w") as f:
		f.write("# Part of StCooler's scripts\n")
		
		for t in list_trainers:
			chosen_pkmns = scsample(fully_evolved, num_poke)
			
			f.write(t + ",".join([p.name for p in chosen_pkmns]) + "\n")
			
	print("Done generating trainers.")




def main_merge_tm_files():
	# Merge the tm.txt files from my old project (with 7G) to the tm.txt of Insurgence (6G + Deltas species)
	# 
	wrong_tms = pku.load_tms("7G/WRONG/PBS/tm.txt")
	current_tms = pku.TM_DATA
	merged_tms = {}
	
	all_tms = list(wrong_tms.keys()) + list(current_tms.keys())
	
	
	
	for tm in all_tms:
		merged_tms[tm] = [] 
		
		tm_in_wrong = (tm in wrong_tms.keys())
		
		
		if tm_in_wrong:
			merged_tms[tm] += [pk for pk in wrong_tms[tm]]
			
			if tm in current_tms.keys():
				merged_tms[tm] += [pk for pk in current_tms[tm] if pk not in wrong_tms[tm]]
		else: 
			if tm in current_tms.keys():
				merged_tms[tm] += [pk for pk in current_tms[tm]]
	
	
	
	with open("7G/MERGED/PBS/tm.txt", "w") as f:
		
		for tm in merged_tms.keys():
			f.write("[" + tm + "]\n")
			f.write(",".join(merged_tms[tm]) + "\n")
			
	print("Done")




def main_add_pokemons_tm______NEEDS_REWORK(pokemon_list, all_forms, transposed_more_tms_other = None ):
	# POKEMONS = pku.POKEMONS if pokemon_list is None else pokemon_list
	
	
	transposed_more_tms = {} if transposed_more_tms_other is None else transposed_more_tms_other
	
	# Livewire : for all Electric  (C'est un Entry-hazard qui paralyse...)
	# Permafrost : for all Ice-type + water-type (c'est un Entry-Hazard qui freeze...) + vérifier combien de temps dure le freeze 
	# En vrai, c'est pour tous les Pokémons qui apprennent déjà ICEBEAM
	# Wildfire : for all fire-types (Burns the opponent + the party weak to fire, if the opponent is grass-Type)
	# En fait, puisque c'est super fort, je pense que je vais le retirer pour le laisser uniquement à des Pokémons FIRE complètement évolués, et pas seulement les pokémons qui apprennent FLAMETHROWER (je crois que c'est le critère)
	# Corrode : for all poison-type 
	# Dracojet : all Dragons + some Dragon-like pokés (Delta-Hydreigon, Charizard, Groudon, Rampardos, Milotic, Gyarados...)
	# RETIRER ZOMBIESTRIKE de TOUT LE MONDE !
	# WORMHOLE : L'ajouter pour tous les Pokémons qui apprennent PSYCHIC ! (pour l'instant y'a que UFI qui peut l'apprendre)
	
	
	not_added = [] 
	for alolan in transposed_more_tms.keys():
		for move in transposed_more_tms[alolan]:
			if move not in pku.TM_DATA.keys():
				pku.TM_DATA[move] = []
				# not_added.append(alolan)
				# not_added.append(move)
				# continue 
				
			pku.TM_DATA[move].append(alolan)
	
	poke_that_do_not_learn = ["CATERPIE","METAPOD","WEEDLE","KAKUNA","MAGIKARP","DITTO","UNOWN","WOBBUFFET","SMEARGLE","WURMPLE","SILCOON","CASCOON","WYNAUT","BELDUM","KRICKETOT","BURMY","COMBEE","TYNAMO","SCATTERBUG","SPEWPA","COSMOG","COSMOEM", "AUSITTO", "DELTADITTO","BLIPBUG", "APPLIN", "DREEPY"]
	
	
	tm_for_all_pokes = ["CONFIDE", "POWERSHRINE", "SPECIALSHRINE"]
	for move_name in tm_for_all_pokes:
		pku.TM_DATA[move_name] = [pk for pk in POKEMONS.keys() if pk not in poke_that_do_not_learn]
	
	
	# Moveset change: I give Angel wings only to all POkémons that are fully evolved. 
	pku.TM_DATA["ANGELWINGS"] = [pk for pk in POKEMONS.keys() if len(POKEMONS[pk].evolutions) == 0]
	
	# Entry hazard, FFS they are tough.
	pku.TM_DATA["LIVEWIRE"] = [pk for pk in POKEMONS.keys() if POKEMONS[pk].hasType("ELECTRIC") and pk not in poke_that_do_not_learn]
	pku.TM_DATA["PERMAFROST"] = [pk for pk in POKEMONS.keys() if POKEMONS[pk].hasType("WATER") and pk not in poke_that_do_not_learn]
	pku.TM_DATA["PERMAFROST"] += [pk for pk in POKEMONS.keys() if POKEMONS[pk].hasType("ICE") and pk not in poke_that_do_not_learn]
	
	# Super effective against STEEL. 
	pku.TM_DATA["CORRODE"] = [pk for pk in POKEMONS.keys() if POKEMONS[pk].hasType("POISON") and pk not in poke_that_do_not_learn]
	
	# Wildfire is really tough too, I give it only FIRE Pokémons that are fully evolved. 
	pku.TM_DATA["WILDFIRE"] = [pk for pk in POKEMONS.keys() if len(POKEMONS[pk].evolutions) == 0 and POKEMONS[pk].hasType("FIRE")]
	pku.TM_DATA["WILDFIRE"].append("GROUDON")
	
	# New priority moves. 
	pku.TM_DATA["WORMHOLE"] = [pk for pk in POKEMONS.keys() if POKEMONS[pk].canLearnMove("PSYCHIC") and pk not in poke_that_do_not_learn]
	pku.TM_DATA["DRACOJET"] = [pk for pk in POKEMONS.keys() if POKEMONS[pk].canLearnMove("DRACOMETEOR") and pk not in poke_that_do_not_learn]
	
	pku.TM_DATA["ZOMBIESTRIKE"] = ["MAROWAK", "AMAROWAK", "MAROWAKSC1"]
	
	
	
	dont_exist = []
	
	# Remove duplicates
	for move in pku.TM_DATA.keys():
		# Add Arceus and Mew everywhere.
		pku.TM_DATA[move].append("MEW")
		pku.TM_DATA[move].append("ARCEUS")
		pku.TM_DATA[move] = list(dict.fromkeys(pku.TM_DATA[move]))
		
		# Check if Pokémons don't exist (safety)
		for pk in pku.TM_DATA[move]:
			if pk not in pokemon_list.keys():
				dont_exist.append(move)
				dont_exist.append(pk)
				print(pk)
	
	# Then write file: 
	with open("new_tms.txt", "w") as f:
		for move in pku.TM_DATA.keys():
			f.write("[" + move + "]\n")
			f.write(",".join(pku.TM_DATA[move]) + "\n")
	
	print("Done adding new Pokémons to TM.")
	# print(len(not_added))
	print(not_added)
	print(len(dont_exist))
	# print(dont_exist)



def transposed_tms_from_unformated_files():
	
	poke_regex = re.compile("\d+ - \D* \(.*\)")
	transposed_tms = {}
	
	
	for i in range(1,3):
		filename = "..\\PBS\\sword_shield_stats,_learnsets,_evolution,_dexentry_part_" + str(i) + ".txt"
		pokeid = ""
		take_poke = True 
		
		with open(filename, "r", encoding="utf-8") as f:
			for line in f:
				line = line.replace("\r", "")
				line = line.replace("\n", "")
				
				res = poke_regex.match(line)
				
				if res:
					pokeid = make_id(line)
					transposed_tms[pokeid] = []
					
				if line.startswith("- [T") and pokeid != "":
					transposed_tms[pokeid].append(make_id(line))
				elif line.startswith("=="):
					if take_poke:
						pokeid = "" 
						
					take_poke = not take_poke
					
	
	return transposed_tms
	
	


def make_id(s):
	
	if "(" in s:
		# Then it's the heade rof the Pokémon.
		s = s.split(" - ")[1]
		s = s.split("(")[0]
	else:
		s = s.split("]")[1]
	
	s = s.replace(" ","")
	s = s.replace("-","")
	s = s.replace(":","")
	s = s.replace(".","")
	s = s.replace("'","")
	s = s.replace("’","")
	s = s.replace("\r","")
	s = s.replace("\n","")
	s = s.upper()
	return s 






def main_merge_poke_numbers():
	# Merge the pokemon.txt files from my old project (with 7G) to the pokemon.txt of Insurgence (6G + Deltas species)
	
	merged_num = 926 # UFI (from Insurgence) is 925
	
	wrong_paths = ["7G/WRONG/Audio/SE/", 
		"7G/WRONG/Graphics/Battlers/", 
		"7G/WRONG/Graphics/Characters/", 
		"7G/WRONG/Graphics/Icons/"]
	merged_paths = [p.replace("WRONG", "MERGED") for p in wrong_paths]
	wrong_file_lists = [os.listdir(p) for p in wrong_paths]
	
	new_f = open("7G/MERGED/PBS/pokemon.txt", "w")
	
	with open("7G/WRONG/PBS/pokemon.txt", "r") as f:
		for line in f:
			if line.startswith("["):
				# line is of the form [XXX] with XXX an integer 
				num = line.replace("[", "")
				old_num = num.replace("]", "")
				old_num = old_num.replace("\n", "")
				old_num = old_num.replace("\r", "")
				
				for i in range(len(wrong_paths)):
					for wrong_file in wrong_file_lists[i]:
						if old_num in wrong_file:
							merged_file = wrong_file.replace(old_num, str(merged_num))
							shutil.copyfile(wrong_paths[i] + wrong_file, merged_paths[i] + merged_file)
				
				new_f.write("[" + str(merged_num) + "]\n")
				
				merged_num += 1
				
			else:
				new_f.write(line)
			
			
	new_f.close()




def test_move_equivalents():
	for type in SCUsefulMoves.PHYSICAL:
		print(type + ":")
		for move in SCUsefulMoves.PHYSICAL[type]:
			for type2 in SCUsefulMoves.PHYSICAL:
				eqs = moveeq.MOVE_DATABASE.find_equivalents_to(move, type2)
				print("Equivalents of " + move + " of type " + type2 + ":")
				input(eqs)
		input()




def main_generate_csv_for_pokemons(pokemon_list = None):
	POKEMONS = pku.POKEMONS if pokemon_list is None else pokemon_list
	
	
	with open("alternate_forms_planner.csv", "a") as f:
		for pk in POKEMONS.keys():
			f.write(POKEMONS[pk].id + ";" + pk + "\n")
			
	print("Done writing CSV.")




def main_add_alternate_forms(pokemon_list = None):
	pokemon_file = "..\\PBS\\pokemon.txt"
	alternate_file = "alternate_forms_summary.txt"
	
	pokemon_lines = []
	alternate_lines = []
	
	original_indices = {}
	transposed_more_tms = {} 
	
	with open(pokemon_file, "r", encoding="utf-8") as f:
		cpt = 0 
		
		for line in f:
			line = line.replace("\r", "")
			line = line.replace("\n", "")
			pokemon_lines.append(line)
			
			if line.startswith("InternalName="):
				original_indices[line] = cpt 
			
			cpt += 1
	
	
	with open(alternate_file, "r", encoding="utf-8") as f:
		new_name = "" 
		
		
		for line in f:
			line = line.replace("\r", "")
			line = line.replace("\n", "")
			
			
			if line.startswith("[NEW] InternalName="):
				new_name = line.split("=")[1]
				alternate_lines.append("InternalName=" + new_name)
				continue 
				
			elif line.startswith("[OLD] InternalName="):
				continue 
				
			elif new_name != "" and line.startswith(new_name):
				pk = line.split("=")
				
				moves = pk[1].split(",")
				pk = pk[0]
				
				transposed_more_tms[pk] = moves
				new_name = ""
				continue 
			
			if line != "" and not line.startswith("---"):
				alternate_lines.append(line)
	
	
	
	with open("pokemon_af.txt", "w", encoding="utf-8") as f:
		for line in pokemon_lines:
			f.write(line + "\n")
		for line in alternate_lines:
			f.write(line + "\n")
	
		
	
	print("File pokemon_af.txt written.")
	
	input(len(transposed_more_tms.keys()))
	pokemon_list = pku.load_pokemons("pokemon_af.txt")
	
	
	main_add_pokemons_tm(pokemon_list, transposed_more_tms)


	
	
	
	
	
if __name__ == "__main__":
	
	
	# for k in blablab.keys():
		# print(k + ": ")
		# input(blablab[k])
	
	
	
	
	# blablab = transposed_tms_from_unformated_files()
	# main_add_pokemons_tm(None, blablab)
	
	# input()
	
	main_generate_learned_moves(pku.POKEMONS, pku.ALL_FORMS)
	main_generate_movesets(pku.POKEMONS, pku.ALL_FORMS)
	main_generate_sc_tiers()
	main_generate_new_sc_tiers()
	main_generate_random_tiers() 
	main_generate_micro_tiers()
	main_generate_trainers(pku.POKEMONS, pku.ALL_FORMS)
	
	# main_generate_csv_for_pokemons(POKEMONS)
	# main_merge_tm_files()
	# main_merge_poke_numbers()
	
	
	# test_move_equivalents()
	
	# main_add_alternate_forms()
