###############################################################################
# SCGenerateTeam
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains functions related to the generation of teams, with 
# regards to a given tier. 
###############################################################################




# TODO:
# - Pattern for ARCEUS
# - Lightclay
# - Trick room setter 


def scGetPersonalItems(speciesid, complete = false)
	personal_items = scLoadPersonalItems(speciesid)
  
  return [] if !personal_items
  
  if complete
    return personal_items
  else 
    only_items = []
    
    for p in personal_items
      only_items.push(p[0])
    end 
    
    return only_items
  end 
  
end 




def scChooseAbility(pokemon, tiers)
	
	ret = pokemon.getAbilityList
	# ret[0] = IDs of the Abilities
	# ret[1] = the index of the ability (determines whether the corresponding ability is 0/1 or hidden 2)
	
	# For Kabutops : 
	# ret[0] = [SWIFTSWIM, BATTLEARMOR, WEAKARMOR] 
	# ret[1] = [0, 1, 2] 
	# For Venusaur:
	# ret[0] = [OVERGROW, CHLOROPHYLL] 
	# ret[1] = [0, 2] 
	
	
	# debug_lol = [PBSpecies::WISHIWASHI, PBSpecies::SOLROCK, PBSpecies::LIEPARD]
	
	
	allowed = [] 
	
	for i in 0...ret.length 
		if not tiers.banned_abilities.include?(ret[i][0])
			allowed.push(i)
		end 
	end 
	
	# if debug_lol.include?(pokemon.species)
		# allo = " allowed = " 
		# ret0 = " ret[0] = "
		# ret1 = " ret[1] = "
		
		# for ab in allowed
			# allo += ab.to_s + ";"
			# ret0 += getConstantName(PBAbilities, ret[0][ab]) + ";"
			# ret1 += ret[1][ab].to_s + ";"
		# end 
		
		# Kernel.pbMessage(pbGetSpeciesConst(pokemon.species) + allo + ret0 + ret1)
	# end 
	
	# For Kabutops:
	# allowed = [0, 1, 2]
	# For Venusaur:
	# allowed = [0, 1]
	
	if allowed.empty?
		return 0 # Still return a Pokemon... 
	end 
  
	
	a = allowed[rand(allowed.length)]
	
	return ret[a][0]
end 






def firstIndexInArray(ary, obj)
	# Finds the index of the given obj in the given array.
	# If obj is not found, then returns -1.
	for i in 0...ary.length
		if ary[i] == obj
			return i
		end 
	end 
	
	return -1 
end 



