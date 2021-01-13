#===============================================================================
#
# ZUD_07: Updated Effects
#
#===============================================================================
# This script rewrites areas of the Essentials script that handle certain items,
# abilities, and moves that need to be changed to accomodate ZUD mechanics.
#
#===============================================================================
# SECTION 1 - ITEMS
#-------------------------------------------------------------------------------
# This section rewrites code for certain item effects or properties to allow for
# compatibility with ZUD mechanics.
#===============================================================================
# SECTION 2 - ABILITIES
#-------------------------------------------------------------------------------
# This section rewrites code for certain ability effects to allow them to 
# function as intended with certain ZUD mechanics.
#===============================================================================
# SECTION 3 - MOVES
#-------------------------------------------------------------------------------
# This section rewrites code for certain move effects to allow them to function
# as intended with certain ZUD mechanics.
#===============================================================================


################################################################################
# SECTION 1 - ITEMS
#===============================================================================
# Updated code for item effects or item properties related to Z-Moves/Dynamax.
#===============================================================================

#===============================================================================
# Z-Crystals
#===============================================================================
# Adds Z-Crystals to items that are infinite in use.
#-------------------------------------------------------------------------------
def pbIsImportantItem?(item)
  itemData = pbLoadItemsData[getID(PBItems,item)]
  return false if !itemData
  return true if itemData[ITEM_TYPE] && itemData[ITEM_TYPE]==6
  return true if itemData[ITEM_TYPE] && itemData[ITEM_TYPE]==14  # Z-Crystals.
  return true if itemData[ITEM_FIELD_USE] && itemData[ITEM_FIELD_USE]==4
  return true if itemData[ITEM_FIELD_USE] && itemData[ITEM_FIELD_USE]==3 && INFINITE_TMS
  return false
end

#-------------------------------------------------------------------------------
# Adds Z-Crystals to held items that cannot be lost or stolen.
#-------------------------------------------------------------------------------
class PokeBattle_Battler
  def unlosableItem?(check_item)
    return false if check_item <= 0
    return true if pbIsMail?(check_item)
    return true if pbIsZCrystal?(check_item)
    return false if @effects[PBEffects::Transform]
    return true if @pokemon && @pokemon.getMegaForm(true) > 0
    return pbIsUnlosableItem?(check_item, @species, @ability)
  end 
end

#===============================================================================
# Confusion Berries
#===============================================================================
# Restores user's HP based on their non-Dynamax HP.
#-------------------------------------------------------------------------------
def pbBattleConfusionBerry(battler,battle,item,forced,flavor,confuseMsg)
  return false if !forced && !battler.pbCanConsumeBerry?(item,false)
  itemName = PBItems.getName(item)
  battle.pbCommonAnimation("EatBerry",battler) if !forced
  baseHP = battler.totalhp
  baseHP = (battler.totalhp/battler.pokemon.dynamaxCalc).floor if battler.dynamax?
  amt = (NEWEST_BATTLE_MECHANICS) ? battler.pbRecoverHP(baseHP/3) : battler.pbRecoverHP(baseHP/2)
  if amt>0
    if forced
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
  end
  nUp = PBNatures.getStatRaised(battler.nature)
  nDn = PBNatures.getStatLowered(battler.nature)
  if nUp!=nDn && nDn-1==flavor
    battle.pbDisplay(confuseMsg)
    battler.pbConfuse if battler.pbCanConfuseSelf?(false)
  end
  return true
end

