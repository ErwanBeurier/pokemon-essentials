#===============================================================================
# Cient diary
# Activates from the bag, isn't consumed. 
# Reminds the player where their next battle is. 
#===============================================================================

ItemHandlers::UseFromBag.add(:CLIENTDIARY,proc { |item|
  scClientBattles.playerNextBattleMessage(false)
  next 1
})



#===============================================================================
# Coats
# Items that reduce the damage. 
# Exclusively for Normal-type Pokémons. 
#===============================================================================

def scHandleCoats(ret, moveType,defType,target)
  if target.pbHasType?(:NORMAL) && defType == PBTypes::NORMAL
    case target.item
    when PBItems::SCELEMENTALCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GRASS
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FIRE
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::WATER
      
    when PBItems::SCMINERALCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ROCK
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GROUND
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::STEEL
      
    when PBItems::SCSWAMPCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::BUG
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::POISON
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DARK
      
    when PBItems::SCFANTASYCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FAIRY
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DRAGON
      
    when PBItems::SCMINDCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::PSYCHIC
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DARK
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FIGHTING
      
    when PBItems::SCMATERIALCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ICE
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::STEEL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ELECTRIC
      
    when PBItems::SCFORESTCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::NORMAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FLYING
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::BUG
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GRASS
      
    when PBItems::SCDEMONICCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DARK
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FIRE
      
    when PBItems::SCAQUATICCOAT
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ICE
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::WATER
      
    end 
  end 
  return ret 
end 



# Coats starting with a vowel (require "an" instead of "a")
BattleHandlers::ItemOnSwitchIn.add(:SCELEMENTALCOAT,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} is wearing an {2}!", battler.pbThis,battler.itemName))
  }
)
BattleHandlers::ItemOnSwitchIn.copy(:SCELEMENTALCOAT,:SCAQUATICCOAT)



# Coats starting with a consonant (require "a" instead of "an")
BattleHandlers::ItemOnSwitchIn.add(:SCMINERALCOAT,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} is wearing a {2}!", battler.pbThis,battler.itemName))
  }
)
BattleHandlers::ItemOnSwitchIn.copy(:SCMINERALCOAT, :SCSWAMPCOAT, :SCFANTASYCOAT, 
  :SCMINDCOAT, :SCMATERIALCOAT, :SCFORESTCOAT, :SCDEMONICCOAT)



#===============================================================================
# Normal crystals 
# Makes Normal moves super-effective against a given type ; gives a resistance 
# to a given type. 
# Exclusively for Normal-type Pokémons. 
#===============================================================================

def scHandleCrystalsTarget(ret, moveType,defType,target)
  if target.pbHasType?(:NORMAL) && defType == PBTypes::NORMAL
    case target.item 
    when PBItems::SCNORMALCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::NORMAL
    when PBItems::SCELECTRICCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ELECTRIC
    when PBItems::SCFIGHTINGCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FIGHTING
    when PBItems::SCFLYINGCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FLYING
    when PBItems::SCROCKCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ROCK
    when PBItems::SCDARKCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DARK
    when PBItems::SCFIRECRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FIRE
    when PBItems::SCGRASSCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GRASS
    when PBItems::SCPOISONCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::POISON
    when PBItems::SCPSYCHICCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::PSYCHIC
    when PBItems::SCSTEELCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::STEEL
    when PBItems::SCWATERCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::WATER
    when PBItems::SCICECRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::ICE
    when PBItems::SCGROUNDCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GROUND
    when PBItems::SCBUGCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::BUG
    when PBItems::SCDRAGONCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::DRAGON
    when PBItems::SCFAIRYCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::FAIRY
    when PBItems::SCGHOSTCRYSTAL
      ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE if moveType == PBTypes::GHOST
    end 
  end 
  return ret 
end 



