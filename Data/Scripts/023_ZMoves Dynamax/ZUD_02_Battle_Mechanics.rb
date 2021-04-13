#===============================================================================
#
# ZUD_02: Battle Mechanics
#
#===============================================================================
# This script implements the core battle mechanics used by all ZUD functions.
# New battler effects, eligibility checks for each battle mechanic, and AI
# functionality with each mechanic is found here.
#
#===============================================================================
# SECTION 1 - BATTLER EFFECTS
#-------------------------------------------------------------------------------
# This section handles all of the new effects required for ZUD functionality,
# and initializes them on each battler in combat.
#===============================================================================
# SECTION 2 - BATTLER CALLS
#-------------------------------------------------------------------------------
# This section handles methods that check for eligibility with each ZUD mechanic
# on a Pokemon, as well as functions to un-Dynamax a Pokemon.
#===============================================================================
# SECTION 3 - BATTLE FUNCTIONS
#-------------------------------------------------------------------------------
# This section initializes ZUD mechanics in battle, and handles methods that 
# check if a mechanic has been registered for use, when they can be used, and
# what effects take place when they are used.
#===============================================================================
# SECTION 4 - AI BATTLERS
#-------------------------------------------------------------------------------
# This section handles AI functions to determine if and when an NPC trainer
# should utilize a ZUD mechanic.
#===============================================================================

################################################################################
# SECTION 1 - BATTLER EFFECTS
#===============================================================================
# New effects used for Z-Moves and Dynamax.
#===============================================================================
module PBEffects
  #-----------------------------------------------------------------------------
  # Battler effects used for compatibility with existing moves.
  #-----------------------------------------------------------------------------
  MoveMimicked     = 200  # Used for compatibility with the move Mimic.
  TransformPokemon = 201  # Used for compatibility with the move Transform.
  #-----------------------------------------------------------------------------
  # Battler effects used for Z-Move and Dynamax mechanics.
  #-----------------------------------------------------------------------------
  BaseMoves        = 202  # Records a Pokemon's base moves to revert to after Z-Moves/Dynamax.
  PowerMovesButton = 203  # Effect used for toggling between base moves and power moves.
  UsedZMoveIndex   = 204  # Records the index of the used Z-move.  
  Dynamax          = 205  # The Dynamax state.
  NonGMaxForm      = 206  # Records a G-Max Pokemon's base form to revert to (used for Alcremie).
  MaxMovePP        = 207  # Records the PP usage of Max Moves while Dynamaxed.
  MaxGuard         = 208  # The effect for the move Max Guard.
  ChiStrike        = 209  # The crit-boosting effect of G-Max Chi Strike.
  MaxRaidBoss      = 210  # The effect that designates a Max Raid Pokemon. Set here for compatibility.
  
  #-----------------------------------------------------------------------------
  # Effects that apply to a side.
  #-----------------------------------------------------------------------------
  ZHeal            = 100  # The healing effect of Z-Parting Shot/Z-Memento.
  VineLash         = 101  # The lingering effect of G-Max Vine Lash.
  Wildfire         = 102  # The lingering effect of G-Max Wildfire.
  Cannonade        = 103  # The lingering effect of G-Max Cannonade.
  Volcalith        = 104  # The lingering effect of G-Max Volcalith.
  Steelsurge       = 105  # The hazard effect of G-Max Steelsurge.
end

#===============================================================================
# Initializes new Pokemon effects in battle.
#===============================================================================
class PokeBattle_Battler
  alias _ZUD_pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    _ZUD_pbInitEffects(batonpass)
    @effects[PBEffects::MoveMimicked]     = false
    @effects[PBEffects::TransformPokemon] = nil
    @effects[PBEffects::BaseMoves]        = nil
    @effects[PBEffects::PowerMovesButton] = false
    @effects[PBEffects::UsedZMoveIndex]   = -1
    @effects[PBEffects::Dynamax]          = 0
    @effects[PBEffects::NonGMaxForm]      = nil
    @effects[PBEffects::MaxMovePP]        = [0,0,0,0]
    @effects[PBEffects::MaxGuard]         = false
    @effects[PBEffects::ChiStrike]        = 0
    @lastMoveUsedIsZMove                  = false
  end
