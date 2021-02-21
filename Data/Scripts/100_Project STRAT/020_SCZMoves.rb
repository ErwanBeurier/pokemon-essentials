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