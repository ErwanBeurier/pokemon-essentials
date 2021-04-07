# Switch to allow Assistance or not. 
NO_ASSISTANCE = 88


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
       [nil, -1] * (@player ? @player.length : 1),
       [nil, -1] * (@opponent ? @opponent.length : 1)
    ]
  end 
  
  
  def pbGetAssistingData(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)

    return @assistanceData[side][owner]
  end 
  
  
  def pbChooseAssistingPokemon(idxBattler)
    # assisting = nil 
    # idxParty = nil 
    # pbParty(idxBattler).each_with_index do |pkmn,i|
      # next if !pkmn || i==@battlers[idxBattler].pokemonIndex
      # next if pkmn.egg?
      # next if pkmn.item != PBItems::SOULLINK
      # assisting = pkmn
      # idxParty = i
    # end
    idxParty = -1
    assisting = nil 
    if @battlers[idxBattler].pbOwnedByPlayer?
      idxParty = pbPartyScreen(idxBattler,false,true,true)
    else 
      idxParty = @battleAI.pbDefaultChooseNewEnemy(idxBattler,pbParty(idxBattler))
    end 
    assisting = pbParty(idxBattler)[idxParty] if idxParty >= 0
    return assisting, idxParty
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
  
  
  # Assistance registration
  def pbRegisterAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @assistance[side][owner] = idxBattler
    assisting, idxParty = pbChooseAssistingPokemon(idxBattler)
    if assisting
      @assistanceData[side][owner] = [assisting, idxParty]
    else 
      # Didn't choose. 
      @assistance[side][owner] = -1 if @assistance[side][owner]==idxBattler
      @assistanceData[side][owner] = [nil, -1]
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
    @assistanceData[side][owner] = [nil, -1]
  end

  def pbDisableAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @assistance[side][owner] = -2 if @assistance[side][owner]==idxBattler
  end

  def pbToggleRegisteredAssistance(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @assistance[side][owner]==idxBattler
      @assistance[side][owner] = -1
      @assistanceData[side][owner] = [nil, -1]
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
  
  
  # DEBUG
  # Disable the other mechanics.
  # def pbCanMegaEvolve?(idxBattler) ; return false ; end 
  # def pbCanUltraBurst?(idxBattler) ; return false ; end 
  # def pbCanZMove?(idxBattler) ; return false ; end 
  # def pbCanDynamax?(idxBattler) ; return false ; end 

end 



class PokeBattle_Battler
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
    
    # Get the changes in effects:
    @effects.each_with_index { |value, effect|
      next if assistEffectsOld[effect] == assistEffectsNew[effect]
      @effects[effect] = assistEffectsNew[effect]
      got_something = true 
    }
    
    
    # Attract             = 1
    # BeakBlast           = 3
    # Bide                = 4
    # BideDamage          = 5
    # BideTarget          = 6
    # BurnUp              = 7
    # Charge              = 8
    # ChoiceBand          = 9
    # Confusion           = 10
    # Counter             = 11
    # CounterTarget       = 12
    # Curse               = 13
    # Dancer              = 14
    # DefenseCurl         = 15
    # DestinyBond         = 16
    # DestinyBondPrevious = 17
    # DestinyBondTarget   = 18
    # Disable             = 19
    # DisableMove         = 20
    # Electrify           = 21
    # Embargo             = 22
    # Encore              = 23
    # EncoreMove          = 24
    # Endure              = 25
    # FirstPledge         = 26
    # FlashFire           = 27
    # Flinch              = 28
    # FocusEnergy         = 29
    # FocusPunch          = 30
    # FollowMe            = 31
    # Foresight           = 32
    # FuryCutter          = 33
    # GastroAcid          = 34
    # GemConsumed         = 35
    # Grudge              = 36
    # HealBlock           = 37
    # HelpingHand         = 38
    # HyperBeam           = 39
    # Illusion            = 40
    # Imprison            = 41
    # Ingrain             = 42
    # Instruct            = 43
    # Instructed          = 44
    # KingsShield         = 45
    # LaserFocus          = 46
    # LeechSeed           = 47
    # LockOn              = 48
    # LockOnPos           = 49
    # MagicBounce         = 50
    # MagicCoat           = 51
    # MagnetRise          = 52
    # MeanLook            = 53
    # MeFirst             = 54
    # Metronome           = 55
    # MicleBerry          = 56
    # Minimize            = 57
    # MiracleEye          = 58
    # MirrorCoat          = 59
    # MirrorCoatTarget    = 60
    # MoveNext            = 61
    # MudSport            = 62
    # Nightmare           = 63
    # Outrage             = 64
    # ParentalBond        = 65
    # PerishSong          = 66
    # PerishSongUser      = 67
    # PickupItem          = 68
    # PickupUse           = 69
    # Pinch               = 70   # Battle Palace only
    # Powder              = 71
    # PowerTrick          = 72
    # Prankster           = 73
    # PriorityAbility     = 74
    # PriorityItem        = 75
    # Protect             = 76
    # ProtectRate         = 77
    # Pursuit             = 78
    # Quash               = 79
    # Rage                = 80
    # RagePowder          = 81   # Used along with FollowMe
    # Revenge             = 82
    # Rollout             = 83
    # Roost               = 84
    # ShellTrap           = 85
    # SkyDrop             = 86
    # SlowStart           = 87
    # SmackDown           = 88
    # Snatch              = 89
    # SpikyShield         = 90
    # Spotlight           = 91
    # Stockpile           = 92
    # StockpileDef        = 93
    # StockpileSpDef      = 94
    # Substitute          = 95
    # Taunt               = 96
    # Telekinesis         = 97
    # ThroatChop          = 98
    # Torment             = 99
    # Toxic               = 100
    # Transform           = 101
    # TransformSpecies    = 102
    # Trapping            = 103   # Trapping move
    # TrappingMove        = 104
    # TrappingUser        = 105
    # Truant              = 106
    # TwoTurnAttack       = 107
    # Type3               = 108
    # Unburden            = 109
    # Uproar              = 110
    # WaterSport          = 111
    # WeightChange        = 112
    # Yawn                = 113
    # GorillaTactics      = 114
    # BallFetch           = 115
    # LashOut             = 118
    # BurningJealousy     = 119
    # NoRetreat           = 120
    # Obstruct            = 121
    # JawLock             = 122
    # JawLockUser         = 123
    # TarShot             = 124
    # Octolock            = 125
    # OctolockUser        = 126
    # BlunderPolicy       = 127
    # SwitchedAlly        = 128
    
    
    # Get the changes in effects of the position (e.g. Wish)
    @battle.positions[@index].effects.each_with_index { |value, effect|
      next if assistPositionsOld[effect] == assistPositionsNew[effect]
      @battle.positions[@index].effects[effect] = assistPositionsNew[effect]
      got_something = true 
    }
    
    if got_something
      @battle.pbDisplay(_INTL("{1} gained some effects from the Assistance!", pbThis))
    end 
  end 
  
end 



  
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
    oldStages = user.stages.clone # Stat stages 
    oldEffects = user.effects.clone # Effects on the Pokémon 
    oldPositions = @battle.positions[idxBattler].effects.clone # Effects on the position. 
    # scToString(oldEffects, "oldEffects")
    # scToString(user.effects, "user.effects")
    
    # Reset choice. 
    choice = [:UseMove, -1, nil, -1]
    
    # Get the assit.
    # assist,idxParty = @battle.pbChooseAssistingPokemon(idxBattler)
    assist, idxParty = @battle.pbGetAssistingData(user.index)
    
    # Check if Pokémon is in battle.
    in_battle = false 
    idxAssist = idxBattler
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
    
    @battle.pbDisplay(_INTL("{1} is here to assist {2}!",@battle.battlers[idxAssist].pbThis, oldName))
    
    # @battle.pbUnregisterAssistance(idxAssist) # 
    # Ask which move the assist should use.
    chosenCmd = 0 
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
        # @battle.pbDisplay(_INTL("choice = [{1}, {2}, {3}, {4}]", choice[0], choice[1], choice[2].name, choice[3]))
        break 
      end 
    }
    
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
    # scToString(oldEffects, "oldEffects")
    # scToString(oldStages, "oldStages")
    @battle.battlers[idxBattler].pbSetAssistanceChanges(oldEffects, oldStages, oldPositions,
                                                assistEffectsOld, assistStagesOld, assistPositionsOld, 
                                                assistEffectsNew, assistStagesNew, assistPositionsNew)
    # scToString(assistEffectsOld, "assistEffectsOld")
    # scToString(assistEffectsNew, "assistEffectsNew")
    # scToString(@battle.battlers[idxBattler].effects, "@battle.battlers[idxBattler].effects")
    # scToString(assistStagesOld, "assistStagesOld")
    # scToString(assistStagesNew, "assistStagesNew")
    # scToString(@battle.battlers[idxBattler].stages, "@battle.battlers[idxBattler].stages")
    # scToString(@battle.battlers[idxAssist].stages, "@battle.battlers[idxAssist].stages")
    
    if chosenCmd == -1
      # Cancel; allow Assistance for next turn.
      @battle.pbUnregisterAssistance(idxBattler)
    else 
      # Disable Assistance for the rest of the battle.
      @battle.pbDisableAssistance(idxBattler)
    end 
    
    # Let the first Pokémon perform its move (Assistance mechanic, not the move Assistance)
    # Delcatty cannot abuse this. 
    @battle.battlers[idxAssist].pbUseMove(@other_choice, true) if @other_choice
  end 
end 




class SCAssistMechanic < PokeBattle_Move_C007
  def initialize(battle)
    pbmove = PBMove.new(getConst(PBMoves, :ASSISTANCE))
    super(battle, pbmove)
  end 
  
  def registerOtherChoice(choice)
    @other_choice = []
    @other_choice[0] = choice[0] # Use move 
    @other_choice[1] = choice[1] # Index of move to be used 
    @other_choice[2] = choice[2] # PokeBattle_Move
    @other_choice[3] = choice[3] # Target
  end 
end 




class PokeBattle_Scene
  
  def pbHideBattler(idxBattler)
    # Set up trainer appearing animation
    disappearAnim = BattlerDisappearAnimation.new(@sprites,@viewport,idxBattler)
    @animations.push(disappearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
  end

  
  def pbShowBattler(idxBattler)
    # Set up trainer appearing animation
    appearAnim = BattlerAppearAnimation.new(@sprites,@viewport,idxBattler, @battle.sideSizes[idxBattler%2])
    @animations.push(appearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
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

