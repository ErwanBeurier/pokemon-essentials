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
    @battle.scActivateCarboniferous
  end
end


class PokeBattle_Battle
  def scActivateCarboniferous(idxBattler = nil)
    # if idxBattler = nil, try to boost all battlers on the field. 
    return if @field.effects[PBEffects::Carboniferous] == 0
    
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
  
  def scEORCarboniferous
    return if @field.effects[PBEffects::Carboniferous] == 0
    
    eachBattler do |b|
      next if !b.pbHasType?(:BUG)
      next if !b.canHeal?
      
      b.pbRecoverHP(b.totalhp/16)
      b.pbDisplay(_INTL("{1} restored a little HP due to the air quality of Carboniferous!", b.pbThis))
    end
  end 
end 


#===============================================================================
# Sets a mandala at the feet of the user. Raises the attack of Pokémon that 
# enter the terrain. Activates three times. (War Mandala)
#===============================================================================
class PokeBattle_Move_C004 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::WarMandala]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::WarMandala] = 3
    @battle.pbDisplay(_INTL("{1} painted a War Mandala!",user.pbThis))
  end
end


#===============================================================================
# Sets a mandala at the feet of the user. Raises the Sp. Atk of Pokémon that 
# enter the terrain. Activates three times. (Mind Mandala)
#===============================================================================
class PokeBattle_Move_C005 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::MindMandala]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::MindMandala] = 3
    @battle.pbDisplay(_INTL("{1} painted a Mind Mandala!",user.pbThis))
  end
end


class PokeBattle_Battle
  
  def scActivateMandalas(battler)
    return if battler.airborne?
    
    if battler.pbOwnSide.effects[PBEffects::WarMandala] > 0 && 
      battler.pbCanRaiseStatStage?(PBStats::ATTACK,battler)
      
      battler.pbRaiseStatStage(PBStats::ATTACK,1,battler)
      pbDisplay(_INTL("The War Mandala strengthened {1}!",battler.pbThis))
      
      battler.pbOwnSide.effects[PBEffects::WarMandala] -= 1
      if battler.pbOwnSide.effects[PBEffects::WarMandala] == 0
        pbDisplay(_INTL("The War Mandala wore off...")) 
      end 
    end 
    if battler.pbOwnSide.effects[PBEffects::MindMandala] > 0 &&
      battler.pbCanRaiseStatStage?(PBStats::SPATK,battler)
      
      battler.pbRaiseStatStage(PBStats::SPATK,1,battler)
      pbDisplay(_INTL("The Mind Mandala strengthened {1}!",battler.pbThis))
      
      battler.pbOwnSide.effects[PBEffects::MindMandala] -= 1
      if battler.pbOwnSide.effects[PBEffects::MindMandala] == 0
        pbDisplay(_INTL("The Mind Mandala wore off...")) 
      end
    end 
  end 
end 


#===============================================================================
# The Pokémon that replaces the user raises its Attack and Sp. Atk by 2 stages. 
# (Warm Welcome)
#===============================================================================
class PokeBattle_Move_C006 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.positions[user.index].effects[PBEffects::WarmWelcome]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.positions[user.index].effects[PBEffects::WarmWelcome] = true
    @battle.pbDisplay(_INTL("{1} is cheering its allies!",user.pbThis))
  end
end




