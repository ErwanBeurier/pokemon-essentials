#===============================================================================
#
# ZUD_04: Battle Effects
#
#===============================================================================
# This script handles certain ZUD mechanics related to move properties and move
# mechanics when used in battle.
#
#===============================================================================
# SECTION 1 - MOVE PROPERTIES
#-------------------------------------------------------------------------------
# This section handles new properties added to PokeBattle_Move that are required
# for certain ZUD mechanics, such as move flags for Z-Moves and Max Moves.
#===============================================================================
# SECTION 2 - MOVE CONVERSION
#-------------------------------------------------------------------------------
# This section handles how a Pokemon's base moves are converted into Z-Moves or
# Max Moves, as well as situations where one of these moves are converted by an
# effect of a move or ability.
#===============================================================================
# SECTION 3 - MOVE MECHANICS
#-------------------------------------------------------------------------------
# This section handles how certain effects are handled in situations related to
# ZUD mechanics, such as move effects that fail on a Dynamax target, or move 
# effects like Encore failing to prevent Z-Move/Max Move selection.
#===============================================================================
# SECTION 4 - MOVE EFFECTS
#-------------------------------------------------------------------------------
# This section handles the lingering effects of certain Max Moves that trigger
# at the end of each round, or the hazard effect set by G-Max Steelsurge.
#===============================================================================

################################################################################
# SECTION 1 - MOVE PROPERTIES
#===============================================================================
# Adds new move properties for Z-Moves/Max Moves.
#===============================================================================
class PokeBattle_Move
  attr_accessor :name
  attr_accessor :flags
  attr_reader   :short_name       # Used for shortening names of Z-Moves/Max Moves.
  attr_accessor :zmove_sel        # Used when the player triggers a Z-Move.
  attr_reader  (:specialUseZMove) # Used for Z-Move display messages in battle.

  #-----------------------------------------------------------------------------
  # Initializes new properties.
  #-----------------------------------------------------------------------------
  alias _ZUD_initialize initialize
  def initialize(battle,move)
    _ZUD_initialize(battle,move)
    @zmove_sel        = false
    @short_name       = @name
    @specialUseZMove  = false
  end
  
  #-----------------------------------------------------------------------------
  # Checks if a move is flagged as a Z-Move or Max Move, or both.
  #-----------------------------------------------------------------------------
  def maxMove?;   return @flags[/x/];        end
  def zMove?;     return @flags[/z/];        end
  def powerMove?; return zMove? || maxMove?; end
  
  #-----------------------------------------------------------------------------
  # The display messages when using a Z-Move in battle.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbDisplayUseMessage pbDisplayUseMessage
  def pbDisplayUseMessage(user)
    if zMove? && !@specialUseZMove
      @battle.pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",user.pbThis)) if !statusMove?      
      @battle.pbCommonAnimation("ZPower",user,nil)
      PokeBattle_ZMove.pbZStatus(@battle, @id, user) if statusMove?
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",user.pbThis))
    end 
    _ZUD_pbDisplayUseMessage(user)
  end 
end


