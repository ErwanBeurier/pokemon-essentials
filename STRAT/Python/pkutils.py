import scpokemon
import form_handler 
import math 




def load_tms(f = None):
	filename = "..\\..\\PBS\\tm.txt" if f is None else f
	tm_data = {}
	
	f = open(filename, "r")
	current_move = ""
	for line in f:
		line = line.strip()
		if line == "":
			break
		elif line.startswith("#"):
			continue 
		elif "[" in line:
			current_move = line.replace("[","")
			current_move = current_move.replace("]","")
			tm_data[current_move] = []
		else:
			tm_data[current_move] = line.split(",")
			
	f.close()
	
	return tm_data


TM_DATA = load_tms() # move => list of pokemons




def transpose_tm_data():
	transposed = {}
	
	for move in TM_DATA.keys():
		for pk in TM_DATA[move]:
			if not pk in transposed.keys():
				transposed[pk] = []
			
			transposed[pk].append(move)
	
	for pk in transposed.keys():
		transposed[pk].sort()
	
	return transposed


TM_DATA_TRANSPOSE = transpose_tm_data() # pokemon => list of moves. 





def write_tms(all_tms):
	lines = []
	with open("..\\..\\PBS\\tm.txt", "r") as f:
		for line in f:
			lines.append(line.rstrip())
	
	tm_name = ""
	new_lines = []
	for line in lines:
		if line.startswith("#"):
			new_lines.append(line)
			continue
		elif line.startswith("["):
			new_lines.append(line)
			tm_name = line.replace("[", "")
			tm_name = tm_name.replace("]", "")
		elif tm_name != "":
			new_lines.append(",".join(TM_DATA[tm_name]))
		
	with open("..\\PBS\\tm.txt", "w") as f:
		for line in new_lines:
			f.write(line + "\n")
	
	print("Done writing TMs.")




def load_all_pokemons():
	filename = "..\\..\\PBS\\pokemon.txt"
	pokemons = {}
	
	with open(filename, "r") as f:
		lines = []
		
		for line in f:
			line = line.strip()
			# print(line)
			if line == "":
				continue
			if line.startswith("#"):
				continue
				
			if line.startswith("["):
				# Then it's an ID
				if lines:
					# Then we have reached another Pokemon. Time to load this one.
					pokemon = scpokemon.SCPokemon(lines)				
					
					pokemons[pokemon.name] = pokemon
					
				# Starting another Pokemon. 
				lines = [line]
			else:
				lines.append(line)
	
		# Then we have reached the last Pokemon.
		pokemon = scpokemon.SCPokemon(lines)
		
		pokemons[pokemon.name] = pokemon
	pokemons["WISHIWASHI"].unmega = 1 
	return pokemons




