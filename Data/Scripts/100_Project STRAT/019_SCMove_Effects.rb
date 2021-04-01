################################################################################
# SCMoves_Effects
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of new moves. I also redefine some 
# other classes to go with the moves.
################################################################################

# Disparition of battler's sprites for Fly or others.
class PokeBattle_Scene
  def pbVanishSprite(pkmn)
    pkmnsprite=@sprites["pokemon_#{pkmn.index}"]
    pkmnsprite.visible = false
    pbUpdate    
  end
  def pbUnVanishSprite(pkmn)
    # @battle.pbCommonAnimation("Fade in",pkmn,nil) if fade
    pkmnsprite=@sprites["pokemon_#{pkmn.index}"]
    pkmnsprite.visible = true
    pbUpdate 
  end 
  # def pbSubstituteSprite(pkmn,back)
    # pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    # pkmnsprite.setPokemonBitmapSpecies("substitute",000,back)
    # pkmnsprite.opacity+=1000
  # end
  # def pbUnSubstituteSprite(pkmn,back)   
    # pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    # pkmnsprite.setPokemonBitmapSpecies(pkmn.battlerToPokemon,pkmn.species,back)
    # pkmnsprite.opacity+=1000
  # end  
end 




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
    user.pbOwnSide.effects[PBEffects::WarMandala] = 2
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
    user.pbOwnSide.effects[PBEffects::MindMandala] = 2
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




#===============================================================================
# Increases the user's Attack by 1 stage (3 stages if the user has the ability 
# Wolf Blood) (updated Howl)
#===============================================================================
class PokeBattle_Move_C007 < PokeBattle_Move_01C
  def pbOnStartUse(user,targets)
    @statUp[1] = (user.hasActiveAbility?(:WOLFBLOOD) ? 3 : 1)
    super
  end
end



#===============================================================================
# Restore HP of allies and self. (Relaxing Purring)
#===============================================================================
class PokeBattle_Move_C008 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user,targets)
    jglheal = 0
    for i in 0...targets.length
      jglheal += 1 if (targets[i].hp == targets[i].totalhp || !targets[i].canHeal?)
    end
    if jglheal == targets.length
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    if target.hp != target.totalhp && target.canHeal?
      hpGain = (target.totalhp/3.0).round
      target.pbRecoverHP(hpGain)
      @battle.pbDisplay(_INTL("{1}'s health was restored.",target.pbThis))
    end
    super
  end
end
