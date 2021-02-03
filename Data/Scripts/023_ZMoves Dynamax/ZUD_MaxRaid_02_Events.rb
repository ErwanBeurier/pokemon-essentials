#===============================================================================
#
# Max Raid Events Script - by Lucidious89
#  For -Pokemon Essentials v18.1-
#
#===============================================================================
#
# ZUD_MaxRaid_02: Events
#
#===============================================================================
# The following is meant as an add-on for the ZUD Plugin for v18.1.
# This adds scripts you may run to initiate two different Max Raid Events:
# Max Raid Dens, and the Max Raid Database.
#
#===============================================================================
# SECTION 1 - SPECIES SETTINGS
#-------------------------------------------------------------------------------
# This section handles all of the user settings related to species that may or
# may not spawn in a Max Raid event.
#===============================================================================
# SECTION 2 - UTILITIES
#-------------------------------------------------------------------------------
# This section handles all of the functions that are used for obtaining the
# correct data for setting up a Max Raid event.
#===============================================================================
# SECTION 3 - MAX RAID DEN EVENT
#-------------------------------------------------------------------------------
# This section handles everything related to a Max Raid Den event, and allows
# you to set up Raid Dens that may be challenged by the player.
#===============================================================================
# SECTION 4 - MAX RAID DATABASE EVENT
#-------------------------------------------------------------------------------
# This section handles everything related to the Max Raid Database, and allows
# the player to access it through an event, or through the Pokegear.
#===============================================================================
# SECTION 5 - MAX RAID ITEMS
#-------------------------------------------------------------------------------
# This section handles any new custom items added that are to be given out as
# rewards for clearing a Max Raid Den. These aren't official items, and are
# included just for fun.
#===============================================================================


################################################################################
# User Guide for setting up Raid Events.
################################################################################
# MAX RAID DENS
#===============================================================================
# This event sets up a Max Raid Den in order to battle a Max Raid Pokemon.
# Write the code "pbMaxRaid" in an event as a script to run this event. This
# will set up a raid battle vs a Max Raid Pokemon when accessed.
# You can manipulate a variety of different parameters for this event to
# customize different attributes for these battles. The parameters are as such:
#
# pbMaxRaid(size,rank,pkmn,loot,field,gmax,hard)
#
# Size: How many Pokemon you send out at once vs the Raid boss.
#       -Defaults to MAXRAID_SIZE when nil.
#       -Supports up to 3 Pokemon at once.
#       -The raid size will scale to your party size if you have fewer Pokemon.
#       -Raid size may change the raid timer or earned rewards.
#
# Rank: The star level difficulty of the raid.
#       -Defaults to a certain rank based on your badge count when nil.
#       -Ranks range from 1-6, with rank 6 being used exclusively for Legendary raids.
#       -If a species is entered that does not match the inputted rank, the rank will scale
#        to the highest raid rank that species can be found in, instead.
#
# Pkmn: The raid boss species.
#       -Defaults to a random species that spawns on the current map when nil.
#       -Set as a specific species name (ex. :DEOXYS) to generate that species.
#           *Certain species will spawn with a randomized form.
#       -Set as a specific species and form (ex. :DEOXYS_1) to generate that particular form.
#           *If a banned form is inputted, defaults to the base species instead.
#       -Set as a species number (ex. 386) to generate that species.
#           *Species generated this way will not have randomized forms.
#       -Set as an array to randomize the species each time. The array is ordered as such:
#           [0]==Type, [1]==Habitat, [2]==Regional Dex
#           *Set any of the above as nil to ignore it while randomizing.
#       -Species defaults to Ditto if none can be found through any of the above methods.
#
# Loot: A custom bonus reward that is added to the raid's loot table.
#       -No bonus reward is added when nil.
#       -Set as an item name or number to add 1 of that item to the raid's loot table.
#       -Set as an array to add a specified quantity of an item to the raid's loot table.
#           [0]==Item, [1]==Quantity
#           *Set the quantity to something like rand(10) to randomize it.
#
# Field: Customized battlefield conditions for the raid.
#       -No customized conditions set when nil.
#       -Set as a specified number found in PBEnvironments to change the battle environment of the raid.
#       -Set as an array to set the default weather and/or terrain of the battle, too.
#           [0]==Weather, [1]==Terrain, [2]==Environment
#           *Set any of these conditions to -1 to randomize it.
#
# GMax: Toggle for Gigantamax Raids.
#       -Defaults to "false" if not set.
#       -Set as "true" to force a Gigantamax Raid, if species can Gigantamax.
#       -Gigantamax Raids may still spawn naturally even if this parameter is set as "false".
#
# Hard: Toggle for Hard Mode Raids.
#       -Defaults to "false" if not set.
#       -Set as "true" to enable Hard Mode difficulty for the raid.
#       -Rank 6 raids (Legendary) always have Hard Mode enabled regardless of this setting.
#
#===============================================================================
# MAX RAID DATABASE
#===============================================================================
# This creates a database you may access of all species and forms that you may 
# find in Max Raid Battles. This is meant to be used as both a reference for 
# players, and a debugging tool of sorts for developers to plan out their raids.
# Write the code "pbOpenRaidData" in an event as a script to run this event.
# By default, you may also access the Database through the Pokegear.
#
# In the Database, you may search through species by:
# -Raid Level
# -Type
# -Habitat
# -Regional Dex
#
# Or any combination of these criteria.
#
# When viewing a specific species' data page, you can view all the possible moves
# they may be carrying while battling them in a raid. You can also see which 
# raid ranks that specific species may appear in, along with whether it can be
# Gigantamax or not, and more. 
#
# If you press the Z key while viewing this page in debug mode, you may initiate
# a test Max Raid battle vs that species.
#
#===============================================================================


################################################################################
# SECTION 1 - SPECIES SETTINGS
#===============================================================================
# Numbers associated with different regions. Regional forms will spawn in 
# raids instead if on a map position that matches a number below.
#-------------------------------------------------------------------------------
ALOLA_REGION       = 1     # The region number designated as the Alola Region.
GALAR_REGION       = 2     # The region number designated as the Galar Region.

#===============================================================================
# Custom Max Raid sets.
#===============================================================================
# Add any Pokemon and moveset you want here, and they will always have those
# moves when you encounter them in a Max Raid. You can use this to give Raid
# Pokemon moves they normally wouldn't learn, or to ensure their moveset always
# contains a specific move.

# You can also use this to alter any other attribute on the Pokemon as well, 
# such as Item, Nature, Ability, etc. Use the commented template as a guide.
#
# Note: Leave Rotom's moves as is. This is a redundancy to ensure its forms
# recieve the correct moves in a Max Raid.
#===============================================================================
def pbCustomRaidSets(pokemon,form)
  if pokemon.isSpecies?(:ROTOM)        
    pokemon.pbLearnMove(:OVERHEAT)  if form==1         # Required for Rotom Heat
    pokemon.pbLearnMove(:HYDROPUMP) if form==2         # Required for Rotom Wash
    pokemon.pbLearnMove(:BLIZZARD)  if form==3         # Required for Rotom Frost
    pokemon.pbLearnMove(:AIRSLASH)  if form==4         # Required for Rotom Fan
    pokemon.pbLearnMove(:LEAFSTORM) if form==5         # Required for Rotom Mow
  elsif pokemon.isSpecies?(:AEGISLASH) 
    pokemon.pbLearnMove(:KINGSSHIELD)                  # Ensures King's Shield
  elsif pokemon.isSpecies?(:ZYGARDE)
    pokemon.setAbility(1)                              # Ensures Power Construct
  elsif pokemon.isSpecies?(:ORICORIO)  
    pokemon.pbLearnMove(:REVELATIONDANCE)              # Ensures Revelation Dance
  elsif pokemon.isSpecies?(:CRAMORANT) 
    pokemon.pbLearnMove(:DIVE)                         # Ensures Dive
  elsif pokemon.isSpecies?(:MORPEKO)   
    pokemon.pbLearnMove(:AURAWHEEL)                    # Ensures Aura Wheel
  #-----------------------------------------------------------------------------
  # Add custom sets below.
  #-----------------------------------------------------------------------------
  #elsif pokemon.isSpecies?(:SPECIESNAME)
  #  pokemon.setItem(:ITEMNAME)
  #  pokemon.setNature(:NATURENAME)
  #  pokemon.setGender(GENDERNUMBER)
  #  pokemon.setAbility(ABILITYSLOT)
  #  pokemon.pbLearnMove(:MOVENAME1)
  #  pokemon.pbLearnMove(:MOVENAME2)
  #  pokemon.pbLearnMove(:MOVENAME3)
  #  pokemon.pbLearnMove(:MOVENAME4)
  end
end


################################################################################
# SECTION 2 - UTILITIES
#===============================================================================
# Various tools for obtaining or resetting data required for Max Raid events.
#===============================================================================
def pbResetRaidSettings
  $game_switches[MAXRAID_SWITCH]  = false
  $game_switches[HARDMODE_RAID]   = false
  $game_variables[MAXRAID_PKMN]   = 0
  $game_variables[REWARD_BONUSES] = [MAXRAID_TIMER,true,true] # Timer, Perfect, Fairness
end

#===============================================================================
# Initializes lists of Pokemon banned from raids, or appear in random forms.
#===============================================================================
def pbInitRaidBanlist
  #-----------------------------------------------------------------------------
  # Hard-coded banned species list.
  #-----------------------------------------------------------------------------
  raid_banlist = [PBSpecies::SMEARGLE,
                  PBSpecies::SHEDINJA,
                  PBSpecies::TYPENULL,
                  PBSpecies::COSMOG,
                  PBSpecies::COSMOEM,
                  PBSpecies::POIPOLE,
                  PBSpecies::MELTAN,
                  PBSpecies::ZACIAN,
                  PBSpecies::ZAMAZENTA,
                  PBSpecies::KUBFU]
  #-----------------------------------------------------------------------------
  # Species with forms that are randomized when encountered in raids.
  #-----------------------------------------------------------------------------
  random_forms = [PBSpecies::UNOWN,
                  PBSpecies::DEOXYS, 
                  PBSpecies::SHELLOS, 
                  PBSpecies::GASTRODON, 
                  PBSpecies::ROTOM,
                  PBSpecies::BASCULIN,
                  PBSpecies::TORNADUS, 
                  PBSpecies::THUNDURUS, 
                  PBSpecies::LANDORUS,
                  PBSpecies::FLABEBE, 
                  PBSpecies::FLOETTE, 
                  PBSpecies::FLORGES, 
                  PBSpecies::PUMPKABOO, 
                  PBSpecies::GOURGEIST,
                  PBSpecies::HOOPA,
                  PBSpecies::ORICORIO,
                  PBSpecies::URSHIFU]
  #-----------------------------------------------------------------------------
  # Species that only display their base forms in the Max Raid Database.
  #-----------------------------------------------------------------------------
  base_forms   = [PBSpecies::PIKACHU,
                  PBSpecies::UNOWN,
                  PBSpecies::VIVILLON,
                  PBSpecies::FLABEBE,
                  PBSpecies::FLOETTE,
                  PBSpecies::FLORGES,
                  PBSpecies::FURFROU,
                  PBSpecies::PUMPKABOO,
                  PBSpecies::GOURGEIST,
                  PBSpecies::ROCKRUFF,
                  PBSpecies::MINIOR,
                  PBSpecies::SINISTEA,
                  PBSpecies::POLTEAGEIST]
  #-----------------------------------------------------------------------------
  # Adds all other forms to raid banlist unless specified below.
  #-----------------------------------------------------------------------------
  formdata = pbLoadFormToSpecies
  for i in 1..PBSpecies.maxValue
    for f in 0...formdata[i].length
      next if f==0
      fSpecies = pbGetFSpeciesFromForm(i,f)
      formname = pbGetMessage(MessageTypes::FormNames,fSpecies)
      raid_banlist.push(fSpecies) if i==PBSpecies::FLOETTE && f==5
      next if formname=="Alolan" || formname=="Galarian"
      next if i==PBSpecies::PIKACHU && f < 3
      next if i==PBSpecies::BURMY
      next if i==PBSpecies::WORMADAM
      next if i==PBSpecies::SHAYMIN
      next if i==PBSpecies::VIVILLON
      next if i==PBSpecies::FURFROU
      next if i==PBSpecies::MEOWSTIC
      next if i==PBSpecies::ZYGARDE && f < 2
      next if i==PBSpecies::ROCKRUFF
      next if i==PBSpecies::LYCANROC
      next if i==PBSpecies::MINIOR && f < 7
      next if i==PBSpecies::SINISTEA
      next if i==PBSpecies::POLTEAGEIST
      next if i==PBSpecies::TOXTRICITY
      next if i==PBSpecies::INDEEDEE
      next if random_forms.include?(i)
      raid_banlist.push(fSpecies)
    end
  end 
  return [raid_banlist, random_forms, base_forms]
end

#===============================================================================
# Used for storing and accessing raid lists.
#===============================================================================
class PokemonTemp
  attr_accessor :raidBanlist
  attr_accessor :raidRandomForms
  attr_accessor :raidDatabaseForms
end

def pbGetMaxRaidBanlist 
  if !$PokemonTemp.raidBanlist
    $PokemonTemp.raidBanlist = pbInitRaidBanlist[0]
  end 
  return $PokemonTemp.raidBanlist
end  

def pbGetMaxRaidRandomForms
  if !$PokemonTemp.raidRandomForms
    $PokemonTemp.raidRandomForms = pbInitRaidBanlist[1]
  end 
  return $PokemonTemp.raidRandomForms
end

def pbGetDataDisplayForms
  if !$PokemonTemp.raidDatabaseForms
    $PokemonTemp.raidDatabaseForms = pbInitRaidBanlist[2]
  end 
  return $PokemonTemp.raidDatabaseForms
end

def pbResetRaidLists
  $PokemonTemp.raidBanlist       = pbInitRaidBanlist[0]
  $PokemonTemp.raidRandomForms   = pbInitRaidBanlist[1]
  $PokemonTemp.raidDatabaseForms = pbInitRaidBanlist[2]
end