def handle_evolutions_and_tms(all_pokemons, all_forms):
	
	
	# input()
	# In all_forms, the forms is preserved. If Cubone is in form 1, it will evolve into form 1. 
	for pkname in all_forms:
		#MEOWTH_2
		for i in range(len(all_forms[pkname].evolutions)):
			evol_name = all_forms[pkname].evolutions[i] #PERRSERKER
			evol_name_form = evol_name + "_" + str(all_forms[pkname].form) # PERRSERKER_2 
			if evol_name in all_pokemons.keys(): # PERRSERKER exists
				if evol_name_form in all_forms.keys(): # PERRSERKER_2 doesn't exist. 
					all_forms[pkname].evolutions[i] = evol_name_form
					all_forms[evol_name_form].pre_evolutions = [pkname]
				else:# PERRSERKER_2 doesn't exist. 
					all_pokemons[evol_name].pre_evolutions = [pkname]
	
	evolutions_to_come = {}

	for pkname in all_pokemons:
		for evol in all_pokemons[pkname].evolutions:
			evolutions_to_come[evol] = all_pokemons[pkname].to_id()
	for pkname in all_forms:
		for evol in all_forms[pkname].evolutions:
			evolutions_to_come[evol] = all_forms[pkname].to_id()
			# evol is the evolution of pkname. 
	
	for pkname in all_forms:
		# pkname = BUTTERFREE_3
		un_form = pkname.split("_")[0]
		# un_form = BUTTERFREE
		if un_form in evolutions_to_come and pkname not in evolutions_to_come:
			# Then pkname and un_form share the same pre-evolution 
			evolutions_to_come[pkname] = evolutions_to_come[un_form]
			# METAPOD evolves into BUTTERFREE or BUTTERFREE_3 
			# For the purposes of my game, we don't care about the way they evolve. 
	
	missing_evols = []
	
	for evol in evolutions_to_come.keys():
		if evol in all_forms:
			pokemons = all_forms
		elif evol in all_pokemons:
			pokemons = all_pokemons
		else:
			missing_evols.append(evol)
			continue 
			
		if pokemons[evol].evolution_stage_max == 1:
			# Has not been updated yet. 
			pre_evol = evolutions_to_come[evol]
			# Then evol is at least a second stage.
			
			if pre_evol in evolutions_to_come.keys():
				pre_pre_evol = evolutions_to_come[pre_evol]
				# pokemons[pre_pre_evol].evolution_stage = 1
				# pokemons[pre_evol].evolution_stage = 2
				# pokemons[evol].evolution_stage = 3
				# pokemons[pre_pre_evol].evolution_stage_max = 3
				# pokemons[pre_evol].evolution_stage_max = 3
				# pokemons[evol].evolution_stage_max = 3
				get_combined(pre_pre_evol, all_pokemons, all_forms).evolution_stage = 1
				get_combined(pre_evol, all_pokemons, all_forms).evolution_stage = 2
				get_combined(evol, all_pokemons, all_forms).evolution_stage = 3
				get_combined(pre_pre_evol, all_pokemons, all_forms).evolution_stage_max = 3
				get_combined(pre_evol, all_pokemons, all_forms).evolution_stage_max = 3
				get_combined(evol, all_pokemons, all_forms).evolution_stage_max = 3
			else:
				get_combined(pre_evol, all_pokemons, all_forms).evolution_stage = 1
				get_combined(evol, all_pokemons, all_forms).evolution_stage = 2
				get_combined(pre_evol, all_pokemons, all_forms).evolution_stage_max = 2
				get_combined(evol, all_pokemons, all_forms).evolution_stage_max = 2
	
	for pkname in TM_DATA_TRANSPOSE.keys():
		if pkname in all_pokemons.keys():
			all_pokemons[pkname].moves += TM_DATA_TRANSPOSE[pkname]
		elif pkname in all_forms.keys():
			all_forms[pkname].moves += TM_DATA_TRANSPOSE[pkname]
			
	
	# Add moves from evolutions. 
	for pkname in evolutions_to_come.keys():
		# input(pokemons[pkname].evolutions)
		# Concatenate with the moves of the pre-evolution. 
		
		evol = evolutions_to_come[pkname]
		# here, evol is the pre-evolution of pkname 
		
		if pkname in all_pokemons:
			if evol in all_pokemons:
				all_pokemons[pkname].moves += all_pokemons[evol].moves
			else:
				all_pokemons[pkname].moves += all_forms[evol].moves
			# pkname is the evolution of evolutions_to_come[pkname]
			all_pokemons[pkname].pre_evolutions.append(evol)
			
		elif pkname in all_forms:
			if evol in all_pokemons:
				all_forms[pkname].moves += all_pokemons[evol].moves
			else:
				all_forms[pkname].moves += all_forms[evol].moves
			
			# pkname is the evolution of evolutions_to_come[pkname]
			all_forms[pkname].pre_evolutions.append(evol)
		else:
			continue 
	
	# Add moves from base forms.
	for pkname in all_forms:
		if all_forms[pkname].base_form_id is not None:
			all_forms[pkname].moves += all_pokemons[all_forms[pkname].base_form_id].moves
	
	# Remove duplicates 
	for pk in all_pokemons.keys():
		all_pokemons[pk].moves = [mv for mv in list(dict.fromkeys(all_pokemons[pk].moves)) if mv != "" ]
	for pk in all_forms.keys():
		all_forms[pk].moves = [mv for mv in list(dict.fromkeys(all_forms[pk].moves)) if mv != "" ]
		
		
	
	for pkname in form_handler.FORBIDDENFORMS:
		if pkname in all_pokemons:
			all_pokemons.pop(pkname, None)
		elif pkname in all_forms:
			all_forms.pop(pkname, None)
	
	
	if len(missing_evols) > 0:
		print("Missing evols")
		print(missing_evols)
	
	
	



