#==============================================================================
# Inverse Battles
#==============================================================================

$InverseBattle = false 

def scMakeInverseBattle
  $InverseBattle = true 
end 

class PBTypes
  # Inverse type effectiveness. 
  def PBTypes.getEffectiveness(attackType,targetType)
    return PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if !targetType || targetType<0
    
    ret = PBTypes.loadTypeData[2][attackType*(PBTypes.maxValue+1)+targetType]
    
    if $InverseBattle
      case ret
      when PBTypeEffectiveness::INEFFECTIVE, PBTypeEffectiveness::NOT_EFFECTIVE_ONE
        ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
        
      when PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
        ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE
        
      end 
    end 
    return ret 
  end
end 

class PokeBattle_Battle 
  # Revert Inverse Battle. 
  alias __inversebattle__pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    ret = __inversebattle__pbEndOfBattle
    $InverseBattle = false
    return ret 
  end 
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


