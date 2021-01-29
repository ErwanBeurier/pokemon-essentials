#===============================================================================
#
# ZUD_06: Move Effects
#
#===============================================================================
# This script handles the effects of each individual Z-Move and Max Move, as
# well as any new moves that have effects associated with a ZUD mechanic.
#
#===============================================================================
# SECTION 1 - NEW MOVES
#-------------------------------------------------------------------------------
# This section contains new moves added in the series that have some kind of 
# special functionality with a ZUD mechanic, such as Dynamax Cannon.
#===============================================================================
# SECTION 2 - Z-MOVES
#-------------------------------------------------------------------------------
# This section contains each individual Z-Move that have some kind of unique
# effect, as well as the generic type-based Z-Moves with no additional effects.
# Z-Moves use the function codes starting with "Z000" and up.
#===============================================================================
# SECTION 3 - MAX MOVES
#-------------------------------------------------------------------------------
# This section contains each individual Max Move and G-Max Move that have some
# kind of unique effect.
# Max Moves use the function codes starting with "D000" and up.
#===============================================================================

################################################################################
# SECTION 1 - NEW MOVES
#===============================================================================
# Deals double damage vs Dynamax targets, except for Eternamax Eternatus.
# (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.dynamax? && !target.isSpecies?(:ETERNATUS)
      baseDmg *= 2
    end
    return baseDmg
  end
end

################################################################################
# SECTION 2 - Z-MOVES
#===============================================================================
# Generic move classes. 
#===============================================================================
# Raises all of the user's stats.
#-------------------------------------------------------------------------------
class PokeBattle_ZMove_AllStatsUp < PokeBattle_ZMove
  def initialize(battle,move,pbmove)
    super
    @statUp = []
  end
  
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Generic Z-Moves
#===============================================================================
# No effect.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z000 < PokeBattle_ZMove
end

#===============================================================================
# Stoked Sparksurfer
#===============================================================================
# Inflicts paralysis.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z001 < PokeBattle_ZMove
  def initialize(battle,move,pbmove)
    super
  end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanParalyze?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbParalyze(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
  end
end 

#===============================================================================
# Malicious Moonsault
#===============================================================================
# Doubles damage on minimized Pokémon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z002 < PokeBattle_ZMove
  def tramplesMinimize?(param=1)
    # Perfect accuracy and double damage if minimized
    return NEWEST_BATTLE_MECHANICS
  end
end 

#===============================================================================
# Extreme Evoboost
#===============================================================================
# Raises all stats by 2 stages.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z003 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,2,PBStats::DEFENSE,2,
               PBStats::SPATK,2,PBStats::SPDEF,2,
               PBStats::SPEED,2]
  end
end 

#===============================================================================
# Genesis Supernova
#===============================================================================
# Sets Psychic Terrain.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z004 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    @battle.pbStartTerrain(user,PBBattleTerrains::Psychic)
  end
end 

#===============================================================================
# Guardian of Alola
#===============================================================================
# Inflicts 75% of the target's current HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z005 < PokeBattle_ZMove
  def pbFixedDamage(user,target)
    return (target.hp*0.75).round
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end
end

#===============================================================================
# Clangorous Soulblaze
#===============================================================================
# Boosts all stats.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z006 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,
               PBStats::SPATK,1,PBStats::SPDEF,1,
               PBStats::SPEED,1]
  end
end 

#===============================================================================
# Menacing Moonraze Maelstrom, Searing Sunraze Smash
#===============================================================================
# Ignores ability.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z007 < PokeBattle_ZMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end 

#===============================================================================
# Splintered Stormshards
#===============================================================================
# Removes terrains.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z008 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    case @battle.field.terrain
    when PBBattleTerrains::Electric
      @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
    when PBBattleTerrains::Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
    when PBBattleTerrains::Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield!"))
    when PBBattleTerrains::Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.pbStartTerrain(user,PBBattleTerrains::None,true)
  end
end 

#===============================================================================
# Light That Burns the Sky
#===============================================================================
# Ignores ability + is physical or special depending on what's best. 
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z009 < PokeBattle_Move_Z007
  def initialize(battle,move,pbmove)
    super
    @calcCategory = 1
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


