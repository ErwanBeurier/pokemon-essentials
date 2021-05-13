################################################################################
# SCAssist_Mechanic
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the main implementation of the Assistance mechanic.
# The rest of the code may be found by searching "Assistance" in the files. 
################################################################################


# Switch to allow Assistance or not. 
NO_ASSISTANCE = 88

# Number of turns between Assistance uses. 
ASSISTANCE_RELOAD_DURATION = 3

# Positive effects that the assisting Pokémon can get from the assisted 
# Pokémon, or conversely. 
POSITIVE_EFFECTS_BATTLER = [
  PBEffects::FocusEnergy,
  PBEffects::FuryCutter, 
  PBEffects::HelpingHand,
  PBEffects::LaserFocus, 
  PBEffects::LockOn,
  PBEffects::LockOnPos,
  PBEffects::Metronome,
  PBEffects::Rage,
  PBEffects::Rollout,
  PBEffects::Stockpile, 
  PBEffects::StockpileDef, 
  PBEffects::StockpileSpDef]
# Positive effects that the assisting Pokémon can get from the assisted 
# Pokémon, or conversely. These effects apply to a position. 
POSITIVE_EFFECTS_POSITION = [
  PBEffects::HealingWish, 
  PBEffects::LunarDance, 
  PBEffects::Wish, 
  PBEffects::WishAmount, 
  PBEffects::WishMaker, 
  PBEffects::WarmWelcome, 
  PBEffects::PhoenixFire
]





# Adding the mechanics of Assistance. 
class PokeBattle_Battle
  attr_accessor :assistance
  attr_accessor :assistanceData
  
  alias __assist__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __assist__init(scene,p1,p2,player,opponent)
    @assistance = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @assistanceData = [
       [nil, -1, false] * (@player ? @player.length : 1),
       [nil, -1, false] * (@opponent ? @opponent.length : 1)
    ]
  end 
  
  
  def pbGetAssistingData(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)

    return @assistanceData[side][owner]
  end 
  
  
  # If player: calls the Party screen to choose a Pokémon from.
  # Otherwise, choose a Pokémon in the team. 
  def pbChooseAssistingPokemon(idxBattler)
    idxParty = -1
    assisting = nil 
    assistAfter = false 
    if @battlers[idxBattler].pbOwnedByPlayer?
      # idxParty = pbPartyScreen(idxBattler,false,true,true)
      @scene.pbPartyScreenAssist(idxBattler) { |idx,partyScene,after|
        idxParty = idx 
        assistAfter = after 
        next true 
      }
    else 
      idxParty = @battleAI.scChooseNonSwitchingPokemon(idxBattler,pbParty(idxBattler))
    end 
    assisting = pbParty(idxBattler)[idxParty] if idxParty >= 0
    return assisting, idxParty, assistAfter
  end 
  
  
  def pbCanCallAssitance?(idxBattler)
    return false if $game_switches[NO_ASSISTANCE]
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if wildBattle? && opposes?(idxBattler)       # No Assistance for wild Pokemon.
    return false if !battler.canCallAssistance?
    return true if $DEBUG && Input.press?(Input::CTRL)        # Allows Assistance with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0    # No Assistance if in Sky Drop.
    return false if @assistance[side][owner]!=-1              # No Assistance if used this battle.
    # Checks if a Pokémon in the party holds the Soul Link. 
    # assist, idxParty = pbChooseAssistingPokemon(idxBattler)
    # return false if !assist || !idxParty
    return @assistance[side][owner]==-1
  end
  
  
  # Returns true if any battle mechanic is available to the user.
  alias __assist__pbCanUseBattleMechanic pbCanUseBattleMechanic?
  def pbCanUseBattleMechanic?(idxBattler)
    ret = __assist__pbCanUseBattleMechanic(idxBattler)
    return ret || pbCanCallAssitance?(idxBattler)
  end
  
  
  #-----------------------------------------------------------------------------
  # Assistance registration
  #-----------------------------------------------------------------------------
  def pbRegisterAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @assistance[side][owner] = idxBattler
    assisting, idxParty, assistAfter = pbChooseAssistingPokemon(idxBattler)
    if assisting
      @assistanceData[side][owner] = [assisting, idxParty, assistAfter]
    else 
      # Didn't choose. 
      @assistance[side][owner] = -1 if @assistance[side][owner]==idxBattler
      @assistanceData[side][owner] = [nil, -1, false]
    end 
    # @choices[idxBattler][0] = :UseMove   # "Use move"
    # @choices[idxBattler][1] = -1         # Index of move to be used
    # @choices[idxBattler][2] = SCAssistMechanic.new(self)  # PokeBattle_Move object to represent the Assistance.
    # @choices[idxBattler][3] = -1         # No target chosen yet
  end
  
  
  def pbUnregisterAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @assistance[side][owner] = -1 if @assistance[side][owner]==idxBattler
    @assistanceData[side][owner] = [nil, -1, false]
  end


  def pbDisableAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @assistance[side][owner] = -2 - ASSISTANCE_RELOAD_DURATION if @assistance[side][owner]==idxBattler
  end
  
  
  def pbToggleRegisteredAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @assistance[side][owner]==idxBattler
      @assistance[side][owner] = -1
      @assistanceData[side][owner] = [nil, -1, false]
    else
      pbRegisterAssistance(idxBattler)
    end
  end
  
  
  def pbRegisteredAssistance?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @assistance[side][owner]==idxBattler
  end
  
  
  #-----------------------------------------------------------------------------
  # Triggers the use of each battle mechanic during the attack phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhaseAssistance
    pbPriority.each do |b|
      # idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      # next unless @choices[b.index][0]==:UseMove && !b.fainted?
      next unless !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @assistance[b.idxOwnSide][owner]!=b.index
      # Store the choice of the Pokémon, and replace the choice with assistance.
      assist = SCAssistMechanic.new(self)
      assist.registerOtherChoice(@choices[b.index])
      @choices[b.index][0] = :UseMove  # "Use move"
      @choices[b.index][1] = -1        # Index of move to be used
      @choices[b.index][2] =  assist   # PokeBattle_Move object to represent the Assistance.
      @choices[b.index][3] = -1        # No target chosen yet
    end
  end
  
  
  def pbEORAssistanceReloading(priority)
    priority.each do |b|
      # idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      # next unless @choices[b.index][0]==:UseMove && !b.fainted?
      next unless !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @assistance[b.idxOwnSide][owner] >= -1 
      
      @assistance[b.idxOwnSide][owner] += 1
      
      if @assistance[b.idxOwnSide][owner] == -1
        pbDisplay(_INTL("{1} can use Assistance again!", pbGetOwnerName(b.index)))
      end 
    end
  end 
  
  
  # DEBUG
  # Disable the other mechanics.
  # def pbCanMegaEvolve?(idxBattler) ; return false ; end 
  # def pbCanUltraBurst?(idxBattler) ; return false ; end 
  # def pbCanZMove?(idxBattler) ; return false ; end 
  # def pbCanDynamax?(idxBattler) ; return false ; end 
