# Script by StCooler
# Do what you want with it. Just credit me if you use it.
# 


=begin

def scBattleStats
	return $CastleHandler.stats
end 

=end


def scTOTDHandler
	return $CastleHandler.totd_handler
end 


class SCTierOfTheDayHandler
	
	def initialize
		@tier_dict = {}
		# dictionary: tierid -> int
		# Remembers what random tiers were already given and how many times
		@current_tier = nil
    @already_chosen_tiers = []
		@all_tiers = [] 
		tiers = load_data("Data/sctiers.dat")
		
		for tier in tiers["TierList"]
			if tiers[tier]["Category"] == "Random" || tiers[tier]["Category"] == "Micro-tier"
				@tier_dict[tier] = 0 
        @all_tiers.push(tier)
			end 
		end 
		self.pick()
	end 
	
	
	def pick()
		i = rand(@all_tiers.length)
		
		tier = @all_tiers[i]
    @already_chosen_tiers.push(tier)
		@current_tier = tier # Stores the tier of the day. 
		@tier_dict[tier] += 1
	end 
	
	
	def get()
		return @current_tier
	end 
	
	def was_totd(tier)
		return (@tier_dict[tier] != nil) && @tier_dict[tier]
	end 
end 



class SCCastleData
	# I group this in one class in order to instantiate only one class in the PokemonLoad and PokemonSave scripts. 
	attr_reader(:storage)
	# attr_reader(:stats)
	attr_reader(:totd_handler)
	
	def initialize
		@storage = SCTeamStorage.new 
		# @stats = SCBattleStatistics.new
		@totd_handler = SCTierOfTheDayHandler.new 
	end 
	
end 




def scTeamStorage
	return $CastleHandler.storage 
end 




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
		pbMessage(_INTL("Current tiers is {1}.", current_tier[0]))
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



#----------------------------------------------------------
# Menu for the PC:
# - Teambuilder 
# - Change tiers 
# - Tier statistics. 
#----------------------------------------------------------
def scCastlePC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
	loop do
		# commands=["Pokémon storage", "Team builder", "Stats"]
		commands=["Team builder", "Stats"]
		commands.push("Change tier") 
		commands.push("Log off")
		
		command=pbMessage(_INTL("Which PC should be accessed?"), commands,commands.length)
		
		case command 
			# when 0 # Pokémon storage 
				# scene = StorageSystemPC.new
				# scene.access() 
			when 0 # Team builder 
				# scene = SCTeamBuilder.new(true)
				scene = SCTeamViewer.new
				scene.main 
			when 1 # Stats 
				# scBattleStats.menu 
				pbMessage("Unimplemented yet.")
			when 2 
				temp = scSelectTierMenu
        scSetTier(temp, false)
				pbMessage("Current tier: " + scGetTier() + ".")
			else 
				break 
		end 
	end
  pbSEPlay("PC close")
end 






def scWatchCastleTV
	list_broadcasts = [
		"\"Mais réveille-toi, connard de Togekiss de merde ! Mais réveille-toi ! MAIS REVEILLE-TOI !\"",
		"Some eyes are staring back at you...",
		"The trainer became angry because he missed five Focus Blasts in a row..."
	]
	
	pbMessage(list_broadcasts[rand(list_broadcasts.length)])
end 






#----------------------------------------------------------
# Loads the graphics for the trainer. 
#----------------------------------------------------------
def scLoadTrainerGraphics(eventopponent, class_i, name_i)
  # Opponent 1: class_i = 53 ; name_i = 54 
  # Opponent 2: class_i = 55 ; name_i = 56
  # Opponent 3: class_i = 57 ; name_i = 58
  client = scFastClient
	filename=sprintf("trchar%03d",client[0])
  eventopponent.character_name = filename
  $game_variables[class_i] = client[0]
  $game_variables[name_i] = client[1]
end 

# Other names I liked: 
# Males: Lóránt, Lörinc
# Females: 

def scFastClient
  client_list = [
    PBTrainers::AROMALADY,
    PBTrainers::BEAUTY,
    PBTrainers::BIKER,
    PBTrainers::BIRDKEEPER,
    PBTrainers::BUGCATCHER,
    PBTrainers::BURGLAR,
    PBTrainers::CHANELLER,
    PBTrainers::CUEBALL,
    PBTrainers::ENGINEER,
    PBTrainers::FISHERMAN,
    PBTrainers::GAMBLER,
    PBTrainers::GENTLEMAN,
    PBTrainers::HIKER,
    PBTrainers::JUGGLER,
    PBTrainers::LADY,
    PBTrainers::PAINTER,
    PBTrainers::POKEMANIAC,
    PBTrainers::POKEMONBREEDER,
    PBTrainers::ROCKER,
    PBTrainers::RUINMANIAC,
    PBTrainers::SAILOR,
    PBTrainers::SCIENTIST,
    PBTrainers::SUPERNERD,
    PBTrainers::TAMER,
    PBTrainers::BLACKBELT,
    PBTrainers::CRUSHGIRL,
    PBTrainers::CAMPER,
    PBTrainers::PICNICKER,
    PBTrainers::COOLTRAINER_M,
    PBTrainers::COOLTRAINER_F,
    PBTrainers::YOUNGSTER,
    PBTrainers::LASS,
    PBTrainers::POKEMONRANGER_M,
    PBTrainers::POKEMONRANGER_F,
    PBTrainers::PSYCHIC_M,
    PBTrainers::PSYCHIC_F,
    PBTrainers::SWIMMER_M,
    PBTrainers::SWIMMER_F,
    PBTrainers::SWIMMER2_M,
    PBTrainers::SWIMMER2_F,
    PBTrainers::CRUSHKIN,
    # Trainers from BW 
    PBTrainers::BWBATTLEGIRL,
    PBTrainers::BWBIKER,
    PBTrainers::BWBLACKBELT,
    PBTrainers::BWFISHERMAN,
    PBTrainers::BWHIKER,
    PBTrainers::BWOFFICELADY,
    PBTrainers::BWPSYCHIC_F,
    PBTrainers::BWPSYCHIC_M,
    PBTrainers::BWROUGHNECK,
    PBTrainers::BWSCIENTIST,
    PBTrainers::BWSWIMMER_M,
    PBTrainers::BWSWIMMER_F,
    # Trainers from DPP 
    PBTrainers::DPBIRDKEEPER,
    PBTrainers::DPCAMPER,
    PBTrainers::DPLADY,
    PBTrainers::DPPAINTER,
    PBTrainers::DPPICNICKER,
    PBTrainers::DPROCKER,
    PBTrainers::DPRUINMANIAC,
    PBTrainers::DPSAILOR,
    PBTrainers::DPSUPERNERD,
    PBTrainers::DPBREEDER,
    # Trainers from HGSS
    PBTrainers::HGSSACETRAINER_F,
    PBTrainers::HGSSACETRAINER_M,
    PBTrainers::HGSSBEAUTY,
    PBTrainers::HGSSBIRDKEEPER,
    PBTrainers::HGSSBUGCATCHER,
    PBTrainers::HGSSBURGLAR,
    PBTrainers::HGSSGENTLEMAN,
    PBTrainers::HGSSMEDIUM,
    PBTrainers::HGSSSUPERNERD,
    PBTrainers::HGSSSWIMMER_F
    ]
  
  return [scsample(client_list, 1), "Punching-ball"]
end 