def load_all_forms(all_pokemons = None):
	if all_pokemons is None:
		all_pokemons = POKEMONS
	
	all_forms = {}
	
	pokemon_forms_path = "..\\..\\PBS\\pokemonforms.txt"
	
	new_form_lines = []
	pokename = ""
	
	with open(pokemon_forms_path, "r") as f:
		for line in f:
			line = line.strip()
			line = line.replace(" = ", "=")
			if line.startswith("["):
				# print(line)
				if len(new_form_lines) > 0:
					if will_change_poke(new_form_lines):
						# print("will change poke")
						new_form = None 
						if pokename in all_pokemons:
							new_form = all_pokemons[pokename].copy(new_form_lines)
						elif pokename in all_forms:
							new_form = all_forms[pokename].copy(new_form_lines)
						else:
							raise Exception("Base form " + pokename + " doesn't exist for " + new_form_lines[0])
							
						all_forms[new_form.to_id()] = new_form
				
				pokename = (line.split(",")[0]).replace("[","")
				new_form_lines = [line]
			
			elif not line.startswith("#"):
				new_form_lines.append(line)
				
				if line.startswith("UnmegaForm="):
					pokename += "_" + line.replace("UnmegaForm=", "")
	
	if will_change_poke(new_form_lines):
		# print("will change poke")
		new_form = None 
		if pokename in all_pokemons:
			new_form = all_pokemons[pokename].copy(new_form_lines)
		elif pokename in all_forms:
			new_form = all_forms[pokename].copy(new_form_lines)
		else:
			raise Exception("Base form " + pokename + " doesn't exist for " + new_form_lines[0])
			
		all_forms[new_form.to_id()] = new_form
	
	return all_forms




def will_change_poke(new_form_lines):
	for line in new_form_lines:
		if line.startswith("Type1=") or line.startswith("Type2=") or line.startswith("BaseStats=") or line.startswith("Moves=") or line.startswith("EggMoves=") or line.startswith("Abilities=") or line.startswith("HiddenAbility=") or line.startswith("MegaStone="):
			return True 
	
	if new_form_lines[0] == "[PIDGEOT,4]":
		return True 
	
	return False 




def get_legendary(pokemon_list = None):
	whole_list = ["ARTICUNO", "ZAPDOS", "MOLTRES", "ARTICUNO_1", "ZAPDOS_1", "MOLTRES_1", "RAIKOU", "ENTEI", "SUICUNE", "REGIROCK", "REGICE", "REGISTEEL", "LATIAS", "LATIOS", "LATIAS_1", "LATIOS_1", "UXIE", "MESPRIT", "AZELF", "HEATRAN", "REGIGIGAS", "CRESSELIA", "COBALION", "TERRAKION", "VIRIZION", "TORNADUS", "THUNDURUS", "LANDORUS", "TORNADUS_1", "THUNDURUS_1", "LANDORUS_1", "TYPENULL", "TAPUKOKO", "TAPULELE", "TAPUBULU", "TAPUFINI", "NIHILEGO", "BUZZWOLE", "PHEROMOSA", "XURKITREE", "CELESTEELA", "KARTANA", "GUZZLORD", "POIPOLE", "NAGANADEL", "STAKATAKA", "BLACEPHALON", "MEW", "CELEBI", "JIRACHI", "PHIONE", "MANAPHY", "SHAYMIN", "SHAYMIN_1", "VICTINI", "KELDEO", "KELDEO_1", "MELOETTA", "DIANCIE", "DIANCIE_1", "HOOPA", "HOOPA_1", "VOLCANION", "MAGEARNA", "MAGEARNA_1", "MARSHADOW", "ZERAORA", "MELTAN", "MELMETAL", "ZYGARDE", "ZYGARDE_1", "KYUREM", "COSMOG", "COSMOEM", "NECROZMA", "KUBFU", "URSHIFU", "URSHIFU_1", "REGIELEKI", "REGIDRAGO", "GLASTRIER", "SPECTRIER", "CALYREX", "CALYREX_1", "CALYREX_2", "ZARUDE"] + duplicate_forms("SILVALLY", 18, [9]) + duplicate_forms("GENESECT", 4, [])
	
	if pokemon_list is None:
		return whole_list
	else:
		return [pk for pk in whole_list if pk in pokemon_list]



# J'ai trouvé l'erreur : c'est que j'ai implémenté les get_legendary() et autres en pensant à STRAT et pas à la Gen 8
# Donc il ne trouve pas Jirachi_1 parce que cette forme n'existe pas.





def load_zcrystals():
	zcrystals_path = "..\\..\\PBS\\ZUD_zmoves.txt"
	zcrystals = {}
	
	with open(zcrystals_path, "r") as f:
		for line in f:
			if not line.startswith("#"):
				line = line.replace(" ", "")
				line_split = line.split(",")
				if line_split[1] != "":
					zcrystals[line_split[1]] = line_split[0]
	
	return zcrystals


ZCRYSTALS = load_zcrystals()




