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
# Sharp Edge
# Raises the damage for "slashing" moves. 
#===============================================================================

class PokeBattle_Move
  def bladeMove?
    return [PBMoves::XSCISSOR, PBMoves::NIGHTSLASH, PBMoves::SACREDSWORD, 
      PBMoves::SECRETSWORD, PBMoves::AERIALACE, PBMoves::AIRSLASH,
      PBMoves::LEAFBLADE, PBMoves::SOLARBLADE, PBMoves::CROSSPOISON,
      PBMoves::PSYCHOCUT, PBMoves::BEHEMOTHBLADE, PBMoves::RAZORSHELL,
      PBMoves::CUT, PBMoves::FALSESWIPE, PBMoves::SLASH].include(@id)
  end 
end


BattleHandlers::DamageCalcUserAbility.add(:SHARPEDGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] *= 4/3.0 if move.bladeMove?
  }
)

