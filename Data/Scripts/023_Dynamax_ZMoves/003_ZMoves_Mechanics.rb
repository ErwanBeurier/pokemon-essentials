################################################################################
# SECTION 1 - SETTINGS
################################################################################
# Switch Numbers + List of Z-Rings.
#===============================================================================
NO_Z_MOVE            = 35    # Switch for disabling Z-Moves.
NO_ULTRA_BURST       = 36    # Switch for disabling Ultra Burst.
INCLUDE_NEWEST_MOVES = true  # Gives Z-Move effects to Gen 8 status moves.
Z_RINGS              = [:ZRING, :ZPOWERRING]

################################################################################
# SECTION 2 - EFFECTS
################################################################################
# New effects for Z-Moves.
#===============================================================================
module PBEffects
  # These effects apply to a battler
  UnZMoves = 300 # Records a Pokemon's base moves before using Z-moves.
  UsedZMoveIndex = 301 # Records the index of the used Z-move. 
  ZMoveButton = 302 
  
  # These effects apply to a battler position
  ZHeal = 100 # Z-parting shot / Z-memento (weaker form of Lunar Dance/Healing Wish)
end

class PokeBattle_ActiveSide
  alias zmove_initialize initialize  
  def initialize
    zmove_initialize
    @effects[PBEffects::ZHeal] = false
  end
end

class PokeBattle_Battler
  alias zmove_pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    zmove_pbInitEffects(batonpass)
    @effects[PBEffects::UnZMoves]      = nil
    @effects[PBEffects::UsedZMoveIndex] = -1
  end
end 

################################################################################
# SECTION 3 - Z-CRYSTAL ITEMS
################################################################################
# Defines Z-Crystals.
#===============================================================================
def pbIsZCrystal?(item)
  ret = pbGetItemData(item,ITEM_TYPE)
  return ret && ret==13
end

def pbIsZCrystal2?(item)
  ret = pbGetItemData(item,ITEM_TYPE)
  return ret && ret==14
end

def pbIsImportantItem?(item)
  itemData = pbLoadItemsData[getID(PBItems,item)]
  return false if !itemData
  return true if itemData[ITEM_TYPE] && itemData[ITEM_TYPE]==6
  return true if itemData[ITEM_TYPE] && itemData[ITEM_TYPE]==14  # Key item representing Z-Crystals.
  return true if itemData[ITEM_FIELD_USE] && itemData[ITEM_FIELD_USE]==4
  return true if itemData[ITEM_FIELD_USE] && itemData[ITEM_FIELD_USE]==3 && INFINITE_TMS
  return false
end

