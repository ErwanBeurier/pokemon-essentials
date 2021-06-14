# -*- coding=utf8 -*- 
###############################################################################
# Generation of movesets
# Part of Pokémon STRAT, by StCooler. 
# 
# This script handles the generation of movesets. First we have an empty class 
# defining all the "useful" moves, that is, all the moves usually used in 
# strategy. 
# Note that these patterns are not meant to be competitive movesets that you 
# find on Smogon, as I don't want to code a scraper. These patterns define 
# ROUGH movesets. 
###############################################################################



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


# =============================================================================
# Class (module) containing the moves usually useful in strategy. 
# Defines them in a dictionary type -> move list, or simply as a list of 
# moves, to be used later. 
# =============================================================================

class SCUsefulMoves:
	
	PHYSICAL = {
		"BUG": ["MEGAHORN", "LUNGE", "LEECHLIFE", "ATTACKORDER", "XSCISSOR"],
		"DARK": ["WICKEDBLOW", "DARKESTLARIAT", "HYPERSPACEFURY", "FALSESURRENDER", "JAWLOCK", "THROATCHOP", "CRUNCH", "KNOCKOFF", "NIGHTSLASH"],
		"DRAGON": ["DRAGONDARTS", "OUTRAGE", "SCALESHOT", "DRAGONHAMMER", "DRAGONCLAW"],
		"ELECTRIC": ["AURAWHEEL", "BOLTBEAK", "BOLTSTRIKE", "FUSIONBOLT", "PLASMAFISTS", "VOLTTACKLE", "ZINGZAP", "WILDCHARGE", "THUNDERPUNCH"],
		"FAIRY": ["PLAYROUGH"],
		"FIGHTING": ["METEORASSAULT", "THUNDEROUSKICK", "SACREDSWORD", "CLOSECOMBAT", "FLYINGPRESS", "DRAINPUNCH", "HIJUMPKICK", "SUPERPOWER", "HAMMERARM"],
		"FIRE": ["VCREATE", "SACREDFIRE", "PYROBALL", "BLAZEKICK", "FLAREBLITZ", "FIRELASH", "FIREPUNCH"],
		"FLYING": ["DRAGONASCENT", "BEAKBLAST", "BRAVEBIRD", "AEROBLAST", "DRILLPECK", "DUALWINGBEAT"],
		"GHOST": ["POLTERGEIST", "SPECTRALTHIEF", "GHOSTGALLOP", "ZOMBIESTRIKE", "SHADOWBONE", "SPIRITSHACKLE", "PHANTOMFORCE", "SHADOWFORCE", "SHADOWCLAW"],
		"GRASS": ["GRAVAPPLE", "POWERWHIP", "WOODHAMMER", "DRUMBEATING", "PETALBLIZZARD", "LEAFBLADE", "SEEDBOMB", "HORNLEECH"],
		"GROUND": ["PRECIPICEBLADES", "THOUSANDARROWS", "EARTHQUAKE", "HIGHHORSEPOWER", "BONEMERANG", "BONERUSH", "LANDSWRATH"],
		"ICE": ["GLACIALLANCE", "ICICLECRASH", "ICEHAMMER", "ICEPUNCH", "AVALANCHE", "ICICLESPEAR"],
		"NORMAL": ["CRUSHGRIP", "DOUBLEEDGE", "RETURN", "BODYSLAM", "FACADE"],
		"POISON": ["GUNKSHOT", "POISONJAB"],
		"PSYCHIC": ["ZENHEADBUTT", "PSYCHICFANGS", "PSYCHOCUT"],
		"ROCK": ["DIAMONDSTORM", "PALEODRAIN", "HEADSMASH", "STONEEDGE", "ROCKSLIDE"],
		"STEEL": ["SUNSTEELSTRIKE", "BEHEMOTHBLADE", "BEHEMOTHBASH", "DOUBLEIRONBASH", "METEORMASH", "GEARGRIND", "ANCHORSHOT", "IRONHEAD", "SMARTSTRIKE"],
		"WATER": ["SURGINGSTRIKES", "CRABHAMMER", "FISHIOUSREND", "WATERFALL", "LIQUIDATION", "AQUATAIL"]
	}
	
	
	SPECIAL = {
		"BUG": ["BUGBUZZ", "POLLENPUFF", "SIGNALBEAM"],
		"DARK": ["FIERYWRATH", "NIGHTDAZE", "DARKPULSE"],
		"DRAGON": ["CLANGINGSCALES", "DYNAMAXCANNON", "SPACIALREND", "ROAROFTIME", "DRAKONVOICE", "ANCIENTROAR", "DEVOUR", "COREENFORCER", "DRAGONPULSE", "DRAGONENERGY", "DRACOMETEOR"],
		"ELECTRIC": ["OVERDRIVE", "THUNDERCAGE", "THUNDERBOLT", "DISCHARGE", "PARABOLICCHARGE"],
		"FAIRY": ["LIGHTOFRUIN", "STRANGESTEAM", "MOONBLAST", "DRAININGKISS", "DAZZLINGGLEAM", "SPIRITBREAK", "FLEURCANNON"],
		"FIGHTING": ["SECRETSWORD", "AURASPHERE", "FOCUSBLAST"],
		"FIRE": ["BLUEFLARE", "SHELLTRAP", "MAGMASTORM", "FUSIONFLARE", "MINDBLOWN", "ERUPTION", "FIREBLAST", "SEARINGSHOT", "FLAMETHROWER", "OVERHEAT", "HEATWAVE", "FIERYDANCE", "MYSTICALFIRE", "BURNINGJEALOUSY"],
		"FLYING": ["OBLIVIONWING", "AIRSLASH", "HURRICANE"],
		"GHOST": ["ASTRALBARRAGE", "MOONGEISTBEAM", "SHADOWBALL", "HEX"],
		"GRASS": ["APPLEACID", "SEEDFLARE", "GIGADRAIN", "GRASSKNOT", "PETALDANCE", "ENERGYBALL", "LEAFSTORM"],
		"GROUND": ["EARTHPOWER", "SCORCHINGSANDS"],
		"ICE": ["FREEZESHOCK", "ICEBEAM", "FREEZEDRY", "BLIZZARD"],
		"NORMAL": ["BOOMBURST", "JUDGMENT", "MULTIATTACK", "RELICSONG", "TRIATTACK", "HYPERVOICE"],
		"POISON": ["SHELLSIDEARM", "SLUDGEWAVE", "SLUDGEBOMB", "CORRODE"],
		"PSYCHIC": ["FREEZINGGLARE", "PHOTONGEYSER", "PSYCHOBOOST", "HYPERSPACEHOLE", "PSYSTRIKE", "PSYSHOCK", "PSYCHIC", "EXTRASENSORY"],
		"ROCK": ["POWERGEM", "METEORBEAM"],
		"STEEL": ["FLEURCANNON", "STEELBEAM", "FLASHCANNON"],
		"WATER": ["SURGINGSTRIKES", "STEAMERUPTION", "ORIGINPULSE", "SPARKLINGARIA", "WATERSHURIKEN", "HYDROPUMP", "SCALD", "SURF", "WATERSPOUT", "SNIPESHOT"]
	}
	
	
	PHYSICALPRIORITY = {
		"BUG": ["FIRSTIMPRESSION"],
		"DARK": ["SUCKERPUNCH", "PURSUIT"],
		"DRAGON": ["DRACOJET"],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": ["MACHPUNCH"],
		"FIRE": [],
		"FLYING": ["FASTSWOOP"],
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
		"ICE": ["AURORABEAM", "BLIZZARD", "ICYWIND"],
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
		"DRAGON": ["SCALESHOT"],
		"ELECTRIC": [],
		"FAIRY": [],
		"FIGHTING": [],
		"FIRE": [],
		"FLYING": [],
		"GHOST": [],
		"GRASS": ["BULLETSEED"],
		"GROUND": ["BONERUSH"],
		"ICE": ["TRIPLEAXEL", "ICICLESPEAR"],
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
		"RECOVER", "SLACKOFF", "SOFTBOILED", "HEALORDER", "MILKDRINK", "FLORALHEALING", "ROOST", "SYNTHESIS", "MOONLIGHT", "MORNINGSUN", "SHOREUP", "STRENGTHSAP", "PAINSPLIT", "WISH", "AQUARING", "LUNARDANCE", "HEALINGWISH", "RENAISSANCE", "JUNGLEHEALING", "LIFEDEW", "RELAXINGPURRING"
	] # Rest is not there because almost all Pokémon can learn Rest. 
	
	
	SUPPORTOFFENSIVE = [
		"FOULPLAY", "DRAGONTAIL", "CIRCLETHROW", "SEISMICTOSS", "EXPLOSION", "MIRRORCOAT", "COUNTER"
	]
	
	
	VOLTTURN = [
		"UTURN", "VOLTSWITCH", "PARTINGSHOT", "FLIPTURN"
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
	
	
	CHEERS = [
		"WARMANDALA", "MINDMANDALA", "WARMWELCOME"
	]
	
	FULLSUPPORTNOHEALING = STATUS + SUPPORT + SUPPORTOFFENSIVE
	
	FULLSUPPORT = FULLSUPPORTNOHEALING + HEALING
	
	ALLNOOFFENSENOHEALING = FULLSUPPORTNOHEALING + HAZARDS + CHEERS
	
	ALLNOOFFENSE = FULLSUPPORT + HAZARDS + CHEERS
	
	
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
		elif s == "C":
			return SCUsefulMoves.CHEERS
		elif s == "FSNH":
			return SCUsefulMoves.FULLSUPPORTNOHEALING
		elif s == "ANO":
			return SCUsefulMoves.ALLNOOFFENSE
		elif s == "ANONH":
			return SCUsefulMoves.ALLNOOFFENSENOHEALING
		else: # s == "FS"
			return SCUsefulMoves.FULLSUPPORT
	
	
	@staticmethod
	def shouldCheckSTABs(move_specs):
		# For Patterns, checks if the given move_specs is a dictionary type -> move list that should consider STABS. 
		if isinstance(move_specs, dict):
			if move_specs == SCUsefulMoves.PHYSICAL:
				return True 
			elif move_specs == SCUsefulMoves.SPECIAL:
				return True 
			elif move_specs == SCUsefulMoves.PULSES:
				return True 
			elif move_specs == SCUsefulMoves.PHYSICALMULTIHIT:
				return True 
			elif "IS_ONE_MOVE" in move_specs.keys():
				# Check if it's a one-move dictionary
				return True
		
		return False 
	
	
	
	@staticmethod
	def findType(move):
		move_dicts_phy = [
			SCUsefulMoves.PHYSICALCOVERAGE,
			SCUsefulMoves.PHYSICAL,
			SCUsefulMoves.PHYSICALPRIORITY,
			SCUsefulMoves.PHYSICALMULTIHIT
		]
		for d in move_dicts_phy:
			for type in d.keys():
				if move in d[type]:
					return type, 1
					
		move_dicts_spe = [
			SCUsefulMoves.SPECIALCOVERAGE,
			SCUsefulMoves.SPECIAL,
			SCUsefulMoves.SPECIALPRIORITY,
			SCUsefulMoves.PULSES
		]
		for d in move_dicts_spe:
			for type in d.keys():
				if move in d[type]:
					return type, 2
					
		return None, None 
	
	
	@staticmethod
	def newEmptyMoveSpecHash():
		return { 
			"BUG": [],
			"DARK": [],
			"DRAGON": [],
			"ELECTRIC": [],
			"FAIRY": [],
			"FIGHTING": [],
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
			"WATER": []
			}
	
	@staticmethod
	def oneTypeHash(type, move_list):
		h = SCUsefulMoves.newEmptyMoveSpecHash()
		h[type] = move_list if isinstance(move_list, list) else [move_list]
		h["IS_ONE_MOVE"] = True
		return h

	
	

# =============================================================================
# A way to define the stats that are most useful for a given pattern.
# Each SCPokemon will have its stats ranked, and if the best stats correspond 
# to the one given by a SCStatPatterns, then the SCPattern will be suitable 
# for that Pokémon.
# =============================================================================
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
	HP_ATK_SPE = [0, 1, 3]
	HP_SPA_SPE = [0, 4, 3]
	ATK_SPA_SPE = [3, 1, 4]
	ATK_SPE = [1, 3]
	SPA_SPE = [4, 3]
	DEF_SPD = [2, 5]
	ATK_DEF = [1, 2]
	ATK_SPD = [1, 5]
	SPA_DEF = [4, 2]
	SPA_SPD = [4, 5]
	ATK_SPA = [1, 4]



# =============================================================================
# Main class for the generation of movesets.
# A pattern is defined by a "type of movesests", that is, for each move slot, 
# it is given a set of moves, defined as a dictionary or list defines in 
# SCUsefulMoves. It is also given some more data, like EVs, natures, and for 
# what kind of Pokémon it is, depending on their stats. (Some patterns depend 
# more strongly on items, or abilities)
# The generation then works as follows: 
# 1. Check if the Pokémon has the right stats (e.g. give Choice Band set to a 
# physical offensive Pokémon, with high ATK). 
# 2. Check if the Pokémon has the right abilities, can be given an item, etc. 
# 3. Check if it can learn at least one move in each slot.
# 4. Generate the string describing the resulting moveset. 
# Patterns are also stores in a PBS file and compiled for later use in the 
# Team Builder.
# =============================================================================
	
class SCPattern:
	
	# Rough roles. 
	LEAD = 1
	OFFENSIVE = 2
	DEFENSIVE = 3
	SUPPORT = 4
	PHYSICAL = 1 
	SPECIAL = 2
	MIXED = 3
	
	# Patterns are also compiled. Some patterns are hard-coded for specific 
	# Pokémons (e.g. Smeargle, Ditto...)
	MAX_ID = 6 
	
	
	def __init__(self, move_spec1, move_spec2, move_spec3, move_spec4, main_stats):
		# The rest of the attributes need to be set later, when defining an instance. 
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
		self.minimum_speed = 0
		
		# Mostly for debug. 
		self.name = ""
		SCPattern.MAX_ID += 1 
		self.id = SCPattern.MAX_ID
		self.essentials_id = ""
		
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
		self.forced_move_probably_stab = -1 
		# For example, if Ancient Power is given as first move, it will replace Rock STAB. 
		# If Ancient Power is move 0, check move_specs[0]
		
		# Checks if the Pokémon will have the room for two STABs of different types. 
		# If False, then both STABs could be possible as xth move. 
		self.room_for_double_stabs = False 
		
		# For Choice bancs/scraf and such, don't give personal items. 
		self.allow_personal_items = True 
		self.allow_heavy_duty_boots = True 
		self.allow_balloon_boots = True 
		
		# Hidden power. 
		self.hidden_power = []
		
		# Only for type 
		self.for_type = ""
		
		# Role of the moveset 
		self.role = 0
		self.category = 0 
		
		# Only for Pokemon (should also specify item). 
		self.for_pokemons = []
		
		# Debug switch. 
		self.debug = False
		
		# Specific moveset (cannot appear in Team that don't require this pattern specifically). 
		self.is_specific = False
		
		# Types given by SCUsefulMoves.PHYSICAL or SCUsefulMoves.SPECIAL, to avoid repeating 
		# them with SCUsefulMoves.PHYSICALCOVERAGE and SCUsefulMoves.SPECIALCOVERAGE
		self.move_types_given = []
	
	
	def checkDoubleOffense(self):
		# Checks if this pattern allows for double stabs or not.
		# Typically, if the pattern has two or more move slots for offensive 
		# moves, then it will allow for double STABS. 
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
		# Filters the moves given as specifications, retaining only the ones 
		# that the given Pokémon can learn. 
		# This is the last step in checking whether this Pokémon is suitable 
		# for this pattern.
		filtered_moves = [ [] for i in range(4) ]
		filtered_moves_types = [ [] for i in range(4) ]
		self.stab_given = False or self.dont_check_stabs
		self.type_stabs_given = [] 
		self.required_stabs = [] if self.dont_check_stabs else [t for t in pokemon.types]
		
		self.checkDoubleOffense()
		
		if self.forced_move_probably_stab > -1:
			if isinstance(self.move_specs[0], str):
				move_type, category = SCUsefulMoves.findType(self.move_specs[0])
				if move_type in self.required_stabs and category == self.category:
					self.required_stabs.remove(move_type)
		
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
					if self.debug:
						input("filterMoves (step 1): m = " + str(m))
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
				if self.debug:
					input("filterMoves (step 2): m = " + str(m))
				return [], []
		
		# If the Pokémon cannot learn any STAB for that moveset, then it is not valid. 
		if not self.stab_given:
			if self.debug:
				input("filterMoves (step 3): m = " + str(m))
			return [], [] 
		
		return filtered_moves, filtered_moves_types
	
	
	
	def filterMovesFromArray(self, move_specs_array, pokemon):
		# Basically returns the intersection between the list of moves given in
		# move_specs_array and the moves that the Pokémon can learn. 
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
		# Basically returns the intersection between the dictionary of moves 
		# given in move_specs_hash and the moves that the Pokémon can learn. 
		# Favours STABS. 
		f_moves = []
		f_moves_types = [] 
		
		# Avoid Coverage repeating types already given by SCUsefulMoves.PHYSICAL or SCUsefulMoves.SPECIAL
		is_main_useful_moves = (move_specs_hash == SCUsefulMoves.PHYSICAL or move_specs_hash == SCUsefulMoves.SPECIAL)
		is_coverage_moves = (move_specs_hash == SCUsefulMoves.PHYSICALCOVERAGE or move_specs_hash == SCUsefulMoves.SPECIALCOVERAGE)
		if is_main_useful_moves:
			self.move_types_given = []
		
		# ORICORIO's special case:
		revelation_dance = self.giveRevelationDance(pokemon) if move_specs_hash == SCUsefulMoves.SPECIAL else "" 
		hidden_power_given = False 
		
		# Restart the computation if we realise no STAB can be given.
		restart = False 
		
		for tp in move_specs_hash.keys():
			# Do not give normal type attacks to a Pokémon that's not Normal. 
			if tp == "IS_ONE_MOVE":
				continue
			if tp == "NORMAL" and not tp in self.required_stabs:
				continue 
			# if tp in pokemon.types and len(self.required_stabs) == 0:
				# if move_specs_hash == SCUsefulMoves.SPECIAL or move_specs_hash == SCUsefulMoves.SPECIALCOVERAGE:
					# # Stabs were given, do not add moves there. 
					# continue 
				# if move_specs_hash == SCUsefulMoves.PHYSICAL or move_specs_hash == SCUsefulMoves.PHYSICALCOVERAGE:
					# # Stabs were given, do not add moves there. 
					# continue 
			
			# First, check if tp is a STAB. If it is and we already gave STABs, then skip this type. 
			# If it is not a STAB and no STAB was given, then skip this type.
			if not self.dont_check_stabs and (SCUsefulMoves.shouldCheckSTABs(move_specs_hash) \
				or (self.allow_coverage_stab and move_specs_hash == SCUsefulMoves.PHYSICALCOVERAGE) \
				or (self.allow_coverage_stab and move_specs_hash == SCUsefulMoves.SPECIALCOVERAGE)):
				if len(self.required_stabs) > 0 and not tp in self.required_stabs:
					# Give only stabs at first 
					continue 
				elif len(self.required_stabs) == 0 and self.stab_given and pokemon.hasType(tp):
					# Do not give another STAB 
					continue 
				elif tp in self.type_stabs_given:
					continue 
			
			# Then, avoid giving covergae moves for types that were already given.
			if is_coverage_moves and tp in self.move_types_given:
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
			if (self.allow_coverage_stab or tp == "ROCK") and tp in self.required_stabs and moves_for_type == 0:
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
			
			# if moves_for_type > 0 and pokemon.hasType(tp):
				# self.type_stabs_given.append(tp)
			
			# For example, Gyarados is Water/ Flying. But Gyarados doesn't have a Flying STAB. 
			# However, it's still a great Pokemon ! This is because the Flying type doesn't 
			# have Physical moves that non-birds can learn (Gyarados, Dragonite, Aerodactyl)
			if moves_for_type == 0 and tp == "FLYING" and pokemon.hasType("FLYING"):
				if move_specs_hash == SCUsefulMoves.PHYSICAL and tp in self.required_stabs:
					self.required_stabs.remove(tp)
			# if moves_for_type == 0 and tp == "ROCK" and pokemon.hasType("ROCK") and len(pokemon.types) == 2:
				# if move_specs_hash == SCUsefulMoves.SPECIAL and tp in self.required_stabs:
					# # Allow Ancient Power. 
					# f1, f2 = self.filterMovesFromArray(SCUsefulMoves.SPECIALCOVERAGE[tp], pokemon)
					# if len(f1) > 0:
						# f_moves += f1 
						# f_moves_types += [tp]
					# self.required_stabs.remove(tp)
			if moves_for_type == 0 and tp == "NORMAL" and pokemon.hasType("NORMAL") and len(pokemon.types) == 2:
				if move_specs_hash == SCUsefulMoves.SPECIAL and tp in self.required_stabs:
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
				# print("HP list: " + str(self.hidden_power))
				if move_specs_hash == SCUsefulMoves.SPECIAL and self.stab_given:
					if tp in self.hidden_power:
						# print("Learned HP " + tp)
						f_moves.append("HIDDENPOWER" + tp)
						f_moves_types.append(tp)
						hidden_power_given = True 
			
			
		if hidden_power_given:
			# input()
			self.hidden_power = []
		
		if is_main_useful_moves:
			self.move_types_given = f_moves_types
		
		return f_moves, f_moves_types
	
	
	
	def checkStats(self, pokemon):
		# Checks if the POkemon has the right profile for the Pattern. 
		# For example, do not give a Calm Mind pattern to Golem or Pinsir. 
		
		# On Snorlax, the expected ordered_stats is: 
		# [ [0], [1, 5], [2, 4], [3]]
		# That is: [ [HP], [Atk, SpD], [Def, SpA], [Speed] ]
		# Mew would have: [ [0,1,2,3,4,5] ] (all stats equal)
		# Kingdra would have: [ [1,2,4,5], [3], [0] ]
		
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
		# self.debug = self.name == "Skill Link Sweeper" and pokemon.name == "CLOYSTER"
		
		# Cheks if the Pokemon is made for using physical or special moves.
		if self.is_for_physical_offensive and not self.is_for_special_offensive and pokemon.bs[4] > pokemon.bs[1] + 10:
			if self.debug:
				input("isValid (step 1): pattern is physical offensive and Pokémon is not")
			return False 
		elif self.is_for_special_offensive and not self.is_for_physical_offensive and pokemon.bs[1] > pokemon.bs[4] + 10:
			if self.debug:
				input("isValid (step 2): pattern is special offensive and Pokémon is not")
			return False 
		
		# Pattern only for certain Pokémons (Arceus...)
		if len(self.for_pokemons) > 0 and pokemon.toTiersStr() not in self.for_pokemons:
			if self.debug:
				input("isValid (step 3): pattern is specific")
			return False 
		
		if not self.checkAbilities(pokemon):
			if self.debug:
				input("isValid (step 4): not the right ability")
			return False 
		
		# Check types. 
		if self.for_type != "" and not self.for_type in pokemon.types:
			if self.debug:
				input("isValid (step 5): not the right types")
			return False
		
		# Check stats (speed requirements and then, stats for the pattern)
		# if pokemon.bs[3] > self.maximum_speed or self.minimum_speed > pokemon.bs[3] :
		if pokemon.bs[3] + (25 * (pokemon.evolution_stage_max - pokemon.evolution_stage)) > self.maximum_speed or self.minimum_speed > pokemon.bs[3] + (25 * (pokemon.evolution_stage_max - pokemon.evolution_stage)):
			if self.debug:
				input("isValid (step 6): not the right speed")
			return False 
			
		if check_stats and not self.checkStats(pokemon):
			if self.debug:
				input("isValid (step 7): not the right stats")
			return False
			
		self.filtered_moves = []
		self.filtered_moves_types = [] 
		
		# First: filter all the moves. 
		self.filtered_moves, self.filtered_moves_types = self.filterMoves(pokemon)
		
		
		if len(self.filtered_moves) == 0:
			if self.debug:
				input("isValid (step 8): not the right moves")
			return False 
			
		if not self.atLeastFourMoves(self.filtered_moves):
			# Adds more moves. 
			self.filtered_moves, self.filtered_moves_types = self.filterMoves(pokemon, True)
		
		return self.atLeastFourMoves(self.filtered_moves) #and self.moreThanTwoMovesInSlots(self.filtered_moves)
	
	
	
	def checkAbilities(self, pokemon):
		# If the pattern requires a specific ability, check if the POkémon 
		# has it. 
		if self.ability:
			for ab in (pokemon.abilities + pokemon.hidden_ability):
				if ab in self.ability:
					return True
			return False 
		else:
			return True 
	
	
	
	def chooseItem(self, pokemon):
		# Besides the items defined when defining the pattern, also give a 
		# few more items, for example to Normal-type Pokémons. 
		# First, check if the Pokemon has a specific item, in which case it has priority.
		if pokemon.required_item != "":
			self.potential_items = [pokemon.required_item]
			return [pokemon.required_item]
		
		personal_items = []
		
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
		
		if self.allow_balloon_boots and pokemon.isAirBalloonCandidate():
			# Give Air Balloon to a Pokemon that needs it. 
			self.potential_items.append("AIRBALLOON")
			
		if self.allow_balloon_boots and pokemon.isHeavyDutyBootsCandidate():
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
	
	
	
	def generateMovesets(self, pokemon):
		# Returns non-deterministic movesets. 
		# Returns "pokemon.name,120" if this pattern doesn't suit this Pokémon.
		
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
		s_tab = "\n    "
		s_pokemon = "Pokemon = " + pokemon.baseFormID() + ",120"
		s_pattern = ""
		s_specific = ""
		
		if self.filtered_moves:
			# Give moves 
			# types_given = [] 
			# Stores the types of the given offensive moves. 
			
			# Moves 
			for m in range(4):
				s_moves += s_tab + "Move" + str(m+1) + " = " + ", ".join(self.filtered_moves[m])
			
			self.chooseItem(pokemon)
			
			# corresponding EVs if applicable. 
			
			if isinstance(self.ev[0], list):
				# Then we have a list of EV spreads. 
				# So the nature will be paired with the EVs. 
				s_evs = ""
				for i in range(len(self.ev)):
					ev_spread = [ str(self.ev[i][j]) for j in range(len(self.ev[i])) ]
					s_evs += s_tab + "EV" + str(i+1) + " = " + ",".join(ev_spread)
			else:
				ev_spread = [ str(self.ev[j]) for j in range(len(self.ev))]
				s_evs = s_tab + "EV1 = " + ",".join(ev_spread)
				
			# Natures
			for n in range(len(self.nature)):
				s_natures += s_tab + "Nature" + str(n+1) + " = " + self.nature[n]
			
			
			iv_spread = [ str(self.iv[j]) for j in range(len(self.iv))]
			s_ivs = ",".join(iv_spread)
			
			
			# Give abilities if specified 
			if pokemon.required_ability != "":
				s_abilities = str(pokemon.required_ability)
			else: 
				for ab in self.ability:
					ab_i = pokemon.indexOfAbility(ab)
					if ab_i != -1:
						s_abilities = str(ab_i)
						break 
			
			
			# Items 
			s_items = ", ".join(self.potential_items)
			
			# Adding the pattern 
			s_pattern = "Pattern = " + self.make_id()
			
			if self.is_specific:
				s_specific = "Specific = yes"
		else:
			return s_pokemon
		
		
		moveset = s_pokemon
		
		if pokemon.form != 0:
			moveset += s_tab + "Form = " + str(pokemon.form) 
		
		if pokemon.unmega != -1:
			moveset += s_tab + "BaseForm = " + str(pokemon.unmega) 
			
		if s_items != "":
			moveset += s_tab + "Item = " + s_items
			
		if s_moves != "":
			moveset += s_moves
			
		if s_abilities != "":
			moveset += s_tab + "Ability = " + s_abilities
			
		if s_natures != "":
			moveset += s_natures
			
		if s_evs != "":
			moveset += s_evs
		
		if s_ivs != "":
			moveset += s_tab + "IV = " + s_ivs
			
		if pokemon.gender != "":
			moveset += s_tab + "Gender = " + pokemon.gender 
		
		if self.role != 0:
			moveset += s_tab + "Role = " + str(self.role)
		
		if s_pattern != "":
			moveset += s_tab + s_pattern
		
		if s_specific != "":
			moveset += s_tab + s_specific
		
		return moveset 
	
	
	
	
	def disallowAllItems(self):
		self.allow_heavy_duty_boots = False 
		self.allow_balloon_boots = False 
		self.allow_sc_crystals = False 
		self.allow_sc_coats = False 
		self.allow_personal_items = False 
	
	
	
	
	def reset(self):
		# Reset before handling another Pokémon. 
		self.filtered_moves = []
	
	
	def isPnotS(self):
		# Sets the pattern to be for physical offensive Pokémon, not for 
		# special offensive. For example, a Bulk Up set, even if the POkémon 
		# s defensive, is meant for POkémon that are a bit more physical than 
		# special. 
		self.is_for_physical_offensive = True 
		self.is_for_special_offensive = False 
	
	
	def isSnotP(self):
		# Sets the pattern to be for special offensive Pokémon, not for 
		# physical offensive. For example, a Calm Mind set, even if the POkémon 
		# s defensive, is meant for POkémon that are a bit more special than 
		# physical. 
		self.is_for_physical_offensive = False 
		self.is_for_special_offensive = True 
	
	
	def isSandP(self):
		# Sets the pattern to be for special both physical and special 
		# offensive Pokémon. Typically for defensive patterns that allow for 
		# the use of both physcial and special moves. 
		self.is_for_physical_offensive = True 
		self.is_for_special_offensive = True 
	
	
	def giveRevelationDance(self, pokemon):
		# Specific function to give to Oricorio a move that will always be a 
		# STAB. 
		if pokemon.name == "ORICORIO":
			t = pokemon.types
			t2 = [tp for tp in t if tp != "FLYING"]
			return t2[0]
		else:
			return "" 
	
	
	def atLeastFourMoves(self, filtered_moves):
		# Checks if the filtered moves contain at least four moves. Otherwise, 
		# the pattern will be canceled. 
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
		# DEPRECATED. 
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
	
	
	def clone(self, new_evs, new_natures, new_name = ""):
		# Clones this pattern. Allows for later modificaitons. 
		der_clone = SCPattern(self.move_specs[0], self.move_specs[1], self.move_specs[2], 
						self.move_specs[3], [m for m in self.main_stats])
		if new_evs is None:
			der_clone.ev = self.ev 
		else:
			der_clone.ev = new_evs
		
		if new_natures is None:
			der_clone.nature = self.nature
		else:
			der_clone.nature = new_natures
		
		der_clone.iv = [i for i in self.iv]
		der_clone.ability = [a for a in self.ability]
		der_clone.items = [i for i in self.items]
		der_clone.is_for_physical_offensive = self.is_for_physical_offensive 
		der_clone.is_for_special_offensive = self.is_for_special_offensive 
		der_clone.maximum_speed = self.maximum_speed
		der_clone.minimum_speed = self.minimum_speed
		
		if new_name == "":
			der_clone.name = self.name
			der_clone.make_id()
		else:
			der_clone.name = new_name
		
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
		der_clone.allow_balloon_boots = self.allow_balloon_boots 
		der_clone.role = self.role 
		der_clone.category = self.category 
		der_clone.is_specific = self.is_specific 
		
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
		self.category = cat 
	
	
	def make_id(self):
		if self.essentials_id != "":
			return self.essentials_id
		
		s = self.name.replace(" ","")
		s = s.replace("(","")
		s = s.replace(")","")
		s = s.replace("[","")
		s = s.replace("]","")
		s = s.replace("-","")
		s = s.replace(":","")
		s = s.replace(".","")
		s = s.replace("'","")
		s = s.replace("’","")
		s = s.replace("\r","")
		s = s.replace("\n","")
		s = s.upper()
		
		self.essentials_id = s 
		
		return self.essentials_id
	
	
	def avoidAbilities(self, pokemon):
		abs_to_avoid = ["ZENMODE", "KLUTZ", "CURIOUSMEDICINE", "RUNAWAY", "RIVALRY", "SLOWSTART", "STALL", "NORMALIZE"]



# =============================================================================
# Class (module) defining the patterns that are specific to given Pokémons. 
# These movesets have priority for them. 
# =============================================================================
class SCSpecificPatterns:
	# For these Patterns, do not check the stats. 
	
	ALL = []
	
	
	
	
	
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
	MEGALAUNCHER.name = "Mega-Launcher"
	ALL.append(MEGALAUNCHER)
	
	
	
	
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
	MULTITYPESPECIAL.name = "Multitype Spe."
	ALL.append(MULTITYPESPECIAL)
	
	MULTITYPESPECIAL2 = SCPattern(
		"JUDGMENT",
		"RECOVER",
		SCUsefulMoves.SPECIAL,
		["CALMMIND", "KINDLING","NASTYPLOT","QUIVERDANCE"],
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Arceus.
	MULTITYPESPECIAL2.ev = [[252,0,0,252,6,0], [6,0,0,252,252,0]]
	MULTITYPESPECIAL2.nature = ["TIMID", "MODEST"]
	MULTITYPESPECIAL2.items = ["FLAMEPLATE", "SPLASHPLATE", "ZAPPLATE", "MEADOWPLATE", "ICICLEPLATE", "FISTPLATE", "TOXICPLATE", "EARTHPLATE", "SKYPLATE", "MINDPLATE", "INSECTPLATE", "STONEPLATE", "SPOOKYPLATE", "DRACOPLATE", "DREADPLATE", "IRONPLATE", "PIXIEPLATE"]
	MULTITYPESPECIAL2.isSnotP()
	MULTITYPESPECIAL2.dont_check_stabs = True 
	MULTITYPESPECIAL2.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	MULTITYPESPECIAL2.ability = ["MULTITYPE"]
	MULTITYPESPECIAL2.name = "Multitype Spe. Set-Up"
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
	MULTITYPEPHYSICAL.name = "Multitype Phy."
	ALL.append(MULTITYPEPHYSICAL)
	
	
	
	#-----------------------------------
	# Silvally
	#-----------------------------------
	
	RKSSYSTEM = SCPattern(
		"SWORDSDANCE",
		"MULTIATTACK",
		SCUsefulMoves.PHYSICAL,
		"P+FS",
		[SCStatPatterns.HP]) # Stat patterns don't matter because it's only for Silvally.
	RKSSYSTEM.ev = [[6,252,0,252,0,0], [240,252,0,16,0,0], [252,6,0,252,0,0], [6,252,0,252,0,0]]
	RKSSYSTEM.nature = ["ADAMANT", "ADAMANT", "JOLLY", "JOLLY"]
	RKSSYSTEM.items = ["FIGHTINGMEMORY", "FLYINGMEMORY", "POISONMEMORY", "GROUNDMEMORY", "ROCKMEMORY", "BUGMEMORY", "GHOSTMEMORY", "STEELMEMORY", "FIREMEMORY", "WATERMEMORY", "GRASSMEMORY", "ELECTRICMEMORY", "PSYCHICMEMORY", "ICEMEMORY", "DRAGONMEMORY", "DARKMEMORY", "FAIRYMEMORY"]
	RKSSYSTEM.isPnotS()
	RKSSYSTEM.dont_check_stabs = True 
	RKSSYSTEM.ability = ["RKSSYSTEM"]
	RKSSYSTEM.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	RKSSYSTEM.name = "RKS System"
	ALL.append(RKSSYSTEM)
	
	
	
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
	PUNKROCK.name = "Punk Rock Sweeper"
	ALL.append(PUNKROCK)
	
	
	#-----------------------------------
	# Darmanitan-Ice  
	#-----------------------------------
	
	DARMANITANCHOICE = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+SO+PP+PC",
		"P+V",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK_SPE])
	DARMANITANCHOICE.ev = [6,252,0,252,0,0]
	DARMANITANCHOICE.nature = ["JOLLY", "ADAMANT"]
	DARMANITANCHOICE.items = ["CHOICEBAND", "CHOICESCARF"]
	DARMANITANCHOICE.isPnotS()
	DARMANITANCHOICE.minimum_speed = 70
	DARMANITANCHOICE.allow_personal_items = False 
	DARMANITANCHOICE.ability = ["GORILLATACTICS"]
	DARMANITANCHOICE.name = "Darmanitan Choice"
	ALL.append(DARMANITANCHOICE)
	