def scHandleCrystalsUser(ret, moveType,defType,user)
  if user.pbHasType?(:NORMAL) && moveType == PBTypes::NORMAL
    case user.item 
    when PBItems::SCNORMALCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::NORMAL
    when PBItems::SCELECTRICCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::ELECTRIC
    when PBItems::SCFIGHTINGCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::FIGHTING
    when PBItems::SCFLYINGCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::FLYING
    when PBItems::SCROCKCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::ROCK
    when PBItems::SCDARKCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::DARK
    when PBItems::SCFIRECRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::FIRE
    when PBItems::SCGRASSCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::GRASS
    when PBItems::SCPOISONCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::POISON
    when PBItems::SCPSYCHICCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::PSYCHIC
    when PBItems::SCSTEELCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::STEEL
    when PBItems::SCWATERCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::WATER
    when PBItems::SCICECRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::ICE
    when PBItems::SCGROUNDCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::GROUND
    when PBItems::SCBUGCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::BUG
    when PBItems::SCDRAGONCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::DRAGON
    when PBItems::SCFAIRYCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::FAIRY
    when PBItems::SCGHOSTCRYSTAL
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if defType == PBTypes::GHOST
    end 
  end 
  return ret 
end 



# Crystals starting with a vowel (require "an" instead of "a")
BattleHandlers::ItemOnSwitchIn.add(:SCELECTRICCRYSTAL,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} is holding an {2}!", battler.pbThis,battler.itemName))
  }
)
BattleHandlers::ItemOnSwitchIn.copy(:SCELECTRICCRYSTAL,:SCICECRYSTAL)



# Crystals starting with a consonant (require "a" instead of "an")
BattleHandlers::ItemOnSwitchIn.add(:SCNORMALCRYSTAL,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} is holding a {2}!", battler.pbThis,battler.itemName))
  }
)
BattleHandlers::ItemOnSwitchIn.copy(:SCNORMALCRYSTAL, :SCFIGHTINGCRYSTAL, 
    :SCFLYINGCRYSTAL, :SCROCKCRYSTAL, :SCDARKCRYSTAL, :SCFIRECRYSTAL, 
    :SCGRASSCRYSTAL, :SCPOISONCRYSTAL, :SCPSYCHICCRYSTAL, :SCSTEELCRYSTAL,
    :SCWATERCRYSTAL, :SCGROUNDCRYSTAL, :SCBUGCRYSTAL, :SCDRAGONCRYSTAL, 
    :SCFAIRYCRYSTAL, :SCGHOSTCRYSTAL)




#===============================================================================
# Normal Maxer 
# Gives 50% bonus to Normal-types moves + 20% to other moves. 
# Exclusively for Normal-type Pokémons. 
#===============================================================================

BattleHandlers::DamageCalcUserItem.add(:SCNORMALMAXER,
	proc { |item,user,target,move,mults,baseDmg,type|
		if user.pbHasType?(PBTypes::NORMAL)
			if type == PBTypes::NORMAL
				mults[BASE_DMG_MULT] *= 1.5
			else
				mults[BASE_DMG_MULT] *= 1.2
			end
		end 
	}
)

BattleHandlers::ItemOnSwitchIn.add(:SCNORMALMAXER,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} is holding a {2}!", battler.pbThis,battler.itemName))
  }
)


#===============================================================================
# Eviolite variants
#===============================================================================

# TREN = Trenbolone (steroid)
BattleHandlers::DamageCalcTargetItem.add(:EVIOLITETREN,
  proc { |item,user,target,move,mults,baseDmg,type|
    # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
    #       means it also cares about the Pokémon's form. Some forms cannot
    #       evolve even if the species generally can, and such forms are not
    #       affected by Eviolite.
    next if !move.physicalMove?
    evos = pbGetEvolvedFormData(target.pokemon.fSpecies,true)
    mults[ATK_MULT] *= 1.3 if evos && evos.length>0
  }
)
# MPH = Methylphenidate (Ritalin, for attention deficit).
BattleHandlers::DamageCalcTargetItem.add(:EVIOLITEMPH,
  proc { |item,user,target,move,mults,baseDmg,type|
    # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
    #       means it also cares about the Pokémon's form. Some forms cannot
    #       evolve even if the species generally can, and such forms are not
    #       affected by Eviolite.
    next if !move.specialMove?
    evos = pbGetEvolvedFormData(target.pokemon.fSpecies,true)
    mults[ATK_MULT] *= 1.3 if evos && evos.length>0
  }
)