#===============================================================================
# Compiles the lists of species found in each raid rank.
#===============================================================================
def pbGetMaxRaidSpeciesLists(filters=nil,displayOnly=false,env=nil)
  rank1    = [] # Contains Pokemon excluding legendaries with >=365 BST
  rank2    = [] # Contains Pokemon excluding legendaries between 365-478 BST
  rank3    = [] # Contains Pokemon excluding legendaries between 480-535 BST
  rank4    = [] # Contains Pokemon excluding legendaries between 535-600 BST
  rank5    = [] # Contains all fully evolved legendaries, Silvally & Ultra Beasts
  banned   = [] # Contains species banned from raid battles.
  for i in pbGetMaxRaidBanlist; banned.push(getID(PBSpecies,i)); end
  formdata = pbLoadFormToSpecies
  g = nil
  #-----------------------------------------------------------------------------
  # Unique cases.
  #-----------------------------------------------------------------------------
  random   = pbGetMaxRaidRandomForms
  trash    = (env==0)
  sandy    = (env==7 || env==8 || env==9)
  enviro   = [PBSpecies::BURMY,PBSpecies::WORMADAM]
  season   = [PBSpecies::DEERLING,PBSpecies::SAWSBUCK]
  timeday  = [PBSpecies::ROCKRUFF,PBSpecies::LYCANROC]
  gender   = [PBSpecies::MEOWSTIC,PBSpecies::INDEEDEE]
  # Species with different icons based on gender.
  fgender  = [PBSpecies::PIKACHU,PBSpecies::RAICHU,
              PBSpecies::SCYTHER,PBSpecies::SCIZOR,
              PBSpecies::HERACROSS,PBSpecies::SNEASEL,
              PBSpecies::UNFEZANT,PBSpecies::PYROAR,
              PBSpecies::FRILLISH,PBSpecies::JELLICENT,
              PBSpecies::MEOWSTIC,PBSpecies::INDEEDEE]
  #-----------------------------------------------------------------------------
  # Gets search criteria if "filters" is an array.
  #-----------------------------------------------------------------------------
  if filters.is_a?(Array)
    rType    = true if filters[0]
    rHabitat = true if filters[1]
    rRegion  = true if filters[2]
  #-----------------------------------------------------------------------------
  # Gets fSpecies if "filters" is a Pokemon.
  #-----------------------------------------------------------------------------
  elsif filters
    pokemon   = getConst(PBSpecies,filters)
    pokemon   = getID(PBSpecies,filters) if filters.is_a?(Numeric)
    pokemon   = (pokemon) ? pokemon : PBSpecies::DITTO
    rSpecies  = pbGetSpeciesFromFSpecies(pokemon)
    randform  = rand(formdata[rSpecies[0]].length)
    g         = rand(2) if fgender.include?(rSpecies[0])
    g         = 0 if filters.is_a?(Numeric)
    rForm     = rSpecies[1]
    rForm     = g if gender.include?(rSpecies[0])
    rForm     = pbGetSeason if season.include?(rSpecies[0])
    rForm     = 0 if rSpecies[0]==PBSpecies::SHAYMIN && PBDayNight.isNight?
    if rForm==0
      rForm   = 1 if enviro.include?(rSpecies[0])  && sandy
      rForm   = 2 if enviro.include?(rSpecies[0])  && trash
      rForm   = 1 if timeday.include?(rSpecies[0]) && PBDayNight.isNight?
      rForm   = 2 if timeday.include?(rSpecies[0]) && PBDayNight.isEvening?
      if random.include?(rSpecies[0])
        rForm   = randform 
        rForm   = 0 if filters.is_a?(Numeric)
      end
    end
    rfSpecies = pbGetFSpeciesFromForm(rSpecies[0],rForm)
    rfSpecies = pbGetFSpeciesFromForm(rSpecies[0],0)      if banned.include?(rfSpecies)
    rfSpecies = pbGetFSpeciesFromForm(PBSpecies::DITTO,0) if banned.include?(rfSpecies)
  end
  #-----------------------------------------------------------------------------
  # Builds filtered ranks of eligible species.
  #-----------------------------------------------------------------------------
  for i in 1..PBSpecies.maxValue
    for f in 0...formdata[i].length
      fSpecies = pbGetFSpeciesFromForm(i,f)
      #-------------------------------------------------------------------------
      # Bans additional species based on inputted arguments.
      #-------------------------------------------------------------------------
      type1    = pbGetSpeciesData(i,f,SpeciesType1)
      type2    = pbGetSpeciesData(i,f,SpeciesType2)
      habitat  = pbGetSpeciesData(i,f,SpeciesHabitat)
      next if rType    && (type1!=filters[0] && type2!=filters[0])
      next if rHabitat && habitat!=filters[1]
      next if rRegion  && !pbAllRegionalSpecies(filters[2]).include?(i)
      next if season.include?(i) && f!=pbGetSeason
      if !displayOnly
        if filters.is_a?(Array)
          g        = rand(2) if fgender.include?(i)
          region   = pbGetCurrentRegion
          formname = pbGetMessage(MessageTypes::FormNames,fSpecies)
          randform = rand(formdata[i].length)            
          next if i==PBSpecies::UNOWN
          next if i==PBSpecies::ETERNATUS
          next if i==PBSpecies::FURFROU  && f>0
          next if i==PBSpecies::ZYGARDE  && f==1
          next if i==PBSpecies::VIVILLON && f!=$Trainer.secretID%18
          next if i==PBSpecies::SHAYMIN  && f==1 && PBDayNight.isNight?
          next if formname=="Alolan"     && region!=ALOLA_REGION
          next if formname=="Galarian"   && region!=GALAR_REGION
          next if gender.include?(i)     && f!=g
          next if season.include?(i)     && f!=pbGetSeason
          next if random.include?(i)     && f!=randform
          next if timeday.include?(i)    && f!=1 && PBDayNight.isNight?
          next if timeday.include?(i)    && f!=2 && PBDayNight.isEvening?
          next if enviro.include?(i)     && f!=0 && !(sandy || trash)
          next if enviro.include?(i)     && f!=1 && sandy
          next if enviro.include?(i)     && f!=2 && trash
        else
          next if fSpecies!=rfSpecies
        end
      else
        next if pbGetDataDisplayForms.include?(i) && f>0
      end
      #-------------------------------------------------------------------------
      # Organizes eligible species into appropriate raid ranks.
      #-------------------------------------------------------------------------
      next if banned.include?(fSpecies)
      bst       = pbBaseStatTotalForm(i,f)
      compat    = pbGetSpeciesData(i,f,SpeciesCompatibility)[0]
      legendary = (compat==0 || compat>=15)
      banRank1  = (i==PBSpecies::WISHIWASHI)
      banRank2  = (i==PBSpecies::ROTOM)
      banRank3  = ((i==PBSpecies::ZYGARDE && f==1) || i==PBSpecies::CALYREX)
      banRank4  = (i==PBSpecies::MANAPHY)
      rank1.push([i,f,g]) if bst<=365 && !banRank1
      rank2.push([i,f,g]) if (bst<480 && bst>365) && !banRank2
      rank3.push([i,f,g]) if (bst<=535 && bst>=480) && !banRank3
      rank3.push([i,f,g]) if i==PBSpecies::ROTOM && f==0
      rank4.push([i,f,g]) if (bst<=600 && bst>535) && !legendary && !banRank4
      rank4.push([i,f,g]) if i==PBSpecies::SLAKING
      rank4.push([i,f,g]) if i==PBSpecies::WISHIWASHI
      rank5.push([i,f,g]) if bst>=570 && legendary
      rank5.push([i,f,g]) if i==PBSpecies::MANAPHY
      rank5.push([i,f,g]) if i==PBSpecies::ZYGARDE && f==1
      rank5.push([i,f,g]) if i==PBSpecies::NAGANADEL
      rank5.push([i,f,g]) if i==PBSpecies::URSHIFU
      rank5.push([i,f,g]) if i==PBSpecies::CALYREX
    end
  end
  return rank1, rank2, rank3, rank4, rank5
end 

#===============================================================================
# Used to obtain an eligible Pokemon for a Max Raid Den event.
#===============================================================================
def pbGetMaxRaidSpecies(poke,rank,env)
  #-----------------------------------------------------------------------------
  # Gets appropriate data to search for species.
  #-----------------------------------------------------------------------------
  env = pbGetEnvironment if !env
  poke[0] = getID(PBTypes,poke[0]) if poke.is_a?(Array)
  if poke==nil
    enctype = $PokemonEncounters.pbEncounterType
    if enctype>0 || $PokemonEncounters.pbMapHasEncounter?($game_map.map_id,enctype)
      encounter = $PokemonEncounters.pbMapEncounter($game_map.map_id,enctype)
      poke = encounter[0]
    end
  end
  #-----------------------------------------------------------------------------
  # Gets lists of filtered Pokemon based on the inputted raid rank.
  #-----------------------------------------------------------------------------
  rank1, rank2, rank3, rank4, rank5 = pbGetMaxRaidSpeciesLists(poke,false,env)
  raidrank  = rank1         if rank<=1
  raidrank  = rank2 + rank1 if rank==2
  raidrank  = rank3 + rank2 if rank==3
  raidrank  = rank4 + rank3 if rank==4 || rank==5
  raidrank  = rank5         if rank==6
  #-----------------------------------------------------------------------------
  # Gets a particular eligible species.
  #-----------------------------------------------------------------------------
  if poke.is_a?(Array)
    species = raidrank[rand(raidrank.length)]
  else
    if raidrank.length>0
      species = raidrank[rand(raidrank.length)]
    else
      mRank1  = rank2 + rank1
      mRank2  = rank3 + rank2
      mRank3  = rank4 + rank3
      if mRank1.length>0; species, rank = mRank1[rand(mRank1.length)], 2; end
      if mRank2.length>0; species, rank = mRank2[rand(mRank2.length)], 3; end
      if mRank3.length>0; species, rank = mRank3[rand(mRank3.length)], 4; end
      if rank4.length>0;  species, rank = rank4[rand(rank4.length)],   5; end
      if rank5.length>0;  species, rank = rank5[rand(rank5.length)],   6; end
    end
  end
  species = [PBSpecies::DITTO,0,nil] if !species
  return species, rank
end

#===============================================================================
# Used to obtain eligible species lists for a Max Raid Database event.
#===============================================================================
def pbGetMaxRaidSpecies2(filters=nil,rank=nil)
  rank1, rank2, rank3, rank4, rank5 = pbGetMaxRaidSpeciesLists(filters,true)
  #-----------------------------------------------------------------------------
  # Gets an array of filtered Pokemon based on the inputted raid level.
  #-----------------------------------------------------------------------------
  metarank1  = rank2 + rank1
  metarank2  = rank3 + rank2
  metarank3  = rank4 + rank3
  totalrank  = rank1
  totalrank += rank2 if $Trainer.numbadges>0
  totalrank += rank3 if $Trainer.numbadges>=3
  totalrank += rank4 if $Trainer.numbadges>=6
  totalrank += rank5 if $Trainer.numbadges>=8
  if !rank
    return totalrank 
  else
    return rank1     if rank==1
    return metarank1 if rank==2
    return metarank2 if rank==3
    return metarank3 if rank==4 || rank==5
    return rank5     if rank==6
  end
end

#===============================================================================
# Determines compatible moves to build a Max Raid Pokemon's moveset.
#===============================================================================
def pbGetMaxRaidMoves(poke,form)
  stabmoves  = []            # List of all eligible STAB moves.
  basemoves  = []            # List of all eligible coverage moves.
  multmoves  = []            # List of all eligible spread moves.
  healmoves  = []            # List of all eligible support moves.
  #-----------------------------------------------------------------------------
  # Moves that are ignored when compiling movelists.
  #-----------------------------------------------------------------------------
  blacklist  = ["0CE","0DE", # Sky Drop, Dream Eater
                "115","090", # Focus Punch, Hidden Power
                "012","174", # Fake Out, First Impression
                "0C2","0E0", # Recharge moves, Self-KO moves
                "0EC","125", # Circle Throw/Dragon Tail, Last Resort
                "195","196", # Steel Roller, Misty Explosion
                "192","03F"] # Poltergeist, Stat Down moves (Overheat, Draco Meteor, etc.)
  #-----------------------------------------------------------------------------
  # Eligible support moves.
  #-----------------------------------------------------------------------------
  whitelist  = ["0D6","0D7", # Roost, Wish
                "160","16D", # Strength Sap, Shore Up
                "0D5","0D8", # Heal moves, Weather heal moves
                "0DA","0DB", # Aqua Ring, Ingrain
                "02F","033", # +2 Defense moves, +2 Sp.Def moves
                "02A","034", # Cosmic Power, Minimize
                "14B","14C", # King's Shield, Spiky Shield
                "168","14E", # Baneful Bunker, Geomancy
                "038","189", # Cotton Guard, Jungle Healing
                "181","180", # Octolock, Obstruct
                "17F","17E"] # No Retreat, Life Dew
  #-----------------------------------------------------------------------------
  fSpecies   = pbGetFSpeciesFromForm(poke,form)
  moveData   = pbLoadMovesData
  legalMoves = pbGetLegalMoves(fSpecies)
  ptype1     = pbGetSpeciesData(poke,form,SpeciesType1)
  ptype2     = pbGetSpeciesData(poke,form,SpeciesType2)
  for move in 0...moveData.length
    next if !legalMoves.include?(move) &&
            !pbSpeciesCompatible?(fSpecies,move)
    type     = pbGetMoveData(move,MOVE_TYPE)
    target   = pbGetMoveData(move,MOVE_TARGET)
    accuracy = pbGetMoveData(move,MOVE_ACCURACY)
    damage   = pbGetMoveData(move,MOVE_BASE_DAMAGE)
    function = pbGetMoveData(move,MOVE_FUNCTION_CODE)
    mult     = (target==4 || target==8)
    stab     = (type==ptype1 || type==ptype2)
    #---------------------------------------------------------------------------
    # Filters through all eligible moves that meet the criteria.
    #---------------------------------------------------------------------------
    next if accuracy>0 && accuracy<70
    next if !function || blacklist.include?(function)
    if whitelist.include?(function)
      healmoves.push(move)  # All eligible support moves.
    elsif damage>=55 && mult
      multmoves.push(move)  # All eligible spread moves.
    elsif damage>=80 && stab
      stabmoves.push(move)  # All eligible STAB moves.
    elsif damage>=70 && !stab && type!=0
      basemoves.push(move)  # All eligible coverage moves.
    end
  end
  #-----------------------------------------------------------------------------
  # Forces certain moves onto specific species' movelists.
  #-----------------------------------------------------------------------------
  if poke==getID(PBSpecies,:SNORLAX)
    healmoves.push(getID(PBMoves,:REST))
  elsif poke==getID(PBSpecies,:SHUCKLE)
    healmoves.push(getID(PBMoves,:POWERTRICK))
  elsif poke==getID(PBSpecies,:SLAKING)
    stabmoves.push(getID(PBMoves,:GIGAIMPACT))
  elsif poke==getID(PBSpecies,:CASTFORM)
    stabmoves.push(getID(PBMoves,:WEATHERBALL))
  elsif poke==getID(PBSpecies,:ROTOM) 
    healmoves.push(getID(PBMoves,:OVERHEAT))  if form==1
    healmoves.push(getID(PBMoves,:HYDROPUMP)) if form==2
    healmoves.push(getID(PBMoves,:BLIZZARD))  if form==3
    healmoves.push(getID(PBMoves,:AIRSLASH))  if form==4
    healmoves.push(getID(PBMoves,:LEAFSTORM)) if form==5
  elsif poke==getID(PBSpecies,:DARKRAI)
    healmoves.push(getID(PBMoves,:DARKVOID))
  elsif poke==getID(PBSpecies,:GENESECT)
    basemoves.push(getID(PBMoves,:TECHNOBLAST))
  elsif poke==getID(PBSpecies,:ORICORIO)
    stabmoves.push(getID(PBMoves,:REVELATIONDANCE))
  elsif poke==getID(PBSpecies,:MELMETAL)
    stabmoves.push(getID(PBMoves,:DOUBLEIRONBASH))
  elsif poke==getID(PBSpecies,:SIRFETCHD)
    stabmoves.push(getID(PBMoves,:METEORASSAULT))
  elsif poke==getID(PBSpecies,:DRAGAPULT)
    stabmoves.push(getID(PBMoves,:DRAGONDARTS))
  elsif poke==getID(PBSpecies,:URSHIFU)
    stabmoves.push(getID(PBMoves,:SURGINGSTRIKES)) if form==1
  end
  return [stabmoves,basemoves,multmoves,healmoves]