################################################################################
# SECTION 3 - MAX MOVES
#===============================================================================
# Generic move classes. 
#===============================================================================
# Raise stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_StatUp < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.pbRaiseStatStage(@statUp[0],@statUp[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Lower stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_TargetStatDown < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbLowerStatStage(@statDown[0],@statDown[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up weather on use.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Weather < PokeBattle_MaxMove
  def initialize(battle,move,pbmove)
    super
    @weatherType = PBWeather::None
  end
  
  def pbEffectGeneral(user)
    if @battle.field.weather!=PBWeather::HarshSun &&
       @battle.field.weather!=PBWeather::HeavyRain &&
       @battle.field.weather!=PBWeather::StrongWinds &&
       @battle.field.weather!=@weatherType
      @battle.pbStartWeather(user,@weatherType,true,false)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up battle terrain on use.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Terrain < PokeBattle_MaxMove
  def initialize(battle,move,pbmove)
    super
    @terrainType = PBBattleTerrains::None
  end

  def pbEffectGeneral(user)
    if @battle.field.terrain!=@terrainType
      @battle.pbStartTerrain(user,@terrainType)
    end
  end
end

#-------------------------------------------------------------------------------
# Applies one of multiple statuses on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Status < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      randstatus = @statuses[@battle.pbRandom(@statuses.length)]
      if b.pbCanInflictStatus?(randstatus,b,false)
        b.pbInflictStatus(randstatus)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Confusion < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbConfuse if b.pbCanConfuse?(user,false)
    end
  end
end

#===============================================================================
# G-Max One Blow, G-Max Rapid Flow.
#===============================================================================
# No effect. (Protection bypass handled elsewhere)
#-------------------------------------------------------------------------------
class PokeBattle_Move_D000 < PokeBattle_MaxMove
end

#===============================================================================
# Max Guard.
#===============================================================================
# Guards the user from all attacks, including Z-Moves/Max Moves.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D001 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::MaxGuard
  end
end

#===============================================================================
# Max Knuckle, Max Steelspike, Max Ooze, Max Quake, Max Airstream.
#===============================================================================
# Increases a stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D002 < PokeBattle_MaxMove_StatUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,1]  if isConst?(@id,PBMoves,:MAXKNUCKLE)
    @statUp = [PBStats::DEFENSE,1] if isConst?(@id,PBMoves,:MAXSTEELSPIKE)
    @statUp = [PBStats::SPATK,1]   if isConst?(@id,PBMoves,:MAXOOZE)
    @statUp = [PBStats::SPDEF,1]   if isConst?(@id,PBMoves,:MAXQUAKE)
    @statUp = [PBStats::SPEED,1]   if isConst?(@id,PBMoves,:MAXAIRSTREAM)
  end
end


#===============================================================================
# Max Wyrmwind, Max Phantasm, Max Flutterby, Max Darkness, Max Strike.
# G-Max Foamburst, G-Max Tartness.
#===============================================================================
# Decreases a stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D003 < PokeBattle_MaxMove_TargetStatDown
  def initialize(battle,move,pbmove)
    super
    @statDown = [PBStats::ATTACK,1]  if isConst?(@id,PBMoves,:MAXWYRMWIND)
    @statDown = [PBStats::DEFENSE,1] if isConst?(@id,PBMoves,:MAXPHANTASM)
    @statDown = [PBStats::SPATK,1]   if isConst?(@id,PBMoves,:MAXFLUTTERBY)
    @statDown = [PBStats::SPDEF,1]   if isConst?(@id,PBMoves,:MAXDARKNESS)
    @statDown = [PBStats::SPEED,1]   if isConst?(@id,PBMoves,:MAXSTRIKE)
    @statDown = [PBStats::SPEED,2]   if isConst?(@id,PBMoves,:GMAXFOAMBURST)
    @statDown = [PBStats::EVASION,1] if isConst?(@id,PBMoves,:GMAXTARTNESS)
  end
end