def adapt_pattern_for_pokemon(pokemon, pattern, wanted_role, wanted_cat, species_list, required_item, required_ability):
	# Some Pokémon might have have abilities or items that greatly improve 
	# their stats. This function makes the pattern ignore their stats. 
	# For example, Marowak with Thick Bone deserves offensive patterns, 
	# while its sttas are defensive. 
	if len(species_list) > 0 and pokemon.name not in species_list:
		return [] 
	if required_ability != "" and required_ability not in pokemon.abilities and required_ability not in pokemon.hidden_ability:
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
	
	# pattern.reset()
	
	return movesets





# =============================================================================
# Class (module) containing general patterns, suitable for most Pokémons. 
# =============================================================================
class SCAllPatterns:
	
	ALL = []
	# ALLPATTERNS = [] # Only the most useful
	# ALLPATTERNSINCASE = [] # To be used only if the POkémon has not many movesets. 
	# SPECIFICPATTERNS = [] # Priority patterns for Pokémons with special abilities or moves. 
	
	
	#-----------------------------------
	# Geomancer 
	#-----------------------------------
	
	GEOMANCER = SCPattern(
		"GEOMANCY",
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		"FS+S+SP",
		[SCStatPatterns.HP, SCStatPatterns.SPA])
	GEOMANCER.ev = [252, 0, 0, 6, 252, 0]
	GEOMANCER.nature = ["MODEST"]
	GEOMANCER.items = ["POWERHERB"]
	GEOMANCER.isSnotP()
	GEOMANCER.name = "Geomancer"
	ALL.append(GEOMANCER)
	
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
	PRANKSTER.name = "Prankster (Spe)"
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
	PRANKSTER2.name = "Prankster (Phy)"
	ALL.append(PRANKSTER2)

	#-----------------------------------
	# Skill link
	#-----------------------------------
	
	# Skill link
	SKILLLINK1 = SCPattern(
		["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "SHELLSMASH"],
		SCUsefulMoves.PHYSICALMULTIHIT,
		"PMH+P",
		"P+PMH+FS+PP",
		[SCStatPatterns.SPE, SCStatPatterns.ATK])
	SKILLLINK1.ev = [6,252,0,252,0,0]
	SKILLLINK1.nature = ["ADAMANT", "JOLLY"]
	SKILLLINK1.items = ["LEFTOVERS", "LIFEORB", "MUSCLEBAND"]
	SKILLLINK1.isPnotS()
	SKILLLINK1.ability = ["SKILLLINK"]
	SKILLLINK1.name = "Skill Link Set-Up"
	ALL.append(SKILLLINK1)
	
	# Skill link
	SKILLLINK2 = SCPattern(
		SCUsefulMoves.PHYSICALMULTIHIT,
		"PMH+P",
		"PMH+P",
		"P+PMH+PP+V",
		[SCStatPatterns.SPE, SCStatPatterns.ATK])
	SKILLLINK2.ev = [6,252,0,252,0,0]
	SKILLLINK2.nature = ["ADAMANT", "JOLLY"]
	SKILLLINK2.items = ["CHOICEBAND", "LIFEORB", "MUSCLEBAND"]
	SKILLLINK2.isPnotS()
	SKILLLINK2.ability = ["SKILLLINK"]
	SKILLLINK2.name = "Skill Link Sweeper"
	ALL.append(SKILLLINK2)
	
	#-----------------------------------
	# Stored power for the lol 
	#-----------------------------------
	
	COSMICPOWER = SCPattern(
		SCUsefulMoves.oneTypeHash("PSYCHIC", "STOREDPOWER"),
		["BODYPRESS", "CALMMIND", "KINDLING", "NASTYPLOT", "QUIVERDANCE", "AMNESIA"],
		["COSMICPOWER", "DEFENDORDER", "STOCKPILE", "IRONDEFENSE"],
		"S+H+ST",
		[SCStatPatterns.HP, SCStatPatterns.DEF, SCStatPatterns.SPD])
	COSMICPOWER.ev = [[252, 0, 0, 252, 6, 0],[252, 0, 252, 0, 6, 0],[252, 0, 0, 0, 6, 252]]
	COSMICPOWER.nature = ["TIMID", "BOLD", "CALM"]
	COSMICPOWER.items = ["LEFTOVERS"]
	COSMICPOWER.allow_sc_coats = True 
	COSMICPOWER.allow_sc_crystals = False 
	COSMICPOWER.for_type = "PSYCHIC"
	COSMICPOWER.name = "Stored Power"
	COSMICPOWER.isSnotP()
	COSMICPOWER.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(COSMICPOWER)
	
	
	#-----------------------------------
	# Baton Pass 
	#-----------------------------------
	
	BATONPASSSPE = SCPattern(
		"BATONPASS",
		["QUIVERDANCE", "CALMMIND", "KINDLING", "TAILGLOW", "NASTYPLOT"],
		["AGILITY", "ROCKPOLISH", "SHIFTGEAR", "AUTOTOMIZE", "IRONDEFENSE"],
		SCUsefulMoves.SPECIAL,
		[SCStatPatterns.HP, SCStatPatterns.SPE])
	BATONPASSSPE.ev = [252, 0, 0, 252, 6, 0]
	BATONPASSSPE.nature = ["TIMID"]
	BATONPASSSPE.items = ["LEFTOVERS"]
	BATONPASSSPE.allow_sc_coats = False 
	BATONPASSSPE.allow_sc_crystals = False 
	BATONPASSSPE.name = "Special Baton Pass"
	BATONPASSSPE.isSnotP()
	BATONPASSSPE.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(BATONPASSSPE)
	
	
	BATONPASSPHY = SCPattern(
		"BATONPASS",
		["BELLYDRUM", "CLANGOROUSSOUL", "COIL", "BULKUP", "SWORDSDANCE", "DRAGONDANCE"],
		["AGILITY", "ROCKPOLISH", "SHIFTGEAR", "AUTOTOMIZE", "AMNESIA"],
		SCUsefulMoves.PHYSICAL,
		[SCStatPatterns.HP, SCStatPatterns.DEF, SCStatPatterns.SPD])
	BATONPASSPHY.ev = [252, 0, 0, 252, 6, 0]
	BATONPASSPHY.nature = ["JOLLY"]
	BATONPASSPHY.items = ["LEFTOVERS"]
	BATONPASSPHY.allow_sc_coats = False 
	BATONPASSPHY.allow_sc_crystals = False 
	BATONPASSPHY.name = "Physical Baton Pass"
	BATONPASSPHY.isPnotS()
	BATONPASSPHY.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	ALL.append(BATONPASSPHY)
	
	
	
	#-----------------------------------
	# Offensive support 
	#-----------------------------------
	
	OFFENSIVESUPPORTPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.HEALING,
		[SCStatPatterns.ATK, SCStatPatterns.SPE])
	OFFENSIVESUPPORTPHYSICAL.ev = [[252, 6, 0, 252, 0, 0],[6, 252, 0, 252, 0, 0]]
	OFFENSIVESUPPORTPHYSICAL.nature = ["JOLLY", "JOLLY"]
	OFFENSIVESUPPORTPHYSICAL.items = ["LEFTOVERS", "LIFEORB", "GENERICZCRYSTAL"]
	OFFENSIVESUPPORTPHYSICAL.allow_sc_coats = True 
	OFFENSIVESUPPORTPHYSICAL.allow_sc_crystals = True 
	OFFENSIVESUPPORTPHYSICAL.isPnotS()
	OFFENSIVESUPPORTPHYSICAL.minimum_speed = 70
	OFFENSIVESUPPORTPHYSICAL.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	OFFENSIVESUPPORTPHYSICAL.name = "Offensive Support 1"
	ALL.append(OFFENSIVESUPPORTPHYSICAL)
	
	
	OFFENSIVESUPPORTSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.FULLSUPPORTNOHEALING,
		SCUsefulMoves.HEALING,
		[SCStatPatterns.SPA, SCStatPatterns.SPE])
	OFFENSIVESUPPORTSPECIAL.ev = [[252, 0, 0, 252, 6, 0],[6, 0, 0, 252, 252, 0]]
	OFFENSIVESUPPORTSPECIAL.nature = ["TIMID", "TIMID"]
	OFFENSIVESUPPORTSPECIAL.items = ["LEFTOVERS", "LIFEORB", "GENERICZCRYSTAL"]
	OFFENSIVESUPPORTSPECIAL.allow_sc_coats = True 
	OFFENSIVESUPPORTSPECIAL.allow_sc_crystals = True 
	OFFENSIVESUPPORTSPECIAL.isSnotP()
	OFFENSIVESUPPORTSPECIAL.minimum_speed = 70
	OFFENSIVESUPPORTSPECIAL.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	OFFENSIVESUPPORTSPECIAL.name = "Offensive Support 2"
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
	LEADPHYSICAL.minimum_speed = 80
	LEADPHYSICAL.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	LEADPHYSICAL.name = "Lead 1"
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
	LEADSPECIAL.minimum_speed = 80
	LEADSPECIAL.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	LEADSPECIAL.name = "Lead 2"
	ALL.append(LEADSPECIAL)
	
	LEADOFFENSIVEPHY = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.HAZARDS,
		"V+P+PP+SO+SU+ST",
		[SCStatPatterns.ATK, SCStatPatterns.ATK_SPE, SCStatPatterns.HP_SPE])
	LEADOFFENSIVEPHY.ev = [252, 6, 0, 252, 0, 0]
	LEADOFFENSIVEPHY.nature = ["JOLLY"]
	LEADOFFENSIVEPHY.items = ["LEFTOVERS", "FOCUSSASH", "LIFEORB"]
	LEADOFFENSIVEPHY.isPnotS()
	LEADOFFENSIVEPHY.minimum_speed = 80
	LEADOFFENSIVEPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	LEADOFFENSIVEPHY.name = "Lead 3"
	ALL.append(LEADOFFENSIVEPHY)
	
	LEADOFFENSIVESPE = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.HAZARDS,
		"V+S+SP+SO+SU+ST",
		[SCStatPatterns.SPA, SCStatPatterns.SPA_SPE, SCStatPatterns.HP_SPE])
	LEADOFFENSIVESPE.ev = [252, 0, 0, 252, 6, 0]
	LEADOFFENSIVESPE.nature = ["TIMID"]
	LEADOFFENSIVESPE.items = ["LEFTOVERS", "FOCUSSASH", "LIFEORB"]
	LEADOFFENSIVESPE.isSnotP()
	LEADOFFENSIVESPE.minimum_speed = 80
	LEADOFFENSIVESPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	LEADOFFENSIVESPE.name = "Lead 4"
	ALL.append(LEADOFFENSIVESPE)
	
	
	#-----------------------------------
	# Leads (Mandalas)
	#-----------------------------------
	
	# Dual mandalas
	DUALMANDALASPE = SCPattern(
		"MINDMANDALA", 
		"WARMANDALA",
		SCUsefulMoves.SPECIAL,
		"V+S+SP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	DUALMANDALASPE.ev = [252,0,0,252,6,0]
	DUALMANDALASPE.nature = ["TIMID"]
	DUALMANDALASPE.items = ["LEFTOVERS"]
	DUALMANDALASPE.isSnotP()
	DUALMANDALASPE.name = "Dual Mandalas (Spe)"
	DUALMANDALASPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(DUALMANDALASPE)
	
	
	DUALMANDALAPHY = SCPattern(
		"MINDMANDALA", 
		"WARMANDALA",
		SCUsefulMoves.PHYSICAL,
		"V+P+PP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	DUALMANDALAPHY.ev = [252,6,0,252,0,0]
	DUALMANDALAPHY.nature = ["JOLLY"]
	DUALMANDALAPHY.items = ["LEFTOVERS"]
	DUALMANDALAPHY.isPnotS()
	DUALMANDALAPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	DUALMANDALAPHY.name = "Dual Mandalas (Phy)"
	ALL.append(DUALMANDALAPHY)
	
	DUALMANDALABULKY1 = DUALMANDALASPE.clone([252,0,0,0,6,252], ["CALM"], "Dual Mandalas Bulky 1")
	DUALMANDALABULKY1.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(DUALMANDALABULKY1)
	DUALMANDALABULKY2 = DUALMANDALASPE.clone([252,0,252,0,6,0], ["BOLD"], "Dual Mandalas Bulky 2")
	DUALMANDALABULKY2.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(DUALMANDALABULKY2)
	DUALMANDALABULKY3 = DUALMANDALAPHY.clone([252,6,0,0,0,252], ["CAREFUL"], "Dual Mandalas Bulky 3")
	DUALMANDALABULKY3.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(DUALMANDALABULKY3)
	DUALMANDALABULKY4 = DUALMANDALAPHY.clone([252,6,252,0,0,0], ["IMPISH"], "Dual Mandalas Bulky 4")
	DUALMANDALABULKY4.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(DUALMANDALABULKY4)
	
	# One mandala, offensive.
	MANDALASPE = SCPattern(
		["MINDMANDALA", "WARMANDALA"], 
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL,
		"V+S+SP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	MANDALASPE.ev = [252,0,0,252,6,0]
	MANDALASPE.nature = ["TIMID"]
	MANDALASPE.items = ["LEFTOVERS"]
	MANDALASPE.isSnotP()
	MANDALASPE.name = "Mandala (Spe)"
	MANDALASPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(MANDALASPE)
	
	
	MANDALAPHY = SCPattern(
		["MINDMANDALA", "WARMANDALA"],
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		"V+P+PP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	MANDALAPHY.ev = [252,6,0,252,0,0]
	MANDALAPHY.nature = ["JOLLY"]
	MANDALAPHY.items = ["LEFTOVERS"]
	MANDALAPHY.isPnotS()
	MANDALAPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	MANDALAPHY.name = "Mandala (Phy)"
	ALL.append(MANDALAPHY)
	
	
	# Mandala + Hazard.
	MANDALAHAZARDSSPE = SCPattern(
		["MINDMANDALA", "WARMANDALA"], 
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.SPECIAL,
		"V+S+SP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	MANDALAHAZARDSSPE.ev = [252,0,0,252,6,0]
	MANDALAHAZARDSSPE.nature = ["TIMID"]
	MANDALAHAZARDSSPE.items = ["LEFTOVERS"]
	MANDALAHAZARDSSPE.isSnotP()
	MANDALAHAZARDSSPE.name = "Mandala Hazard (Spe)"
	MANDALAHAZARDSSPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(MANDALAHAZARDSSPE)
	
	
	MANDALAHAZARDSPHY = SCPattern(
		["MINDMANDALA", "WARMANDALA"],
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.PHYSICAL,
		"V+P+PP+SO+SU+ST",
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	MANDALAHAZARDSPHY.ev = [252,6,0,252,0,0]
	MANDALAHAZARDSPHY.nature = ["JOLLY"]
	MANDALAHAZARDSPHY.items = ["LEFTOVERS"]
	MANDALAHAZARDSPHY.isPnotS()
	MANDALAHAZARDSPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	MANDALAHAZARDSPHY.name = "Mandala Hazard (Phy)"
	ALL.append(MANDALAHAZARDSPHY)
	
	MANDALAHAZARDSDEFSPE1 = MANDALAHAZARDSSPE.clone([252,0,0,0,6,252], ["CALM"], "Mandala Hazard Bulky 1")
	MANDALAHAZARDSDEFSPE1.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(MANDALAHAZARDSDEFSPE1)
	MANDALAHAZARDSDEFSPE2 = MANDALAHAZARDSSPE.clone([252,0,252,0,6,0], ["BOLD"], "Mandala Hazard Bulky 2")
	MANDALAHAZARDSDEFSPE2.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(MANDALAHAZARDSDEFSPE2)
	MANDALAHAZARDSDEFSPE3 = MANDALAHAZARDSPHY.clone([252,6,0,0,0,252], ["CAREFUL"], "Mandala Hazard Bulky 3")
	MANDALAHAZARDSDEFSPE3.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(MANDALAHAZARDSDEFSPE3)
	MANDALAHAZARDSDEFSPE4 = MANDALAHAZARDSPHY.clone([252,6,252,0,0,0], ["IMPISH"], "Mandala Hazard Bulky 4")
	MANDALAHAZARDSDEFSPE4.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(MANDALAHAZARDSDEFSPE4)
	
	
	#-----------------------------------
	# Warm Welcome (lead)
	#-----------------------------------
	
	# Offensive
	WELCOMESPE = SCPattern(
		"WARMWELCOME", 
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		"H+S+SP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	WELCOMESPE.ev = [252,0,0,252,6,0]
	WELCOMESPE.nature = ["TIMID"]
	WELCOMESPE.items = ["LEFTOVERS"]
	WELCOMESPE.isSnotP()
	WELCOMESPE.name = "Welcome Lead (Spe)"
	WELCOMESPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(WELCOMESPE)
	
	
	WELCOMEPHY = SCPattern(
		"WARMWELCOME", 
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		"H+P+PP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	WELCOMEPHY.ev = [252,6,0,252,0,0]
	WELCOMEPHY.nature = ["JOLLY"]
	WELCOMEPHY.items = ["LEFTOVERS"]
	WELCOMEPHY.isPnotS()
	WELCOMEPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	WELCOMEPHY.name = "Welcome Lead (Phy)"
	ALL.append(WELCOMEPHY)
	
	WELCOMEBULKY1 = WELCOMESPE.clone([252,0,0,0,6,252], ["CALM"], "Welcome Bulky 1")
	WELCOMEBULKY1.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEBULKY1)
	WELCOMEBULKY2 = WELCOMESPE.clone([252,0,252,0,6,0], ["BOLD"], "Welcome Bulky 2")
	WELCOMEBULKY2.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEBULKY2)
	WELCOMEBULKY3 = WELCOMEPHY.clone([252,6,0,0,0,252], ["CAREFUL"], "Welcome Bulky 3")
	WELCOMEBULKY3.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEBULKY3)
	WELCOMEBULKY4 = WELCOMEPHY.clone([252,6,252,0,0,0], ["IMPISH"], "Welcome Bulky 4")
	WELCOMEBULKY4.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEBULKY4)
	
	# Warm Welcome + Hazard.
	WELCOMEHAZARDSSPE = SCPattern(
		"WARMWELCOME", 
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	WELCOMEHAZARDSSPE.ev = [252,0,0,252,6,0]
	WELCOMEHAZARDSSPE.nature = ["TIMID"]
	WELCOMEHAZARDSSPE.items = ["LEFTOVERS"]
	WELCOMEHAZARDSSPE.isSnotP()
	WELCOMEHAZARDSSPE.name = "Welcome Lead Hazard (Spe)"
	WELCOMEHAZARDSSPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(WELCOMEHAZARDSSPE)
	
	
	WELCOMEHAZARDSPHY = SCPattern(
		"WARMWELCOME", 
		SCUsefulMoves.HAZARDS,
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	WELCOMEHAZARDSPHY.ev = [252,6,0,252,0,0]
	WELCOMEHAZARDSPHY.nature = ["JOLLY"]
	WELCOMEHAZARDSPHY.items = ["LEFTOVERS"]
	WELCOMEHAZARDSPHY.isPnotS()
	WELCOMEHAZARDSPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	WELCOMEHAZARDSPHY.name = "Welcome Lead Hazard (Phy)"
	ALL.append(WELCOMEHAZARDSPHY)
	
	WELCOMEHAZARDSBULKY1 = WELCOMEHAZARDSSPE.clone([252,0,0,0,6,252], ["CALM"], "Welcome Hazard Bulky 1")
	WELCOMEHAZARDSBULKY1.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEHAZARDSBULKY1)
	WELCOMEHAZARDSBULKY2 = WELCOMEHAZARDSSPE.clone([252,0,252,0,6,0], ["BOLD"], "Welcome Hazard Bulky 2")
	WELCOMEHAZARDSBULKY2.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEHAZARDSBULKY2)
	WELCOMEHAZARDSBULKY3 = WELCOMEHAZARDSPHY.clone([252,6,0,0,0,252], ["CAREFUL"], "Welcome Hazard Bulky 3")
	WELCOMEHAZARDSBULKY3.main_stats = [SCStatPatterns.HP_SPD, SCStatPatterns.SPD, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEHAZARDSBULKY3)
	WELCOMEHAZARDSBULKY4 = WELCOMEHAZARDSPHY.clone([252,6,252,0,0,0], ["IMPISH"], "Welcome Hazard Bulky 4")
	WELCOMEHAZARDSBULKY4.main_stats = [SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD]
	ALL.append(WELCOMEHAZARDSBULKY4)
	
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
	DEFENSIVEPHYSICAL.name = "Physical Defensive 1"
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
	DEFENSIVEPHYSICAL2.name = "Physical Defensive 2"
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
	DEFENSIVESPECIAL.name = "Special Defensive 1"
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
	DEFENSIVESPECIAL2.name = "Special Defensive 2"
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
	SUPPORTPHYSICAL.name = "Support 1"
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
	SUPPORTPHYSICAL2.name = "Support 2"
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
	SUPPORTSPECIAL.name = "Support 3"
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
	SUPPORTSPECIAL2.name = "Support 4"
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
	WISHSUPPORT.name = "Wish 1"
	ALL.append(WISHSUPPORT)
	
	# Clone for special defense
	WISHSUPPORT2 = WISHSUPPORT.clone([252, 0, 6, 0, 0, 252], ["CALM"], "Wish 2")
	ALL.append(WISHSUPPORT2)
	
	WISHSUPPORT3 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORT + SCUsefulMoves.VOLTTURN,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD])
	WISHSUPPORT3.ev = [252, 0, 252, 0, 0, 6]
	WISHSUPPORT3.nature = ["IMPISH"]
	WISHSUPPORT3.items = ["LEFTOVERS"]
	WISHSUPPORT3.isPnotS()
	WISHSUPPORT3.name = "Wish 3"
	ALL.append(WISHSUPPORT3)
	
	# Clone for special defense
	WISHSUPPORT4 = WISHSUPPORT3.clone([252, 0, 6, 0, 0, 252], ["CAREFUL"], "Wish 4")
	ALL.append(WISHSUPPORT4)
	
	
	WISHSUPPORT5 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		"V+S+SP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WISHSUPPORT5.ev = [252, 0, 0, 252, 0, 6]
	WISHSUPPORT5.nature = ["TIMID"]
	WISHSUPPORT5.items = ["LEFTOVERS"]
	WISHSUPPORT5.isSnotP()
	WISHSUPPORT5.name = "Wish 5"
	WISHSUPPORT5.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(WISHSUPPORT5)
	
	WISHSUPPORT6 = SCPattern(
		"WISH",
		SCUsefulMoves.PROTECT + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		"V+P+PP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WISHSUPPORT6.ev = [252, 0, 0, 252, 0, 6]
	WISHSUPPORT6.nature = ["JOLLY"]
	WISHSUPPORT6.items = ["LEFTOVERS"]
	WISHSUPPORT6.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	WISHSUPPORT6.name = "Wish 6"
	WISHSUPPORT6.isPnotS()
	ALL.append(WISHSUPPORT6)
	
	
	
	#-----------------------------------
	# Warm Welcome (support)
	#-----------------------------------
	
	WELCOMESUPPORT = SCPattern(
		"WARMWELCOME",
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD])
	WELCOMESUPPORT.ev = [252, 0, 252, 0, 0, 6]
	WELCOMESUPPORT.nature = ["BOLD"]
	WELCOMESUPPORT.items = ["LEFTOVERS"]
	WELCOMESUPPORT.isSnotP()
	WELCOMESUPPORT.name = "Welcome 1"
	ALL.append(WELCOMESUPPORT)
	
	# Clone for special defense
	WELCOMESUPPORT2 = WELCOMESUPPORT.clone([252, 0, 6, 0, 0, 252], ["CALM"], "Welcome 2")
	ALL.append(WELCOMESUPPORT2)
	
	WELCOMESUPPORT3 = SCPattern(
		"WARMWELCOME",
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.DEF_SPD])
	WELCOMESUPPORT3.ev = [252, 0, 252, 0, 0, 6]
	WELCOMESUPPORT3.nature = ["IMPISH"]
	WELCOMESUPPORT3.items = ["LEFTOVERS"]
	WELCOMESUPPORT3.isPnotS()
	WELCOMESUPPORT3.name = "Welcome 3"
	ALL.append(WELCOMESUPPORT3)
	
	# Clone for special defense
	WELCOMESUPPORT4 = WELCOMESUPPORT3.clone([252, 0, 6, 0, 0, 252], ["CAREFUL"], "Welcome 4")
	ALL.append(WELCOMESUPPORT4)
	
	
	WELCOMESUPPORT5 = SCPattern(
		"WARMWELCOME",
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.SPECIAL,
		"S+SP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WELCOMESUPPORT5.ev = [252, 0, 0, 252, 0, 6]
	WELCOMESUPPORT5.nature = ["TIMID"]
	WELCOMESUPPORT5.items = ["LEFTOVERS"]
	WELCOMESUPPORT5.isSnotP()
	WELCOMESUPPORT5.name = "Welcome 5"
	WELCOMESUPPORT5.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(WELCOMESUPPORT5)
	
	WELCOMESUPPORT6 = SCPattern(
		"WARMWELCOME",
		SCUsefulMoves.VOLTTURN + ["TELEPORT"],
		SCUsefulMoves.PHYSICAL,
		"P+PP",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPE])
	WELCOMESUPPORT6.ev = [252, 0, 0, 252, 0, 6]
	WELCOMESUPPORT6.nature = ["JOLLY"]
	WELCOMESUPPORT6.items = ["LEFTOVERS"]
	WELCOMESUPPORT6.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	WELCOMESUPPORT6.name = "Welcome 6"
	WELCOMESUPPORT6.isPnotS()
	ALL.append(WELCOMESUPPORT6)
	
	
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
	AGILITYSWEEPERPHYSICAL.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "MUSCLEBAND", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	AGILITYSWEEPERPHYSICAL.isPnotS()
	AGILITYSWEEPERPHYSICAL.allow_sc_coats = True 
	AGILITYSWEEPERPHYSICAL.allow_sc_crystals = True 
	AGILITYSWEEPERPHYSICAL.maximum_speed = 70
	AGILITYSWEEPERPHYSICAL.name = "Physical Agility"
	ALL.append(AGILITYSWEEPERPHYSICAL)
	
	AGILITYSWEEPERSPECIAL = SCPattern(
		["AGILITY", "ROCKPOLISH", "AUTOTOMIZE"],
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"S+FS+SC", 
		[SCStatPatterns.HP_ATK, SCStatPatterns.ATK])
	AGILITYSWEEPERSPECIAL.ev = [252,0,0,6,252,0]
	AGILITYSWEEPERSPECIAL.nature = ["TIMID", "MODEST"]
	AGILITYSWEEPERSPECIAL.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	AGILITYSWEEPERSPECIAL.isSnotP()
	AGILITYSWEEPERSPECIAL.allow_sc_coats = True 
	AGILITYSWEEPERSPECIAL.allow_sc_crystals = True 
	AGILITYSWEEPERSPECIAL.maximum_speed = 70
	AGILITYSWEEPERSPECIAL.name = "Special Agility"
	ALL.append(AGILITYSWEEPERSPECIAL)
	
	
	#-----------------------------------
	# Choice Band/Specs/Scarf
	#-----------------------------------
	CHOICEPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+SO+PP+PC",
		"P+V",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK_SPE])
	CHOICEPHYSICAL.ev = [6,252,0,252,0,0]
	CHOICEPHYSICAL.nature = ["JOLLY", "ADAMANT"]
	CHOICEPHYSICAL.items = ["CHOICEBAND", "CHOICESCARF"]
	CHOICEPHYSICAL.isPnotS()
	CHOICEPHYSICAL.minimum_speed = 70
	CHOICEPHYSICAL.allow_personal_items = False 
	CHOICEPHYSICAL.allow_balloon_boots = False 
	CHOICEPHYSICAL.name = "Fast Physical Choice"
	ALL.append(CHOICEPHYSICAL)
	
	CHOICEPHYSICALSLOW = CHOICEPHYSICAL.clone([252,252,6,0,0,0],  ["ADAMANT", "BRAVE"], "Slow Physical Choice")
	CHOICEPHYSICALSLOW.maximum_speed = 70
	CHOICEPHYSICALSLOW.minimum_speed = 0
	CHOICEPHYSICALSLOW.items = ["CHOICEBAND"]
	CHOICEPHYSICALSLOW.main_stats = [SCStatPatterns.ATK, SCStatPatterns.HP_ATK]
	ALL.append(CHOICEPHYSICALSLOW)
	
	
	CHOICESPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"SP+S+SO+SC", 
		"V+S", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA_SPE])
	CHOICESPECIAL.ev = [6,0,0,252,252,0]
	CHOICESPECIAL.nature = ["TIMID", "MODEST"]
	CHOICESPECIAL.items = ["CHOICESPECS", "CHOICESCARF"]
	CHOICESPECIAL.allow_personal_items = False 
	CHOICESPECIAL.allow_balloon_boots = False 
	CHOICESPECIAL.isSnotP()
	CHOICESPECIAL.minimum_speed = 70
	CHOICESPECIAL.name = "Fast Special Choice"
	ALL.append(CHOICESPECIAL)
	
	CHOICESPECIALSLOW = CHOICESPECIAL.clone([252,0,6,0,252,0],  ["QUIET", "MODEST"], "Slow Special Choice")
	CHOICESPECIALSLOW.maximum_speed = 70
	CHOICESPECIALSLOW.minimum_speed = 0
	CHOICESPECIALSLOW.items = ["CHOICESPECS"]
	CHOICESPECIALSLOW.main_stats = [SCStatPatterns.SPA, SCStatPatterns.HP_SPA]
	ALL.append(CHOICESPECIALSLOW)
	
	# Mixed are handled later
	
	#-----------------------------------
	# Life Orbs  
	#-----------------------------------
	LIFEORBPHYSICAL = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL, 
		"P+SO+PP+PC",
		"P+V+FS",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK_SPE])
	LIFEORBPHYSICAL.ev = [6,252,0,252,0,0]
	LIFEORBPHYSICAL.nature = ["JOLLY", "ADAMANT"]
	LIFEORBPHYSICAL.items = ["LIFEORB"]
	LIFEORBPHYSICAL.minimum_speed = 70
	LIFEORBPHYSICAL.isPnotS()
	LIFEORBPHYSICAL.name = "Physical Life Orb"
	ALL.append(LIFEORBPHYSICAL)
	
	LIFEORBPHYSICALSLOW = LIFEORBPHYSICAL.clone([252,252,6,0,0,0],  ["ADAMANT", "BRAVE"], "Slow Physical Life Orb")
	LIFEORBPHYSICALSLOW.maximum_speed = 70
	LIFEORBPHYSICALSLOW.minimum_speed = 0
	LIFEORBPHYSICALSLOW.main_stats = [SCStatPatterns.ATK, SCStatPatterns.HP_ATK]
	ALL.append(LIFEORBPHYSICALSLOW)
	
	LIFEORBSPECIAL = SCPattern(
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.SPECIAL, 
		"S+SO+SP+SC",
		"S+V+FS",
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA_SPE])
	LIFEORBSPECIAL.ev = [6,0,0,252,252,0]
	LIFEORBSPECIAL.nature = ["TIMID", "MODEST"]
	LIFEORBSPECIAL.items = ["LIFEORB"]
	LIFEORBSPECIAL.isSnotP()
	LIFEORBSPECIAL.name = "Special Life Orb"
	ALL.append(LIFEORBSPECIAL)
	
	LIFEORBSPECIALSLOW = LIFEORBSPECIAL.clone([252,0,6,0,252,0],  ["MODEST", "QUIET"], "Slow Special Life Orb")
	LIFEORBSPECIALSLOW.maximum_speed = 70
	LIFEORBSPECIALSLOW.minimum_speed = 0
	LIFEORBSPECIALSLOW.main_stats = [SCStatPatterns.SPA, SCStatPatterns.HP_SPA]
	ALL.append(LIFEORBSPECIALSLOW)
	
	
	#-----------------------------------
	# Life Orb mixed 
	#-----------------------------------
	LIFEORBMIXED = SCPattern(
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"P+S+FSNH",
		[SCStatPatterns.ATK_SPA, SCStatPatterns.ATK_SPA_SPE])
	LIFEORBMIXED.ev = [0,96,0,252,160,0]
	LIFEORBMIXED.nature = ["NAIVE", "HASTY"]
	LIFEORBMIXED.items = ["LIFEORB"]
	LIFEORBMIXED.isSandP()
	LIFEORBMIXED.minimum_speed = 70
	LIFEORBMIXED.setRole(SCPattern.OFFENSIVE, SCPattern.MIXED)
	LIFEORBMIXED.name = "Mixed 1"
	ALL.append(LIFEORBMIXED)
	
	LIFEORBMIXEDSLOW = LIFEORBMIXED.clone([252,96,0,0,160,0],  ["QUIET"], "Slow Mixed 1")
	LIFEORBMIXEDSLOW.maximum_speed = 70
	LIFEORBMIXEDSLOW.minimum_speed = 0
	LIFEORBMIXEDSLOW.main_stats = [SCStatPatterns.ATK_SPA, SCStatPatterns.HP_ATK_SPA]
	ALL.append(LIFEORBMIXEDSLOW)
	
	LIFEORBMIXED2 = SCPattern(
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.PHYSICAL,
		"P+S+FSNH",
		[SCStatPatterns.ATK_SPA, SCStatPatterns.ATK_SPA_SPE])
	LIFEORBMIXED2.ev = [0,160,0,252,96,0]
	LIFEORBMIXED2.nature = ["NAIVE", "HASTY"]
	LIFEORBMIXED2.items = ["LIFEORB"]
	LIFEORBMIXED2.isSandP()
	LIFEORBMIXED2.minimum_speed = 70
	LIFEORBMIXED2.setRole(SCPattern.OFFENSIVE, SCPattern.MIXED)
	LIFEORBMIXED2.name = "Mixed 2"
	ALL.append(LIFEORBMIXED2)
	
	LIFEORBMIXEDSLOW2 = LIFEORBMIXED2.clone([252,160,0,0,96,0],  ["BRAVE"], "Slow Mixed 2")
	LIFEORBMIXEDSLOW2.maximum_speed = 70
	LIFEORBMIXEDSLOW2.minimum_speed = 0
	LIFEORBMIXEDSLOW2.main_stats = [SCStatPatterns.ATK_SPA, SCStatPatterns.HP_ATK_SPA]
	ALL.append(LIFEORBMIXEDSLOW2)
	
	
	
	#-----------------------------------
	# Mixed choice scarf 
	#-----------------------------------
	CHOICEMIXED = LIFEORBMIXED.clone([252,96,0,0,160,0],  ["NAIVE", "HASTY"], "Mixed Scarf 1")
	CHOICEMIXED.move_specs[3] = "P+S+V"
	CHOICEMIXED.items = ["CHOICESCARF"]
	CHOICEMIXED.allow_balloon_boots = False
	ALL.append(CHOICEMIXED)
	
	CHOICEMIXED2 = LIFEORBMIXED2.clone([0,160,0,252,96,0],  ["NAIVE", "HASTY"], "Mixed Scarf 2")
	CHOICEMIXED2.move_specs[3] = "P+S+V"
	CHOICEMIXED2.items = ["CHOICESCARF"]
	CHOICEMIXED2.allow_balloon_boots = False
	ALL.append(CHOICEMIXED2)
	
	
	#-----------------------------------
	# Shell Smash
	#-----------------------------------
	SETUPSHELLSMASHPHYSICAL2 = SCPattern(
		"SHELLSMASH",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO+PC", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK])
	SETUPSHELLSMASHPHYSICAL2.ev = [6,252,0,252,0,0]
	SETUPSHELLSMASHPHYSICAL2.nature = ["JOLLY", "ADAMANT"]
	SETUPSHELLSMASHPHYSICAL2.items = ["WHITEHERB"]
	SETUPSHELLSMASHPHYSICAL2.isPnotS()
	SETUPSHELLSMASHPHYSICAL2.name = "Physical Shell Smash"
	ALL.append(SETUPSHELLSMASHPHYSICAL2)
	
	SETUPSHELLSMASHSPECIAL = SCPattern(
		"SHELLSMASH",
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SO+SC", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA])
	SETUPSHELLSMASHSPECIAL.ev = [6,0,0,252,252,0]
	SETUPSHELLSMASHSPECIAL.nature = ["JOLLY", "ADAMANT"]
	SETUPSHELLSMASHSPECIAL.items = ["WHITEHERB"]
	SETUPSHELLSMASHSPECIAL.isSnotP()
	SETUPSHELLSMASHSPECIAL.name = "Special Shell Smash"
	ALL.append(SETUPSHELLSMASHSPECIAL)
	
	
	#-----------------------------------
	# Clangorous Souls
	#-----------------------------------
	CLANGOROUSSOUL = SCPattern(
		"CLANGOROUSSOUL",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK, SCStatPatterns.HP_ATK_SPE])
	CLANGOROUSSOUL.ev = [6,252,0,252,0,0]
	CLANGOROUSSOUL.nature = ["JOLLY", "ADAMANT"]
	CLANGOROUSSOUL.items = ["THROATSPRAY"]
	CLANGOROUSSOUL.disallowAllItems()
	CLANGOROUSSOUL.isPnotS()
	CLANGOROUSSOUL.name = "Physical Clangorous"
	ALL.append(CLANGOROUSSOUL)
	
	
	CLANGOROUSSOUL1 = SCPattern(
		"CLANGOROUSSOUL",
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SO", 
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA, SCStatPatterns.HP_SPA_SPE])
	CLANGOROUSSOUL1.ev = [6,0,0,252,252,0]
	CLANGOROUSSOUL1.nature = ["TIMID", "MODEST"]
	CLANGOROUSSOUL1.items = ["THROATSPRAY"]
	CLANGOROUSSOUL1.disallowAllItems()
	CLANGOROUSSOUL1.isPnotS()
	CLANGOROUSSOUL1.name = "Special Clangorous"
	ALL.append(CLANGOROUSSOUL1)
	
	
	#-----------------------------------
	# Belly drum
	#-----------------------------------
	SETUPBELLYDRUM = SCPattern(
		"BELLYDRUM",
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SO+PC", 
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK, SCStatPatterns.HP_ATK_SPE])
	SETUPBELLYDRUM.ev = [6,252,0,252,0,0]
	SETUPBELLYDRUM.minimum_speed = 70 
	SETUPBELLYDRUM.nature = ["JOLLY", "ADAMANT"]
	SETUPBELLYDRUM.items = ["SITRUSBERRY"]
	SETUPBELLYDRUM.disallowAllItems()
	SETUPBELLYDRUM.isPnotS()
	SETUPBELLYDRUM.name = "Belly Drummer"
	ALL.append(SETUPBELLYDRUM)
	
	SETUPBELLYDRUMSLOW = SETUPBELLYDRUM.clone([252,252,0,0,0,6], ["BRAVE", "ADAMANT"], "Slow Belly Drummer")
	SETUPBELLYDRUMSLOW.maximum_speed = 70 
	SETUPBELLYDRUMSLOW.minimum_speed = 0
	SETUPBELLYDRUMSLOW.main_stats = [SCStatPatterns.HP_ATK, SCStatPatterns.ATK]
	ALL.append(SETUPBELLYDRUMSLOW)
	
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
	SETUPPHYSICALBULKY.maximum_speed = 70
	SETUPPHYSICALBULKY.allow_sc_coats = True 
	SETUPPHYSICALBULKY.allow_sc_crystals = True 
	SETUPPHYSICALBULKY.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	SETUPPHYSICALBULKY.name = "Physical Bulky Set-Up" 
	ALL.append(SETUPPHYSICALBULKY)
	
	
	#-----------------------------------
	# Setup Physical Sweeper 
	#-----------------------------------
	SETUPPHYSICALSWEEPER = SCPattern(
		["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "NORETREAT"],
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"P+PP+SU+H+ST+PC",
		[SCStatPatterns.ATK_SPE, SCStatPatterns.ATK, SCStatPatterns.HP_ATK_SPE])
	SETUPPHYSICALSWEEPER.ev = [6,252,0,252,0,0]
	SETUPPHYSICALSWEEPER.nature = ["JOLLY", "ADAMANT"]
	SETUPPHYSICALSWEEPER.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "MUSCLEBAND", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	SETUPPHYSICALSWEEPER.isPnotS()
	SETUPPHYSICALSWEEPER.minimum_speed = 70
	SETUPPHYSICALSWEEPER.allow_sc_crystals = True 
	SETUPPHYSICALSWEEPER.name = "Physical Set-Up" 
	ALL.append(SETUPPHYSICALSWEEPER)
	
	SETUPPHYSICALSWEEPER2 = SETUPPHYSICALSWEEPER.clone([252,252,0,0,0,6], ["BRAVE", "ADAMANT"], "Slow Physical Set-Up")
	SETUPPHYSICALSWEEPER2.main_stats = [SCStatPatterns.HP_ATK, SCStatPatterns.ATK]
	SETUPPHYSICALSWEEPER2.maximum_speed = 70
	SETUPPHYSICALSWEEPER2.minimum_speed = 0
	ALL.append(SETUPPHYSICALSWEEPER2)
	
	
	#-----------------------------------
	# Special bulky setup heal support
	#-----------------------------------
	SETUPSPECIALBULKY = SCPattern(
		["CALMMIND", "KINDLING", "QUIVERDANCE"], 
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
	SETUPSPECIALBULKY.name = "Special Bulky Set-Up" 
	ALL.append(SETUPSPECIALBULKY)
	
	
	#-----------------------------------
	# Special bulky setup
	#-----------------------------------
	SETUPSPECIALBULKY2 = SCPattern(
		["CALMMIND", "KINDLING"], 
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
	SETUPSPECIALBULKY2.name = "Special Bulky Set-Up 2" 
	SETUPSPECIALBULKY2.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(SETUPSPECIALBULKY2)
	
	
	#-----------------------------------
	# Special bulky + physical setup
	#-----------------------------------
	SETUPSPECIALBULKY3 = SCPattern(
		["CALMMIND", "KINDLING", "QUIVERDANCE"], 
		"IRONDEFENSE",
		SCUsefulMoves.SPECIAL, 
		"FS+S+SP", 
		[SCStatPatterns.DEF_SPD, SCStatPatterns.HP_SPD])
	SETUPSPECIALBULKY3.ev = [[252,0,6,0,252,0], [252,0,6,0,252,0], [252,0,252,0,6,0]]
	SETUPSPECIALBULKY3.nature = ["MODEST", "BOLD"]
	SETUPSPECIALBULKY3.items = ["LEFTOVERS", "SHELLBELL", "EVIOLITE"]
	SETUPSPECIALBULKY3.isSnotP()
	SETUPSPECIALBULKY3.allow_sc_coats = True 
	SETUPSPECIALBULKY3.allow_sc_crystals = True 
	SETUPSPECIALBULKY3.setRole(SCPattern.DEFENSIVE, SCPattern.PHYSICAL)
	SETUPSPECIALBULKY3.name = "Special Bulky Set-Up 3" 
	ALL.append(SETUPSPECIALBULKY3)
	
	
	#-----------------------------------
	# Setup Special Sweeper 
	#-----------------------------------
	SETUPSPECIALSWEEPER = SCPattern(
		["QUIVERDANCE", "CALMMIND", "KINDLING", "TAILGLOW", "NASTYPLOT"],
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SU+H+ST+HZ+SC",
		[SCStatPatterns.SPA_SPE, SCStatPatterns.SPA, SCStatPatterns.HP_SPA_SPE])
	SETUPSPECIALSWEEPER.ev = [6,0,0,252,252,0]
	SETUPSPECIALSWEEPER.nature = ["TIMID", "MODEST"]
	SETUPSPECIALSWEEPER.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	SETUPSPECIALSWEEPER.isSnotP()
	SETUPSPECIALSWEEPER.minimum_speed = 70
	SETUPSPECIALSWEEPER.allow_sc_crystals = True 
	SETUPSPECIALSWEEPER.name = "Special Set-Up" 
	ALL.append(SETUPSPECIALSWEEPER)
	
	SETUPSPECIALSWEEPER2 = SCPattern(
		["CALMMIND", "KINDLING", "TAILGLOW", "NASTYPLOT"],
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"S+SP+SU+H+ST+HZ+SC",
		[SCStatPatterns.HP_SPA, SCStatPatterns.SPA])
	SETUPSPECIALSWEEPER2.ev = [252,0,6,0,252,0]
	SETUPSPECIALSWEEPER2.nature = ["QUIET", "MODEST"]
	SETUPSPECIALSWEEPER2.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	SETUPSPECIALSWEEPER2.isSnotP()
	SETUPSPECIALSWEEPER2.maximum_speed = 70
	SETUPSPECIALSWEEPER2.allow_sc_crystals = True 
	SETUPSPECIALSWEEPER2.name = "Slow Special Set-Up" 
	ALL.append(SETUPSPECIALSWEEPER2)
	
	
	#-----------------------------------
	# Z-Moves 
	#-----------------------------------
	ZFOURATTACKSPHY = CHOICEPHYSICAL.clone(None, None, "Z-Move Fast Phys. Off.")
	ZFOURATTACKSPHY.items = ["GENERICZCRYSTAL"]
	ZFOURATTACKSPHY.disallowAllItems()
	ALL.append(ZFOURATTACKSPHY)
	
	ZFOURATTACKSPHYSLOW = CHOICEPHYSICALSLOW.clone(None, None, "Z-Move Slow Phys. Off.")
	ZFOURATTACKSPHYSLOW.items = ["GENERICZCRYSTAL"]
	ZFOURATTACKSPHYSLOW.disallowAllItems()
	ALL.append(ZFOURATTACKSPHYSLOW)
	
	ZFOURATTACKSSPE = CHOICESPECIAL.clone(None, None, "Z-Move Fast Spe. Off.")
	ZFOURATTACKSSPE.items = ["GENERICZCRYSTAL"]
	ZFOURATTACKSSPE.disallowAllItems()
	ALL.append(ZFOURATTACKSSPE)
	
	ZFOURATTACKSSPESLOW = CHOICESPECIALSLOW.clone(None, None, "Z-Move Slow Spe. Off.")
	ZFOURATTACKSSPESLOW.items = ["GENERICZCRYSTAL"]
	ZFOURATTACKSSPESLOW.disallowAllItems()
	ALL.append(ZFOURATTACKSSPESLOW)
	
	ZBELLYDRUM = SETUPBELLYDRUM.clone(None, None, "Z-Belly Drum")
	ZBELLYDRUM.items = ["NORMALIUMZ"]
	ZBELLYDRUM.disallowAllItems() 
	ALL.append(ZBELLYDRUM)
	
	ZBELLYDRUMSLOW = SETUPBELLYDRUMSLOW.clone(None, None, "Slow Z-Belly Drum")
	ZBELLYDRUMSLOW.items = ["NORMALIUMZ"]
	ZBELLYDRUMSLOW.disallowAllItems()
	ALL.append(ZBELLYDRUMSLOW)
	
	#-----------------------------------
	# Z-Celebrate equivalents:
	#-----------------------------------
	# Physical 
	ZCELEBRATEPHY = SETUPPHYSICALSWEEPER.clone(None, None, "Physical Z-All-Stats-Up")
	ZCELEBRATEPHY.move_specs[0] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATEPHY.items = ["NORMALIUMZ"]
	ZCELEBRATEPHY.disallowAllItems()
	ALL.append(ZCELEBRATEPHY)
	
	ZCELEBRATEPHYSLOW = SETUPPHYSICALSWEEPER2.clone(None, None, "Slow Physical Z-All-Stats-Up")
	ZCELEBRATEPHYSLOW.move_specs[0] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATEPHYSLOW.items = ["NORMALIUMZ"]
	ZCELEBRATEPHYSLOW.disallowAllItems()
	ALL.append(ZCELEBRATEPHYSLOW)
	
	ZCELEBRATEPHY2 = SETUPPHYSICALSWEEPER.clone(None, None, "Z-Forest Curse 1")
	ZCELEBRATEPHY2.move_specs[0] = ["FORESTSCURSE"]
	ZCELEBRATEPHY2.items = ["GRASSIUMZ"]
	ZCELEBRATEPHY2.disallowAllItems()
	ALL.append(ZCELEBRATEPHY2)
	
	ZCELEBRATEPHYSLOW2 = SETUPPHYSICALSWEEPER2.clone(None, None, "Slow Z-Forest Curse 1")
	ZCELEBRATEPHYSLOW2.move_specs[0] = ["FORESTSCURSE"]
	ZCELEBRATEPHYSLOW2.items = ["GRASSIUMZ"]
	ZCELEBRATEPHYSLOW2.disallowAllItems()
	ALL.append(ZCELEBRATEPHYSLOW2)
	
	ZCELEBRATEPHY3 = SETUPPHYSICALSWEEPER.clone(None, None, "Z-Trick-Or-Treat 1")
	ZCELEBRATEPHY3.move_specs[0] = ["TRICKORTREAT"]
	ZCELEBRATEPHY3.items = ["GHOSTIUMZ"]
	ZCELEBRATEPHY3.disallowAllItems()
	ALL.append(ZCELEBRATEPHY3)
	
	ZCELEBRATEPHYSLOW3 = SETUPPHYSICALSWEEPER2.clone(None, None, "Slow Z-Trick-Or-Treat 1")
	ZCELEBRATEPHYSLOW3.move_specs[0] = ["TRICKORTREAT"]
	ZCELEBRATEPHYSLOW3.items = ["GHOSTIUMZ"]
	ZCELEBRATEPHYSLOW3.disallowAllItems()
	ALL.append(ZCELEBRATEPHYSLOW3)
	
	# Special: 
	ZCELEBRATESPE = SETUPSPECIALSWEEPER.clone(None, None, "Special Z-All-Stats-Up")
	ZCELEBRATESPE.move_specs[0] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATESPE.items = ["NORMALIUMZ"]
	ZCELEBRATESPE.disallowAllItems()
	ALL.append(ZCELEBRATESPE)
	
	ZCELEBRATESPESLOW = SETUPSPECIALSWEEPER2.clone(None, None, "Slow Special Z-All-Stats-Up")
	ZCELEBRATESPESLOW.move_specs[0] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATESPESLOW.items = ["NORMALIUMZ"]
	ZCELEBRATESPESLOW.disallowAllItems()
	ALL.append(ZCELEBRATESPESLOW)
	
	ZCELEBRATESPE2 = SETUPSPECIALSWEEPER.clone(None, None, "Z-Forest Curse 2")
	ZCELEBRATESPE2.move_specs[0] = ["FORESTSCURSE"]
	ZCELEBRATESPE2.items = ["GRASSIUMZ"]
	ZCELEBRATESPE2.disallowAllItems()
	ALL.append(ZCELEBRATESPE2)
	
	ZCELEBRATESPESLOW2 = SETUPSPECIALSWEEPER2.clone(None, None, "Slow Z-Forest Curse 2")
	ZCELEBRATESPESLOW2.move_specs[0] = ["FORESTSCURSE"]
	ZCELEBRATESPESLOW2.items = ["GRASSIUMZ"]
	ZCELEBRATESPESLOW2.disallowAllItems()
	ALL.append(ZCELEBRATESPESLOW2)
	
	ZCELEBRATESPE3 = SETUPSPECIALSWEEPER.clone(None, None, "Z-Trick-Or-Treat 2")
	ZCELEBRATESPE3.move_specs[0] = ["TRICKORTREAT"]
	ZCELEBRATESPE3.items = ["GHOSTIUMZ"]
	ZCELEBRATESPE3.disallowAllItems()
	ALL.append(ZCELEBRATESPE3)
	
	ZCELEBRATESPESLOW3 = SETUPSPECIALSWEEPER2.clone(None, None, "Slow Z-Trick-Or-Treat 2")
	ZCELEBRATESPESLOW3.move_specs[0] = ["TRICKORTREAT"]
	ZCELEBRATESPESLOW3.items = ["GHOSTIUMZ"]
	ZCELEBRATESPESLOW3.disallowAllItems()
	ALL.append(ZCELEBRATESPESLOW3)
	
	# Mixed: 
	ZCELEBRATEMIXED = LIFEORBMIXED.clone(None, None, "Mixed Z-All-Stats-Up 1")
	ZCELEBRATEMIXED.move_specs[3] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATEMIXED.items = ["NORMALIUMZ"]
	ZCELEBRATEMIXED.disallowAllItems()
	ALL.append(ZCELEBRATEMIXED)
	
	ZCELEBRATEMIXEDSLOW = LIFEORBMIXEDSLOW.clone(None, None, "Slow Mixed Z-All-Stats-Up 1")
	ZCELEBRATEMIXEDSLOW.move_specs[3] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATEMIXEDSLOW.items = ["NORMALIUMZ"]
	ZCELEBRATEMIXEDSLOW.disallowAllItems()
	ALL.append(ZCELEBRATEMIXEDSLOW)
	
	ZCELEBRATEMIXED2 = LIFEORBMIXED2.clone(None, None, "Mixed Z-All-Stats-Up 2")
	ZCELEBRATEMIXED2.move_specs[3] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATEMIXED2.items = ["NORMALIUMZ"]
	ZCELEBRATEMIXED2.disallowAllItems()
	ALL.append(ZCELEBRATEMIXED2)
	
	ZCELEBRATESPESLOW2 = LIFEORBMIXEDSLOW2.clone(None, None, "Slow Mixed Z-All-Stats-Up")
	ZCELEBRATESPESLOW2.move_specs[3] = ["CELEBRATE","CONVERSION","HAPPYHOUR","HOLDHANDS"]
	ZCELEBRATESPESLOW2.items = ["NORMALIUMZ"]
	ZCELEBRATESPESLOW2.disallowAllItems()
	ALL.append(ZCELEBRATESPESLOW2)
	
	# Z-Spinda
	ZSPINDAPHY = ZCELEBRATEPHYSLOW.clone(None, None, "Physical Z-Spinda")
	ZSPINDAPHY.move_specs[0] = ["TEETERDANCE"]
	ZSPINDAPHY.items = ["SPINDIUMZ"]
	ZSPINDAPHY.for_pokemons = ["SPINDA"]
	ZSPINDAPHY.disallowAllItems()
	ALL.append(ZSPINDAPHY)
	
	ZSPINDASPE = ZCELEBRATESPESLOW.clone(None, None, "Special Z-Spinda")
	ZSPINDASPE.move_specs[0] = ["TEETERDANCE"]
	ZSPINDASPE.items = ["SPINDIUMZ"]
	ZSPINDASPE.for_pokemons = ["SPINDA"]
	ZSPINDASPE.disallowAllItems()
	ALL.append(ZSPINDASPE)
	
	ZSPINDAMIXED = ZCELEBRATEMIXEDSLOW.clone(None, None, "Mixed Z-Spinda")
	ZSPINDAMIXED.move_specs[0] = ["TEETERDANCE"]
	ZSPINDAMIXED.items = ["SPINDIUMZ"]
	ZSPINDAMIXED.for_pokemons = ["SPINDA"]
	ZSPINDAMIXED.disallowAllItems()
	ALL.append(ZSPINDAMIXED)
	
	# Z-Ancient Power, for fossils only 
	fossil_list = ["OMANYTE", "OMASTAR", "AERODACTYL", "AERODACTYL_2", "LILEEP", "CRADILY", "ANORITH", "ARMALDO", "RELICANTH", "CRANIDOS", "RAMPARDOS", "RAMPARDOS_1", "SHIELDON", "BASTIODON", "TIRTOUGA", "CARRACOSTA", "ARCHEN", "ARCHEOPS", "ARCHEN_1", "ARCHEOPS_1", "TYRUNT", "TYRANTRUM", "AMAURA", "AURORUS", "DRACOZOLT", "DRACOVISH", "ARCTOZOLT", "ARCTOVISH"]
	
	ZANCIENTPOWERPHY = ZCELEBRATEPHY.clone(None, None, "Physical Z-Ancient Power")
	ZANCIENTPOWERPHY.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERPHY.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERPHY.for_pokemons = fossil_list
	ZANCIENTPOWERPHY.forced_move_probably_stab = 0
	ZANCIENTPOWERPHY.disallowAllItems()
	ALL.append(ZANCIENTPOWERPHY)
	
	ZPALEODRAINPHY = ZCELEBRATEPHY.clone(None, None, "Z-Paleo Drain")
	ZPALEODRAINPHY.move_specs[0] = SCUsefulMoves.oneTypeHash("ROCK", "PALEODRAIN")
	ZPALEODRAINPHY.items = ["FOSSILIUMZ"]
	ZPALEODRAINPHY.for_pokemons = ["KABUTO", "KABUTOPS"]
	ZPALEODRAINPHY.forced_move_probably_stab = 0
	ZPALEODRAINPHY.disallowAllItems()
	ALL.append(ZPALEODRAINPHY)
	
	ZANCIENTPOWERPHYSLOW = ZCELEBRATEPHYSLOW.clone(None, None, "Slow Physical Z-Ancient Power")
	ZANCIENTPOWERPHYSLOW.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERPHYSLOW.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERPHYSLOW.for_pokemons = fossil_list
	ZANCIENTPOWERPHYSLOW.forced_move_probably_stab = 0
	ZANCIENTPOWERPHYSLOW.disallowAllItems()
	ALL.append(ZANCIENTPOWERPHYSLOW)
	
	ZANCIENTPOWERSPE = ZCELEBRATESPE.clone(None, None, "Special Z-Ancient Power")
	ZANCIENTPOWERSPE.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERSPE.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERSPE.for_pokemons = fossil_list
	ZANCIENTPOWERSPE.forced_move_probably_stab = 0
	ZANCIENTPOWERSPE.disallowAllItems()
	ALL.append(ZANCIENTPOWERSPE)
	
	ZANCIENTPOWERSPESLOW = ZCELEBRATESPESLOW.clone(None, None, "Slow Special Z-Ancient Power")
	ZANCIENTPOWERSPESLOW.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERSPESLOW.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERSPESLOW.for_pokemons = fossil_list
	ZANCIENTPOWERSPESLOW.forced_move_probably_stab = 0
	ZANCIENTPOWERSPESLOW.disallowAllItems()
	ALL.append(ZANCIENTPOWERSPESLOW)
	
	ZANCIENTPOWERMIXED = ZCELEBRATEMIXED.clone(None, None, "Mixed Z-Ancient Power")
	ZANCIENTPOWERMIXED.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERMIXED.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERMIXED.for_pokemons = fossil_list
	ZANCIENTPOWERMIXED.forced_move_probably_stab = 0
	ZANCIENTPOWERMIXED.disallowAllItems()
	ALL.append(ZANCIENTPOWERMIXED)
	
	ZANCIENTPOWERMIXEDSLOW = ZCELEBRATEMIXEDSLOW.clone(None, None, "Slow Mixed Z-Ancient Power")
	ZANCIENTPOWERMIXEDSLOW.move_specs[0] = "ANCIENTPOWER"
	ZANCIENTPOWERMIXEDSLOW.items = ["FOSSILIUMZ"]
	ZANCIENTPOWERMIXEDSLOW.for_pokemons = fossil_list
	ZANCIENTPOWERMIXEDSLOW.forced_move_probably_stab = 0
	ZANCIENTPOWERMIXEDSLOW.disallowAllItems()
	ALL.append(ZANCIENTPOWERMIXEDSLOW)
	
	
	# Assistance (Skitty/Delcatty)
	ASSISTANCESUPPORT = SCPattern(
		"ASSISTANCE",
		SCUsefulMoves.PHYSICAL, 
		"P+PP+FS", 
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.SPE])
	ASSISTANCESUPPORT.ev = [252,0,6,0,252,0]
	ASSISTANCESUPPORT.nature = ["QUIET", "MODEST"]
	ASSISTANCESUPPORT.items = ["LEFTOVERS", "SHELLBELL", "LIFEORB", "EXPERTBELT", "WISEGLASSES", "SCNORMALMAXER", "GENERICZCRYSTAL"]
	ASSISTANCESUPPORT.isPnotS()
	ASSISTANCESUPPORT.allow_sc_crystals = True 
	ASSISTANCESUPPORT.name = "Assistance Support" 
	ALL.append(ASSISTANCESUPPORT)



class SCPatternsForStrategy:
	# Distorsion, weather, Carboniferous.
	
	ALL = [] 
	
	
	
	# --------------------------
	# Distorsion
	# --------------------------
	TRICKROOMLEADDEFSPE = SCPattern(
		"TRICKROOM", 
		SCUsefulMoves.VOLTTURN + ["TELEPORT", "HEALINGWISH", "LUNARDANCE"],
		SCUsefulMoves.SPECIAL,
		"HZ+C",
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.HP_SPD])
	TRICKROOMLEADDEFSPE.ev = [252,0,0,0,6,252]
	TRICKROOMLEADDEFSPE.nature = ["SASSY"]
	TRICKROOMLEADDEFSPE.items = ["LEFTOVERS"]
	TRICKROOMLEADDEFSPE.maximum_speed = 70 
	TRICKROOMLEADDEFSPE.isSnotP()
	TRICKROOMLEADDEFSPE.name = "Trick Room Lead Def 1"
	TRICKROOMLEADDEFSPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	TRICKROOMLEADDEFSPE.is_specific = True
	ALL.append(TRICKROOMLEADDEFSPE)
	
	TRICKROOMLEADDEFSPE2 = TRICKROOMLEADDEFSPE.clone([252,0,252,0,6,0], ["RELAXED"], "Trick Room Lead Def 2")
	ALL.append(TRICKROOMLEADDEFSPE2)
	
	TRICKROOMLEADDEFPHY = SCPattern(
		"TRICKROOM", 
		SCUsefulMoves.VOLTTURN + ["TELEPORT", "HEALINGWISH", "LUNARDANCE"],
		SCUsefulMoves.PHYSICAL,
		"HZ+C",
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.HP_SPD])
	TRICKROOMLEADDEFPHY.ev = [252,6,0,0,0,252]
	TRICKROOMLEADDEFPHY.nature = ["SASSY"]
	TRICKROOMLEADDEFPHY.items = ["LEFTOVERS"]
	TRICKROOMLEADDEFPHY.maximum_speed = 70 
	TRICKROOMLEADDEFPHY.isPnotS()
	TRICKROOMLEADDEFPHY.name = "Trick Room Lead Def 3"
	TRICKROOMLEADDEFPHY.is_specific = True
	TRICKROOMLEADDEFPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	ALL.append(TRICKROOMLEADDEFPHY)
	
	TRICKROOMLEADDEFPHY2 = TRICKROOMLEADDEFPHY.clone([252,6,252,0,0,0], ["RELAXED"], "Trick Room Lead Def 4")
	ALL.append(TRICKROOMLEADDEFPHY2)
	
	# Offensive leads.
	TRICKROOMLEADOFFSPE = TRICKROOMLEADDEFSPE.clone([252,0,0,0,252,6], ["QUIET"], "Trick Room Lead Off Spe")
	TRICKROOMLEADOFFSPE.move_specs[1] = SCUsefulMoves.VOLTTURN + ["TELEPORT", "HEALINGWISH", "LUNARDANCE"] + SCUsefulMoves.HAZARDS + SCUsefulMoves.CHEERS
	TRICKROOMLEADOFFSPE.move_specs[3] = "S+SP"
	TRICKROOMLEADOFFSPE.main_stats = [SCStatPatterns.HP_SPA, SCStatPatterns.HP]
	ALL.append(TRICKROOMLEADOFFSPE)
	
	TRICKROOMLEADOFFPHY = TRICKROOMLEADDEFPHY.clone([252,252,0,0,0,6], ["BRAVE"], "Trick Room Lead Off Phy")
	TRICKROOMLEADOFFPHY.move_specs[1] = SCUsefulMoves.VOLTTURN + ["TELEPORT", "HEALINGWISH", "LUNARDANCE"] + SCUsefulMoves.HAZARDS + SCUsefulMoves.CHEERS
	TRICKROOMLEADOFFPHY.move_specs[3] = "P+PP"
	TRICKROOMLEADOFFPHY.main_stats = [SCStatPatterns.HP_ATK, SCStatPatterns.HP]
	ALL.append(TRICKROOMLEADOFFPHY)
	
	# Tanks
	TRICKROOMTANKSPE = TRICKROOMLEADDEFSPE.clone([252,0,0,0,252,6], ["QUIET"], "Trick Room Tank Spe")
	TRICKROOMTANKSPE.move_specs[1] = SCUsefulMoves.SPECIAL
	TRICKROOMTANKSPE.move_specs[3] = "S+SP"
	TRICKROOMTANKSPE.main_stats = [SCStatPatterns.HP_SPA, SCStatPatterns.SPA]
	TRICKROOMTANKSPE.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(TRICKROOMTANKSPE)
	
	TRICKROOMTANKPHY = TRICKROOMLEADDEFPHY.clone([252,252,0,0,0,6], ["BRAVE"], "Trick Room Tank Phy")
	TRICKROOMTANKPHY.move_specs[1] = SCUsefulMoves.PHYSICAL
	TRICKROOMTANKPHY.move_specs[3] = "P+PP"
	TRICKROOMTANKPHY.main_stats = [SCStatPatterns.HP_ATK, SCStatPatterns.ATK]
	TRICKROOMTANKPHY.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	ALL.append(TRICKROOMTANKPHY)
	
	TRICKROOMSETUPSPE = TRICKROOMTANKSPE.clone([252,0,0,0,252,6], ["QUIET"], "Trick Room Setup Spe")
	TRICKROOMSETUPSPE.move_specs[3] = ["QUIVERDANCE", "CALMMIND", "KINDLING", "TAILGLOW", "NASTYPLOT"]
	ALL.append(TRICKROOMSETUPSPE)
	
	TRICKROOMSETUPPHY = TRICKROOMTANKPHY.clone([252,252,0,0,0,6], ["BRAVE"], "Trick Room Setup Phy")
	TRICKROOMSETUPPHY.move_specs[3] = ["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "NORETREAT"]
	ALL.append(TRICKROOMSETUPPHY)
	
	
	# Support
	TRICKROOMSUPPORT1 = TRICKROOMLEADDEFSPE.clone(None, None, "Trick Room Support 1")
	TRICKROOMSUPPORT1.move_specs[3] = SCUsefulMoves.FULLSUPPORT
	TRICKROOMSUPPORT1.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(TRICKROOMSUPPORT1)
	
	TRICKROOMSUPPORT2 = TRICKROOMLEADDEFSPE.clone([252,0,252,0,6,0], ["RELAXED"], "Trick Room Support 2")
	TRICKROOMSUPPORT2.move_specs[3] = SCUsefulMoves.FULLSUPPORT
	TRICKROOMSUPPORT2.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	ALL.append(TRICKROOMSUPPORT2)
	
	TRICKROOMSUPPORT3 = TRICKROOMLEADDEFPHY.clone(None, None, "Trick Room Support 3")
	TRICKROOMSUPPORT3.move_specs[3] = SCUsefulMoves.FULLSUPPORT
	TRICKROOMSUPPORT3.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(TRICKROOMSUPPORT3)
	
	TRICKROOMSUPPORT4 = TRICKROOMLEADDEFPHY.clone([252,6,252,0,0,0], ["RELAXED"], "Trick Room Support 4")
	TRICKROOMSUPPORT4.move_specs[3] = SCUsefulMoves.FULLSUPPORT
	TRICKROOMSUPPORT4.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	ALL.append(TRICKROOMSUPPORT4)
	
	
	ALL_CARBONIFEROUS = [] # For duplication to other setters (e.g. Magnetic Terrain)
	
	# --------------------------
	# Carboniferous
	# --------------------------
	# Moves 
	# Vérifier les stats requises.
	CARBONIFEROUSLEADDEFSPE = SCPattern(
		"CARBONIFEROUS", 
		"HZ+C",
		SCUsefulMoves.SPECIAL,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.HP_SPD])
	CARBONIFEROUSLEADDEFSPE.ev = [252,0,0,0,6,252]
	CARBONIFEROUSLEADDEFSPE.nature = ["CALM"]
	CARBONIFEROUSLEADDEFSPE.items = ["LEFTOVERS"]
	CARBONIFEROUSLEADDEFSPE.isSnotP()
	CARBONIFEROUSLEADDEFSPE.name = "Carboniferous Lead Def 1"
	CARBONIFEROUSLEADDEFSPE.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	CARBONIFEROUSLEADDEFSPE.is_specific = True
	ALL.append(CARBONIFEROUSLEADDEFSPE)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADDEFSPE)
	
	CARBONIFEROUSLEADDEFSPE2 = CARBONIFEROUSLEADDEFSPE.clone([252,0,252,0,6,0], ["BOLD"], "Carboniferous Lead Def 2")
	ALL.append(CARBONIFEROUSLEADDEFSPE2)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADDEFSPE2)
	
	CARBONIFEROUSLEADDEFPHY = SCPattern(
		"CARBONIFEROUS", 
		"HZ+C",
		SCUsefulMoves.PHYSICAL,
		SCUsefulMoves.FULLSUPPORT,
		[SCStatPatterns.HP, SCStatPatterns.HP_DEF, SCStatPatterns.HP_SPD])
	CARBONIFEROUSLEADDEFPHY.ev = [252,6,0,0,0,252]
	CARBONIFEROUSLEADDEFPHY.nature = ["CAREFUL"]
	CARBONIFEROUSLEADDEFPHY.items = ["LEFTOVERS"]
	CARBONIFEROUSLEADDEFPHY.isPnotS()
	CARBONIFEROUSLEADDEFPHY.name = "Carboniferous Lead Def 3"
	CARBONIFEROUSLEADDEFPHY.is_specific = True
	CARBONIFEROUSLEADDEFPHY.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	ALL.append(CARBONIFEROUSLEADDEFPHY)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADDEFPHY)
	
	CARBONIFEROUSLEADDEFPHY2 = CARBONIFEROUSLEADDEFPHY.clone([252,6,252,0,0,0], ["IMPISH"], "Carboniferous Lead Def 4")
	ALL.append(CARBONIFEROUSLEADDEFPHY2)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADDEFPHY2)
	
	# Offensive leads.
	CARBONIFEROUSLEADOFFSPE = CARBONIFEROUSLEADDEFSPE.clone([6,0,0,252,252,0], ["TIMID"], "Carboniferous Lead Off Spe")
	CARBONIFEROUSLEADOFFSPE.move_specs[1] = "FS+V"
	CARBONIFEROUSLEADOFFSPE.move_specs[3] = "S+SP"
	CARBONIFEROUSLEADOFFSPE.minimum_speed = 70
	CARBONIFEROUSLEADOFFSPE.main_stats = [SCStatPatterns.SPA_SPE, SCStatPatterns.SPE]
	ALL.append(CARBONIFEROUSLEADOFFSPE)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADOFFSPE)
	
	CARBONIFEROUSLEADOFFSPESLOW = CARBONIFEROUSLEADOFFSPE.clone([252,0,0,0,252,6], ["MODEST"], "Slow Carboniferous Lead Off Spe")
	CARBONIFEROUSLEADOFFSPESLOW.minimum_speed = 0
	CARBONIFEROUSLEADOFFSPESLOW.maximum_speed = 70
	CARBONIFEROUSLEADOFFSPESLOW.main_stats = [SCStatPatterns.HP_SPA, SCStatPatterns.HP]
	ALL.append(CARBONIFEROUSLEADOFFSPESLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADOFFSPESLOW)
	
	CARBONIFEROUSLEADOFFPHY = CARBONIFEROUSLEADDEFPHY.clone([6,252,0,252,0,0], ["JOLLY"], "Carboniferous Lead Off Phy")
	CARBONIFEROUSLEADOFFPHY.move_specs[1] = "FS+V"
	CARBONIFEROUSLEADOFFPHY.move_specs[3] = "P+PP"
	CARBONIFEROUSLEADOFFPHY.main_stats = [SCStatPatterns.ATK_SPE, SCStatPatterns.SPE]
	ALL.append(CARBONIFEROUSLEADOFFPHY)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADOFFPHY)
	
	CARBONIFEROUSLEADOFFPHYSLOW = CARBONIFEROUSLEADOFFPHY.clone([252,252,0,0,0,6], ["ADAMANT"], "Slow Carboniferous Lead Off Phy")
	CARBONIFEROUSLEADOFFPHYSLOW.minimum_speed = 0
	CARBONIFEROUSLEADOFFPHYSLOW.maximum_speed = 70
	CARBONIFEROUSLEADOFFPHYSLOW.main_stats = [SCStatPatterns.HP_ATK, SCStatPatterns.HP]
	ALL.append(CARBONIFEROUSLEADOFFPHYSLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSLEADOFFPHYSLOW)
	
	# Offenses
	CARBONIFEROUSOFFENSIVESPE = CARBONIFEROUSLEADOFFSPE.clone(None, ["TIMID", "MODEST"], "Carboniferous Off Spe")
	CARBONIFEROUSOFFENSIVESPE.move_specs[1] = SCUsefulMoves.SPECIAL
	CARBONIFEROUSOFFENSIVESPE.move_specs[3] = "S+SP+V"
	CARBONIFEROUSOFFENSIVESPE.main_stats = [SCStatPatterns.SPA_SPE, SCStatPatterns.SPA]
	CARBONIFEROUSOFFENSIVESPE.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	ALL.append(CARBONIFEROUSOFFENSIVESPE)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSOFFENSIVESPE)
	
	CARBONIFEROUSOFFENSIVESPESLOW = CARBONIFEROUSOFFENSIVESPE.clone([252,0,0,0,252,6], ["MODEST"], "Slow Carboniferous Off Spe")
	CARBONIFEROUSOFFENSIVESPESLOW.minimum_speed = 0
	CARBONIFEROUSOFFENSIVESPESLOW.maximum_speed = 70
	CARBONIFEROUSOFFENSIVESPESLOW.main_stats = [SCStatPatterns.SPA]
	ALL.append(CARBONIFEROUSOFFENSIVESPESLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSOFFENSIVESPESLOW)

	CARBONIFEROUSOFFENSIVEPHY = CARBONIFEROUSLEADDEFPHY.clone(None, ["JOLLY", "ADAMANT"], "Carboniferous Off Phy")
	CARBONIFEROUSOFFENSIVEPHY.move_specs[1] = SCUsefulMoves.PHYSICAL
	CARBONIFEROUSOFFENSIVEPHY.move_specs[3] = "P+PP+V"
	CARBONIFEROUSOFFENSIVEPHY.main_stats = [SCStatPatterns.ATK_SPE, SCStatPatterns.ATK]
	CARBONIFEROUSOFFENSIVEPHY.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	ALL.append(CARBONIFEROUSOFFENSIVEPHY)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSOFFENSIVEPHY)
	
	CARBONIFEROUSOFFENSIVEPHYSLOW = CARBONIFEROUSOFFENSIVEPHY.clone([252,252,0,0,0,6], ["ADAMANT"], "Slow Carboniferous Off Phy")
	CARBONIFEROUSOFFENSIVEPHYSLOW.minimum_speed = 0
	CARBONIFEROUSOFFENSIVEPHYSLOW.maximum_speed = 70
	CARBONIFEROUSOFFENSIVEPHYSLOW.main_stats = [SCStatPatterns.ATK]
	ALL.append(CARBONIFEROUSOFFENSIVEPHYSLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSOFFENSIVEPHYSLOW)
	
	
	CARBONIFEROUSSETUPSPE = CARBONIFEROUSOFFENSIVESPE.clone(None, None, "Carboniferous Setup Spe")
	CARBONIFEROUSSETUPSPE.move_specs[3] = ["QUIVERDANCE", "CALMMIND", "KINDLING", "TAILGLOW", "NASTYPLOT"]
	ALL.append(CARBONIFEROUSSETUPSPE)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSETUPSPE)
	
	CARBONIFEROUSSETUPSPESLOW = CARBONIFEROUSSETUPSPE.clone([252,0,0,0,252,6], ["MODEST"], "Slow Carboniferous Setup Spe")
	CARBONIFEROUSSETUPSPESLOW.minimum_speed = 0
	CARBONIFEROUSSETUPSPESLOW.maximum_speed = 70
	CARBONIFEROUSSETUPSPESLOW.main_stats = [SCStatPatterns.SPA]
	ALL.append(CARBONIFEROUSSETUPSPESLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSETUPSPESLOW)
	
	CARBONIFEROUSSETUPPHY = CARBONIFEROUSOFFENSIVEPHY.clone(None, None, "Carboniferous Setup Phy")
	CARBONIFEROUSSETUPPHY.move_specs[3] = ["COIL", "BULKUP", "SWORDSDANCE", "FELLSTINGER", "DRAGONDANCE", "NORETREAT"]
	ALL.append(CARBONIFEROUSSETUPPHY)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSETUPPHY)
	
	CARBONIFEROUSSETUPPHYSLOW = CARBONIFEROUSSETUPPHY.clone([252,252,0,0,0,6], ["ADAMANT"], "Slow Carboniferous Setup Phy")
	CARBONIFEROUSSETUPPHYSLOW.minimum_speed = 0
	CARBONIFEROUSSETUPPHYSLOW.maximum_speed = 70
	CARBONIFEROUSSETUPPHYSLOW.main_stats = [SCStatPatterns.ATK]
	ALL.append(CARBONIFEROUSSETUPPHYSLOW)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSETUPPHYSLOW)
	
	
	# Support
	CARBONIFEROUSSUPPORT1 = CARBONIFEROUSLEADDEFSPE.clone(None, None, "Carboniferous Support 1")
	CARBONIFEROUSSUPPORT1.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(CARBONIFEROUSSUPPORT1)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSUPPORT1)
	
	CARBONIFEROUSSUPPORT2 = CARBONIFEROUSLEADDEFSPE2.clone(None, None, "Carboniferous Support 2")
	CARBONIFEROUSSUPPORT2.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	ALL.append(CARBONIFEROUSSUPPORT2)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSUPPORT2)
	
	CARBONIFEROUSSUPPORT3 = CARBONIFEROUSLEADDEFPHY.clone(None, None, "Carboniferous Support 3")
	CARBONIFEROUSSUPPORT3.setRole(SCPattern.SUPPORT, SCPattern.SPECIAL)
	ALL.append(CARBONIFEROUSSUPPORT3)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSUPPORT3)
	
	CARBONIFEROUSSUPPORT4 = CARBONIFEROUSLEADDEFPHY2.clone(None, None, "Carboniferous Support 4")
	CARBONIFEROUSSUPPORT4.setRole(SCPattern.SUPPORT, SCPattern.PHYSICAL)
	ALL.append(CARBONIFEROUSSUPPORT4)
	ALL_CARBONIFEROUS.append(CARBONIFEROUSSUPPORT4)
	
	
	# Magnetic terrain 
	for pattern in ALL_CARBONIFEROUS:
		new_p = pattern.clone(None, None, pattern.name.replace("Carboniferous", "Magnetic"))
		new_p.move_specs[0] = "MAGNETICTERRAIN"
		ALL.append(new_p)
	
	