#===============================================================================
# Equipping holdable Z-Crystals from key item.
#===============================================================================
ItemHandlers::UseOnPokemon.add(:BUGINIUMZ,proc{|item,pokemon,scene|
  # Find the corresponding compatibility conditions 
  zcomp = pbGetZMoveDataIfCompatible(pokemon,item)
  if zcomp
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(zcomp[PBZMove::HELD_ZCRYSTAL])
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          next true
        end
      end
    else
      pokemon.setItem(zcomp[PBZMove::HELD_ZCRYSTAL])
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      next true      
    end
  else       
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.copy(:BUGINIUMZ,:DARKINIUMZ,:DRAGONIUMZ,:ELECTRIUMZ,:FAIRIUMZ, 
                                :FIGHTINIUMZ,:FIRIUMZ,:FLYINIUMZ,:GHOSTIUMZ,:GRASSIUMZ, 
                                :GROUNDIUMZ,:ICIUMZ,:NORMALIUMZ,:POISONIUMZ,:PSYCHIUMZ, 
                                :ROCKIUMZ,:STEELIUMZ,:WATERIUMZ,:ALORAICHIUMZ,:DECIDIUMZ, 
                                :INCINIUMZ,:PRIMARIUMZ,:EEVIUMZ,:PIKANIUMZ,:SNORLIUMZ, 
                                :MEWNIUMZ,:TAPUNIUMZ,:MARSHADIUMZ,:PIKASHUNIUMZ,:KOMMONIUMZ,
                                :LYCANIUMZ,:MIMIKIUMZ,:LUNALIUMZ,:SOLGANIUMZ,:ULTRANECROZIUMZ)

#-------------------------------------------------------------------------------
# Held Z-Crystals don't return to bag when removed.
#-------------------------------------------------------------------------------                               
class PokemonBag
  def pbStoreItem(item,qty=1)
    item = getID(PBItems,item)
    if pbIsZCrystal?(item)
      return true
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("Item number {1} is invalid.",item))
    end
    pocket = pbGetPocket(item)
    maxsize = maxPocketSize(pocket)
    maxsize = @pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreItem(@pockets[pocket],maxsize,
                                         BAG_MAX_PER_SLOT,item,qty,true)
  end
end


################################################################################
# SECTION 4 - TRIGGERING Z-MOVES
################################################################################
# Battle Calls
#===============================================================================
class PokeBattle_Battler
  def ultra?;    return @pokemon && @pokemon.ultra?;    end
  def hasUltra?; return @pokemon && @pokemon.hasUltra?; end

  def hasZMove?
    zmovedata = pbGetZMoveDataIfCompatible(self.pokemon, self.item)
    return zmovedata != nil 
  end

  def pbCompatibleZMoveFromMove?(move)
    return true if move.is_a?(PokeBattle_ZMove)
    zmovedata = pbGetZMoveDataIfCompatible(self.pokemon, self.item, move)
    return zmovedata != nil 
  end
  
  def pbCompatibleZMoveFromIndex?(moveindex)
    return pbCompatibleZMoveFromMove?(self.moves[moveindex])
  end
  
  def pbZCrystalFromType(type)
    zmovecomps = pbLoadZMoveCompatibility
    zmovecomps["order"].each { |comp|
      next if !comp[PBZMove::REQ_TYPE]
      next if comp[PBZMove::REQ_TYPE] != type
      return comp[PBZMove::HELD_ZCRYSTAL]
    }
    return nil 
  end
  
  def pbZMoveFromType(type)
    zmovecomps = pbLoadZMoveCompatibility
    zmovecomps["order"].each { |comp|
      next if !comp[PBZMove::REQ_TYPE]
      next if comp[PBZMove::REQ_TYPE] != type
      return comp[PBZMove::ZMOVE]
    }
    return nil 
  end
  
  def unlosableItem?(check_item)
    return false if check_item <= 0
    return true if pbIsMail?(check_item)
    return true if pbIsZCrystal?(check_item)
    return false if @effects[PBEffects::Transform]
    return true if @pokemon && @pokemon.getMegaForm(true) > 0
    return pbIsUnlosableItem?(check_item, @species, @ability)
  end 
  
  #-----------------------------------------------------------------------------
  # Displaying Z-moves/normal moves.
  #-----------------------------------------------------------------------------
  def pbZDisplayZMoves
    oldmoves = [@moves[0],@moves[1],@moves[2],@moves[3]]
    if !@effects[PBEffects::UnZMoves]
      @effects[PBEffects::UnZMoves] = oldmoves
    end
    for i in 0...4
      next if !@moves[i] || @moves[i].id == 0
      comp = pbGetZMoveDataIfCompatible(self.pokemon, self.item, @moves[i])
      next if !comp
      @moves[i] = PokeBattle_ZMove.pbFromOldMoveAndCrystal(@battle, self, @moves[i], self.item)
      @moves[i].pp = 1
      @moves[i].totalpp = 1
    end 
  end 
  
  def pbZDisplayOldMoves
    oldmoves = @pokemon.moves
    # Gets a transformed Pokemon's copied moves from before the Z-move.
    oldmoves = @effects[PBEffects::UnZMoves] if @effects[PBEffects::Transform] 
    @moves  = [
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[0]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[1]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[2]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[3])
    ]
    for i in 0...4
      next if !@moves[i] || @moves[i].id == 0
      @moves[i].pp      -= 1 if i == @effects[PBEffects::UsedZMoveIndex]
    end
  end 
  
  #-----------------------------------------------------------------------------
  # Handles the actual use of Z-Moves.
  #-----------------------------------------------------------------------------
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
    if choice[2].zmove 
      # Use Z-Moves 
      choice[2].zmove=false
      @battle.pbUseZMove(self.index,choice[2],self.item)
      pbZDisplayOldMoves
    else
      # Use the move
      PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
      PBDebug.logonerr{
        pbUseMove(choice,choice[2]==@battle.struggle)
      }
    end
    @battle.pbJudge
    return true
  end
  
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
    if @battle.zMove[side][owner]==self.index
      crystal = pbZCrystalFromType(choice[2].type)
      zmove = PokeBattle_ZMove.pbFromOldMoveAndCrystal(@battle,self,choice[2],crystal)
      zmove.pbUse(self, choice, specialUsage)
    else
      pbUseMove(choice,specialUsage)
    end
  end
end

#===============================================================================
# Decide whether the opponent should use a Z-Move or Ultra Burst.
#===============================================================================
class PokeBattle_AI
  def pbEnemyShouldUltraBurst?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanUltraBurst?(idxBattler)   # Simple "always should if possible"
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Ultra Burst")
      return true
    end
    return false
  end
  
  def pbEnemyShouldZMove?(index)
    # If all opposing have less than half HP, then don't Z-Move.
    return false if !@battle.pbCanZMove?(index) #Conditions based on effectiveness and type handled later  
    @battle.battlers[index].eachOpposing { |opp|
      return true if opp.hp>(opp.totalhp/2).round
    }
    return false 
  end

  def pbChooseEnemyZMove(index)  #Put specific cases for trainers using status Z-Moves
    # Choose the move.
    chosenmove=false
    chosenindex=-1
    attacker = @battle.battlers[index]
    for i in 0..3
      move=attacker.moves[i]
      if attacker.pbCompatibleZMoveFromMove?(move)
        if !chosenmove
          chosenindex = i
          chosenmove=move
        else
          if move.baseDamage>chosenmove.baseDamage
            chosenindex=i
            chosenmove=move
          end          
        end
      end
    end   
    target_i = nil
    target_eff = 0 
    # Choose the target
    attacker.eachOpposing { |opp|
      temp_eff = chosenmove.pbCalcTypeMod(chosenmove.type,attacker,opp)        
      if temp_eff > target_eff
        target_i = opp.index
        target_eff = target_eff
      end 
    }
    @battle.pbRegisterZMove(index)
    @battle.pbRegisterMove(index,chosenindex,false)
    @battle.pbRegisterTarget(index,target_i)
  end
end

