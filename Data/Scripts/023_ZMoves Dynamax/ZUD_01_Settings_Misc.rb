#===============================================================================
#
# Z-Moves, Ultra Burst, and Dynamax (ZUD)
#  For -Pokemon Essentials v18.1-
#
#===============================================================================
# The following adds the functionality for new battle mechanics found in the
# series starting with Gen 7 (Z-Moves, Ultra Burst) and Gen 8 (Dynamax). All
# three mechanics are present here and function together with existing mechanics
# such as Mega Evolution and Primal Reversion.
#
#===============================================================================
#
# ZUD_01: Settings and Misc.
#
#===============================================================================
# This script handles user settings that affect aspects of the rest of the plugin,
# and various items and Pokemon data required for a variety of gameplay aspects.
#
#===============================================================================
# SECTION 1 - CUSTOMIZATION
#-------------------------------------------------------------------------------
# This section handles all of the user settings for customizing certain ZUD
# mechanics to your liking. Anything you set here will be considered by the rest
# of the plugin.
#===============================================================================
# SECTION 2 - NEW ITEMS
#-------------------------------------------------------------------------------
# This section is simply for adding any new items required by ZUD mechanics,
# such as Z-Crystals and Dynamax Candy.
#===============================================================================
# SECTION 3 - POKEMON PROPERTIES
#-------------------------------------------------------------------------------
# This section introduces new Pokemon data required for certain ZUD mechanics, 
# such as Ultra Burst functions, and new functions for calculating Dynamax HP.
#===============================================================================
# SECTION 4 - MISCELLANEOUS
#-------------------------------------------------------------------------------
# This section contains new additions that don't fit anywhere else in the plugin,
# such as Ultra Necrozma forms, Max Moves in the summary, and Dynamax cries.
#===============================================================================
# SECTION 5 - PLUGIN MANAGER
#-------------------------------------------------------------------------------
# This section registers the ZUD plugin. 
#===============================================================================

################################################################################
# SECTION 1 - CUSTOMIZATION
#===============================================================================
# Settings
#===============================================================================
# Visual Settings
#-------------------------------------------------------------------------------
SHORTEN_MOVES  = true  # If true, shortens long names of Z-Moves/Max Moves in the fight menu. 
DYNAMAX_SIZE   = true  # If true, Pokemon's sprites will become enlarged while Dynamaxed.
DYNAMAX_COLOR  = true  # If true, applies a red overlay on the sprites of Dynamaxed Pokemon.
GMAX_XL_ICONS  = true  # Set as "true" ONLY when using the 256x128 icons for G-Max Pokemon.
DMAX_BUTTON_2  = false # Uses the modern (true) or classic (false) Dynamax Button style.
#-------------------------------------------------------------------------------
# Z-Move Settings
#-------------------------------------------------------------------------------
ADD_NEW_ZMOVES = true  # If true, gives Z-Move effects to Gen 8 status moves.
#-------------------------------------------------------------------------------
# Dynamax Settings
#-------------------------------------------------------------------------------
DMAX_ANYMAP    = true  # If true, allows Dynamax on any map location.
CAN_DMAX_WILD  = false # If true, allows Dynamax during normal wild encounters.
DYNAMAX_TURNS  = 3     # The number of turns Dynamax lasts before expiring.
#-------------------------------------------------------------------------------
# Switch Numbers
#-------------------------------------------------------------------------------
NO_Z_MOVE      = 85    # The switch number for disabling Z-Moves.
NO_ULTRA_BURST = 86    # The switch number for disabling Ultra Burst.
NO_DYNAMAX     = 87    # The switch number for disabling Dynamax.
#-------------------------------------------------------------------------------
# Item Arrays
#-------------------------------------------------------------------------------
# List of items that allow the use of Z-Moves/Ultra Burst or Dynamax.
#-------------------------------------------------------------------------------
Z_RINGS        = [:ZRING,:ZPOWERRING]
DMAX_BANDS     = [:DYNAMAXBAND]
#-------------------------------------------------------------------------------
# Map Arrays
#-------------------------------------------------------------------------------
# Map ID's where Dynamax (POWERSPOTS) and Eternamax (ETERNASPOT) are allowed.
#-------------------------------------------------------------------------------
POWERSPOTS     = [10,37,56,59,61,64]  # Pokemon Gyms, Pokemon League, Battle Facilities
ETERNASPOT     = []                   # None by default
#-------------------------------------------------------------------------------
# Species Arrays
#-------------------------------------------------------------------------------
# List of species unable to Dynamax.
#-------------------------------------------------------------------------------
DMAX_BANLIST   = [:ZACIAN,:ZAMAZENTA,:ETERNATUS]