end

#===============================================================================
# Determines Technical Records rewarded by a Max Raid Pokemon, based on type.
# Won't do anything if Technical Records aren't installed.
#===============================================================================
def pbGetTechnicalRecordByType(pokemon)
  trList   = []
  if defined?(pokemon.trmoves)
    type1    = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesType1)
    type2    = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesType2)
    itemData = pbLoadItemsData
    for i in 0...itemData.length
      next if !itemData[i]
      next if !pbIsTechnicalRecord?(i)
      move = pbGetMachine(i)
      type = pbGetMoveData(move,MOVE_TYPE)
      next if type!=type1 && type!=type2
      trList.push(i)
    end
  end
  return trList
end

#===============================================================================
# Gets the base stat total of a particular form of a species.
#===============================================================================
def pbBaseStatTotalForm(species,form)
  baseStats = pbGetSpeciesData(species,form,SpeciesBaseStats)
  ret = 0
  baseStats.each { |s| ret += s }
  return ret
end

#===============================================================================
# Gets relevant display names in the Raid Database for Pokemon forms.
#===============================================================================
def pbGetRaidFormName(poke,form)
  baseform = [:BURMY,:WORMADAM,:SHELLOS,:GASTRODON,:BASCULIN,:DEERLING,
              :SAWSBUCK,:TORNADUS,:THUNDURUS,:LANDORUS,:MEOWSTIC,:LYCANROC,
              :ORICORIO,:INDEEDEE,:TOXTRICITY,:URSHIFU]
  for i in baseform; basename = true if poke==getID(PBSpecies,i); end
  if form>0 || basename
    fSpecies = pbGetFSpeciesFromForm(poke,form)
    fname    = pbGetMessage(MessageTypes::FormNames,fSpecies)
    formname = "" 
    if fname && fname!="" && fname!=PBSpecies.getName(poke)
      formname = _INTL(" ({1})",fname)
    end
  end
  return formname
end
    
#===============================================================================
# Prepares a Pokemon for a Max Raid battle.
#===============================================================================  
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[MAXRAID_SWITCH]
    #---------------------------------------------------------------------------
    # Gets raid boss attributes depending on the type of event.
    #---------------------------------------------------------------------------
    hardmode   = $game_switches[HARDMODE_RAID]
    storedPkmn = pbMapInterpreter.get_character(0).id + MAXRAID_PKMN
    # Debug Raid Pokemon (Max Raid Database)
    if $game_variables[MAXRAID_PKMN].is_a?(Array)
      raidtype   = 0
      bosspoke   = $game_variables[MAXRAID_PKMN][0]
      bossform   = $game_variables[MAXRAID_PKMN][1]
      bossgender = $game_variables[MAXRAID_PKMN][2]
      bosslevel  = $game_variables[MAXRAID_PKMN][3]
      gmax       = $game_variables[MAXRAID_PKMN][4]
    # Max Raid Pokemon (New Den Pokemon)
    elsif $game_variables[storedPkmn].is_a?(Array)
      raidtype   = 1
      bosspoke   = $game_variables[storedPkmn][0]
      bossform   = $game_variables[storedPkmn][1]
      bossgender = $game_variables[storedPkmn][2]
      bosslevel  = $game_variables[storedPkmn][3]
      gmax       = $game_variables[storedPkmn][4]
    # Max Raid Pokemon (Existing Den Pokemon)
    elsif $game_variables[storedPkmn].is_a?(PokeBattle_Pokemon)
      raidtype   = 2
      bosspoke   = $game_variables[storedPkmn].species
      bossform   = $game_variables[storedPkmn].form
      bossgender = $game_variables[storedPkmn].gender
      bosslevel  = $game_variables[storedPkmn].level
      bossmoves  = $game_variables[storedPkmn].moves
      bossnature = $game_variables[storedPkmn].nature
      bossabil   = $game_variables[storedPkmn].abilityflag
      bossiv     = $game_variables[storedPkmn].iv
      shinyboss  = $game_variables[storedPkmn].shiny?
      shadowboss = $game_variables[storedPkmn].shadowPokemon?
      gmax       = $game_variables[storedPkmn].gmaxFactor?
    end
    gmax = true if bosspoke==getID(PBSpecies,:ETERNATUS)
    #---------------------------------------------------------------------------
    # Gets the raid rank and Dynamax Level based on raid Pokemon's level.
    #---------------------------------------------------------------------------
    rank = 1 if bosslevel>=15
    rank = 2 if bosslevel>=30
    rank = 3 if bosslevel>=40
    rank = 4 if bosslevel>=50
    rank = 5 if bosslevel>=60
    rank = 6 if bosslevel==70
    dlvl = 5  if rank==1
    dlvl = 10 if rank==2
    dlvl = 20 if rank==3
    dlvl = 30 if rank==4
    dlvl = 40 if rank==5
    dlvl = 50 if rank==6
    dlvl+= rank*2 if hardmode
    #---------------------------------------------------------------------------
    # Sets the raid attributes for a newly generated wild species.
    #---------------------------------------------------------------------------
    pokemon.species = bosspoke
    if raidtype==2
      pokemon.moves = bossmoves
      pokemon.setNature(bossnature)
      pokemon.setAbility(bossabil)
      pokemon.makeShiny if shinyboss
      pokemon.makeShadow if shadowboss
      for i in 0...6; pokemon.iv[i] = bossiv[i]; end
    else
      raidmoves = pbGetMaxRaidMoves(bosspoke,bossform)
      move1     = raidmoves[0][rand(raidmoves[0].length)]
      move2     = raidmoves[1][rand(raidmoves[1].length)]
      move3     = raidmoves[2][rand(raidmoves[2].length)]
      move4     = raidmoves[3][rand(raidmoves[3].length)]
      pokemon.pbLearnMove(move1) if raidmoves[0].length>0
      pokemon.pbLearnMove(move2) if raidmoves[1].length>0
      pokemon.pbLearnMove(move3) if raidmoves[2].length>0
      pokemon.pbLearnMove(move4) if raidmoves[3].length>0
      pokemon.setAbility(2) if rank==4  && rand(10)<2
      pokemon.setAbility(2) if rank==5  && rand(10)<5
      pokemon.setAbility(2) if hardmode && rand(10)<8
      # Scales randomized IV's to match the raid level.
      maxIV = 1
      pokemon.iv[rand(6)]=31
      randivs = [0,1,2,3,4,5]
      for i in randivs.shuffle
        next if pokemon.iv[i]==31
        maxIV +=1
        pokemon.iv[i]=31 
        break if maxIV>=rank
      end
    end
    pokemon.setGender(bossgender)
    pokemon.form = bossform
    pokemon.setDynamaxLvl(dlvl)
    pokemon.giveGMaxFactor if pokemon.hasGmax? && gmax
    pbCustomRaidSets(pokemon,bossform) if raidtype<2
    pokemon.obtainText = _INTL("Max Raid Den.")
    pokemon.makeDynamax
    pokemon.calcStats
    pokemon.hp = pokemon.totalhp
    pokemon.pbReversion(true)
    $game_variables[storedPkmn] = pokemon if raidtype>0
  end
}

################################################################################
# SECTION 3 - MAX RAID DEN EVENT
#===============================================================================
# Sets up an event to access a Max Raid Den.
#===============================================================================
class MaxRaidScene
  BASE   = Color.new(248,248,248)
  SHADOW = Color.new(0,0,0)
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
   
  def pbEndScene
    pbUpdate
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbResetRaidSettings
  end
  
#===============================================================================
# Sets up Pokemon data for the event.
#===============================================================================
  def pbStartScene(size,rank,pkmn,loot,field,gmax,hard,storedPkmn)
    pbResetRaidSettings
    @viewport   = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @loot       = loot ? loot : nil
    @size       = size ? size : MAXRAID_SIZE
    @weather    = field.is_a?(Array) ? field[0] : 0
    @terrain    = field.is_a?(Array) ? field[1] : 0
    @environ    = field.is_a?(Array) ? field[2] : field
    @weather    = rand(5) if @weather==-1
    @terrain    = rand(5) if @terrain==-1
    @environ    = rand(PBEnvironment.maxValue) if @environ==-1
    #---------------------------------------------------------------------------
    # Determines Raid Pokemon data of an existing raid species.
    #---------------------------------------------------------------------------
    if $game_variables[storedPkmn]!=0
      if $game_variables[storedPkmn].is_a?(PokeBattle_Pokemon)
        pkmn      = $game_variables[storedPkmn]
        poke      = pkmn.species
        form      = pkmn.form
        gender    = pkmn.gender
        level     = pkmn.level
        makegmax  = pkmn.gmaxFactor?
      else
        pkmn      = $game_variables[storedPkmn]
        poke      = pkmn[0]
        form      = pkmn[1]
        gender    = pkmn[2]
        level     = pkmn[3]
        makegmax  = pkmn[4]
      end
      rank = 1 if level>=15
      rank = 2 if level>=30
      rank = 3 if level>=40
      rank = 4 if level>=50
      rank = 5 if level>=60
      rank = 6 if level>=70
    else
      #-------------------------------------------------------------------------
      # Determines Raid Pokemon data of a newly spawned species.
      #-------------------------------------------------------------------------
      stars  = []
      stars1 = 15+rand(5) # 1 Star Pokemon raid levels: 15-20
      stars2 = 30+rand(5) # 2 Star Pokemon raid levels: 30-35
      stars3 = 40+rand(5) # 3 Star Pokemon raid levels: 40-45
      stars4 = 50+rand(5) # 4 Star Pokemon raid levels: 50-55
      stars5 = 60+rand(5) # 5 Star Pokemon raid levels: 60-65
      stars.push(stars1) if $Trainer.numbadges<6
      stars.push(stars2) if $Trainer.numbadges<8 && $Trainer.numbadges>0
      stars.push(stars3) if $Trainer.numbadges>=3
      stars.push(stars4) if $Trainer.numbadges>=6
      stars.push(stars5) if $Trainer.numbadges>=8
      if !rank
        level = stars[rand(stars.length)] # Random raid rank if rank is nil
        rank = 1 if level>=15
        rank = 2 if level>=30
        rank = 3 if level>=40
        rank = 4 if level>=50
        rank = 5 if level>=60
      end
      species, rank = pbGetMaxRaidSpecies(pkmn,rank,@environ)
      poke   = species[0]
      form   = species[1]
      gender = species[2]
      level  = stars1 if rank<=1
      level  = stars2 if rank==2
      level  = stars3 if rank==3
      level  = stars4 if rank==4
      level  = stars5 if rank>=5
      level  = 70 if rank>=6
      if pbGmaxSpecies?(poke,form)
        gmaxchance = rand(10)
        makegmax = true if rank==3 && gmaxchance<2
        makegmax = true if rank==4 && gmaxchance<3
        makegmax = true if rank>=5 && gmaxchance<5
        makegmax = true if gmax
      else
        makegmax = false
      end
    end
    $game_switches[HARDMODE_RAID] = true if hard || rank==6
    #---------------------------------------------------------------------------
    # Saves the game and begins Raid Event.
    #---------------------------------------------------------------------------
    @sprites    = {}
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    # Hold CTRL in Debug to skip saving prompt.
    if $game_variables[storedPkmn]!=0 || ($DEBUG && Input.press?(Input::CTRL))
      pbMessage(_INTL("You peered into the raid den before you..."))
      if !$game_variables[storedPkmn].is_a?(PokeBattle_Pokemon)
        $game_variables[storedPkmn] = [poke,form,gender,level,makegmax]
      end
      pbMaxRaidEntry(rank,storedPkmn)
    else
      if pbConfirmMessage(_INTL("You must save the game before entering a new raid den. Is this ok?"))
        if safeExists?(RTP.getSaveFileName("Game.rxdata"))
          if $PokemonTemp.begunNewGame
            pbMessage(_INTL("WARNING!"))
            pbMessage(_INTL("There is a different game file that is already saved."))
            pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
            if !pbConfirmMessageSerious(
              _INTL("Are you sure you want to save now and overwrite the other save file?"))
              pbSEPlay("GUI save choice")
            else
              $game_variables[storedPkmn] = [poke,form,gender,level,makegmax]
              pbSave
              pbSEPlay("GUI save choice")
              pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]",$Trainer.name))
              pbMaxRaidEntry(rank,storedPkmn)
            end
          else
            $game_variables[storedPkmn] = [poke,form,gender,level,makegmax]
            pbSave
            pbSEPlay("GUI save choice")
            pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]",$Trainer.name))
            pbMaxRaidEntry(rank,storedPkmn)
          end
        end
      end
    end
  end