################################################################################
# SECTION 2 - MOVE CONVERSION
#===============================================================================
# Changes moves into their Z-Move or Max Move equivalents.
#===============================================================================
class PokeBattle_Battler
  
  #=============================================================================
  # Used for converting base moves into Z-Moves/Max Moves.
  #=============================================================================
  def pbDisplayPowerMoves(mode=0)
    #---------------------------------------------------------------------------
    # Set "mode" to 1 to convert to Z-Moves.
    # Set "mode" to 2 to convert to Max Moves.
    #---------------------------------------------------------------------------
    newpoke  = @effects[PBEffects::TransformPokemon]
    pokemon  = @effects[PBEffects::Transform] ? newpoke : self.pokemon
    oldmoves = [@moves[0],@moves[1],@moves[2],@moves[3]]
    @effects[PBEffects::BaseMoves] = oldmoves if !@effects[PBEffects::MaxRaidBoss]
    for i in 0...4
      next if !@moves[i] || @moves[i].id==0
      # Z-Moves
      if mode==1
        comp = pbGetZMoveDataIfCompatible(pokemon,item,@moves[i])
        next if !comp
        @moves[i]         = PokeBattle_ZMove.pbFromOldMoveAndCrystal(@battle,self,@moves[i],item)
        @moves[i].pp      = 1
        @moves[i].totalpp = 1
      # Max Moves
      elsif mode==2
        currentPP         = @moves[i].pp
        totalPP           = @moves[i].totalpp
        @moves[i]         = PokeBattle_MaxMove.pbFromOldMove(@battle,self,@moves[i])
        @moves[i].pp      = currentPP     
        @moves[i].totalpp = totalPP
      end
    end
  end
  
  #=============================================================================
  # Used for reverting Z-Moves/Max Moves into base moves.
  #=============================================================================
  def pbDisplayBaseMoves(mode=0)
    #---------------------------------------------------------------------------
    # Set "mode" to 1 to reduce PP of base move converted into Z-Move.
    # Set "mode" to 2 to reduce PP of base moves converted into Max Moves.
    # "Mode" can be omitted if there is no need to reduce PP.
    #---------------------------------------------------------------------------
    oldmoves    = []
    basemoves   = @pokemon.moves
    storedmoves = @effects[PBEffects::BaseMoves]
    #---------------------------------------------------------------------------
    # Determines base move set to revert to (considers Mimic/Transform).
    #---------------------------------------------------------------------------
    if @effects[PBEffects::MoveMimicked]
      for i in 0...@moves.length
        next if !@moves[i] || @moves[i].id==0
        if basemoves[i]==storedmoves[i]
          oldmoves.push(basemoves[i])
        else
          oldmoves.push(storedmoves[i])
        end
      end
    elsif @effects[PBEffects::Transform]
      oldmoves = storedmoves
    else
      oldmoves = basemoves
    end
    #---------------------------------------------------------------------------
    @moves = [
      PokeBattle_Move.pbFromPBMove(@battle,oldmoves[0]),
      PokeBattle_Move.pbFromPBMove(@battle,oldmoves[1]),
      PokeBattle_Move.pbFromPBMove(@battle,oldmoves[2]),
      PokeBattle_Move.pbFromPBMove(@battle,oldmoves[3])
    ]
    for i in 0...4
      next if !@moves[i] || @moves[i].id == 0
      if @effects[PBEffects::Transform]
        @moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1
        @moves[i].pp -= @effects[PBEffects::MaxMovePP][i] if mode==2
      else
        @pokemon.moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1
        @pokemon.moves[i].pp -= @effects[PBEffects::MaxMovePP][i] if mode==2
      end
    end
    @effects[PBEffects::BaseMoves] = nil if !@effects[PBEffects::MaxRaidBoss]
  end
  
  #=============================================================================
  # Effects that may change a Z-Move/Max Move into one of a different type.
  #=============================================================================  
  def pbChangePowerMove(choice)
    thismove = choice[2]
    basemove = @pokemon.moves[choice[1]]
    newtype  = :ELECTRIC if @effects[PBEffects::Electrify]
    newtype  = :ELECTRIC if @battle.field.effects[PBEffects::IonDeluge] && thismove.type==0
    if thismove.type==0 && thismove.damagingMove?
      #-------------------------------------------------------------------------
      # Abilities that change move type (only applies to Max Moves).
      #-------------------------------------------------------------------------
      newtype = :ICE      if hasActiveAbility?(:REFRIGERATE) && thismove.maxMove?
      newtype = :FAIRY    if hasActiveAbility?(:PIXILATE)    && thismove.maxMove?
      newtype = :FLYING   if hasActiveAbility?(:AERILATE)    && thismove.maxMove?
      newtype = :ELECTRIC if hasActiveAbility?(:GALVANIZE)   && thismove.maxMove?
      #-------------------------------------------------------------------------
      # Weather is in play and base move is Weather Ball.
      #-------------------------------------------------------------------------
      if basemove.id==getID(PBMoves,:WEATHERBALL)
        case @battle.pbWeather
        when PBWeather::Sun, PBWeather::HarshSun;   newtype = :FIRE
        when PBWeather::Rain, PBWeather::HeavyRain; newtype = :WATER
        when PBWeather::Sandstorm;                  newtype = :ROCK
        when PBWeather::Hail;                       newtype = :ICE
        end
      #-------------------------------------------------------------------------
      # Terrain is in play and base move is Terrain Pulse.
      #-------------------------------------------------------------------------
      elsif basemove.id==getID(PBMoves,:TERRAINPULSE)
        case @battle.field.terrain
        when PBBattleTerrains::Electric;            newtype = :ELECTRIC
        when PBBattleTerrains::Grassy;              newtype = :GRASS
        when PBBattleTerrains::Misty;               newtype = :FAIRY
        when PBBattleTerrains::Psychic;             newtype = :PSYCHIC
        end
      #-------------------------------------------------------------------------
      # Base move is Revelation Dance.
      #-------------------------------------------------------------------------
      elsif basemove.id==getID(PBMoves,:REVELATIONDANCE)
        userTypes = pbTypes(true)
        newtype   = userTypes[0]
      #-------------------------------------------------------------------------
      # Base move is Techno Blast and a drive is held by Genesect.
      #-------------------------------------------------------------------------
      elsif basemove.id==getID(PBMoves,:TECHNOBLAST) && isSpecies?(:GENESECT)
        itemtype  = true
        itemTypes = {
           :SHOCKDRIVE => :ELECTRIC,
           :BURNDRIVE  => :FIRE,
           :CHILLDRIVE => :ICE,
           :DOUSEDRIVE => :WATER
        }
      #-------------------------------------------------------------------------
      # Base move is Judgment and user has Multitype and held plate.
      #-------------------------------------------------------------------------
      elsif basemove.id==getID(PBMoves,:JUDGMENT) && hasActiveAbility?(:MULTITYPE)
        itemtype  = true
        itemTypes = {
           :FISTPLATE   => :FIGHTING,
           :SKYPLATE    => :FLYING,
           :TOXICPLATE  => :POISON,
           :EARTHPLATE  => :GROUND,
           :STONEPLATE  => :ROCK,
           :INSECTPLATE => :BUG,
           :SPOOKYPLATE => :GHOST,
           :IRONPLATE   => :STEEL,
           :FLAMEPLATE  => :FIRE,
           :SPLASHPLATE => :WATER,
           :MEADOWPLATE => :GRASS,
           :ZAPPLATE    => :ELECTRIC,
           :MINDPLATE   => :PSYCHIC,
           :ICICLEPLATE => :ICE,
           :DRACOPLATE  => :DRAGON,
           :DREADPLATE  => :DARK,
           :PIXIEPLATE  => :FAIRY
        }
      #-------------------------------------------------------------------------
      # Base move is Multi-Attack and user has RKS System and held memory.
      #-------------------------------------------------------------------------
      elsif basemove.id==getID(PBMoves,:MULTIATTACK) && hasActiveAbility?(:RKSSYSTEM)
        itemtype  = true
        itemTypes = {
           :FIGHTINGMEMORY => :FIGHTING,
           :SLYINGMEMORY   => :FLYING,
           :POISONMEMORY   => :POISON,
           :GROUNDMEMORY   => :GROUND,
           :ROCKMEMORY     => :ROCK,
           :BUGMEMORY      => :BUG,
           :GHOSTMEMORY    => :GHOST,
           :STEELMEMORY    => :STEEL,
           :FIREMEMORY     => :FIRE,
           :WATERMEMORY    => :WATER,
           :GRASSMEMORY    => :GRASS,
           :ELECTRICMEMORY => :ELECTRIC,
           :PSYCHICMEMORY  => :PSYCHIC,
           :ICEMEMORY      => :ICE,
           :DRAGONMEMORY   => :DRAGON,
           :DARKMEMORY     => :DARK,
           :FAIRYMEMORY    => :FAIRY
        }
      end
      if itemActive? && itemtype
        itemTypes.each do |item, itemType|
          next if !hasActiveItem?(item)
          newtype = itemType
          break
        end
      end
    end
    if newtype
      newtype = getID(PBTypes,newtype)
      oldMove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(basemove.id))
      #-------------------------------------------------------------------------
      # Z-Moves - Converts to a new Z-Move of a given type.
      #-------------------------------------------------------------------------
      if thismove.zMove?
        crystal = [:NORMALIUMZ,:EEVIUMZ,:SNORLIUMZ]
        for i in crystal; newZMove = true if hasActiveItem?(i); end
        if newZMove || @effects[PBEffects::Electrify]
          zMove   = pbZMoveFromType(newtype)
          newMove = PBMove.new(zMove)
          newMove = PokeBattle_ZMove.new(@battle,oldMove,newMove)
          return newMove
        end
      end
      #-------------------------------------------------------------------------
      # Max Moves - Converts to a new Max Move of a given type.
      #-------------------------------------------------------------------------
      if thismove.maxMove?
        gmaxmove = pbGetGMaxMoveFromSpecies(@pokemon,newtype)
        maxMove  = (gmaxmove && gmaxFactor?) ? gmaxmove : pbGetMaxMove(newtype)
        newMove  = (thismove.statusMove?) ? PBMove.new(:MAXGUARD) : PBMove.new(maxMove)
        newMove  = PokeBattle_MaxMove.pbFromOldMove(@battle,oldMove,newMove)
        return newMove
      end
    end
  end
  
  #=============================================================================
  # Handles the actual use of Z-Moves, and converts to base moves when done.
  #=============================================================================
  def pbUseMoveSimple(moveID,target=-1,idxMove=-1,specialUsage=true)
    choice = []
    choice[0] = :UseMove
    choice[1] = idxMove
    if idxMove>=0
      choice[2] = @moves[idxMove]
    else
      choice[2] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveID))
      choice[2].pp = -1
    end
    choice[3] = target
    PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
    side=(@battle.opposes?(self.index)) ? 1 : 0
    owner=@battle.pbGetOwnerIndexFromBattlerIndex(self.index)
    #---------------------------------------------------------------------------
    # Z-Moves
    #---------------------------------------------------------------------------
    if @battle.zMove[side][owner]==self.index
      crystal = pbZCrystalFromType(choice[2].type)
      the_zmove = PokeBattle_ZMove.pbFromOldMoveAndCrystal(@battle,self,choice[2],crystal)
      the_zmove.pbUse(self,choice,specialUsage)
    else
      pbUseMove(choice,specialUsage)
    end
    #---------------------------------------------------------------------------
  end
  
  def pbProcessTurn(choice,tryFlee=true)
    return false if fainted?
    if tryFlee && @battle.wildBattle? && opposes? &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
      pbBeginTurn(choice)
      @battle.pbDisplay(_INTL("{1} fled from battle!",pbThis)) { pbSEPlay("Battle flee") }
      @battle.decision = 3
      pbEndTurn(choice)
      return true
    end
    if choice[0]==:Shift
      idxOther = -1
      case @battle.pbSideSize(@index)
      when 2
        idxOther = (@index+2)%4
      when 3
        if @index!=2 && @index!=3
          idxOther = ((@index%2)==0) ? 2 : 3
        end
      end
      if idxOther>=0
        @battle.pbSwapBattlers(@index,idxOther)
        case @battle.pbSideSize(@index)
        when 2
          @battle.pbDisplay(_INTL("{1} moved across!",pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1} moved to the center!",pbThis))
        end
      end
      pbBeginTurn(choice)
      pbCancelMoves
      @lastRoundMoved = @battle.turnCount
      return true
    end
    if choice[0]!=:UseMove
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit] = false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge
      return false
    end
    #---------------------------------------------------------------------------
    # Z-Moves
    #---------------------------------------------------------------------------
    if choice[2].zmove_sel
      choice[2].zmove_sel = false
      @battle.pbUseZMove(self.index,choice[2],self.item)
      pbDisplayBaseMoves(1)
    else
      PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
      PBDebug.logonerr{
        pbUseMove(choice,choice[2]==@battle.struggle)
      }
    end
    #---------------------------------------------------------------------------
    @battle.pbJudge
    return true
  end
  
  