################################################################################
# SECTION 2 - NEW ITEMS
#===============================================================================
# Defines Z-Crystals.
#===============================================================================
def pbIsZCrystal?(item)
  ret = pbGetItemData(item,ITEM_TYPE)
  return ret && ret==14
end

#===============================================================================
# Equipping holdable Z-Crystals from key item.
#===============================================================================
ItemHandlers::UseOnPokemon.add(:NORMALIUMZ,proc{|item,pokemon,scene|
  # Find the corresponding compatibility conditions
  zcomp = pbGetZMoveDataIfCompatible(pokemon,item)
  next false if !zcomp && !scene.pbConfirm(_INTL("This Pokémon currently can't use this crystal's Z-Power. Is that OK?"))
  scene.pbDisplay(_INTL("The {1} will be given to the Pokémon so that the Pokémon can use its Z-Power!",PBItems.getName(item)))
  if pokemon.item!=0
    itemname = PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding a {2}.\1",pokemon.name,itemname))
    if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
      if !$PokemonBag.pbStoreItem(pokemon.item)
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        next false
      else
        scene.pbDisplay(_INTL("You took the Pokémon's {1} and gave it the {2}.",itemname,PBItems.getName(item)))
      end
    else
      next false
    end
  end
  pokemon.setItem(item)
  scene.pbDisplay(_INTL("Your Pokémon is now holding {1}!",PBItems.getName(item)))
  next true
})

ItemHandlers::UseOnPokemon.copy(:NORMALIUMZ,  :FIRIUMZ,     :WATERIUMZ,  :ELECTRIUMZ,   :GRASSIUMZ,
                                :ICIUMZ,      :FIGHTINIUMZ, :POISONIUMZ, :GROUNDIUMZ,   :FLYINIUMZ,  
                                :PSYCHIUMZ,   :BUGINIUMZ,   :ROCKIUMZ,   :GHOSTIUMZ,    :DRAGONIUMZ,
                                :DARKINIUMZ,  :STEELIUMZ,   :FAIRIUMZ,   :ALORAICHIUMZ, :DECIDIUMZ,
                                :INCINIUMZ,   :PRIMARIUMZ,  :EEVIUMZ,    :PIKANIUMZ,    :SNORLIUMZ, 
                                :MEWNIUMZ,    :TAPUNIUMZ,   :MARSHADIUMZ,:PIKASHUNIUMZ, :KOMMONIUMZ,
                                :LYCANIUMZ,   :MIMIKIUMZ,   :LUNALIUMZ,  :SOLGANIUMZ,   :ULTRANECROZIUMZ,
                                :FOSSILIUMZ,  :SPINDIUMZ,   :HOOHIUMZ)
                                
#===============================================================================
# Dynamax items
#===============================================================================
# Max Honey - Fully revives a Pokemon.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.copy(:MAXREVIVE,:MAXHONEY)

#-------------------------------------------------------------------------------
# Max Mushrooms - Increases all stats by 1 stage.
#-------------------------------------------------------------------------------
ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS,proc { |item,battler,scene|
  showAnim=true
  battler.pokemon.changeHappiness("battleitem")
  for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
    if battler.pbCanRaiseStatStage?(i,battler)
      battler.pbRaiseStatStage(i,1,battler,showAnim)
      showAnim=false
    end
  end  
})

#-------------------------------------------------------------------------------
# Dynamax Candy - Increases the Dynamax Level of a Pokemon.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:DYNAMAXCANDY,proc { |item,pkmn,scene|
  if pkmn.dynamax_lvl>=10 || !pkmn.dynamaxAble? || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.addDynamaxLvl 
  pbSEPlay("Pkmn move learnt")
  scene.pbDisplay(_INTL("{1}'s Dynamax level was increased by 1!",pkmn.name))
  scene.pbHardRefresh
  next true
})