#===============================================================================
# Triggering Z-Mechanics in battle.
#===============================================================================
class PokeBattle_Battle
  attr_accessor :zMove

  alias zmove_initialize initialize
  def initialize(scene,p1,p2,player,opponent)
    zmove_initialize(scene,p1,p2,player,opponent)
    @zMove             = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @ultraBurst        = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
  end
  
  #-----------------------------------------------------------------------------
  # Checks if the user is capable of using a Z-Move.
  #-----------------------------------------------------------------------------
  def pbHasZRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)   # Assume AI trainer have a ring
    Z_RINGS.each do |item|
      return true if hasConst?(PBItems,item) && $PokemonBag.pbHasItem?(item)
    end
    return false
  end
  
  def pbCanZMove?(idxBattler)
    battler = @battlers[idxBattler]
    side    = battler.idxOwnSide
    owner   = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_Z_MOVE]
    return false if !pbHasZRing?(idxBattler)
    return false if !battler.hasZMove?
    # return false if battler.mega? || battler.hasMega?
    return false if battler.primal? || battler.hasPrimal?
    return false if battler.hasUltra?
    return false if battler.shadowPokemon?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if battler.effects[PBEffects::SkyDrop]>=0
    return @zMove[side][owner]==-1
  end

  
  #-----------------------------------------------------------------------------
  # Registering the use of a Z-Move.
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
  # Uses the eligible Z-Move.
  #-----------------------------------------------------------------------------
  def pbUseZMove(idxBattler,move,crystal)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasZMove?
    pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",battler.pbThis))      
    pbCommonAnimation("ZPower",battler,nil)
    zmove = PokeBattle_ZMove.pbFromOldMoveAndCrystal(self,battler,move,crystal)
    zmove.pbUse(battler, nil, false)
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @zMove[side][owner] = -2
  end
  
  def pbAttackPhaseZMoves
    pbPriority.each do |b|
      idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @zMove[b.idxOwnSide][owner]!=b.index
      @choices[b.index][2].zmove=true
    end
  end
  
  