def scGenerateTeamRand(trainer, type_of_team = -1, type1 = -1, type2 = -1)
	# type_of_team:
	# if < 0: choose at random.
	# if = 0: Hyper Offense (Lead + 4 offensive + anything)
	# if = 1: Offensive (Lead + 3 offensive + 2 defensive)
	# if = 2: Balanced (Lead + 2 Offensive + 3 defensive)
	# if = 3: Defensive (Lead + Offensive + 4 defensive)
	# if = 4: Stall (5 defensive + Anything)
	
	# Build the team. 
	
	party_species = [] 
	party_roles = [] 
	
	
	# Get tier. 
  tierid = "FE"
  tierid = $PokemonTemp.battleRules["tier"] if $PokemonTemp.battleRules["tier"]
  
	result_generation = []
  tiers = loadTiers(tierid)
  
  
  
  # Generate the Pokémons. 
  if tierid == "MONO"
    # If all POkémons are KO, then change the type. 
    counter = 0
    for i in 0...trainer.party.length
      counter += 1 if trainer.party[i].hp == 0
    end 
    
    if counter == trainer.party.length 
      # All dead; change type! 
      if trainer == $Trainer
        result_generation = tiers.randTeamSpecies(nil, type_of_team)
        # wanted_type = nil alloww the player to choose the type 
      else
        result_generation = tiers.randTeamSpecies(-1, type_of_team)
        # wanted_type = -1 chooses the type at random. 
      end 
    else 
      wanted_type = type1
      wanted_type = tiers.findType(trainer.party) if type1 != nil && type1 < 0
      result_generation = tiers.randTeamSpecies(wanted_type, type_of_team)
    end 
  elsif tierid == "BI"
    # If all POkémons are KO, then change the type. 
    counter = 0
    for i in 0...trainer.party.length
      counter += 1 if trainer.party[i].hp == 0
    end 
    
    if counter == trainer.party.length 
      # All dead; change type! 
      if trainer == $Trainer
        result_generation = tiers.randTeamSpecies(nil, nil, type_of_team)
        # wanted_type = nil alloww the player to choose the type 
      else
        result_generation = tiers.randTeamSpecies(-1, -1, type_of_team)
        # wanted_type = -1 chooses the type at random. 
      end 
    else 
      wanted_types = [type1, type2]
      wanted_types = tiers.findTypes(trainer.party) if type1 != nil && type1 < 0 &&type2 != nil && type2 < 0
      result_generation = tiers.randTeamSpecies(wanted_types[0], wanted_types[1], type_of_team)
    end 
    
  else 
    result_generation = tiers.randTeamSpecies(type_of_team)
  end 
  
	party_species = result_generation[0]
	party_roles = result_generation[1]
	party_movesets = result_generation[2]
	
  
	# In a Nuzzlocke ladder, every dead Pokémon will be changed. 
	deleted_species = []
	party_survivors = [] 
	
	if $PokemonTemp.battleRules["nuzzlocke"]
		# Remove duplicates. 
		for i in 0...trainer.party.length
			pk = trainer.party[i]
			
			if pk.hp == 0
				# j = party_species.find_index(pk.species)
				j = firstIndexInArray(party_species, pk.species)
				
				if j > -1
					delsp = party_species.delete_at(j)
					deleted_species.push(delsp)
					
					party_movesets.delete(delsp)
				end 
			else
				party_survivors.push(pk)
			end 
		end 
		
		# Ensure there are only 6 Pokémons per party. 
		while party_species.length + party_survivors.length > 6
			party_species.delete_at(party_species.length-1)
			party_movesets.delete(party_species[-1])
		end 
		
		# Create the message for the player.
		message = ""
		
		if deleted_species.length > 0
			for i_sp in 0...deleted_species.length
				message += pbGetSpeciesConst(deleted_species[i_sp])
				
				if i_sp < deleted_species.length - 2
					message += ", "
				elsif i_sp < deleted_species.length - 1
					message += " and "
				end 
			end 
			
			# Then some Pokémon died.
			if deleted_species.length == 1
				message += " was replaced."
			else
				message += " were replaced."
			end 
		else 
			# Nobody died. 
			message = "" 
		end 
		$game_variables[202] = message
    
	else
		$game_variables[202] = ""
	end
  
	
	for i in 0...6
		if party_roles[i] == nil
			raise _INTL("Party roles: {1}-{2}-{3}-{4}-{5}-{6}", party_roles[0], party_roles[1], party_roles[2], party_roles[3], party_roles[4], party_roles[5])
		end 
	end 
	
	party = []
	
	if party_species.length != 6 and deleted_species.length > 0
		raise _INTL("Party_species.length == {1} and deleted_species.length == {2}", 
			party_species.length, deleted_species.length)
	end 
	
	
	# And then, create the actual party: create the Pokemons + choose a moveset. 
	for i_sp in 0...party_species.length
		pkmn = party_movesets[i_sp]
			
    # Give form if applicable. 
    form = (pkmn[SCMovesetsMetadata::FORM] ? pkmn[SCMovesetsMetadata::FORM] : 0)
    sp = pbGetFSpeciesFromForm(pkmn[SCMovesetsMetadata::SPECIES], form)
    
		# For each species, choose one moveset.
		pokemon = PokeBattle_Pokemon.new(sp,pkmn[SCMovesetsMetadata::LEVEL], trainer)
    
		# Check if it has moves. If not, then the moves will be given by the level. 
		# Allow Ditto that has only one move, but also EVs/IVs and such. 
		# Pokemons like Caterpie don't have moves at all, neither do they have EVs/IVs and such.
		if pkmn[SCMovesetsMetadata::MOVE1]
			# Give moves 
			# First, give a STAB.
			# Then, give moves. 
			types_given = [] 
			stab_given = false 
			# Stores the types of the given offensive moves. 
			given_moves = []
			
			# Kernel.pbMessage(_INTL("{1}",pkmn))
			
			for m in SCMovesetsMetadata::MOVE1..SCMovesetsMetadata::MOVE4
				# We filter the moves again. Do not give several offensive 
				# moves with the same type (unless one has priority). 
        
 				if !pkmn[m]
					break 
				end
        
				filtered_again = []
				
				if pkmn[m].is_a?(Fixnum)
					raise _INTL("pkmn[m]={2} is a Fixnum, rather than an array: m={1} and " + scConvertMovesetToString(pkmn), m, pkmn[m])
				end 
				
				for mvid in pkmn[m]
					
					if given_moves.include?(mvid)
						next 
					end 
					
					mvdata = PBMoveData.new(mvid)
					
					if (mvdata.priority <= 0 and (mvdata.category == 0 or mvdata.category == 1) and mvdata.basedamage >= 60) or isConst?(mvid, PBMoves, :LOWKICK) or isConst?(mvid, PBMoves, :GRASSKNOT)
						# Then, it's an offensive move.
						
						if not stab_given
							# Then give ONLY stabs in filtered_again
							if pokemon.hasType?(mvdata.type)
								# Then it's a STAB
								filtered_again.push(mvid)
							end 
							# Always give a STAB to a Pokemon as its first offensive move. 
							
						elsif not types_given.include?(mvdata.type)
							filtered_again.push(mvid)
							# Avoid already given types. 
							# + A stab was already given. 
						end 
					else 
						filtered_again.push(mvid)
					end 
				end
        
				# Some security: if filtered_again is empty, then use a trick to force a fourth move. 
				if filtered_again.empty?
					for mvid in pkmn[m]
						
						if given_moves.include?(mvid)
							next 
						end 
						
						filtered_again.push(mvid)
					end 
				end 
				
				if filtered_again.empty?
					next 
				end 
				
				mvid = scsample(filtered_again, 1)
				
				if mvid == nil
					raise _INTL("Nil move for {1}\nFiltered again = {2}\nFiltered moves = {3}\nGiven moves={4}", pokemon.species, filtered_again,pkmn[m], given_moves)
				end 
				mvdata = PBMoveData.new(mvid)
				pokemon.moves[m-SCMovesetsMetadata::MOVE1] = PBMove.new(mvid)
				given_moves.push(mvid)

				if mvdata.priority <= 0 and (mvdata.category == 0 or mvdata.category == 1) and mvdata.basedamage >= 60
					# It's a damage move, save its type. 
					types_given.push(mvdata.type)
					
					if pokemon.hasType?(mvdata.type)
						stab_given = true 
					end 
				end 
				
			end 
			
			
			# Give nature and corresponding EVs if applicable. 
      
      ev_i = rand(pkmn[SCMovesetsMetadata::EV].length)
      nat_i = 0
      
      if pkmn[SCMovesetsMetadata::EV].length == pkmn[SCMovesetsMetadata::NATURE].length
        nat_i = ev_i 
      else 
        nat_i = rand(pkmn[SCMovesetsMetadata::NATURE].length)
      end 
      
      pokemon.setNature(pkmn[SCMovesetsMetadata::NATURE][nat_i])
      pokemon.ev = pkmn[SCMovesetsMetadata::EV][ev_i]
			
			totalev = 0
			
			for i in 0...6
				totalev += pokemon.ev[i]
			end 
			
			if totalev < 508 or totalev > 510
				str_ev = ""
        
				for i in 0...6
					str_ev += pokemon.ev[i].to_s + ", "
				end 
				
				raise _INTL("Wrong {1} EV but:\r\n{2}", str_ev,scConvertMovesetToString(pkmn))
			end 
			
			
			# Give IVs 
      pokemon.iv = (pkmn[SCMovesetsMetadata::IV] ? pkmn[SCMovesetsMetadata::IV] : Array.new(6, 31))
			
			# Give ability 
			ab = pkmn[SCMovesetsMetadata::ABILITY]
      
      if ab
				pokemon.setAbility(ab)
      else 
				pokemon.setAbility(scChooseAbility(pokemon, tiers))
      end
      
			# Give gender 
			pokemon.setGender(pkmn[SCMovesetsMetadata::GENDER]) if pkmn[SCMovesetsMetadata::GENDER]
			
			# Give item.
      it = rand(pkmn[SCMovesetsMetadata::ITEM].length)
      pokemon.item = pkmn[SCMovesetsMetadata::ITEM][it]
			
			pokemon.calcStats
		end 
		
		party.push(pokemon)
	end
	
	return party + party_survivors
end 




