end

#===============================================================================
# Initializes new field effects in battle.
#===============================================================================
class PokeBattle_ActiveSide
  alias _ZUD_initialize initialize  
  def initialize
    _ZUD_initialize
    @effects[PBEffects::ZHeal]      = false
    @effects[PBEffects::VineLash]   = 0
    @effects[PBEffects::Wildfire]   = 0
    @effects[PBEffects::Cannonade]  = 0
    @effects[PBEffects::Volcalith]  = 0
    @effects[PBEffects::Steelsurge] = false
  end
end


################################################################################
# SECTION 2 - BATTLER CALLS
#===============================================================================
# Various battler calls used for Z-Moves, Ultra Burst, and Dynamax.
#-------------------------------------------------------------------------------
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  # Placeholder for Max Raid compatibility.
  #-----------------------------------------------------------------------------
  def pbRaidBossUseMove(choice); end
  def pbRaidShieldBreak(move,target); end
  def pbSuccessCheckMaxRaid(move,user,target); return true; end
    
  #-----------------------------------------------------------------------------
  # Checks if the battler is in one of these modes.
  #-----------------------------------------------------------------------------
  def ultra?;       return @pokemon && @pokemon.ultra?;       end
  def dynamax?;     return @pokemon && @pokemon.dynamax?;     end
  def gmax?;        return @pokemon && @pokemon.gmax?;        end
    
  #-----------------------------------------------------------------------------
  # Checks various Dynamax conditions.
  #-----------------------------------------------------------------------------
  def dynamaxAble?; return @pokemon && @pokemon.dynamaxAble?; end
  def dynamaxBoost; return @pokemon && @pokemon.dynamaxBoost; end
  def gmaxFactor?;  return @pokemon && @pokemon.gmaxFactor?;  end
    
  #-----------------------------------------------------------------------------
  # Gets the non-Dynamax HP of a Pokemon.
  #-----------------------------------------------------------------------------
  def realhp;       return @pokemon && @pokemon.realhp;       end
  def realtotalhp;  return @pokemon && @pokemon.realtotalhp;  end
  
  #-----------------------------------------------------------------------------
  # Checks for Z-Move compatibility from inputted move.
  #-----------------------------------------------------------------------------
  def pbCompatibleZMoveFromMove?(move)
    return true if move.is_a?(PokeBattle_ZMove)
    transform = @effects[PBEffects::Transform]
    newpoke   = @effects[PBEffects::TransformPokemon] 
    pokemon   = transform ? newpoke : self.pokemon
    return false if transform && pokemon.ultra? && hasActiveItem?(:ULTRANECROZIUMZ)
    zmovedata = pbGetZMoveDataIfCompatible(pokemon,self.item,move)
    return zmovedata != nil 
  end
  
  def pbCompatibleZMoveFromIndex?(moveindex)
    return pbCompatibleZMoveFromMove?(self.moves[moveindex])
  end
    
  #-----------------------------------------------------------------------------
  # Checks if the battler is capable of using any of the following mechanics.
  #-----------------------------------------------------------------------------
  def hasZMove?
    return false if shadowPokemon?
    return false if primal? || hasPrimal?
    return pbCompatibleZMoveFromMove?(nil)
  end
  
  def hasUltra?
    return false if @effects[PBEffects::Transform]
    return false if shadowPokemon?
    return false if mega?   || hasMega?
    return false if primal? || hasPrimal? 
    return @pokemon && pokemon.hasUltra?
  end
  
  def hasDynamax?
    transform = @effects[PBEffects::Transform] || @effects[PBEffects::Illusion]
    newpoke   = @effects[PBEffects::TransformPokemon] if @effects[PBEffects::Transform]
    newpoke   = @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]
    pokemon   = transform ? newpoke : @pokemon
    powerspot  = $game_map && POWERSPOTS.include?($game_map.map_id)
    eternaspot = $game_map && ETERNASPOT.include?($game_map.map_id)
    return true if isSpecies?(:ETERNATUS) && eternaspot && !transform
    return false if !pokemon.dynamaxAble?
    return false if !powerspot && !DMAX_ANYMAP
    return false if shadowPokemon?
    return false if pbIsZCrystal?(self.item) || hasZMove?
    return false if pokemon.mega?   || hasMega?
    return false if pokemon.primal? || hasPrimal?
    return false if pokemon.ultra?  || hasUltra?
    return false if canCallAssistance?
    return true
  end
  
  def hasGmax?
    return false if !hasDynamax?
    return @pokemon && @pokemon.hasGmax?
  end
  
  #-----------------------------------------------------------------------------
  # Reverts the effects of Dynamax.
  #-----------------------------------------------------------------------------
  def pbUndynamax
    text = "Dynamax"
    text = "Gigantamax" if gmax?
    text = "Eternamax"  if isConst?(species,PBSpecies,:ETERNATUS)
    @battle.pbCommonAnimation("UnDynamax",self)
    @pokemon.makeUndynamax
    pbUpdate(false)
    @pokemon.pbReversion(false)
    if !@effects[PBEffects::MaxRaidBoss]
      pbDisplayBaseMoves(2)
      @effects[PBEffects::Dynamax]          = 0
      @effects[PBEffects::MaxMovePP]        = [0,0,0,0]
      @effects[PBEffects::PowerMovesButton] = false
      self.form = @effects[PBEffects::NonGMaxForm] if self.isSpecies?(:ALCREMIE)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.scene.pbHPChanged(self,totalhp) if !fainted?
      @battle.pbDisplay(_INTL("{1}'s {2} energy left its body!",pbThis,text))
      @battle.scene.pbRefresh
    end
  end
  alias unmax pbUndynamax
  
  def pbFaint(showMessage=true)
    #---------------------------------------------------------------------------
    # Initiates capture sequence on Raid Boss when KO'd.
    #---------------------------------------------------------------------------
    if defined?(MAXRAID_SWITCH) && $game_switches[MAXRAID_SWITCH] && @effects[PBEffects::MaxRaidBoss]
      self.hp += 1
      pbCatchRaidPokemon(self)
    else
    #---------------------------------------------------------------------------
      if !fainted?
        PBDebug.log("!!!***Can't faint with HP greater than 0")
        return
      end
      return if @fainted
      @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
      PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
      @battle.scene.pbFaintBattler(self)
      pbInitEffects(false)
      self.status      = PBStatuses::NONE
      self.statusCount = 0
      if @pokemon && @battle.internalBattle
        badLoss = false
        @battle.eachOtherSideBattler(@index) do |b|
          badLoss = true if b.level>=self.level+30
        end
        @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
      end
      @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
      @pokemon.makeUnmega   if mega?
      @pokemon.makeUnprimal if primal?
      #-------------------------------------------------------------------------
      @pokemon.makeUnUltra  if ultra?    # Reverts Ultra Burst upon fainting.
      @pokemon.unmax        if dynamax?  # Reverts Dynamax upon fainting.
      #-------------------------------------------------------------------------
      @pokemon.yamaskhp = 0 # Yamask
      @battle.pbClearChoice(@index)
      pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
      pbAbilitiesOnFainting
      @battle.pbEndPrimordialWeather
      #-------------------------------------------------------------------------
      # Reduces the KO counter in Max Raid battles if your Pokemon are KO'd.
      #-------------------------------------------------------------------------
      if defined?(MAXRAID_SWITCH) && $game_switches[MAXRAID_SWITCH]
        pbRaidKOCounter(self.pbDirectOpposing)
      end
      #-------------------------------------------------------------------------
    end
  end
