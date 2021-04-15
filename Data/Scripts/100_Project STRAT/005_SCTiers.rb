###############################################################################
# SCTier and co
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# Classes that handle tiers (list of authorised Pokémons, generation of valid 
# teams, team checking, some menuing for creation of teams, et ceatera). 
# Several tiers require more "hard-code", like Monotype and Bitype. 
###############################################################################



# =============================================================================
# SCTier 
# General class for tiers. General tiers should be instances of this instance. 
# Subclassing is required only when there is more than just lists of banned + 
# frequent + rare + allowed Pokémons. 
# Typically, Monotype will require more lists, because each type will have its 
# own list of allowed Pokémons (for complexity reasons, I prepared lists of 
# Pokémons per type, instead of checking the types on-the-fly). 
# =============================================================================
class SCTier 
	# Probability 0 of being chosen 
	attr_reader(:banned_pkmns)
	# High probability of being chosen
	attr_reader(:frequent_pkmns)
	# Low probability of being chosen (typically 0 to 2 per team)
	attr_reader(:rare_pkmns)
	# No probability of being chosen, but still allowed.
	attr_reader(:allowed_pkmns)
	# Banned items 
	attr_reader(:banned_items)
	# Banned moves 
	attr_reader(:banned_moves)
	# Banned abilities 
	attr_reader(:banned_abilities)
	# Name 
	attr_reader(:name)
	# id (short name)
	attr_reader(:id)
	# category 
	attr_reader(:category)
	# dictionary of species, by first letter.
	attr_reader(:dict_of_species)
  # This is an integer. For FE, should be 50.
  # This means that generated teams will have Pokémons with base stat total within a range of 50.
  # This allows for (kind of) balanced teams and should avoid having Tyranitar with Dunsparce. 
	attr_reader(:stratum_range)
	attr_reader(:stratum)
	attr_reader(:strata)
	
	
	def initialize(dictionary)
		@name = dictionary["Name"]
		@id = dictionary["ID"]
		@category = dictionary["Category"]
		@frequent_pkmns = dictionary["FrequentPokemons"]
		@allowed_pkmns = dictionary["AllowedPokemons"]
		@rare_pkmns = dictionary["RarePokemons"]
		@banned_pkmns = dictionary["BannedPokemons"]
		@banned_items = dictionary["BannedItems"]
		@banned_moves = dictionary["BannedMoves"]
		@banned_abilities = dictionary["BannedAbilities"]
    @allow_specific = dictionary["AllowSpecific"]
    @default_index_menu = 0 # Index in the stratum choice. 
    
    if dictionary["Stratum"]
      @stratum_range = dictionary["Stratum"]
      @stratum = 450
      @strata = nil
      chooseStratum(@stratum)
    else 
      @stratum_range = nil 
      @stratum = nil 
      @strata = nil 
    end 
    
		@dict_of_species = nil 
	end 
	
	
	# Just for extorior display, we don't need fully built teams.
	def fastRandSpecies(num_species)
		return scsample(@frequent_pkmns, num_species)
	end 
  
  
  # Stratum of base stats.
  # When the tier is crowded, allow for the use of a range of base stats, to 
  # prevent generating a team with Dunsparce and Tyranitar.
  def chooseStratum(new_stratum)
    return if !@stratum_range || ! @stratum
    data = scLoadStatTotals
    @strata = []
    data.each_pair { |bs, list_poke|
      @strata += list_poke if bs > new_stratum - @stratum_range && bs <= new_stratum + @stratum_range
    }
    @strata = nil if @strata.length < 14
  end 
	
  
  
	def randTeamSpecies2(type_of_team = -1, ask_stratum = false)
		# type_of_team:
		# if < 0: choose at random.
		# if = 0: Hyper Offense (Lead + 4 offensive + anything)
		# if = 1: Offensive (Lead + 3 offensive + 2 defensive)
		# if = 2: Balanced (Lead + 2 Offensive + 3 defensive)
		# if = 3: Defensive (Lead + Offensive + 4 defensive)
		# if = 4: Stall (5 defensive + Anything)
		
    if ask_stratum && @stratum
      # Then the player wants to choose. 
      @stratum = stratumMenu
      chooseStratum(@stratum)
    end 
    
		team_roles = [0, 0, 0, 0, 0, 0]
		
		# 0 = anything 
		# 1X = Lead 
		# 2X = Offensive 
		# 3X = Defensive 
		# 4X = Support 
		# X = 0 if any, 1 if physical, 2 if special, 3 if mixed
		# Notes: 
		# - Lead include Offensive (just in case the tier does not have enough Leads).
		# - Support include Defensive
		
		
		if type_of_team < 0 || type_of_team > 4
			type_of_team = rand(5)
		end 
		
		case type_of_team
		when 0 # Hyper Offense (Lead + 4 offensive + anything)
			team_roles = [10] + scsample([21, 21, 22, 22, 0], 5) # Shuffle the given list lol 
		when 1 # Offensive (Lead + 3 offensive + 2 defensive)
			team_roles = [10] + scsample([20, 21, 22, 31, 32], 5)
			# Note; if 10 and 20 are in the same team_roles, then the category will be different.
			# For example, if we pick a physical lead (then 10 turns to a 11), then we will take a
			# special offensive (then 20 turns to a 22). 
		when 2 # Balanced (Lead + 2 Offensive + 3 defensive)
			team_roles = [10] + scsample([21, 22, 31, 32, 40], 5)
		when 3 # Defensive (2 Offensive + 4 defensive)
			team_roles = scsample([21, 22, 31, 31, 32, 32], 6) 
		when 4 # Stall (5 defensive + Anything)
			team_roles = scsample([31, 31, 32, 32, 30, 0], 6) # Shuffle 
		end 
		
		for i in 0...6
			if team_roles[i] == nil
				raise _INTL("{1}-{2}-{3}-{4}-{5}-{6}", team_roles[0], team_roles[1], team_roles[2], team_roles[3], team_roles[4], team_roles[5])
			end 
		end 
		# Filter the pokémons per role. 
		# for each wanted role defined in team_roles, list all the pokémons that 
    # match this role. 
		# Normally, Random tiers shouldn't have problems of availability, as each 
    # tier should have enough both physical and special sweepers and defensive. 
		
		
		team_pkmns = []

		movesets = {} # movesets of the picked Pokemons
		
		movesetlog = scLoadMovesetsData
		
		list_poke = Array.new(@frequent_pkmns)
    list_poke = list_poke & @strata if @strata
		i = 0 
		# for i in 0...6
		while i < 6
			# Kernel.pbMessage(_INTL("i={1}", i))
			if i == 4
				list_poke = @frequent_pkmns + @rare_pkmns
        list_poke = list_poke & @strata if @strata
				# Rare only for the last two slots. 
			end 
			
			# Loop initialisation
			filtered_movesets = [] # List of movesets. 
			filtered_pokemons = []
			filtered_pokemons_roles = [] 
			choice_of_lead = 10 # Change to 11 if given a physical lead and expect a special sweeper to accompany it. 
			
      
			for pk in list_poke
				next if team_pkmns.include?(pk)
				
				# Check the movesets. 
				if !movesetlog.keys.include?(pk)
					raise _INTL("No moveset for {1}.", PBSpecies.getName(pk))
				end 
				
				for mv in movesetlog[pk][0]
					# mv = []
					
					# next if req_item && !mv[3].include?(req_item) # Wrong item.
					add_the_moveset = false 
					
					case team_roles[i]
					when 21, 22, 23, 31, 32, 33
						add_the_moveset = (mv[SCMovesetsData::ROLE] == team_roles[i])
						
					when 10 # Any lead
						# Leads include Offensive, but this will be handled later. 
						if [11, 12, 13].include?(mv[SCMovesetsData::ROLE])
							choice_of_lead = mv[SCMovesetsData::ROLE] # To remember if we gave a physical or special or mixed lead. 
							add_the_moveset = true 
						end 
						
					when 15 # We couldn't find a real lead, take an offensive mon. 
						if [21, 22, 23].include?(mv[SCMovesetsData::ROLE])
							choice_of_lead = mv[SCMovesetsData::ROLE] - 10 
							# They are supposed to be leads. 
							add_the_moveset = true 
						end 
						
					when 20 # Any offensive, except if we chose a specific lead. 
						if choice_of_lead == 11 && mv[SCMovesetsData::ROLE] == 22 
							# We gave a physical lead. Give a special offensive. 
							choice_of_lead = 10 
							add_the_moveset = true 
						elsif choice_of_lead == 12 && mv[SCMovesetsData::ROLE] == 21 
							# We gave a special lead. Give a physical offensive. 
							choice_of_lead = 10 
							add_the_moveset = true 
						elsif [21, 22, 23].include?(mv[SCMovesetsData::ROLE])
							add_the_moveset = true 
						end 
					when 30 # Any defensive 
						add_the_moveset = ([31, 32, 33].include?(mv[SCMovesetsData::ROLE]))
						
					when 40 # Any support 
						add_the_moveset = ([40, 41, 42, 43, 31, 32, 33].include?(mv[SCMovesetsData::ROLE]))
						
					when 0 # No condition, take any set. 
						add_the_moveset = true 
						
					end 
					
					if add_the_moveset
						filtered_pokemons.push(pk)
						filtered_pokemons_roles.push(mv[SCMovesetsData::ROLE])
						filtered_movesets.push(mv)
					end 
				end 
			end 
			
			if filtered_pokemons.empty?
				# Ah crap. No Pokémon were found for that given role. Probably the tier
        # is too shallow. But we don't need to warn the player about the wrong 
        # choices of tier made by the creator.
				# Let's quick fix this. 
				
				if team_roles[i] == 0
					# There were no movesets! This is a problem. 
					raise _INTL("Species {1} yielded no movesets!", PBSpecies.getName(pk))
				end 
				
				if team_roles[i] == 10
					# We couldn't find a lead. Try offensive. 
					team_roles[i] = 15 
				elsif team_roles[i] == 21 || team_roles[i] == 22 || team_roles[i] == 23
					# We couldn't find a specific offensive. Maybe try another offensive. 
					team_roles[i] = 20
				elsif team_roles[i] == 31 || team_roles[i] == 32 || team_roles[i] == 33
					# We couldn't find a specific defensive. Maybe try another defensive or support. 
					team_roles[i] = 40
				else 
					# We tried to replace the lead with an offensive.
					team_roles[i] = 0 
				end 
				
				i -= 1 
			else 
				# Choose a poke. 
				choice = rand(filtered_pokemons.length)
				
				team_pkmns.push(filtered_pokemons[choice])
				team_roles[i] = filtered_pokemons_roles[choice]
				movesets[i] = filtered_movesets[choice]
			end 
			
			i += 1 
		end 
		
		for i in 0...6
			if team_roles[i] == nil
				raise _INTL("{1}-{2}-{3}-{4}-{5}-{6}", team_roles[0], team_roles[1], team_roles[2], team_roles[3], team_roles[4], team_roles[5])
			end 
		end 
		
		
		return [team_pkmns, team_roles, movesets]
	end 
	
  
	def randTeamSpecies(team_filter = nil, ask_stratum = false)
    # type_of_team: nil, or constant of SCTeamFilters.
    team_filter = SCTeamFilters::Random if !team_filter
    stored_team_filter = team_filter
    
    # Type variations to make colorful teams.
    team_filter = team_filter.vary() if self.numFrequent() > 50 && !["MONO", "BI"].include?(@id)
    
    # team_filter = SCTeamFilters::Test1
    
    if ask_stratum && @stratum && stored_team_filter.is_a?(SCDummyTeamFilter)
      # Then the player wants to choose. 
      @stratum = stratumMenu
      chooseStratum(@stratum)
    end 
    
		team_roles = team_filter.getShuffledRoles()
    team_roles_clone = team_roles.clone
    allowed_errors = 0 
		team_generation_max_errors = 1
		# 0 = anything 
		# 1X = Lead 
		# 2X = Offensive 
		# 3X = Defensive 
		# 4X = Support 
		# X = 0 if any, 1 if physical, 2 if special, 3 if mixed
		# Notes: 
		# - Lead include Offensive (just in case the tier does not have enough Leads).
		# - Support include Defensive
		
		
		for i in 0...6
			if team_roles[i] == nil
				raise _INTL("{1}-{2}-{3}-{4}-{5}-{6}", team_roles[0], team_roles[1], team_roles[2], team_roles[3], team_roles[4], team_roles[5])
			end 
		end 
		# Filter the pokémons per role. 
		# for each wanted role defined in team_roles, list all the pokémons that 
    # match this role. 
		# Normally, Random tiers shouldn't have problems of availability, as each 
    # tier should have enough both physical and special sweepers and defensive. 
		
		
		team_pkmns = []

		movesets = {} # movesets of the picked Pokemons
		
		movesetlog = scLoadMovesetsData
		
		list_poke = Array.new(@frequent_pkmns)
    list_poke = list_poke & @strata if @strata && stored_team_filter.is_a?(SCDummyTeamFilter)
		i = 0 
    
    filtered_movesets = Array.new(6, Array.new(6, [])) # Index in role -> Index in filter -> list of movesets. 
    filtered_pokemons = Array.new(6, Array.new(6, []))
    filtered_pokemons_roles = Array.new(6, Array.new(6, []))
    
		while i < 6
			if i == 4
				list_poke = @frequent_pkmns + @rare_pkmns
        list_poke = list_poke & @strata if @strata
				# Rare only for the last two slots. 
			end 
			
			# Loop initialisation
			choice_of_lead = 10 # Change to 11 if given a physical lead and expect a special sweeper to accompany it. 
			
      previous_ind = []
      # pbMessage(_INTL("list_poke = {1}", list_poke.length))
			for pk in list_poke
				# next if team_pkmns.include?(pk)
        repartition = []
        f_movesets = {}
        f_pk = {}
        f_roles = {}
        specific = []
        team_filter.eachFittingMoveset(movesetlog, pk, team_roles[i], allowed_errors) do |mv, ind, filter|
          repartition.push(ind) if !repartition.include?(ind)
          specific.push(ind) if filter && filter.specific && !specific.include?(ind)
          
          f_movesets[ind] = [] if !f_movesets[ind]
          f_pk[ind] = [] if !f_pk[ind]
          f_roles[ind] = [] if !f_roles[ind]
          
          f_movesets[ind].push(mv)
          f_pk[ind].push(mv[SCMovesetsData::BASESPECIES])
          f_roles[ind].push(mv[SCMovesetsData::ROLE])
        end 
        
        next if repartition.length == 0 
        
        list_indices = (specific.length == 0 ? repartition : specific)
        
        # Give priority to empty spots. 
        indc = -1 
        for r in list_indices
          next if !filtered_movesets[i][r].empty?
          indc = r 
          break 
        end 
        # scLog(repartition)
        indc = scsample(list_indices, 1) if indc == -1 
        
        filtered_movesets[i][indc] += f_movesets[indc]
        filtered_pokemons[i][indc] += f_pk[indc]
        filtered_pokemons_roles[i][indc] += f_roles[indc]
			end 
      
      found_something = false
      for ind in 0...6
        if filtered_movesets[i][ind].length > 0
          found_something = true 
          break 
        end 
      end 
      # pbMessage(_INTL("i = {2}, role = {1}, Lengths = {3}-{4}-{5}-{6}-{7}-{8}", team_roles[i], i, 
        # filtered_pokemons_roles[i][0].length, filtered_pokemons_roles[i][1].length, 
        # filtered_pokemons_roles[i][2].length, filtered_pokemons_roles[i][3].length, 
        # filtered_pokemons_roles[i][4].length, filtered_pokemons_roles[i][5].length))
			
			if !found_something
        pbMessage("Coucou")
				# Ah crap. No Pokémon were found for that given role. Probably the tier
        # is too shallow. But we don't need to warn the player about the wrong 
        # choices of tier made by the creator.
				# Let's quick fix this. 
				
				if team_roles[i] == 0
          if allowed_errors > team_generation_max_errors
            if team_filter.name == "EMPTY"
              # There were no movesets! This is a problem. 
              raise _INTL("Team Filter {1} yielded no movesets for tier {2}!\n i = {3} and list_poke = {4}", team_filter.name, @name, i, list_poke.length)
            else 
              # Forget about the filter. Give a dummy pattern.
              team_filter = SCTeamFilter.new("EMPTY", team_roles_clone)
            end 
          else
            # Try again but allow movesets that do not perfectly fit the filter. 
            team_roles[i] = team_roles_clone[i]
            allowed_errors += 1
          end 
				end 
				
				if team_roles[i] == 10
					# We couldn't find a lead. Try offensive. 
					team_roles[i] = 15 
				elsif team_roles[i] == 21 || team_roles[i] == 22 || team_roles[i] == 23
					# We couldn't find a specific offensive. Maybe try another offensive. 
					team_roles[i] = 20
				elsif team_roles[i] == 31 || team_roles[i] == 32 || team_roles[i] == 33
					# We couldn't find a specific defensive. Maybe try another defensive or support. 
					team_roles[i] = 40
				else 
					# We tried to replace the lead with an offensive.
					team_roles[i] = 0 
				end 
			else 
        # Next. 
        i += 1 
			end 
		end 
    
    
    # I don't understand but the resulting filtered_movesets is just the first line repeated 6 times.
    # I can get rid of combinations for now. 
    
    # Start with the fewer movesets.
    chosen = []
    team_pkmns = Array.new(6)
    
    while chosen.length < 6
      min_i = 0
      min_mvsts = 100000
      
      for i in 0...6
        next if chosen.include?(i)
        min_i, min_mvsts = i, filtered_movesets[0][i].length if filtered_movesets[0][i].length < min_mvsts
      end 
      
      choice = rand(min_mvsts)
      
      team_pkmns[min_i] = filtered_pokemons[0][min_i][choice]
      team_roles[min_i] = filtered_pokemons_roles[0][min_i][choice]
      movesets[min_i] = filtered_movesets[0][min_i][choice]
      
      if !team_roles[min_i]
        raise diagnoseEmpty(team_filter, filtered_movesets)
        raise _INTL("min_mvsts = {1}, pokemon = {2}, moveset = {3}", min_mvsts, team_pkmns[min_i], movesets[min_i])
      end 
      
      chosen.push(min_i)
      
      
      # Now avoid repeating the Pokémons.
      for i in 0...6
        filtered_pokemons[0][i] = [] if i == min_i
        
        new_filtered_pokemons = []
        new_filtered_pokemons_roles = []
        new_filtered_movesets = []
        
        for m in 0...filtered_pokemons[0][i].length
          if filtered_pokemons[0][i][m] != team_pkmns[min_i]
            new_filtered_pokemons.push(filtered_pokemons[0][i][m])
            new_filtered_pokemons_roles.push(filtered_pokemons_roles[0][i][m])
            new_filtered_movesets.push(filtered_movesets[0][i][m])
          end 
        end 
        filtered_pokemons[0][i] = new_filtered_pokemons
        filtered_pokemons_roles[0][i] = new_filtered_pokemons_roles
        filtered_movesets[0][i] = new_filtered_movesets
      end 
    end 
    
    
    # # Now, we have arrays Index in role -> Index in filter -> list of movesets. 
    # # It's a 6x6 matrix with possibly some empty cells. 
    # # List all available combinations (I don't know better)
    # comb = Array.new(6) { |i| i }
    # combinations = []
    
    # # Try a few combinations. 
    # for xxx in 0...20
      # comb = scsample(comb, -1)
      # try_next = false 
      # for i in 0...6
        # if filtered_movesets[comb[i]][i].length == 0
          # try_next = true
          # break
        # end 
      # end 
      # next if try_next
      
      # combinations.push(comb.clone)
    # end 
    
    # if combinations.length == 0
      # # Exhaustive enumeration. Not complexity friendly. 
      # $PokemonTemp.eachCombination do |c| 
        # try_next = false 
        # for i in 0...6
          # if filtered_movesets[c[i]][i].length == 0
            # try_next = true
            # break
          # end 
        # end 
        # next if try_next
        
        # combinations.push(c)
      # end 
    # end 
    
    
    # comb = combinations[rand(combinations.length)]
    
    # begin 
    # for i in 0...6
      # # Choose a poke. 
      # choice = 0 
      # for j in 0...10
        # choice = rand(filtered_pokemons[comb[i]][i].length)
        # break if !team_pkmns.include?(filtered_pokemons[comb[i]][i][choice])
      # end 
      # team_pkmns.push(filtered_pokemons[comb[i]][i][choice])
      # team_roles[i] = filtered_pokemons_roles[comb[i]][i][choice]
      # movesets[i] = filtered_movesets[comb[i]][i][choice]
      # # for k in 0..5
        # # scLog(scConvertMovesetToString(filtered_movesets[comb[i]][i][k]))
        # # scLog("========================================================")
      # # end 
    # end 
    
    # rescue 
      # raise diagnoseEmpty(team_filter, filtered_movesets, comb)
    # end 
    
		for i in 0...6
			if team_roles[i] == nil
				raise _INTL("{1}-{2}-{3}-{4}-{5}-{6}", team_roles[0], team_roles[1], team_roles[2], team_roles[3], team_roles[4], team_roles[5])
			end 
		end 
		
		
		return [team_pkmns, team_roles, movesets]
	end 
	
  
  def diagnoseEmpty(team_filter, filtered_movesets)#, comb)
    s = _INTL("Team Filter: {1} yielded no movesets.\n", team_filter.name)
    s += "filtered_movesets = \n"
    
    for i in 0...6
      for j in 0...6
        s += _INTL("{1}", filtered_movesets[i][j].length)
        s += "  " if j < 5
      end
      s += "\n"
    end 
    # s += "comb = " + scToStringRec(comb)
    
    return s 
  end 
  
  
	
  def stratumMenu
		list_strata = [600, 550, 500, 450, 400]
    list_strata_str = ["Very strong", "Strong", "Medium", "Weak", "Very weak"]
    
		cmd = pbMessage("How strong do you want your team?", list_strata_str, -1, nil, @default_index_menu)
		
		if cmd > -1 
      @default_index_menu = cmd 
			return list_strata[cmd]
		end 
		
		return list_strata[1]
  end 
  
  
	
	def isValid(party)
		valid = true 
		report = []
		
    if party.length != 6
      valid = false 
      report.push(_INTL("Your party doesn't have the right number of Pokémon: {1}.", party.length))
    end 
    
		for pk in party
			if @banned_pkmns.include?(pk.fSpecies)
				valid = false 
				report.push(_INTL("Pokémon {1} is not allowed.", PBSpecies.getName(pk.fSpecies)))
			end 
			if @banned_items.include?(pk.item)
				valid = false 
				report.push(_INTL("Item {1} on {2} is not allowed.", PBItems.getName(pk.item), PBSpecies.getName(pk.species)))
			end 
			if @banned_abilities.include?(pk.ability)
				valid = false 
				report.push(_INTL("Ability {1} on {2} is not allowed.", PBAbilities.getName(pk.ability), PBSpecies.getName(pk.species)))
			end 
			for m in pk.moves
				if @banned_moves.include?(m.id)
					valid = false 
					report.push(_INTL("Move {1} on {2} is not allowed.", PBMoves.getName(m.id), PBSpecies.getName(pk.species)))
				end 
			end 
		end 
		return [valid, report]
	end 
	
	
	
	def partyListIsValid(party_list)
		# Works a bit differently; it's for SCTeamBuildingMenu, 
		# where pk is a list, and not a PokeBattle_Pokemon!
		valid = true 
		report = []
		
		for pk in party_list
			# No species defined. 
			next if !pk[SCMovesetsData::SPECIES]
			
			species_name = PBSpecies.getName(pk[SCMovesetsData::SPECIES])
			# for i in 0...pk.length
				# Kernel.pbMessage(_INTL("pk[{1}]={2}", i, pk[i]))
			# end 
			
			form_species = pbGetFSpeciesFromForm(pk[SCMovesetsData::BASESPECIES], pk[SCMovesetsData::FORM])
      
			if @banned_pkmns.include?(form_species)
				report.push(_INTL("Pokémon {1} in form {2} is not allowed.", 
          species_name, pk[SCMovesetsData::FORM].to_s))
			end 
			if @banned_items.include?(pk[SCMovesetsData::ITEM])
				report.push(_INTL("Item {1} on {2} is not allowed.", 
          PBItems.getName(pk[SCMovesetsData::ITEM]), species_name))
			end 
			
			# Check ability ffs it's so stupid how it's handled. 
			if @banned_abilities.include?(pk[SCMovesetsData::ABILITY])
				valid = false 
				report.push(_INTL("Ability {1} on {2} is not allowed.", PBAbilities.getName(pk[SCMovesetsData::ABILITY]), species_name))
			end 
			
			# raise _INTL("{1} num 9 => {2}", pk[0], pk[9])
			for m in SCMovesetsData::MOVE1..SCMovesetsData::MOVE4
				if @banned_moves.include?(pk[m])
					valid = false 
					report.push(_INTL("Move {1} on {2} is not allowed.", PBMoves.getName(pk[m]), species_name))
				end 
			end 
		end 
		return [valid, report]
	end 
	
	
	
	def formIsInArray(pk, ary_species, ary_pkmns)
		# I don't know what this does ????
		valid = false 
		
		for i in 0...ary_species.length 
			next if ary_species[i] != pk[0]
			
			form_stuff = ary_pkmns[i]
			valid = true 
			
			for d in 0...form_stuff.length 
				if form_stuff[d] == "form"
					valid = valid && form_stuff[d+1] == pk[12][0]
				elsif form_stuff[d] == "gender"
					valid = valid && form_stuff[d+1] == pk[3]
				elsif form_stuff[d] == "abil"
					valid = valid && form_stuff[d+1] == pk[4]
				elsif form_stuff[d] == "item"
					valid = valid && form_stuff[d+1] == pk[5]
				end 
			end 
			
			return true if valid 
		end 
		
		return false  
	end 
	
	
	
	def filterItems(items)
		filtered_items = []
		
		for i in items
			filtered_items.push(i) if not @banned_items.include?(i)
		end 
		
		return filtered_items
	end 
	
	
	
	def numAllowed()
		return @allowed_pkmns.length + @frequent_pkmns.length + @rare_pkmns.length
	end 
	
	
  
  def numFrequent()
    return @frequent_pkmns.length
  end 
  
  
	
	def numBanned()
		return @banned_pkmns.length 
	end 
	
	
	
	def isAllowed(species, form=0)
		# Two cases : 1. species is already a form ID, 2. species + form. 
		
    species = pbGetFSpeciesFromForm(species,form)
		
		return @frequent_pkmns.include?(species) || 
			@rare_pkmns.include?(species) || @allowed_pkmns.include?(species)
	end 
	
	
	
	def alphabeticSpecies()
		if @dict_of_species != nil 
			return @dict_of_species
		end 
		
		alphabet = ["A","B","C","D","E","F",
					"G","H","I","J","K","L",
					"M","N","O","P","Q","R",
					"S","T","U","V","W","X",
					"Y","Z"]
		
		@dict_of_species = {}
		
		for letter in alphabet
			for sp in @frequent_pkmns + @rare_pkmns + @allowed_pkmns
				l = PBSpecies.getName(sp)
				# l = pbGetMessage(MessageTypes::Species,sp,true)
				# Kernel.pbMessage(_INTL("letter={3}, l[0]={1}, pk={2}", l[0,1], l, letter))
				if l[0,1] == letter
					if @dict_of_species.keys.include?(letter)
						@dict_of_species[letter].push(sp)
					else 
						@dict_of_species[letter] = [sp]
					end 
				end 
			end
		end 
		
		return @dict_of_species
	end 