def adapt_patterns_for_weathers():
	# return 
	sun_enjoyer_special = SCUsefulMoves.newEmptyMoveSpecHash()
	sun_enjoyer_special["FIRE"] = list(SCUsefulMoves.SPECIAL["FIRE"]) + ["WEATHERBALL"]
	sun_enjoyer_special["GRASS"] = ["SOLARBEAM"]
	
	# Special Sun enjoyers
	adapt_patterns_for_strategy(22, SCUsefulMoves.SPECIAL, sun_enjoyer_special, 
		["CHLOROPHYLL", "FLOWERGIFT", "LEAFGUARD", "SOLARPOWER"], "GROWTH", 
		["MORNINGSUN", "SYNTHESIS", "MOONLIGHT"], 2, "Sun ")
	
	# Physical Sun enjoyers
	adapt_patterns_for_strategy(21, None, None, 
		["CHLOROPHYLL", "FLOWERGIFT", "LEAFGUARD", "SOLARPOWER"], "GROWTH", 
		["MORNINGSUN", "SYNTHESIS", "MOONLIGHT"], 0, "Sun ")
	
	hail_enjoyer_special = SCUsefulMoves.newEmptyMoveSpecHash()
	hail_enjoyer_special["FLYING"] = ["HURRICANE"]
	hail_enjoyer_special["ICE"] = ["BLIZZARD"]
	
	# Special Hail enjoyers
	adapt_patterns_for_strategy(22, SCUsefulMoves.SPECIAL, hail_enjoyer_special, 
		[], None, None, 1, "Hail ")
	
	rain_enjoyer_special = SCUsefulMoves.newEmptyMoveSpecHash()
	rain_enjoyer_special["WATER"] = list(SCUsefulMoves.SPECIAL["WATER"])
	rain_enjoyer_special["FLYING"] = ["HURRICANE"]
	rain_enjoyer_special["ELECTRIC"] = ["THUNDER"]
	
	adapt_patterns_for_strategy(22, SCUsefulMoves.SPECIAL, rain_enjoyer_special, 
		["DRYSKIN", "HYDRATION", "RAINDISH", "SWIFTSWIM"], None, None, 1, "Rain ")
	
	
	
	
	
