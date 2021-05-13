###############################################################################
# SCGenerateTeam
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains functions related to the generation of teams and 
# movesets (and Z-crystals), with regards to a given tier.
###############################################################################


def scChooseAbility(pokemon, tier)
  
  ret = pokemon.getAbilityList
  # ret[i][0] = the index of the ability (determines whether the corresponding ability is 0/1 or hidden 2)
  # ret[i][1] = IDs of the Abilities
  
  # For Kabutops : 
  # ret[0] = [0, SWIFTSWIM] 
  # ret[1] = [1, BATTLEARMOR] 
  # ret[2] = [2, WEAKARMOR] 
  # For Venusaur:
  # ret[0] = [0, OVERGROW] 
  # ret[1] = [2, CHLOROPHYLL]   
  
  allowed = [] 
  
  for i in 0...ret.length 
    if not tier.banned_abilities.include?(ret[i][0])
      allowed.push(i)
    end 
  end 
    
  # For Kabutops:
  # allowed = [0, 1, 2]
  # For Venusaur:
  # allowed = [0, 1]
  
  if allowed.empty?
    return ret[0][1] # Still return a Pokemon... 
  end 
  
  a = allowed[rand(allowed.length)]
  
  return ret[a][1]
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



def scGenerateTeamRand(trainer, type_of_team = nil, type1 = -1, type2 = -1, tierid = nil)
  # type_of_team: nil, or constant of SCTeamFilters.
  
  # Build the team. 
  
  party_species = [] 
  party_roles = [] 
  
  
  # Get tier. 
  tierid = scGetTier() if !tierid
  
  result_generation = []
  tier = loadTier(tierid)
  
  for_player = (trainer == $Trainer)
  
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
        result_generation = tier.randTeamSpecies(nil, type_of_team)
        # wanted_type = nil alloww the player to choose the type 
      else
        result_generation = tier.randTeamSpecies(-1, type_of_team)
        # wanted_type = -1 chooses the type at random. 
      end 
    else 
      wanted_type = type1
      wanted_type = tier.findType(trainer.party) if type1 != nil && type1 < 0
      result_generation = tier.randTeamSpecies(wanted_type, type_of_team)
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
        result_generation = tier.randTeamSpecies(nil, nil, type_of_team)
        # wanted_type = nil alloww the player to choose the type 
      else
        result_generation = tier.randTeamSpecies(-1, -1, type_of_team)
        # wanted_type = -1 chooses the type at random. 
      end 
    else 
      wanted_types = [type1, type2]
      if type1 == -1 && type2 == -1
        result = tier.findTypes(trainer.party) 
        wanted_types = result if result
      end 
      result_generation = tier.randTeamSpecies(wanted_types[0], wanted_types[1], type_of_team)
    end 
    
  else 
    result_generation = tier.randTeamSpecies(type_of_team, trainer == $Trainer) # ask the strength of the team if ever. 
  end 
  
  party_species = result_generation[0]
  party_roles = result_generation[1]
  party_movesets = result_generation[2]
  
  # movesetlog = load_data("Data/scmovesets.dat")
  # party_species[0] = PBSpecies::ABOMASNOW
  # party_movesets[0] = movesetlog[party_species[0]][0]
  # party_roles[0] = party_movesets[0][SCMovesetsData::ROLE]
  
  
  
  # In a Nuzzlocke ladder, every dead Pokémon will be changed. 
  deleted_species = []
  party_survivors = [] 
  
  if scIsNuzzlocke()
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
    $game_variables[SCVar::NuzzlockeChanges] = message
    
  else
    $game_variables[SCVar::NuzzlockeChanges] = ""
  end
  
  
  for i in 0...6
    if party_roles[i] == nil
      raise _INTL("Party roles: {1}-{2}-{3}-{4}-{5}-{6}", party_roles[0], party_roles[1], party_roles[2], party_roles[3], party_roles[4], party_roles[5])
    end 
  end 
  
  party = []
  
  if party_species.length != 6 && deleted_species.length > 0
    raise _INTL("Party_species.length == {1} and deleted_species.length == {2}", 
      party_species.length, deleted_species.length)
  end 
  
  
  # And then, create the actual party: create the Pokemons + choose a moveset. 
  for i_sp in 0...party_species.length
    pkmn = party_movesets[i_sp]
    pokemon = scGenerateMoveset(pkmn, trainer, tier)
    party.push(pokemon)
  end
  
  return party + party_survivors
