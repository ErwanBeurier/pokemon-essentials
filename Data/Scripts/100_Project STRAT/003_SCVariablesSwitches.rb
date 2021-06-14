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
  RegionOfOriginName = 86
  # The number of double battles done (condition to allow 6v6). 
  NumberOfDoubleBattles = 73
  # The number of battles done today (condition to allow the player to sleep). 
  NumberOfBattlesToday = 74
  
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
  # Stores whether the player is asked the strength of the team when generating 
  # a team. 0 = Do ask, 1 = don't ask (default)
  AskStrataForTeamGeneration = 76 
  
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
  ClientBattlesRequired2 = 77
  ClientBattlesRequired3 = 78
  ClientBattlesRequired4 = 79
  # The number of battles done. 
  NumberClientBattlesDone = 63
  NumberClientBattlesDone2 = 80
  NumberClientBattlesDone3 = 81
  NumberClientBattlesDone4 = 82
  # Index of the next switch to activate, when the required number of client 
  # battles is done.
  NextSwitch = 64 
  NextSwitch2 = 83 
  NextSwitch3 = 84 
  NextSwitch4 = 85 
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
  # Allow White Butterfree and new forms.
  AllowWhiteButterfree = 107
  # Allow new fossil forms.
  AllowNewFossils = 108
  # Puts Carboniferous archetype in the generation of teams.
  AllowCarboniferous = 124
  # Allows Bitype in the requests.
  AllowBitype = 125 
  
  # ---------------------------------------------------------------------------
  # Other castle stuff.
  # ---------------------------------------------------------------------------
  # Stores whether the player is doing a nuzzlocke challenge.
  IsNuzzlocke = 82
  # Force loading the trainers in the park (I put these constants here because 
  # I set these variables to false upon saving).
  LoadCastle = 111
  LoadCastleMusic = 117
  LoadGardens = 110
  LoadStadium = 112
  LoadCliff = 113
  LoadBeach = 114
  LoadForestA = 115
  LoadForestB = 116
  
  # ---------------------------------------------------------------------------
  # Client battles
  # ---------------------------------------------------------------------------
  # Whether the current client battle is done. 
  ClientBattleDone = 78
  # Battle result
  ClientBattleResult = 77 
  # True or False, to give to the next Switch. Defaults to True. 
  NextSwitchValue = 118
  NextSwitchValue2 = 119
  NextSwitchValue3 = 120
  NextSwitchValue4 = 121
  
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
  # Forces the player to use their real Pokémons. 
  # Blocks the PC into cleaning the team + the real Pokémon now can enter the 
  # team. 
  UseRealPokemons = 122 
  
  # ---------------------------------------------------------------------------
  # Story related stuff
  # ---------------------------------------------------------------------------
  # Start the dialogue with Hettie for unlocking Big Formats.
  StartQuestUnlockingBigFormats = 209
  # We are at night:
  TimeNight = 211
  TimeAfternoon = 212
  TimeMorning = 235 
  # Unlocks the Flying Pokémon in the Castle Gardens.
  UnlockFlyingInGardens = 123 
end 





