
def scSetTier(tier, forced)
	all_tiers = load_data("Data/sctiers.dat")
	
	if not all_tiers.keys.include?(tier)
		raise _INTL("Given tiers \"{1}\" was set but does not exist.", tier)
	end 
	
	setBattleRule("tier", tier)
  if forced
    setBattleRule("forceTier")
    # forced tier: for narrative reasons, don't allow the tier to be altered. 
  else 
    setBattleRule("unforceTier")
  end 
end 



def isNuzzlocke()
  return ($PokemonTemp.battleRules["nuzzlocke"] != nil &&  $PokemonTemp.battleRules["nuzzlocke"])
end 

def scUnforceTier()
  setBattleRule("unforceTier")
	# The tier is not forced anymore. 
end 




def scGetTier(simple = true)
  $PokemonTemp.battleRules["tier"] = "FE" if !$PokemonTemp.battleRules["tier"]
  
  return $PokemonTemp.battleRules["tier"] if simple 
	return [$PokemonTemp.battleRules["tier"], $PokemonTemp.battleRules["forcedTier"]]
	# Current tier ID + is it forced (for narrative reasons)
end 


#----------------------------------------------------------
# Menu function to select the current tier. 
#----------------------------------------------------------
def scSelectTierMenu
	current_tier = scGetTier(false)
	
	if current_tier[1]
		# Tiers is forced for narrative reasons.
		pbMessage(_INTL("The tier of your previous client was {1}.", current_tier[0])) if scClientBattles.battleIsDone
		pbMessage(_INTL("The tier of your next client is {1}.", current_tier[0])) if !scClientBattles.battleIsDone
		pbMessage(_INTL("You cannot change tier now."))
		
		return current_tier[0]
	end 
	
	
	tiers = load_data("Data/sctiers.dat")
	
	
	tiers_cats = {} 
	# dictionary category -> list of tier IDs 
	tiers_cats_names = {}
	# dictionary category -> list of tier names. 
	
	# Load the tiers. 
	for t in tiers["TierList"]
		t_name = tiers[t]["Name"]
		
		cat = tiers[t]["Category"]
		
		# if (cat != "Random" && cat != "Micro-tier") or scTOTDHandler.was_totd(t)
		if true
			# Add a Random tier only if it was Tier of the Day. (?)
      if !tiers_cats[cat]
        tiers_cats[cat] = []
        tiers_cats_names[cat] = []
      end
      
      tiers_cats[cat].push(t)
      tiers_cats_names[cat].push(t_name)
		end 
	end
	
	
	for c in tiers_cats.keys
		tiers_cats[c] = tiers_cats[c].sort 
	end 
	
	# Special treatment for random tiers : gather them by stats. 
	random_tiers = {}
	random_tiers_keys = []
	
	for rand_tier in tiers_cats["Random"]
		rand_section = "Base stats " + rand_tier[4..6] # RANDXXX-YY => Base stats XXX
		random_tiers_keys.push(rand_section) if !random_tiers.keys.include?(rand_section)
		random_tiers[rand_section] = [] if !random_tiers.keys.include?(rand_section)
		random_tiers[rand_section].push(rand_tier)
	end 
	
	random_tiers_keys = random_tiers_keys.sort 
  random_tiers["Themed tiers"] = []
  
  for themed_tier in tiers_cats["Micro-tier"]
    random_tiers["Themed tiers"].push(themed_tier)
  end 
  
  random_tiers_keys = ["Themed tiers"] + random_tiers_keys
	
	# The menu. 
	cmd = 0
	tierid = ""
	chosen_type = nil 
	
	# Different list because I want the tiers to follow a certain order. 
	menu_list = ["FE", "Other presets", "Monotype", "Bitype", "Base stats", "Tier of the day", "Old tier of the day"]
	# Theme tier = Micro-tier 
	# Old tier of the day = Random tiers that already appeared
	
	while cmd > -2 
		cmd = pbMessage("Choose a category of tiers (current tiers=" + scGetTier()+ ").", menu_list, -2, nil, 0)
		
		
		if cmd > -2
			category = menu_list[cmd]
			
			if category == "FE"
				tierid = "FE" 
				cmd = -2 
				
			#elsif category == "OTF Preset"
				# Handled in the "else" case. 
				
			elsif category == "Monotype"
				tierid = "MONO"
				cmd = -2 
				
			elsif category == "Bitype"
				tierid = "BI"
				cmd = -2 
				
			elsif category == "Tier of the day"
				cmd2 = pbMessage(_INTL("Choose tier of the day? ({1})", scTOTDHandler.get()), ["Yes", "No"], 1)
				if cmd2 == 0
					tierid = scTOTDHandler.get()
					cmd = -2 
				end 
				
			# elsif category == "Theme tier"
				# handled in the "else" case 
			
			elsif category == "Old tier of the day"
        pbMessage("These are tiers that were tier of the day at least once.")
				cmd = pbMessage("Choose a base stat total.", random_tiers_keys, -1, nil, 0)
				
				if cmd > -1 
					base_stat = random_tiers[random_tiers_keys[cmd]]
					
					cmd = pbMessage("Choose a tiers (current=" + scGetTier() + ").", base_stat, -1, nil, 0)
					
					if cmd > -1
						tierid = base_stat[cmd]
						cmd = -2
					end 
				end 
        
			elsif category == "Random"
        pbMessage("These tiers contain a selected list of Pokémons whose base stats are around a given total.")
				cmd = pbMessage("Choose a base stat total.", random_tiers_keys, -1, nil, 0)
				
				if cmd > -1 
					base_stat = random_tiers[random_tiers_keys[cmd]]
					
					cmd = pbMessage("Choose a tiers (current=" + scGetTier() + ").", base_stat, -1, nil, 0)
					
					if cmd > -1
						tierid = base_stat[cmd]
						cmd = -2
					end 
				end 
      
      elsif category == "Base stats"
        category = "Base stats tiers"
        
				pbMessage("These tiers contain all Pokémons whose total base stats are around a given value.")
				cmd = pbMessage("Choose a tier.", tiers_cats[category], -1, nil, 0)
				
				if cmd > -1
					tierid = tiers_cats[category][cmd]
					cmd = -2
				end
        
			# elsif category == "OTF"
				# tierid = "OTF"
				# t = SCPersonalisedTiers.new(tiers[tierid])
				# t.menu
				# cmd = -2 
				
			else # Other presets
				if category == "Other presets"
					category = "Preset tiers"
				end 
				
				cmd = pbMessage("Choose a tiers (current=" + scGetTier() + ").", tiers_cats[category], -1, nil, 0)
				
				if cmd > -1
					tierid = tiers_cats[category][cmd]
					cmd = -2
				end 
			end 
			
		end 
		
	end 
	
	tierid = scGetTier() if tierid == "" 
	
	return tierid
	
end 