end 



# =============================================================================
# SCMonotypeTier 
# Special class for the Monotype tier. Along with the list of banned/allowed/
# rare/frequent Pokémons, there is a list of Pokémons per type + the 
# generation of teams needs this. 
# =============================================================================
class SCMonotypeTier < SCTier
	# Dictionary to store the list of Pokémons per type. 
	attr_reader(:pkmns_per_type)
	
	
	
	def initialize(dictionary)
		super(dictionary)
		# dictionary should contain keys of the form TypeXXXXX 
		# where XXXXX is a type (one list per type).
		@pkmns_per_type = {} 
		
		# In practice, I am probably only using one Monotype tier, 
		# based on the FE tier, but I leave the opportunity to change my mind. 
		for key in dictionary.keys
			if key[0...5] == "Type:"
				t = getConst(PBTypes,key[5..-1])
				@pkmns_per_type[t] = dictionary[key]
			end 
		end 
		@untyped_frequent_pkmns = Array.new(@frequent_pkmns)
		@untyped_rare_pkmns = Array.new(@rare_pkmns)
	end 
	
	
	
	def fastRandSpecies(num_species)
		# Choose a type, before choosing the species. 
		wanted_type = scsample(@pkmns_per_type.keys, 1)
		
		@frequent_pkmns = @untyped_frequent_pkmns & @pkmns_per_type[wanted_type]
		species_list = 	super(num_species)
		@frequent_pkmns = @untyped_frequent_pkmns
		
		return species_list
	end 
	
	
	
	def randTeamSpecies(wanted_type = -1, type_of_team = -1) 
    # Choose a type before choosing the team. 
		if wanted_type == nil
			wanted_type = self.menu 
			# nil = give a chance to choose. 
		end 
		
		# If no type is given, then choose a random type. 
		if wanted_type == nil or wanted_type < 0
			warn_player = (wanted_type == nil)
			wanted_type = scsample(@pkmns_per_type.keys, 1)
			Kernel.pbMessage(_INTL("Choosen type: {1}.", PBTypes.getName(wanted_type))) if warn_player
		end 
		
    # pbMessage(_INTL("@pkmns_per_type length: is {1}", @pkmns_per_type.keys.length))
		@frequent_pkmns = @untyped_frequent_pkmns & @pkmns_per_type[wanted_type]
		@rare_pkmns = @untyped_rare_pkmns & @pkmns_per_type[wanted_type]
		
		res = super(type_of_team)
		
		@frequent_pkmns = @untyped_frequent_pkmns
		@rare_pkmns = @untyped_rare_pkmns 
		
		return res 
	end 
	
	
	
	def findType(party)
		# Finds the type of this Monotype party. 
		list_species = []
		
		for pkmn in party
			list_species.push(pkmn.species)
		end 
		
		for t in @pkmns_per_type.keys
			# Intersection. 
			inter = @pkmns_per_type[t] & list_species
			if inter.length == list_species.length 
				return t
			end 
		end 
		
		return nil 
	end 
	
	
	
	def isValid(party)		
		# Checks if the party is a Monotype, and then checks the banned moves and such. 
		if findType(party) == nil 
			return [false, "The given party is not a Monotype!"]
		end 
		
		return super(party)
	end 
	
	
	
	def partyListFindType(party_list)
		# Finds the type of this Monotype party. 
		list_species = []
		
		for pkmn in party_list
      sp = pbGetFSpeciesFromForm(pkmn[SCMovesetsData::SPECIES], pkmn[SCMovesetsData::FORM])
			list_species.push(sp)
		end 
		
		for t in @pkmns_per_type.keys
			# Intersection. 
			inter = @pkmns_per_type[t] & list_species
			if inter.length == list_species.length 
				return t
			end 
		end 
		
		return nil 
	end 
	
	
	
	def partyListIsValid(party_list)
		# Checks if the party is a Monotype, and then checks the banned moves and such. 
		if partyListFindType(party_list) == nil
			return [false, "The given party is not a Monotype!"]
		end 
		
		return super(party_list)
	end 
	
	
	
	def partyHasType(party, type)
		# Checks if the party has the given type. 
		list_species = []
		
		for pkmn in party
			list_species.push(pkmn.fSpecies)
		end 
		
		# Intersection. 
		inter = @pkmns_per_type[type] & list_species
		
		return inter.length == list_species.length 
	end 
	
	
	
	def menu
		# First, choose the type before making the team. 
		list_types = ["Bug", "Dark", "Dragon", "Electric", "Fairy", 
				"Fighting", "Fire", "Flying", "Ghost", "Grass", 
				"Ground", "Ice", "Normal", "Poison", "Psychic", 
				"Rock", "Steel", "Water"]
		
		cmd = Kernel.pbMessage("Which type do you want?", list_types, -1)
		
		if cmd > -1 
			return getConst(PBTypes,list_types[cmd].upcase)
		end 
		
		return nil 
	end 