end 




def scGenerateMovesetFast(fspecies, role = 0)
  # For the owned Pokémns.
  # But also returns a random moveset of the given role. 
  movesetdb = scLoadMovesetsData
  real_filter = SCRealPokemonsFilter.new
  
  movesets = []
  
  loop do 
    real_filter.eachFittingMoveset(movesetdb, fspecies, role, 0) do |mv, ind, filter|
      movesets.push(mv)
    end 
    
    if movesets.length > 0
      break
    elsif movesets.length == 0 && role == 0
      raise _INTL("Error: no moveset found for {1}", PBSpecies.getName(fspecies))
    elsif movesets.length == 0
      role = SCTeamFilter.extendRole(role)
    end 
  end 
  
  moveset = scsample(movesets, 1)
  
  return scGenerateMoveset(moveset, $Trainer, loadTierNoStorage("FE"))
end 



def scGenerateMoveset(pkmn, trainer, tier)
  # Give form if applicable. 
  # form = (pkmn[SCMovesetsData::BASEFORM] ? pkmn[SCMovesetsData::BASEFORM] : pkmn[SCMovesetsData::FORM])
  form = pkmn[SCMovesetsData::FORM]
  if pkmn[SCMovesetsData::BASEFORM] && pkmn[SCMovesetsData::BASEFORM] != pkmn[SCMovesetsData::FORM]
    form = pkmn[SCMovesetsData::BASEFORM] 
  end 
  form = (form ? form : 0)
  sp = pbGetFSpeciesFromForm(pkmn[SCMovesetsData::BASESPECIES], form)
  
  # pbMessage(_INTL("Base species: {1}", PBSpecies.getName(pkmn[SCMovesetsData::SPECIES] ? pkmn[SCMovesetsData::SPECIES] : pkmn[SCMovesetsData::BASESPECIES]))) 
  # For each species, choose one moveset.
  pokemon = PokeBattle_Pokemon.new(sp,pkmn[SCMovesetsData::LEVEL], trainer)
  
  # Check if it has moves. If not, then the moves will be given by the level. 
  # Allow Ditto that has only one move, but also EVs/IVs and such. 
  # Pokemons like Caterpie don't have moves at all, neither do they have EVs/IVs and such.
  if pkmn[SCMovesetsData::MOVE1]
    # Give moves 
    # First, give a STAB.
    # Then, give moves. 
    types_given = [] 
    stab_given = false 
    # Stores the types of the given offensive moves. 
    given_moves = []
    
    for m in SCMovesetsData::MOVE1..SCMovesetsData::MOVE4
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
      
      pbMessage(_INTL("mvid[0] =  {1}", mvid[0])) if mvid.is_a?(Array)
      pbMessage(_INTL("mvid[0] =  {1}", PBMoves.getName(mvid[0]))) if mvid.is_a?(Array)
      
      if mvid == nil
        raise _INTL("Nil move for {1}\nFiltered again = {2}\nFiltered moves = {3}\nGiven moves={4}", pokemon.species, filtered_again,pkmn[m], given_moves)
      end 
      mvdata = PBMoveData.new(mvid)
      pokemon.moves[m-SCMovesetsData::MOVE1] = PBMove.new(mvid)
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
    ev_i = rand(pkmn[SCMovesetsData::EV].length)
    nat_i = 0
    
    if pkmn[SCMovesetsData::EV].length == pkmn[SCMovesetsData::NATURE].length
      nat_i = ev_i 
    else 
      nat_i = rand(pkmn[SCMovesetsData::NATURE].length)
    end 
    
    pokemon.setNature(pkmn[SCMovesetsData::NATURE][nat_i])
    pokemon.ev = pkmn[SCMovesetsData::EV][ev_i]
    
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
    pokemon.iv = (pkmn[SCMovesetsData::IV] ? pkmn[SCMovesetsData::IV] : Array.new(6, 31))
    
    # Give ability 
    ab = pkmn[SCMovesetsData::ABILITYINDEX]
    
    if ab
      pokemon.setAbility(ab) # Here, it's the INDEX!!!!
    else 
      pokemon.setAbility(scChooseAbility(pokemon, tier))
    end
    
    # Give gender 
    pokemon.setGender(pkmn[SCMovesetsData::GENDER]) if pkmn[SCMovesetsData::GENDER]
    
    # Give item.
    it = scsample(pkmn[SCMovesetsData::ITEM], 1)
    
    if it == PBItems::GENERICZCRYSTAL
      # Then choose the right crystal.
      potential_crystals = scGetFittingZCrystals(pokemon, true)
      it = scsample(potential_crystals, 1)
    end 
    pokemon.item = it 
    
    # Dynamax stuff
    pokemon.setDynamaxLvl(pkmn[SCMovesetsData::DYNAMAXLEVEL] || 10)
    
    if (pkmn[SCMovesetsData::GMAXFACTOR] || pkmn[SCMovesetsData::GMAXFACTOR].nil?) && pokemon.hasGmax?
      pokemon.giveGMaxFactor 
    else 
      pokemon.removeGMaxFactor 
    end 
    
    # Give other details no one cares about.
    pokemon.ballused = pkmn[SCMovesetsData::BALL] if pkmn[SCMovesetsData::BALL]
    pokemon.happiness = (pkmn[SCMovesetsData::HAPPINESS] ? pkmn[SCMovesetsData::HAPPINESS] : 255)
    
    pokemon.calcStats
    
  end 
  
  return pokemon
