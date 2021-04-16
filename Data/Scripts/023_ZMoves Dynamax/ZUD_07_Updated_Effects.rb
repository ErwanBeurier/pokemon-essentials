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
  alias _ZUD_unlosableItem unlosableItem?
  def unlosableItem?(check_item)
    return false if check_item <= 0
    return true if pbIsZCrystal?(check_item)
    self._ZUD_unlosableItem(check_item)
  end 
end

#===============================================================================
# Berry Juice
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::HPHealItem.add(:BERRYJUICE,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && battler.hp>battler.totalhp/2
    itemName = PBItems.getName(item)
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
    battle.pbCommonAnimation("UseItem",battler) if !forced
    battler.pbRecoverHP(20,true,true,true) # Ignores Dynamax
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

#===============================================================================
# Oran Berry
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::HPHealItem.add(:ORANBERRY,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && battler.isUnnerved?
    next false if !forced && battler.hp>battler.totalhp/2
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    if battler.hasActiveAbility?(:RIPEN)
      battler.pbRecoverHP(20,true,true,true) # Ignores Dynamax
    else
      battler.pbRecoverHP(10,true,true,true) # Ignores Dynamax
    end
    itemName = PBItems.getName(item)
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

#===============================================================================
# Shell Bell
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::UserItemAfterMoveUse.add(:SHELLBELL,
  proc { |item,user,targets,move,numHits,battle|
    next if !user.canHeal?
    totalDamage = 0
    targets.each { |b| totalDamage += b.damageState.totalHPLost }
    next if totalDamage<=0
    user.pbRecoverHP(totalDamage/8,true,true,true) # Ignores Dynamax
    battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
       user.pbThis,user.itemName))
  }
)

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
      battle.pbRecallAndReplace(user.index, newPkmn, true)
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
# Forewarn
#===============================================================================
# Checks the target's base moves, not Max Moves.
#-------------------------------------------------------------------------------
BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMoveWithIndex do |m,i|
        move = (b.dynamax?) ? b.effects[PBEffects::BaseMoves][i] : m
        moveData = pbGetMoveData(move.id)
        power = moveData[MOVE_BASE_DAMAGE]
        power = 160 if ["070"].include?(moveData[MOVE_FUNCTION_CODE])    # OHKO
        power = 150 if ["08B"].include?(moveData[MOVE_FUNCTION_CODE])    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(moveData[MOVE_FUNCTION_CODE])
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(moveData[MOVE_FUNCTION_CODE])
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(move.id)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveID = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      end
      battle.pbHideAbilitySplash(battler)
    end
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
    user.effects[PBEffects::BaseMoves] = []
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
      user.effects[PBEffects::BaseMoves][i]  = newMove
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end

#===============================================================================
# Copycat
#===============================================================================
# If last move used was a Max Move, copies the base move of that Max Move.
# Move fails if last used move was a Z-Move (handled elsewhere).
# Some functions were rewritten because Copycat had a bug, and the Gen 8 
# project does not contain the bugfix for now.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0AF < PokeBattle_Move
  # Added for bugfix. 
  alias _copycat_initialize initialize
  def initialize(battle,move)
    _copycat_initialize(battle, move)
    @copied_move = -1
  end 
  
  # Added for bugfix. 
  def pbChangeUsageCounters(user,specialUsage)
    super
    @copied_move = @battle.lastMoveUsed || 0
  end

  # Added for bugfix. 
  def pbMoveFailed?(user,targets)
    if @copied_move<=0 ||
       @moveBlacklist.include?(pbGetMoveData(@copied_move,MOVE_FUNCTION_CODE))
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def pbEffectGeneral(user)
    lastmove = @copied_move
    @battle.eachBattler do |b|
      next if @copied_move!=b.lastMoveUsed
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
# Spite
#===============================================================================
# Reduced PP of Max Moves is properly applied to the base move as well.
#-------------------------------------------------------------------------------
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.eachMoveWithIndex do |m,i|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [4,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      target.effects[PBEffects::MaxMovePP][i] +=4 if target.dynamax?
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
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
    if user.dynamax? && !target.dynamaxAble?
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
    newHP = (user.realhp+target.realhp)/2
    if user.realhp>newHP;    user.pbReduceHP(user.realhp-newHP,false,false,true,true)
    elsif user.realhp<newHP; user.pbRecoverHP(newHP-user.realhp,false,true,true)
    end
    if target.realhp>newHP;    target.pbReduceHP(target.realhp-newHP,false,false,true,true)
    elsif target.realhp<newHP; target.pbRecoverHP(newHP-target.realhp,false,true,true)
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
    return target.realhp-user.realhp
  end
end

#===============================================================================
# Super Fang
#===============================================================================
# Damage dealt is based on the target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return (target.realhp/2.0).round
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
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched.length>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end

#===============================================================================
# Strength Sap
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk      = target.attack
    atkStage = target.stages[PBStats::ATTACK]+6
    healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(PBStats::ATTACK,user,self)
      target.pbLowerStatStage(PBStats::ATTACK,1,user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt,true,true,true,true) # Ignores Dynamax
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt*1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt,true,true,true) # Ignores Dynamax
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
end