#===============================================================================
# Max Flare, Max Gyser, Max Hailstorm, Max Rockfall.
#===============================================================================
# Sets up weather effect on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D004 < PokeBattle_MaxMove_Weather
  def initialize(battle,move,pbmove)
    super
    @weatherType = PBWeather::Sun       if isConst?(@id,PBMoves,:MAXFLARE)
    @weatherType = PBWeather::Rain      if isConst?(@id,PBMoves,:MAXGEYSER)
    @weatherType = PBWeather::Hail      if isConst?(@id,PBMoves,:MAXHAILSTORM)
    @weatherType = PBWeather::Sandstorm if isConst?(@id,PBMoves,:MAXROCKFALL)
  end
end

#===============================================================================
# Max Overgrowth, Max Lightning, Max Starfall, Max Mindstorm.
#===============================================================================
# Sets up battle terrain on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D005 < PokeBattle_MaxMove_Terrain
  def initialize(battle,move,pbmove)
    super
    @terrainType = PBBattleTerrains::Electric if isConst?(@id,PBMoves,:MAXLIGHTNING)
    @terrainType = PBBattleTerrains::Grassy   if isConst?(@id,PBMoves,:MAXOVERGROWTH)
    @terrainType = PBBattleTerrains::Misty    if isConst?(@id,PBMoves,:MAXSTARFALL)
    @terrainType = PBBattleTerrains::Psychic  if isConst?(@id,PBMoves,:MAXMINDSTORM)
  end
end

