################################################################################
# SCVariablesSwitches
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the definition of constants for variables and switches, 
# to make it easier to include them in scripts and still knowwhat they do.
################################################################################



module SCVar
  def self.set(var, value)
    var = getID(SCVar,var)
    $game_variables[var] = value
  end 
  
  def self.get(var)
    var = getID(SCVar,var)
    return $game_variables[var]
  end 
  
  def self.increment(var)
    var = getID(SCVar,var)
    $game_variables[var] += 1
  end 
  
  
  # ---------------------------------------------------------------------------
  # General purpose 
  # ---------------------------------------------------------------------------
  GeneralTemp = 3 # Temp Pokémon name but could be used anywhere.
  
  
  # ---------------------------------------------------------------------------
  # Story information
  # ---------------------------------------------------------------------------
  # Region of origin of the player.
  RegionOfOrigin = 70
  
  # ---------------------------------------------------------------------------
  # Forced team. 
  # ---------------------------------------------------------------------------
  # Index of the forced team.
  ForcedTeamIndex = 71
  # Message reminding what the team should be.
  ForcedTeamMessage = 72 
  
  # ---------------------------------------------------------------------------
  # Tier related stuff. 
  # ---------------------------------------------------------------------------
  # The tier of the next client. Can be changed through the day by the player, 
  # but cannot be changed sometimes, for narrative reasons. 
  Tier = 51 
  # Contains the tier first intended for the team the player has. 
  TierOfTeam = 66
  # Contains the tier that clients like at the moment. 
  HypedTier = 60 
  
  # ---------------------------------------------------------------------------
  # Other castle stuff.
  # ---------------------------------------------------------------------------
  # Contains the message stating the replacements that occured after a 
  # Nuzzlocke battle.
  NuzzlockeChanges = 59
  # Chosen battle format in the ladder. 
  BattleFormat = 67
  
  # ---------------------------------------------------------------------------
  # Client battles
  # ---------------------------------------------------------------------------
  # Stores the name of the partner the client wanted. Only the name though. 
  WantedPartner = 61
  # The required number of client battles before the story continues
  ClientBattlesRequired = 62
  # The number of battles done. 
  ClientBattlesDone = 63
  # Index of the next switch to activate, when the required number of client 
  # battles is done.
  NextSwitch = 64 
end 



module SCSwitch
  def self.set(var, value)
    var = getID(SCSwitch,var)
    $game_switches[var] = value
  end 
  
  def self.get(var)
    var = getID(SCSwitch,var)
    return $game_switches[var]
  end 
  
  def self.isTrue(var)
    var = getID(SCSwitch,var)
    return $game_switches[var]
  end 
  
  # ---------------------------------------------------------------------------
  # Tier related stuff
  # ---------------------------------------------------------------------------
  # Stores whether the tier is forced for narrative reasons. 
  ForcedTier = 81
  # Switch to decide when t show the Manager at the desk.
  ShowManager = 79 
  # Switch to allow/disallow Legendary Pokémons in big tiers (only in post-game).
  AllowLegendary = 89 
  # Forced team.
  ForcedTeam = 91
  # Switch to allow/disallow Battle Royales.
  AllowBattleRoyales = 102
  # Switch to allow/disallow Inverse Battles.
  AllowInverseBattles = 105
  # Switch to allow/disallow Changing Terrain.
  AllowChangingTerrain = 103
  # Switch to allow/disallow Changing Weather.
  AllowChangingWeather = 104
  # Switch to allow/disallow battles with formats bigger than 3v3.
  AllowBigFormats = 106
  
  
  
  # ---------------------------------------------------------------------------
  # Other castle stuff.
  # ---------------------------------------------------------------------------
  # Stores whether the player is doing a nuzzlocke challenge.
  IsNuzzlocke = 82
  
  # ---------------------------------------------------------------------------
  # Client battles
  # ---------------------------------------------------------------------------
  # Whether the current client battle is done. 
  RandBattleDone = 78
  # Battle result
  ClientBattleResult = 77 
  
  # ---------------------------------------------------------------------------
  # Real Pokémon stuff
  # ---------------------------------------------------------------------------
  # Whether or not the player is allowed to change their team. (Only once per 
  # game)
  AllowTeamChange = 90
  # Switches to know which is taken.
  # Can also be accessed by using SCSwitch::StarterFollowing + SCStoryPokemon::XXX
  StarterFollowing = 92
  CoreStrongFollowing = 93
  CoreWeakFollowing = 94
  HalfLegendaryFollowing = 95
  OrdinaryFollowing = 96
  CuteFollowing = 97
  Badass1Following = 98
  Badass2Following = 99
  FlyingFollowing = 100
  TotemFollowing = 101
end 