################################################################################
# SECTION 5 - ULTRA BURST
################################################################################
# Checks if the user is capable of using Ultra Burst.
#===============================================================================
  def pbCanUltraBurst?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_ULTRA_BURST]
    return false if !pbHasZRing?(idxBattler)
    return false if !battler.hasUltra?
    return false if battler.mega? || battler.hasMega?
    return false if battler.primal? || battler.hasPrimal?
    return false if battler.shadowPokemon?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if battler.effects[PBEffects::SkyDrop]>=0
    return false if @ultraBurst[side][owner]!=-1
    return @ultraBurst[side][owner]==-1
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
  # Ultra Bursts the user.
  #-----------------------------------------------------------------------------
  def pbUltraBurst(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasUltra? || battler.ultra?
    pbDisplay(_INTL("Bright light is about to burst out of {1}!",battler.pbThis))    
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
  
  def pbAttackPhaseUltraBurst
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @ultraBurst[b.idxOwnSide][owner]!= b.index
      pbUltraBurst(b.index)
    end
  end
end

#===============================================================================
# Ultra Necrozma
#===============================================================================
MultipleForms.register(:NECROZMA,{
"getUltraForm"=>proc{|pokemon|
   next 3 if isConst?(pokemon.item,PBItems,:ULTRANECROZIUMZ2) && pokemon.form==1
   next 4 if isConst?(pokemon.item,PBItems,:ULTRANECROZIUMZ2) && pokemon.form==2
   next
},
"getUltraName"=>proc{|pokemon|
   next _INTL("Ultra Necrozma") if pokemon.form==3
   next _INTL("Ultra Necrozma") if pokemon.form==4
   next
},
"getUnUltraForm"=>proc{|pokemon|
   next pokemon.form-=2 if pokemon.form>2
   next
},
"onSetForm"=>proc{|pokemon,form,oldForm|
   pbSeenForm(pokemon)
   moves=[
      :CONFUSION,       # Normal
      :SUNSTEELSTRIKE,  # Dusk Mane
      :MOONGEISTBEAM,   # Dawn Wings
   ]
   if form<3
     moves.each{|move|
        pokemon.pbDeleteMove(getID(PBMoves,move))
     }
     pokemon.pbLearnMove(moves[form])
   end
}
})

class PokeBattle_Pokemon
  def hasUltra?
    v=MultipleForms.call("getUltraForm",self)
    return v!=nil
  end  

  def ultra?
    v=MultipleForms.call("getUltraForm",self)
    return v!=nil && v==@form
  end

  def makeUltra
    v=MultipleForms.call("getUltraForm",self)
    if v!=nil
      @startform=self.form
      self.form=v 
    end
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

  def formNoCall=(value)
    @form=value
    self.calcStats
  end
end

def pbAfterBattle(decision,canLose)
  $Trainer.party.each do |pkmn|
    pkmn.statusCount = 0 if pkmn.status==PBStatuses::POISON   # Bad poison becomes regular
    pkmn.makeUnmega
    pkmn.makeUnprimal
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
  if decision==2 || decision==5   # if loss or draw
    if canLose
      $Trainer.party.each { |pkmn| pkmn.heal }
      (Graphics.frame_rate/4).times { Graphics.update }
    end
  end
  Events.onEndBattle.trigger(nil,decision,canLose)
end


################################################################################
# SECTION 6 - Z-MOVES
################################################################################
# Z-Moves
#===============================================================================
class PokeBattle_Move
  attr_accessor :name
  attr_accessor :zmove    # True if the player triggered the Z-Move
  attr_accessor :is_zmove # True only if the move is an actual Z-Move.

  def to_int; return @id; end

  alias zmove_initialize initialize
  def initialize(battle,move)
    zmove_initialize(battle,move)
    @zmove      = false
    @is_zmove   = false
  end
end

class PokeBattle_ZMove < PokeBattle_Move
  attr_reader(:thismove)
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)

  def initialize(battle,move,pbmove)
    # move is the old move; instance of PokeBattle_Move
    # pbmove is the PBMove of the new move.
    super(battle, pbmove)
    @status     = !(move.physicalMove?(move.type) || move.specialMove?(move.type))
    @category   = move.category
    @oldmove    = move
    @oldname    = move.name
    @is_zmove   = true 
    if @status 
      @name     = "Z-" + move.name
    end 
    @baseDamage = pbZMoveBaseDamage(move)
    @thismove   = self
  end
  
  def pbZMoveBaseDamage(oldmove)
    if @status
      # Status moves remain status. 
      return 0
    elsif @baseDamage != 1
      # Then the base damage is given in the moves.txt PBS file. 
      return @baseDamage
    end 
    
    # Specific values for specific moves: 
    case @oldmove.id
    when getID(PBMoves,:MEGADRAIN)
      return 120
    when getID(PBMoves,:WEATHERBALL)  
      return 160
    when getID(PBMoves,:HEX)
      return 160
    when getID(PBMoves,:GEARGRIND)  
      return 180
    when getID(PBMoves,:VCREATE)  
      return 220
    when getID(PBMoves,:FLYINGPRESS)
      return 170
    when getID(PBMoves,:COREENFORCER)
      return 140
    end 
    
    # This is for non-specific moves. 
    check=@oldmove.baseDamage
    if check<56
      return 100
    elsif check<66
      return 120
    elsif check<76
      return 140
    elsif check<86
      return 160
    elsif check<96
      return 175
    elsif check<101
      return 180
    elsif check<111
      return 185
    elsif check<126
      return 190
    elsif check<131
      return 195
    elsif check>139
      return 200
    end
  end
  
  def pbUse(battler, simplechoice=nil, specialUsage=false)
    battler.pbBeginTurn(self)
    if !@status
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
    end    
    zchoice=@battle.choices[battler.index] #[0,0,move,move.target]
    if simplechoice
      zchoice=simplechoice
    end    
    ztargets=battler.pbFindTargets(zchoice,self,battler)
    if ztargets.length==0
      if @target==PBTargets::NearOther ||
         @target==PBTargets::RandomNearFoe ||
         @target==PBTargets::AllNearFoes ||
         @target==PBTargets::AllNearOthers ||
         @target==PBTargets::NearAlly ||
         @target==PBTargets::UserOrNearAlly ||
         @target==PBTargets::NearFoe ||
         @target==PBTargets::UserAndAllies 
        @battle.pbDisplay(_INTL("But there was no target..."))
      else
        #selftarget status moves here
        pbZStatus(@oldmove.id,battler) if !specialUsage
        # zchoice[2].name = @name
        zchoice[2] = @oldmove
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      end      
    else
      if @status
        #targeted status Z's here
        pbZStatus(@oldmove.id,battler) if !specialUsage
        zchoice[2] = @oldmove
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      else
        zchoice[2] = self
        battler.pbUseMove(zchoice)
        battler.pbReducePPOther(@oldmove)
      end
    end
  end 
  
  def PokeBattle_ZMove.pbFromOldMoveAndCrystal(battle,battler,move,crystal)
    return move if move.is_a?(PokeBattle_ZMove)
    # Load the Z-move data
    zmovedata = pbGetZMoveDataIfCompatible(battler.pokemon, crystal, move)
    pbmove = nil
    if !zmovedata
      # We assume that the Z-Move is called only if it is valid. 
      # If zmovedata is empty, then it is a status move.
      # Z-status move keep the same effect. 
      pbmove = PBMove.new(move.id)
      pbmove.pp = 1 
      return PokeBattle_ZMove.new(battle,move,pbmove)
    end 
    
    z_move_id = zmovedata[PBZMove::ZMOVE]
    
    # The following moves need to adapt their Z-move to their actual type: 
    moves_to_check = [PBMoves::WEATHERBALL, PBMoves::TERRAINPULSE]
    if crystal == PBItems::NORMALIUMZ2 && moves_to_check.include?(move.id)
      new_type = move.pbBaseType(battler)
      z_move_id = battler.pbZMoveFromType(new_type)
    end 
    
    pbmove = PBMove.new(z_move_id)
    moveFunction = pbGetMoveData(pbmove.id,MOVE_FUNCTION_CODE) || "Z000"
    className = sprintf("PokeBattle_Move_%s",moveFunction)
    
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle,move,pbmove)
    end
    return PokeBattle_ZMove.new(battle,move,pbmove)
  end
  
  # Redefining this method so that damaging Z-moves do not trigger type-changing 
  # abilities. However Z-moves are affected by Ion Deluge / Electrify; this is 
  # handled in pbCalcType, which is left unchanged. 
  def pbBaseType(user)
    return @type if !@status
    return super(user)
  end
  

