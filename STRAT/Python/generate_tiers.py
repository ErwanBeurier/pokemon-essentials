# -*- coding=utf8 -*- 



import random 
import shutil 
import os 
import re 
# import scpokemon as pku 
import form_handler as fh 
import pkutils as pku 
import type_handler 



TM_DATA = pku.TM_DATA
TM_DATA_TRANSPOSE = pku.TM_DATA_TRANSPOSE
# ALL_FORMS = 
TYPE_HANDLER = type_handler.TYPE_HANDLER
AVAILABLE_SETS = [] 
ORDERED_SECTIONS = ["FrequentPokemons", "RarePokemons", "AllowedPokemons", "BannedPokemons", "BannedAbilities", "BannedItems", "BannedMoves"]
POKEMONS_PLUS_FORMS = pku.POKEMONS_PLUS_FORMS



def scsample(a, n):
	if n == 1:
		return a[random.randint(0, len(a)-1)]
		
	cpt = 0
	indices = []
	
	for o in a:
		indices.append(cpt)
		cpt += 1
		
	# print("cpt=" + str(cpt))
	# print("indices=" + str(len(indices)))
	# print(indices)
	
	# Shuffle the array of indices:
	for i in range(cpt):
		j = random.randint(0, cpt-1)
		# print("j=" + str(j))
		temp = indices[j]
		indices[j] = indices[i]
		indices[i] = temp 
	
	a_sample = []
	
	for i in range(n):
		a_sample.append(a[indices[i]])
	
	return a_sample




def process_available_sets():
	filename = "..\\..\\PBS\\scmovesets.txt"
	
	available_sets = {}
	# Function : pokemon -> [gender, form, role]
	
	mv_pokemon = ""
	mv_form = ""
	mv_role = -1
	mv_gender = "" 
	
	with open(filename, "r") as f:
		for line in f:
			if line.startswith("#"):
				continue 
			
			line = line.rstrip()
			line = line.replace(" ", "")
			
			line_split = line.split("=")
			if line_split[0] == "Pokemon":
				if mv_role > -1:
					if mv_pokemon in available_sets:
						available_sets[mv_pokemon].append([mv_gender, mv_form, mv_role])
					else:
						available_sets[mv_pokemon] = [[mv_gender, mv_form, mv_role]]
				
				mv_pokemon = line_split[1].split(",")[0]
				mv_form = ""
				mv_role = -1
				mv_gender = "" 
			
			elif line_split[0] == "Gender":
				mv_gender = line_split[1]
			
			elif line_split[0] == "Role":
				mv_role = int(line_split[1])
			
			elif line_split[0] == "Form":
				mv_form = line_split[1]
				mv_pokemon += "_" + mv_form
	
	return available_sets




def available_sets_for_poke(pokeid):
	
	res = {}
	
	for big_role in range(1, 5):
		for category in range(1, 4):
			res[big_role*10 + category] = 0
	
	if pokeid not in AVAILABLE_SETS.keys():
		return res 
		
	
	for slot in AVAILABLE_SETS[pokeid]:
		res[slot[2]] = 1 
	
	# if "@" in pokeid:
		# input(res)
	
	return res 
	
	
	
def available_sets_for_tier(list_pokes):
	
	res = available_sets_for_poke("CATERPIE")
	
	for pokeid in list_pokes:
		res1 = available_sets_for_poke(pokeid)
		
		for k in res.keys():
			res[k] += res1[k]
	
	return res
	
	
def is_tiers_rich_enough(list_pokes):
	available_sets = available_sets_for_tier(list_pokes)
	
	rich_enough = True 
	
	for k in [22, 21, 32, 31]:
		rich_enough = rich_enough and available_sets[k] > 7
	
	return rich_enough
	


def write_tier(pkmn_lists, composition, name, id, type = "Preset tier", stratum = -1, allow_specific = False):
	# pkmn_lists = list containing the lists fully_evolved, delta_species, and so on.
	# composition = list with 0, 1, 2 and 3: not allowed, allowed, rare and frequent. 
	
	d = {}
	d["FrequentPokemons"] = []
	d["AllowedPokemons"] = []
	d["RarePokemons"] = []
	d["BannedPokemons"] = []
	d["BannedAbilities"] = ["MOODY","ARENATRAP","SHADOWTAG"]
	d["BannedItems"] = []
	d["BannedMoves"] = ["MINIMIZE", "DOUBLETEAM", "FISSURE", "SHEERCOLD", "GUILLOTINE", "HORNDRILL", "SWAGGER"]
	d["AllowSpecific"] = allow_specific
	
	# Make the actual tier from composition: 
	for i in range(len(pkmn_lists)):
		if composition[i] == 0:
			d["BannedPokemons"] += pkmn_lists[i]
			
		elif composition[i] == 1:
			d["AllowedPokemons"] += pkmn_lists[i]
			
		elif composition[i] == 2:
			d["RarePokemons"] += pkmn_lists[i]
			
		elif composition[i] == 3:
			d["FrequentPokemons"] += pkmn_lists[i]
	
	if len(d["FrequentPokemons"]) == 0:
		# raise Exception("Tiers: " + name + " / " + id + " has no frequent Pokémons.")
		print("Tiers: " + name + " / " + id + " has no frequent Pokémons.")
		return 
	
	# Then write the tier. 
	with open("..\\..\\PBS\\sctiers.txt", "a") as f:
		f.write("[" + id + "]\n")
		f.write("Name = " + name + "\n")
		f.write("Category = " + type + "\n")
		
		if stratum > 1:
			f.write("Stratum = " + str(stratum) + "\n")
		
		for k in ORDERED_SECTIONS:
			f.write(k + " = " + ", ".join(d[k]) + "\n")



