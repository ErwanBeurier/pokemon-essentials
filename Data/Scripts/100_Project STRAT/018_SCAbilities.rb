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