#===============================================================================
# Choice Items
#===============================================================================
# Stat bonuses are not applied to Z-Moves/Max Moves.
#-------------------------------------------------------------------------------
BattleHandlers::DamageCalcUserItem.add(:CHOICEBAND,
  proc { |item,user,target,move,mults,baseDmg,type|
    if move.physicalMove? && !move.powerMove?
      mults[BASE_DMG_MULT] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserItem.add(:CHOICESPECS,
  proc { |item,user,target,move,mults,baseDmg,type|
    if move.specialMove? && !move.powerMove?
      mults[BASE_DMG_MULT] *= 1.5 
    end
  }
)

BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
  proc { |item,battler,mult|
    next mult*1.5 if !battler.dynamax?
  }
)

#===============================================================================
# Red Card
#===============================================================================
# Item triggers, but its effects fail to activate vs Dynamax targets.
#-------------------------------------------------------------------------------
BattleHandlers::TargetItemAfterMoveUse.add(:REDCARD,
  proc { |item,battler,user,move,switched,battle|
    next if user.fainted? || switched.include?(user.index)
    newPkmn = battle.pbGetReplacementPokemonIndex(user.index,true)
    next if newPkmn<0
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
       battler.pbThis,battler.itemName,user.pbThis(true)))
    battler.pbConsumeItem
    if user.dynamax?
      battle.pbDisplay(_INTL("But it failed!"))
    else
      battle.pbRecallAndReplace(user.index,newPkmn)
      battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
      battle.pbClearChoice(user.index)
      switched.push(user.index)
    end
  }
)


################################################################################
# SECTION 2 - ABILITIES
#===============================================================================
# Updated code for ability effects related to Z-Moves/Dynamax.
#===============================================================================

#===============================================================================
# Imposter
#===============================================================================
# Ability fails to trigger if the user is Dynamaxed, and the transform target
# is a species that is unable to have a Dynamax form.
#-------------------------------------------------------------------------------
BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if battler.dynamax? && !choice.dynamaxAble?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(getConst(PBMoves,:TRANSFORM),battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

#===============================================================================
# Gorilla Tactics
#===============================================================================
# No Attack multiplier applied when using Z-Moves/Max Moves.
#-------------------------------------------------------------------------------
BattleHandlers::DamageCalcUserAbility.add(:GORILLATACTICS,
  proc { |ability,user,target,move,mults,baseDmg,type|
  if move.physicalMove? && !move.powerMove?
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
  end
  }
)

#===============================================================================
# Cursed Body
#===============================================================================
# Ability fails to trigger if the attacker is a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted? || user.dynamax?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.totalpp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# Wandering Spirit
#===============================================================================
# Ability fails to trigger if the attacker is a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted? || user.dynamax?
    abilityBlacklist = [
       :DISGUISE,
       :FLOWERGIFT,
       :GULPMISSILE,
       :ICEFACE,
       :IMPOSTER,
       :RECEIVER,
       :RKSSYSTEM,
       :SCHOOLING,
       :STANCECHANGE,
       :WONDERGUARD,
       :ZENMODE,
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    oldAbil = -1
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = getConst(PBAbilities,:WANDERINGSPIRIT)
      target.ability = oldAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end

      battle.pbHideAbilitySplash(user)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    if oldAbil>=0
      user.pbOnAbilityChanged(oldAbil)
      target.pbOnAbilityChanged(getConst(PBAbilities,:WANDERINGSPIRIT))
    end

  }
)


################################################################################
# SECTION 3 - MOVES
#===============================================================================
# Updated code for move effects related to Z-Moves/Max Moves.
#===============================================================================

#===============================================================================
# Assist
#===============================================================================
# Ignores Z-Moves/Max Moves when calling a move in the party.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @assistMoves = []
    @battle.pbParty(user.index).each_with_index do |pkmn,i|
      next if !pkmn || i==user.pokemonIndex
      next if NEWEST_BATTLE_MECHANICS && pkmn.egg?
      pkmn.moves.each do |move|
        next if !move || move.id<=0
        flags = pbGetMoveData(move.id,MOVE_FLAGS)
        next if flags.include?("x") || flags.include?("z") # Z-Move/Max Move flags
        next if @moveBlacklist.include?(pbGetMoveData(move.id,MOVE_FUNCTION_CODE))
        next if isConst?(move.type,PBTypes,:SHADOW)
        @assistMoves.push(move.id)
      end
    end
    if @assistMoves.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Metronome