end 




class PokeBattle_Battler
  # Assistance come after Z-moves, Mega, and before Dynamax. 
  def canCallAssistance?
    # DEBUG 
    # return true 
    # END OF DEBUG
    return false if shadowPokemon?
    return false if pbIsZCrystal?(self.item) || hasZMove?
    return false if pokemon.mega?   || hasMega?
    return false if pokemon.primal? || hasPrimal?
    return false if pokemon.ultra?  || hasUltra?
    return false if !isConst?(self.item, PBItems, :SOULLINK)
    # return false if hasDynamax?
    return true
  end
  
  
  # Get the positive effects gained by the assited Pokémon due to the action 
  # of the assit.
  def pbSetAssistanceChanges(effectsOld, stagesOld, positionsOld, 
            assistEffectsOld, assistStagesOld, assistPositionsOld, 
            assistEffectsNew, assistStagesNew, assistPositionsNew)
    
    # Get back the old effects / stages
    @effects = effectsOld
    @stages = stagesOld
    @battle.positions[@index].effects = positionsOld
    
    return if !assistEffectsOld || !assistEffectsNew
    return if !assistStagesOld || !assistStagesNew
    return if !assistPositionsOld || !assistPositionsNew
    
    got_something = false 
    
    # Get the stat changes.
    PBStats.eachBattleStat { |s| 
      next if assistStagesOld[s] == assistStagesNew[s] # Unchanged 
      next if assistStagesNew[s] < 0 # Don't take negative stuff. 
      @stages[s] += assistStagesNew[s] - assistStagesOld[s]
      got_something = true 
    }
    
    # Get the changes in effects (Only positive effects carry out)
    POSITIVE_EFFECTS_BATTLER.each { |effect|
      next if assistEffectsOld[effect] == assistEffectsNew[effect]
      @effects[effect] = assistEffectsNew[effect]
      got_something = true 
    }
    
    # Get the changes in effects of the position (e.g. Wish)
    # Needed only if the assisting Pokémon was on the field and set something 
    # to the position. 
    POSITIVE_EFFECTS_POSITION.each { |effect|
      next if assistPositionsOld[effect] == assistPositionsNew[effect]
      @battle.positions[@index].effects[effect] = assistPositionsNew[effect]
      got_something = true 
    }
    
    if got_something
      @battle.pbDisplay(_INTL("{1} gained some effects from the Assistance!", pbThis))
    end 
  end 
  
  
  # Transfer the positive effects of the calling Pokémon to the assist. 
  def pbSetAssistanceEffects(effectsOld, stagesOld, positionsOld, isAssist)
    # isAssist = true if self is the assisting Pokémon, false if it is the 
    # assisted Pokémon.
    got_something = false 
    
    # Get the stat changes.
    PBStats.eachBattleStat { |s| 
      next if @stages[s] == stagesOld[s] # Unchanged 
      next if stagesOld[s] < 0 # Don't take negative stuff. 
      @stages[s] = stagesOld[s]
      got_something = true 
    }
    
    # Get the changes in effects (Only positive effects carry out)
    POSITIVE_EFFECTS_BATTLER.each { |effect|
      next if @effects[effect] == effectsOld[effect]
      @effects[effect] = effectsOld[effect]
      got_something = true 
    }
    
    # Get the changes in effects of the position (e.g. Wish)
    # Needed only if the assisting Pokémon was on the field and set something 
    # to the position. 
    POSITIVE_EFFECTS_POSITION.each { |effect|
      next if @battle.positions[@index].effects[effect] == positionsOld[effect]
      @battle.positions[@index].effects[effect] = positionsOld[effect]
      got_something = true 
    }
    
    if got_something && isAssist
      @battle.pbDisplay(_INTL("{1} gained some effects from the caller!", pbThis)) 
    end 
  end 