################################################################################
# SECTION 3 - POKEMON PROPERTIES
#===============================================================================
# Adds properties for Ultra Burst and Dynamax to Pokemon.
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor(:dynamax)
  attr_accessor(:reverted)
  attr_accessor(:dynamax_lvl)
  attr_accessor(:gmaxfactor)
  attr_accessor(:acepkmn)
  
  #-----------------------------------------------------------------------------
  # Ultra Burst
  #-----------------------------------------------------------------------------
  def hasUltra?
    v = MultipleForms.call("getUltraForm",self)
    return v!=nil
  end  

  def ultra?
    v = MultipleForms.call("getUltraForm",self)
    return v!=nil && v==@form
  end

  def makeUltra
    v = MultipleForms.call("getUltraForm",self)
    self.form = v if v!=nil
  end

  def makeUnUltra
    v = MultipleForms.call("getUnUltraForm",self)
    if v!=nil;     self.form = v
    elsif ultra?;  self.form = 0
    end
  end
  
  def ultraName
    v=MultipleForms.call("getUltraName",self)
    return v if v!=nil
    return ""
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax
  #-----------------------------------------------------------------------------
  def dynamaxAble?
    for i in DMAX_BANLIST
      return false if isSpecies?(i)
    end
    return true
  end

  def makeDynamax
    @dynamax = true
    @reverted = false
  end
  
  def makeUndynamax
    @dynamax = false
    @reverted = true
  end

  def dynamax?
    return @dynamax
  end
  
  def pbReversion(revert=false)
    @reverted = true if revert
    @reverted = false if !revert
  end
  
  def reverted?
    return @reverted
  end
  
  #-----------------------------------------------------------------------------
  # Gigantamax
  #-----------------------------------------------------------------------------
  def hasGmax?
    gmaxData = pbLoadGmaxData
    return true if isSpecies?(:ALCREMIE)
    return true if gmaxData[self.fSpecies]
  end
  
  def gmax?
    return true if (self.dynamax? && self.gmaxFactor? && self.hasGmax?)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax Levels
  #-----------------------------------------------------------------------------
  def dynamax_lvl
    return @dynamax_lvl || 0
  end
  
  def setDynamaxLvl(value)
    if !egg? && dynamaxAble?
      self.dynamax_lvl = value
    end
  end
  
  def addDynamaxLvl
    if !egg? && dynamaxAble?
      self.dynamax_lvl += 1
      self.dynamax_lvl  = 10 if self.dynamax_lvl>10
    end
  end
  
  def removeDynamaxLvl
    self.dynamax_lvl -= 1
    self.dynamax_lvl  = 0 if self.dynamax_lvl<0
  end
  
  #-----------------------------------------------------------------------------
  # Gigantamax Factor
  #-----------------------------------------------------------------------------
  def giveGMaxFactor
    @gmaxfactor = true
  end
  
  def removeGMaxFactor
    @gmaxfactor = false
  end
  
  def gmaxFactor?
    return true if @gmaxfactor 
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Trainer Ace
  #-----------------------------------------------------------------------------
  def trainerAce?
    return @acepkmn
  end
  
  def makeAcePkmn
    @acepkmn = true
  end
  
  def notAcePkmn  
    @acepkmn = false
  end
  
  #-----------------------------------------------------------------------------
  # Stat Calculations
  #-----------------------------------------------------------------------------
  def realhp;       return @hp/dynamaxBoost;      end
  def realtotalhp;  return @totalhp/dynamaxBoost; end
    
  def dynamaxCalc
    return (1.5+(dynamax_lvl*0.05))
  end
  
  def dynamaxBoost
    return dynamaxCalc if dynamax?
    return 1
  end
  
  def calcHP(base,level,iv,ev)
    return 1 if base==1   # For Shedinja
    return ((((base*2+iv+(ev>>2))*level/100).floor+level+10)*dynamaxBoost).ceil
  end
  
  def calcStats
    bs        = self.baseStats
    usedLevel = self.level
    usedIV    = self.calcIV
    pValues   = PBNatures.getStatChanges(self.calcNature)
    stats = []
    PBStats.eachStat do |s|
      if s==PBStats::HP
        stats[s] = calcHP(bs[s],usedLevel,usedIV[s],@ev[s])
      else
        stats[s] = calcStat(bs[s],usedLevel,usedIV[s],@ev[s],pValues[s])
      end
    end
    # Dynamax HP Calcs
    if dynamax? && !reverted? && @totalhp>1
      @totalhp = stats[PBStats::HP]
      @hp      = (@hp*dynamaxCalc).ceil
    elsif reverted? && !dynamax? && @totalhp>1
      @totalhp = stats[PBStats::HP]
      @hp      = (@hp/dynamaxCalc).round
      @hp     +=1 if !fainted? && @hp<=0
    else
      hpDiff   = @totalhp-@hp
      @totalhp = stats[PBStats::HP]
      @hp      = @totalhp-hpDiff
    end
    @hp      = 0 if @hp<0
    @hp      = @totalhp if @hp>@totalhp
    @attack  = stats[PBStats::ATTACK]
    @defense = stats[PBStats::DEFENSE]
    @spatk   = stats[PBStats::SPATK]
    @spdef   = stats[PBStats::SPDEF]
    @speed   = stats[PBStats::SPEED]
  end
  
  alias _ZUD_baseStats baseStats
  def baseStats
    v = MultipleForms.call("baseStats",self)
    return v if v!=nil
    return self._ZUD_baseStats
  end
  
  alias _ZUD_initialize initialize  
  def initialize(*args)
    _ZUD_initialize(*args)
    @dynamax_lvl = 0
    @dynamax     = false
    @reverted    = false
    @gmaxfactor  = false
    @acepkmn     = false
  end