end 




# =============================================================================
# SCPersonalisedTier - DEPRECATED
# Special class for the tier on-the-fly. Along with the list of banned/allowed
# /rare/frequent Pokémons, there is a list of Pokémons per "big tier". It's an 
# attempt to allow the player to design their own tier. 
# =============================================================================
class SCPersonalisedTier < SCTier
	# tiers "On-The-Fly" - DEPRECATED
	
	def initialize(dictionary)
		super(dictionary)

		# The code: 
		# 0 = banned
		# 1 = allowed but almost never to be seen (allowed for player, but NPC will never have them)
		# 2 = allowed but rare 
		# 3 = allowed but common (the main POkémons of the tier)
		@personalised_data = {}
		@personalised_data["FullyEvolved"] = [3, dictionary["FullyEvolved"]]
		@personalised_data["NotFullyEvolved"] = [0, dictionary["NotFullyEvolved"]]
		@personalised_data["LittleCup"] = [0, dictionary["LittleCup"]]
		@personalised_data["Legendary"] = [0, dictionary["Legendary"]]
		@personalised_data["StrongLegendary"] = [0, dictionary["StrongLegendary"]]
		@personalised_data["Delta"] = [0, dictionary["Delta"]]
		@personalised_data["Variant"] = [0, dictionary["Variant"]]
		
		@main_defined = false 
		
		decodeGV203
		 
	end 
	
	
	
	def encodeGV203
		# In order to have a "clean" project, I prefer to store a number in $game_variables. 
		# Thus, I encode the tier composition in an integer, a bit like you encode logical 
		# proofs in the Godel encoding. 
		# Note: this is not a Godel encoding.
		
		fe = @personalised_data["FullyEvolved"][0] * 1000000
		nfe = @personalised_data["NotFullyEvolved"][0] * 100000
		lc = @personalised_data["LittleCup"][0] * 10000
		lg = @personalised_data["Legendary"][0] * 1000
		sl = @personalised_data["StrongLegendary"][0] * 100
		de = @personalised_data["Delta"][0] * 10
		var = @personalised_data["Variant"][0]
		
		# Note: Int maximum for 32 bits is around 2x10^9
		$game_variables[203] = fe + nfe + lc + lg + sl + de + var 
	end 
	
	
	
	def decodeGV203
		# See previous function for the encoding. 
		
		code = $game_variables[203]
		
		if !code or code == 0
			# it's unitialised.
			encodeGV203
		end 
		
		fe = (code / 1000000).to_i
		
		temp = code % 1000000
		nfe = (temp / 100000).to_i
		
		temp = temp % 100000
		lc = (temp / 10000).to_i
		
		temp = code % 10000
		lg = (temp / 1000).to_i
		
		temp = code % 1000
		sl = (temp / 100).to_i
		
		temp = code % 100
		de = (temp / 10).to_i
		
		var = code % 10
		
		if not [fe, nfe, lc, lg, sl, de, var].include?(3)
			fe = 3 
			encodeGV203
		end 
		
		@personalised_data["FullyEvolved"][0] = fe 
		@personalised_data["NotFullyEvolved"][0] = nfe 
		@personalised_data["LittleCup"][0] = lc 
		@personalised_data["Legendary"][0] = lg
		@personalised_data["StrongLegendary"][0] = sl
		@personalised_data["Delta"][0] = de 
		@personalised_data["Variant"][0] = var
		
		update
	end 
	
	
	
	def update
		@main_defined = false 
		
		@frequent_pkmns = [] 
		@allowed_pkmns = []
		@rare_pkmns = []
		@banned_pkmns = []
		
		# blabla = "" 
		
		
		for key in @personalised_data.keys
			# if  @personalised_data[key][1].is_a?(Fixnum)
				# blabla += _INTL(key + " is a Fixnum: {1} ", @personalised_data[key][1])
				# next 
			# end 
			case @personalised_data[key][0]
			when 0
				@banned_pkmns += @personalised_data[key][1]
			when 2
				@rare_pkmns += @personalised_data[key][1]
			when 3
				@frequent_pkmns += @personalised_data[key][1]
				@main_defined = true 
			else 
				@allowed_pkmns += @personalised_data[key][1]
			end 
		end 
		
		
		# if @frequent_pkmns.length == 0
		# raise _INTL("@frequent_pkmns.length = {1}", @frequent_pkmns.length)
		# end 
		# if blabla != ""
			# raise blabla
		# end 
	end 
	
	# The code: 
	# 0 = banned
	# 1 = allowed but almost never to be seen (allowed for player, but NPC will never have them)
	# 2 = allowed but rare 
	# 3 = allowed but common (the main POkémons of the tier)
	def allowCategory(class_name)
		@personalised_data[class_name] = 1 
	end 
	
	
	
	def makeCategoryRare(class_name)
		@personalised_data[class_name] = 2
	end 
	
	
	
	def makeCategoryFrequent(class_name)
		@personalised_data[class_name] = 3 
	end 
	
	
	
	def banCategory(class_name)
		@personalised_data[class_name] = 0
	end 
	
	
	
	def menu 
		list_categories = ["Fully evolved", "Not fully evolved", "Little cup", 
					"Legendary", "Strong legendary", "Delta species", "Variants"]
			
		list_keys = ["FullyEvolved", "NotFullyEvolved", "LittleCup", 
					"Legendary", "StrongLegendary", "Delta", "Variant"]
			
		list_allowed = ["Main", "Rare", "Allowed", "Banned", "Cancel"]
		
		cat = 0 
		
		
		while cat > -1
			cat = Kernel.pbMessage("Select a category.", list_categories, -1, nil, 0)
			
			if cat > -1
				msg = "What to do with the category " + list_categories[cat] + "?"
				allow = Kernel.pbMessage(msg, list_allowed, -1, nil, 0)
				
				if allow > -1 and allow < 4
					@personalised_data[list_keys[cat]][0] = 3 - allow 
					Kernel.pbMessage(list_categories[cat] + " are " + list_allowed[allow] + ".")
					update 
				end 
			end 
		end 
		
		if not @main_defined
			@personalised_data["FullyEvolved"][0] = 3 
			Kernel.pbMessage("There is no category defined as Main.")
			Kernel.pbMessage("Fully evolved Pokémons are set to Main.")
		end 
		
		# summary = []
		
		# for i in 0...list_categories.length
			# allow = @personalised_data[list_keys[i]][0]
			# Kernel.pbMessage(list_categories[i] + " are " + list_allowed[3 - allow])
		# end 
		for i in 0...list_allowed.length - 1
			allowed = []
			
			for k in @personalised_data.keys()
				if 3 - i == @personalised_data[k][0]
					allowed.push(k)
				end 
			end 
			if allowed.empty?
				Kernel.pbMessage(list_allowed[i] + ": None")
			else 
				msg = "" 
				for j in 0...allowed.length - 1
					msg += allowed[j] + ", "
				end 
				
				msg += allowed[allowed.length-1]
				
				Kernel.pbMessage(list_allowed[i] + ": " + msg)
			end 
		end 
		
		encodeGV203
	end 
