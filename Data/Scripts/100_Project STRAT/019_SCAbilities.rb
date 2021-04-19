################################################################################
# SCClientBattles
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of new abilities.
################################################################################

#===============================================================================
# High potential
# Doubles the special attack (like Huge Power)
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:HIGHPOTENTIAL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if move.specialMove?
  }
)


#===============================================================================
# Parasitic mould
# When the Pokémon is KO-ed, it activates Leech Seed on the attacking Pokémon. 
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:PARASITICMOULD,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if user.effects[PBEffects::LeechSeed]>=0
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1} was seeded!",user.pbThis))
    user.effects[PBEffects::LeechSeed] = target.index
    battle.pbHideAbilitySplash(target)
  }
)


#===============================================================================
# Sharp Edge
# Raises the damage for "slashing" moves. 
#===============================================================================

class PokeBattle_Move
  
  alias __blademove__init initialize
  def initialize(battle,move)
    __blademove__init(battle, move)
    @isBladeMove = -1
  end
  
  def bladeMove?
    if @isBladeMove == -1
      @isBladeMove = [PBMoves::AERIALACE, 
                      PBMoves::AIRSLASH, 
                      PBMoves::BEHEMOTHBLADE, 
                      PBMoves::CROSSPOISON, 
                      PBMoves::CUT, 
                      PBMoves::FALSESWIPE, 
                      PBMoves::FURYCUTTER, 
                      PBMoves::LEAFBLADE, 
                      PBMoves::NIGHTSLASH, 
                      PBMoves::PSYCHOCUT, 
                      PBMoves::RAZORSHELL, 
                      PBMoves::SACREDSWORD, 
                      PBMoves::SECRETSWORD, 
                      PBMoves::SLASH, 
                      PBMoves::SOLARBLADE, 
                      PBMoves::XSCISSOR].include?(@id)
    end 
    return @isBladeMove
  end 
end


BattleHandlers::DamageCalcUserAbility.add(:SHARPEDGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] *= 4/3.0 if move.bladeMove?
  }
)


#===============================================================================
# Wolf Blood 
# Raises the power of biting moves + Howl raises the attack by 3 stages instead 
# of 1 (handled elsewhere). 
#===============================================================================

BattleHandlers::DamageCalcUserAbility.copy(:STRONGJAW,:WOLFBLOOD)


#===============================================================================
# Vampiric  
# Biting moves restore 25% of the damage dealt. 
#===============================================================================

BattleHandlers::UserAbilityOnHit.add(:VAMPIRIC,
  proc { |ability,user,target,move,battle|
    next if target.damageState.hpLost<=0
    next if !move.bitingMove?
    battle.pbShowAbilitySplash(user)
    hpGain = (target.damageState.hpLost/4.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
    battle.pbHideAbilitySplash(user)
  }
)


#===============================================================================
# Race Horse   
# Increases Speed by one stage when switching in. 
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:RACEHORSE,
  proc { |ability,battler,battle|
    stat = PBStats::SPEED
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)


#===============================================================================
# Avenger   
# In Double Battles (or more), raises the attack by 3 stages if a partner died.
# When switching in, if this Pokémon is the last of the team, raises its attack 
# by 3 stages.
#===============================================================================

# In Double Battles (or more), raises the attack by 3 stages if a partner died.
BattleHandlers::AbilityOnBattlerFainting.add(:AVENGER,
  proc { |ability,battler,fainted,battle|
    next if fainted.opposes?(battler)
    battle.pbShowAbilitySplash(battler)
    battler.pbRaiseStatStageByAbility(PBStats::ATTACK,3,battler)
    battle.pbDisplay(_INTL("{1} wants to avenge {2}!", battler.pbThis, fainted.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

# When switching in, if this Pokémon is the last of the team, raises its attack 
# by 3 stages.
BattleHandlers::AbilityOnSwitchIn.add(:AVENGER,
  proc { |ability,battler,battle|
    next if battle.pbCanChooseNonActive?(battler.index)
    battle.pbShowAbilitySplash(battler)
    battler.pbRaiseStatStageByAbility(PBStats::ATTACK,3,battler)
    battle.pbDisplay(_INTL("{1} wants to avenge its partners!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)



#===============================================================================
# Dragonborn   
# On switching in, the Pokémon gains a third type (Dragon). 
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:DRAGONBORN,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::Type3] = getConst(PBTypes,:DRAGON)
  }
)


#===============================================================================
# Lava Monster   
# Rock-type moves become Fire-type.
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:LAVAMONSTER,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:ROCK) || !hasConst?(PBTypes,:FIRE)
    move.powerBoost = true
    next getConst(PBTypes,:FIRE)
  }
)
BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:LAVAMONSTER)


#===============================================================================
# Blacksmith   
# Rock-type moves become Steel-type. 
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:BLACKSMITH,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:ROCK) || !hasConst?(PBTypes,:STEEL)
    move.powerBoost = true
    next getConst(PBTypes,:STEEL)
  }
)


#===============================================================================
# Predator   
# If a Pokémon uses a STAB on another Pokémon with that same type, then boosts 
# damage.
# Example: Water-type Pokémon uses Water-type move on Water-type Pokémon.
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:PREDATOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !target.pbHasType?(move.type)
    next if !user.pbHasType?(move.type)
    mults[BASE_DMG_MULT] *= 4/3.0 
  }
)