#===============================================================================
# G-Max Vine Lash, G-Max Wildfire, G-Max Cannonade, G-Max Volcalith.
#===============================================================================
# Damages all Pokemon on the opposing field for 4 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D006 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXVINELASH) &&
       user.pbOpposingSide.effects[PBEffects::VineLash]==0
      user.pbOpposingSide.effects[PBEffects::VineLash]=4
      @battle.pbDisplay(_INTL("{1} got trapped with vines!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXWILDFIRE) &&
       user.pbOpposingSide.effects[PBEffects::Wildfire]==0
      user.pbOpposingSide.effects[PBEffects::Wildfire]=4
      @battle.pbDisplay(_INTL("{1} were surrounded by fire!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXCANNONADE) &&
       user.pbOpposingSide.effects[PBEffects::Cannonade]==0
      user.pbOpposingSide.effects[PBEffects::Cannonade]=4
      @battle.pbDisplay(_INTL("{1} got caught in a vortex of water!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXVOLCALITH) &&
       user.pbOpposingSide.effects[PBEffects::Volcalith]==0
      user.pbOpposingSide.effects[PBEffects::Volcalith]=4
      @battle.pbDisplay(_INTL("{1} became surrounded by rocks!",user.pbOpposingTeam))
    end
  end
end

#===============================================================================
# G-Max Drum Solo, G-Max Fireball, G-Max Hydrosnipe.
#===============================================================================
# Bypasses target's abilities that would reduce or ignore damage.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D007 < PokeBattle_MaxMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end

#===============================================================================
# G-Max Malador, G-Max Volt Crash, G-Max Stun Shock, G-Max Befuddle.
#===============================================================================
# Applies status effects on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D008 < PokeBattle_MaxMove_Status
  def initialize(battle,move,pbmove)
    super
    if isConst?(@id,PBMoves,:GMAXMALODOR)
      @statuses = [PBStatuses::POISON]
    end
    if isConst?(@id,PBMoves,:GMAXVOLTCRASH)
      @statuses = [PBStatuses::PARALYSIS]
    end
    if isConst?(@id,PBMoves,:GMAXSTUNSHOCK)
      @statuses = [PBStatuses::POISON,PBStatuses::PARALYSIS]
    end
    if isConst?(@id,PBMoves,:GMAXBEFUDDLE)
      @statuses = [PBStatuses::POISON,PBStatuses::PARALYSIS,PBStatuses::SLEEP]
    end
  end
end

#===============================================================================
# G-Max Smite, G-Max Gold Rush.
#===============================================================================
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D009 < PokeBattle_MaxMove_Confusion
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXGOLDRUSH) && user.pbOwnedByPlayer?
      @battle.field.effects[PBEffects::PayDay] += 100*user.level
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end
end

#===============================================================================
# G-Max Stonesurge, G-Max Steelsurge.
#===============================================================================
# Sets up entry hazard on the opposing side's field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D010 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXSTONESURGE) &&
       !user.pbOpposingSide.effects[PBEffects::StealthRock]
      user.pbOpposingSide.effects[PBEffects::StealthRock] = true
      @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
         user.pbOpposingTeam(true)))
    end
    if isConst?(@id,PBMoves,:GMAXSTEELSURGE) &&
       !user.pbOpposingSide.effects[PBEffects::Steelsurge]
      user.pbOpposingSide.effects[PBEffects::Steelsurge] = true
      @battle.pbDisplay(_INTL("Sharp-pointed pieces of steel started floating around {1}!",
         user.pbOpposingTeam(true)))
    end   
  end
end

#===============================================================================
# G-Max Centiferno, G-Max Sand Blast.
#===============================================================================
# Traps all opposing Pokemon in a vortex for multiple turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D011 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    moveid = getID(PBMoves,:FIRESPIN) if isConst?(@id,PBMoves,:GMAXCENTIFERNO)
    moveid = getID(PBMoves,:SANDTOMB) if isConst?(@id,PBMoves,:GMAXSANDBLAST)
    user.eachOpposing do |b|    
      next if b.damageState.substitute
      next if b.effects[PBEffects::Trapping]>0
      if user.hasActiveItem?(:GRIPCLAW)
        b.effects[PBEffects::Trapping] = (NEWEST_BATTLE_MECHANICS) ? 8 : 6
      else
        b.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
      end
      b.effects[PBEffects::TrappingMove] = moveid
      b.effects[PBEffects::TrappingUser] = user.index
      msg = _INTL("{1} was trapped in the vortex!",b.pbThis)
      if isConst?(@id,PBMoves,:GMAXCENTIFERNO)
        msg = _INTL("{1} was trapped in the fiery vortex!",b.pbThis)
      elsif isConst?(@id,PBMoves,:GMAXSANDBLAST)
        msg = _INTL("{1} became trapped by Sand Tomb!",b.pbThis)
      end
      @battle.pbDisplay(msg)
    end
  end
end

#===============================================================================
# G-Max Wind Rage.
#===============================================================================
# Blows away effects hazards and opponent side's effects.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D012 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist]>0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard]>0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOwnSide.effects[PBEffects::StickyWebUser]  = -1
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if NEWEST_BATTLE_MECHANICS
      target.pbOpposingSide.effects[PBEffects::StickyWebUser] = -1 if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Steelsurge] ||
       (NEWEST_BATTLE_MECHANICS &&
       target.pbOpposingSide.effects[PBEffects::Steelsurge])
      target.pbOwnSide.effects[PBEffects::Steelsurge]      = false
      target.pbOpposingSide.effects[PBEffects::Steelsurge] = false if NEWEST_BATTLE_MECHANICS
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
    case @battle.field.terrain
      when PBBattleTerrains::Electric
        @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when PBBattleTerrains::Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when PBBattleTerrains::Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when PBBattleTerrains::Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.pbStartTerrain(user,PBBattleTerrains::None,true)
    case @battle.pbWeather
    when PBWeather::Fog
      @battle.pbDisplay(_INTL("{1} blew away the deep fog!",user.pbThis))
      @weatherType = PBWeather::None
    end
  end
end

#===============================================================================
# G-Max Gravitas.
#===============================================================================
# Increases gravity on the field for 5 rounds.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D013 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::Gravity]==0
      @battle.field.effects[PBEffects::Gravity] = 5
      @battle.pbDisplay(_INTL("Gravity intensified!"))
      @battle.eachBattler do |b|
        showMessage = false
        if b.inTwoTurnAttack?("0C9","0CC","0CE")
          b.effects[PBEffects::TwoTurnAttack] = 0
          @battle.pbClearChoice(b.index) if !b.movedThisRound?
          showMessage = true
        end
        if b.effects[PBEffects::MagnetRise]>0 ||
           b.effects[PBEffects::Telekinesis]>0 ||
           b.effects[PBEffects::SkyDrop]>=0
          b.effects[PBEffects::MagnetRise]  = 0
          b.effects[PBEffects::Telekinesis] = 0
          b.effects[PBEffects::SkyDrop]     = -1
          showMessage = true
        end
        @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!",
           b.pbThis)) if showMessage
      end
    end
  end
