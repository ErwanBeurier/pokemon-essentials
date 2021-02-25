################################################################################
# SCUnorthodoxBattles
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of battles rule changers: 
# - inverse battles (inverses the effectiveness of moves)
# - random terrain / weather (changes the weather/terrain at the end of a turn)
# - disallow all mechanics (+ enable them). 
################################################################################


#==============================================================================
# Inverse Battles
#==============================================================================

class PokeBattle_Battle
  attr_accessor :inverseBattle
  attr_accessor :inverseSTAB
  
  alias __inversebattle__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __inversebattle__init(scene,p1,p2,player,opponent)
    @inverseBattle = false 
    @inverseSTAB = false 
  end 
  
  def invertEffectivenessOne(eff)
    case eff
    when PBTypeEffectiveness::INEFFECTIVE, PBTypeEffectiveness::NOT_EFFECTIVE_ONE
      eff = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
      
    when PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
      eff = PBTypeEffectiveness::NOT_EFFECTIVE_ONE
      
    end 
    return eff 
  end 
  
end 

alias __inversebattle__pbPrepareBattle pbPrepareBattle
def pbPrepareBattle(battle)
  __inversebattle__pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
  # Prepare for inverse battle (invert type effectiveness) (STRAT)
  battle.inverseBattle = battleRules["inverseBattle"] if !battleRules["inverseBattle"].nil?
  # STAB apply to moves with different types (STRAT)
  battle.inverseSTAB = battleRules["inverseSTAB"] if !battleRules["inverseSTAB"].nil?
end 




#==============================================================================
# Random Terrain / Weather
#==============================================================================

class PokeBattle_Battle
  attr_accessor :changingTerrain
  attr_accessor :changingWeather
  
  alias __unorthodox__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __unorthodox__init(scene,p1,p2,player,opponent)
    @changingTerrain = false 
    @changingWeather = false 
  end 
  
  def scSelectRandomTerrain
    terrains = [
      PBBattleTerrains::Electric,
      PBBattleTerrains::Grassy,
      PBBattleTerrains::Misty,
      PBBattleTerrains::Psychic,
      PBBattleTerrains::Magnetic
    ]
    newTerrain = terrains[rand(terrains.length)]
    pbStartTerrain(nil,newTerrain,true)
  end 
  
  
  alias __unorthodox__pbEORTerrain pbEORTerrain
  def pbEORTerrain
    if @changingTerrain
      scSelectRandomTerrain
    else
      __unorthodox__pbEORTerrain
    end 
  end 
  
  def scSelectRandomWeather
    weathers = [
      PBWeather::Sun,
      PBWeather::Rain,
      PBWeather::Sandstorm,
      PBWeather::Hail,
      PBWeather::Fog,
      PBWeather::Tempest
    ]
    newWeather = weathers[rand(weathers.length)]
    pbStartWeather(nil,newWeather,true)
  end 
  
  
  alias __unorthodox__pbEORWeather pbEORWeather
  def pbEORWeather(priority)
    if @changingWeather
      scSelectRandomWeather
    else
      __unorthodox__pbEORWeather(priority)
    end 
  end 
end 

alias __unorthodox__prepare pbPrepareBattle
def pbPrepareBattle(battle)
  __unorthodox__prepare(battle)
  battleRules = $PokemonTemp.battleRules
  # Whether the terrain changes at the end of each turn (default: false) (STRAT)
  battle.changingTerrain = battleRules["changingTerrain"] if !battleRules["changingTerrain"].nil?
  # Whether the weather changes at the end of each turn (default: false) (STRAT)
  battle.changingWeather = battleRules["changingWeather"] if !battleRules["changingWeather"].nil?
end 


#==============================================================================
# Control all mechanics.
#==============================================================================

def scDisableAllMechanics
  $game_switches[NO_Z_MOVE] = true
  $game_switches[NO_ULTRA_BURST] = true
  $game_switches[NO_DYNAMAX] = true
  $game_switches[NO_MEGA_EVOLUTION] = true
  $game_switches[NO_ASSISTANCE] = true
end 

def scEnableAllMechanics
  $game_switches[NO_Z_MOVE] = false
  $game_switches[NO_ULTRA_BURST] = false
  $game_switches[NO_DYNAMAX] = false
  $game_switches[NO_MEGA_EVOLUTION] = false
  $game_switches[NO_ASSISTANCE] = false
end 