def duplicate_forms(pokename, num_forms, avoid):
	forms = [pokename]
	for i in range(1, num_forms + 1):
		if i in avoid:
			continue 
		forms.append(pokename + "_" + str(i))
	return forms




def get_strong_legendary(pokemon_list = None):
	whole_list = ["MEWTWO", "MEWTWO_1", "MEWTWO_2", "MEWTWO_3", "LUGIA", "HOOH", "KYOGRE", "GROUDON", "RAYQUAZA", "KYOGRE_1", "GROUDON_1", "RAYQUAZA_1", "DEOXYS", "DEOXYS_1", "DEOXYS_2", "DEOXYS_3", "DIALGA", "PALKIA", "GIRATINA", "GIRATINA_1", "REGIGIGAS_1", "DARKRAI", "RESHIRAM", "ZEKROM", "KYUREM_1", "KYUREM_2", "XERNEAS", "YVELTAL", "SOLGALEO", "LUNALA", "ZYGARDE_2", "NECROZMA_1", "NECROZMA_2", "NECROZMA_3", "ZACIAN", "ZACIAN_1", "ZAMAZENTA", "ZAMAZENTA_1", "ETERNATUS", "CALYREX_1", "CALYREX_2"] + duplicate_forms("ARCEUS", 18, [9]) # Those that are directly Ubers
	
	if pokemon_list is None:
		return whole_list
	else:
		return [pk for pk in whole_list if pk in pokemon_list]




def get_full_legendary(pokemon_list = None):
	return get_legendary(pokemon_list) + get_strong_legendary(pokemon_list) #+ get_delta_legendary(pokemon_list)





POKEMONS = load_all_pokemons()
ALL_FORMS = load_all_forms()

def get_combined(pkname, all_pokemons = None, all_forms = None):
	if pkname in all_pokemons:
		return all_pokemons[pkname]
	else:
		return all_forms[pkname]



form_handler.manual_form_additions(POKEMONS, ALL_FORMS)
handle_evolutions_and_tms(POKEMONS, ALL_FORMS)
form_handler.rectify_moves(POKEMONS, ALL_FORMS)

# def check_temporary_forms(all_forms = None):
	# # Check if the new forms can learn stuff from themselves. Meaning that these forms will have probably different movepools to the base form. 
	# if all_forms is None:
		# global ALL_FORMS
		# all_forms = ALL_FORMS
	
	# for form_id in all_forms.keys():
		# if form_id in TM_DATA_TRANSPOSE.keys():
			# # Then it can earn stuff, and the form is not temporary.
			# all_forms[form_id].this_form_has_different_movepool = True 


POKEMONS_PLUS_FORMS = {}

for form in ALL_FORMS.keys():
	POKEMONS_PLUS_FORMS[form] = ALL_FORMS[form]
for form in POKEMONS.keys():
	POKEMONS_PLUS_FORMS[form] = POKEMONS[form]



def find_gen(pokemon):
	gens = [0, 151, 251, 386, 493, 649, 721, 809, 898]
	
	for i in range(1,9):
		if pokemon.id > gens[i]:
			continue 
		if pokemon.id <= gens[i]:
			return i
	return 0 


