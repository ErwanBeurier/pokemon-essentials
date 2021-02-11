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


#===============================================================================
# For 5 rounds, increases Bug-type Pokémon stats. (Carboniferous)
#===============================================================================
class PokeBattle_Move_C003 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.effects[PBEffects::Carboniferous]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::Carboniferous] = 5
    @battle.pbDisplay(_INTL("The battlefield regresses to an ancient time!"))
    @battle.pbActivateCarboniferous
  end
end


class PokeBattle_Battle
  def pbActivateCarboniferous(idxBattler = nil)
    # if idxBattler = nil, try to boost all battlers on the field. 
    return if @field.effects[PBEffects::Carboniferous] <= 0
    
    idxBattler = idxBattler.index if idxBattler && idxBattler.respond_to?("index")
    statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,PBStats::SPATK,1,PBStats::SPDEF,1,PBStats::SPEED,1]
    showMessage = false 
    
    eachBattler do |b|
      next if !b.pbHasType?(:BUG)
      next if idxBattler && b.index != idxBattler
      
      showAnim = true 
      
      for i in 0...statUp.length/2
        next if !b.pbCanRaiseStatStage?(statUp[i*2],b,self)
        if b.pbRaiseStatStage(statUp[i*2],statUp[i*2+1],b,showAnim)
          showAnim = false
          showMessage = true
        end
      end
    end
    pbDisplay(_INTL("Bug-type Pokémon are stronger in Carboniferous!")) if showMessage
  end 
end 