end

# Safari Zone compatibility
class PokeBattle_FakeBattler
  def dynamax?; return false; end
end  

################################################################################
# SECTION 3 - BATTLE FUNCTIONS
#===============================================================================
# Triggering and using each mechanic during battle.
#===============================================================================
class PokeBattle_Battle
  attr_accessor :zMove
  attr_accessor :ultraBurst
  attr_accessor :dynamax

  #-----------------------------------------------------------------------------
  # Initializes each battle mechanic.
  #-----------------------------------------------------------------------------
  alias _ZUD_initialize initialize
  def initialize(scene,p1,p2,player,opponent)
    _ZUD_initialize(scene,p1,p2,player,opponent)
    @zMove             = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @ultraBurst        = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @dynamax         = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
  end
  
  #-----------------------------------------------------------------------------
  # Placeholder for Max Raid compatibility.
  #-----------------------------------------------------------------------------
  def pbRaidUpdate(boss); end
  def pbAttackPhaseCheer; end
  def pbAttackPhaseRaidBoss; end
  
  #-----------------------------------------------------------------------------
  # Checks for items required to utilize certain battle mechanics.
  #-----------------------------------------------------------------------------
  def pbHasZRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)
    Z_RINGS.each do |item|
      return true if hasConst?(PBItems,item) && $PokemonBag.pbHasItem?(item)
    end
    return false
  end
  
  def pbHasDynamaxBand?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)
    DMAX_BANDS.each do |item|
      return true if hasConst?(PBItems,item) && $PokemonBag.pbHasItem?(item)
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Eligibility checks.
  #-----------------------------------------------------------------------------
  def pbCanZMove?(idxBattler)
    battler = @battlers[idxBattler]
    side    = battler.idxOwnSide
    owner   = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_Z_MOVE]                # No Z-Moves if switch enabled.
    return false if !battler.hasZMove?                       # No Z-Moves if ineligible.
    return false if battler.hasUltra?                        # No Z-Moves if Ultra Burst is available first.
    return false if wildBattle? && opposes?(idxBattler)      # No Z-Moves for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Z-Moves with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0   # No Z-Moves if in Sky Drop.
    return false if @zMove[side][owner]!=-1                  # No Z-Moves if used this battle.
    return false if !pbHasZRing?(idxBattler)                 # No Z-Moves if no Z-Ring.
    return @zMove[side][owner]==-1
  end
  
  def pbCanUltraBurst?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_ULTRA_BURST]           # No Ultra Burst if switch enabled.
    return false if !battler.hasUltra?                       # No Ultra Burst if ineligible.
    return false if wildBattle? && opposes?(idxBattler)      # No Ultra Burst for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Ultra Burst with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0   # No Ultra Burst if in Sky Drop.
    return false if @ultraBurst[side][owner]!=-1             # No Ultra Burst if used this battle.
    return false if !pbHasZRing?(idxBattler)                 # No Ultra Burst if no Z-Ring.
    return @ultraBurst[side][owner]==-1
  end
  
  def pbCanDynamax?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_DYNAMAX]                # No Dynamax if switch enabled.
    return false if !battler.hasDynamax?                      # No Dynamax if ineligible.
    return false if wildBattle? && opposes?(idxBattler)       # No Dynamax for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)        # Allows Dynamax with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0    # No Dynamax if in Sky Drop.
    return false if @dynamax[side][owner]!=-1                 # No Dynamax if used this battle.
    return false if wildBattle? && !CAN_DMAX_WILD && 
                   !$game_switches[MAXRAID_SWITCH]            # No Dynamax in normal wild battles, unless enabled.
    return false if !pbHasDynamaxBand?(idxBattler)            # No Dynamax if no Dynamax Band.
    return @dynamax[side][owner]==-1
  end
  
  # Returns true if any battle mechanic is available to the user.
  def pbCanUseBattleMechanic?(idxBattler)
    return true if pbCanMegaEvolve?(idxBattler) ||
                   pbCanZMove?(idxBattler) ||
                   pbCanUltraBurst?(idxBattler) ||
                   pbCanDynamax?(idxBattler)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Uses the eligible battle mechanic.
  #-----------------------------------------------------------------------------
  def pbUseZMove(idxBattler,move,crystal)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasZMove?
    the_zmove = PokeBattle_ZMove.pbFromOldMoveAndCrystal(self,battler,move,crystal)
    the_zmove.pbUse(battler, nil, false)
  end
  
  def pbUltraBurst(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasUltra? || battler.ultra?
    pbDisplay(_INTL("Bright light is about to burst out of {1}!",battler.pbThis(true)))    
    pbCommonAnimation("UltraBurst",battler)
    battler.pokemon.makeUltra
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("UltraBurst2",battler)
    ultraname = battler.pokemon.ultraName
    if !ultraname || ultraname==""
      ultraname = _INTL("Ultra {1}",PBSpecies.getName(battler.pokemon.species))
    end
    pbDisplay(_INTL("{1} regained its true power with Ultra Burst!",battler.pbThis))    
    PBDebug.log("[Ultra Burst] #{battler.pbThis} became #{ultraname}")
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = -2
  end
  
  def pbDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasDynamax? || battler.dynamax?
    return if @move.id==@struggle.id
    #---------------------------------------------------------------------------
    # Compatibility for Mid Battle Dialogue - Prior to Dynamaxing.
    #---------------------------------------------------------------------------
    if defined?(DialogueModule)
      if !battler.opposes?
        TrainerDialogue.display("dynamaxBefore",self,@scene)
        TrainerDialogue.display("gmaxBefore",self,@scene) if battler.gmaxFactor?
      else
        TrainerDialogue.display("dynamaxBeforeOpp",self,@scene)
        TrainerDialogue.display("gmaxBeforeOpp",self,@scene) if battler.gmaxFactor?
      end
    end
    #---------------------------------------------------------------------------
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} recalled {2}!",trainerName,battler.pbThis(true)))
    battler.effects[PBEffects::Dynamax]     = DYNAMAX_TURNS
    if isDynAdventure?
      dyn = pbGetDynAdventure.currentRoom.dynamax_turns rescue nil 
      battler.effects[PBEffects::Dynamax]   = dyn if dyn
    end 
    battler.effects[PBEffects::NonGMaxForm] = battler.form
    battler.effects[PBEffects::Encore]      = 0
    battler.effects[PBEffects::Disable]     = 0
    battler.effects[PBEffects::Substitute]  = 0
    battler.effects[PBEffects::Torment]     = false
    @scene.pbRecall(idxBattler)
    # Alcremie reverts to form 0 only for the duration of Gigantamax.
    battler.pokemon.form = 0 if battler.isSpecies?(:ALCREMIE) && battler.gmaxFactor?
    battler.pokemon.form = 0 if battler.isSpecies?(:CRAMORANT)
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
      @scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back,battler)
    end
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -2
    oldhp = battler.hp
    battler.pbUpdate(false)
    @scene.pbHPChanged(battler,oldhp)
    battler.pokemon.pbReversion(true)
    #---------------------------------------------------------------------------
    # Compatibility for Mid Battle Dialogue - After Dynamaxing.
    #---------------------------------------------------------------------------
    if defined?(DialogueModule)
      if !battler.opposes?
        TrainerDialogue.display("dynamaxAfter",self,@scene)
        TrainerDialogue.display("gmaxAfter",self,@scene) if battler.gmaxFactor?
      else
        TrainerDialogue.display("dynamaxAfterOpp",self,@scene)
        TrainerDialogue.display("gmaxAfterOpp",self,@scene) if battler.gmaxFactor?
      end
    end
    #---------------------------------------------------------------------------
  end
  
  #-----------------------------------------------------------------------------
  # Registering Z-Moves.
  #-----------------------------------------------------------------------------
  def pbRegisterZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @zMove[side][owner] = idxBattler
  end
  
  def pbUnregisterZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @zMove[side][owner] = -1 if @zMove[side][owner]==idxBattler
  end

  def pbToggleRegisteredZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @zMove[side][owner]==idxBattler
      @zMove[side][owner] = -1
    else
      @zMove[side][owner] = idxBattler
    end
  end
  
  def pbRegisteredZMove?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @zMove[side][owner]==idxBattler
  end
  
  #-----------------------------------------------------------------------------
  # Registering Ultra Burst.
  #-----------------------------------------------------------------------------
  def pbRegisterUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = idxBattler
  end
  
  def pbUnregisterUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = -1 if @ultraBurst[side][owner]==idxBattler
  end

  def pbToggleRegisteredUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @ultraBurst[side][owner]==idxBattler
      @ultraBurst[side][owner] = -1
    else
      @ultraBurst[side][owner] = idxBattler
    end
  end
  
  def pbRegisteredUltraBurst?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @ultraBurst[side][owner]==idxBattler
  end

  #-----------------------------------------------------------------------------
  # Registering Dynamax
  #-----------------------------------------------------------------------------
  def pbRegisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = idxBattler
  end

  def pbUnregisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -1 if @dynamax[side][owner]==idxBattler
  end

  def pbToggleRegisteredDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @dynamax[side][owner]==idxBattler
      @dynamax[side][owner] = -1
    else
      @dynamax[side][owner] = idxBattler
    end
  end

  def pbRegisteredDynamax?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @dynamax[side][owner]==idxBattler
  end
  
  #-----------------------------------------------------------------------------
  # Triggers the use of each battle mechanic during the attack phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhaseZMoves
    pbPriority.each do |b|
      idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @zMove[b.idxOwnSide][owner]!=b.index
      @choices[b.index][2].zmove_sel = true
    end
  end
  
  def pbAttackPhaseUltraBurst
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @ultraBurst[b.idxOwnSide][owner]!= b.index
      pbUltraBurst(b.index)
    end
  end
  
  def pbAttackPhaseDynamax
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @dynamax[b.idxOwnSide][owner]!= b.index
      pbDynamax(b.index)
    end
  end
    