end 



# =============================================================================
# SCBitypeTier 
# Special class for the Bitype tier. Along with the list of banned/allowed/
# rare/frequent Pokémons, there is a list of Pokémons per pair of types. 
# =============================================================================
class SCBitypeTier < SCTier
	# Matrix types x types => list of Pokémons. 
	attr_reader(:pkmns_bitype)
	
	
	
	def initialize(dictionary)
		super(dictionary)
		@pkmns_bitype = {} 
		@pkmns_bitype_len = {}
		@enough_pkmns = 15 # The minimum number of Pokemons per bitype for random generation. 
		@rich_bitypes = [] # All the bi-types with enough pokemons (number > @enough_pkmns)
		
		# In practice, I am probably only using one Monotype tier, 
		# based on the FE tier, but I leave the opportunity to change my mind. 
		for key in dictionary.keys
			if key[0...5] == "Type:"
				two_types = key[5..-1].split(",")
				t1 = getConst(PBTypes,two_types[0])
				t2 = getConst(PBTypes,two_types[1])
				@pkmns_bitype[t1] = {} if !@pkmns_bitype.keys.include?(t1)
				@pkmns_bitype_len[t1] = {} if !@pkmns_bitype_len.keys.include?(t1)
				@pkmns_bitype[t1][t2] = dictionary[key]
				@pkmns_bitype_len[t1][t2] = dictionary[key].length
				
				if @enough_pkmns < @pkmns_bitype_len[t1][t2]
					@rich_bitypes.push([t1, t2])
				end 
				# raise _INTL("Choosen bi-type: {1} + {2}.", PBTypes.getName(t1), PBTypes.getName(t2))
			end 
		end 
		@untyped_frequent_pkmns = Array.new(@frequent_pkmns)
		@untyped_rare_pkmns = Array.new(@rare_pkmns)
	end 
	
	
	
	def fastRandSpecies(num_species)
		# Choose two types before choosing the Pokémons. 
		wanted_types = scsample(@rich_bitypes, 1)
		type1 = wanted_types[0]
		type2 = wanted_types[1]
		
		@frequent_pkmns = @untyped_frequent_pkmns & @pkmns_bitype[type1][type2]
		species_list = 	super(num_species)
		@frequent_pkmns = @untyped_frequent_pkmns
		
		return species_list
	end 
	
	
	
	def randTeamSpecies(type1 = -1, type2 = -1, type_of_team = -1)
		# Choose the two types before choosing the team. 
		if type1 == nil || type2 == nil 
			wanted_types = self.menu 
			type1 = wanted_types[0]
			type2 = wanted_types[1]
			# nil = give a chance to the player to choose. 
		end 
		
		
		if type2 == nil || type2 < 0
			warn_player = (type1 == nil || type2 == nil)
			
			if type1 == nil || type1 < 0
				wanted_types = scsample(@rich_bitypes, 1)
				type1 = wanted_types[0]
				type2 = wanted_types[1]
			else # type1 was chosen. 
				# Choose only the bi-types with enough pokemons. 
				constrained_second_types = []
				
				for pair in @rich_bitypes
					constrained_second_types.push(pair[1]) if pair[0] == type1
				end 
				
				type2 = scsample(constrained_second_types, 1)
			end 
			
			Kernel.pbMessage(_INTL("Choosen bi-type: {1} + {2}.", PBTypes.getName(type1), PBTypes.getName(type2))) if warn_player
		end 
		
		if @untyped_frequent_pkmns == nil 
			raise _INTL("untyped_frequent_pkmns is nil")
		end 
		if @untyped_rare_pkmns == nil 
			raise _INTL("untyped_rare_pkmns is nil")
		end 
		if @pkmns_bitype == nil 
			raise _INTL("pkmns_bitype is nil")
		end 
		if @pkmns_bitype[type1] == nil 
			raise _INTL("pkmns_bitype[type1] is nil")
		end 
		if @pkmns_bitype[type1][type2] == nil 
			raise _INTL("@pkmns_bitype[type1][type2] is nil")
		end 
		
		@frequent_pkmns = @untyped_frequent_pkmns & @pkmns_bitype[type1][type2]
		@rare_pkmns = @untyped_rare_pkmns & @pkmns_bitype[type1][type2]
		
		res = super(type_of_team)
		
		@frequent_pkmns = @untyped_frequent_pkmns
		@rare_pkmns = @untyped_rare_pkmns 
		
		return res 
	end 
	
	
	
	def findTypes(party)
		# Finds the double-type of this Bitype party. 
		list_species = []
		
		for pkmn in party
			list_species.push(pkmn.species)
		end 
		
		for type1 in @pkmns_bitype.keys
			for type2 in @pkmns_bitype[type1].keys
				# Intersection. 
				inter = @pkmns_bitype[type1][type2] & list_species
				if inter.length == list_species.length 
					return [type1, type2]
				end
			end 
		end 
		
		return nil 
	end 
	
	
	
	def isValid(party)
		# Checks if the party is a Bitype, and then checks the banned moves and such. 
		if findTypes(party) == nil 
			return [false, "The given party is not a Bitype!"]
		end 
		
		return super(party)
	end 
	
	
	
	def partyListFindType(party)
		# Finds the double-type of this Bitype party. 
		list_species = []
		
		for pkmn in party
      sp = pbGetFSpeciesFromForm(pkmn[SCMovesetsData::BASESPECIES], pkmn[SCMovesetsData::FORM])
			list_species.push(sp)
		end 
		
		for type1 in @pkmns_bitype.keys
			for type2 in @pkmns_bitype[type1].keys
				# Intersection. 
				inter = @pkmns_bitype[type1][type2] & list_species
				if inter.length == list_species.length 
					return [type1, type2]
				end
			end 
		end 
		
		return nil 
	end 
	
	
	
	def partyListIsValid(party_list)
		# Checks if the party is a Bitype, and then checks the banned moves and such. 
		if partyListFindType(party_list) == nil
			return [false, "The given party is not a Bitype!"]
		end 
		
		return super(party_list)
	end 
	
	
	
	def partyHasTypes(party, type1, type2)
		# Checks if the party has the given types. 
		list_species = []
		
		for pkmn in party
			list_species.push(pkmn.fSpecies)
		end 
		
		# Intersection. 
		inter = @pkmns_bitype[type1][type2] & list_species
		
		return inter.length == list_species.length 
	end 
	
	
	
	def menu
		list_types = ["Random", "Bug", "Dark", "Dragon", "Electric", 
					"Fairy", "Fighting", "Fire", "Flying", "Ghost", 
					"Grass", "Ground", "Ice", "Normal", "Poison", 
					"Psychic", "Rock", "Steel", "Water"]
		
		cmd = Kernel.pbMessage("Choose the first type of your team.", list_types, -1)

		if cmd > 0
			type1 = getConst(PBTypes,list_types[cmd].upcase)
			list_types2 = []
			
			for tt in list_types
				list_types2.push(tt) if tt != list_types[cmd]
			end 
			
			cmd = Kernel.pbMessage("Choose the second type of your team.", list_types2, -1)
			
			if cmd > 0
				return [type1, getConst(PBTypes,list_types2[cmd].upcase)]
			else 
				return [type1, nil]
			end 
		end 
		
		return [nil, nil] 
	end 