def write_monotype(pkmn_lists, pokemon_list, name, id):
	# First, make the usual dictionary for the tier, with allowed Pokémons, and banned moves and such.
	d = {}
	d["FrequentPokemons"] = []
	d["AllowedPokemons"] = []
	d["RarePokemons"] = []
	d["BannedPokemons"] = []
	d["BannedAbilities"] = ["MOODY","ARENATRAP","SHADOWTAG"]
	d["BannedItems"] = []
	d["BannedMoves"] = ["MINIMIZE", "DOUBLETEAM", "FISSURE", "SHEERCOLD", "GUILLOTINE", "HORNDRILL", "SWAGGER"]
	d["AllowSpecific"] = False 
	
	# Every Pokémon will be allowed. 
	for pkmns in pkmn_lists:
		d["FrequentPokemons"] += pkmns 
	
	# Then create the list for each type. 
	for tp in TYPE_HANDLER.types:
		d["Type:" + tp] = [] 
		
		for pkmn in d["FrequentPokemons"]:
			if pokemon_list[pkmn].hasType(tp):
				d["Type:" + tp].append(pkmn)
	
	# And then write all the stuff. 
	with open("..\\..\\PBS\\sctiers.txt", "a") as f:
		f.write("[" + id + "]\n")
		f.write("Name = " + name + "\n")
		f.write("Category = Monotype\n")
		
		for k in ORDERED_SECTIONS:
			f.write(k + " = " + ", ".join(d[k]) + "\n")
			
		for t1 in TYPE_HANDLER.types:
			sectionname = "Type:" + t1
			f.write(sectionname + " = " + ", ".join(d[sectionname]) + "\n")




def write_micro_tiers(pkmn_lists, pokemon_list, name, id, type="Micro-tier"):
	list_banned = []
	list_banned = [pk for pk in pokemon_list if pk not in pkmn_lists[0] and pk not in pkmn_lists[1] and pk not in pkmn_lists[2]]
	
	
	pkmn_lists.append(list_banned)
	
	write_tier(pkmn_lists, [3,2,1,0], name, id, type, -1, False)



def main_generate_sc_tiers(pokemon_list = None):
	# Writes the list of StCooler's tiers. 
	sctarget = "..\\..\\PBS\\sctiers.txt"
	POKEMONS = POKEMONS_PLUS_FORMS if pokemon_list is None else pokemon_list
	
	
	# First, sort every Pokémon. 
	# Pokémons are divided into nine groups. 
	fully_evolved = []
	legendary = pku.get_legendary(POKEMONS)
	strong_legendary = pku.get_strong_legendary(POKEMONS)
	not_full_evolved = [] # All POkémons that are middle-step evolutions. 
	little_cup = [] # Only the first steps! 
	
	
	# Fill the groups. 
	for pks in POKEMONS.keys():
		if pks in fh.FORBIDDENFORMS:
			continue 

		if len(POKEMONS[pks].evolutions) == 0:
			if pks not in legendary and pks not in strong_legendary:
				fully_evolved.append(pks)
		else:
			# Then, either it is a LC, or an NFE. 
			first_step = False 
			middle_step = False 
			
			# Those that have never evolved, but can evolve, are Little Cup
			# Those that have evolved once, but still can, a bit are NFE.
			
			if len(POKEMONS[pks].pre_evolutions) == 0:
				little_cup.append(pks)
			else:
				not_full_evolved.append(pks)
			
	
	# Create the tiers. 
	pkmn_lists = [fully_evolved, legendary, strong_legendary, [], []]
	
	with open(sctarget, "w", encoding = "utf-8") as f:
		f.write("# This file is specific to Pokémon Project STRAT by StCooler. Generated by generate_movesets.py\n")
		
	write_tier(pkmn_lists, [3, 0, 0, 0, 0], "Fully Evolved", "FE", stratum = 80, allow_specific = True)
	# write_tier(pkmn_lists, [3, 2, 1, 2, 2], "Fully Evolved, weighted", "FEW")
	write_tier(pkmn_lists, [3, 3, 0, 0, 0], "Fully Evolved w legendary", "FEL", stratum = 80, allow_specific = True)
	write_tier(pkmn_lists, [2, 3, 3, 0, 0], "Uber", "UBER", stratum = 80, allow_specific = True)
	# write_tier(pkmn_lists, [3, 0, 0, 3, 2], "Fully Evolved, no legendary, weighted", "FENOLW")
	
	nfe_lists = [little_cup, [], not_full_evolved, [],
		fully_evolved + legendary + strong_legendary]
	
	write_tier(nfe_lists, [1, 0, 3, 0, 0], "Not Evolved", "NE", stratum = -1, allow_specific = True)
	# write_tier(nfe_lists, [3, 2, 3, 2, 0], "Not Evolved, weighted", "NEW")
	# write_tier(nfe_lists, [2, 2, 3, 3, 0], "Not Fully Evolved", "NFE")
	write_tier(nfe_lists, [3, 0, 0, 0, 0], "Little Cup", "LC", stratum = -1, allow_specific = True)
	
	# For Random tier generation. 
	write_tier([fully_evolved, legendary, strong_legendary, little_cup, not_full_evolved], [3, 1, 0, 3, 3], "Random", "RAND", stratum = -1, allow_specific = False)
	
	# write_monotype([fully_evolved, legendary], POKEMONS, "Monotype", "MONO")
	# main_generate_bitype([fully_evolved, legendary], POKEMONS)
	write_monotype([fully_evolved, []], POKEMONS, "Monotype", "MONO")
	write_monotype([fully_evolved, legendary], POKEMONS, "Monotype-Legendary", "MONOL")
	main_generate_bitype([fully_evolved, []], POKEMONS, "Bitype", "BI")
	main_generate_bitype([fully_evolved, legendary], POKEMONS, "Bitype-Legendary", "BIL")
	
	print("\rDone generating tiers. ")



