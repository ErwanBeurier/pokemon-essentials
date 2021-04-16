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
  # The required number of client battles before the story continues
  ClientBattlesRequired = 62
  # The number of battles done. 
  ClientBattlesDone = 63
  # Index of the next switch to activate, when the required number of client 
  # battles is done.
  NextSwitch = 64 
end 


module SCSwitch
  # ---------------------------------------------------------------------------
  # Tier related stuff
  # ---------------------------------------------------------------------------
  # Stores whether the tier is forced for narrative reasons. 
  ForcedTier = 81
  # Switch to decide when t show the Manager at the desk.
  ShowManager = 79 
  # Switch to allow/disallow Legendary Pokémons in big tiers (only in post-game).
  AllowLegendary = 89 
  
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
end 