#===============================================================================
# Reverting the effects of Dynamax.
#===============================================================================
# Counts down Dynamax turns and reverts the user once it expires.
# Must be added to def pbEndOfRoundPhase.
#-------------------------------------------------------------------------------
  def pbDynamaxTimer
    eachBattler do |b|
      next if b.effects[PBEffects::Dynamax]<=0
      # Converts any newly-learned moves into Max Moves while Dynamaxed.
      for m in 0...b.moves.length
        next if b.moves[m].id==0 || b.moves[m].id==nil
        next if b.moves[m].maxMove?
        b.moves[m] = PokeBattle_MaxMove.pbFromOldMove(self,b,b.moves[m])
      end
      b.effects[PBEffects::Dynamax]-=1
      b.unmax if b.effects[PBEffects::Dynamax]==0
      pbRaidUpdate(b)
    end
  end

  #-----------------------------------------------------------------------------
  # Reverts Dynamax upon switching.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbRecallAndReplace pbRecallAndReplace
  def pbRecallAndReplace(idxBattler,idxParty,randomReplacement=false,batonPass=false)
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax?
    _ZUD_pbRecallAndReplace(idxBattler,idxParty,randomReplacement,batonPass)
  end
  
  alias _ZUD_pbSwitchInBetween pbSwitchInBetween
  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    ret = _ZUD_pbSwitchInBetween(idxBattler,checkLaxOnly,canCancel)
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax? && ret > 0
    return ret 
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Dynamax at the end of battle.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    @battlers.each do |b|
      next if !b || !b.dynamax?
      next if b.effects[PBEffects::MaxRaidBoss]
      b.unmax
    end
    _ZUD_pbEndOfBattle
  end