end 



#===============================================================================
# Visual animations (appear/disappear)
#===============================================================================


class PokeBattle_Scene
  # Used to hide the calling Pokémon.
  def pbHideBattler(idxBattler)
    # Set up trainer appearing animation
    disappearAnim = BattlerDisappearAnimation.new(@sprites,@viewport,idxBattler)
    @animations.push(disappearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
  end

  
  # Used to move back the calling Pokémon.
  def pbShowBattler(idxBattler)
    # Set up trainer appearing animation
    appearAnim = BattlerAppearAnimation.new(@sprites,@viewport,idxBattler, @battle.sideSizes[idxBattler%2])
    @animations.push(appearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
  end
  
  
  # A Party screen function that allows to choose which Pokémon to use for assist.
  def pbPartyScreenAssist(idxBattler)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Choose an assisting Pokémon."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Choose an assisting Pokémon."))
      idxParty = switchScreen.pbChoosePokemon
      break if idxParty<0
      # Choose a command for the selected Pokémon
      cmdAssistBefore  = -1
      cmdAssistAfter  = -1
      cmdSwitch  = -1
      cmdSummary = -1
      commands = []
      commands[cmdAssistBefore  = commands.length] = _INTL("Assist (before)") if modParty[idxParty].able?
      commands[cmdAssistAfter = commands.length] = _INTL("Assist (after)") if modParty[idxParty].able?
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      if (cmdAssistBefore>=0 && command==cmdAssistBefore) || 
        cmdAssistAfter>=0 && command==cmdAssistAfter      # Chosen for assistance
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen, (command==cmdAssistAfter) # True = fater, False = before
      elsif cmdSummary>=0 && command==cmdSummary   # Summary
        scene.pbSummary(idxParty,true)
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
  end
end 




class BattlerDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,idxBattler)
    @idxBattler = idxBattler
    super(sprites,viewport)
  end
  
  def createProcesses
    delay = 0
    # Make old trainer sprite move off-screen first if necessary
    if @sprites["pokemon_#{@idxBattler}"] && @sprites["pokemon_#{@idxBattler}"].visible
      oldPokemon = addSprite(@sprites["pokemon_#{@idxBattler}"],PictureOrigin::Bottom)
      oldPokemon.moveDelta(delay,8,-Graphics.width/2,0)
      oldPokemon.setVisible(delay+8,false)
      delay = oldPokemon.totalDuration
    end
  end
end




class BattlerAppearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,idxBattler, sideSize)
    @idxBattler = idxBattler
    @sideSize = sideSize
    super(sprites,viewport)
  end
  
  def createProcesses
    delay = 0
    # Make new trainer sprite move on-screen
    if @sprites["pokemon_#{@idxBattler}"]
      battlerX, battlerY = PokeBattle_SceneConstants.pbBattlerPosition(@idxBattler,@sideSize)
      newBattler = addSprite(@sprites["pokemon_#{@idxBattler}"],PictureOrigin::Bottom)
      newBattler.setVisible(delay,true)
      newBattler.setXY(delay,-Graphics.width/2,0)
      newBattler.moveDelta(delay,8,battlerX + Graphics.width/2,battlerY)
    end
  end
