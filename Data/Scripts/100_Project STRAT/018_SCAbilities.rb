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
  
  def __blademove__init initialize
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
                      PBMoves::XSCISSOR].include(@id)
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
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:AVENGER,
  proc { |ability,battler,fainted,battle|
    next if fainted.opposes?(battler)
    battle.pbShowAbilitySplash(battler)
    battler.pbRaiseStatStageByAbility(PBStats::ATTACK,3,battler)
    battle.pbDisplay(_INTL("{1} wants to avenge {2}!", battler.pbThis, fainted.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

