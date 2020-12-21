# This script inserts preset teams into the PC for narrative purposes. 



# Following this scheme: 
# [speciesid, # 		0 = Species 
# 1, # 					1 = Min level (not used)
# 120, # 				2 = Level 
# -1, # 				3 = Gender 
# 0, # 					4 = Ability 
# -1, # 				5 = Items 
# -1, # 				6 = Nature 
# "", # 				7 = Nickname 
# Array.new(6, 31), # 	8 = IVs 
# Array.new(4, -1), # 	9 = moves 
# Array.new(6, 0), # 	10 = EVs 
# false, # 				11 = Shiny
# form_stuff]  # 		12 = Form (unimplemented)


def scNewMovesetData(pokeid, ability, nature, item, move1, move2, move3, move4, evs)
	pklist = scEmptyPokemonData(pokeid)
	
	pklist[4] = ability # ability number (0, 1, 2)
	pklist[5] = item 
	pklist[6] = nature
	pklist[9][0] = move1
	pklist[9][1] = move2
	pklist[9][2] = move3 # For Delta Volcarona
	pklist[9][3] = move4
	pklist[10] = evs
	
	return pklist 
end 





def scInsertTeam0001
	team = []
	
	# Big threat #1
	volcarona = scNewMovesetData(
					PBSpecies::VOLCARONA, 2, 
					PBNatures::TIMID, 
					PBItems::HEAVYDUTYBOOTS, 
					PBMoves::QUIVERDANCE, 
					PBMoves::FLAMETHROWER, # Should suffice to kill everything. 
					PBMoves::HIDDENPOWERGROUND, # For Delta Volcarona
					PBMoves::ROOST,
					[6,0,0,252,252,0])
	team.push(volcarona)
	
	# Big threat #2 
	deltavolcarona = scNewMovesetData(
					PBSpecies::DELTAVOLCARONA, 0,
					PBNatures::TIMID,
					PBItems::CHOICESPECS,
					PBMoves::DARKPULSE,
					PBMoves::FLAMETHROWER, 
					PBMoves::ANCIENTPOWER, # For Volcarona
					PBMoves::EARTHPOWER, # For Delta Volcarona 
					[6,0,0,252,252,0])
	team.push(deltavolcarona)
	
	
	# Lead, sets the stealth rocks. 
	wormadam = scNewMovesetData(
					PBSpecies::WORMADAM, 0,
					PBNatures::CALM,
					PBItems::FOCUSSASH,
					PBMoves::FLASHCANNON, 
					PBMoves::TOXIC, 
					PBMoves::STEALTHROCK,
					PBMoves::SUCKERPUNCH, 
					[252,0,0,0,6,252])
	wormadam[12] = [2, "Thrash"] # Steel form 
	team.push(wormadam)
	
	
	# To handle volcarona 
	masquerain = scNewMovesetData(
					PBSpecies::MASQUERAINSC1, 2,
					PBNatures::CALM,
					PBItems::DAMPROCK,
					PBMoves::RAINDANCE, # Anti-volcarona
					PBMoves::HYDROPUMP, 
					PBMoves::BUGBUZZ, 
					PBMoves::STICKYWEB, # Anti-volcarona + delta volcarona 
					[252,0,0,0,6,252]) # Handle damage
	team.push(masquerain)
	
	
	# To handle delta volcarona
	butterfree = scNewMovesetData(
					PBSpecies::BUTTERFREESC2, 2,
					PBNatures::CALM,
					PBItems::LEFTOVERS,
					PBMoves::DRAININGKISS, 
					PBMoves::HIDDENPOWERGROUND, 
					PBMoves::QUIVERDANCE,
					PBMoves::ROOST, 
					[252,0,0,0,6,252]) # Handle damage
	team.push(butterfree)
	
	
	# For fun 
	frosmoth = scNewMovesetData(
					PBSpecies::FROSMOTH, 2,
					PBNatures::MODEST,
					PBItems::LEFTOVERS,
					PBMoves::ICEBEAM, 
					PBMoves::HURRICANE, 
					PBMoves::HIDDENPOWERFIRE,
					PBMoves::QUIVERDANCE, 
					[252,0,0,6,252,0]) # Handle damage
	team.push(frosmoth)
	
	
	scTeamStorage.addTeam("Butterflies", team, "BUTTERFLIES")
end 




















