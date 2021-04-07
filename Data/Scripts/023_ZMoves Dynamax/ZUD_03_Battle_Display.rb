#===============================================================================
#
# ZUD_03: Battle Display
#
#===============================================================================
# This script implements the battle visuals for selecting each battle mechanic
# in the fight menu. This includes the button toggles for each mechanic, display
# messages, as well as converting moves into Z-Moves/Max Moves when appropriate.
#
#===============================================================================
# SECTION 1 - BATTLE PHASES
#-------------------------------------------------------------------------------
# This section handles functions during the command and attack phase in battle.
#===============================================================================
# SECTION 2 - FIGHT MENU
#-------------------------------------------------------------------------------
# This section handles everything related to the fight menu display in battle,
# including button toggles and updating new moves to display.
#===============================================================================
# SECTION 3 - DATABOX DISPLAY
#-------------------------------------------------------------------------------
# This section simply includes the Dynamax icon for Pokemon that are Dynamaxed.
#===============================================================================

################################################################################
# SECTION 1 - BATTLE PHASES
#===============================================================================
# Handles battle mechanics while selecting and executing a move.
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  # Pokemon with an eligible battle mechanic may always access its fight menu,
  # even if the effects of Encore would otherwise lock them out.
  #-----------------------------------------------------------------------------
  def pbCanShowFightMenu?(idxBattler)
    battler = @battlers[idxBattler]
    return false if battler.effects[PBEffects::Encore]>0 && !pbCanUseBattleMechanic?(idxBattler)
    usable = false
    battler.eachMoveWithIndex do |_m,i|
      next if !pbCanChooseMove?(idxBattler,i,false)
      usable = true
      break
    end
    return usable
  end
  
  #-----------------------------------------------------------------------------
  # Message display when an Encored move is selected in the fight menu.
  #-----------------------------------------------------------------------------
  def pbCanChooseMove?(idxBattler,idxMove,showMessages,sleepTalk=false)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false unless move && move.id>0
    if move.pp==0 && move.totalpp>0 && !sleepTalk
      pbDisplayPaused(_INTL("There's no PP left for this move!")) if showMessages
      return false
    end
    if battler.effects[PBEffects::Encore]>0
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove>=0 && idxMove!=idxEncoredMove && !move.powerMove?
        pbDisplayPaused(_INTL("Encore prevents using this move!")) if showMessages
        return false 
      end 
    end
    return battler.pbCanChooseMove?(move,true,showMessages,sleepTalk)
  end
  
  #-----------------------------------------------------------------------------
  # Unregisters mechanics and returns to base moves when a choice is cancelled.
  #-----------------------------------------------------------------------------
  def pbCancelChoice(idxBattler)
    if @choices[idxBattler][0]==:UseItem
      item = @choices[idxBattler][1]
      pbReturnUnusedItemToBag(item,idxBattler) if item && item>0
    end
    pbUnregisterMegaEvolution(idxBattler)
    pbUnregisterUltraBurst(idxBattler)
    if pbRegisteredZMove?(idxBattler)
      pbUnregisterZMove(idxBattler)
      @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
      @battlers[idxBattler].pbDisplayBaseMoves
    end
    if pbRegisteredDynamax?(idxBattler)
      pbUnregisterDynamax(idxBattler)
      @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
      @battlers[idxBattler].pbDisplayBaseMoves
    end
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Unregister any custom battle mechanics here.
    #===========================================================================
    # pbUnregister<InsertCustomMechanic>(idxBattler)
    #---------------------------------------------------------------------------
    pbUnregisterAssistance(idxBattler)
    pbClearChoice(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Battle mechanics during the command phase.
  #-----------------------------------------------------------------------------
  def pbCommandPhase
    @scene.pbBeginCommandPhase
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Mega Evolution
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    # Ultra Burst
    for side in 0...2
      @ultraBurst[side].each_with_index do |uBurst,i|
        @ultraBurst[side][i] = -1 if uBurst>=0
      end
    end
    # Z-Moves
    for side in 0...2
      @zMove[side].each_with_index do |zMove,i|
        @zMove[side][i] = -1 if zMove>=0
      end
    end
    # Dynamax
    for side in 0...2
      @dynamax[side].each_with_index do |dmax,i|
        @dynamax[side][i] = -1 if dmax>=0
      end
    end
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Add the code for selecting any custom battle mechanics during the command
    # phase here. Use the code below as a guide.
    #===========================================================================
    #for side in 0...2
    #  @custom[side].each_with_index do |customMechanic,i|
    #    @custom[side][i] = -1 if customMechanic>=0
    #  end
    #end
    #---------------------------------------------------------------------------
    # Assistance
    for side in 0...2
      @assistance[side].each_with_index do |ass,i|
        @assistance[side][i] = -1 if ass>=0
        @assistanceData[side][i] = [nil, -1] if ass>=0
      end
    end
    pbCommandPhaseLoop(true)
    return if @decision!=0
    pbCommandPhaseLoop(false)
  end

  #-----------------------------------------------------------------------------
  # Battle mechanics during the attack phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")
    end
    #---------------------------------------------------------------------------
    # Prepare for Z-Moves.
    #---------------------------------------------------------------------------
    @battlers.each_with_index do |b,i|
      next if !b || b.fainted?
      next if @choices[i][0]!=:UseMove
      side  = (opposes?(i)) ? 1 : 0
      owner = pbGetOwnerIndexFromBattlerIndex(i)
      @choices[i][2].zmove_sel = (@zMove[side][owner]==i)
    end
    #---------------------------------------------------------------------------
    PBDebug.log("")
    pbCalculatePriority(true)
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseUltraBurst
    pbAttackPhaseZMoves
    pbAttackPhaseDynamax
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Add the code for triggering any custom battle mechanic effects during the
    # attack phase here.
    #===========================================================================
    #pbAttackPhase<InsertCustomMechanic>
    #---------------------------------------------------------------------------
    pbAttackPhaseAssistance
    pbAttackPhaseRaidBoss
    pbAttackPhaseCheer
    pbAttackPhaseMoves
  end

  
################################################################################
# SECTION 2 - FIGHT MENU
#===============================================================================
# Handles buttons for activating battle mechanics.
#===============================================================================
  def pbFightMenu(idxBattler)
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    return true if pbAutoFightMenu(idxBattler)
    ret = false
    @scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler),
                                  pbCanUltraBurst?(idxBattler),
                                  pbCanZMove?(idxBattler),
                                  pbCanDynamax?(idxBattler),
                                  ##############################################
                                  # CUSTOM MECHANICS
                                  #=============================================
                                  # Add a comma after the above line, and add
                                  # any custom battle mechanic checks here.
                                  #=============================================
                                  #pbCan<InsertCustomMechanic>?(idxBattler)
                                  #---------------------------------------------
                                  pbCanCallAssitance?(idxBattler)
                                  ) { |cmd|
      case cmd
      when -1   # Cancel
      when -2   # Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when -3   # Ultra Burst
        pbToggleRegisteredUltraBurst(idxBattler)
        next false
      when -4   # Z-Moves
        pbToggleRegisteredZMove(idxBattler)
        next false
      when -5   # Dynamax
        pbToggleRegisteredDynamax(idxBattler)
        next false
      ##########################################################################
      # CUSTOM MECHANICS
      #=========================================================================
      # Add the toggle for any custom battle mechanics here.
      # Make sure to adjust the numbers after "when" for Shift.
      #=========================================================================
      #when -7   # Custom Mechanic
      #  pbToggleRegistered<InsertCustomMechanic>(idxBattler)   
      #  next false
      #-------------------------------------------------------------------------
      when -6   # Assistance 
        pbToggleRegisteredAssistance(idxBattler)
        # ret = true 
        next false 
      when -7   # Shift
        pbUnregisterMegaEvolution(idxBattler)
        pbUnregisterUltraBurst(idxBattler)
        pbUnregisterZMove(idxBattler)
        pbUnregisterDynamax(idxBattler)
        @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
        @battlers[idxBattler].pbDisplayBaseMoves
        ########################################################################
        # CUSTOM MECHANICS
        #=======================================================================
        # Unregister any custom battle mechanics here.
        #=======================================================================
        # pbUnregister<InsertCustomMechanic>(idxBattler)
        #-----------------------------------------------------------------------
        pbUnregisterAssistance(idxBattler)
        pbRegisterShift(idxBattler)
        ret = true
      else
        next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
                                @battlers[idxBattler].moves[cmd].id<=0
        next false if !pbRegisterMove(idxBattler,cmd)
        next false if !singleBattle? &&
           !pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    }
    return ret
  end