end

class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  # Reverts Dynamax upon fainting.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbFaintBattler pbFaintBattler
  def pbFaintBattler(battler)
    if @battle.battlers[battler.index].dynamax?
      @battle.battlers[battler.index].unmax
    end
    _ZUD_pbFaintBattler(battler)
  end

  #-----------------------------------------------------------------------------
  # Reverts enlarged Pokemon sprites to normal size.
  #-----------------------------------------------------------------------------
  def pbChangePokemon(idxBattler,pkmn)
    idxBattler   = idxBattler.index if idxBattler.respond_to?("index")
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back         = !@battle.opposes?(idxBattler)
    battler      = @battle.battlers[idxBattler]
    pkmnSprite.setPokemonBitmap(pkmn,back,battler)
    shadowSprite.setPokemonBitmap(pkmn)
    if shadowSprite && !back
      shadowSprite.visible = showShadow?(pkmn.fSpecies)
    end
    # Reverts to initial sprite once Dynamax ends.
    if !battler.dynamax? && !pbInSafari?
      if battler.effects[PBEffects::Transform]
        pkmn = battler.effects[PBEffects::TransformPokemon]
        pkmnSprite.setPokemonBitmap(pkmn,back,battler)
      end
      if DYNAMAX_SIZE
        pkmnSprite.zoom_x   = 1
        pkmnSprite.zoom_y   = 1
        shadowSprite.zoom_x = 1
        shadowSprite.zoom_y = 1
      end
      if DYNAMAX_COLOR
        pkmnSprite.color = Color.new(0,0,0,0)
      end
    end
  end