def main_generate_new_sc_tiers(pokemon_list = None):
	POKEMONS = POKEMONS_PLUS_FORMS if pokemon_list is None else pokemon_list
	sctarget = "..\\..\\PBS\\sctiers.txt"
	
	dict_tiers = {
		"Variant": [],
		"Legendary": pku.get_legendary(pokemon_list),
		"StrongLegendary": pku.get_strong_legendary(pokemon_list),
		"FullyEvolved": [],
		"NotFullyEvolved": [],
		"LittleCup": []
		}
		
	# Regex to match POKEMON_4 
	re_var = re.compile("[A-Z]+SC\d+")
	
	
	# Fill the groups. 
	for pks in POKEMONS.keys():
		if pks in fh.FORBIDDENFORMS:
			continue 
		
		# Check evolutions: 
		if len(POKEMONS[pks].evolutions) == 0:
			dict_tiers["FullyEvolved"].append(pks)
			
		elif len(POKEMONS[pks].pre_evolutions) == 0:
			dict_tiers["LittleCup"].append(pks)
			
		else:
			dict_tiers["NotFullyEvolved"].append(pks)
		
		# Check if they are my variants: 
		res = re_var.match(pks)
		
		if res: 
			dict_tiers["Variant"].append(pks)
	
	
	write_tier([dict_tiers["FullyEvolved"]], [3], "On-The-Fly", "OTF", "OTF")
	
	
	with open(sctarget, "a") as f:
		# f.write("[OTF]\n")
		# f.write("Name=On The Fly\n")
		
		for key in dict_tiers.keys():
			f.write(key + " = " + ", ".join(dict_tiers[key]) + "\n")
	
	
	same_species = []