end

#===============================================================================
# Effects of button inputs for battle mechanics.
#===============================================================================
class PokeBattle_Scene
  def pbFightMenu(idxBattler,megaEvoPossible=false,
                             ultraPossible=false,
                             zMovePossible=false,
                             dynamaxPossible=false,
                             ###################################################
                             # CUSTOM MECHANICS
                             #==================================================
                             # Add a comma after the above line, and add any
                             # custom battle mechanics set to false here.
                             #==================================================
                             #customPossible=false
                             #--------------------------------------------------
                             assistancePossible=false 
                             )
                             
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex  = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id>0
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    mechanicPossible = false
    cw.chosen_button = FightMenuDisplay::NoButton
    cw.chosen_button = FightMenuDisplay::MegaButton       if megaEvoPossible
    cw.chosen_button = FightMenuDisplay::UltraBurstButton if ultraPossible
    cw.chosen_button = FightMenuDisplay::ZMoveButton      if zMovePossible
    cw.chosen_button = FightMenuDisplay::DynamaxButton    if dynamaxPossible
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Add the button for any custom battle mechanics here. Make sure to add the
    # check for your custom mechanic in the "if" statement below.
    #===========================================================================
    #cw.chosen_button = FightMenuDisplay::CustomButton     if customPossible
    #---------------------------------------------------------------------------
    cw.chosen_button = FightMenuDisplay::AssistanceButton  if assistancePossible
    if megaEvoPossible || ultraPossible || 
       zMovePossible   || dynamaxPossible ||
       assistancePossible # || customPossible
      mechanicPossible = true
    end
    cw.setIndexAndMode(moveIndex,(mechanicPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if ultraPossible
          newMode = (@battle.pbRegisteredUltraBurst?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if zMovePossible
          newMode = (@battle.pbRegisteredZMove?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if dynamaxPossible
          newMode = (@battle.pbRegisteredDynamax?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        ########################################################################
        # CUSTOM MECHANICS
        #=======================================================================
        # Add the register check for your custom battle mechanics here.
        #=======================================================================
        #if customPossible
        #  newMode = (@battle.pbRegistered<InsertCustomMechanic>?(idxBattler)) ? 2 : 1
        #  cw.mode = newMode if newMode!=cw.mode
        #end
        #-----------------------------------------------------------------------
        if assistancePossible
          newMode = (@battle.pbRegisteredAssistance?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      pbUpdate(cw)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id>0
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id>0
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
#===============================================================================
# Confirm Selection
#===============================================================================
      if Input.trigger?(Input::C)
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          if cw.mode==2
            if !battler.pbCompatibleZMoveFromIndex?(cw.index)
              @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",
                PBMoves.getName(battler.moves[cw.index]),PBItems.getName(battler.item)))
              if battler.effects[PBEffects::PowerMovesButton]
                battler.effects[PBEffects::PowerMovesButton] = false
                battler.pbDisplayBaseMoves(1)
              end
              break if yield -1
            end
          end
        end
        #-----------------------------------------------------------------------
        # Dynamax - Gets Max Move PP usage.
        #-----------------------------------------------------------------------
        if battler.effects[PBEffects::PowerMovesButton]
          pressure = true if @battle.pbCheckOpposingAbility(:PRESSURE,battler)
          ppusage  = (pressure) ? 2 : 1
          battler.effects[PBEffects::MaxMovePP][cw.index] += ppusage
        end
        #-----------------------------------------------------------------------
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
#===============================================================================
# Cancel Selection
#===============================================================================
      elsif Input.trigger?(Input::B)
        #-----------------------------------------------------------------------
        # Z-Moves - Reverts to base moves.
        #-----------------------------------------------------------------------
        if zMovePossible
          if battler.effects[PBEffects::PowerMovesButton]
            battler.effects[PBEffects::PowerMovesButton] = false
            battler.pbDisplayBaseMoves
          end
        end
        #-----------------------------------------------------------------------
        # Dynamax - Reverts to base moves.
        #-----------------------------------------------------------------------
        if dynamaxPossible
          if battler.effects[PBEffects::PowerMovesButton] && !battler.dynamax?
            battler.effects[PBEffects::PowerMovesButton] = false
            battler.pbDisplayBaseMoves
          end
        end
        #-----------------------------------------------------------------------
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
#===============================================================================
# Toggle Battle Mechanic
#===============================================================================
      elsif Input.trigger?(Input::A)
        #-----------------------------------------------------------------------
        # Mega Evolution
        #-----------------------------------------------------------------------
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Ultra Burst
        #-----------------------------------------------------------------------
        if ultraPossible
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
          if battler.effects[PBEffects::PowerMovesButton]
            battler.pbDisplayPowerMoves(1)
          else
            battler.pbDisplayBaseMoves
          end
          needFullRefresh = true
          pbPlayDecisionSE
          break if yield -4
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Dynamax
        #-----------------------------------------------------------------------
        if dynamaxPossible
          if battler.effects[PBEffects::PowerMovesButton]
            battler.effects[PBEffects::PowerMovesButton] = false
            battler.pbDisplayBaseMoves
          else
            battler.effects[PBEffects::PowerMovesButton] = true
            battler.pbDisplayPowerMoves(2)
          end
          needFullRefresh = true
          pbPlayDecisionSE
          break if yield -5
          needRefresh = true
        end
        ########################################################################
        # CUSTOM MECHANICS
        #=======================================================================
        # Add button input for your custom battle mechanics here.
        # Renumber "yield" in the Shift command to account for added mechanics.
        #=======================================================================
        #if customPossible
        #  pbPlayDecisionSE
        #  break if yield -6
        #  needRefresh = true
        #end
        #-----------------------------------------------------------------------
        # Assistance
        #-----------------------------------------------------------------------
        if assistancePossible
          pbPlayDecisionSE
          break if yield -6
          needRefresh = true
        end
#===============================================================================
# Shift Command
#===============================================================================
      elsif Input.trigger?(Input::F5)
        if cw.shiftMode>0
          pbPlayDecisionSE
          break if yield -7
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end
end

#===============================================================================
# Displays button graphics.
#===============================================================================
class FightMenuDisplay < BattleMenuBase
  NoButton         =-1 
  MegaButton       = 0
  UltraBurstButton = 1
  ZMoveButton      = 2
  DynamaxButton    = 3
  AssistanceButton = 4
  ##############################################################################
  # CUSTOM MECHANICS
  #=============================================================================
  # Add a button number for any custom battle mechanics here.
  #=============================================================================
  #CustomButton     = 4
  #-----------------------------------------------------------------------------
  
  def initialize(viewport,z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height-96
    @battler   = nil
    @shiftMode = 0
    if USE_GRAPHICS
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      @battleButtonBitmap = {}
      # Mega Evolution
      @battleButtonBitmap[MegaButton]       = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      # Ultra Burst
      @battleButtonBitmap[UltraBurstButton] = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_ultra"))
      # Z-Moves
      @battleButtonBitmap[ZMoveButton]      = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_zmove"))
      # Dynamax
      @battleButtonBitmap[DynamaxButton]    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_dynamax"))
      @battleButtonBitmap[DynamaxButton]    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_dynamax_2")) if DMAX_BUTTON_2
      ##########################################################################
      # CUSTOM MECHANICS
      #=========================================================================
      # Add the button graphics for any custom battle mechanics here.
      #=========================================================================
      #@battleButtonBitmap[CustomButton]     = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_custom"))
      #-------------------------------------------------------------------------
      # Assistance
      @battleButtonBitmap[AssistanceButton] = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_assistance"))
      # Chosen button:
      @chosen_button = NoButton
      background = IconSprite.new(0,Graphics.height-96,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background",background)
      @buttons = Array.new(MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+4
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+6
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
      @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay",@overlay)
      @infoOverlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay",@infoOverlay)
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x+416
      @typeIcon.y      = self.y+20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon",@typeIcon)
      @battleButton = SpriteWrapper.new(viewport) # For button graphic
      @shiftButton = SpriteWrapper.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x+4
      @shiftButton.y      = self.y-@shiftBitmap.height
      addSprite("shiftButton",@shiftButton)
    else
      @msgBox = Window_AdvancedTextPokemon.newWithSize("",
         self.x+320,self.y,Graphics.width-320,Graphics.height-self.y,viewport)
      @msgBox.baseColor   = TEXT_BASE_COLOR
      @msgBox.shadowColor = TEXT_SHADOW_COLOR
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox",@msgBox)
      @cmdWindow = Window_CommandPokemon.newWithSize([],
         self.x,self.y,320,Graphics.height-self.y,viewport)
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow",@cmdWindow)
    end
    self.z = z
  end
  
  def dispose
    super
    @buttonBitmap.dispose  if @buttonBitmap
    @typeBitmap.dispose    if @typeBitmap
    @shiftBitmap.dispose   if @shiftBitmap
    @battleButtonBitmap.each { |k,bmp| bmp.dispose if bmp}
  end
  
  #-----------------------------------------------------------------------------
  # Updates the move name display.
  #-----------------------------------------------------------------------------
  def refreshButtonNames
    moves = (@battler) ? @battler.moves : []
    if !USE_GRAPHICS
      commands = []
      moves.each { |m| commands.push((m && m.id>0) ? m.short_name : "-") }
      @cmdWindow.commands = commands
      return
    end
    @overlay.bitmap.clear
    textPos = []
    moves.each_with_index do |m,i|
      button = @buttons[i]
      next if !@visibility["button_#{i}"]
      x = button.x-self.x+button.src_rect.width/2
      y = button.y-self.y+8
      moveNameBase = TEXT_BASE_COLOR
      if m.type>=0
        moveNameBase = button.bitmap.get_pixel(10,button.src_rect.y+34)
      end
      textPos.push([m.short_name,x,y,2,moveNameBase,TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap,textPos)
  end
  
  #-----------------------------------------------------------------------------
  # Displays appropriate button for battle mechanics.
  #-----------------------------------------------------------------------------
  def refreshBattleButton
    return if !USE_GRAPHICS
    if USE_GRAPHICS
      if @chosen_button != NoButton
        @battleButton.bitmap = @battleButtonBitmap[@chosen_button].bitmap
        @battleButton.x      = self.x+146
        @battleButton.y      = self.y-@battleButtonBitmap[@chosen_button].height/2
        @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height/2
        addSprite("battleButton",@battleButton)
      else 
        @chosen_button = NoButton
      end
    end
    if @battleButtonBitmap[@chosen_button]
      @battleButton.src_rect.y    = (@mode - 1) * @battleButtonBitmap[@chosen_button].height / 2
      @battleButton.z             = self.z - 1
      @visibility["battleButton"] = (@mode > 0)
    else 
      @visibility["battleButton"] = false
    end
  end
  
  def chosen_button=(value)
    oldValue = @chosen_button
    @chosen_button = value
    refresh if @chosen_button!=oldValue
  end
  
  def refresh
    return if !@battler
    refreshSelection
    refreshShiftButton
    refreshBattleButton
    refreshButtonNames
  end
end


################################################################################
# SECTION 3 - DATABOX DISPLAY
#===============================================================================
# Adds the Dynamax icon in a Pokemon's databox while it's dynamaxed.
#===============================================================================
class PokemonDataBox < SpriteWrapper
  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    textPos = []
    imagePos = []
    self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth-116 if nameWidth>116
    textPos.push([@battler.name,@spriteBaseX+8-nameOffset,6,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
    case @battler.displayGender
    when 0   # Male
      textPos.push([_INTL("♂"),@spriteBaseX+126,6,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
    when 1   # Female
      textPos.push([_INTL("♀"),@spriteBaseX+126,6,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
    end
    pbDrawTextPositions(self.bitmap,textPos)
    imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
    pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
    if @battler.shiny?
      shinyX = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
      imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
    end
    if @battler.mega?
      imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
    elsif @battler.primal?
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      if @battler.isSpecies?(:KYOGRE)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+primalX,4])
      elsif @battler.isSpecies?(:GROUDON)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+primalX,4])
      end
    #---------------------------------------------------------------------------
    # Draws Dynamax icon.
    #---------------------------------------------------------------------------
    elsif @battler.dynamax?
      imagePos.push(["Graphics/Pictures/Dynamax/icon_dynamax",@spriteBaseX+8,34])
    end
    #---------------------------------------------------------------------------
    if @battler.owned? && @battler.opposes?(0)
      imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
    end
    if @battler.status>0
      s = @battler.status
      s = 6 if s==PBStatuses::POISON && @battler.statusCount>0   # Badly poisoned
      imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,36,
         0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
    end
    pbDrawImagePositions(self.bitmap,imagePos)
    refreshHP
    refreshExp
  end
end