#===============================================================================
# Mine clearer
# The Pokémon clears hasards, walls and mandalas when it switches in.
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:MINECLEARER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachBattler do |b|
      next if !b 
      if b.pbOwnSide.effects[PBEffects::AuroraVeil]>0
        b.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      end
      if b.pbOwnSide.effects[PBEffects::LightScreen]>0
        b.pbOwnSide.effects[PBEffects::LightScreen] = 0
      end
      if b.pbOwnSide.effects[PBEffects::Reflect]>0
        b.pbOwnSide.effects[PBEffects::Reflect] = 0
      end
      if b.pbOwnSide.effects[PBEffects::Mist]>0
        b.pbOwnSide.effects[PBEffects::Mist] = 0
      end
      if b.pbOwnSide.effects[PBEffects::Safeguard]>0
        b.pbOwnSide.effects[PBEffects::Safeguard] = 0
      end
      if b.pbOwnSide.effects[PBEffects::StealthRock]
        b.pbOwnSide.effects[PBEffects::StealthRock] = false
      end
      if b.pbOwnSide.effects[PBEffects::LavaTrap]
        b.pbOwnSide.effects[PBEffects::LavaTrap] = false
      end
      if b.pbOwnSide.effects[PBEffects::Spikes]>0
        b.pbOwnSide.effects[PBEffects::Spikes] = 0
      end
      if b.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        b.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      end
      if b.pbOwnSide.effects[PBEffects::StickyWeb]
        b.pbOwnSide.effects[PBEffects::StickyWeb]      = false
        b.pbOwnSide.effects[PBEffects::StickyWebUser]  = -1
      end
      if b.pbOwnSide.effects[PBEffects::WarMandala]>0
        b.pbOwnSide.effects[PBEffects::WarMandala] = 0
      end
      if b.pbOwnSide.effects[PBEffects::MindMandala]>0
        b.pbOwnSide.effects[PBEffects::MindMandala] = 0
      end
    end 
    battle.pbDisplay("Every hazard and protection was removed!")
    battle.pbHideAbilitySplash(battler)
  }
)


#===============================================================================
# Beginner's Luck
# Once per switch-in, the Pokémon ignores the immunity of a target. 
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:BEGINNERSLUCK,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::BeginnersLuck] = 1 if battler.effects[PBEffects::BeginnersLuck] == -1
  }
)


#===============================================================================
# Invasive
# The Pokémon calls a clone in battle. 
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:INVASIVE,
  proc { |ability,battler,battle|
    next if battle.pbSideSize(battler.index) >= 6 
    # Warn the player.
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is invasive!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    # Prepare the indices. 
    idxBattler = battler.index
    idxOwner = battle.pbGetOwnerIndexFromBattlerIndex(idxBattler)
    idxSide = idxBattler % 2
    idxInvader = battle.sideSizes[idxSide] * 2 + idxSide
    # Prepare the new invader.
    invader = battler.pokemon.clone
    battle.sideSizes[idxSide] += 1
    if battle.battlers[idxInvader].nil?
      battle.pbCreateBattler(idxInvader,invader,battle.pbParty(idxBattler).length)
    else
      battle.battlers[idxInvader].pbInitialize(invader,battle.pbParty(idxBattler).length)
    end
    battle.scene.pbSOSJoin(idxInvader,invader)
    battle.pbDisplay(_INTL("{1} appeared!",battle.battlers[idxInvader].pbThis))
    # required to gain exp and to do "switch in" effects, like Spikes
    battle.pbOnActiveOne(battle.battlers[idxInvader])
    # @party2.push(ally)
    # @party2order.push(@party2order.length)
    # If the battler is on the player's side, allow it to choose the commands.
    # while battle.lastCmd.length < battle.battlers.length
      # battle.lastCmd.push(0)
    # end 
    battle.scene.pbUpdateLastCmd
  }
)
class PokeBattle_Scene
  def pbUpdateLastCmd
    while @lastCmd.length < @battle.battlers.length
      @lastCmd.push(0)
      @lastMove.push(0)
    end 
  end 
end 


#===============================================================================
# Wind rider
# Boosts speed when struck with wind moves. 
#===============================================================================

class PokeBattle_Move
  alias __windmove__init initialize
  def initialize(battle,move)
    __windmove__init(battle, move)
    @isWindMove = -1
  end
  
  def windMove?
    if @isWindMove == -1
      @isWindMove = [PBMoves::SILVERWIND,
                      PBMoves::TWISTER,
                      PBMoves::FAIRYWIND,
                      PBMoves::VACUUMWAVE,
                      PBMoves::AEROBLAST,
                      PBMoves::AIRCUTTER,
                      PBMoves::AIRSLASH,
                      PBMoves::GUST,
                      PBMoves::HURRICANE,
                      PBMoves::OMINOUSWIND,
                      PBMoves::ICYWIND,
                      PBMoves::RAZORWIND].include?(@id)
    end 
    return @isWindMove
  end 
end


BattleHandlers::MoveImmunityTargetAbility.add(:WINDRIDER,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if !move.windMove?
    stat = PBStats::ATTACK
    battle.pbShowAbilitySplash(target)
    if target.pbCanRaiseStatStage?(stat,target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        target.pbRaiseStatStage(stat,1,target)
      else
        target.pbRaiseStatStageByCause(stat,1,target,target.abilityName)
      end
    else
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis,target.abilityName,move.name))
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)