end




#===============================================================================
# Calls a Pokémon for Assistance. 
# (Assistance)
#===============================================================================

class PokeBattle_Move_C007 < PokeBattle_Move
  def initialize(battle, move)
    super(battle, move)
    @other_choice = nil 
  end 
  
  
  def pbMoveFailed?(user, targets)
    # assist, idxParty = @battle.pbChooseAssistingPokemon(user.index)
    side = user.idxOwnSide
    owner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    if !@battle.assistanceData[side][owner][0] || @battle.assistanceData[side][owner][1] < 0 || 
      @battle.assistanceData[side][owner][0].egg?
      @battle.pbDisplay(_INTL("{1} couldn't find Assistance!",user.pbThis))
      return true 
    end 
    return false 
  end 
  
  
  def pbDisplayUseMessage(user)
    @battle.pbDisplay(_INTL("{1} called for Assistance!",user.pbThis))
  end
  
  
  def pbEffectGeneral(user)
    # Store old data.
    idxBattler = user.index 
    idxCallingPkmn = @battle.battlers[idxBattler].pokemonIndex
    oldName = user.pbThis
    
    # Reset choice. 
    choice = [:UseMove, -1, nil, -1]
    
    # Get the assit.
    assist, idxParty, assistAfter = @battle.pbGetAssistingData(user.index)
    
    if !user.opposes?
      TrainerDialogue.display("assistBefore",@battle,@battle.scene, user)
    else
      TrainerDialogue.display("assistBeforeOpp",@battle,@battle.scene, user)
    end
    
    # currentAction = allows to track which, of the assiting and assisted, came first. 
    for currentAction in 0..1
      idxAssist = idxBattler
      
      if !assistAfter
        #------------------------------------
        # The part of the assisting Pokémon.
        #------------------------------------
        # Old state of the caller. 
        oldStages = user.stages.clone # Stat stages 
        oldEffects = user.effects.clone # Effects on the Pokémon 
        oldPositions = @battle.positions[idxBattler].effects.clone # Effects on the position. 
        
        # Check if Pokémon is in battle.
        in_battle = false 
        oldAssistChoice = nil # Stores the first choice for the Assist, so that the Assist can attack twice (one with the Assist + the normal turn).
        lastRoundMovedAssist = nil 
        
        @battle.eachBattler { |b| 
          next if b.opposes?(idxBattler)
          next if b.pokemonIndex != idxParty
          in_battle = true
          idxAssist = b.index 
          oldAssistChoice = [@battle.choices[idxAssist][0], 
                            @battle.choices[idxAssist][1], 
                            @battle.choices[idxAssist][2], 
                            @battle.choices[idxAssist][3]]
          lastRoundMovedAssist = b.lastRoundMoved
          break 
        }
        
        # Set the assist if the assist in not in battle. 
        if !in_battle
          @battle.scene.pbHideBattler(idxBattler)
          @battle.battlers[idxBattler].pbInitialize(assist,idxParty,false)
          @battle.scene.pbChangePokemon(idxBattler,assist)
          @battle.scene.pbShowBattler(idxBattler)
        end 
        
        # Store the effects / stages of the Assist before it uses its move. 
        assistEffectsOld = @battle.battlers[idxAssist].effects.clone 
        assistStagesOld = @battle.battlers[idxAssist].stages.clone
        assistPositionsOld = @battle.positions[idxAssist].effects.clone # Effects on the position. 
        
        # Transfer the positive effects to the assist. 
        @battle.battlers[idxAssist].pbSetAssistanceEffects(oldEffects, oldStages, oldPositions, true)
        
        @battle.pbDisplay(_INTL("{1} is here to assist {2}!",@battle.battlers[idxAssist].pbThis, oldName))
        
        # Ask which move the assist should use.
        chosenCmd = 0 
        
        if user.opposes?
          @battle.battleAI.pbChooseMoves(idxAssist)
          choice = @battle.choices[idxAssist]
        else 
          @battle.scene.pbFightMenu(idxAssist,false, false, false, false, false) { |cmd|
            chosenCmd = cmd 
            if cmd >= 0 
              choice[1] = cmd
              choice[2] = @battle.battlers[idxAssist].moves[cmd]
              
              @battle.pbChooseTarget(@battle.battlers[idxAssist],choice[2])
              choice[3] = @battle.choices[idxAssist][3]
              
              if choice[3] == idxAssist && idxAssist != idxBattler
                # Target the other Pokémon instead.
                choice[3] = idxBattler
              end 
              break 
            end 
          }
        end 
        
        assistEffectsNew = nil 
        assistStagesNew = nil 
        assistPositionsNew = nil 
        
        if chosenCmd == -1
          # Chosen to cancel. Cancel the move. 
          @battle.pbDisplay(_INTL("{1} canceled the Assistance!", oldName))
        else 
          # Use the move.
          @battle.battlers[idxAssist].pbUseMove(choice, true)
          
          # Get the new effects gained by the Assist 
          assistEffectsNew = @battle.battlers[idxAssist].effects.clone 
          assistStagesNew = @battle.battlers[idxAssist].stages.clone
          assistPositionsNew = @battle.positions[idxAssist].effects.clone
        end 
        
        # Get back the calling Pokémon. 
        if !in_battle
          @battle.scene.pbHideBattler(idxBattler)
          oldPkmn = @battle.pbParty(idxBattler)[idxCallingPkmn]
          
          @battle.battlers[idxBattler].pbInitialize(oldPkmn,idxCallingPkmn,false)
          
          @battle.scene.pbChangePokemon(idxBattler,oldPkmn)
          @battle.scene.pbShowBattler(idxBattler)
        else 
          # Reset the choice of the battler. 
          @battle.battlers[idxAssist].lastRoundMoved = lastRoundMovedAssist
          @battle.choices[idxAssist] = oldAssistChoice
          
          # Reset the battler's effects.
          @battle.battlers[idxAssist].effects = assistEffectsOld
          @battle.battlers[idxAssist].stages = assistStagesOld
        end 
        
        # Give back the effects. 
        @battle.battlers[idxBattler].pbSetAssistanceChanges(oldEffects, oldStages, oldPositions,
                                                    assistEffectsOld, assistStagesOld, assistPositionsOld, 
                                                    assistEffectsNew, assistStagesNew, assistPositionsNew)
      else 
        #------------------------------------
        # The part of the assisted Pokémon.
        #------------------------------------
        # Let the first Pokémon perform its move (Assistance mechanic, not the move Assistance)
        # Delcatty cannot abuse this. 
        @battle.battlers[idxAssist].pbUseMove(@other_choice, true) if @other_choice
        
      end 
      
      assistAfter = !assistAfter
    end 
    
    if chosenCmd == -1
      # Cancel; allow Assistance for next turn.
      @battle.pbUnregisterAssistance(idxBattler)
    else 
      # Disable Assistance for the rest of the battle.
      @battle.pbDisableAssistance(idxBattler)
    end 
    
    if !user.opposes?
      TrainerDialogue.display("assistAfter",@battle,@battle.scene, user)
    else
      TrainerDialogue.display("assistAfterOpp",@battle,@battle.scene, user)
    end
  end 