end 




# =============================================================================
# Functions
# =============================================================================

class PokemonTemp
  attr_accessor :current_tier
end 


def loadTier(tierid)
	# Loads the tier from the compiled file. 
	# Stores a SCTier (or subclass) instance in PokémonTemp, and returns it. 
  
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  
  if !$PokemonTemp.current_tier || $PokemonTemp.current_tier.id != tierid
    $PokemonTemp.current_tier = loadTierNoStorage(tierid)
  end
  
  return $PokemonTemp.current_tier
end 



def loadTierNoStorage(tierid)
	# Loads the tier from the compiled file. 
	# Returns a class. 
  
  if tierid.is_a?(Array)
    # We assume it's a list of Pokémons. 
    dictionary = {}
		
		dictionary["Name"] = "Temp"
		dictionary["ID"] = "TEMP"
		dictionary["Category"] = "Temporary"
		dictionary["FrequentPokemons"] = tierid
		dictionary["AllowedPokemons"] = []
		dictionary["RarePokemons"] = []
		dictionary["BannedPokemons"] = []
		dictionary["BannedItems"] = []
		dictionary["BannedMoves"] = []
		dictionary["BannedAbilities"] = []
		
		return SCTier.new(dictionary)
  end 
  
  tier_dict = scLoadTierData
  
  if !tier_dict.key?(tierid)
    raise _INTL("{1} is not a tier!", tierid)
  end 
  
  case tierid
  when "MONO"
    tier =  SCMonotypeTier.new(tier_dict[tierid])
  when "BI"
    tier = SCBitypeTier.new(tier_dict[tierid])
  when "OTF"
    tier = SCPersonalisedTier.new(tier_dict[tierid])
  else 
    tier = SCTier.new(tier_dict[tierid])
  end 
  
  return tier 
end 




def trainerPartyIsValid
  # Checks if the party of the player is valid for the current tier.
  return isValidForTier($Trainer.party, false, nil)
end 



def trainerPartyFitsCurrentTier
  return scGetTierOfTeam() == scGetTier()
end 



def isValidForTier(party, show_messages, tierid = nil)
	# Checks if the given party is valid for the given tierid.
  tierid = scGetTier() if !tierid
	tier = loadTier(tierid)
	
	res = tier.isValid(party)
	
	if show_messages
		if res[0]
			pbMessage("The team is valid.")
		else
			for explanation in res[1]
				pbMessage(explanation)
			end 
		end 
	end 
	
	return res[0]
end 



def partyListIsValidForTier(party_list, show_messages, tierid = nil)
	# Checks if the given party is valid for the given tierid.
  tierid = scGetTier() if !tierid
	tier = loadTier(tierid)
	
	res = tier.partyListIsValid(party_list)
	
	if show_messages
		if res[0]
			Kernel.pbMessage("The team is valid.")
		else
			for explanation in res[1]
				Kernel.pbMessage(explanation)
			end 
		end 
	end 
	
	return res[0]
end 

