def adapt_patterns_for_strategy(for_role, move_spec_old, move_spec_new, new_abilities, new_boost, new_healing, num_changes, prefix):
	# global SCSpecificPatterns.ALL
	# global SCAllPatterns.ALL
	
	for pattern in SCAllPatterns.ALL: 
		if pattern.role != for_role:
			continue
		if len(pattern.ability) != 0:
			continue 
		
		new_pattern = pattern.clone(None, None, prefix + pattern.name)
		new_pattern.is_specific = True 
		
		cpt = 0 
		cpt_moves = 0 
		for i in range(0, 4):
			if new_boost is not None and isinstance(new_pattern.move_specs[i], list) and "NASTYPLOT" in new_pattern.move_specs[i]:
				new_pattern.move_specs[i] = [new_boost]
				cpt += 1
			elif new_healing is not None and isinstance(new_pattern.move_specs[i], list) and "RECOVER" in new_pattern.move_specs[i]:
				new_pattern.move_specs[i] = new_healing
				cpt += 1
			elif move_spec_old is not None and cpt_moves < num_changes and isinstance(new_pattern.move_specs[i], dict) and new_pattern.move_specs[i] == move_spec_old:
				new_pattern.move_specs[i] = move_spec_new
				cpt_moves += 1
				cpt += 1
		
		if cpt == 0:
			continue 
		
		new_pattern.ability = new_abilities
		
		SCPatternsForStrategy.ALL.append(new_pattern)