#===============================================================================
# PokeBattle_Move Features needed for move use
#===============================================================================
  def specialMove?(type=nil)
    return @oldmove.specialMove?(type)
  end
  
  def physicalMove?(type=nil)  
    return @oldmove.physicalMove?(type)
  end  
  
  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::QuickGuard] || 
        opponent.effects[PBEffects::Protect] || 
        opponent.effects[PBEffects::Obstruct] ||
        opponent.effects[PBEffects::KingsShield] ||
        opponent.effects[PBEffects::SpikyShield] ||
        opponent.effects[PBEffects::BanefulBunker] ||
        opponent.effects[PBEffects::MatBlock]
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",opponent.pbThis))
      return damagemult/4
    else      
      return damagemult
    end    
  end    
  
#===============================================================================
# Z-Status Effect check
#=============================================================================== 
  def pbZStatus(move,attacker)
    cause = "Z-Power"
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Attack.
    #---------------------------------------------------------------------------
    atk1   = [:BULKUP,:HONECLAWS,:HOWL,:LASERFOCUS,:LEER,:MEDITATE,:ODORSLEUTH,
              :POWERTRICK,:ROTOTILLER,:SCREECH,:SHARPEN,:TAILWHIP,:TAUNT,:TOPSYTURVY,
              :WILLOWISP,:WORKUP]
    atk2   = [:MIRRORMOVE]
    atk3   = [:SPLASH]
    if INCLUDE_NEWEST_MOVES
      atk1 += [:COACHING]
    end
    atkID1 = []; atkID2 = []; atkID3 = []
    for i in atk1; atkID1.push(getID(PBMoves,i)); end
    for i in atk2; atkID2.push(getID(PBMoves,i)); end
    for i in atk3; atkID3.push(getID(PBMoves,i)); end
    # Z-Curse raises Attack if user is a non-Ghost.
    if move==getID(PBMoves,:CURSE) && !attacker.pbHasType?(:GHOST)
      atkID1.push(move)
    end
    atkStage = 1 if atkID1.include?(move)
    atkStage = 2 if atkID2.include?(move)
    atkStage = 3 if atkID3.include?(move)
    if atkStage
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::ATTACK,atkStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Defense.
    #---------------------------------------------------------------------------
    def1   = [:AQUARING,:BABYDOLLEYES,:BANEFULBUNKER,:BLOCK,:CHARM,:DEFENDORDER,
              :FAIRYLOCK,:FEATHERDANCE,:FLOWERSHIELD,:GRASSYTERRAIN,:GROWL,:HARDEN,
              :MATBLOCK,:NOBLEROAR,:PAINSPLIT,:PLAYNICE,:POISONGAS,:POISONPOWDER,
              :QUICKGUARD,:REFLECT,:ROAR,:SPIDERWEB,:SPIKES,:SPIKYSHIELD,:STEALTHROCK,
              :STRENGTHSAP,:TEARFULLOOK,:TICKLE,:TORMENT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,
              :WIDEGUARD,:WITHDRAW]
    def2   = []
    def3   = []
    if INCLUDE_NEWEST_MOVES
      def1 += [:OCTOLOCK]
    end
    defID1 = []; defID2 = []; defID3 = []
    for i in def1; defID1.push(getID(PBMoves,i)); end
    for i in def2; defID2.push(getID(PBMoves,i)); end
    for i in def3; defID3.push(getID(PBMoves,i)); end
    defStage = 1 if defID1.include?(move)
    defStage = 2 if defID2.include?(move)
    defStage = 3 if defID3.include?(move)
    if defStage
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::DEFENSE,defStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Sp.Atk.
    #---------------------------------------------------------------------------
    spatk1 = [:CONFUSERAY,:ELECTRIFY,:EMBARGO,:FAKETEARS,:GEARUP,:GRAVITY,:GROWTH,
              :INSTRUCT,:IONDELUGE,:METALSOUND,:MINDREADER,:MIRACLEEYE,:NIGHTMARE,
              :PSYCHICTERRAIN,:REFLECTTYPE,:SIMPLEBEAM,:SOAK,:SWEETKISS,:TEETERDANCE,
              :TELEKINESIS]
    spatk2 = [:HEALBLOCK,:PSYCHOSHIFT]
    spatk3 = []
    if INCLUDE_NEWEST_MOVES
      spatk1 += [:MAGICPOWDER]
    end
    spatkID1 = []; spatkID2 = []; spatkID3 = []
    for i in spatk1; spatkID1.push(getID(PBMoves,i)); end
    for i in spatk2; spatkID2.push(getID(PBMoves,i)); end
    for i in spatk3; spatkID3.push(getID(PBMoves,i)); end
    spatkStage = 1 if spatkID1.include?(move)
    spatkStage = 2 if spatkID2.include?(move)
    spatkStage = 3 if spatkID3.include?(move)
    if spatkStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::SPATK,spatkStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Sp.Def.
    #---------------------------------------------------------------------------
    spdef1 = [:CHARGE,:CONFIDE,:COSMICPOWER,:CRAFTYSHIELD,:EERIEIMPULSE,:ENTRAINMENT,
              :FLATTER,:GLARE,:INGRAIN,:LIGHTSCREEN,:MAGICROOM,:MAGNETICFLUX,:MEANLOOK,
              :MISTYTERRAIN,:MUDSPORT,:SPOTLIGHT,:STUNSPORE,:THUNDERWAVE,:WATERSPORT,
              :WHIRLWIND,:WISH,:WONDERROOM]
    spdef2 = [:AROMATICMIST,:CAPTIVATE,:IMPRISON,:MAGICCOAT,:POWDER]
    spdef3 = []
    if INCLUDE_NEWEST_MOVES
      spdef1 += [:CORROSIVEGAS,:DECORATE]
    end
    spdefID1 = []; spdefID2 = []; spdefID3 = []
    for i in spdef1; spdefID1.push(getID(PBMoves,i)); end
    for i in spdef2; spdefID2.push(getID(PBMoves,i)); end
    for i in spdef3; spdefID3.push(getID(PBMoves,i)); end
    spdefStage = 1 if spdefID1.include?(move)
    spdefStage = 2 if spdefID2.include?(move)
    spdefStage = 3 if spdefID3.include?(move)
    if spdefStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::SPDEF,spdefStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Speed.
    #---------------------------------------------------------------------------
    speed1 = [:AFTERYOU,:AURORAVEIL,:ELECTRICTERRAIN,:ENCORE,:GASTROACID,:GRASSWHISTLE,
              :GUARDSPLIT,:GUARDSWAP,:HAIL,:HYPNOSIS,:LOCKON,:LOVELYKISS,:POWERSPLIT,
              :POWERSWAP,:QUASH,:RAINDANCE,:ROLEPLAY,:SAFEGUARD,:SANDSTORM,:SCARYFACE,
              :SING,:SKILLSWAP,:SLEEPPOWDER,:SPEEDSWAP,:STICKYWEB,:STRINGSHOT,:SUNNYDAY,
              :SUPERSONIC,:TOXICTHREAD,:WORRYSEED,:YAWN]
    speed2 = [:ALLYSWITCH,:BESTOW,:MEFIRST,:RECYCLE,:SNATCH,:SWITCHEROO,:TRICK]
    speed3 = []
    if INCLUDE_NEWEST_MOVES
      speed1 += [:COURTCHANGE,:TARSHOT]
    end
    speedID1 = []; speedID2 = []; speedID3 = []
    for i in speed1; speedID1.push(getID(PBMoves,i)); end
    for i in speed2; speedID2.push(getID(PBMoves,i)); end
    for i in speed3; speedID3.push(getID(PBMoves,i)); end
    speedStage = 1 if speedID1.include?(move)
    speedStage = 2 if speedID2.include?(move)
    speedStage = 3 if speedID3.include?(move)  
    if speedStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::SPEED,speedStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Accuracy.
    #---------------------------------------------------------------------------
    acc1   = [:COPYCAT,:DEFENSECURL,:DEFOG,:FOCUSENERGY,:MIMIC,:SWEETSCENT,:TRICKROOM]
    acc2   = []
    acc3   = []
    accID1 = []; accID2 = []; accID3 = []
    for i in acc1; accID1.push(getID(PBMoves,i)); end
    for i in acc2; accID2.push(getID(PBMoves,i)); end
    for i in acc3; accID3.push(getID(PBMoves,i)); end
    accStage = 1 if accID1.include?(move)
    accStage = 2 if accID2.include?(move)
    accStage = 3 if accID3.include?(move)
    if accStage
      if attacker.pbCanRaiseStatStage?(PBStats::ACCURACY,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::ACCURACY,accStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Evasion.
    #---------------------------------------------------------------------------
    eva1   = [:CAMOFLAUGE,:DETECT,:FLASH,:KINESIS,:LUCKYCHANT,:MAGNETRISE,:SANDATTACK,
              :SMOKESCREEN]
    eva2   = []
    eva3   = []
    evaID1 = []; evaID2 = []; evaID3 = []
    for i in eva1; evaID1.push(getID(PBMoves,i)); end
    for i in eva2; evaID2.push(getID(PBMoves,i)); end
    for i in eva3; evaID3.push(getID(PBMoves,i)); end
    evaStage = 1 if evaID1.include?(move)
    evaStage = 2 if evaID2.include?(move)
    evaStage = 3 if evaID3.include?(move)
    if evaStage
      if attacker.pbCanRaiseStatStage?(PBStats::EVASION,attacker)
        attacker.pbRaiseStatStageByCause(PBStats::EVASION,evaStage,attacker,cause,true)
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise all stats.
    #---------------------------------------------------------------------------
    stat1  = [:CELEBRATE,:CONVERSION,:FORESTSCURSE,:GEOMANCY,:HAPPYHOUR,:HOLDHANDS,
              :PURIFY,:SKETCH,:TRICKORTREAT]
    stat2  = []
    stat3  = []
    if INCLUDE_NEWEST_MOVES
      stat1 += [:TEATIME]
    end
    statID1 = []; statID2 = []; statID3 = []
    for i in stat1; statID1.push(getID(PBMoves,i)); end
    for i in stat2; statID2.push(getID(PBMoves,i)); end
    for i in stat3; statID3.push(getID(PBMoves,i)); end
    statStage = 1 if statID1.include?(move)
    statStage = 2 if statID2.include?(move)
    statStage = 3 if statID3.include?(move)
    if statStage
      showAnim = true
      msg = "boosted"             if statStage==1
      msg = "sharply boosted"     if statStage==2
      msg = "drastically boosted" if statStage==3
      for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
        if attacker.pbCanRaiseStatStage?(stat,attacker)
          attacker.pbRaiseStatStageBasic(stat,statStage)
          if showAnim
            @battle.pbCommonAnimation("StatUp",attacker)
            @battle.pbDisplayBrief(_INTL("{1}'s Z-Power {2} its stats!",attacker.pbThis,msg))
          end
          showAnim = false
        end
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that returns lowered stats to normal.
    #---------------------------------------------------------------------------
    reset  = [:ACIDARMOR,:AGILITY,:AMNESIA,:ATTRACT,:AUTOTOMIZE,:BARRIER,:BATONPASS,
              :CALMMIND,:COIL,:COTTONGUARD,:COTTONSPORE,:DARKVOID,:DISABLE,:DOUBLETEAM,
              :DRAGONDANCE,:ENDURE,:FLORALHEALING,:FOLLOWME,:HEALORDER,:HEALPULSE,
              :HELPINGHAND,:IRONDEFENSE,:KINGSSHIELD,:LEECHSEED,:MILKDRINK,:MINIMIZE,
              :MOONLIGHT,:MORNINGSUN,:NASTYPLOT,:PERISHSONG,:PROTECT,:QUIVERDANCE,
              :RAGEPOWDER,:RECOVER,:REST,:ROCKPOLISH,:ROOST,:SHELLSMASH,:SHIFTGEAR,
              :SHOREUP,:SLACKOFF,:SOFTBOILED,:SPORE,:SUBSTITUTE,:SWAGGER,:SWALLOW,
              :SWORDSDANCE,:SYNTHESIS,:TAILGLOW]
    if INCLUDE_NEWEST_MOVES
      reset += [:LIFEDEW,:OBSTRUCT,:JUNGLEHEALING]
    end
    resetID = []
    for i in reset; resetID.push(getID(PBMoves,i)); end
    if resetID.include?(move)
      for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                   PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        if attacker.stages[stat]<0
          attacker.stages[stat]=0
        end
      end
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power returned its decreased stats to normal!",attacker.pbThis))
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that heal HP.
    #---------------------------------------------------------------------------
    heal1  = [:AROMATHERAPY,:BELLYDRUM,:CONVERSION2,:HAZE,:HEALBELL,:MIST,:PSYCHUP,
              :REFRESH,:SPITE,:STOCKPILE,:TELEPORT,:TRANSFORM]
    heal2  = [:MEMENTO,:PARTINGSHOT]
    healID1 = []; healID2 = []
    if INCLUDE_NEWEST_MOVES
      heal1 += [:CLANGOROUSSOUL,:NORETREAT,:STUFFCHEEKS]
    end
    for i in heal1; healID1.push(getID(PBMoves,i)); end
    for i in heal2; healID2.push(getID(PBMoves,i)); end
    # Z-Curse fully restores HP if user is a Ghost-type.
    if move==getID(PBMoves,:CURSE) && attacker.pbHasType?(:GHOST)
      healID1.push(move)
    end
    if healID1.include?(move)
      attacker.pbRecoverHP(attacker.totalhp,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power restored its health!",attacker.pbThis))
    end
    if healID2.include?(move)
      attacker.effects[PBEffects::ZHeal] = true
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that boosts critical hit rate.
    #---------------------------------------------------------------------------
    crit = [:ACUPRESSURE,:FORESIGHT,:HEARTSWAP,:SLEEPTALK,:TAILWIND]
    critID = []
    for i in crit; critID.push(getID(PBMoves,i)); end
    if critID.include?(move)
      if attacker.effects[PBEffects::FocusEnergy]<=0
        attacker.effects[PBEffects::FocusEnergy] = 2
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power got it pumped!",attacker.pbThis))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that cause misdirection.
    #---------------------------------------------------------------------------
    center = [:DESTINYBOND,:GRUDGE]
    centerID = []
    for i in center; centerID.push(getID(PBMoves,i)); end
    if centerID.include?(move)
      @battle.eachSameSideBattler do |b|
        b.effects[PBEffects::FollowMe]   = false
        b.effects[PBEffects::RagePowder] = false  
      end
      attacker.effects[PBEffects::FollowMe] = true
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power made it the center of attention!",attacker.pbThis))
    end
  end
end

#===============================================================================
# Specific effects of Z-Moves
#===============================================================================
class PokeBattle_Move_Z000 < PokeBattle_ZMove
end

#===============================================================================
# Inflicts paralysis. (Stoked Sparksurfer)
#===============================================================================
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
# Doubles damage on minimized Pokémons. (Malicious Moonsault)
#===============================================================================
class PokeBattle_Move_Z002 < PokeBattle_ZMove
  def tramplesMinimize?(param=1)
    # Perfect accuracy and double damage if minimized
    return NEWEST_BATTLE_MECHANICS
  end
end

#===============================================================================
# Base class of Z-Moves that increase all stats. 
#===============================================================================
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
# Raises all stats by 2 stages. (Extreme Evoboost)
#===============================================================================
class PokeBattle_Move_Z003 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,2,PBStats::DEFENSE,2,
               PBStats::SPATK,2,PBStats::SPDEF,2,
               PBStats::SPEED,2]
  end
end 

#===============================================================================
# Sets Psychic Terrain. (Genesis Supernova)
#===============================================================================
class PokeBattle_Move_Z004 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    @battle.pbStartTerrain(user,PBBattleTerrains::Psychic)
  end
end 

#===============================================================================
# Inflicts 75% of the target's current HP. (Guardian of Alola)
#===============================================================================
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
# Boosts all stats. (Clangorous Soulblaze)
#===============================================================================
class PokeBattle_Move_Z006 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,
               PBStats::SPATK,1,PBStats::SPDEF,1,
               PBStats::SPEED,1]
  end
