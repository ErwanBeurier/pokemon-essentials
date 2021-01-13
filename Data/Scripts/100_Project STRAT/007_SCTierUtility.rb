###############################################################################
# SCTierUtility
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# Management of tiers: set tiers, force tiers, access tiers. 
# Also, tier of the team held by the player, when the player has loaded the 
# team. 
# Also also, menu to alter the current tier. 
###############################################################################


def scCanChangeTier?
  return !$game_switches[SCSwitch::ForcedTier] # If forced, can't change. 
end 



def scSetTier(tier, forced)
  all_tiers = scLoadTierData
  
  if not all_tiers.keys.include?(tier)
    raise _INTL("Given tier \"{1}\" was set but does not exist.", tier)
  end 
  
  $game_variables[SCVar::Tier] = tier 
  $game_switches[SCSwitch::ForcedTier] = forced
end 



def scUnforceTier()
  # The tier is not forced anymore. 
  # The player can battle random players or take clients. 
  $game_switches[SCSwitch::ForcedTier] = false
end 



def scGetTier(simple = true)
  $game_variables[SCVar::Tier] = "FE" if !$game_variables[SCVar::Tier] || $game_variables[SCVar::Tier] == 0
  
  return $game_variables[SCVar::Tier] if simple 
  # Current tier ID + is it forced (for narrative reasons)
  return [$game_variables[SCVar::Tier], $game_switches[SCSwitch::ForcedTier]]
end 



def scGetTierOfTeam()
  return $game_variables[SCVar::TierOfTeam]
end 



def scSetTierOfTeam(tier)
  $game_variables[SCVar::TierOfTeam] = tier
end



#===============================================================================
# Management of nuzzlocke
#===============================================================================



def scIsNuzzlocke()
  return ($game_switches[SCSwitch::IsNuzzlocke] != nil && $game_switches[SCSwitch::IsNuzzlocke])
end 


def scSetNuzzlocke()
  $game_switches[SCSwitch::IsNuzzlocke] = true 
end 


def scUnsetNuzzlocke()
  $game_switches[SCSwitch::IsNuzzlocke] = false 
end 


#----------------------------------------------------------
# Menu function to select the current tier. 
#----------------------------------------------------------
def scSelectTierMenu
  current_tier = scGetTier(false)
  
  if current_tier[1]
    # Tier is forced for narrative reasons.
    pbMessage(_INTL("The tier of your previous client was {1}.", current_tier[0])) if scClientBattles.battleIsDone
    pbMessage(_INTL("The tier of your next client is {1}.", current_tier[0])) if !scClientBattles.battleIsDone
    pbMessage(_INTL("You cannot change tier now."))
    
    return current_tier[0]
  end 
  
  
  tiers = scLoadTierData
  
  
  tier_cats = {} 
  # dictionary category -> list of tier IDs 
  tier_cats_names = {}
  # dictionary category -> list of tier names. 
  
  # Load the tiers. 
  for t in tiers["TierList"]
    t_name = tiers[t]["Name"]
    
    cat = tiers[t]["Category"]
    
    # if (cat != "Random" && cat != "Micro-tier") or scTOTDHandler.was_totd(t)
    if true
      # Add a Random tier only if it was Tier of the Day. (?)
      if !tier_cats[cat]
        tier_cats[cat] = []
        tier_cats_names[cat] = []
      end
      
      tier_cats[cat].push(t)
      tier_cats_names[cat].push(t_name)
    end 
  end
  
  
  for c in tier_cats.keys
    tier_cats[c] = tier_cats[c].sort 
  end 
  
  # Special treatment for random tiers : gather them by stats. 
  random_tiers = {}
  random_tier_keys = []
  
  for rand_tier in tier_cats["Random"]
    rand_section = "Base stats " + rand_tier[4..6] # RANDXXX-YY => Base stats XXX
    random_tier_keys.push(rand_section) if !random_tiers.keys.include?(rand_section)
    random_tiers[rand_section] = [] if !random_tiers.keys.include?(rand_section)
    random_tiers[rand_section].push(rand_tier)
  end 
  
  random_tier_keys = random_tier_keys.sort 
  random_tiers["Themed tiers"] = []
  
  for themed_tier in tier_cats["Micro-tier"]
    random_tiers["Themed tiers"].push(themed_tier)
  end 
  
  random_tier_keys = ["Themed tiers"] + random_tier_keys
  
  # The menu. 
  cmd = 0
  tierid = ""
  chosen_type = nil 
  
  # Different list because I want the tiers to follow a certain order. 
  menu_list = ["FE", "Other presets", "Monotype", "Bitype", "Base stats", "Tier of the day", "Old tier of the day"]
  # Theme tier = Micro-tier 
  # Old tier of the day = Random tiers that already appeared
  
  while cmd > -2 
    cmd = pbMessage("Choose a category of tier (current tier=" + scGetTier()+ ").", menu_list, -2, nil, 0)
    
    
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
        cmd = pbMessage("Choose a base stat total.", random_tier_keys, -1, nil, 0)
        
        if cmd > -1 
          base_stat = random_tiers[random_tier_keys[cmd]]
          
          cmd = pbMessage("Choose a tier (current=" + scGetTier() + ").", base_stat, -1, nil, 0)
          
          if cmd > -1
            tierid = base_stat[cmd]
            cmd = -2
          end 
        end 
        
      elsif category == "Random"
        pbMessage("These tiers contain a selected list of Pokémons whose base stats are around a given total.")
        cmd = pbMessage("Choose a base stat total.", random_tier_keys, -1, nil, 0)
        
        if cmd > -1 
          base_stat = random_tiers[random_tier_keys[cmd]]
          
          cmd = pbMessage("Choose a tier (current=" + scGetTier() + ").", base_stat, -1, nil, 0)
          
          if cmd > -1
            tierid = base_stat[cmd]
            cmd = -2
          end 
        end 
      
      elsif category == "Base stats"
        category = "Base stats tiers"
        
        pbMessage("These tiers contain all Pokémons whose total base stats are around a given value.")
        cmd = pbMessage("Choose a tier.", tier_cats[category], -1, nil, 0)
        
        if cmd > -1
          tierid = tier_cats[category][cmd]
          cmd = -2
        end
        
      # elsif category == "OTF"
        # tierid = "OTF"
        # t = SCPersonalisedTier.new(tiers[tierid])
        # t.menu
        # cmd = -2 
        
      else # Other presets
        if category == "Other presets"
          category = "Preset tiers"
        end 
        
        cmd = pbMessage("Choose a tier (current=" + scGetTier() + ").", tier_cats[category], -1, nil, 0)
        
        if cmd > -1
          tierid = tier_cats[category][cmd]
          cmd = -2
        end 
      end 
      
    end 
    
  end 
  
  tierid = scGetTier() if tierid == "" 
  
  return tierid
  
end 


