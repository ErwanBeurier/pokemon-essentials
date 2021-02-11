#===============================================================================
# For 5 rounds, creates a magnetic terrain which makes Electric and Steel-types 
# airborne. (Magnetic Terrain)
#===============================================================================
class PokeBattle_Move_C001 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain==PBBattleTerrains::Magnetic
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user,PBBattleTerrains::Magnetic)
  end
end



#===============================================================================
# Starts tempest weather. (Autumn Tempest)
#===============================================================================
class PokeBattle_Move_C002 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = PBWeather::Tempest
  end
end