################################################################################
# SECTION 3 - MOVE MECHANICS
#===============================================================================
# Mechanics for certain effects when utilized with Z-Moves/Dynamax.
#===============================================================================
  alias _ZUD_pbCanChooseMove? pbCanChooseMove?
  def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
    if move.zMove?
      #=========================================================================
      # Prevents Z-Moves from being affected by the following effects:
      # Disable, Heal Block, Imprison, Throat Chop, Taunt, Torment.
      # If something actually blocks Z-moves, write this code here:
      #=========================================================================
      # ENTER HERE
      #-------------------------------------------------------------------------
      # Gravity
      if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
        if showMessages
          msg = _INTL("{1} can't use {2} because of gravity!",pbThis,move.name)
          (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
        end
        return false
      end
      return true 
    end 
    return _ZUD_pbCanChooseMove?(move,commandPhase,showMessages,specialUsage)
  end
  
  #=============================================================================
  # Flinch
  #=============================================================================
  # Dynamax Pokemon are immune to flinching.
  #-----------------------------------------------------------------------------
  def pbFlinch(user=nil)
    return if (hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker)
    return if @effects[PBEffects::Dynamax]>0
    @effects[PBEffects::Flinch] = true
  end
  
  #=============================================================================
  # Destiny Bond
  #=============================================================================
  # Effect is negated on Dynamax Pokemon.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbEffectsOnMakingHit pbEffectsOnMakingHit
  def pbEffectsOnMakingHit(move,user,target)
    _ZUD_pbEffectsOnMakingHit(move,user,target)
    if target.opposes?(user) && user.dynamax?
      user.effects[PBEffects::DestinyBondTarget] = -1
    end
  end
  
  #=============================================================================
  # Transform
  #=============================================================================
  # -Stores base moves of the Transform target as user's new base moves.
  # -Stores the Pokemon data of the Transform target.
  # -Copies the base moves of a Dynamaxed Transform target.
  # -Gets the correct Max Moves if the user is Dynamaxed prior to transforming.
  #-----------------------------------------------------------------------------
  def pbTransform(target)
    oldAbil = @ability
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    @effects[PBEffects::TransformPokemon] = target.pokemon # Stores the entire PokeBattle_Pokemon
    pbChangeTypes(target)
    @ability = target.ability
    @attack  = target.attack
    @defense = target.defense
    @spatk   = target.spatk
    @spdef   = target.spdef
    @speed   = target.speed
    PBStats.eachBattleStat { |s| @stages[s] = target.stages[s] }
    if NEWEST_BATTLE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m,i|
      if target.dynamax?
        basemove  = target.effects[PBEffects::BaseMoves][i].id
        @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(basemove))
      else
        @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(m.id))
      end
      @moves[i].pp      = 5
      @moves[i].totalpp = 5
    end 
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = 0
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    @effects[PBEffects::BaseMoves]    = target.effects[PBEffects::BaseMoves]
    pbDisplayPowerMoves(2) if @pokemon.dynamax? # Converts new moves to Max Moves if Dynamaxed.
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,target.pbThis(true)))
    pbOnAbilityChanged(oldAbil)
  end
  
  #=============================================================================
  # Encore/Copycat 
  #=============================================================================
  # Records if last used move was a Z-Move to prevent the move being copied.
  #-----------------------------------------------------------------------------
  attr_accessor :lastMoveUsedIsZMove
  
  alias _ZUD_pbUseMove pbUseMove
  def pbUseMove(choice, specialUsage=false)
    @lastMoveUsedIsZMove = false 
    _ZUD_pbUseMove(choice, specialUsage)
  end 
  
  alias _ZUD_pbTryUseMove pbTryUseMove 
  def pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
    ret = _ZUD_pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
    if !ret && move.zMove?
      @battle.lastMoveUsed = -2 
    end 
    return ret 
  end
  
  def pbEndTurn(_choice)
    if _choice[0] == :UseMove
      if _choice[2].zMove?
        if @battle.lastMoveUsed == -2
          @battle.pbUnregisterZMove(self.index)
          self.pbDisplayBaseMoves(1)
          self.effects[PBEffects::PowerMovesButton] = false
        else 
          side  = self.idxOwnSide
          owner = @battle.pbGetOwnerIndexFromBattlerIndex(self.index)
          @battle.zMove[side][owner] = -2
        end 
        @battle.lastMoveUsed = -1
      end
    end
    #===========================================================================
    # Choice Items/Gorilla Tactics
    #===========================================================================
    # Move options aren't locked while the user is Dynamaxed.
    #---------------------------------------------------------------------------
    @lastRoundMoved = @battle.turnCount
    if @effects[PBEffects::Dynamax]<=0
      # Choice Items
      if @effects[PBEffects::ChoiceBand]<0 &&
         hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
        if @lastMoveUsed>=0 && pbHasMove?(@lastMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastMoveUsed
        elsif @lastRegularMoveUsed>=0 && pbHasMove?(@lastRegularMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
        end
      end
      # Gorilla Tactics
      if @effects[PBEffects::GorillaTactics]<0 && 
         hasActiveAbility?(:GORILLATACTICS)
        if @lastMoveUsed>=0 && pbHasMove?(@lastMoveUsed) 
          @effects[PBEffects::GorillaTactics] = @lastMoveUsed
        elsif @lastRegularMoveUsed>=0 && pbHasMove?(@lastRegularMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
        end
      end
    else
      @effects[PBEffects::ChoiceBand]     = -1
      @effects[PBEffects::GorillaTactics] = -1
    end
    @effects[PBEffects::Charge]      = 0 if @effects[PBEffects::Charge]==1
    @effects[PBEffects::GemConsumed] = 0
    @battle.eachBattler { |b| b.pbContinualAbilityChecks }
  end
  
  #=============================================================================
  # Dynamax Immunities
  #=============================================================================
  # Prevents Dynamax targets from being affected by various moves.
  # Must be added to def pbSuccessCheckAgainstTarget.
  #-----------------------------------------------------------------------------
  def pbSuccessCheckDynamax(move,user,target)
    #---------------------------------------------------------------------------
    # Dynamax Pokemon are immune to specified moves.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::Dynamax]>0
      if move.function=="066" || # Entrainment
         move.function=="067" || # Skill Swap
         move.function=="070" || # OHKO moves
         move.function=="09A" || # Weight-based moves
         move.function=="0B7" || # Torment
         move.function=="0B9" || # Disable
         move.function=="0BC" || # Encore
         move.function=="0E7" || # Destiny Bond
         move.function=="0EB" || # Roar/Whirlwind
         move.function=="16B"    # Instruct
        @battle.pbDisplay(_INTL("But it failed!"))
        ret = false
      end
    end
    raidsuccess = pbSuccessCheckMaxRaid(move,user,target)
    ret = false if raidsuccess==false
    #---------------------------------------------------------------------------
    # Max Guard blocks all moves except specified moves.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::MaxGuard]
      if isConst?(move.id,PBMoves,:MEANLOOK) ||
         isConst?(move.id,PBMoves,:ROLEPLAY) ||
         isConst?(move.id,PBMoves,:PERISHSONG) ||
         isConst?(move.id,PBMoves,:DECORATE) ||
         # Feint damages, but doesn't remove Max Guard.
         isConst?(move.id,PBMoves,:FEINT) || 
         isConst?(move.id,PBMoves,:GMAXONEBLOW) ||
         isConst?(move.id,PBMoves,:GMAXRAPIDFLOW)
        ret = true
      else
        @battle.pbCommonAnimation("Protect",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        pbRaidShieldBreak(move,target)
        ret = false
      end
    end
    return ret
  end
end


################################################################################
# SECTION 4 - MOVE EFFECTS
#===============================================================================
# Handles the end of round effects of certain G-Max Moves.
# Must be added to def pbEndOfRoundPhase.
#===============================================================================
class PokeBattle_Battle
  def pbEORMaxMoveEffects(priority)
    priority.each do |b|
      b.effects[PBEffects::MaxGuard] = false
    end
    for side in 0...2
      #-------------------------------------------------------------------------
      # G-Max Vine Lash
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::VineLash]>0
      	#@battle.pbCommonAnimation("VineLash") if side==0
      	#@battle.pbCommonAnimation("VineLashOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:GRASS)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Vine Lash's ferocious beating!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::VineLash,
          _INTL("{1} was released from G-Max Vinelash's beating!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Wildfire
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Wildfire]>0
      	#@battle.pbCommonAnimation("Wildfire") if side==0
      	#@battle.pbCommonAnimation("WildfireOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is burning up within G-Max Wildfire's flames!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Wildfire,
          _INTL("{1} was released from G-Max Wildfire's flames!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Cannonade
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Cannonade]>0
      	#@battle.pbCommonAnimation("Cannonade") if side==0
      	#@battle.pbCommonAnimation("CannonadeOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:WATER)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Cannonade's vortex!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Cannonade,
          _INTL("{1} was released from G-Max Cannonade's vortex!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Volcalith
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Volcalith]>0
      	#@battle.pbCommonAnimation("Volcalith") if side==0
      	#@battle.pbCommonAnimation("VolcalithOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:ROCK)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by the rocks thrown out by G-Max Volcalith!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Volcalith,
          _INTL("Rocks stopped being thrown out by G-Max Volcalith on {1}!",@battlers[side].pbTeam(true)))
      end
    end
  end
  
#===============================================================================
# Hazard effect for G-Max Steelsurge.
#===============================================================================
  def pbSteelsurgeEffect(battler) # Added to def pbOnActiveOne
    if battler.pbOwnSide.effects[PBEffects::Steelsurge] && battler.takesIndirectDamage?
      aType = getConst(PBTypes,:STEEL) || 0
      bTypes = battler.pbTypes(true)
      eff = PBTypes.getCombinedEffectiveness(aType,bTypes[0],bTypes[1],bTypes[2])
      if !PBTypes.ineffective?(eff)
        eff = eff.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("The sharp steel bit into {1}!",battler.pbThis(true)))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)
          return pbOnActiveOne(battler) 
        end
      end
    end
  end
end 
