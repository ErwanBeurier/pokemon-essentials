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


#===============================================================================
# Some functions to handle the current tier, without refering to 
# Switches/Variables.
#===============================================================================

def scCanChangeTier?
  return !SCSwitch.get(:ForcedTier) # If forced, can't change. 
end 



def scSetTier(tier, forced)
  all_tiers = scLoadTierData
  
  if not all_tiers.keys.include?(tier)
    raise _INTL("Given tier \"{1}\" was set but does not exist.", tier)
  end 
  
  SCVar.set(:Tier, tier)
  SCSwitch.set(:ForcedTier, forced)
end 



def scUnforceTier()
  # The tier is not forced anymore. 
  # The player can battle random players or take clients. 
  SCSwitch.set(:ForcedTier, false)
end 



def scGetTier(simple = true)
  SCVar.set(:Tier, "FE") if !SCVar.get(:Tier)|| SCVar.get(:Tier) == 0
  
  return SCVar.get(:Tier) if simple 
  # Current tier ID + is it forced (for narrative reasons)
  return [SCVar.get(:Tier), SCSwitch.get(:ForcedTier)]
end 



def scGetTierOfTeam()
  return SCVar.get(:TierOfTeam)
end 



def scSetTierOfTeam(tier)
  SCVar.set(:TierOfTeam, tier)
end


def scLegendaryAllowed?
  return SCSwitch.get(:AllowLegendary)
end 


def scTiersWithLegendaries
  return ["FEL", "UBER", "ALLLEG", "STRONGLEG", "SMALLLEG", "BIL", "MONOL"]
end 


#===============================================================================
# Management of nuzzlocke
#===============================================================================



def scIsNuzzlocke()
  return (SCSwitch.get(:IsNuzzlocke) != nil && SCSwitch.get(:IsNuzzlocke))
end 


def scSetNuzzlocke()
  SCSwitch.set(:IsNuzzlocke, true) 
end 


def scUnsetNuzzlocke()
  SCSwitch.set(:IsNuzzlocke, false) 
end 


#===============================================================================
# Menu function to select the current tier. 
#===============================================================================
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
    
    if cat == "Preset tier" && !scLegendaryAllowed? && 
      scTiersWithLegendaries.include?(t)
      next 
    end 
    
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
  random_tiers["Themed tiers"] = random_tiers["Themed tiers"].sort
  
  # random_tier_keys = ["Themed tiers"] + random_tier_keys
  
  # The menu. 
  cmd = 0
  tierid = ""
  chosen_type = nil 
  
  # Different list because I want the tiers to follow a certain order. 
  menu_list = ["FE", "Other presets", "Monotype", "Bitype", "Themed tiers", "Base stats", "Tier of the day", "Old tiers of the day"]
  # Theme tier = Micro-tier 
  # Old tier of the day = Random tiers that already appeared
  
  # Add the current tier. 
  current_tier = scGetTier()
  
  if scLegendaryAllowed?
    menu_list = ["FE+Legendary"] + menu_list
    
    if current_tier != "FE" && current_tier != "FE+Legendary"
      menu_list = [current_tier] + menu_list
    end 
  elsif current_tier != "FE"
    menu_list = [current_tier] + menu_list
  end 
  
  while cmd > -2 
    cmd = pbMessage("Choose a category of tier (current tier=" + current_tier + ").", menu_list, -2, nil, 0)
    
    
    if cmd > -2
      category = menu_list[cmd]
      
      
      if category == current_tier
        tierid = current_tier
        cmd = -2 
        
      elsif category == "FE"
        tierid = "FE" 
        cmd = -2 
        
      #elsif category == "OTF Preset"
        # Handled in the "else" case. 
        
      elsif category == "FE+Legendary"
        tierid = "FEL"
        cmd = -2 
        
      elsif category == "Monotype"
        if scLegendaryAllowed?
          cmd2 = pbMessage(_INTL("Which Monotype?"), ["Normal", "With Legendary"], -1)
          if cmd2 == 0
            tierid = "MONO"
            cmd = -2 
          elsif cmd2 == 1
            tierid = "MONOL"
            cmd = -2 
          end 
        else
          tierid = "MONO"
          cmd = -2 
        end 
        
      elsif category == "Bitype"
        if scLegendaryAllowed?
          cmd2 = pbMessage(_INTL("Which Bitype?"), ["Normal", "With Legendary"], -1)
          if cmd2 == 0
            tierid = "BI"
            cmd = -2 
          elsif cmd2 == 1
            tierid = "BIL"
            cmd = -2 
          end 
        else
          tierid = "BI"
          cmd = -2 
        end 
      
      elsif category == "Themed tiers"
        
        cmd = pbMessage("Choose a tier.", random_tiers["Themed tiers"], -1, nil, 0)
        
        if cmd > -1
          tierid = random_tiers["Themed tiers"][cmd]
          cmd = -2
        end
        
      elsif category == "Tier of the day"
        cmd2 = pbMessage(_INTL("Choose tier of the day? ({1})", scTOTDHandler.get()), ["Yes", "No"], 1)
        if cmd2 == 0
          tierid = scTOTDHandler.get()
          cmd = -2 
        end 
        
      # elsif category == "Theme tier"
        # handled in the "else" case 
      
      elsif category == "Old tiers of the day"
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


