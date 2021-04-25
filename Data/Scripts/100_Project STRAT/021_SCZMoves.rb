################################################################################
# SCZMoves
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of new Z-moves. I also redefine some 
# other classes to go with them.
################################################################################

#===============================================================================
# Prehistoric Power Rejurgence
#===============================================================================
# Is physical or special depending on what's best + boosts all stats. 
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z010 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @calcCategory = 1
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,
               PBStats::SPATK,1,PBStats::SPDEF,1,
               PBStats::SPEED,1]
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk        = user.attack
    atkStage   = user.stages[PBStats::ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[PBStats::SPATK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end


#===============================================================================
# Confusion Solo Dance
#===============================================================================
# Boosts all stats. 
#-------------------------------------------------------------------------------

class PokeBattle_Move_Z011 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,3,PBStats::DEFENSE,3,
               PBStats::SPATK,3,PBStats::SPDEF,3,
               PBStats::SPEED,3]
  end
end 


#===============================================================================
# Phoenix Fire
#===============================================================================
# Resurrects a Pokémon from the party. 
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z012 < PokeBattle_ZMove_AllStatsUp
  def pbAdditionalEffect(user, target)
    return if @battle.positions[user.index].effects[PBEffects::PhoenixFire]
    @battle.positions[user.index].effects[PBEffects::PhoenixFire] = true
    @battle.pbDisplay(_INTL("{1} sets up a reviving fire!",user.name))
  end 
end

# Phoenix Fire effect. 
class PokeBattle_Battler
# Faint Dialogue
  alias __phoenix__faint pbFaint # Should be the one from ZUD
  def pbFaint(showMessage=true)
    return if @fainted # Already fainted properly. 
    if @battle.positions[@index].effects[PBEffects::PhoenixFire]
      @battle.positions[@index].effects[PBEffects::PhoenixFire] = false
      @battle.pbCommonAnimation("PhoenixFireEffect",self)
      pbRecoverHP((self.totalhp*3 / 4).round)
      self.status      = PBStatuses::NONE
      self.statusCount = 0
      @battle.pbDisplay(_INTL("{1} was saved by Phoenix Fire!",pbThis))
      if !opposes?
        TrainerDialogue.display("phenixFire",@battle,@battle.scene, self)
      else
        TrainerDialogue.display("phenixFireOpp",@battle,@battle.scene, self)
      end
      return 
    end 
    return __phoenix__faint(showMessage)
  end
end