#===============================================================================
# Ignores Z-Moves/Max Moves when calling a random move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    movesData = pbLoadMovesData
    @metronomeMove = 0
    1000.times do
      move = @battle.pbRandom(PBMoves.maxValue)+1
      next if !movesData[move]
      flags = movesData[move][MOVE_FLAGS]
      next if flags.include?("x") || flags.include?("z") # Z-Move/Max Move flags
      next if @moveBlacklist.include?(movesData[move][MOVE_FUNCTION_CODE])
      blMove = false
      @moveBlacklistSignatures.each do |m|
        next if !isConst?(move,PBMoves,m)
        blMove = true; break
      end
      next if blMove
      next if isConst?(movesData[move][MOVE_TYPE],PBTypes,:SHADOW)
      @metronomeMove = move
      break
    end
    if @metronomeMove<=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Me First
#===============================================================================
# Move fails when attempting to copy a target's Z-Move/Max Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B0 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    oppMove = @battle.choices[target.index][2]
    if !oppMove || oppMove.id<=0 || oppMove.powerMove? || # Z-Move/Max Move flags
       oppMove.statusMove? || @moveBlacklist.include?(oppMove.function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Sketch
#===============================================================================
# Move fails when attempting to Sketch a Z-Move/Max Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05D < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
    oppMove = @battle.choices[target.index][2]
    if target.lastRegularMoveUsed<=0 || oppMove.powerMove? || # Z-Move/Max Move flags
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
       isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Mimic
#===============================================================================
# Move fails when attempting to Mimic a Z-Move/Max Move.
# Records mimicked move as a new base move to revert to after Z-Move/Dynamax.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05C < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
    if target.lastRegularMoveUsed<=0 || 
       target.lastMoveUsedIsZMove || lastMoveData[MOVE_FLAGS].include?("x") || # Z-Move/Max Move
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
       isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  # Records the correct move to revert to after Z-Move/Dynamax.
  def pbEffectAgainstTarget(user,target)
    user.effects[PBEffects::BaseMoves]   = []
    for i in 0...4
      battlemove = PokeBattle_Move.pbFromPBMove(@battle,user.pokemon.moves[i])
      user.effects[PBEffects::BaseMoves].push(battlemove)
    end
    user.eachMoveWithIndex do |m,i|
      next if m.id!=@id
      newMove = PBMove.new(target.lastRegularMoveUsed)
      newMove = PokeBattle_Move.pbFromPBMove(@battle,newMove)
      user.moves[i] = newMove
      @battle.pbDisplay(_INTL("{1} learned {2}!",user.pbThis,
         PBMoves.getName(target.lastRegularMoveUsed)))
      user.effects[PBEffects::MoveMimicked]  = true
      user.effects[PBEffects::BaseMoves][i]   = newMove
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end

#===============================================================================
# Copycat
#===============================================================================
# If last move used was a Max Move, copies the base move of that Max Move.
# Move fails if last use move was a Z-Move (handled elsewhere).
#-------------------------------------------------------------------------------
class PokeBattle_Move_0AF < PokeBattle_Move
  def pbEffectGeneral(user)
    lastmove = @battle.lastMoveUsed
    @battle.eachBattler do |b|
      next if @battle.lastMoveUsed!=b.lastMoveUsed
      if b.dynamax?
        movesel  = @battle.choices[b.index][1]
        lastmove = b.pokemon.moves[movesel].id
      end
    end
    user.pbUseMoveSimple(lastmove)
  end
end

#===============================================================================
# Encore
#===============================================================================
# Move fails if the target's last used move was a Z-Move.
# No effect on Max Moves because Dynamax Pokemon are already immune to Encore.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0BC < PokeBattle_Move
  alias _ZUD_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user,target)
    if target.lastMoveUsedIsZMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return _ZUD_pbFailsAgainstTarget?(user, target)
  end
end

#===============================================================================
# Sleep Talk
#===============================================================================
# Z-Sleep Talk will use the Z-Powered version of the random move selected.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbEffectGeneral(user)
    choice = @sleepTalkMoves[@battle.pbRandom(@sleepTalkMoves.length)]
    user.pbUseMoveSimple(user.moves[choice].id,user.pbDirectOpposing.index, choice)
  end
end