end
  

################################################################################
# SECTION 4 - AI BATTLERS
#===============================================================================
# Determines if and when the AI should utilize certain battle mechanics.
#===============================================================================
class PokeBattle_AI
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
    @battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
    pbChooseEnemyZMove(idxBattler) if pbEnemyShouldZMove?(idxBattler)
    pbChooseMoves(idxBattler) if !@battle.pbRegisteredZMove?(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Z-Moves - The AI will use Z-Moves if opponent's HP isn't below half.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldZMove?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanZMove?(idxBattler)
      battler.eachOpposing { |opp|
        if opp.hp>(opp.totalhp/2).round
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use a Z-Move")
          return true
          break
        end
      }
    end
    return false 
  end

  def pbChooseEnemyZMove(idxBattler) #Put specific cases for trainers using status Z-Moves
    chosenmove  = nil
    chosenindex = -1
    useZMove    = false
    attacker    = @battle.battlers[idxBattler]
    # Choose the move
    for i in 0...4
      move = attacker.moves[i]
      next if !move
      if attacker.pbCompatibleZMoveFromMove?(move)
        if !chosenmove
          chosenindex = i
          chosenmove  = move
        else
          if move.baseDamage>chosenmove.baseDamage
            chosenindex = i
            chosenmove  = move
          end          
        end
      end
    end   
    return false if !chosenmove
    target_i   = nil
    target_eff = 0 
    # Choose the target
    attacker.eachOpposing { |opp|
      temp_eff = chosenmove.pbCalcTypeMod(chosenmove.type,attacker,opp)        
      if temp_eff > target_eff
        target_i   = opp.index
        target_eff = target_eff
        useZMove   = true
      end 
    }
    if useZMove
      @battle.pbRegisterZMove(idxBattler)
      @battle.pbRegisterMove(idxBattler,chosenindex,false)
      @battle.pbRegisterTarget(idxBattler,target_i)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Ultra Burst - The AI will immediately use Ultra Burst, if possible.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldUltraBurst?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanUltraBurst?(idxBattler)
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Ultra Burst")
      return true
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax - The AI will only use Dynamax on their Trainer Ace Pokemon.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldDynamax?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanDynamax?(idxBattler) && battler.pokemon.trainerAce?
      battler.pbDisplayPowerMoves(2) if !@battle.pbOwnedByPlayer?(idxBattler)
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Dynamax")
      return true
    end
    return false
  end
end