end 

#===============================================================================
# Ignores ability. (Menacing Moonraze Maelstrom, Searing Sunraze Smash)
#===============================================================================
class PokeBattle_Move_Z007 < PokeBattle_ZMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end 

#===============================================================================
# Removes terrains. (Splintered Stormshards)
#===============================================================================
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
# Ignores ability + is physical or special depending on what's best. 
# (Light That Burns the Sky)
#===============================================================================
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
# SECTION 7 - COMPILER
################################################################################
# Gets the compatibility data from zmovescomp.
#===============================================================================
module PBZMove
  # Z Moves compatibility
  
  KEY_ZCRYSTAL = 0
  HELD_ZCRYSTAL = 1
  REQ_TYPE = 2
  REQ_MOVE = 3
  REQ_SPECIES = 4
  ZMOVE = 5
end 


def pbCompileZMoveCompatibility
  records   = {}
  records["order"] = [] # For the decompiler.
  
  pbCompilerEachPreppedLine("PBS/zmovescomp.txt") { |line,lineno|
    record = []
    lineRecord = pbGetCsvRecord(line,lineno,[0,"eeEEEe",
       PBItems, # Z-Crystal in the bag
       PBItems, # Z-Crystal held by the Pokémon
       PBTypes, # Move type required for the Z-Move 
       PBMoves, # Specific move required for the Z-Move 
       PBSpecies, # Specific species required for the Z-Move
       PBMoves]) # The Z-Move
    if !lineRecord[PBZMove::REQ_TYPE] && !lineRecord[PBZMove::REQ_MOVE] && !lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (you need to specify a type, or a move + species).\r\n{1}",FileLineData.linereport)
    end
    if lineRecord[PBZMove::REQ_TYPE] && lineRecord[PBZMove::REQ_MOVE] && lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (do not specifiy a type + a move + a species).\r\n{1}",FileLineData.linereport)
    end
    records[lineRecord[PBZMove::KEY_ZCRYSTAL]] = [] if !records[lineRecord[PBZMove::KEY_ZCRYSTAL]]
    records[lineRecord[PBZMove::KEY_ZCRYSTAL]].push(lineRecord)
    
    records[lineRecord[PBZMove::HELD_ZCRYSTAL]] = [] if !records[lineRecord[PBZMove::HELD_ZCRYSTAL]]
    records[lineRecord[PBZMove::HELD_ZCRYSTAL]].push(lineRecord)
    
    records["order"].push(lineRecord)
  }
  
  save_data(records,"Data/zmovescomp.dat")