def main_generate_micro_tiers(pokemon_list = None):
	POKEMONS = POKEMONS_PLUS_FORMS if pokemon_list is None else pokemon_list
	pkmn_frequent = []
	pkmn_rare = []
	pkmn_allowed = []
	
	LEGENDARY = pku.get_legendary(POKEMONS)
	STRONG_LEGENDARY = pku.get_strong_legendary(POKEMONS)
	ALL_LEGENDARY = pku.get_full_legendary(POKEMONS)
	
	
	
	# Fossils 
	pkmn_frequent = ["OMASTAR", "KABUTOPS", "AERODACTYL", "ARMALDO", "CRADILY", "RAMPARDOS_1", "RAMPARDOS", "BASTIODON", "CARRACOSTA", "ARCHEOPS", "ARCHEOPS_1", "TYRANTRUM", "AURORUS", "DRACOZOLT", "ARCTOZOLT", "DRACOVISH", "ARCTOVISH", "AERODACTYL_1"]
	pkmn_rare = []
	pkmn_allowed = ["OMANYTE", "KABUTO", "ANORITH", "LILEEP", "CRANIDOS", "SHIELDON", "TIRTOUGA", "ARCHEN", "ARCHEN_1", "TYRUNT", "AMAURA"]
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Fossils", "FOSSILS")
	
	
	# Starters 
	pkmn_frequent = ["VENUSAUR", "CHARIZARD", "BLASTOISE", "MEGANIUM", "TYPHLOSION", "FERALIGATR", "SCEPTILE", "BLAZIKEN", "SWAMPERT", "TORTERRA", "INFERNAPE", "EMPOLEON", "SERPERIOR", "EMBOAR", "SAMUROTT", "CHESNAUGHT", "DELPHOX", "GRENINJA", "DECIDUEYE", "INCINEROAR", "PRIMARINA", "RILLABOOM", "CINDERACE", "INTELEON"]
	pkmn_rare = []
	pkmn_allowed = ["BULBASAUR", "IVYSAUR", "CHARMANDER", "CHARMELEON", "SQUIRTLE", "WARTORTLE", "CHIKORITA", "BAYLEEF", "CYNDAQUIL", "QUILAVA", "TOTODILE", "CROCONAW", "TREECKO", "GROVYLE", "TORCHIC", "COMBUSKEN", "MUDKIP", "MARSHTOMP", "TURTWIG", "GROTLE", "CHIMCHAR", "MONFERNO", "PIPLUP", "PRINPLUP", "SNIVY", "SERVINE", "TEPIG", "PIGNITE", "OSHAWOTT", "DEWOTT", "CHESPIN", "QUILLADIN", "FENNEKIN", "BRAIXEN", "FROAKIE", "FROGADIER", "ROWLET", "DARTRIX", "LITTEN", "TORRACAT", "POPPLIO", "BRIONNE", "GROOKEY", "THWACKEY", "SCORBUNNY", "RABOOT", "SOBBLE", "DRIZZILE"]
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Starters", "STARTER")
	
	
	
	# Only third evolutions
	pkmn_frequent = [pks for pks in POKEMONS.keys() if POKEMONS[pks].evolution_stage == 3]
	pkmn_rare = []
	pkmn_allowed = []
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "3rd stages", "STAGE3")
	
	
	# Only mid-step evolutions
	pkmn_frequent = [pks for pks in POKEMONS.keys() if POKEMONS[pks].evolution_stage_max == 3 and POKEMONS[pks].evolution_stage == 2]
	pkmn_rare = []
	pkmn_allowed = []
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "2nd stages", "STAGE2")
	
	
	# Only first-step evolutions
	pkmn_frequent = [pks for pks in POKEMONS.keys() if POKEMONS[pks].evolution_stage_max == 3 and POKEMONS[pks].evolution_stage == 1]
	pkmn_rare = []
	pkmn_allowed = []
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "1st stages", "STAGE1")
	
	
	# No evolutions
	pkmn_frequent = [pks for pks in POKEMONS.keys() if len(POKEMONS[pks].evolutions) == 0 and len(POKEMONS[pks].pre_evolutions) == 0 and pks not in ALL_LEGENDARY]
	pkmn_rare = []
	pkmn_allowed = []
	
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "No evolutions", "NOEVOL")
	
	
	# Only legendary 
	write_micro_tiers([ALL_LEGENDARY, [], []], POKEMONS, "All legendaries", "ALLLEG")
	write_micro_tiers([STRONG_LEGENDARY, [], []], POKEMONS, "Strong legendaries", "STRONGLEG")
	write_micro_tiers([LEGENDARY, [], []], POKEMONS, "Small legendaries", "SMALLLEG")
	
	
	# Only butterflies
	pkmn_frequent = ["BUTTERFREE", "VENOMOTH", "BEAUTIFLY", "DUSTOX", "MASQUERAIN", "WORMADAM", "WORMADAM_1", "WORMADAM_2", "MOTHIM", "VOLCARONA", "VIVILLON", "BUTTERFREE_1", "BUTTERFREE_2", "BUTTERFREE_3", "MASQUERAIN_1", "FROSMOTH"]
	pkmn_rare = []
	pkmn_allowed = []
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Butterflies", "BUTTERFLIES")
	
	
	# Only rats
	pkmn_frequent = ["RATICATE", "RAICHU", "RAICHU_1", "SANDSLASH", "FURRET", "AZUMARILL", "LINOONE", "PLUSLE", "MINUN", "BIBAREL", "PACHIRISU", "LOPUNNY", "WATCHOG", "CINCCINO", "EMOLGA", "DIGGERSBY", "DEDENNE", "TOGEDEMARU", "RATICATE_1", "RAICHU_2", "SANDSLASH_1", "RATICATE_2", "AZUMARILL_1", "CINDERACE", "GREEDENT", "OBSTAGOON", "MORPEKO"]
	pkmn_rare = []
	pkmn_allowed = ["RATTATA", "PIKACHU", "SANDSHREW", "SENTRET", "MARILL", "ZIGZAGOON", "BIDOOF", "BUNEARY", "PATRAT", "MINCCINO", "BUNNELBY", "RATTATA_1", "SANDSHREW_1", "RATTATA_2", "MARILL_1", "SCORBUNNY", "RABOOT", "SKWOVET", "ZIGZAGOON_1", "LINOONE_1"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Rats and other rodents", "RATS")
	
	
	# Only birds
	pkmn_frequent = ["PIDGEOT", "PIDGEOT_1", "PIDGEOT_2", "FEAROW", "FEAROW_1", "FARFETCHD", "DODRIO", "NOCTOWL", "XATU", "DELIBIRD", "SKARMORY", "BLAZIKEN", "SWELLOW", "EMPOLEON", "STARAPTOR", "HONCHKROW", "CHATOT", "TOGEKISS", "UNFEZANT", "ARCHEOPS", "SWANNA", "BRAVIARY", "MANDIBUZZ", "TALONFLAME", "HAWLUCHA", "DECIDUEYE", "TOUCANNON", "ORICORIO", "FEAROW_1", "NOCTOWL_1", "ARCHEOPS_1", "BRAVIARY_1", "CORVIKNIGHT", "CRAMORANT", "SIRFETCHD", "EISCUE"]
	pkmn_rare = []
	pkmn_allowed = ["PIDGEY", "PIDGEOTTO", "SPEAROW", "DODUO", "HOOTHOOT", "TOGETIC", "NATU", "MURKROW", "TORCHIC", "COMBUSKEN", "TAILLOW", "WINGULL", "PIPLUP", "PRINPLUP", "STARLY", "STARAVIA", "PIDOVE", "TRANQUILL", "ARCHEN", "DUCKLETT", "RUFFLET", "VULLABY", "FLETCHLING", "FLETCHINDER", "ROWLET", "DARTRIX", "PIKIPEK", "TRUMBEAK", "ARCHEN_1", "ROOKIDEE", "CORVISQUIRE", "FARFETCHD_1"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Birds", "BIRDS")
	
	
	# Only snakes 
	pkmn_frequent = ["ARBOK", "ARBOK_1", "STEELIX", "DUNSPARCE", "SEVIPER", "SERPERIOR", "ONIX_1", "ONIX_2", "DUNSPARCE_1", "DUNSPARCE_2", "SEVIPER_1", "SANDACONDA"]
	pkmn_rare = []
	pkmn_allowed = ["EKANS", "ONIX", "SILICOBRA"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Snakes", "SNAKES")
	
	
	# Only cats
	pkmn_frequent = ["PERSIAN", "VAPOREON", "JOLTEON", "FLAREON", "ESPEON", "UMBREON", "DELCATTY", "ZANGOOSE", "ABSOL", "LUXRAY", "PURUGLY", "LEAFEON", "GLACEON", "LIEPARD", "PYROAR", "MEOWSTIC", "INCINEROAR", "PERSIAN_1", "DELCATTY_1", "LIEPARD_1", "PERRSERKER"]
	pkmn_rare = []
	pkmn_allowed = ["MEOWTH", "EEVEE", "SKITTY", "SHINX", "LUXIO", "GLAMEOW", "PURRLOIN", "LITLEO", "ESPURR", "LITTEN", "TORRACAT", "MEOWTH_1", "SKITTY_1", "PURRLOIN_1", "MEOWTH_2"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Cats and other felids", "CATS")
	
	
	# Only dogs 
	pkmn_frequent = ["NINETALES", "NINETALES_1", "NINETALES_2", "ARCANINE", "GRANBULL", "HOUNDOOM", "MIGHTYENA", "MANECTRIC", "LUCARIO", "STOUTLAND", "ZOROARK", "DELPHOX", "FURFROU", "LYCANROC", "NINETALES_3", "GRANBULL_1", "THIEVUL", "BOLTUND"]
	pkmn_rare = []
	pkmn_allowed = ["VULPIX", "GROWLITHE", "SNUBBULL", "HOUNDOUR", "POOCHYENA", "ELECTRIKE", "RIOLU", "LILLIPUP", "HERDIER", "ZORUA", "FENNEKIN", "BRAIXEN", "ROCKRUFF", "VULPIX_1", "SNUBBULL_1", "NICKIT", "YAMPER"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Dogs and other canids", "DOGS")
	
	
	
	# Only fish 
	pkmn_frequent = ["SEAKING", "QWILFISH", "MANTINE", "KINGDRA", "SWAMPERT", "SHARPEDO", "WHISCASH", "MILOTIC", "HUNTAIL", "GOREBYSS", "RELICANTH", "LUVDISC", "LUMINEON", "BASCULIN", "ALOMOMOLA", "EELEKTROSS", "STUNFISK", "DRAGALGE", "LANTURN", "WISHIWASHI", "BRUXISH", "BARRASKEWDA", "STUNFISK_1"]
	pkmn_rare = []
	pkmn_allowed = ["HORSEA", "SEADRA", "GOLDEEN", "MAGIKARP", "REMORAID", "MUDKIP", "MARSHTOMP", "CARVANHA", "FEEBAS", "FINNEON", "MANTYKE", "TYNAMO", "EELEKTRIK", "SKRELP", "CHINCHOU", "ARROKUDA"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Fish", "FISH")
	
	
	# Turtles and crocodiles
	pkmn_frequent = ["BLASTOISE", "TORKOAL", "TORTERRA", "CARRACOSTA", "TURTONATOR", "DREDNAW", "FERALIGATR", "MAWILE", "KROOKODILE"]
	pkmn_rare = []
	pkmn_allowed = ["SQUIRTLE", "WARTORTLE", "TURTWIG", "GROTLE", "TIRTOUGA", "CHEWTLE", "TOTODILE", "CROCONAW", "SANDILE", "KROKOROK"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Turtles and crocodiles", "TURCRO")
	
	
	# Frogs / salamanders 
	pkmn_frequent = ["VENUSAUR", "POLIWRATH", "POLITOED", "TOXICROAK", "SEISMITOAD", "GRENINJA", "QUAGSIRE", "HELIOLISK", "SALAZZLE", "INTELEON"]
	pkmn_rare = []
	pkmn_allowed = ["BULBASAUR", "IVYSAUR", "POLIWAG", "POLIWHIRL", "CROAGUNK", "TYMPOLE", "PALPITOAD", "FROAKIE", "FROGADIER", "WOOPER", "HELIOPTILE", "SALANDIT", "SOBBLE", "DRIZZILE"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Frogs and amphidian", "FROGS")
	
	# # Only bears
	# pkmn_frequent = [SNORLAX, URSARING, SPINDA, BEARTIC, PANGORO, BEWEAR, 
	# pkmn_allowed = [TEDDIURSA, MUNCHLAX, CUBCHOO, PANCHAM, STUFFUL, 
	
	# # Spiders 
	# pkmn_frequent = [ARIADOS, GALVANTULA, ARAQUANID, ARIADOS_1, 
	# pkmn_allowed = [SPINARAK, SURSKIT, JOLTIK, DEWPIDER, 
	
	# # Champignons 
	# pkmn_frequent = [PARASECT", "BRELOOM", "AMOONGUSS", "SHIINOTIC", "
	# ]
	# pkmn_rare = []
	# pkmn_allowed = [PARAS", "SHROOMISH", "FOONGUS", "MORELULL", "
	# ]
	
	
	# Living objects 
	pkmn_frequent = ["MUK", "ELECTRODE", "SWALOT", "BANETTE", "CHIMECHO", "BRONZONG", "MAGNEZONE", "ROTOM", "GARBODOR", "VANILLUXE", "KLINKLANG", "CHANDELURE", "AEGISLASH", "KLEFKI", "COFAGRIGUS", "COMFEY", "MIMIKYU", "DHELMISE", "MUK_1", "POLTEAGEIST", "RUNERIGUS", "STONJOURNER"]
	pkmn_rare = ["MAGNETON", "DOUBLADE"]
	pkmn_allowed = ["MAGNEMITE", "GRIMER", "VOLTORB", "GULPIN", "SHUPPET", "BRONZOR", "TRUBBISH", "VANILLITE", "VANILLISH", "KLINK", "KLANG", "LITWICK", "LAMPENT", "HONEDGE", "YAMASK", "GRIMER_1", "SINISTEA", "YAMASK_1"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Living objects", "OBJ")
	
	
	# # Horses 
	# pkmn_frequent = ["RAPIDASH", "ZEBSTRIKA", "STANTLER", "SAWSBUCK", "COBALION", "VIRIZION", "KELDEO", "MUDSDALE", "RAPIDASH_1", "RAPIDASH_2", "RAPIDASH_3", "RAPIDASH_4"]
	# pkmn_rare = []
	# pkmn_allowed = ["PONYTA", "BLITZLE", "DEERLING", "MUDBRAY", "PONYTA_1", "PONYTA_2", "PONYTA_3", "PONYTA_4"]
	# write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Horses and stags", "HORSES")
	
	
	# Monkeys 
	pkmn_frequent = ["PRIMEAPE", "INFERNAPE", "AMBIPOM", "SIMISAGE", "SIMISEAR", "SIMIPOUR", "DARMANITAN", "ORANGURU", "PASSIMIAN", "RILLABOOM", "DARMANITAN_2"]
	pkmn_rare = []
	pkmn_allowed = ["MANKEY", "AIPOM", "CHIMCHAR", "MONFERNO", "PANSAGE", "PANSEAR", "PANPOUR", "DARUMAKA", "GROOKEY", "THWACKEY", "DARUMAKA_2"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Monkeys", "MONKEYS")
	
	
	# Beach 
	pkmn_frequent = ["TENTACRUEL", "CLOYSTER", "KINGLER", "EXEGGUTOR", "STARMIE", "PELIPPER", "VANILLUXE", "JELLICENT", "TOXAPEX", "PALOSSAND", "EXEGGUTOR_1", "PINCURCHIN"]
	pkmn_rare = ["VANILLISH"]
	pkmn_allowed = ["TENTACOOL", "SHELLDER", "KRABBY", "STARYU", "WINGULL", "VANILLITE", "FRILLISH", "MAREANIE", "SANDYGAST"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Beach", "BEACH")
	
	
	# Deep sea 
	pkmn_frequent = ["LANTURN", "QWILFISH", "CORSOLA", "KINGDRA", "HUNTAIL", "GOREBYSS", "RELICANTH", "LUMINEON",  "EELEKTROSS", "BARBARACLE", "DRAGALGE", "PYUKUMUKU", "DHELMISE", "KINGDRA_1", "CURSOLA", "ARCTOVISH", "DRACOVISH"]
	pkmn_rare = ["SEADRA", "EELEKTRIK", "CORSOLA_1"]
	pkmn_allowed = ["HORSEA", "CHINCHOU", "FINNEON", "TYNAMO", "BINACLE", "SKRELP"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Deep Sea", "DEEPSEA")
	
	
	# Antic 
	pkmn_frequent = [pk for pk in POKEMONS if POKEMONS[pk].evolution_stage == POKEMONS[pk].evolution_stage_max and POKEMONS[pk].canLearnMove("ANCIENTPOWER") and pk not in ALL_LEGENDARY]
	pkmn_rare = []
	pkmn_allowed = [pk for pk in POKEMONS if POKEMONS[pk].evolution_stage < POKEMONS[pk].evolution_stage_max and POKEMONS[pk].canLearnMove("ANCIENTPOWER") and pk not in ALL_LEGENDARY]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Antic", "ANTIC")
	
	
	# Farm 
	pkmn_frequent = ["RAPIDASH", "TAUROS", "AMPHAROS", "MILTANK", "GRUMPIG", "VESPIQUEN", "CHERRIM", "LOPUNNY", "EMBOAR", "WHIMSICOTT", "BOUFFALANT", "GOGOAT", "RIBOMBEE", "MUDSDALE", "RAPIDASH_1", "RAPIDASH_2", "RAPIDASH_3", "TAUROS_1", "CINDERACE", "DUBWOOL", "FLAPPLE", "APPLETUN", "RAPIDASH_4", "FARFETCHD", "SWANNA", "GOLDUCK_1", "SIRFETCHD", "GOLDUCK"]
	pkmn_rare = ["FLAAFFY", "PIGNITE", "RABOOT"]
	pkmn_allowed = ["PONYTA", "MAREEP", "SPOINK", "COMBEE", "CHERUBI", "BUNEARY", "TEPIG", "COTTONEE", "SKIDDO", "CUTIEFLY", "MUDBRAY", "PONYTA_1", "PONYTA_2", "PONYTA_3", "SCORBUNNY", "WOOLOO", "APPLIN", "PONYTA_4", "DUCKLETT", "FARFETCHD_1", "PSYDUCK"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Farm and cultivation", "FARM")
	
	# Savana
	pkmn_frequent = ["DODRIO", "GIRAFARIG", "GLISCOR", "DONPHAN", "INFERNAPE", "LUXRAY", "HIPPOWDON", "RHYPERIOR", "WATCHOG", "SIMISAGE", "SIMISEAR", "SIMIPOUR", "ZEBSTRIKA","KROOKODILE", "BOUFFALANT", "DURANT", "PYROAR", "MIGHTYENA", "LYCANROC", "ORANGURU", "PASSIMIAN", "RILLABOOM", "COPPERAJAH"]
	pkmn_rare = ["RHYDON", "MONFERNO", "LUXIO", "KROKOROK", "THWACKEY"]
	pkmn_allowed = ["DODUO", "RHYHORN", "GLIGAR", "PHANPY", "CHIMCHAR", "SHINX", "HIPPOPOTAS", "PATRAT", "PANSAGE", "PANSEAR", "PANPOUR", "BLITZLE", "SANDILE", "LITLEO", "POOCHYENA", "ROCKRUFF", "GROOKEY", "CUFANT"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "Savana", "SAVANA")
	
	
	# European Forest 
	pkmn_frequent = ["NINETALES", "VENOMOTH", "FURRET", "LEDIAN", "ARIADOS", "ARIADOS_1", "FORRETRESS", "URSARING", "STANTLER", "MIGHTYENA", "LINOONE", "SHIFTRY", "SWELLOW", "BRELOOM", "ZANGOOSE", "WORMADAM", "MOTHIM", "VESPIQUEN", "PACHIRISU", "FLOATZEL", "LOPUNNY", "HONCHKROW", "SKUNTANK", "EMBOAR", "UNFEZANT", "LEAVANNY", "SAWSBUCK", "AMOONGUSS", "FERROTHORN", "DURANT", "DELPHOX", "DIGGERSBY", "TALONFLAME", "LURANTIS", "SHIINOTIC", "NINETALES_1", "NINETALES_2", "LEDIAN_1", "ARIADOS_1", "JUMPLUFF_1", "JUMPLUFF", "GREEDENT", "CORVIKNIGHT", "ORBEETLE", "OBSTAGOON"]
	pkmn_rare = ["NUZLEAF", "PIGNITE", "TRANQUILL", "SWADLOON", "BRAIXEN", "FLETCHINDER", "SKIPLOOM", "CORVISQUIRE", "DOTTLER", "THIEVUL", "LINOONE_1"]
	pkmn_allowed = ["VULPIX", "VENONAT", "SENTRET", "LEDYBA", "SPINARAK", "PINECO", "TEDDIURSA", "POOCHYENA", "ZIGZAGOON", "SEEDOT", "TAILLOW", "SHROOMISH", "BURMY", "COMBEE", "BUIZEL", "BUNEARY", "STUNKY", "TEPIG", "PIDOVE", "SEWADDLE", "DEERLING", "FOONGUS", "FERROSEED", "FENNEKIN", "BUNNELBY", "FLETCHLING", "FOMANTIS", "MORELULL", "HOPPIP", "SKWOVET", "ROOKIDEE", "BLIPBUG", "NICKIT", "ZIGZAGOON_1"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "European Forest", "FOREST")
	
	
	# Night 
	pkmn_frequent = ["NIDOQUEEN", "NIDOKING", "CLEFABLE", "WIGGLYTUFF", "BELLOSSOM_1","LUNATONE", "MUSHARNA", "WIGGLYTUFF_1", "WIGGLYTUFF_2", "WIGGLYTUFF_3", "MUSHARNA_1", "NIDOQUEEN_1", "NIDOQUEEN_2", "NIDOQUEEN_3", "NIDOKING_1", "NIDOKING_2", "NIDOKING_3", "DELCATTY", "DELCATTY_1", "NOCTOWL", "CROBAT", "UMBREON", "DUSTOX", "VOLBEAT", "ILLUMISE", "SPIRITOMB", "SWOOBAT", "ZOROARK", "GOTHITELLE", "CHANDELURE", "NOIVERN", "DECIDUEYE", "CROBAT_1", "NOCTOWL_1", "VOLBEAT_1", "ILLUMISE_1"]
	pkmn_rare = ["NIDORINA", "NIDORINO", "CLEFAIRY", "JIGGLYPUFF", "JIGGLYPUFF_1", "JIGGLYPUFF_2", "GOLBAT", "GOTHORITA", "LAMPENT", "DARTRIX", "GOLBAT_1"]
	pkmn_allowed = ["NIDORANfE", "NIDORANmA", "MUNNA", "SKITTY", "SKITTY_1", "ZUBAT", "HOOTHOOT", "MURKROW", "WOOBAT", "ZORUA", "GOTHITA", "LITWICK", "NOIBAT", "ROWLET", "ZUBAT_1"]
	write_micro_tiers([pkmn_frequent, pkmn_rare, pkmn_allowed], POKEMONS, "The night and the moon", "NIGHT")
	
	
	
	print("Written micro-tiers")
	


def main_generate_random_tiers(pokemon_list = None):
	global POKEMONS_PLUS_FORMS
	POKEMONS = POKEMONS_PLUS_FORMS if pokemon_list is None else pokemon_list
	
	# input([pk for pk in POKEMONS if "@" in pk])
	# input(POKEMONS["ALTARIA@item=ALTARITE"].total_bs)
	
	global AVAILABLE_SETS
	AVAILABLE_SETS = process_available_sets()
	
	ignored_pokemons = ["WISHIWASHI", "WISHIWASHI_1"] + pku.get_legendary(POKEMONS) + pku.get_strong_legendary(POKEMONS)
	
	num_poke = 40
	num_tiers = 1 
	stddev = 30
	
	for total_bs in range(200, 700, 50):
		all_pokemons_with_bs = [pk for pk in POKEMONS_PLUS_FORMS if POKEMONS_PLUS_FORMS[pk].total_bs > total_bs - stddev and POKEMONS_PLUS_FORMS[pk].total_bs < total_bs + stddev and pk in AVAILABLE_SETS.keys() and pk not in ignored_pokemons]
		# print("Tiers with total_bs=" + str(total_bs) + " and stddev=" + str(stddev) + " has " + str(len(all_pokemons_with_bs)) + " Pokémons (" + str(num_poke) + " wanted)")
		
		
		# First, make a tier with all the Pokémons in it.
		
		tiers_name = "Tiers of base stats " + str(total_bs)
		tiers_id = "BS" + str(total_bs)
		
		write_micro_tiers([all_pokemons_with_bs, [], []], POKEMONS, tiers_name, tiers_id, type = "Base stats tiers")
		
		continue # DO NOT make random tiers. 
		
		if len(all_pokemons_with_bs) >= num_poke:
				# print("Tiers with total_bs=" + str(total_bs) + " and stddev=" + str(stddev) + " has " + str(len(all_pokemons_with_bs)) + " Pokémons (" + str(num_poke) + " wanted)")
			# else:
			several_tiers = 4 if len(all_pokemons_with_bs) > 2*num_poke else 1 
			several_tiers = 8 if len(all_pokemons_with_bs) > 4*num_poke else several_tiers
			several_tiers = 12 if len(all_pokemons_with_bs) > 6*num_poke else several_tiers
			
			
			for i in range(several_tiers):
				pkmns_in_tiers = scsample(all_pokemons_with_bs, num_poke)
				rich_enough = is_tiers_rich_enough(pkmns_in_tiers)
				
				attempt = 1 
				while not rich_enough and attempt < 100:
					pkmns_in_tiers = scsample(all_pokemons_with_bs, num_poke)
					rich_enough = is_tiers_rich_enough(pkmns_in_tiers)
					
					attempt += 1
				
				if rich_enough:
					allowed_mon_without_item = []
					# If required item, then the pokemon without the item is still allowed. 
					for pk in pkmns_in_tiers:
						if "@item=" in pk:
							allowed_mon_without_item.append(pk.split("@")[0])
					
					
					tiers_name = "Random tiers with base stats " + str(total_bs) + " num. " +  str(i+1)
					tiers_id = "RAND" + str(total_bs) + "N" + str(i+1).rjust(2, "0")
					
					write_micro_tiers([pkmns_in_tiers, [], allowed_mon_without_item], POKEMONS, tiers_name, tiers_id, type = "Random")
					
					num_tiers += 1 
				else:
					print(str(attempt) + " failed attempts for random tiers with total bs = " + str(total_bs) + ".")
	
	print("Generated " + str(num_tiers - 1) + " random tiers.")



def fitsDoubleType(pokemon, type1, type2):
	if len(pokemon.types) == 1:
		return pokemon.hasType(type1) or pokemon.hasType(type2)
	else:
		return pokemon.hasType(type1) and pokemon.hasType(type2)



def main_generate_bitype(pkmn_lists, pokemon_list, name, id):
	global POKEMONS_PLUS_FORMS
	POKEMONS = POKEMONS_PLUS_FORMS if pokemon_list is None else pokemon_list
	
	# input([pk for pk in POKEMONS if "@" in pk])
	# input(POKEMONS["ALTARIA@item=ALTARITE"].total_bs)
	
	
	bi_types = {}
	
	for t1 in range(len(TYPE_HANDLER.types)):
		type1 = TYPE_HANDLER.types[t1]
		bi_types[type1] = {}
		
		for t2 in range(len(TYPE_HANDLER.types)):
			if t1 == t2:
				continue 
				
			type2 = TYPE_HANDLER.types[t2] 
			
			bi_types[type1][type2] = [pk for pk in POKEMONS_PLUS_FORMS if fitsDoubleType(POKEMONS_PLUS_FORMS[pk], type1, type2)]
			
			
	d = {}
	d["FrequentPokemons"] = []
	d["AllowedPokemons"] = []
	d["RarePokemons"] = []
	d["BannedPokemons"] = []
	d["BannedAbilities"] = ["MOODY","ARENATRAP","SHADOWTAG"]
	d["BannedItems"] = []
	d["BannedMoves"] = ["MINIMIZE", "DOUBLETEAM", "FISSURE", "SHEERCOLD", "GUILLOTINE", "HORNDRILL", "SWAGGER"]
	
	# Every Pokémon will be allowed. 
	for pkmns in pkmn_lists:
		d["FrequentPokemons"] += pkmns 
	
	# Check if there are enough Pokémon. No influence on the tier, it's just some info for the dev. 
	all_few = []
	for t1 in bi_types.keys():
		for t2 in bi_types[t1].keys():
			l = len([pk for pk in bi_types[t1][t2] if pk in d["FrequentPokemons"]])
			
			if l < 14:
				all_few.append(t1 + "," + t2 + "=" + str(l))
	
	if len(all_few) > 0:
		print("The following types have very few Pokemons:")
		for s in all_few:
			print(s)
	
	# And then write all the stuff. 
	with open("..\\..\\PBS\\sctiers.txt", "a") as f:
		f.write("[" + id + "]\n")
		f.write("Name = " + name + "\n")
		f.write("Category = Bitype\n")
		for k in ORDERED_SECTIONS:
			f.write(k + " = " + ", ".join(d[k]) + "\n")
			
		
		for t1 in TYPE_HANDLER.types:
			for t2 in TYPE_HANDLER.types:
				if t1 == t2:
					continue 
				
				sectionname = "Type:" + t1 + "," + t2
				
				# if sectionname not in bi_types.keys():
					# continue 
				
				f.write(sectionname + " = " + ", ".join(bi_types[t1][t2]) + "\n")

	



if __name__ == "__main__":
	# main_generate_random_tiers() 
	print(pku.POKEMONS["VENUSAUR"].pre_evolutions)