#===============================================================================
# Draws the Max Raid entry screen.
#=============================================================================== 
  def pbMaxRaidEntry(rank,storedPkmn)
    hardmode     = $game_switches[HARDMODE_RAID]
    raidboss     = $game_variables[storedPkmn]
    if raidboss.is_a?(PokeBattle_Pokemon)
      bosspoke   = raidboss.species
      bossform   = raidboss.form
      bossgender = raidboss.gender
      bosslevel  = raidboss.level
      gmax       = raidboss.gmaxFactor?
    elsif raidboss.is_a?(Array)
      bosspoke   = raidboss[0]
      bossform   = raidboss[1]
      bossgender = raidboss[2]
      bosslevel  = raidboss[3]
      gmax       = raidboss[4]
    end
    @sprites["raidentry"]  = IconSprite.new(0,0)
    @sprites["raidentry"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_entry")
    @sprites["pokeicon"]   = PokemonSpeciesIconSprite.new(bosspoke,@viewport)
    @sprites["pokeicon"].pbSetParams(bosspoke,bossgender,bossform,false,gmax)
    @sprites["pokeicon"].x = 95
    @sprites["pokeicon"].y = 132
    if gmax && GMAX_XL_ICONS
      @sprites["pokeicon"].x -= 12
      @sprites["pokeicon"].y -= 12
    else
      @sprites["pokeicon"].zoom_x = 1.5
      @sprites["pokeicon"].zoom_y = 1.5
    end
    @sprites["pokeicon"].color.alpha = 255
    @sprites["raidstar1"] = IconSprite.new(-100,64)
    @sprites["raidstar1"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar2"] = IconSprite.new(-100,64)
    @sprites["raidstar2"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar3"] = IconSprite.new(-100,64)
    @sprites["raidstar3"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar4"] = IconSprite.new(-100,64)
    @sprites["raidstar4"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar5"] = IconSprite.new(-100,64)
    @sprites["raidstar5"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar1"].x = 10
    @sprites["raidstar2"].x = 50  if rank>=2
    @sprites["raidstar3"].x = 90  if rank>=3
    @sprites["raidstar4"].x = 130 if rank>=4
    @sprites["raidstar5"].x = 170 if rank>=5
    @overlay = @sprites["overlay"].bitmap
    #---------------------------------------------------------------------------
    # Party display.
    #---------------------------------------------------------------------------
    party = 0
    icons = 0
    for i in $Trainer.ablePokemonParty; party += 1; end
    @size = 4 if party<5 && @size>=5
    @size = 3 if party<4 && @size>=4
    @size = 3 if @size>3 && !defined?(PCV)
    @size = 2 if party<3 && @size>=3
    @size = 1 if party<2 && @size>=2
    for i in 0...party
      @sprites["partybg#{i}"] = IconSprite.new(-100,252)
      @sprites["partybg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
    end
    for i in 0...$Trainer.party.length
      next if $Trainer.party[i].egg? || $Trainer.party[i].fainted?
      species = $Trainer.party[i].species
      gender  = $Trainer.party[i].gender
      form    = $Trainer.party[i].form
      @sprites["pkmnsprite#{icons}"] = PokemonSpeciesIconSprite.new(species,@viewport)
      @sprites["pkmnsprite#{icons}"].pbSetParams(species,gender,form)
      @sprites["pkmnsprite#{icons}"].y       = 250
      @sprites["pkmnsprite#{icons}"].zoom_x  = 0.5
      @sprites["pkmnsprite#{icons}"].zoom_y  = 0.5
      @sprites["pkmnsprite#{icons}"].visible = false
      icons += 1
      break if icons==@size
    end
    partyX = 127-(19*@size)
    for i in 0...@size
      @sprites["partybg#{i}"].x          = partyX+(37*i)
      @sprites["pkmnsprite#{i}"].x       = @sprites["partybg#{i}"].x+2
      @sprites["pkmnsprite#{i}"].visible = true
    end
    #---------------------------------------------------------------------------
    # Battlefield display.
    #---------------------------------------------------------------------------
    land = 0
    case @environ           # Raid Tags:
    when 0;       land = 1  # Urban      (None)
    when 1, 2;    land = 2  # Grassland  (Grass, Tall Grass)
    when 3, 4;    land = 3  # Aquatic    (Moving Water, Still Water)
    when 5;       land = 4  # Wetlands   (Puddle)
    when 6;       land = 5  # Underwater
    when 7;       land = 6  # Cavern     (Cave)
    when 8;       land = 7  # Earth      (Rocky)
    when 9;       land = 8  # Sandy      (Sand)
    when 10, 11;  land = 9  # Forest     (Forest, Forest Grass)
    when 12, 13;  land = 10 # Frosty     (Snow, Ice)
    when 14;      land = 11 # Volcanic   (Volcano)
    when 15;      land = 12 # Spiritual  (Graveyard)
    when 16;      land = 13 # Sky
    when 17;      land = 14 # Space
    when 18;      land = 15 # Ultra Space
    end
    conds = []
    conds.push(@weather) if @weather
    conds.push(@terrain) if @terrain
    conds.push(land)     if @environ
    @sprites["fieldbg"] = IconSprite.new(295,16)
    @sprites["fieldbg"].setBitmap("Graphics/Pictures/Dynamax/raid_field_bg")
    @sprites["fieldbg"].visible = false
    fieldbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raid_field"))
    if (@weather+@terrain)==0 && land>0
      @sprites["fieldbg"].visible = true
      @overlay.blt(444,38,fieldbitmap.bitmap,Rect.new(land*58,64,58,32))
    elsif @weather>0 || @terrain>0 || land>0
      xpos = -1
      @sprites["fieldbg"].visible = true
      for i in 0...conds.length
        xpos += 1 if conds[i]>0
        @overlay.blt(444-(xpos*58),38,fieldbitmap.bitmap,Rect.new(conds[i]*58,i*32,58,32)) if conds[i]>0
      end
    end
    #---------------------------------------------------------------------------
    # Extra raid conditions display.
    #---------------------------------------------------------------------------
    extras = []
    @sprites["gmax"] = IconSprite.new(-100,94)
    @sprites["gmax"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
    @sprites["hard"] = IconSprite.new(-100,80)
    @sprites["hard"].setBitmap("Graphics/Pictures/Dynamax/raid_hard")
    @sprites["loot"] = IconSprite.new(-100,80)
    @sprites["loot"].setBitmap("Graphics/Pictures/Dynamax/raid_loot")
    extras.push(@sprites["gmax"]) if gmax
    extras.push(@sprites["hard"]) if hardmode
    extras.push(@sprites["loot"]) if @loot
    for i in 0...extras.length
      extras[i].x = 460-(i*54)
    end
    #---------------------------------------------------------------------------
    # Raid Pokemon type display.
    #---------------------------------------------------------------------------
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    type1      = pbGetSpeciesData(bosspoke,bossform,SpeciesType1)
    type2      = pbGetSpeciesData(bosspoke,bossform,SpeciesType2)
    type1rect  = Rect.new(0,type1*32,96,32)
    type2rect  = Rect.new(0,type2*32,96,32)
    @overlay.blt(10,106,typebitmap.bitmap,type1rect)
    @overlay.blt(110,106,typebitmap.bitmap,type2rect) if type1!=type2
    #---------------------------------------------------------------------------
    # Text displays.
    #---------------------------------------------------------------------------
    textPos = []
    textPos.push([_INTL("MAX RAID DEN"),25,26,0,BASE,SHADOW])
    textPos.push([_INTL("Leave Den (X)"),363,148,0,BASE,SHADOW])
    textPos.push([_INTL("Enter Den (C)"),363,211,0,BASE,SHADOW])
    textPos.push([_INTL("View Party (Z)"),67,289,0,BASE,SHADOW])
    timerbonus = ((bosslevel+5)/10).floor+1 if @size==1
    timerbonus = ((bosslevel+5)/20).ceil+1  if @size==2
    turns      = MAXRAID_TIMER
    turns     += timerbonus if bosslevel>20 && @size<3
    turns      = 5 if turns<5
    turns      = 25 if turns>25
    kocount    = MAXRAID_KOS
    kocount   -=1 if bosslevel>55
    battletext  = _INTL("Battle ends in {1} turns, or after {2} knock outs.",turns,kocount)
    pbSetSmallFont(@overlay)
    pbDrawTextPositions(@overlay,textPos)
    drawTextEx(@overlay,287,268,220,2,battletext,BASE,SHADOW)
    #---------------------------------------------------------------------------
    # Selection loop.
    #---------------------------------------------------------------------------
    loop do
      Graphics.update
      Input.update
      pbUpdate
      #-------------------------------------------------------------------------
      # Accesses Party screen and updates party display.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::A)
        pbPlayCancelSE
        Input.update
        pbPokemonScreen
        icons = 0
        for i in 0...$Trainer.party.length
          next if $Trainer.party[i].egg? || $Trainer.party[i].fainted?
          species = $Trainer.party[i].species
          gender  = $Trainer.party[i].gender
          form    = $Trainer.party[i].form
          @sprites["pkmnsprite#{icons}"].pbSetParams(species,gender,form)
          icons += 1
          break if icons==@size
        end
      end
      #-------------------------------------------------------------------------
      # Sets up and accesses the Raid battle.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::C)
        if pbConfirmMessage(_INTL("Enter the raid den?"))
          pbFadeOutIn(99999){
            pbSEPlay("Door enter")
            Input.update
            pbDisposeSpriteHash(@sprites)
            @viewport.dispose
            #-------------------------------------------------------------------
            # Gets the environmental properties of the battle.
            #-------------------------------------------------------------------
            @environ  = 7 if !@environ
            openSpace = true if (pbGetEnvironment==PBEnvironment::Sky || 
                                 pbGetEnvironment==PBEnvironment::Space || 
                                 pbGetEnvironment==PBEnvironment::UltraSpace)
            case @environ                              # Raid Tags:
            when 0;      bg = base = "city"            # Urban
            when 1, 2;   bg = "field"; base = "grass"  # Grassland
            when 3, 4;   bg = base = "water"           # Aquatic
            when 5;      bg = "water"; base = "puddle" # Wetlands
            when 6;      bg = base = "underwater"      # Underwater
            when 7;      bg = base = "cave3"           # Cavern
            when 8, 14;  bg = base = "rocky"           # Earth, Volcanic
            when 9;      bg = "rocky"; base = "sand"   # Sandy
            when 10;     bg = base = "forest"          # Forest
            when 11;     bg = "forest"; base = "grass" # Forest
            when 12;     bg = base = "snow"            # Frosty
            when 13;     bg = "snow"; base = "ice"     # Frosty
            when 15;     bg = base = "distortion"      # Spiritual
            when 16;     bg = base = "sky"             # Sky
            when 17, 18; bg = base = "space"           # Space, Ultra Space
            end
            #-------------------------------------------------------------------
            # Finalizes battle rules and begins the raid battle.
            #-------------------------------------------------------------------
            setBattleRule("noPartner")
            setBattleRule(sprintf("%dv%d",@size,1)) # Raid size
            setBattleRule("weather",@weather) if @weather
            setBattleRule("terrain",@terrain) if @terrain
            setBattleRule("environ",@environ) if @environ && !openSpace
            setBattleRule("base",base)        if base && !openSpace
            setBattleRule("backdrop",bg)      if bg && !openSpace
            $PokemonGlobal.nextBattleBGM = (rank==6) ? "Max Raid Battle (Legendary)" : "Max Raid Battle"
            $PokemonGlobal.nextBattleBGM = "Eternamax Battle" if bosspoke==getID(PBSpecies,:ETERNATUS)
            pbMessage(_INTL("\\me[Max Raid Intro]You ventured into the den...\\wt[34] ...\\wt[34] ...\\wt[60]!\\wtnp[8]")) if !$DEBUG
            $game_switches[MAXRAID_SWITCH] = true
            #-------------------------------------------------------------------
            # Compatibility with Modular Battle Scene.
            #-------------------------------------------------------------------
            $PokemonSystem.activebattle = true if @size>=3 && defined?(PCV)
            #-------------------------------------------------------------------
            pbWildBattleCore(bosspoke,bosslevel)
            pbWait(20)
            pbSEPlay("Door exit")
          }
          #---------------------------------------------------------------------
          # Displays Raid results screen and resets variable if necessary.
          #---------------------------------------------------------------------
          pbRaidRewardsScreen(rank,$game_variables[storedPkmn])
          if $game_variables[1]==1 || $game_variables[1]==4
            $game_variables[storedPkmn] = 1
            for i in $Trainer.party; i.heal; end
          end
          break
        end
      end
      #-------------------------------------------------------------------------
      # Exits the Raid event and saves the Raid Pokemon to a variable.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::B)
        if pbConfirmMessage(_INTL("Would you like to leave the raid den?"))
          $game_variables[storedPkmn]  = [bosspoke,bossform,bossgender,bosslevel,gmax]
          $game_variables[storedPkmn]  = 0 if ($DEBUG && Input.press?(Input::CTRL)) 
          Input.update
          pbEndScene
          break
        end
      end
    end
  end
  
#===============================================================================
# Max Raid rewards screen.
#===============================================================================
  def pbRaidRewardsScreen(rank,pkmn)
    @sprites    = {}
    @viewport   = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["rewardscreen"] = IconSprite.new(0,0)
    @sprites["rewardscreen"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_rewards")
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(pkmn)
    @sprites["raidstar1"] = IconSprite.new(-100,64)
    @sprites["raidstar1"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar2"] = IconSprite.new(-100,64)
    @sprites["raidstar2"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar3"] = IconSprite.new(-100,64)
    @sprites["raidstar3"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar4"] = IconSprite.new(-100,64)
    @sprites["raidstar4"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    @sprites["raidstar5"] = IconSprite.new(-100,64)
    @sprites["raidstar5"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    if rank<=1
      @sprites["raidstar1"].x = 365
    elsif rank==2
      @sprites["raidstar1"].x = 345
      @sprites["raidstar2"].x = 385
    elsif rank==3
      @sprites["raidstar1"].x = 325
      @sprites["raidstar2"].x = 365
      @sprites["raidstar3"].x = 405
    elsif rank==4
      @sprites["raidstar1"].x = 305
      @sprites["raidstar2"].x = 345
      @sprites["raidstar3"].x = 385
      @sprites["raidstar4"].x = 425
    elsif rank>=5
      @sprites["raidstar1"].x = 285
      @sprites["raidstar2"].x = 325
      @sprites["raidstar3"].x = 365
      @sprites["raidstar4"].x = 405
      @sprites["raidstar5"].x = 445
    end
    @sprites["gmax"] = IconSprite.new(140,82)
    @sprites["gmax"].setBitmap("Graphics/Pictures/Dynamax/gfactor") if pkmn.gmaxFactor?
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    #---------------------------------------------------------------------------
    # Text displays.
    #---------------------------------------------------------------------------
    textPos = []
    condition     = $game_variables[1]
    result        = "lost to"
    lvldisplay    = "???"
    abildisplay   = "???"
    if condition==1
      result      = "defeated"
    elsif condition==4
      result      = "caught"
      lvldisplay  = pkmn.level
      abildisplay = PBAbilities.getName(pkmn.ability)
      if pkmn.male?
        gendermark = "♂"
        textPos.push([gendermark,20,80,0,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pkmn.female?
        gendermark = "♀"
        textPos.push([gendermark,20,80,0,Color.new(248,56,32),Color.new(224,152,144)])
      end
    end
    result  = _INTL("You {1} {2}!",result,PBSpecies.getName(pkmn.species))
    textPos.push([result,270,26,0,BASE,SHADOW])
    textPos.push([_INTL("Press X to Exit"),320,288,0,BASE,SHADOW])
    textPos.push([_INTL("Lvl. {1}",lvldisplay),38,82,0,BASE,SHADOW])
    textPos.push([_INTL("Ability: {1}",abildisplay),20,288,0,BASE,SHADOW])
    textPos.push([_INTL("No Rewards Earned."),296,174,0,BASE,SHADOW]) if condition==2 || condition==3
    pbSetSmallFont(@overlay)
    pbDrawTextPositions(@overlay,textPos)
    #---------------------------------------------------------------------------
    # Rewards display for captured/defeated Raid Pokemon.
    #---------------------------------------------------------------------------
    if condition==1 || condition==4
      bonuses  = $game_variables[REWARD_BONUSES]
      bonusTIMER    = true if bonuses[0]>MAXRAID_TIMER/2.floor
      bonusPERFECT  = true if bonuses[1]==true
      bonusFAIRNESS = true if bonuses[2]==true
      bonusCAPTURE  = true if condition==4
      bonusHARDMODE = true if $game_switches[HARDMODE_RAID]
      bonusRewards  = true if (bonusTIMER || bonusPERFECT || bonusFAIRNESS || bonusCAPTURE || bonusHARDMODE)
      if bonusRewards
        @sprites["bonusbg"] = IconSprite.new(0,16)
        @sprites["bonusbg"].setBitmap("Graphics/Pictures/Dynamax/raid_bonus_bg")
        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        bonusbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raid_bonus"))
        @bonuses = []
        hardmode = 0
        perfect  = 1
        timer    = 2
        fairness = 3
        capture  = 4
        @bonuses.push(hardmode) if bonusHARDMODE
        @bonuses.push(perfect)  if bonusPERFECT
        @bonuses.push(timer)    if bonusTIMER
        @bonuses.push(fairness) if bonusFAIRNESS
        @bonuses.push(capture)  if bonusCAPTURE
        for i in 0...@bonuses.length
          @overlay.blt(i*41,38,bonusbitmap.bitmap,Rect.new(@bonuses[i]*41,0,41,33))
        end
      end
      rewards = pbGetMaxRaidRewards(rank,pkmn)
      items   = []
      for i in 0...rewards.length
        qty    = rewards[i][1]
        item   = rewards[i][0]
        itemid = getID(PBItems,item)
        next if !itemid || itemid==0
        move   = pbGetMachine(item)
        itemname = PBItems.getName(itemid)
        itemname = _INTL("{1} {2}",itemname,PBMoves.getName(move)) if move
        items.push(_INTL("{1}  x{2}",itemname,qty))
        $PokemonBag.pbStoreItem(item,qty)
      end
      @sprites["itemwindow"] = Window_CommandPokemon.newWithSize(items,260,92,258,196,@viewport)
      @sprites["itemwindow"].index = 0
      @sprites["itemwindow"].baseColor   = BASE
      @sprites["itemwindow"].shadowColor = SHADOW
      @sprites["itemwindow"].windowskin  = nil
    end
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        Input.update
        break
      end
    end
    pbEndScene
  end
  
#===============================================================================
# Determines list of rewards player recieves for beating a Max Raid.
#===============================================================================
  def pbGetMaxRaidRewards(rank,pkmn)
    rewards   = []
    hasbonus  = true if @bonuses && @bonuses.length==5
    bonus     = 1
    bonus    += @bonuses.length if @bonuses
    qty       = @size+((rank*bonus)*1.1).round   # Calculates item yield
    qty75     = qty/1.5.floor+1                  # Calculates 75% of item yield
    qty50     = qty/2.floor+1                    # Calculates 50% of item yield
    qty25     = qty/4.floor+1                    # Calculates 25% of item yield
    #---------------------------------------------------------------------------
    # Reward lists.
    #---------------------------------------------------------------------------
    expcandy  = [:EXPCANDYXS,:EXPCANDYS,:EXPCANDYM,:EXPCANDYL,:EXPCANDYXL]
    berries   = [:POMEGBERRY,:KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY]
    vitamins  = [:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS]
    training  = [:PPMAX,:ABILITYCAPSULE,:ABILITYPATCH,:BOTTLECAP,:GOLDBOTTLECAP]
    treasure1 = [:TINYMUSHROOM,:NUGGET,:PEARL,:RELICCOPPER,:RELICVASE]
    treasure2 = [:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:RELICSILVER,:RELICBAND]
    treasure3 = [:BALMMUSHROOM,:PEARLSTRING,:RELICGOLD,:RELICSTATUE,:RELICCROWN]
    bonusitem = [:DYNAMAXCANDYXL,:MAXSOUP]
    weather   = [0,:HEATROCK,:DAMPROCK,:SMOOTHROCK,:ICYROCK]
    terrain   = [0,:ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED]
    environ   = [0,:ABSORBBULB,:POWERHERB,:MYSTICWATER,:FRESHWATER,:FLOATSTONE,:SHOALSHELL,
                   :LUMINOUSMOSS,:HARDSTONE,:LIGHTCLAY,:SHEDSHELL,:MENTALHERB,:SNOWBALL,
                   :NEVERMELTICE,:BRIGHTPOWDER,:RAREBONE,:PRETTYWING,:STARDUST,:ENIGMABERRY]
    #---------------------------------------------------------------------------
    # Adds Exp. Candy rewards.
    #---------------------------------------------------------------------------
    if rank<=1
      rewards.push([expcandy[0],qty+rand(3)])
      rewards.push([expcandy[1],qty25+rand(3)])
    elsif rank==2
      rewards.push([expcandy[0],qty+rand(3)])
      rewards.push([expcandy[1],qty50+rand(3)])
    elsif rank==3
      rewards.push([expcandy[0],qty75+rand(3)])
      rewards.push([expcandy[1],qty+rand(3)])
      rewards.push([expcandy[2],qty25+rand(3)])
    elsif rank==4
      rewards.push([expcandy[0],qty75+rand(3)])
      rewards.push([expcandy[1],qty+rand(3)])
      rewards.push([expcandy[2],qty50+rand(3)])
      rewards.push([expcandy[3],qty25+rand(3)]) if rand(10)<2
    elsif rank==5
      rewards.push([expcandy[0],qty50+rand(3)]) if rand(10)<6
      rewards.push([expcandy[1],qty75+rand(3)])
      rewards.push([expcandy[2],qty+rand(3)])
      rewards.push([expcandy[3],qty50+rand(3)])
      rewards.push([expcandy[4],qty25+rand(3)])
    elsif rank>=6
      rewards.push([expcandy[0],qty25+rand(2)]) if rand(10)<2
      rewards.push([expcandy[1],qty50+rand(3)]) if rand(10)<6
      rewards.push([expcandy[2],qty75+rand(3)])
      rewards.push([expcandy[3],qty+rand(3)])
      rewards.push([expcandy[4],qty50+rand(3)])
    end
    rewards.push([:RARECANDY,qty25+rand(3)]) if rank>2
    rewards.push([:DYNAMAXCANDY,qty25+rand(3)]) if rank>2
    rewards.push([bonusitem[rand(bonusitem.length)],1]) if hasbonus && rank>2
    #---------------------------------------------------------------------------
    # Adds species-specific rewards.
    #---------------------------------------------------------------------------
    if @bonuses && @bonuses.length>2
      rewards.push([:MAXEGGS,1])   if pkmn.isSpecies?(:BLISSEY)
      rewards.push([:MAXSCALES,1]) if pkmn.isSpecies?(:LUVDISC)
      rewards.push([:MAXHONEY,1])  if pkmn.isSpecies?(:VESPIQUEN)
      if pkmn.isSpecies?(:PARASECT) ||
         pkmn.isSpecies?(:BRELOOM) ||
         pkmn.isSpecies?(:AMOONGUS) ||
         pkmn.isSpecies?(:SHIINOTIC)
        rewards.push([:MAXMUSHROOMS,1])
      end
      if pkmn.isSpecies?(:FEAROW) ||
         pkmn.isSpecies?(:NOCTOWL) ||
         pkmn.isSpecies?(:STARAPTOR) ||
         pkmn.isSpecies?(:BRAVIARY) ||
         pkmn.isSpecies?(:MANDIBUZZ) ||
         pkmn.isSpecies?(:TALONFLAME)
        rewards.push([:MAXPLUMAGE,1])
      end
    end
    #---------------------------------------------------------------------------
    # Adds Technical Record rewards.
    #---------------------------------------------------------------------------
    trList = pbGetTechnicalRecordByType(pkmn)
    rewards.push([trList[rand(trList.length)],1]) if trList && rank>2
    #---------------------------------------------------------------------------
    # Adds general rewards.
    #---------------------------------------------------------------------------
    rewards.push([berries[rand(berries.length)],qty50+rand(3)])
    rewards.push([vitamins[rand(vitamins.length)],qty25+rand(3)]) if rank>=3
    rewards.push([:PPUP,1+rand(3)]) if rank>=4 && rand(10)<2
    rewards.push([training[rand(training.length)],1])   if rank>=5 && rand(10)<1
    rewards.push([treasure1[rand(treasure1.length)],1]) if rank==3 && rand(10)<1
    rewards.push([treasure2[rand(treasure2.length)],1]) if rank==4 && rand(10)<1
    rewards.push([treasure3[rand(treasure3.length)],1]) if rank>=5 && rand(10)<1
    #---------------------------------------------------------------------------
    # Adds rewards based on field settings of the raid.
    #---------------------------------------------------------------------------
    if @weather>0 && @weather<=4 && rand(100)<25
      rewards.push([weather[@weather],1])
    end
    if @terrain>0 && rand(100)<25
      rewards.push([terrain[@terrain],1])
    end
    if @environ>0 && rand(100)<25
      rewards.push([environ[@environ],1])
    end
    #---------------------------------------------------------------------------
    # Adds manually entered custom rewards.
    #---------------------------------------------------------------------------
    if @loot!=nil
      if @loot.is_a?(Array)
        rewards.push([@loot[0],@loot[1]]) 
      else
        rewards.push([@loot,1])
      end
    end
    return rewards
  end
end

#===============================================================================
# Used to call a Max Raid Den in an event script.
#===============================================================================
def pbMaxRaid(size=nil,rank=nil,pkmn=nil,loot=nil,field=nil,gmax=false,hard=false)
  thisMap    = $game_map.map_id
  thisEvent  = pbMapInterpreter.get_character(0).id
  storedPkmn = thisEvent + MAXRAID_PKMN
  $game_switches[MAXRAID_SWITCH] = false
  $game_switches[HARDMODE_RAID]  = false
  if DMAX_ANYMAP || ($game_map && POWERSPOTS.include?(thisMap))
    pbSetEventTime
    # Forces a manual Raid Reset while holding CTRL in Debug.
    if ($DEBUG && Input.press?(Input::CTRL))
      $game_variables[storedPkmn] = 0
      pbSetSelfSwitch(thisEvent,"B",false) 
    end
    # Resets a Max Raid Den via Wishing Pieces.
    if $game_self_switches[[thisMap,thisEvent,"B"]]
      if $game_variables[storedPkmn]==1
        pbMessage(_INTL("There doesn't seem to be anything in the den..."))
        if pbConfirmMessage(_INTL("Want to throw in a Wishing Piece?"))
          if $PokemonBag.pbHasItem?(:WISHINGPIECE)
            $game_variables[storedPkmn] = 0
            $PokemonBag.pbDeleteItem(:WISHINGPIECE)
            pbMessage(_INTL("You threw a Wishing Piece into the den!"))
            pbSetSelfSwitch(thisEvent,"B",false)
          else
            pbMessage(_INTL("But you don't have any Wishing Pieces..."))
          end
        end
      end
    end
    # Begins Max Raid Den event.
    if !$game_self_switches[[thisMap,thisEvent,"B"]]
      scene  = MaxRaidScene.new
      screen = MaxRaidScreen.new(scene)
      screen.pbStartScreen(size,rank,pkmn,loot,field,gmax,hard,storedPkmn)
      if $game_variables[storedPkmn]==1
        pbSetSelfSwitch(thisEvent,"B",true)
      end
    end
  else
    pbMessage(_INTL("There appears to be a raid den here, but no Dynamax energy is present."))
  end
end

class MaxRaidScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(size,rank,pkmn,loot,field,gmax,hard,storedPkmn)
    @scene.pbStartScene(size,rank,pkmn,loot,field,gmax,hard,storedPkmn)
    @scene.pbEndScene
  end
end

#===============================================================================
# Used for resetting a Max Raid Den.
#===============================================================================
# Naturally resets after an alotted amount of time has passed.
def pbMaxRaidTime
  thisEvent  = pbMapInterpreter.get_character(0).id
  storedPkmn = thisEvent + MAXRAID_PKMN
  $game_variables[storedPkmn] = 0
  pbSetSelfSwitch(thisEvent,"A",false)
  pbSetSelfSwitch(thisEvent,"B",false)
end

# When afterLoss=false, forces the raid to reset only once its been cleared.
# When afterLoss=true, forces the raid to reset every time, even after a loss.
def pbForcedRaidReset(afterLoss=false)
  thisMap    = $game_map.map_id
  thisEvent  = pbMapInterpreter.get_character(0).id
  storedPkmn = thisEvent + MAXRAID_PKMN
  if afterLoss
    $game_variables[storedPkmn] = 0
    pbSetSelfSwitch(thisEvent,"B",false)
  else
    if $game_self_switches[[thisMap,thisEvent,"B"]]
      $game_variables[storedPkmn] = 0
      pbSetSelfSwitch(thisEvent,"B",false)
    end
  end
end
  

################################################################################
# SECTION 4 - MAX RAID DATABASE EVENT
#===============================================================================
# Sets up an event to access the Max Raid Database.
#===============================================================================
class RaidDataScene
  BASE   = Color.new(248,248,248)
  SHADOW = Color.new(104,104,104)
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbResetBattle
    @sSel     = MAXRAID_SIZE-1
    @wSel     = 0
    @tSel     = 0
    @eSel     = 7
    pbResetRaidSettings
  end
  
  def pbEndScene
    pbResetBattle
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
#===============================================================================
# Sets up Pokemon sprites, menus, and default settings.
#===============================================================================
  def pbStartScene
    @sprites     = {}
    @viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z  = 99999
    @sprites["screen"]  = IconSprite.new(0,0,@viewport)
    @sprites["screen"].setBitmap("Graphics/Pictures/Dynamax/raiddata_menu")
    @sprites["search"]  = IconSprite.new(0,0,@viewport)
    @sprites["search"].setBitmap("Graphics/Pictures/Dynamax/raiddata_search")
    @sprites["search"].visible = false
    @sprites["results"] = IconSprite.new(0,0,@viewport)
    @sprites["results"].setBitmap("Graphics/Pictures/Dynamax/raiddata_results")
    @sprites["results"].visible = false
    @xpos = 0
    @ypos = 42
    @pageLimit  = 98
    @rowLimit   = 14
    @increment  = 32
    for i in 0...@pageLimit
      @sprites["pkmnsprite#{i}"] = PokemonSpeciesIconSprite.new(0,@viewport)
      @sprites["pkmnsprite#{i}"].zoom_x  = 0.5
      @sprites["pkmnsprite#{i}"].zoom_y  = 0.5
      @sprites["pkmnsprite#{i}"].visible = false
      @xpos  = 0 if @xpos>=@rowLimit*@increment
      @xpos += @increment
      @sprites["pkmnsprite#{i}"].x = @xpos
      if i<@rowLimit
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment
      elsif i<@rowLimit*2
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*2
      elsif i<@rowLimit*3
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*3
      elsif i<@rowLimit*4
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*4
      elsif i<@rowLimit*5
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*5
      elsif i<@rowLimit*6
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*6
      else
        @sprites["pkmnsprite#{i}"].y = @ypos+@increment*7
      end
    end
    searchcmds = [
      _INTL("Show Pokémon"),
      _INTL("Filter: Raid"),
      _INTL("Filter: Type"),
      _INTL("Filter: Habitat"),
      _INTL("Filter: Region"),
      _INTL("Exit")
    ]
    @sprites["settings"] = Window_CommandPokemon.newWithSize(searchcmds,65,95,500,250,@viewport)
    @sprites["settings"].index = 0
    @sprites["settings"].baseColor   = BASE
    @sprites["settings"].shadowColor = SHADOW
    @sprites["settings"].windowskin  = nil
    @sprites["settings"].visible     = false
    @sprites["filter"] = Window_CommandPokemon.newWithSize("",160,95,300,220,@viewport)
    @sprites["filter"].index = 0
    @sprites["filter"].baseColor     = BASE
    @sprites["filter"].shadowColor   = SHADOW
    @sprites["filter"].windowskin    = nil
    @sprites["filter"].visible       = false
    @sprites["cursor"] = IconSprite.new(0,0,@viewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/Storage/cursor_point_1")
    @sprites["cursor"].zoom_x        = 0.5
    @sprites["cursor"].zoom_y        = 0.5
    @sprites["cursor"].visible       = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    #---------------------------------------------------------------------------
    # Default settings for Debug Battles
    #---------------------------------------------------------------------------
    @sSel     = MAXRAID_SIZE-1
    @wSel     = 0
    @tSel     = 0
    @eSel     = 7
    @raidlist = []
  end
  
#===============================================================================
# Search mode - Searches database for all species that match search criteria.
#===============================================================================
  def pbRaidData
    command    = 0
    raid       = nil
    type       = nil
    habitat    = nil
    region     = nil
    textPos = []
    raid = 1
    raid = 2 if $Trainer.numbadges>0
    raid = 3 if $Trainer.numbadges>=3
    raid = 4 if $Trainer.numbadges>=6
    raid = 5 if $Trainer.numbadges>=8
    pkmnCount = pbGetMaxRaidSpecies2(nil,raid).length
    textPos.push(
      [_INTL("[Raid Lvl {1}]",raid),270,143,0,BASE,SHADOW],
      [_INTL("[Any]"),270,175,0,BASE,SHADOW],
      [_INTL("[Any]"),270,207,0,BASE,SHADOW],
      [_INTL("[Any]"),270,239,0,BASE,SHADOW],
      [_INTL("Available Pokémon: {1}",pkmnCount),256,340,2,BASE,SHADOW]
    )
    pbSetSystemFont(@overlay)
    pbDrawTextPositions(@overlay,textPos)
    @sprites["settings"].visible = true
    loop do
      Graphics.update
      Input.update
      pbUpdate
      command = @sprites["settings"].index
      @sprites["search"].visible   = true
      @sprites["filter"].visible   = false
      @sprites["settings"].visible = true
      #-------------------------------------------------------------------------
      # Return all species that fit the search criteria.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::C)
        case command
        when -1, 5
          break
        when 0
          for i in 0...@pageLimit
            @sprites["pkmnsprite#{i}"].visible = false
            @sprites["pkmnsprite#{i}"].pbSetParams(0,nil,nil)
          end
          @raidlist.clear
          @raidlist = pbGetMaxRaidSpecies2([type,habitat,region],raid)
          @raidlist.push([getID(PBSpecies,:DITTO),0]) if @raidlist.length<=0
          @sprites["settings"].visible = false
          @sprites["search"].visible   = false
          @sprites["results"].visible  = true
          @overlay.clear
          pbDeactivateWindows(@sprites) { pbSpeciesSelect }
        #-----------------------------------------------------------------------
        # Filter: Raid Level
        #-----------------------------------------------------------------------
        when 1
          select = 0
          @sprites["filter"].index = 0
          loop do
            Graphics.update
            Input.update
            pbUpdate
            cmds = []
            raidlvl = []
            cmds.push(_INTL("Raid Level 1"))
            raidlvl.push(1)
            if $Trainer.numbadges>0
              cmds.push(_INTL("Raid Level 2"))
              raidlvl.push(2)
            end
            if $Trainer.numbadges>=3
              cmds.push(_INTL("Raid Level 3"))
              raidlvl.push(3)
            end
            if $Trainer.numbadges>=6
              cmds.push(_INTL("Raid Level 4"))
              raidlvl.push(4)
            end
            if $Trainer.numbadges>=8
              cmds.push(_INTL("Raid Level 5"))
              raidlvl.push(5)
              cmds.push(_INTL("Legendary Raid"))
              raidlvl.push(6)
            end
            cmds.push(_INTL("Remove Raid Level"))
            @sprites["filter"].commands = cmds
            select = @sprites["filter"].index
            @sprites["settings"].visible = false
            @sprites["filter"].visible   = true
            @overlay.clear
            textPos.clear
            break if Input.trigger?(Input::B)
            if Input.trigger?(Input::C)
              raid = raidlvl[select]
              @sprites["settings"].index = 0
              break
            end
          end
        #-----------------------------------------------------------------------
        # Filter: Type
        #-----------------------------------------------------------------------
        when 2
          select = 0
          @sprites["filter"].index = 0
          loop do
            Graphics.update
            Input.update
            pbUpdate
            cmds = []
            types = []
            for i in 0...PBTypes.getCount
              next if i==getID(PBTypes,:QMARKS)
              cmds.push(PBTypes.getName(i))
              types.push(i)
            end
            cmds.push(_INTL("Remove Type"))
            @sprites["filter"].commands = cmds
            select = @sprites["filter"].index
            @sprites["settings"].visible = false
            @sprites["filter"].visible   = true
            @overlay.clear
            textPos.clear
            break if Input.trigger?(Input::B)
            if Input.trigger?(Input::C)
              type = types[select]
              @sprites["settings"].index = 0
              break
            end
          end
        #-----------------------------------------------------------------------
        # Filter: Habitat
        #-----------------------------------------------------------------------
        when 3
          select = 0
          @sprites["filter"].index = 0
          loop do
            Graphics.update
            Input.update
            pbUpdate
            cmds     = []
            habitats = []
            for i in 0...PBHabitats.getCount
              next if i==getID(PBHabitats,PBHabitats::None)
              cmds.push(PBHabitats.getName(i))
              habitats.push(i)
            end
            cmds.push(_INTL("Remove Habitat"))
            @sprites["filter"].commands = cmds
            select = @sprites["filter"].index
            @sprites["settings"].visible = false
            @sprites["filter"].visible   = true
            @overlay.clear
            textPos.clear
            break if Input.trigger?(Input::B)
            if Input.trigger?(Input::C)
              habitat = habitats[select]
              @sprites["settings"].index = 0
              break
            end
          end
        #-----------------------------------------------------------------------
        # Filter: Region
        #-----------------------------------------------------------------------
        when 4
          select = 0
          @sprites["filter"].index = 0
          loop do
            Graphics.update
            Input.update
            pbUpdate
            cmds    = []
            regions = []
            regionData = pbLoadRegionalDexes
            for i in 0...regionData.length
              cmds.push(_INTL("{1}",pbDexNames[i][0]))
              regions.push(i)
            end
            cmds.push(_INTL("Remove Region"))
            @sprites["filter"].commands = cmds
            select = @sprites["filter"].index
            @sprites["settings"].visible = false
            @sprites["filter"].visible   = true
            @overlay.clear
            textPos.clear
            break if Input.trigger?(Input::B)
            if Input.trigger?(Input::C)
              region = regions[select]
              @sprites["settings"].index = 0
              break
            end
          end
        end
        text1  = (raid)    ? _INTL("Raid Lvl {1}",raid) : "Any"
        text1  = "Legendary" if raid==6
        text2  = (type)    ? PBTypes.getName(type) : "Any"
        text3  = (habitat) ? PBHabitats.getName(habitat) : "Any"
        text4  = (region)  ? pbDexNames[region][0] : "Any"
        pkmnCount = pbGetMaxRaidSpecies2([type,habitat,region],raid).length
        textPos.push(
          [_INTL("[{1}]",text1),270,143,0,BASE,SHADOW],
          [_INTL("[{1}]",text2),270,175,0,BASE,SHADOW],
          [_INTL("[{1}]",text3),270,207,0,BASE,SHADOW],
          [_INTL("[{1}]",text4),270,239,0,BASE,SHADOW],
          [_INTL("Available Pokémon: {1}",pkmnCount),256,340,2,BASE,SHADOW]
        )
        pbDrawTextPositions(@overlay,textPos)
      #-------------------------------------------------------------------------
      # Exits scene.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      end
    end
  end
  
#===============================================================================
# Selection Mode - Selects a Pokemon out of the returned list of species.
#===============================================================================
  def pbSpeciesSelect
    textPos    = []
    index      = 0
    offset     = 0
    select     = index+offset
    spritelist = -1
    pkmnTotal  = @raidlist.length
    pokename   = PBSpecies.getName(@raidlist[select][0])
    formname   = pbGetRaidFormName(@raidlist[select][0],@raidlist[select][1])
    textPos.push([_INTL("{1}{2}",pokename,formname),256,340,2,BASE,SHADOW])
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 44
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 298
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["cursor"].x = @sprites["pkmnsprite#{index}"].x+10
    @sprites["cursor"].y = @sprites["pkmnsprite#{index}"].y-10
    @sprites["cursor"].visible = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(@overlay)
    pbDrawTextPositions(@overlay,textPos)
    for i in 0...@raidlist.length
      break if i>=@pageLimit
      poke   = @raidlist[i][0]
      form   = @raidlist[i][1]
      form   = 1 if poke==getID(PBSpecies,:WISHIWASHI)
      @sprites["pkmnsprite#{i}"].pbSetParams(poke,nil,form)
      @sprites["pkmnsprite#{i}"].visible = true
      pbUpdate
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if pkmnTotal>@pageLimit
        @sprites["uparrow"].visible   = true
        @sprites["downarrow"].visible = true
        @sprites["uparrow"].visible   = false if offset<=0
        @sprites["downarrow"].visible = false if offset>=pkmnTotal-@pageLimit
      end
      #-------------------------------------------------------------------------
      # Scrolling upwards
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::UP)
        pbPlayCancelSE
        Input.update
        index -= @rowLimit
        # Previous page of species
        if pkmnTotal>@pageLimit && offset>0 && index<0
          for i in offset-@pageLimit...@raidlist.length
            spritelist += 1
            break if spritelist>=@pageLimit
            poke   = @raidlist[i][0]
            form   = @raidlist[i][1]
            form   = 1 if poke==getID(PBSpecies,:WISHIWASHI)
            @sprites["pkmnsprite#{spritelist}"].pbSetParams(poke,nil,form)
            @sprites["pkmnsprite#{spritelist}"].visible = true
            pbUpdate
          end
          offset -= spritelist
          spritelist = -1
          index      =  0
        end
        # Returns to last index
        if index<0
          endsprite = 0
          for i in 0...@pageLimit
            next if !@sprites["pkmnsprite#{endsprite}"].visible
            break if endsprite>@pageLimit
            endsprite += 1 
          end
          index  = endsprite-1
        end
        @sprites["cursor"].x = @sprites["pkmnsprite#{index}"].x+10
        @sprites["cursor"].y = @sprites["pkmnsprite#{index}"].y-10
        @overlay.clear
        textPos.clear
        select   = index+offset
        pokename = PBSpecies.getName(@raidlist[select][0])
        formname = pbGetRaidFormName(@raidlist[select][0],@raidlist[select][1])
        textPos.push([_INTL("{1}{2}",pokename,formname),256,340,2,BASE,SHADOW])
        pbDrawTextPositions(@overlay,textPos)
      end
      #-------------------------------------------------------------------------
      # Scrolling downwards
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::DOWN)
        pbPlayCancelSE
        Input.update
        index += @rowLimit
        # Next page of species
        if pkmnTotal>@pageLimit+offset && index>@pageLimit-1
          for i in 0...@pageLimit
            @sprites["pkmnsprite#{i}"].pbSetParams(0,nil,nil)
            @sprites["pkmnsprite#{i}"].visible = false
          end
          for i in @pageLimit+offset...@raidlist.length
            spritelist += 1
            break if spritelist>=@pageLimit
            poke   = @raidlist[i][0]
            form   = @raidlist[i][1]
            form   = 1 if poke==getID(PBSpecies,:WISHIWASHI)
            @sprites["pkmnsprite#{spritelist}"].pbSetParams(poke,nil,form)
            @sprites["pkmnsprite#{spritelist}"].visible = true
            pbUpdate
          end
          offset += spritelist
          offset += @pageLimit-spritelist if spritelist<@pageLimit
          spritelist = -1
          index      =  0
        end
        # Returns to first index
        index  = 0 if index>@pageLimit-1
        index  = 0 if !@sprites["pkmnsprite#{index}"].visible
        if index<@pageLimit
          @sprites["cursor"].x = @sprites["pkmnsprite#{index}"].x+10
          @sprites["cursor"].y = @sprites["pkmnsprite#{index}"].y-10
        end
        @overlay.clear
        textPos.clear
        select   = index+offset
        pokename = PBSpecies.getName(@raidlist[select][0])
        formname = pbGetRaidFormName(@raidlist[select][0],@raidlist[select][1])
        textPos.push([_INTL("{1}{2}",pokename,formname),256,340,2,BASE,SHADOW])
        pbDrawTextPositions(@overlay,textPos)
      end
      #-------------------------------------------------------------------------
      # Scrolling left
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::LEFT)
        pbPlayCancelSE
        Input.update
        index -= 1
        # Returns to last index
        if index<0
          endsprite = 0
          for i in 0...@pageLimit
            next if !@sprites["pkmnsprite#{endsprite}"].visible
            break if endsprite>@pageLimit
            endsprite += 1 
          end
          index  = endsprite-1
        end
        @sprites["cursor"].x = @sprites["pkmnsprite#{index}"].x+10
        @sprites["cursor"].y = @sprites["pkmnsprite#{index}"].y-10
        @overlay.clear
        textPos.clear
        select   = index+offset
        pokename = PBSpecies.getName(@raidlist[select][0])
        formname = pbGetRaidFormName(@raidlist[select][0],@raidlist[select][1])
        textPos.push([_INTL("{1}{2}",pokename,formname),256,340,2,BASE,SHADOW])
        pbDrawTextPositions(@overlay,textPos)
      end
      #-------------------------------------------------------------------------
      # Scrolling right
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::RIGHT)
        if index<@pageLimit
          pbPlayCancelSE
          Input.update
          index += 1
          # Returns to first index
          index  = 0 if index>@pageLimit-1
          index  = 0 if !@sprites["pkmnsprite#{index}"].visible
          @sprites["cursor"].x = @sprites["pkmnsprite#{index}"].x+10
          @sprites["cursor"].y = @sprites["pkmnsprite#{index}"].y-10
          @overlay.clear
          textPos.clear
          select   = index+offset
          pokename = PBSpecies.getName(@raidlist[select][0])
          formname = pbGetRaidFormName(@raidlist[select][0],@raidlist[select][1])
          textPos.push([_INTL("{1}{2}",pokename,formname),256,340,2,BASE,SHADOW])
          pbDrawTextPositions(@overlay,textPos)
        end
      end
      #-------------------------------------------------------------------------
      # Opens species' raid data page.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        pbFadeOutIn(99999){
          select = index+offset
          for i in 0...@raidlist.length
            pkmn = @raidlist[i] if select==i
          end
          pbRaidDataBase(pkmn[0],pkmn[1])
        }
      #-------------------------------------------------------------------------
      # Returns to search mode.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::B)
        pbPlayDecisionSE()
        @sprites["cursor"].visible    = false
        @sprites["uparrow"].visible   = false
        @sprites["downarrow"].visible = false
        @sprites["results"].visible   = false
        pbFadeOutIn(99999){
          @overlay.clear
          textPos.clear
          for i in 0...@raidlist.length
            break if i>=@pageLimit
            @sprites["pkmnsprite#{i}"].visible = false
          end
        }
        break
      end
    end
  end
  
#===============================================================================
# Opens a species' Raid Data page.
#===============================================================================
  def pbRaidDataBase(poke,form=0)
    species  = getID(PBSpecies,poke)
    raidform = form
    form     = 7 if species==getID(PBSpecies,:MINIOR)
    pkmname  = PBSpecies.getName(species)
    habitat  = pbGetSpeciesData(poke,form,SpeciesHabitat)
    habname  = PBHabitats.getName(habitat)
    rank1    = pbGetMaxRaidSpecies2(nil,1)
    rank2    = pbGetMaxRaidSpecies2(nil,2)
    rank3    = pbGetMaxRaidSpecies2(nil,3)
    rank4    = pbGetMaxRaidSpecies2(nil,4)
    rank5    = pbGetMaxRaidSpecies2(nil,5)
    rank6    = pbGetMaxRaidSpecies2(nil,6)
    moves    = pbGetMaxRaidMoves(species,form)
    stab     = moves[0]
    base     = moves[1]
    mult     = moves[2]
    heal     = moves[3]
    sprites     = {}
    viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z  = 99999
    sprites["screen"]  = IconSprite.new(0,0,viewport)
    sprites["screen"].setBitmap("Graphics/Pictures/Dynamax/raiddata_bg")
    sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    overlay = sprites["overlay"].bitmap
    sprites["pokemon"] = PokemonSprite.new(viewport)
    sprites["pokemon"].setOffset(PictureOrigin::Center)
    sprites["pokemon"].x = 432
    sprites["pokemon"].y = 110
    sprites["pokemon"].zoom_x = 0.5
    sprites["pokemon"].zoom_y = 0.5
    form = 0 if species==getID(PBSpecies,:MINIOR)
    form = 1 if species==getID(PBSpecies,:WISHIWASHI)
    sprites["pokemon"].setSpeciesBitmap(species,nil,form)
    sprites["gmax"] = IconSprite.new(472,124,viewport)
    sprites["gmax"].setBitmap("Graphics/Pictures/Dynamax/gfactor") if pbGmaxSpecies?(species,form)
    sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,viewport)
    sprites["uparrow"].x = 167
    sprites["uparrow"].y = 4
    sprites["uparrow"].play
    sprites["uparrow"].visible = false
    sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,viewport)
    sprites["downarrow"].x = 167
    sprites["downarrow"].y = 345
    sprites["downarrow"].play
    sprites["downarrow"].visible = false
    #---------------------------------------------------------------------------
    # Draws general species info.
    #---------------------------------------------------------------------------
    pbSetSmallFont(overlay)
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    type1      = pbGetSpeciesData(poke,form,SpeciesType1)
    type2      = pbGetSpeciesData(poke,form,SpeciesType2)
    type1rect  = Rect.new(0,type1*28,64,28)
    type2rect  = Rect.new(0,type2*28,64,28)
    if type1==type2
      overlay.blt(400,194,typebitmap.bitmap,type1rect)
    else
      overlay.blt(367,194,typebitmap.bitmap,type1rect)
      overlay.blt(435,194,typebitmap.bitmap,type2rect)
    end
    movebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raiddata_moves"))
    overlay.blt(0,0,movebitmap.bitmap,Rect.new(0,0,181,194)) if stab.length>0
    overlay.blt(181,0,movebitmap.bitmap,Rect.new(181,0,181,194)) if base.length>0
    overlay.blt(0,193,movebitmap.bitmap,Rect.new(0,194,181,388)) if mult.length>0
    overlay.blt(181,193,movebitmap.bitmap,Rect.new(181,194,362,388)) if heal.length>0
    textPos = []
    dexnum = "#"+species.to_s.rjust(3,"0")
    textPos.push([dexnum,477,52,2,BASE,SHADOW])
    textPos.push([pkmname,434,16,2,BASE,SHADOW])
    fSpecies = pbGetFSpeciesFromForm(species,form)
    formname = pbGetMessage(MessageTypes::FormNames,fSpecies)
    if formname && formname!="" && formname!=PBSpecies.getName(species) &&
       # Species that don't need their base form names displayed.
       !(species==PBSpecies::CASTFORM ||
         species==PBSpecies::KELDEO   ||
         species==PBSpecies::XERNEAS  || 
         species==PBSpecies::SILVALLY ||
         species==PBSpecies::SINISTEA ||
         species==PBSpecies::POLTEAGEIST)
      # Species that will randomize forms with each encounter.
      randform = [PBSpecies::UNOWN,
                  PBSpecies::FLABEBE,
                  PBSpecies::FLOETTE,
                  PBSpecies::FLORGES,
                  PBSpecies::PUMPKABOO,
                  PBSpecies::GOURGEIST]
      if randform.include?(species)
        formname = _INTL("Random Form")
      elsif formname.to_s.length>15
        formname = _INTL("Base Form") if form==0
        formname = _INTL("Form {1}",form) if form>0
      end
      textPos.push([_INTL("{1}",formname),434,145,2,BASE,SHADOW])
    end
    textPos.push([_INTL("Habitat:"),434,322,2,BASE,SHADOW],
                 [_INTL("{1}",habname),434,348,2,BASE,SHADOW])
    textPos.push([_INTL("Appears In:"),383,223,0,BASE,SHADOW])
    pbSEPlay(pbCryFile(species,form))
    stars  = []
    # Gets the raid levels the species may appear in naturally.
    form = 0 if species==getID(PBSpecies,:WISHIWASHI)
    for i in 0...rank6.length; stars.push("Legendary") if rank6[i][0]==species; end
    for i in 0...rank5.length; stars.push("5") if rank5[i][0]==species && rank5[i][1]==form; end
    for i in 0...rank4.length; stars.push("4") if rank4[i][0]==species && rank4[i][1]==form; end
    for i in 0...rank3.length; stars.push("3") if rank3[i][0]==species && rank3[i][1]==form; end
    for i in 0...rank2.length; stars.push("2") if rank2[i][0]==species && rank2[i][1]==form; end
    for i in 0...rank1.length; stars.push("1") if rank1[i][0]==species && rank1[i][1]==form; end
    if stars.length<=0
      textPos.push([_INTL("None"),413,255,0,BASE,SHADOW])
    else
      for i in 0...stars.length
        if stars[i]=="Legendary"
          textPos.push([_INTL("{1} Raid",stars[i]),368,255+(20*i),0,BASE,SHADOW])
          break
        else
          textPos.push([_INTL("Raid Lv. {1}",stars[i]),389,251+(20*i),0,BASE,SHADOW])
        end
      end
    end
    display = 8   # Number of moves displayed (counts 0)
    page    = 0   # Continues counting moves from where display left off
    ydiff   = 17  # Difference in y positioning 
    xposL   = 92  # Left Column
    xposR   = 270 # Right Column
    yposT   = 30  # Top Row
    yposB   = 218 # Bottom Row
    # Text when the species has no raid moves of a given category.
    textPos.push([_INTL("None Found"),xposL,85,2,BASE,SHADOW]) if stab.length==0
    textPos.push([_INTL("None Found"),xposR,85,2,BASE,SHADOW]) if base.length==0
    textPos.push([_INTL("None Found"),xposL,278,2,BASE,SHADOW]) if mult.length==0
    textPos.push([_INTL("None Found"),xposR,278,2,BASE,SHADOW]) if heal.length==0
    pbDrawTextPositions(overlay,textPos)
    #---------------------------------------------------------------------------
    # Draws move lists.
    #---------------------------------------------------------------------------
    sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    overlay2 = sprites["overlay2"].bitmap
    pbSetSmallFont(overlay2)
    movePos = []
    # Primary movelist
    if stab.length>0
      primary = true if stab.length>display
      for i in 0...stab.length
        movePos.push([PBMoves.getName(stab[i]),xposL,yposT+(i*ydiff),2,BASE,SHADOW])
        break if i>=display
      end
    end
    # Secondary movelist
    if base.length>0
      secondary = true if base.length>display
      for i in 0...base.length
        movePos.push([PBMoves.getName(base[i]),xposR,yposT+(i*ydiff),2,BASE,SHADOW])
        break if i>=display
      end
    end
    # Spread moves movelist
    if mult.length>0
      spread = true if mult.length>display
      for i in 0...mult.length
        movePos.push([PBMoves.getName(mult[i]),xposL,yposB+(i*ydiff),2,BASE,SHADOW])
        break if i>=display
      end
    end
    # Support moves movelist
    if heal.length>0
      support = true if heal.length>display
      for i in 0...heal.length
        movePos.push([PBMoves.getName(heal[i]),xposR,yposB+(i*ydiff),2,BASE,SHADOW])
        break if i>=display
      end
    end
    if primary || secondary || spread || support
      sprites["downarrow"].visible = true
    end
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(sprites)
      pbDrawTextPositions(overlay2,movePos)
      offset1 = offset2 = offset3 = offset4 = -1
      topReached  = true
      topReached  = false if page>0
      endReached  = false
      endReached1 = (stab.length<=display+1) ? true : false
      endReached2 = (base.length<=display+1) ? true : false
      endReached3 = (mult.length<=display+1) ? true : false
      endReached4 = (heal.length<=display+1) ? true : false
      endReached  = true if endReached1 && endReached2 && endReached3 && endReached4
      sprites["uparrow"].visible = true if page>0
      sprites["uparrow"].visible = false if topReached
      sprites["downarrow"].visible = false if endReached
      sprites["downarrow"].visible = true if !endReached
      #-------------------------------------------------------------------------
      # Scrolling movelists downwards.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::DOWN)
        if !endReached
          page    += 9
          display += 9
          pbPlayCancelSE
          Input.update
          movePos.clear
          overlay2.clear
          offset1 = offset2 = offset3 = offset4 = -1
          for i in page...stab.length
            offset1 += 1 if i>0
            movePos.push([PBMoves.getName(stab[i]),xposL,yposT+(offset1*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          endReached1 = true if display>stab.length
          for i in page...base.length
            offset2 += 1 if i>0
            movePos.push([PBMoves.getName(base[i]),xposR,yposT+(offset2*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          endReached2 = true if display>base.length
          for i in page...mult.length
            offset3 += 1 if i>0
            movePos.push([PBMoves.getName(mult[i]),xposL,yposB+(offset3*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          endReached3 = true if display>mult.length
          for i in page...heal.length
            offset4 += 1 if i>0
            movePos.push([PBMoves.getName(heal[i]),xposR,yposB+(offset4*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          endReached4 = true if display>heal.length
        end
      #-------------------------------------------------------------------------
      # Scrolling movelists upwards.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::UP)
        if !topReached
          page    -= 9
          page     = 0 if page<0
          display -= 9
          display  = 8 if page==0
          pbPlayCancelSE
          Input.update
          movePos.clear
          overlay2.clear
          offset1 = offset2 = offset3 = offset4 = -1
          for i in page...stab.length
            offset1 += 1 if i<stab.length
            movePos.push([PBMoves.getName(stab[i]),xposL,yposT+(offset1*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          for i in page...base.length
            offset2 += 1 if i<base.length
            movePos.push([PBMoves.getName(base[i]),xposR,yposT+(offset2*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          for i in page...mult.length
            offset3 += 1 if i<mult.length
            movePos.push([PBMoves.getName(mult[i]),xposL,yposB+(offset3*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          for i in page...heal.length
            offset4 += 1 if i<heal.length
            movePos.push([PBMoves.getName(heal[i]),xposR,yposB+(offset4*ydiff),2,BASE,SHADOW])
            break if i>=display
          end
          topReached = true if page==0
        end
      #-------------------------------------------------------------------------
      # Test battle (Debug Mode)
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::A) && $DEBUG
        Input.update
        if pbConfirmMessage(_INTL("Test battle this Max Raid species?"))
          pbMessage(_INTL("Choose any desired raid criteria for this battle."))
          pbResetBattle
          pbDebugMaxRaidBattle(species,raidform,stars)
        end
      #-------------------------------------------------------------------------
      # Returns to selection mode.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        Input.update
        break
      end
    end
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end
  
#===============================================================================
# Sets up a Max Raid battle in debug mode.
#===============================================================================
  def pbDebugMaxRaidBattle(species,raidform,stars)
    cmd=0
    criteria  = []
    # Sets default raid level
    raidlvl   = stars[0].to_i
    raidlvl   = 6 if stars[0]=="Legendary"
    raidmsg   = raidlvl==6 ? "Legendary" : raidlvl
    # Sets default difficulty
    hardmode  = stars.include?("Legendary") ? true : false
    hardmsg   =  hardmode ? "Hard" : "Normal"
    # Sets default max mode settings
    gmax      = pbGmaxSpecies?(species,raidform) ? true : false
    eternamax = species==getID(PBSpecies,:ETERNATUS) ? true : false
    maxtype   = eternamax ? "Eternamax" : "Gigantamax"
    gmaxmsg   = gmax ? "Yes" : "No"
    # Sets up options display
    sizes     = ["1","2","3"]
    sizes    += ["4","5"] if defined?(PCV)
    weather   = ["None","Sun","Rain","Sandstorm","Hail"]
    terrain   = ["None","Electric","Grassy","Misty","Psychic"]
    environ   = ["None","Grass","Tall Grass","Moving Water","Still Water",
                 "Puddle","Underwater","Cave","Rock","Sand","Forest",
                 "Forest Grass","Snow","Ice","Volcano","Graveyard","Sky",
                 "Space","Ultra Space"]
    criteria.push(_INTL("Start Battle"))
    criteria.push(_INTL("Raid Level [{1}]",raidmsg))
    criteria.push(_INTL("Raid Size [{1}]",sizes[@sSel]))
    criteria.push(_INTL("Difficulty [{1}]",hardmsg))
    criteria.push(_INTL("{1} [{2}]",maxtype,gmaxmsg))
    criteria.push(_INTL("Weather [{1}]",weather[@wSel]))
    criteria.push(_INTL("Terrain [{1}]",terrain[@tSel]))
    criteria.push(_INTL("Environment [{1}]",environ[@eSel]))
    criteria.push(_INTL("Back"))
    setBattleRule("canLose")
    setBattleRule("cannotRun")
    setBattleRule("noPartner")
    setBattleRule("weather",0)
    setBattleRule("terrain",0)
    setBattleRule("environ",7)
    setBattleRule("base","cave3")    
    setBattleRule("backdrop","cave3")
    setBattleRule(sprintf("%dv%d",MAXRAID_SIZE,1))
    loop do
      Input.update
      cmd = pbShowCommands(nil,criteria,-1,cmd)
      #-------------------------------------------------------------------------
      # Cancel & Reset
      #-------------------------------------------------------------------------
      if cmd==8 || cmd<0
        pbResetBattle
        $PokemonTemp.clearBattleRules
        pbMessage(_INTL("Battle cancelled."))
        break
      end
      #-------------------------------------------------------------------------
      # Start Battle
      #-------------------------------------------------------------------------
      if cmd==0
        pbFadeOutIn(99999){
          pbSEPlay("Door enter")
          Input.update
          lvl = 15+rand(5) if raidlvl==1
          lvl = 30+rand(5) if raidlvl==2
          lvl = 40+rand(5) if raidlvl==3
          lvl = 50+rand(5) if raidlvl==4
          lvl = 60+rand(5) if raidlvl==5
          lvl = 70         if raidlvl==6
          # Gets randomized forms for certain species.
          formdata = pbLoadFormToSpecies
          randform = [PBSpecies::UNOWN,
                      PBSpecies::FLABEBE,
                      PBSpecies::FLORGES,
                      PBSpecies::PUMPKABOO,
                      PBSpecies::GOURGEIST]
          raidform = rand(formdata[species].length) if randform.include?(species)
          raidform = rand(5) if species==PBSpecies::FLOETTE
          raidform = rand(7) if species==PBSpecies::MINIOR
          $PokemonGlobal.nextBattleBGM = (raidlvl==6) ? "Max Raid Battle (Legendary)" : "Max Raid Battle"
          $PokemonGlobal.nextBattleBGM = "Eternamax Battle" if species==getID(PBSpecies,:ETERNATUS)
          $game_switches[MAXRAID_SWITCH] = true
          $game_variables[MAXRAID_PKMN]  = [species,raidform,nil,lvl,gmax]
          $game_switches[HARDMODE_RAID]  = hardmode
          #---------------------------------------------------------------------
          # Compatibility with Modular Battle Scene
          #---------------------------------------------------------------------
          $PokemonSystem.activebattle = true if @sSel>=3 && defined?(PCV)
          #---------------------------------------------------------------------
          pbWildBattleCore(species,lvl)
          pbWait(20)
          pbSEPlay("Door exit")
        }
        pbResetBattle
        $PokemonTemp.clearBattleRules
        for i in $Trainer.party; i.heal; end
        break
      #-------------------------------------------------------------------------
      # Set Raid Level
      #-------------------------------------------------------------------------
      elsif cmd==1
        choice = 0
        if !stars.include?("Legendary")
          loop do
            Input.update
            choice = pbShowCommands(nil,stars,-1,choice)
            pbPlayCancelSE() if choice==-1
            if choice>-1
              raidlvl = stars[choice].to_i
              pbMessage(_INTL("Raid level set to {1}.",stars[choice]))
            end
            break
          end
        else
          pbMessage(_INTL("This species may only appear in Legendary raids."))
        end
      #-------------------------------------------------------------------------
      # Set Raid Size
      #-------------------------------------------------------------------------
      elsif cmd==2
        choice = 0
        loop do
          Input.update
          choice = pbShowCommands(nil,sizes,-1,choice)
          pbPlayCancelSE() if choice==-1
          if choice>-1
            @sSel = choice
            setBattleRule(sprintf("%dv%d",sizes[choice],1))
            pbMessage(_INTL("Raid size is set to {1}.",sizes[choice]))
          end
          break
        end
      #-------------------------------------------------------------------------
      # Set Difficulty mode
      #-------------------------------------------------------------------------    
      elsif cmd==3
        if !stars.include?("Legendary")
          loop do
            Input.update
            if !hardmode
              hardmode = true
              pbMessage(_INTL("Hard Mode enabled."))
            else
              hardmode = false
              pbMessage(_INTL("Hard Mode disabled."))
            end
            break
          end
        else
          pbMessage(_INTL("Difficulty for Legendary raids cannot be changed."))
        end
      #-------------------------------------------------------------------------
      # Set Gigantamax
      #-------------------------------------------------------------------------
      elsif cmd==4
        if pbGmaxSpecies?(species,raidform)
          if !eternamax
            loop do
              Input.update
              if !gmax
                gmax = true
                pbMessage(_INTL("Gigantamax Factor applied."))
              else
                gmax = false
                pbMessage(_INTL("Gigantamax Factor removed."))
              end
              break
            end
          else
            pbMessage(_INTL("This species can only appear in its Eternamax Form."))
          end
        else
          pbMessage(_INTL("This species is unable to Gigantamax."))
        end
      #-------------------------------------------------------------------------
      # Set Weather
      #-------------------------------------------------------------------------
      elsif cmd==5
        choice = 0
        loop do
          Input.update
          choice = pbShowCommands(nil,weather,-1,choice)
          pbPlayCancelSE() if choice==-1
          if choice==0
            @wSel = 0
            setBattleRule("weather",0)
            pbMessage(_INTL("No default weather set."))
          elsif choice>0
            @wSel = choice
            setBattleRule("weather",choice)
            pbMessage(_INTL("Weather is set to {1}.",weather[choice]))
          end
          break
        end
      #-------------------------------------------------------------------------
      # Set Terrain
      #-------------------------------------------------------------------------
      elsif cmd==6
        choice = 0
        loop do
          Input.update
          choice = pbShowCommands(nil,terrain,-1,choice)
          pbPlayCancelSE() if choice==-1
          if choice==0
            @tSel = 0
            setBattleRule("terrain",0)
            pbMessage(_INTL("No default terrain set."))
          elsif choice>0
            @tSel = choice
            setBattleRule("terrain",choice)
            pbMessage(_INTL("Terrain is set to {1} Terrain.",terrain[choice]))
          end
          break
        end
      #-------------------------------------------------------------------------
      # Set Environment
      #-------------------------------------------------------------------------
      elsif cmd==7
        choice = 0
        loop do
          Input.update
          choice = pbShowCommands(nil,environ,-1,choice)
          if choice==0;                bg = base = "city";            end          
          if choice==1 || choice==2;   bg = "field"; base = "grass";  end 
          if choice==3 || choice==4;   bg = base = "water";           end
          if choice==5;                bg = "water"; base = "puddle"; end 
          if choice==6;                bg = base = "underwater";      end       
          if choice==7;                bg = base = "cave3";           end            
          if choice==8 || choice==14;  bg = base = "rocky";           end           
          if choice==9;                bg = "rocky"; base = "sand";   end    
          if choice==10;               bg = base = "forest";          end           
          if choice==11;               bg = "forest"; base = "grass"; end  
          if choice==12;               bg = base = "snow";            end             
          if choice==13;               bg = "snow"; base = "ice";     end      
          if choice==15;               bg = base = "distortion";      end       
          if choice==16;               bg = base = "sky";             end              
          if choice==17 || choice==18; bg = base = "space";           end
          if choice>-1
            @eSel = choice
            setBattleRule("base",base)    
            setBattleRule("backdrop",bg)
            setBattleRule("environ",choice)
            pbMessage(_INTL("Environment is set to {1}.",environ[choice]))
          else
            pbPlayCancelSE()
          end
          break
        end
      end
      #-------------------------------------------------------------------------
      # Sets newly selected criteria
      #-------------------------------------------------------------------------
      criteria.clear
      raidmsg = raidlvl==6 ? "Legendary" : raidlvl
      hardmsg = hardmode   ? "Hard" : "Normal"
      maxtype = eternamax  ? "Eternamax" : "Gigantamax"
      gmaxmsg = gmax       ? "Yes" : "No"
      criteria.push(_INTL("Start Battle"))
      criteria.push(_INTL("Raid Level [{1}]",raidmsg))
      criteria.push(_INTL("Raid Size [{1}]",sizes[@sSel]))
      criteria.push(_INTL("Difficulty [{1}]",hardmsg))
      criteria.push(_INTL("{1} [{2}]",maxtype,gmaxmsg))
      criteria.push(_INTL("Weather [{1}]",weather[@wSel]))
      criteria.push(_INTL("Terrain [{1}]",terrain[@tSel]))
      criteria.push(_INTL("Environment [{1}]",environ[@eSel]))
      criteria.push(_INTL("Back"))
    end
  end
end

#===============================================================================
# Used to open the Max Raid Database scene.
#===============================================================================
class RaidDataScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbRaidData
    @scene.pbEndScene
  end
end

def pbOpenRaidData
  pbFadeOutIn(99999){
    scene = RaidDataScene.new
    screen = RaidDataScreen.new(scene)
    screen.pbStartScreen
  }
end

#===============================================================================
# Access Max Raid Database in the Pokegear.
# Compatibility with Pokemon Birthsigns' Birthsign Journal.
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMap        = -1
    cmdPhone      = -1
    cmdJukebox    = -1
    cmdBirthsigns = -1 if defined?(pbOpenJournal)
    cmdRaidData   = -1
    commands[cmdMap = commands.length]     = ["map",_INTL("Map")]
    if $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length>0
      commands[cmdPhone = commands.length] = ["phone",_INTL("Phone")]
    end
    commands[cmdJukebox = commands.length] = ["jukebox",_INTL("Jukebox")]
    if defined?(pbOpenJournal)
      commands[cmdBirthsigns = commands.length] = ["birthsigns",_INTL("Birthsigns")]
    end
    commands[cmdRaidData = commands.length] = ["database",_INTL("Raid Database")]
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        pbPlayCancelSE
        break
      elsif cmdMap>=0 && cmd==cmdMap
        pbPlayDecisionSE
        pbShowMap(-1,false)
      elsif cmdPhone>=0 && cmd==cmdPhone
        pbPlayDecisionSE
        pbFadeOutIn(99999){
          PokemonPhoneScene.new.start
        }
      elsif cmdJukebox>=0 && cmd==cmdJukebox
        pbPlayDecisionSE
        pbFadeOutIn(99999){
          scene = PokemonJukebox_Scene.new
          screen = PokemonJukeboxScreen.new(scene)
          screen.pbStartScreen
        }
      # Support for Birthsigns Journal.
      elsif defined?(pbOpenJournal) && cmdBirthsigns>=0 && cmd==cmdBirthsigns
        pbPlayDecisionSE
        pbOpenJournal
      # Raid Database
      elsif cmdRaidData>=0 && cmd==cmdRaidData
        pbPlayDecisionSE
        pbOpenRaidData
      end
    end
    @scene.pbEndScene
  end
end


################################################################################
# SECTION 5 - MAX RAID ITEMS
#===============================================================================
# Custom items that are obtained as rewards from completing Max Raid Dens.
#===============================================================================
# Max Soup - Toggles Gigantamax Factor. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSOUP,proc { |item,pkmn,scene|
  if !pkmn.hasGmax? || !pkmn.dynamaxAble? || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.gmaxFactor?
    pkmn.removeGMaxFactor
    scene.pbDisplay(_INTL("{1} lost its Gigantamax energy.",pkmn.name))
  else
    pkmn.giveGMaxFactor
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1} is now bursting with Gigantamax energy!",pkmn.name))
  end
  scene.pbHardRefresh
  next true
})

#-------------------------------------------------------------------------------
# Dynamax Candy XL - Maxes out a Pokemon's Dynamax Level. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:DYNAMAXCANDYXL,proc { |item,pkmn,scene|
  if pkmn.dynamax_lvl>=10 || !pkmn.dynamaxAble? || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setDynamaxLvl(10)
  pbSEPlay("Pkmn move learnt")
  scene.pbDisplay(_INTL("{1}'s Dynamax level was increased to 10!",pkmn.name))
  scene.pbHardRefresh
  next true
})

#-------------------------------------------------------------------------------
# Max Eggs - Increases Exp. for the whole party by 20,000. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseInField.add(:MAXEGGS,proc { |item|
  if $Trainer.pokemonCount==0
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  cangiveExp = false
  for i in $Trainer.pokemonParty
    next if i.level>=PBExperience.maxLevel
    next if i.shadowPokemon?
    cangiveExp = true; break
  end
  if !cangiveExp
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  expplus    = 0
  experience = 20000
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Using item..."),false)
    for i in 0...$Trainer.party.length
      pkmn = $Trainer.party[i]
      next if pkmn.level>=PBExperience.maxLevel || pkmn.shadowPokemon?
      expplus   += 1
      newexp     = PBExperience.pbAddExperience(pkmn.exp,experience,pkmn.growthrate)
      newlevel   = PBExperience.pbGetLevelFromExperience(newexp,pkmn.growthrate)
      curlevel   = pkmn.level
      leveldif   = newlevel - curlevel
      if PBExperience.pbGetMaxExperience(pkmn.growthrate) < (pkmn.exp + experience)
        screen.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pkmn.name,(PBExperience.pbGetMaxExperience(pkmn.growthrate)-pkmn.exp)))
      else
        screen.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pkmn.name,experience))
      end
      if newlevel==curlevel
        pkmn.exp = newexp
        pkmn.calcStats
        screen.pbRefreshSingle(i)
      else
        leveldif.times do
          pbChangeLevel(pkmn,pkmn.level+1,screen)
          screen.pbRefreshSingle(i)
        end
      end
    end
    if expplus==0
      screen.pbDisplay(_INTL("It won't have any effect."))
      screen.pbEndScene
      next 0
    else
      screen.pbEndScene
      next 3
    end
  }
})

#-------------------------------------------------------------------------------
# Max Scales - Allows a Pokemon to recall a past move. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSCALES,proc { |item,pkmn,scene|
  if pbGetRelearnableMoves(pkmn).length<=0 || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("What move should {1} recall?",pkmn.name))
  m = pkmn.moves
  oldmoves = [m[0],m[1],m[2],m[3]]
  pbRelearnMoveScreen(pkmn)
  newmoves = [m[0],m[1],m[2],m[3]]
  next false if newmoves==oldmoves
  next true
})

#-------------------------------------------------------------------------------
# Max Plumage - Increases each IV of a Pokemon by 1 point. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXPLUMAGE,proc { |item,pkmn,scene|
  stats = 0
  for i in 0...6
    next if pkmn.iv[i]==31
    stats += 1
    pkmn.iv[i] += 1
  end
  if stats==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s base stats increased by 1!",pkmn.name))
  scene.pbHardRefresh
  next true
})