end


################################################################################
# SECTION 4 - MISCELLANEOUS
#===============================================================================
# Sets up form data for Necrozma and Eternatus.
#===============================================================================

# Ultra Necrozma
MultipleForms.register(:NECROZMA,{
  "getUltraForm" => proc { |pkmn|
     next 3 if pkmn.hasItem?(:ULTRANECROZIUMZ) && pkmn.form==1
     next 4 if pkmn.hasItem?(:ULTRANECROZIUMZ) && pkmn.form==2
     next
  },
  "getUltraName" => proc { |pkmn|
     next _INTL("Ultra Necrozma") if pkmn.form>2
     next
  },
  "getUnUltraForm" => proc { |pkmn|
     next pkmn.form-=2 if pkmn.form>2
     next
  },
  "onSetForm" => proc { |pkmn,form,oldForm|
     pbSeenForm(pkmn)
     moves=[
        :CONFUSION,       # Normal
        :SUNSTEELSTRIKE,  # Dusk Mane
        :MOONGEISTBEAM,   # Dawn Wings
     ]
     if form<3
       moves.each{|move|
          pkmn.pbDeleteMove(getID(PBMoves,move))
       }
       pkmn.pbLearnMove(moves[form])
     end
  }
})

# Eternamax Eternatus
MultipleForms.register(:ETERNATUS,{
  "baseStats"=>proc{|pokemon|
    next if !(pokemon.isSpecies?(:ETERNATUS) && pokemon.gmax?)
    next [255,115,250,130,125,250]
  },
  "onSetForm"=>proc{|pokemon,form,oldForm|
    pbSeenForm(pokemon)
  }
})

# Reverts Ultra Burst after battle.
alias _ZUD_pbAfterBattle pbAfterBattle
def pbAfterBattle(decision,canLose)
  $Trainer.party.each do |pkmn|
    pkmn.makeUnUltra
  end
  if $PokemonGlobal.partner
    pbHealAll
    $PokemonGlobal.partner[3].each do |pkmn|
      pkmn.heal
      pkmn.makeUnmega
      pkmn.makeUnprimal
      pkmn.makeUnUltra
    end
  end
  if $PokemonGlobal.partner2
    pbHealAll
    $PokemonGlobal.partner2[3].each do |pkmn|
      pkmn.heal
      pkmn.makeUnmega
      pkmn.makeUnprimal
      pkmn.makeUnUltra
    end
  end
  _ZUD_pbAfterBattle(decision, canLose)
end