end 



def scGetFittingZCrystals(pokemon, strict)
  # strict =  if "true", then ONLY return actual crystals that fit the pokemon
  #           (for the generation of movesets)
  #           if "false", then if the strict doesn't return any crystal, return 
  #           the whole list of crystals that would fit the species, regardless
  #           of their moves (for Team Builder).
  moves = []
  fspecies = 0 
  
  if pokemon.is_a?(PokeBattle_Pokemon)
    pokemon.moves.each { |m|
      moves.push(PokeBattle_Move.new(nil, m))
    }
    fspecies = pokemon.fSpecies
    
  else # It's an array. 
    for i in SCMovesetsData::MOVE1..SCMovesetsData::MOVE4
      next if !pokemon[i]
      move = pokemon[i]
      
      raise _INTL("Cannot use scGetFittingZCrystals on a non-finished moveset!") if move.is_a?(Array) && move.length > 1
      
      move = move[0] if move.is_a?(Array)
      pbmv = PBMove.new(move)
      moves.push(PokeBattle_Move.new(nil, pbmv))
    end 
    
    fspecies = pokemon[SCMovesetsData::FSPECIES]
  end 
  
  zmovecomps = pbLoadZMoveCompatibility
  
  potential_crystals = []
  all_available = [] # Only checks the species. 
  
  zmovecomps.each { |zcrystal, comps|
    next if zcrystal == "order"
    
    comps.each { |comp| 
      reqmove    = false
      reqtype    = false
      reqspecies = false
      
      # Checks type, if required.
      if comp[PBZMove::REQ_TYPE]
        for move in moves
          reqtype=true if move.type==comp[PBZMove::REQ_TYPE]
        end 
      else 
        reqtype = true 
      end 
      
      # Checks move, if required.
      if comp[PBZMove::REQ_MOVE]
        for move in moves
          reqmove=true if move.id==comp[PBZMove::REQ_MOVE]
        end
      else 
        reqmove = true
      end 
      
      # Checks for species, if required.
      if comp[PBZMove::REQ_SPECIES]
        reqspecies = true if comp[PBZMove::REQ_SPECIES] == fspecies
      else 
        reqspecies = true 
      end 
      
      all_available.push(zcrystal) if reqspecies
      
      if reqmove && reqtype && reqspecies
        potential_crystals.push(zcrystal)
        break 
      end 
    }
  }
  
  if potential_crystals.length == 0 
    if strict
      raise _INTL("{1} could not get a Z-crystal, this is weird!", PBSpecies.getName(fspecies))
    else 
      return all_available
    end 
  end 
  
  return potential_crystals
end 