end 



#===============================================================================
# This is the placehlder move that is registeered when the player triggers the  
# assistance mechanic.
#===============================================================================
class SCAssistMechanic < PokeBattle_Move_C007
  def initialize(battle)
    pbmove = PBMove.new(getConst(PBMoves, :ASSISTANCE))
    super(battle, pbmove)
  end 
  
  
  def statusMove?
    return false 
  end 
  
  
  def registerOtherChoice(choice)
    @other_choice = []
    @other_choice[0] = choice[0] # Use move 
    @other_choice[1] = choice[1] # Index of move to be used 
    @other_choice[2] = choice[2] # PokeBattle_Move
    @other_choice[3] = choice[3] # Target
  end 
end 




#===============================================================================
# AI stuff: choose an assisting Pokémon + make the AI accessible frm outside.
#===============================================================================

class PokeBattle_Battle
  attr_accessor :battleAI
end 


class PokeBattle_AI
  # For Assistance, teleport...
  # Allows to choose a Pokémon either in the party or in the battle field.
  def scChooseNonSwitchingPokemon(idxBattler,party)
    enemies = []
    idxPkmn = @battle.battlers[idxBattler].pkmn.index
    party.each_with_index do |_p,i|
      enemies.push(i) if p.able? && idxPkmn != i 
    end
    return -1 if enemies.length==0
    return pbChooseBestNewEnemy(idxBattler,party,enemies)
  end
  
  def pbEnemyShouldCallForAssistance?(idxBattler)
    return @battle.pbCanCallAssitance?(idxBattler)
  end 
end 