#===============================================================================
# Displays Dynamax information in a Pokemon's summary.
#===============================================================================
class PokemonSummary_Scene
  #-----------------------------------------------------------------------------
  # Displays Gigantamax Factor in the summary.
  # Must be added to def drawPage in PScreen_Summary.
  #-----------------------------------------------------------------------------
  def pbDisplayGMaxFactor
    if @pokemon.gmaxFactor? && @pokemon.dynamaxAble?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push(["Graphics/Pictures/Dynamax/gfactor",88,95,0,0,-1,-1])
      pbDrawImagePositions(overlay,imagepos)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Displays Dynamax Levels in the summary.
  # Must be added to def drawPage in PScreen_Summary.
  #-----------------------------------------------------------------------------
  def pbDisplayDynamaxMeter
    if @page==3 && @pokemon.dynamaxAble?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push(["Graphics/Pictures/Dynamax/dynamax_meter",56,308,0,0,-1,-1])
      pbDrawImagePositions(overlay,imagepos)
      dlevel=@pokemon.dynamax_lvl
      levels=AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/dynamax_levels"))
      overlay.blt(69,325,levels.bitmap,Rect.new(0,0,dlevel*12,21))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Displays Max Move names and type in the summary.
  # Must be added to def drawMoveSelection.
  #-----------------------------------------------------------------------------
  def drawMaxMoveSel(move,yPos,moveBase,moveShadow,moveToLearn)
    movetype = pbGetMoveData(move.id,MOVE_TYPE)
    category = pbGetMoveData(move.id,MOVE_CATEGORY)
    gmaxmove = pbGetGMaxMoveFromSpecies(@pokemon,movetype)
    if @pokemon.dynamax? && moveToLearn==0
      if category==2
        image = ["Graphics/Pictures/types",248,yPos+2,0,0,64,28]
        text  = [PBMoves.getName(:MAXGUARD),316,yPos,0,moveBase,moveShadow]
      else
        image = ["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28]
        if @pokemon.gmaxFactor? && gmaxmove
          text = [PBMoves.getName(gmaxmove),316,yPos,0,moveBase,moveShadow]
        else  
          text = [PBMoves.getName(pbGetMaxMove(movetype)),316,yPos,0,moveBase,moveShadow]
        end
      end
    else  
      image = ["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28]
      text  = [PBMoves.getName(move.id),316,yPos,0,moveBase,moveShadow]
    end
    return [image,text]
  end
  
  #-----------------------------------------------------------------------------
  # Displays Max Move data in the summary.
  # Must be added to def drawSelectedMove.
  #-----------------------------------------------------------------------------
  def pbGetMaxMoveData(moveToLearn,moveid)
    if @pokemon.dynamax? && moveToLearn==0
      movetype = pbGetMoveData(moveid,MOVE_TYPE)
      category = pbGetMoveData(moveid,MOVE_CATEGORY)
      gmaxmove = pbGetGMaxMoveFromSpecies(@pokemon,movetype)
      if category==2
        maxMoveID = getID(PBMoves,:MAXGUARD)
      else
        if @pokemon.gmaxFactor? && gmaxmove
          maxMoveID = getID(PBMoves,gmaxmove)
        else
          maxMoveID = getID(PBMoves,(pbGetMaxMove(movetype)))
        end
      end
      basedamage = pbMaxMoveBaseDamage(moveid,maxMoveID)
      basedamage = 0 if maxMoveID==getID(PBMoves,:MAXGUARD)
      accuracy   = 0
      moveid     = maxMoveID
      return [basedamage,accuracy,moveid]
    end
  end
end

#-------------------------------------------------------------------------------
# Checks for G-Max forms of a species.
#-------------------------------------------------------------------------------
def pbGmaxSpecies?(species,form)
  gmaxData = pbLoadGmaxData
  fSpecies = pbGetFSpeciesFromForm(species,form)
  return true if species==getID(PBSpecies,:ALCREMIE)
  return true if gmaxData[fSpecies]
end

#-------------------------------------------------------------------------------
# Plays the Dynamax cry of a species.
#-------------------------------------------------------------------------------
def pbPlayDynamaxCry(species,form)
  pkmn = getID(PBSpecies,species)
  pbPlayCrySpecies(pkmn,form,100,60)
end

################################################################################
# SECTION 5 - COMPATIBILITY
#===============================================================================
# Compatibility with Mid Battle Dialogue.
#-------------------------------------------------------------------------------
module TrainerDialogue
  def self.setInstance(parameter)
    noIncrement = ["lowHP","lowHPOpp","halfHP","halfHPOpp","bigDamage","bigDamageOpp","smlDamage",
      "smlDamageOpp","attack","attackOpp","superEff","superEffOpp","notEff","notEffOpp",
      "maxMove", "maxMoveOpp", "zmove", "zmoveOpp", "dynamaxBefore", "dynamaxBeforeOpp", 
      "dynamaxAfter", "dynamaxAfterOpp", "gmaxBefore", "gmaxBeforeOpp", "gmaxAfter", "gmaxAfterOpp"]
    return if parameter.include?("rand")
    if !noIncrement.include?(parameter)
       $PokemonTemp.dialogueInstances[parameter] += 1
    end
  end
end

#-------------------------------------------------------------------------------
# Registers the ZUD plugin.
#-------------------------------------------------------------------------------
PluginManager.register({
  :name => "ZUD plugin",
  :version => "1.0",
  :credits => ["Lucidious89", "StCooler"]
})