# =============================================================================
# Class (module) containing lame patterns, suitable for most Pokémons, and 
# reserved for Pokémons that couldn't get a moveset from SCAllPatterns. 
# This is for hopeless cases, as every Pokémon should have at least a moveset. 
# =============================================================================
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
	ASSAULTVESTPHYSICAL.name = "Physical Assault Vest 1"
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
	ASSAULTVESTPHYSICAL2.name = "Physical Assault Vest 2"
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
	ASSAULTVESTSPECIAL.name = "Special Assault Vest 1"
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
	ASSAULTVESTSPECIAL2.name = "Special Assault Vest 2"
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
	RESTDEFENSIVE.name = "Sleep Talk 1"
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
	RESTDEFENSIVE2.name = "Sleep Talk 2"
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
	RESTDEFENSIVE3.name = "Sleep Talk 3"
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
	RESTDEFENSIVE4.name = "Sleep Talk 4"
	ALL.append(RESTDEFENSIVE4)
	
	
	# Rest + Sleep talk + 2 offensive moves. 
	RESTOFFENSIVEPHY = SCPattern(
		SCUsefulMoves.PHYSICAL, 
		SCUsefulMoves.PHYSICAL, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_ATK, SCStatPatterns.ATK, SCStatPatterns.ATK_DEF, SCStatPatterns.ATK_SPD])
	RESTOFFENSIVEPHY.ev = [252,252,0,0,0,6]
	RESTOFFENSIVEPHY.nature = ["ADAMANT"]
	RESTOFFENSIVEPHY.items = ["LEFTOVERS"]
	RESTOFFENSIVEPHY.isPnotS()
	RESTOFFENSIVEPHY.setRole(SCPattern.OFFENSIVE, SCPattern.PHYSICAL)
	RESTOFFENSIVEPHY.allow_sc_coats = True 
	RESTOFFENSIVEPHY.name = "Phy Rest Offense"
	ALL.append(RESTOFFENSIVEPHY)
	
	RESTOFFENSIVESPE = SCPattern(
		SCUsefulMoves.SPECIAL, 
		SCUsefulMoves.SPECIAL, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_SPA, SCStatPatterns.SPA, SCStatPatterns.SPA_DEF, SCStatPatterns.SPA_SPD])
	RESTOFFENSIVESPE.ev = [252,0,6,0,252,0]
	RESTOFFENSIVESPE.nature = ["MODEST"]
	RESTOFFENSIVESPE.items = ["LEFTOVERS"]
	RESTOFFENSIVESPE.isSnotP()
	RESTOFFENSIVESPE.setRole(SCPattern.OFFENSIVE, SCPattern.SPECIAL)
	RESTOFFENSIVESPE.allow_sc_coats = True 
	RESTOFFENSIVESPE.name = "Spe Rest Offense"
	ALL.append(RESTOFFENSIVESPE)
	
	
	# Dual screens
	DUALSCREENS = SCPattern(
		SCUsefulMoves.SPECIAL,
		"FSNH+S",
		"LIGHTSCREEN", 
		"REFLECT",
		[SCStatPatterns.HP_SPE, SCStatPatterns.SPA_SPE, SCStatPatterns.SPE])
	DUALSCREENS.ev = [252,0,0,252,6,0]
	DUALSCREENS.nature = ["TIMID"]
	DUALSCREENS.items = ["LEFTOVERS", "LIGHTCLAY"]
	DUALSCREENS.isSnotP()
	DUALSCREENS.name = "Dual Screens (Spe)"
	DUALSCREENS.setRole(SCPattern.LEAD, SCPattern.SPECIAL)
	ALL.append(DUALSCREENS)
	
	
	DUALSCREENS2 = SCPattern(
		SCUsefulMoves.PHYSICAL,
		"FSNH+P",
		"LIGHTSCREEN", 
		"REFLECT",
		[SCStatPatterns.HP_SPE, SCStatPatterns.ATK_SPE, SCStatPatterns.SPE])
	DUALSCREENS2.ev = [252,6,0,252,0,0]
	DUALSCREENS2.nature = ["JOLLY"]
	DUALSCREENS2.items = ["LEFTOVERS", "LIGHTCLAY"]
	DUALSCREENS2.isPnotS()
	DUALSCREENS2.setRole(SCPattern.LEAD, SCPattern.PHYSICAL)
	DUALSCREENS2.name = "Dual Screens (Phy)"
	ALL.append(DUALSCREENS2)
	
	
	
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
	CHOICEPHYSICALTRICK.name = "Physical Trick Scarf"
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
	CHOICESPECIALTRICK.name = "Special Trick Scarf"
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
	CROPHYSICAL.name = "Physical Cro"
	ALL.append(CROPHYSICAL)
	
	
	# CRO (CM + Rest + Sleep Talk + 1 move)
	CROSPECIAL = SCPattern(
		["CALMMIND", "KINDLING", "QUIVERDANCE"], 
		SCUsefulMoves.SPECIAL, 
		"REST", 
		"SLEEPTALK", 
		[SCStatPatterns.HP_DEF, SCStatPatterns.DEF, SCStatPatterns.DEF_SPD])
	CROSPECIAL.ev = [252,0,252,0,6,0]
	CROSPECIAL.nature = ["BOLD"]
	CROSPECIAL.items = ["LEFTOVERS"]
	CROSPECIAL.isSnotP()
	CROSPECIAL.name = "Special Cro"
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
	SUPPORTPHYSICAL.name = "Physical Support 1"
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
	SUPPORTPHYSICAL2.name = "Physical Support 2"
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
	SUPPORTSPECIAL.name = "Special Support 1"
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
	SUPPORTSPECIAL2.name = "Special Support 2"
	ALL.append(SUPPORTSPECIAL2)
	


	