end 


def pbSaveZMoveCompatibility
  zmovecomps = pbLoadZMoveCompatibility
  return if !zmovecomps
  
  zmovecomps = zmovecomps["order"]
  return if !zmovecomps
  
  File.open("PBS/zmovescomp.txt","wb") { |f|
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    zmovecomps.each { |comp| 
      f.write(sprintf("%s,%s,%s,%s,%s,%s",
         getConstantName(PBItems,comp[PBZMove::KEY_ZCRYSTAL]),
         getConstantName(PBItems,comp[PBZMove::HELD_ZCRYSTAL]),
         (comp[PBZMove::REQ_TYPE] ? getConstantName(PBTypes,comp[PBZMove::REQ_TYPE]) : ""),
         (comp[PBZMove::REQ_MOVE] ? getConstantName(PBMoves,comp[PBZMove::REQ_MOVE]) : ""),
         (comp[PBZMove::REQ_SPECIES] ? getConstantName(PBSpecies,comp[PBZMove::REQ_SPECIES]) : ""),
         getConstantName(PBMoves,comp[PBZMove::ZMOVE])
      ))
      f.write("\r\n")
    }
  }
end 


def pbLoadZMoveCompatibility
  return load_data("Data/zmovescomp.dat")
end 


# This is for ItemHandlers + the use of PokeBattle_ZMove.  
def pbGetZMoveDataIfCompatible(pokemon, zcrystal, basemove = nil)
  # basemove = the base move to be transformed. For use in battle.
  # zcrystal is either a Key-item crystal (returns true to pbIsZCrystal2?) 
  # or a held crystal (returns true to pbIsZCrystal?)   
  zmovecomps = pbLoadZMoveCompatibility
  return nil if !zmovecomps || !zmovecomps[zcrystal]
  
  zmovecomps[zcrystal].each { |comp|
    reqmove = false
    reqtype = false
    reqspecies = false
    
    if comp[PBZMove::REQ_TYPE]
      # If a type is required, then check if it has that type.
      if basemove
        reqtype=true if basemove.type==comp[PBZMove::REQ_TYPE]
      else 
        for move in pokemon.moves
          reqtype=true if move.type==comp[PBZMove::REQ_TYPE]
        end 
      end
    else 
      # If no type is required, then it's ok.
      reqtype = true 
    end 
    
    if comp[PBZMove::REQ_MOVE]
      # If a move is required, then check if the Pokémon has that move.
      if basemove
        reqmove=true if basemove.id==comp[PBZMove::REQ_MOVE]
      else 
        for move in pokemon.moves
          reqmove=true if move.id==comp[PBZMove::REQ_MOVE]
        end
      end 
    else 
      # If no move is required, then it's ok.
      reqmove = true
    end 
    
    if comp[PBZMove::REQ_SPECIES]
      # If a species is required, then check if the Pokémon has the right species.
      reqspecies = true if comp[PBZMove::REQ_SPECIES] == pokemon.fSpecies
    else 
      reqspecies = true 
    end 
    
    return comp if reqtype && reqmove && reqspecies
  }
  return nil 
end 