def main_stats_study():
	# pokemon_list = POKEMONS_PLUS_FORMS
	pokemon_list = POKEMONS
	
	data = {}
	data[1] = {"end": 151, "sum": 0, "num": 0}
	data[2] = {"end": 251, "sum": 0, "num": 0}
	data[3] = {"end": 386, "sum": 0, "num": 0}
	data[4] = {"end": 493, "sum": 0, "num": 0}
	data[5] = {"end": 649, "sum": 0, "num": 0}
	data[6] = {"end": 721, "sum": 0, "num": 0}
	data[7] = {"end": 809, "sum": 0, "num": 0}
	data[8] = {"end": 898, "sum": 0, "num": 0}
	
	# Init.
	for g in range(1,9):
		data[g] = {}
		data[g]["sum"] = 0
		data[g]["num"] = 0
		data[g]["stddev"] = 0
		data[g]["max"] = 0
		data[g]["min"] = 1000
		data[g]["min < mean-std"] = 0
		data[g]["mean-std < mean+std"] = 0
		data[g]["mean+std < max"] = 0
	
	
	# Compute sum 
	for pk in pokemon_list:
		pkmn = pokemon_list[pk]
		if not pkmn.isFinalEvol():
			continue 
		if pk in ["DITTO", "SMEARGLE", "SHEDINJA"]:
			continue 
			
		g = find_gen(pkmn)
		data[g]["sum"] += pkmn.total_bs
		data[g]["num"] += 1
	
	# Compute mean 
	for g in range(1, 9):
		data[g]["mean"] = int(data[g]["sum"] / data[g]["num"])
		
	# Compute std dev, min and max
	for pk in pokemon_list:
		pkmn = pokemon_list[pk]
		if not pkmn.isFinalEvol():
			continue 
		if pk in ["DITTO", "SMEARGLE", "SHEDINJA"]:
			continue 
		g = find_gen(pkmn)
		data[g]["stddev"] += (pkmn.total_bs - data[g]["mean"]) * (pkmn.total_bs - data[g]["mean"])
		if data[g]["max"] < pkmn.total_bs:
			data[g]["max"] = pkmn.total_bs
		if data[g]["min"] > pkmn.total_bs:
			data[g]["min"] = pkmn.total_bs
	
	for g in range(1, 9):
		data[g]["stddev"] = data[g]["stddev"] / data[g]["num"]
		data[g]["stddev"] = int(math.sqrt(data[g]["stddev"]))
	
	# Compute intervals
	for pk in pokemon_list:
		pkmn = pokemon_list[pk]
		if not pkmn.isFinalEvol():
			continue 
		if pk in ["DITTO", "SMEARGLE", "SHEDINJA"]:
			continue 
		
		g = find_gen(pkmn)
		# min < mean-std < mean+std < max 
		if pkmn.total_bs <= data[g]["mean"] - data[g]["stddev"]:
			data[g]["min < mean-std"] += 1
		elif pkmn.total_bs <= data[g]["mean"] + data[g]["stddev"]:
			data[g]["mean-std < mean+std"] += 1
		else:
			data[g]["mean+std < max"] += 1
	
	
	# Print data:
	for g in range(1,9):
		print("#---------------------------------")
		print("Generation " + str(g) + ": ")
		print("Stats: " + str(data[g]["min"]) + " < " + str(data[g]["mean"]) + "+/-" + str(data[g]["stddev"]) + " < " + str(data[g]["max"]))
		print("min | " + str(data[g]["min < mean-std"]) + " | mean-std | " + str(data[g]["mean-std < mean+std"]) + " | mean+std | " + str(data[g]["mean+std < max"]) + " | max")
	
	# First table 
	print("#---------------------------------")
	s = "".ljust(8)
	for g in range(1,9):
		s += " | Gen " + str(g)
		
	print(s + "|")
	
	for val in ["min", "mean", "stddev", "max"]:
		s = val.ljust(8)
		for g in range(1,9):
			s += (" | " + str(data[g][val])).ljust(8)
		print(s + "|")
	
	s = "Min".ljust(8)
	for g in range(1,9):
		s += " | ".ljust(8)
	print(s + "|")
	
	s = "".ljust(8)
	for g in range(1,9):
		s += (" | " + str(data[g]["min < mean-std"])).ljust(8)
	print(s + "|")
	
	s = "Mean-std".ljust(8)
	for g in range(1,9):
		s += " | ".ljust(8)
	print(s + "|")
	
	s = "".ljust(8)
	for g in range(1,9):
		s += (" | " + str(data[g]["mean-std < mean+std"])).ljust(8)
	print(s + "|")
	
	s = "Mean+std".ljust(8)
	for g in range(1,9):
		s += " | ".ljust(8)
	print(s + "|")
	
	s = "".ljust(8)
	for g in range(1,9):
		s += (" | " + str(data[g]["mean+std < max"])).ljust(8)
	print(s + "|")
	
	s = "Max".ljust(8)
	for g in range(1,9):
		s += " | ".ljust(8)
	print(s + "|")
	
	# for val in [, "", ""]:
		# s = val.ljust(7)
		# for g in range(1,9):
			# s += (" | " + str(data[g][val])).ljust(8)
		# print(s)
	

def main_add_new_tm():
	
	# new_move = "KINDLING"
	list_poke = []
	
	for k in POKEMONS_PLUS_FORMS.keys():
		poke = POKEMONS_PLUS_FORMS[k]
		if poke.hasType("FIRE"):
			list_poke.append(k)
			# list_poke.append(poke.total_bs)
	
	# list_poke.sort(key=lambda k: k.total_bs)

	for pk in list_poke:
		print(pk, end=",")

if __name__ == "__main__":
	
	
	# form_handler.manual_tm_additions(TM_DATA, TM_DATA_TRANSPOSE)
	# write_tms(TM_DATA)
	
	
	# main_stats_study()
	
	
	# print(find_gen(POKEMONS_PLUS_FORMS["DARMANITAN"]))
	# main_stats_study()
	main_add_new_tm()