def get_specific_movesets():
	# Gets hard-coded movesets.
	specific_movesets = {}
	pokemon = ""
	
	with open("specific_movesets.txt", "r") as f:
		for line in f:
			line = line.rstrip()
			if line.startswith("Pokemon = "):
				pokemon = line.replace(" ","")
				pokemon = pokemon.split("=")[1]
				pokemon = pokemon.split(",")[0]
				specific_movesets[pokemon] = [line]
			else:
				specific_movesets[pokemon].append(line)
			
	return specific_movesets


SPECIFIC_MOVESETS = get_specific_movesets()


POKEMONS_WITH_NO_MOVESET = ["CATERPIE", "METAPOD", "WEEDLE", "KAKUNA", "MAGIKARP", "UNOWN", "WURMPLE", "SILCOON", "CASCOON", "BELDUM", "KRICKETOT", "BURMY", "COMBEE", "TYNAMO", "SCATTERBUG", "SPEWPA", "COSMOG", "COSMOEM", "BLIPBUG", "NICKIT", "APPLIN", "DREEPY", "TOXEL"]




# =============================================================================
# Main functions. 
# =============================================================================


def main_generate_learned_moves(pokemon_list, all_forms):
	# Generates the file containing all the moves each Pokémon can learn. 
	sclearned = "..\\..\\PBS\\sclearned.txt"
	
	with open(sclearned, "w", encoding="utf-8") as f:
		f.write("# This file is specific to Pokémon Project STRAT by StCooler. Generated by generate_movesets.py\n")
	
	num_poke = 0 
	
	poke_dic = {}
	
	for poke_list in [pokemon_list, all_forms]:
		for pks in poke_list.keys():
			# input(pks)
			num_poke += 1
			if pks in fh.FORBIDDENFORMS:
				continue 
			
			pokemon = poke_list[pks]

			with open(sclearned, "a") as f:
				pokemon.moves.sort()
				f.write(pks + " = " + str(pokemon.total_bs) + ", " + ", ".join(pokemon.moves) + "\n")
				
			rough_total = int(pokemon.total_bs / 10) * 10 
			if rough_total not in poke_dic.keys():
				poke_dic[rough_total] = [pks]
			else:
				poke_dic[rough_total].append(pks)
			
			print("(" + str(num_poke) + "/" + str(len(poke_list)) + "). Procesed moves learned by " + pks, end="              \r")
	with open("totals.txt", "w") as f:
		for total in range(0,1000):
			if total in poke_dic.keys():
				f.write(str(total) + " = " + ", ".join(poke_dic[total]) + "\n")
	
	print()
	print("Done getting all learned moves.")
	



