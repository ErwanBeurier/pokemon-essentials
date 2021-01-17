# This script assumes that you have the Mid Battle Dialog plugin installed AFTER the Dynamax plugin (not necessarily RIGHT after though). If you have Dynamax after the Mid Battle Dialog plugin, you shouldn't. Put the scripts in the right order. 


class PokeBattle_Battle
  # Loss and Win Dialogue
  alias __midbattledialog_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    @battlers.each do |b|
      next if !b || !b.dynamax?
      next if b.effects[PBEffects::MaxRaidBoss]
      b.unmax
    end
    __midbattledialog_pbEndOfBattle
  end
  
  def pbDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasDynamax? || battler.dynamax? 
    if battler.gmaxFactor?
      if !opposes?(idxBattler)
        TrainerDialogue.display("gmaxBefore",@battle,@battle.scene)
      else
        TrainerDialogue.display("gmaxBeforeOpp",@battle,@battle.scene)
      end
    else
      if !opposes?(idxBattler)
        TrainerDialogue.display("dynamaxBefore",@battle,@battle.scene)
      else
        TrainerDialogue.display("dynamaxBeforeOpp",@battle,@battle.scene)
      end
    end 
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} recalled {2}!",trainerName,battler.pbThis(true)))
    battler.effects[PBEffects::Dynamax]     = DYNAMAX_TURNS
    battler.effects[PBEffects::NonGMaxForm] = battler.form
    battler.effects[PBEffects::Encore]      = 0
    battler.effects[PBEffects::Disable]     = 0
    battler.effects[PBEffects::Torment]     = false
    @scene.pbRecall(idxBattler)
    # Alcremie reverts to form 0 only for the duration of Gigantamax.
    if battler.isSpecies?(:ALCREMIE) && battler.gmaxFactor?
      battler.pokemon.form = 0 
    end
    battler.pokemon.makeDynamax
    text = "Dynamax"
    text = "Gigantamax" if battler.hasGmax? && battler.gmaxFactor?
    text = "Eternamax"  if isConst?(battler.species,PBSpecies,:ETERNATUS)
    pbDisplay(_INTL("{1}'s ball surges with {2} energy!",battler.pbThis,text))
    party = pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    for i in idxPartyStart...idxPartyEnd
      if party[i] == battler.pokemon
        pbSendOut([[idxBattler,party[i]]])
      end
    end
    # Gets appropriate battler sprite if user was transformed prior to Dynamaxing.
    if battler.effects[PBEffects::Transform]
      back = !opposes?(idxBattler)
      pkmn = battler.effects[PBEffects::TransformPokemon]
      @scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back)
    end
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -2
    oldhp = battler.hp
    battler.pbUpdate(false)
    @scene.pbHPChanged(battler,oldhp)
    battler.pokemon.pbReversion(true)
    if battler.gmaxFactor?
      if !opposes?(idxBattler)
        TrainerDialogue.display("gmaxAfter",@battle,@battle.scene)
      else
        TrainerDialogue.display("gmaxAfterOpp",@battle,@battle.scene)
      end
    else
      if !opposes?(idxBattler)
        TrainerDialogue.display("dynamaxAfter",@battle,@battle.scene)
      else
        TrainerDialogue.display("dynamaxAfterOpp",@battle,@battle.scene)
      end
    end 
  end
  
end 




class PokeBattle_Move
# Attack Dialogue
  def pbDisplayUseMessage(user)
    dialogparam = "attack"
    dialogparam = "zmove" if zMove? && !@specialUseZMove
    dialogparam = "maxMove" if maxMove?
    dialogparam += "Opp" if user.opposes?
    
    if !user.damageState.firstAttack
      user.damageState.firstAttack = true
      TrainerDialogue.display(dialogparam,@battle,@battle.scene)
    end
    
    if zMove? && !@specialUseZMove
      @battle.pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",user.pbThis)) if !statusMove?      
      @battle.pbCommonAnimation("ZPower",user,nil)
      PokeBattle_ZMove.pbZStatus(@battle, @id, user) if statusMove?
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",user.pbThis))
    end 
    @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,@name))
  end 
  
# Setting Damage Data
  def pbReduceDamage(user,target)
    damage = target.damageState.calcDamage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage>target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
      return
    end
    # Disguise takes the damage
    return if target.damageState.disguise
    # Ice Face takes the damage
    return if target.damageState.iceface
    # Max Raids - Damage thresholds for triggering shields. (ZUD)
    damage = pbReduceMaxRaidDamage(target,damage)
    # Target takes the damage
    if damage>=target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user,target)
        damage -= 1
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
      elsif damage==target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp==target.totalhp
          target.damageState.focusSash = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100)<10
          target.damageState.focusBand = true
          damage -= 1
        end
      end
    end
    damage = 0 if damage<0
    if damage > (target.totalhp*0.6).floor &&  damage != target.hp
      target.damageState.bigDamage = 1
      target.damageState.smlDamage = 1
    elsif damage < (target.totalhp*0.4).floor &&  damage != target.hp
      target.damageState.smlDamage = 1
    end
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
  end
end 




module TrainerDialogue
  def self.setInstance(parameter)
    noIncrement = ["lowHP","lowHPOpp","halfHP","halfHPOpp","bigDamage","bigDamageOpp","smlDamage",
      "smlDamageOpp","attack","attackOpp","superEff","superEffOpp","notEff","notEffOpp",
      "maxMove", "maxMoveOpp", "zmove", "zmoveOpp", "dynamaxBefore", "dynamaxBeforeOpp", 
      "dynamaxAfter", "dynamaxAfterOpp", "gmaxBefore", "gmaxBeforeOpp", "gmaxAfter", "gmaxAfterOpp"]
    return if parameter.include?("rand")
    if !noIncrement.include?(parameter)
       $PokemonTemp.dialogueInstances[parameter] += 1
    end
  end
end 