end

#===============================================================================
# G-Max Finale.
#===============================================================================
# Heals all ally Pokemon by 1/6th their max HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D014 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.hp == b.totalhp
      next if b.effects[PBEffects::HealBlock]>0
      hpGain = (b.totalhp/6.0).round
      b.pbRecoverHP(hpGain)
    end
  end
end

#===============================================================================
# G-Max Sweetness.
#===============================================================================
# Cures any status conditions of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D015 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      t = b.status
      b.pbCureStatus(false)
      case t
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was healed of its burn!",b.pbThis))  
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poison!",b.pbThis))  
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis!",b.pbThis))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",b.pbThis)) 
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",b.pbThis)) 
      end
    end
  end
end

#===============================================================================
# G-Max Replenish.
#===============================================================================
# User has a 50% chance to recover its last consumed item.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D016 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @battle.pbRandom(10)<5
      item = user.recycleItem
      user.item = item
      user.setInitialItem(item) if @battle.wildBattle? && user.initialItem==0
      user.setRecycleItem(0)
      user.effects[PBEffects::PickupItem] = 0
      user.effects[PBEffects::PickupUse]  = 0
      itemName = PBItems.getName(item)
      if itemName.starts_with_vowel?
        @battle.pbDisplay(_INTL("{1} found an {2}!",user.pbThis,itemName))
      else
        @battle.pbDisplay(_INTL("{1} found a {2}!",user.pbThis,itemName))
      end
      user.pbHeldItemTriggerCheck
    end
  end
end

#===============================================================================
# G-Max Depletion.
#===============================================================================
# The target's last used move loses 2 PP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D017 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.eachMoveWithIndex do |m,i|
        next if m.id!=b.lastRegularMoveUsed || m.pp==0 || m.totalpp<=0
        reduction = [2,m.pp].min
        b.pbSetPP(m,m.pp-reduction)
        b.effects[PBEffects::MaxMovePP][i] +=4 if b.dynamax?
        @battle.pbDisplay(_INTL("{1}'s PP was reduced!",b.pbThis))
        break
      end
    end
  end
end

#===============================================================================
# G-Max Resonance.
#===============================================================================
# Sets up Aurora Veil for the party for 5 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D018 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if user.pbOwnSide.effects[PBEffects::AuroraVeil]==0
      user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
      user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
      @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
         @name,user.pbTeam(true)))
    end
  end
end

#===============================================================================
# G-Max Chi Strike.
#===============================================================================
# Increases the critical hit rate of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D019 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.effects[PBEffects::FocusEnergy] > 2
      b.effects[PBEffects::FocusEnergy] = 2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",b.pbThis))
    end
  end
end

#===============================================================================
# G-Max Terror.
#===============================================================================
# Prevents all opposing Pokemon from switching.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D020 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      next if b.effects[PBEffects::MeanLook] = user.index
      @battle.pbDisplay(_INTL("{1} can no longer escape!",b.pbThis))
      b.effects[PBEffects::MeanLook] = user.index
    end
  end
end

#===============================================================================
# G-Max Snooze.
#===============================================================================
# Has a 50% chance of making the target drowsy.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D021 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::Yawn]==0 && @battle.pbRandom(10)<5
      target.effects[PBEffects::Yawn] = 2
      @battle.pbDisplay(_INTL("{1} made {2} drowsy!",user.pbThis,target.pbThis(true)))
    end
  end
end

#===============================================================================
# G-Max Cuddle.
#===============================================================================
# Infatuates all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D022 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbAttract(user) if b.pbCanAttract?(user)
    end
  end
end

#===============================================================================
# G-Max Meltdown.
#===============================================================================
# Torments all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D023 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      next if b.effects[PBEffects::Torment]
      b.effects[PBEffects::Torment] = true
      @battle.pbDisplay(_INTL("{1} was subjected to torment!",b.pbThis))
      b.pbItemStatusCureCheck
    end
  end
end