def generate_all_movesets(pokemon):
	#Helper function. Generates all the movesets for the given Pokémon. 
	movesets = []
	
	
	for pattern in SCSpecificPatterns.ALL:
		if pattern.isValid(pokemon, False):
			movesets.append(pattern.generateMovesets(pokemon))
			
		pattern.reset()
	
	
	
	for pattern in SCAllPatterns.ALL:
		# Attempt: specific patterns for items. 
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, ["CUBONE", "MAROWAK", "MAROWAK_1", "MAROWAK_2"], "THICKCLUB", "")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, [], "", "HUGEPOWER")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, [], "", "PUREPOWER")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.SPECIAL, [], "", "HIGHPOTENTIAL")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.SPECIAL, [], "", "BEESWARM")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, [], "", "BEESWARM")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, ["DARMANITAN"], "", "SHEERFORCE")
		movesets += adapt_pattern_for_pokemon(pokemon, pattern, SCPattern.OFFENSIVE, SCPattern.PHYSICAL, ["DARMANITAN_2"], "", "GORILLATACTICS")
	
	
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
			pattern.dont_check_stabs = False 
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
	
	
	
	if not movesets:
		# This one is for desperate cases. Second chance. 
		for pattern in SCPatternsInCase.ALL:
			pattern.allow_coverage_stab = True  
			pattern.dont_check_stabs = True 
			if pattern.isValid(pokemon, False):
				movesets.append(pattern.generateMovesets(pokemon))
				
			pattern.reset()
	
	# Always generate specific patterns. 
	for pattern in SCPatternsForStrategy.ALL:
		if pattern.isValid(pokemon, False):
			movesets.append(pattern.generateMovesets(pokemon))
			
		pattern.reset()
	
	
	return movesets