#===============================================================================
# Transform
#===============================================================================
# Move fails if the user is Dynamaxed and attempts to Transform into a species
# that is unable to have a Dynamax form.
#-------------------------------------------------------------------------------
class PokeBattle_Move_069 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Transform] ||
       target.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.effects[PBEffects::Dynamax]>0 && !target.dynamaxAble?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Pain Split
#===============================================================================
# Changes to HP is based on user/target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    userHP = user.hp
    targHP = target.hp
    userHP = (user.hp/user.dynamaxBoost).round if user.dynamax?
    targHP = (target.hp/target.dynamaxBoost).round if target.dynamax?
    newHP  = (userHP+targHP)/2
    if userHP>newHP;    user.pbReduceHP(userHP-newHP,false,false)
    elsif userHP<newHP; user.pbRecoverHP(newHP-userHP,false)
    end
    if targHP>newHP;    target.pbReduceHP(targHP-newHP,false,false)
    elsif targHP<newHP; target.pbRecoverHP(newHP-targHP,false)
    end
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    user.pbItemHPHealCheck
    target.pbItemHPHealCheck
  end
end

#===============================================================================
# Endeavor
#===============================================================================
# Damage dealt is based on the user/target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_06E < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    userHP = user.hp
    targHP = target.hp
    userHP = (user.hp/user.dynamaxBoost).round if user.dynamax?
    targHP = (target.hp/target.dynamaxBoost).round if target.dynamax?
    return targHP-userHP
  end
end

#===============================================================================
# Super Fang
#===============================================================================
# Damage dealt is based on the target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    baseHP = target.hp
    baseHP = (target.hp/target.dynamaxBoost).round if target.dynamax?
    return (baseHP/2.0).round
  end
end

#===============================================================================
# Defog
#===============================================================================
# Also clears away hazard applied with G-Max Steelsurge.
#-------------------------------------------------------------------------------
class PokeBattle_Move_049 < PokeBattle_TargetStatDownMove
  alias _ZUD_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::Steelsurge]
    return false if NEWEST_BATTLE_MECHANICS && 
                    target.pbOpposingSide.effects[PBEffects::Steelsurge]
    _ZUD_pbFailsAgainstTarget?(user,target)
    return super
  end
  
  alias _ZUD_pbEffectAgainstTarget pbEffectAgainstTarget
  def pbEffectAgainstTarget(user,target)
    _ZUD_pbEffectAgainstTarget(user,target)
    if target.pbOwnSide.effects[PBEffects::Steelsurge] ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::Steelsurge])
      target.pbOwnSide.effects[PBEffects::Steelsurge]      = false
      target.pbOpposingSide.effects[PBEffects::Steelsurge] = false if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
  end
end

#===============================================================================
# Rapid Spin
#===============================================================================
# Also clears away hazard applied with G-Max Steelsurge.
#-------------------------------------------------------------------------------
class PokeBattle_Move_110 < PokeBattle_Move
  alias _ZUD_pbEffectAfterAllHits pbEffectAfterAllHits
  def pbEffectAfterAllHits(user,target)
    _ZUD_pbEffectAfterAllHits(user,target)
    return if user.fainted? || target.damageState.unaffected
    if user.pbOwnSide.effects[PBEffects::Steelsurge]
      user.pbOwnSide.effects[PBEffects::Steelsurge] = false
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
  end
end

#===============================================================================
# Dragon Tail/Circle Throw
#===============================================================================
# Forced switch fails to trigger if target is Dynamaxed, or user is Raid Boss.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if @battle.wildBattle? && target.level<=user.level && 
       !target.dynamax? && !user.effects[PBEffects::MaxRaidBoss] &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      @battle.decision = 3
    end
  end
  
  def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    return if @battle.wildBattle?
    return if user.fainted? || numHits==0
    return if user.effects[PBEffects::MaxRaidBoss]
    roarSwitched = []
    targets.each do |b|
      next if b.dynamax?
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if switchedBattlers.include?(b.index)
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
      next if newPkmn<0
      @battle.pbRecallAndReplace(b.index,newPkmn)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end