def main_generate_movesets(pokemon_list, all_forms):
	# Generates all the movesets for all Pokémons. 
	scmovesets = "..\\..\\PBS\\scmovesets.txt"
	
	num_poke = 0
	num_movesets = 0 
	no_moveset_given_while_should = [] 
	
	with open(scmovesets, "w", encoding="utf-8") as f:
		f.write("# This file is specific to Pokémon Project STRAT by StCooler. Generated by generate_movesets.py\n")	
	
	# Weather enjoyers. 
	adapt_patterns_for_weathers()
	
	
	# Some preprocessing:
	for pattern in SCAllPatterns.ALL:
		pattern.checkRole()
	for pattern in SCSpecificPatterns.ALL:
		pattern.checkRole()
	for pattern in SCPatternsForStrategy.ALL:
		pattern.checkRole()
	for pattern in SCPatternsInCase.ALL:
		pattern.checkRole()
	
	
	
	for poke_list in [pokemon_list, all_forms]:
		for pks in poke_list.keys():
			num_poke += 1 
			if pks in fh.FORBIDDENFORMS:
				continue 
			
			if pks in SPECIFIC_MOVESETS.keys():
				with open(scmovesets, "a") as f:
					f.write("#-------------------------------\n")
					for line in SPECIFIC_MOVESETS[pks]:
						f.write(line + "\n")
				num_movesets += 1
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
					f.write("Pokemon = " + pks + ",120\n")
					num_movesets += 1
				
				if pks not in POKEMONS_WITH_NO_MOVESET:
					no_moveset_given_while_should.append(pks)
					no_moveset_given_while_should.append(len(pokemon.moves))
			
			print("(" + str(num_poke) + "/" + str(len(poke_list)) + "). Generated " + str(len(movesets)) + " movesets for " + pks, end="         \r")
	
	print()
	print("Generated a total of " + str(num_movesets) + " movesets.")
	print("Pokémons with no moveset: ")
	print(no_moveset_given_while_should)




def main_generate_trainers(pokemon_list, all_forms):
	# DEPRECATED
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




def make_id(s):
	# Converts a name into an Essentials ID. 
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




def main_generate_pattern_list():
	# Generates the PBS file for the patterns. 
	sclearned = "..\\..\\PBS\\scmvstpatterns.txt"
	
	with open(sclearned, "w", encoding="utf-8") as f:
		f.write("# This file is specific to Pokémon Project STRAT by StCooler. Generated by generate_movesets.py\n")
	
		f.write("1,NOPATTERN,\"No pattern\"\n")
		f.write("2,SMEARGLEBATONPASS,\"Smeargle Baton Pass\"\n")
		f.write("3,SMEARGLESUPPORT,\"Smeargle Support\"\n")
		f.write("4,DITTOSCARF,\"Ditto Scarf\"\n")
		f.write("5,WOBBUFFETTRAPPER,\"Wobbuffet Trapper\"\n")
		f.write("6,PYUKUMUKUKILLER,\"Pyukumuku Killer\"\n")
		
		for pattern in SCSpecificPatterns.ALL:
			f.write(str(pattern.id) + "," + pattern.make_id() + ",\""+ pattern.name + "\"\n")
			
		for pattern in SCAllPatterns.ALL:
			f.write(str(pattern.id) + "," + pattern.make_id() + ",\""+ pattern.name + "\"\n")
			
		for pattern in SCPatternsInCase.ALL:
			f.write(str(pattern.id) + "," + pattern.make_id() + ",\""+ pattern.name + "\"\n")
		
		for pattern in SCPatternsForStrategy.ALL:
			f.write(str(pattern.id) + "," + pattern.make_id() + ",\""+ pattern.name + "\"\n")
	
	print("Done writing moveset patterns.")




if __name__ == "__main__":
	# print("--------------------------------")
	# print("Attention, tu viens d'ajouter des movesets avec des Z-moves, alors que tu n'as pas ajouté la gestion des Z-moves dans ton jeu. Peut-être attends un peu avant de re-générer les movesets. ")
	# input("--------------------------------")
	# return 
	main_generate_learned_moves(pku.POKEMONS, pku.ALL_FORMS)
	main_generate_movesets(pku.POKEMONS, pku.ALL_FORMS)
	main_generate_sc_tiers()
	# main_generate_new_sc_tiers() # I don't want OTF. 
	main_generate_random_tiers()
	main_generate_micro_tiers()
	main_generate_trainers(pku.POKEMONS, pku.ALL_FORMS)
	main_generate_pattern_list()
	
