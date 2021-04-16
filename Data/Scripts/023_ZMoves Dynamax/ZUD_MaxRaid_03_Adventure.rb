#===============================================================================
#
# Dynamax Adventures Script - by Lucidious89
#  For -Pokemon Essentials v18.1-
#
#===============================================================================
#
# ZUD_MaxRaid_03: Adventure
#
#===============================================================================
# The following is meant as an add-on for the ZUD Plugin for v18.1.
# This adds functionality to set up your own Dynamax Adventures, complete with
# all game mechanics present in the main series.
#
#===============================================================================
# SECTION 1 - DYNAMAX ADVENTURE CLASS
#-------------------------------------------------------------------------------
# This section handles all of the mechanics for setting up and tracking the
# states of a Dynamax Adventure.
#===============================================================================
# SECTION 2 - MAX LAIR BATTLES
#-------------------------------------------------------------------------------
# This section handles changes to battle mechanics for battles in a Max Lair.
#===============================================================================
# SECTION 3 - MAX LAIR MENUS
#-------------------------------------------------------------------------------
# This section handles all of the custom menus and UI used for various displays
# during a Dynamax Adventure.
#===============================================================================

################################################################################
# SECTION 1 - DYNAMAX ADVENTURE CLASS
#===============================================================================
# The class for handling the various states of a Dynamax Adventure.
#===============================================================================
class DynAdventureState
  attr_accessor :knockouts
  attr_accessor :bossBattled
  attr_accessor :bossSpecies
  attr_accessor :lastPokemon
  attr_accessor :lairSpecies
  
  # Window skin used for NPC encounter text (not dialogue).
  WINDOWSKIN = "Graphics/Windowskins/sign hgss loc"
  
  def clear
    @knockouts   = 0
    @inProgress  = false
    @bossBattled = false
    @lastPokemon = nil
    @bossSpecies = nil
    @lairSpecies = []
    @prizes      = []
    @party       = []
  end
  
  def initialize;  clear; end
  def inProgress?; return @inProgress; end
  def completed?;  return true if @bossBattled; end
  def defeated?;   return true if @knockouts<=0; end
  def ended?;      return true if completed? || defeated?; end
    
  #-----------------------------------------------------------------------------
  # Sets up the encounters in a Max Lair.
  #-----------------------------------------------------------------------------
  def pbGenerateLairSpecies
    rank = 1
    rank1, rank2, rank3, rank4, rank5 = pbGetMaxRaidSpeciesLists([nil])
    for i in 0...4
      rank += 1 if rank<4
      rank  = 6 if i==3
      raidrank  = rank1 if rank<=1
      raidrank  = rank2 if rank==2
      raidrank  = rank3 if rank==3
      raidrank  = rank4 if rank==4 || rank==5
      raidrank  = rank5 if rank>=6
      lairpkmn  = []
      speciesA  = raidrank[rand(raidrank.length)]
      fspeciesA = pbGetFSpeciesFromForm(speciesA[0],speciesA[1])
      speciesB  = raidrank[rand(raidrank.length)]
      fspeciesB = pbGetFSpeciesFromForm(speciesB[0],speciesB[1])
      speciesC  = raidrank[rand(raidrank.length)]
      fspeciesC = pbGetFSpeciesFromForm(speciesC[0],speciesC[1])
      speciesD  = raidrank[rand(raidrank.length)]
      fspeciesD = pbGetFSpeciesFromForm(speciesD[0],speciesD[1])
      if rank>=6
        @bossSpecies = (@bossSpecies) ? @bossSpecies : fspeciesA
        @lairSpecies.push(@bossSpecies)
      else
        @lairSpecies.push(fspeciesA)
        @lairSpecies.push(fspeciesB)
        @lairSpecies.push(fspeciesC) if i>0
        @lairSpecies.push(fspeciesD) if i>0
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Various events that may be triggered during a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  # Scientist NPC
  def pbLairEventSwap
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Scientist!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("How have the results of your adventure been so far?"))
    pbMessage(_INTL("I have a rental Pokémon here that I could swap with you, if you'd like."))
    trainer = PokeBattle_Trainer.new("RENTAL",0)
    pokemon = pbGetMaxLairRental(5,$Trainer.party[0].level,trainer)
    pokemon.item = 0
    pbMaxLairMenu([1,pokemon])
    pbMessage(_INTL("I'll head back to study the new data I've gathered."))
    pbMessage(_INTL("Please report any new findings you may discover on your adventure!"))
  end
  
  # Backpacker NPC
  def pbLairEventItems
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Backpacker!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I was worried I'd run into trouble in here, so I stocked up on more than I can carry..."))
    pbMessage(_INTL("I can share my supplies with you if you're in need. What items would you like?"))
    pbMaxLairMenu([3])
    pbMessage(_INTL("Remember, preparation is the key to victory!"))
  end
  
  # Blackbelt NPC
  def pbLairEventTrain
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Blackbelt!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I've been training deep in this cave so that I can grow strong like a Dynamax Pokémon!"))
    pbMessage(_INTL("Do you want to become strong, too? Let me share my secret training techniques with you!"))
    pbMaxLairMenu([4])
    pbMessage(_INTL("Keep pushing yourself until you've reached your limits!"))
  end
  
  # Ace Trainer NPC
  def pbLairEventTutor
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered an Ace Trainer!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I've been studying the most effective tactics to use in Dynamax battles."))
    pbMessage(_INTL("If you'd like, I can teach one of your Pokémon a new move to help it excel in battle!"))
    pbMaxLairMenu([5])
    pbMessage(_INTL("A good strategy will help you overcome any obstacle!"))
  end
  
  # Channeller NPC
  def pbLairEventWardIntro
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Channeler!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("Ahh! Your spirit beckons me to cleanse it of its weariness!"))
    pbMessage(_INTL("Let me exorcise the demons that plague your body and soul!"))
    pbMessage(_INTL("...\\wt[10] ...\\wt[10] ...\\wt[20]Begone!"))
    pbSEPlay(sprintf("Anim/Natural Gift"))
  end
  
  def pbLairEventWardOutro
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("Your total number of hearts increased!\\wt[34]"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("What am I even doing here, you ask?\nHaha! Foolish child."))
    randtext = rand(5)
    case randtext
    when 0
      pbMessage(_INTL("I was once an adventurer like you who got lost in these caves.\nMany...\\wt[10]many years ago.\\wt[10]"))
      pbMessage(_INTL("Huh? The Channeler suddenly vanished!"),nil,0,WINDOWSKIN)
    when 1
      pbMessage(_INTL("I go where the spirits say I'm needed! Nothing more!"))
      pbMessage(_INTL("I must go now, young one. There are many other souls that need saving!"))
    when 2
      pbMessage(_INTL("What makes you think I was ever really here at all?\nOooooo....\\wt[10]"))
      pbWait(20)
      pbMessage(_INTL("The Channeler tripped over a rock during their dramatic exit."),nil,0,WINDOWSKIN)
    when 3
      pbMessage(_INTL("I was summoned here by the wailing of souls crying out from this cave!"))
      pbMessage(_INTL("..but now that I'm here, I think it was just the wind."))
      pbMessage(_INTL("Perhaps it was fate that drew me here to meet you?\nAlas, it is now time for us to part ways."))
      pbMessage(_INTL("Farewell, child. Good luck on your journeys."))
    when 4
      pbMessage(_INTL("If you must know, I...\\wt[10]just got lost."))
      pbMessage(_INTL("The exit is back there, you say?\nThank you, child."))
      pbMessage(_INTL("May the spirits guide you better than they have me!"))
    end
  end
  
  # Nurse NPC
  def pbLairEventHeal
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Nurse!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("Are your Pokémon feeling a bit worn out from your adventure?"))
    pbMessage(_INTL("Please, let me heal them back to full health."))
    for i in $Trainer.party; i.heal; end
    pbMEPlay("Pkmn healing")
    pbWait(60)
    pbMessage(_INTL("I'll be going now.\nGood luck with the rest of your adventure!"))
  end
  
  # Random NPC
  def pbLairEventRandom(event)
    return if ended?
    return if !inProgress?
    pbLairEventSwap      if event==0
    pbLairEventItems     if event==1
    pbLairEventTrain     if event==2
    pbLairEventTutor     if event==3
    pbLairEventHeal      if event==4
  end
  
  # Berries
  def pbLairBerries
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You found some Berries lying on the ground!"))
    pbMessage(_INTL("Your Pokémon ate the Berries and some of their HP was restored!"))
    for i in $Trainer.party
      i.hp += i.totalhp/2
      i.hp = i.totalhp if i.hp>i.totalhp
    end
  end
  
  # Roadblocks
  def pbLairObstacles(value)
    return if ended?
    return if !inProgress?
    case value
    when 0
      pbMessage(_INTL("A deep chasm blocks your path forward."))
      pbMessage(_INTL("A Flying-type Pokémon may be able to lift you safely across."))
      text = "{1} happily carried you across the chasm."
    when 1
      pbMessage(_INTL("A large pool of murky water blocks your path forward."))
      pbMessage(_INTL("A Water-type Pokémon may be able to get you safely across."))
      text = "{1} happily carried you across the water."
    when 2
      pbMessage(_INTL("You reached what appears to be a dead end, but the wall here seems thin."))
      pbMessage(_INTL("A Fighting-type Pokémon may be able to punch through the wall and forge a path forward."))
      text = "{1} bashed through the wall with a mighty blow!"
    when 3
      pbMessage(_INTL("The floor here seems unstable in certain spots, and you may fall through if you proceed."))
      pbMessage(_INTL("A Psychic-type Pokémon may be able to foresee the safest route forward and avoid any pitfalls."))
      text = "{1} foresaw the dangers ahead and navigated you safely across."
    when 4
      pbMessage(_INTL("Strong winds funneled through the caves and whipped up a storm of dust that is impossible to see through."))
      pbMessage(_INTL("A Rock, Ground, or Steel-type Pokémon may be able to safely guide you through the storm."))
      text = "{1} bravely traversed the storm and led you across."
    when 5
      pbMessage(_INTL("Pitch-black darkness makes it too dangerous to move forward."))
      pbMessage(_INTL("A Bug, Dark, or Ghost-type Pokémon may be able to see through the darkness and lead you through it."))
      text = "{1} bravely traversed the darkness and led you across."
    when 6
      pbMessage(_INTL("A massive boulder blocks your path forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Attack may be physically capable of moving it."))
      text = "{1} flexed its muscles and tossed the boulder aside with ease!"
    when 7
      pbMessage(_INTL("Falling rocks makes it too dangerous to move forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Defense may be tough enough to shield you from harm."))
      text = "{1} unflinchingly shrugged off the falling rocks as you moved forward!"
    when 8
      pbMessage(_INTL("A steep incline makes it too difficult to move forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Speed may be quick enough to carry you forward."))
      text = "{1} bolted you up the incline without breaking a sweat!"
    when 9
      pbMessage(_INTL("An impenetrable barrier of Dynamax energy blocks your path forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Special Attack may be powerful enough to blast through it."))
      text = "{1} let out a yawn and effortlessly shattered the barrier!"
    when 10
      pbMessage(_INTL("A powerful wave of Dynamax energy prevents you from moving forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Special Defense may have enough fortitude to carry you through it."))
      text = "{1} swatted away the waves of energy and carried you through unscathed!"
    when 11
      pbMessage(_INTL("An intimidating gauntlet of various challenges prevents you from moving forward."))
      pbMessage(_INTL("A Pokémon with balanced training may be capable of overcoming the numerous obstacles."))
      text = "{1} impressively traversed the gauntlet with near-perfect form!"
    end
    for i in $Trainer.party
      criteria = (i.hasType?(:FLYING))   if value==0
      criteria = (i.hasType?(:WATER))    if value==1
      criteria = (i.hasType?(:FIGHTING)) if value==2
      criteria = (i.hasType?(:PSYCHIC))  if value==3
      criteria = (i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)) if value==4
      criteria = (i.hasType?(:BUG)  || i.hasType?(:DARK)   || i.hasType?(:GHOST)) if value==5
      criteria = (i.ev[1]==252) if value==6
      criteria = (i.ev[2]==252) if value==7
      criteria = (i.ev[3]==252) if value==8
      criteria = (i.ev[4]==252) if value==9
      criteria = (i.ev[5]==252) if value==10
      criteria = (i.ev[1]==50)  if value==11
      if criteria
        pbSEPlay(pbCryFile(i.species,i.form))
        pbMessage(_INTL(text,i.name))
        return true
        break
      end
    end
    pbMessage(_INTL("Unable to proceed, you turned back the way you came."))
    return false
  end
  
  # Hidden Traps
  def pbLairTraps(value)
    return if ended?
    return if !inProgress?
    pbSEPlay("Exclaim")
    case value
    when 0
      pbMessage(_INTL("You suddenly lost your footing and fell down a deep shaft!"))
      text1 = "{1} came to your rescue and cushioned your fall!"
      text2 = "Luckily, {1} managed to avoid harm!"
      text3 = "However, {1} was injured in the process..."
    when 1
      pbMessage(_INTL("An overgrown mushroom nearby suddenly burst and released a cloud of spores!"))
      text1 = "{1} pushed you aside and was hit by the cloud of spores instead!"
      text2 = "Luckily, the spores had no effect on {1}!"
      text3 = "{1} became sleepy due to the spores!"
    when 2
      pbMessage(_INTL("A mysterious ooze leaked from the cieling and fell towards you!"))
      text1 = "{1} pushed you aside and was hit by the mysterious ooze instead!"
      text2 = "Luckily, the mysterious ooze had no effect on {1}!"
      text3 = "{1} became poisoned due to the mysterious ooze!"
    when 3
      pbMessage(_INTL("A geyser of steam suddenly erupted beneath your feet!"))
      text1 = "{1} pushed you aside and was hit by the steam instead!"
      text2 = "Luckily, the steam had no effect on {1}!"
      text3 = "{1} became burned due to the steam!"
    when 4
      pbMessage(_INTL("An electrical pulse was suddenly released by iron deposits nearby!"))
      text1 = "{1} pushed you aside and was hit by the electrical pulse instead!"
      text2 = "Luckily, the electrical pulse had no effect on {1}!"
      text3 = "{1} became paralyzed due to the electrical pulse!"
    when 5
      pbMessage(_INTL("You walked over a sheet of ice and it began to crack beneath your feet!"))
      text1 = "{1} pushed you aside and plunged into the frigid water instead!"
      text2 = "Luckily, the frigid water had no effect on {1}!"
      text3 = "{1} was frozen solid due to the frigid water!"
    end
    p = $Trainer.party[rand($Trainer.party.length)]
    pbSEPlay(pbCryFile(p.species,p.form))
    pbMessage(_INTL(text1,p.name))
    if value==0
      random = rand(10)
      if random<2
        pbSEPlay("Mining found all")
        pbMessage(_INTL(text2,p.name))
      else
        p.hp-= p.totalhp/4
        p.hp = 1 if p.hp<=0
        pbSEPlay("Battle damage normal")
        pbMessage(_INTL(text3,p.name))
      end
    else
      noeffect = true if p.status>0 || p.hasAbility?(:COMATOSE)
      noeffect = true if value==1 && (p.hasType?(:GRASS)    || p.hasAbility?(:INSOMNIA)   || p.hasAbility?(:VITALSPIRIT) || p.hasAbility?(:SWEETVEIL))
      noeffect = true if value==2 && (p.hasType?(:POISON)   || p.hasType?(:STEEL)         || p.hasAbility?(:IMMUNITY)    || p.hasAbility?(:PASTELVEIL))
      noeffect = true if value==3 && (p.hasType?(:FIRE)     || p.hasAbility?(:WATERVEIL)  || p.hasAbility?(:WATERBUBBLE))
      noeffect = true if value==4 && (p.hasType?(:ELECTRIC) || p.hasType?(:GROUND)        || p.hasAbility?(:LIMBER))
      noeffect = true if value==5 && (p.hasType?(:ICE)      || p.hasAbility?(:MAGMAARMOR))
      if noeffect
        pbSEPlay("Mining found all")
        pbMessage(_INTL(text2,p.name))
      else
        p.status      = value
        p.statusCount = (value==1) ? 2 : 0
        pbSEPlay("Battle damage normal")
        pbMessage(_INTL(text3,p.name))
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Initiates the party exchange screen upon capturing a Pokemon in a Max Lair.
  #-----------------------------------------------------------------------------
  def pbSwap
    @prizes.push(@lastPokemon)
    if @prizes.length>6; @prizes.delete_at(0); end
    randev = 1+rand(6)
    @lastPokemon.ev[0] = 252
    for i in 1...6; @lastPokemon.ev[i] =  50 if randev==6; end
    for i in 1...6; @lastPokemon.ev[i] = 252 if i==randev; end
    @lastPokemon.calcStats
    return if ended?
    return if !inProgress?
    pbMaxLairMenu([1,@lastPokemon]) if !completed?
  end
  
  #-----------------------------------------------------------------------------
  # Initiates the prize screen at the end of a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbPrize
    return if !inProgress?
    return if @prizes.length==0
    shinycharm = (hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM))
    odds = (shinycharm) ? 100 : 300
    for i in @prizes
      i.item = 0
      i.resetMoves
      i.ev = [0,0,0,0,0,0]
      i.makeShiny if rand(odds)==1
    end
    pbMaxLairMenu([2,@prizes])
  end
  
  #-----------------------------------------------------------------------------
  # Begins a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbStart(map=0)
    return if inProgress?
    clear
    size    = (defined?(PCV)) ? 4 : 3
    baselvl = 15
    for i in 1...$Trainer.numbadges
      baselvl += 10
      break if baselvl>=65
    end
    if pbConfirmMessage(_INTL("Would you like to embark on a Dynamax Adventure?"))
      if pbSavedLairRoutes.length>0
        pbMessage(_INTL("According to my notes, it seems you might know how to find certain special Pokémon."))
        text = _INTL("Which Pokémon would you like to set out to find today?")
        list = []
        for i in pbSavedLairRoutes; list.push(PBSpecies.getName(i)); end
        list.push(_INTL("Anything is fine"))
        loop do
          cmd = pbMessage(text,list,-1,nil,0)
          case cmd
          when -1
            pbMessage(_INTL("I hope we'll see you again soon!"))
            break
          else
            @inProgress  = true
            @bossSpecies = pbSavedLairRoutes[cmd] if cmd<list.length
            break
          end
        end
      else
        @inProgress = true
      end
      if inProgress?
        for i in 0...$Trainer.party.length
          @party.push($Trainer.party[i])
        end
        pbMaxLairMenu([0,size,baselvl])
        pbGenerateLairSpecies
        @knockouts = $Trainer.party.length
        if $Trainer.party==@party
          clear
          pbMessage(_INTL("I hope we'll see you again soon!"))
        else
          previousBGM = $game_system.getPlayingBGM
          pbFadeOutInWithMusic {
            pbMaxLairMap(map)
            pbWait(25)
            $Trainer.party = @party
            pbPrize if @prizes.length>0 && ended?
          }
          pbBGMPlay(previousBGM)
          pbEnd
        end
      end
    else
      pbMessage(_INTL("I hope we'll see you again soon!"))
    end
  end

  #-----------------------------------------------------------------------------
  # Ends a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbEnd
    return if !inProgress?
    if defeated?
      bossname = PBSpecies.getName(@bossSpecies)
      for i in pbSavedLairRoutes; marked = true if i==@bossSpecies; end
      pbMessage(_INTL("Well done facing such a tough opponent!\nVictory seemed so close - I could almost taste it!"))      
      if @bossBattled && !marked && 
         pbConfirmMessage(_INTL("Would you like me to jot down where you found {1} this time so that you might find it again?",bossname))
        if pbSavedLairRoutes.length>=3
          pbMessage(_INTL("You already have the maximum number of routes saved..."))
          if pbConfirmMessage(_INTL("Would you like to replace an existing route?"))
            text = _INTL("Which route should be replaced?")
            list = []
            for i in pbSavedLairRoutes; list.push(PBSpecies.getName(i)); end
            list.push(_INTL("Nevermind"))
            loop do
              Input.update
              cmd = 0
              cmd = pbMessage(text,list,-1,nil,0)
              case cmd
              when -1,list.length-1; break
              else
                $PokemonGlobal.markedAdvRoutes.delete_at(cmd)
                $PokemonGlobal.markedAdvRoutes.push(@bossSpecies)
                pbMessage(_INTL("The route to {1} was saved for future reference.",bossname))
                break
              end
            end
          end
        else 
          $PokemonGlobal.markedAdvRoutes.push(@bossSpecies)
          pbMessage(_INTL("The route to {1} was saved for future reference.",bossname))
        end
      end
      pbMessage(_INTL("I hope we'll see you again soon!"))
    elsif completed?
      for i in 0...pbSavedLairRoutes.length
        $PokemonGlobal.markedAdvRoutes.delete_at(i) if @bossSpecies==pbSavedLairRoutes[i]
      end
      pbMessage(_INTL("Well done defeating that tough opponent!\nI hope we'll see you again soon!"))
    else
      pbMessage(_INTL("Huh, you're giving up?\nPlease come back any time for a new adventure!"))
    end
    clear
  end
  
  def pbSummary(pokemon,pkmnid,hidesprites)
    oldsprites = pbFadeOutAndHide(hidesprites)
    scene  = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,true)
    screen.pbStartScreen(pokemon,pkmnid)
    yield if block_given?
    pbFadeInAndShow(hidesprites,oldsprites)
  end
end

#===============================================================================
# Various utilities used for Dynamax Adventure functions.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :markedAdvRoutes
  attr_accessor :dynAdventureState
  
  alias _ZUD_initialize initialize
  def initialize
    @markedAdvRoutes   = []
    @dynAdventureState = nil
    _ZUD_initialize
  end
end

def pbSavedLairRoutes
  if !$PokemonGlobal.markedAdvRoutes
    $PokemonGlobal.markedAdvRoutes = []
  end
  return $PokemonGlobal.markedAdvRoutes
end

def pbDynAdventureState
  if !$PokemonGlobal.dynAdventureState
    $PokemonGlobal.dynAdventureState = DynAdventureState.new
  end
  return $PokemonGlobal.dynAdventureState
end

#-------------------------------------------------------------------------------
# Checks if the player is currently in a Dynamax Adventure.
#-------------------------------------------------------------------------------
def pbInDynAdventure?
  return pbDynAdventureState.inProgress?
end

#-------------------------------------------------------------------------------
# Creates a rental Pokemon.
#-------------------------------------------------------------------------------
def pbGetMaxLairRental(rank,level,trainer)
  rank1, rank2, rank3, rank4, rank5 = pbGetMaxRaidSpeciesLists([nil])
  raidrank = rank1 if rank<=1
  raidrank = rank2 if rank==2
  raidrank = rank3 if rank==3
  raidrank = rank4 if rank==4 || rank==5
  raidrank = rank5 if rank>=6
  species  = raidrank[rand(raidrank.length)]
  pokemon = pbNewPkmn(species[0],level,trainer,true)
  pokemon.personalID = rand(65536)
  pokemon.personalID|= rand(65536)<<8
  pokemon.personalID-= pokemon.personalID%25
  pokemon.personalID+= pokemon.nature
  pokemon.personalID&= 0xFFFFFFFF
  pokemon.happiness  = 0
  pokemon.setDynamaxLvl(5)
  pokemon.giveGMaxFactor if pbGmaxSpecies?(species[0],species[1]) && rand(10)<5
  form = species[1]
  form = 7+rand(7) if species[0]==getID(PBSpecies,:MINIOR)
  raidmoves = pbGetMaxRaidMoves(species[0],form,true)
  move1 = raidmoves[0][rand(raidmoves[0].length)]
  move2 = raidmoves[1][rand(raidmoves[1].length)]
  move3 = raidmoves[2][rand(raidmoves[2].length)]
  move4 = raidmoves[3][rand(raidmoves[3].length)]
  pokemon.pbLearnMove(move1) if raidmoves[0].length>0
  pokemon.pbLearnMove(move2) if raidmoves[1].length>0
  pokemon.pbLearnMove(move3) if raidmoves[2].length>0
  pokemon.pbLearnMove(move4) if raidmoves[3].length>0
  pbCustomRaidSets(pokemon,species[1])
  pokemon.form = form
  pokemon.setGender(species[2])
  pokemon.item = 0
  pokemon.setItem(:ORANBERRY)   if rand(100)<25
  pokemon.setItem(:SITRUSBERRY) if rand(100)<5
  pokemon.setAbility(rand(pokemon.getAbilityList.length))
  randev = 1+rand(6)
  pokemon.ev[0] = 252
  for i in 1...6; pokemon.ev[i] =  50 if randev==6; end
  for i in 1...6; pokemon.ev[i] = 252 if i==randev; end
  for i in 0...6; pokemon.iv[i] = 20; end
  pokemon.obtainText = _INTL("Max Lair Rental.")
  pokemon.calcStats
  return pokemon
end


################################################################################
# SECTION 2 - MAX LAIR BATTLES
#===============================================================================
# Handles the battle class during a Dynamax Adventure.
#===============================================================================
Events.onWildBattleOverride += proc { |_sender,e|
  species = $game_variables[MAXRAID_PKMN][0]
  level   = $game_variables[MAXRAID_PKMN][3]
  handled = e[2]
  next if handled[0]!=nil
  next if !pbInDynAdventure?
  maxsize = (defined?(PCV)) ? 5 : 3
  size    = ($Trainer.party.length<=maxsize) ? $Trainer.party.length : 1
  $PokemonSystem.activebattle = true if size>=3 && defined?(PCV)
  handled[0] = pbMaxLairBattle(size,species,level)
}

def pbMaxLairBattle(size,species,level)
  Events.onStartBattle.trigger(nil)
  pkmn = pbGenerateWildPokemon(species,level)
  foeParty          = [pkmn]
  playerTrainer     = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  scene   = pbNewBattleScene
  battle  = PokeBattle_MaxLairBattle.new(scene,playerParty,foeParty,playerTrainer,nil)
  battle.party1starts = playerPartyStarts
  baselvl = $Trainer.party[0].level
  $PokemonGlobal.nextBattleBGM = (level==(baselvl+5)) ? "Max Raid Battle (Legendary)" : "Max Raid Battle"
  $PokemonGlobal.nextBattleBGM = "Eternamax Battle" if species==getID(PBSpecies,:ETERNATUS)
  setBattleRule("canLose")
  setBattleRule("cannotRun")
  setBattleRule("noPartner")
  setBattleRule("environ",7)
  setBattleRule("base","cave3")
  setBattleRule("backdrop","cave3")
  setBattleRule(sprintf("%dv%d",size,1))
  pbPrepareBattle(battle)
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),0,foeParty) {
    decision = battle.pbStartBattle
    pbAfterBattle(decision,true)
    $Trainer.party.each do |pkmn|
      pkmn.heal if pkmn.fainted?
      pkmn.makeUnmega
      pkmn.makeUnprimal
      pkmn.makeUnUltra
    end
  }
  Input.update
  pbSet(1,decision)
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return (decision!=2 && decision!=3 && decision!=5)
end

#-------------------------------------------------------------------------------
# Initiates swap screen upon capturing a Pokemon in a Max Lair.
#-------------------------------------------------------------------------------
class PokeBattle_MaxLairBattle < PokeBattle_Battle
  def pbStorePokemon(pkmn)
    pkmn.heal
    pbDynAdventureState.lastPokemon = pkmn
    pbDisplay(_INTL("Caught {1}!",pkmn.name))
    pbDynAdventureState.pbSwap
  end
end


################################################################################
# SECTION 3 - MAX LAIR MENUS
#===============================================================================
# The class for handling various menus and displays during a Dynamax Adventure.
#===============================================================================
class MaxLairEventScene
  BASE   = Color.new(248,248,248)
  SHADOW = Color.new(0,0,0)
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbFadeOutIn(99999){
      pbUpdate
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    }
  end
  
  def pbShowCommands(commands,index=0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
       cmdwindow.z = @viewport.z+1
       cmdwindow.index = index
       pbBottomRight(cmdwindow)
       loop do
         Graphics.update
         Input.update
         cmdwindow.update
         pbUpdate
         if Input.trigger?(Input::B)
           pbPlayCancelSE
           ret = -1
           break
         elsif Input.trigger?(Input::C)
           pbPlayDecisionSE
           ret = cmdwindow.index
           break
         end
       end
    }
    return ret
  end
  
  def pbClearAll
    @rentals.clear
    @textPos.clear
    @imagePos.clear
    @changetext.clear
    @changesprites.clear
  end
  
  #-----------------------------------------------------------------------------
  # Begins the screen.
  #-----------------------------------------------------------------------------
  def pbStartScene(size,level)
    @rentals     = []
    @rentalparty = []
    @textPos     = []
    @imagePos    = []
    @size        = size
    @level       = level
    @trainer     = PokeBattle_Trainer.new("RENTAL",0)
    @sprites     = {}
    @viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z  = 99999
    @sprites["selectbg"] = IconSprite.new(0,0,@viewport)
    @sprites["selectbg"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_bg")
    @sprites["prizebg"]  = IconSprite.new(0,0,@viewport)
    @sprites["prizebg"].setBitmap("Graphics/Pictures/Dynamax/lairmenu")
    @sprites["prizebg"].src_rect.set(0,0,197,384)
    @sprites["prizebg"].visible = false
    @sprites["prizesel"] = IconSprite.new(197,0,@viewport)
    @sprites["prizesel"].setBitmap("Graphics/Pictures/Dynamax/lairmenu")
    @sprites["prizesel"].src_rect.set(197,0,315,384)
    @sprites["prizesel"].visible = false
    @xpos = Graphics.width-330
    @ypos = 39
    for i in 0...3
      @sprites["pokeslot#{i}"] = IconSprite.new(@xpos,@ypos+(i*114),@viewport)
      @sprites["pokeslot#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["pokeslot#{i}"].src_rect.set(0,109,330,115)
      @sprites["pokeslot#{i}"].visible = false
    end
    @sprites["slotsel"] = IconSprite.new(@xpos,@ypos,@viewport)
    @sprites["slotsel"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
    @sprites["slotsel"].src_rect.set(0,0,165,109)
    @sprites["slotsel"].visible = false
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = @xpos-30
    @sprites["rightarrow"].play
    @sprites["rightarrow"].visible = false
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = @xpos-42
    @sprites["leftarrow"].play
    @sprites["leftarrow"].visible = false
    for i in 0...@size
      @sprites["partybg#{i}"] = IconSprite.new(4,90+(i*40),@viewport)
      @sprites["partybg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["partyname#{i}"] = IconSprite.new(41,99+(i*40),@viewport)
      @sprites["partyname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["partyname#{i}"].src_rect.set(197,20,150,19)
    end
    @sprites["menudisplay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["menudisplay"].z += 1
    @menudisplay = @sprites["menudisplay"].bitmap
    @sprites["changesprites"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["changesprites"].z += 1
    @changesprites = @sprites["changesprites"].bitmap
    @sprites["statictext"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["statictext"].z += 1
    @statictext = @sprites["statictext"].bitmap
    pbSetSmallFont(@statictext)
    @sprites["changetext"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["changetext"].z += 1
    @changetext = @sprites["changetext"].bitmap
    pbSetSmallFont(@changetext)
    drawTextEx(@statictext,4,-2,164,0,_INTL("DYNAMAX ADVENTURE"),BASE,SHADOW)
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @categorybitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/category"))
    @statbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/lairmenu_stats"))
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
  end
    
  def pbDrawParty(party,showname=true)
    for i in 0...party.length
      @sprites["partysprite#{i}"] = PokemonIconSprite.new(party[i],@viewport)
      spritex = @sprites["partysprite#{i}"].x = @sprites["partybg#{i}"].x+2
      spritey = @sprites["partysprite#{i}"].y = @sprites["partybg#{i}"].y
      @sprites["partysprite#{i}"].zoom_x = 0.5
      @sprites["partysprite#{i}"].zoom_y = 0.5
      if showname
        @textPos.push([_INTL("{1}",party[i].name),spritex+40,spritey+5,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
      end
    end
  end
  
  def pbDrawTypeIcons(poke,ypos)
    type1 = pbGetSpeciesData(poke.species,poke.form,SpeciesType1)
    type2 = pbGetSpeciesData(poke.species,poke.form,SpeciesType2)
    type1rect  = Rect.new(0,type1*28,64,28)
    type2rect  = Rect.new(0,type2*28,64,28)
    @changesprites.blt(@xpos+86,ypos,@typebitmap.bitmap,type1rect)
    @changesprites.blt(@xpos+86,ypos+32,@typebitmap.bitmap,type2rect) if type1!=type2
  end
  
  def pbDrawStatIcons(poke,ypos)
    stat = nil
    for i in 1...6
      stat = i if poke.ev[i]==252
      stat = 6 if poke.ev[i]==50
    end
    for i in 0...$Trainer.party.length
      xpos = @sprites["partysprite#{i}"].x+55 if poke==$Trainer.party[i]
    end
    xpos = Graphics.width-34 if !xpos 
    @changesprites.blt(xpos,ypos,@statbitmap.bitmap,Rect.new((stat-1)*32,0,32,32)) if stat
  end
  
#===============================================================================
# Max Lair - Rental Screen
#===============================================================================
  def pbRentalSelect
    pbGenerateRentals
    index    = -1
    maxindex = @rentals.length-1
    drawTextEx(@statictext,4,52,164,0,_INTL("Rental Party:"),BASE,SHADOW)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      drawTextEx(@statictext,8,346,120,0,_INTL("View Party (Z)"),BASE,SHADOW) if @rentalparty.length>0
      if @rentalparty.length>=@size
        pbWait(20)
        pbMessage(_INTL("{1} set out on an adventure!",$Trainer.name))
        $Trainer.party = @rentalparty
        pbSEPlay("Door enter")
        break
      end
      # Scrolls up/down through rental options.
      if Input.trigger?(Input::DOWN)
        pbPlayCancelSE
        Input.update
        index += 1
        index  = 0 if index>maxindex
        @sprites["slotsel"].y  = @sprites["pokeslot#{index}"].y
        @sprites["rightarrow"].y = 80+(index*114)
        @sprites["slotsel"].visible = true
        @sprites["rightarrow"].visible = true
      elsif Input.trigger?(Input::UP)
        pbPlayCancelSE
        Input.update
        index -= 1
        index  = maxindex if index<0
        @sprites["slotsel"].y  = @sprites["pokeslot#{index}"].y
        @sprites["rightarrow"].y = 80+(index*114)
        @sprites["slotsel"].visible = true
        @sprites["rightarrow"].visible = true
      # View the Summary of the current rental party.
      elsif Input.trigger?(Input::A) && @rentalparty.length>0
        pbDynAdventureState.pbSummary(@rentalparty,0,@sprites)
      end
      # Select a rental Pokemon.
      if Input.trigger?(Input::C) && index>-1
        Input.update
        cmd = 0
        cmd = pbShowCommands(["Select","Summary","Back"],cmd)
        # Adds the selected rental Pokemon to your rental team.
        if cmd==0
          poke = @rentals[index]
          if pbConfirmMessage(_INTL("Add {1} to your rental team?",poke.name))
            pbSEPlay(pbCryFile(poke.species,poke.form))
            pbWait(25)
            index = -1
            @rentalparty.push(poke)
            for i in 0...@rentals.length
              @sprites["pkmnsprite#{i}"].dispose
              @sprites["gmaxsprite#{i}"].dispose
              @sprites["helditem#{i}"].dispose
            end
            pbClearAll
            @sprites["slotsel"].visible = false
            @sprites["rightarrow"].visible = false
            pbGenerateRentals
          end
        # View the Summary of the selected rental Pokemon.
        elsif cmd==1
          pbDynAdventureState.pbSummary(@rentals,index,@sprites)
        end
      elsif Input.trigger?(Input::B)
        break if pbConfirmMessage(_INTL("Exit the Max Lair?"))
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Rental Pokemon creation.
  #-----------------------------------------------------------------------------
  def pbGenerateRentals
    pbDrawParty(@rentalparty)
    remainder = @size-@rentalparty.length
    if remainder>0
      @textPos.push([_INTL("Select {1} more rental Pokémon.",remainder),230,0,0,BASE,SHADOW])
      for i in 0...3
        @rentals.push(pbGetMaxLairRental(3,@level,@trainer))
        @sprites["pokeslot#{i}"].visible = true
        @sprites["gmaxsprite#{i}"] = IconSprite.new(0,0,@viewport)
        @sprites["gmaxsprite#{i}"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
        @sprites["pkmnsprite#{i}"] = PokemonIconSprite.new(@rentals[i],@viewport)
        spritex = @sprites["pkmnsprite#{i}"].x = @xpos+12
        spritey = @sprites["pkmnsprite#{i}"].y = (@ypos+5)+(i*114)
        @sprites["gmaxsprite#{i}"].x = spritex-4
        @sprites["gmaxsprite#{i}"].y = spritey+4
        @sprites["gmaxsprite#{i}"].visible = false if !@rentals[i].gmaxFactor?
        @sprites["helditem#{i}"] = HeldItemIconSprite.new(spritex-8,spritey+40,@rentals[i],@viewport)
        offset = (@rentals[i].genderless?) ? -4 : 12
        name   = @rentals[i].name
        abil   = PBAbilities.getName(@rentals[i].ability)
        mark, base, shadow = "♂", Color.new(24,112,216), Color.new(136,168,208) if @rentals[i].male?
        mark, base, shadow = "♀", Color.new(248,56,32),  Color.new(224,152,144) if @rentals[i].female?
        @textPos.push([mark,spritex-4,spritey+56,0,base,shadow]) if !@rentals[i].genderless?
        @textPos.push([_INTL("{1}",name),spritex+offset,spritey+58,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",abil),spritex-4,spritey+78,0,BASE,SHADOW])
        for m in 0...@rentals[i].moves.length
          move = PBMoves.getName(@rentals[i].moves[m].id)
          xpos = spritex+160
          ypos = (spritey+6)+(m*22)
          @textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
        end
        pbDrawStatIcons(@rentals[i],@sprites["pokeslot#{i}"].y-2)
        pbDrawTypeIcons(@rentals[i],spritey+2)
      end
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Exchange Screen
#===============================================================================
  def pbSwapSelect(pokemon)
    pbDrawSwapScreen(pokemon)
    @sprites["slotsel"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,220,-4,400,0,_INTL("Select a party member to swap."),BASE,SHADOW)
    if pbConfirmMessage(_INTL("Would you like to swap Pokémon?"))
      pbMessage(_INTL("Select a party member to exchange."))
      index    = 0
      maxindex = $Trainer.party.length-1
      @sprites["leftarrow"].y = 95
      @sprites["leftarrow"].visible = true
      loop do
        Graphics.update
        Input.update
        pbUpdate
        # Scrolls up/down through your rental party.
        if Input.trigger?(Input::DOWN)
          pbPlayCancelSE
          Input.update
          index += 1
          index  = 0 if index>maxindex
          @sprites["leftarrow"].y = 95+(index*40)
        elsif Input.trigger?(Input::UP)
          pbPlayCancelSE
          Input.update
          index -= 1
          index  = maxindex if index<0
          @sprites["leftarrow"].y = 95+(index*40)
        # View the Summary of the current rental party.
        elsif Input.trigger?(Input::A)
          pbDynAdventureState.pbSummary([pokemon],0,@sprites)
        end
        # Select a party member.
        if Input.trigger?(Input::C)
          Input.update
          cmd = 0
          cmd = pbShowCommands(["Select","Summary","Back"],cmd)
          # Exchanges the selected party member for the caught Pokemon.
          if cmd==0
            oldpoke = $Trainer.party[index]
            olditem = $Trainer.party[index].item
            if pbConfirmMessage(_INTL("Exchange {1} for the new Pokémon?",oldpoke.name))
              pbSEPlay(pbCryFile(pokemon.species,pokemon.form))
              pbWait(25)
              @sprites["partysprite#{index}"].dispose
              @sprites["pkmnsprite"].dispose
              @sprites["gmaxsprite"].dispose
              @sprites["helditem"].dispose
              @sprites["slotsel"].visible = false
              @sprites["leftarrow"].visible = false
              $Trainer.party[index] = pokemon
              $Trainer.party[index].item = olditem
              pbClearAll
              pbDrawSwapScreen
              pbMessage(_INTL("\\se[]{1} was added to the party!\\se[Pkmn move learnt]",pokemon.name))
              pbMessage(_INTL("{1}'s {2} was given to {3}.",oldpoke.name,PBItems.getName(olditem),pokemon.name)) if olditem>0
              break
            end
          # View the Summary of the selected party member.
          elsif cmd==1
            pbDynAdventureState.pbSummary($Trainer.party,index,@sprites)
          end
        elsif Input.trigger?(Input::B)
          break if pbConfirmMessage(_INTL("Move on without swapping?"))
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws all the Pokemon data for a swap screen.
  #-----------------------------------------------------------------------------
  def pbDrawSwapScreen(pokemon=nil)
    pbDrawParty($Trainer.party)
    if pokemon
      slot = 1
      @sprites["pokeslot#{slot}"].visible = true
      @sprites["gmaxsprite"] = IconSprite.new(0,0,@viewport)
      @sprites["gmaxsprite"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
      @sprites["pkmnsprite"] = PokemonIconSprite.new(pokemon,@viewport)
      spritex = @sprites["pkmnsprite"].x = @xpos+12
      spritey = @sprites["pkmnsprite"].y = @ypos+(slot*114)
      @sprites["slotsel"].y  = @sprites["pokeslot#{slot}"].y
      @sprites["gmaxsprite"].x = spritex-4
      @sprites["gmaxsprite"].y = spritey+4
      @sprites["gmaxsprite"].visible = false if !pokemon.gmaxFactor?
      @sprites["helditem"] = HeldItemIconSprite.new(spritex-8,spritey+40,pokemon,@viewport)
      newtag = [["Graphics/Pictures/Dynamax/lairmenu_slot",@xpos+10,spritey-15,165,0,60,20]]
      pbDrawImagePositions(@changesprites,newtag)
      name   = pokemon.name
      abil   = PBAbilities.getName(pokemon.ability)
      offset = (pokemon.genderless?) ? -4 : 12
      mark, base, shadow = "♂", Color.new(24,112,216), Color.new(136,168,208) if pokemon.male?
      mark, base, shadow = "♀", Color.new(248,56,32),  Color.new(224,152,144) if pokemon.female?
      @textPos.push([mark,spritex-4,spritey+56,0,base,shadow]) if !pokemon.genderless?
      @textPos.push([_INTL("{1}",name),spritex+offset,spritey+58,0,BASE,SHADOW])
      @textPos.push([_INTL("{1}",abil),spritex-4,spritey+78,0,BASE,SHADOW])
      for m in 0...pokemon.moves.length
        move = PBMoves.getName(pokemon.moves[m].id)
        xpos = spritex+160
        ypos = (spritey+6)+(m*22)
        @textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
      end
      pbDrawStatIcons(pokemon,@sprites["pokeslot#{slot}"].y-2)
      pbDrawTypeIcons(pokemon,spritey+2)
      @textPos.push([_INTL("View PKMN (Z)"),14,348,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Item Screen
#===============================================================================
  def pbItemSelect
    items    = []
    itempool = [:EVIOLITE,:FOCUSSASH,:LIFEORB,:LEFTOVERS,:MUSCLEBAND,:WISEGLASSES,
                :ASSAULTVEST,:WEAKNESSPOLICY,:EXPERTBELT,:QUICKCLAW,:BRIGHTPOWDER,
                :ROCKYHELMET,:SHELLBELL,:WIDELENS,:SAFETYGOGGLES,:UTILITYUMBRELLA,
                :SCOPELENS,:SITRUSBERRY,:LUMBERRY,:LEPPABERRY,:ELECTRICSEED,
                :GRASSYSEED,:MISTYSEED,:PSYCHICSEED,:WHITEHERB,:PROTECTIVEPADS,
                :CHOICESCARF,:CHOICESPECS,:CHOICEBAND]
    for i in 0...6
      randitem = rand(itempool.length)
      items.push(itempool[randitem])
      itempool.delete_at(randitem)
    end
    pbDrawItemScreen(items)
    ended = false
    @sprites["prizesel"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,8,346,120,0,_INTL("View Party (Z)"),BASE,SHADOW)
    pbDrawParty($Trainer.party,false)
    for i in 0...$Trainer.party.length
      spritex = @sprites["partysprite#{i}"].x
      spritey = @sprites["partysprite#{i}"].y
      @sprites["partyitem#{i}"] = ItemIconSprite.new(spritex+73,spritey+18,$Trainer.party[i].item,@viewport)
      @sprites["partyitem#{i}"].zoom_x  = 0.5
      @sprites["partyitem#{i}"].zoom_y  = 0.5
      @sprites["partyitem#{i}"].visible = false if $Trainer.party[i].item==0
    end
    if pbConfirmMessage(_INTL("Would you like to give items to your Pokémon?"))
      for i in 0...$Trainer.party.length
        index    = 0
        maxindex = items.length-1
        poke     = $Trainer.party[i]
        olditem  = PBItems.getName(poke.item)
        pbMessage(_INTL("Select an item to give to {1}.",poke.name))
        text  = _INTL("{1} is already holding a {2}.",poke.name,olditem)
        text  = _INTL("{1} is already holding an {2}.",poke.name,olditem)   if olditem.starts_with_vowel?
        text  = _INTL("{1} is already holding some {2}.",poke.name,olditem) if poke.hasItem?(:LEFTOVERS)
        pairs = [:WISEGLASSES,:CHOICESPECS,:SAFETYGOGGLES,:PROTECTIVEPADS]
        for item in 0...pairs.length
          text = _INTL("{1} is already holding a pair of {2}.",poke.name,olditem) if poke.hasItem?(pairs[item])
        end
        next if poke.item>0 && !pbConfirmMessage(_INTL("{1}\nReplace this item?",text))
        @textPos.push([_INTL("Select {1}'s item.",poke.name),250,0,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",poke.name),46,(90+(i*40))+5,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
        @sprites["rightarrow"].x = @xpos+44
        @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
        @sprites["rightarrow"].visible = true
        @sprites["partyitem#{i}"].visible = false
        loop do
          Graphics.update
          Input.update
          pbUpdate
          # Scrolls up/down through the item options.
          if Input.trigger?(Input::DOWN)
            pbPlayCancelSE
            Input.update
            index += 1
            index  = 0 if index>maxindex
            @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
          elsif Input.trigger?(Input::UP)
            pbPlayCancelSE
            Input.update
            index -= 1
            index  = maxindex if index<0
            @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
          # View the Summary of the party.
          elsif Input.trigger?(Input::A)
            pbDynAdventureState.pbSummary($Trainer.party,i,@sprites)
          end
          # Select an item.
          if Input.trigger?(Input::C)
            Input.update
            cmd  = 0
            cmd  = pbShowCommands(["Give","Details","No Item","Back"],cmd)
            item = getID(PBItems,items[index])
            # Equips the selected hold item.
            if cmd==0
              if poke.item==getID(PBItems,item)
                pbMessage(_INTL("{1}",text))
              else
                if pbConfirmMessage(_INTL("Give the {1} to {2}?",PBItems.getName(item),poke.name))
                  pbSEPlay(pbCryFile(poke.species,poke.form))
                  pbWait(25)
                  pbMessage(_INTL("{1} was given the {2}.",poke.name,PBItems.getName(item)))
                  @sprites["partyitem#{i}"].item=(item)
                  @sprites["partyitem#{i}"].visible = true
                  @sprites["rightarrow"].visible    = false
                  poke.setItem(item)
                  for item in 0...items.length
                    @sprites["itembg#{item}"].dispose
                    @sprites["itemname#{item}"].dispose
                    @sprites["itemsprite#{item}"].dispose
                  end
                  items.delete_at(index)
                  pbClearAll
                  pbDrawItemScreen(items)
                  break
                end
              end
            # Checks the decription of the selected item.
            elsif cmd==1
              pbMessage(_INTL("{1}",pbGetMessage(MessageTypes::ItemDescriptions,item)))
            # Skips to the next Pokemon.
            elsif cmd==2
              if pbConfirmMessage(_INTL("Skip {1} without giving it an item?",poke.name))
                @sprites["partyitem#{i}"].visible = true if poke.item>0
                @sprites["rightarrow"].visible    = false
                for item in 0...items.length
                  @sprites["itembg#{item}"].dispose
                  @sprites["itemname#{item}"].dispose
                  @sprites["itemsprite#{item}"].dispose
                end
                pbClearAll
                pbDrawItemScreen(items)
                break
              end
            end
          elsif Input.trigger?(Input::B)
            if pbConfirmMessage(_INTL("Move on without equipping any more items?"))
              ended = true
              break
            end
          end
        end
        break if ended
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Draws the item equip screen.
  #-----------------------------------------------------------------------------
  def pbDrawItemScreen(items)
    for i in 0...items.length
      item = getID(PBItems,items[i])
      spritex = @xpos+80
      spritey = 56+(i*40)
      @sprites["itembg#{i}"] = IconSprite.new(spritex,spritey,@viewport)
      @sprites["itembg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["itemname#{i}"] = IconSprite.new(spritex+37,spritey+9,@viewport)
      @sprites["itemname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["itemname#{i}"].src_rect.set(197,20,150,19)
      @sprites["itemsprite#{i}"] = ItemIconSprite.new(spritex+19,spritey+18,item,@viewport)
      @sprites["itemsprite#{i}"].zoom_x = 0.5
      @sprites["itemsprite#{i}"].zoom_y = 0.5
      @textPos.push([_INTL("{1}",PBItems.getName(item)),spritex+40,spritey+5,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Training Screen
#===============================================================================
  def pbTrainingSelect
    stats = [["Attack Training"  ,1],
             ["Defense Training" ,2],
             ["Sp. Atk Training" ,4],
             ["Sp. Def Training" ,5],
             ["Speed Training"   ,3],
             ["Balanced Training",6]]
    ended = false
    @sprites["prizesel"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,8,346,120,0,_INTL("View Party (Z)"),BASE,SHADOW)
    pbDrawParty($Trainer.party,false)
    pbDrawStatScreen(stats)
    if pbConfirmMessage(_INTL("Would you like to train your Pokémon?\nDoing so may undo thier current training."))
      for i in 0...$Trainer.party.length
        index    = 0
        maxindex = stats.length-1
        poke     = $Trainer.party[i]
        pbMessage(_INTL("Select the type of training {1} should undergo.",poke.name))
        totalev  = 0
        oldstat  = 0
        ypos     = @sprites["partysprite#{i}"].y+3
        for s in 1...6; totalev += poke.ev[s]; end
        for s in 1...6; oldstat = s if poke.ev[s]==252; end
        oldstat = 6 if totalev==250
        oldevs  = poke.ev
        poke.ev = [252,0,0,0,0,0]
        @changesprites.clear
        for p in 0...$Trainer.party.length
          next if poke==$Trainer.party[p]
          ypos = @sprites["partysprite#{p}"].y+3
          pbDrawStatIcons($Trainer.party[p],ypos)
        end
        @textPos.push([_INTL("Select {1}'s training.",poke.name),230,0,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",poke.name),46,(90+(i*40))+5,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
        @sprites["rightarrow"].x = @xpos+44
        @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
        @sprites["rightarrow"].visible = true
        loop do
          Graphics.update
          Input.update
          pbUpdate
          # Scrolls up/down through the stat options.
          if Input.trigger?(Input::DOWN)
            pbPlayCancelSE
            Input.update
            index += 1
            index  = 0 if index>maxindex
            @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
          elsif Input.trigger?(Input::UP)
            pbPlayCancelSE
            Input.update
            index -= 1
            index  = maxindex if index<0
            @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
          # View the Summary of the party.
          elsif Input.trigger?(Input::A)
            pbDynAdventureState.pbSummary($Trainer.party,i,@sprites)
          end
          # Select a training course.
          if Input.trigger?(Input::C)
            Input.update
            cmd  = 0
            cmd  = pbShowCommands(["Train","Details","Don't Train","Back"],cmd)
            # Trains up the selected stat for the Pokemon.
            if cmd==0
              statsel  = stats[index][1]
              statname = (statsel==6) ? "balanced" : PBStats.getName(statsel)
              if statsel==oldstat
                pbMessage(_INTL("{1} already has {2} training.",poke.name,statname))
              else
                if pbConfirmMessage(_INTL("Give {1} some {2} training?",poke.name,statname))
                  pbSEPlay(pbCryFile(poke.species,poke.form))
                  oldstats = [0,poke.attack,poke.defense,poke.speed,poke.spatk,poke.spdef]
                  if statsel==6; poke.ev = [252,50,50,50,50,50] 
                  else; poke.ev[statsel] = 252
                  end
                  poke.calcStats
                  newstats = [0,poke.attack,poke.defense,poke.speed,poke.spatk,poke.spdef]
                  pbWait(25)
                  pbMessage(_INTL("{1} unlearned its previous training.\\nAnd...\1",poke.name)) if oldstat>0
                  pbSEPlay("Pkmn move learnt")
                  if statsel==6
                    for s in 1...newstats.length
                      next if s==oldstat
                      statdiff = newstats[s]-oldstats[s]
                      pbMessage(_INTL("{1}'s training increased its {2} by {3} point(s)!",poke.name,PBStats.getName(s),statdiff))
                    end
                  else
                    statdiff = newstats[statsel]-oldstats[statsel]
                    pbMessage(_INTL("{1}'s training increased its {2} by {3} point(s)!",poke.name,statname,statdiff))
                  end
                  @sprites["rightarrow"].visible = false
                  for s in 0...stats.length
                    @sprites["statbg#{s}"].dispose
                    @sprites["statname#{s}"].dispose
                  end
                  stats.delete_at(index)
                  pbClearAll
                  @menudisplay.clear
                  pbDrawStatScreen(stats)
                  break
                end
              end
            elsif cmd==1
              if oldstat==6; pbMessage(_INTL("{1} is currently slightly trained across all stats.",poke.name))
              elsif oldstat>0; pbMessage(_INTL("{1} is currently fully trained in the {2} stat.",poke.name,PBStats.getName(oldstat)))
              else; pbMessage(_INTL("{1} doesn't currently have any training.",poke.name))
              end
            # Skips to the next Pokemon.
            elsif cmd==2
              if pbConfirmMessage(_INTL("Skip {1} without giving it any training?",poke.name))
                @sprites["rightarrow"].visible = false
                for s in 0...stats.length
                  @sprites["statbg#{s}"].dispose
                  @sprites["statname#{s}"].dispose
                end
                pbClearAll
                @menudisplay.clear
                poke.ev = oldevs
                poke.calcStats
                pbDrawStatScreen(stats)
                break
              end
            end
          elsif Input.trigger?(Input::B)
            if pbConfirmMessage(_INTL("Move on without any further training?"))
              poke.ev = oldevs
              poke.calcStats
              ended = true
              break
            end
          end
        end
        break if ended
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws the training screen and stat icons.
  #-----------------------------------------------------------------------------
  def pbDrawStatScreen(stats)
    for i in 0...$Trainer.party.length
      ypos = @sprites["partysprite#{i}"].y+3
      pbDrawStatIcons($Trainer.party[i],ypos)
    end
    for i in 0...stats.length
      name    = stats[i][0]
      icon    = stats[i][1]-1
      spritex = @xpos+80
      spritey = 56+(i*40)
      @sprites["statbg#{i}"] = IconSprite.new(spritex,spritey,@viewport)
      @sprites["statbg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["statname#{i}"] = IconSprite.new(spritex+37,spritey+9,@viewport)
      @sprites["statname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["statname#{i}"].src_rect.set(197,20,150,19)
      @menudisplay.blt(spritex+3,spritey+3,@statbitmap.bitmap,Rect.new(icon*32,0,32,32))
      @textPos.push([_INTL("{1}",name),spritex+40,spritey+5,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Tutor Screen
#===============================================================================
  def pbTutorSelect
    @sprites["pokeslot#{1}"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,8,346,120,0,_INTL("View Party (Z)"),BASE,SHADOW)
    drawTextEx(@statictext,220,-4,400,0,_INTL("Select a party member to tutor."),BASE,SHADOW)
    pbDrawParty($Trainer.party)
    if pbConfirmMessage(_INTL("Would you like to tutor a Pokémon?"))
      pbMessage(_INTL("Select a party member to tutor."))
      newmoves = []
      for i in 0...$Trainer.party.length
        poke = $Trainer.party[i]
        pokemoves  = []
        tutormoves = []
        for m in poke.moves; pokemoves.push(m.id); end
        movelist  = pbGetMaxRaidMoves(poke.species,poke.form,true)
        raidmoves = movelist[0]+movelist[1]+movelist[3]
        for m in 0...raidmoves.length
          category = pbGetMoveData(raidmoves[m],MOVE_CATEGORY)
          next if pokemoves.include?(raidmoves[m])
          next if category!=0 && poke.ev[1]==252
          next if category!=1 && poke.ev[4]==252
          next if category!=2 && (poke.ev[2]==252 || poke.ev[5]==252)
          tutormoves.push(raidmoves[m])
        end
        move = (tutormoves.length>0) ? tutormoves[rand(tutormoves.length)] : nil
        newmoves.push(move)
      end
      index    = 0
      maxindex = $Trainer.party.length-1
      @sprites["leftarrow"].y = 95
      @sprites["leftarrow"].visible = true
      pbDrawTutorScreen($Trainer.party[index],newmoves[index])
      loop do
        Graphics.update
        Input.update
        pbUpdate
        # Scrolls up/down through your rental party.
        if Input.trigger?(Input::DOWN)
          pbPlayCancelSE
          Input.update
          index += 1
          index  = 0 if index>maxindex
          @sprites["leftarrow"].y = 95+(index*40)
          pbDrawTutorScreen($Trainer.party[index],newmoves[index])
        elsif Input.trigger?(Input::UP)
          pbPlayCancelSE
          Input.update
          index -= 1
          index  = maxindex if index<0
          @sprites["leftarrow"].y = 95+(index*40)
          pbDrawTutorScreen($Trainer.party[index],newmoves[index])
        # View the Summary of the current rental party.
        elsif Input.trigger?(Input::A)
          pbDynAdventureState.pbSummary($Trainer.party,index,@sprites)
        end
        # Select a party member.
        if Input.trigger?(Input::C)
          Input.update
          poke = $Trainer.party[index]
          if newmoves[index]
            cmd = 0
            cmd = pbShowCommands(["Teach","Details","Summary","Back"],cmd)
            # Select a move to replace.
            if cmd==0
              if pbConfirmMessage(_INTL("Teach {1} the move {2}?",poke.name,PBMoves.getName(newmoves[index])))
                pbSEPlay(pbCryFile(poke.species,poke.form))
                pbWait(25)
                if poke.numMoves<4
                  pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",poke.name,PBMoves.getName(newmoves[index])))
                  poke.pbLearnMove(newmoves[index])
                  break
                else
                  forgetMove = @scene.pbForgetMove(poke,newmoves[index])
                  if forgetMove>=0
                    oldMoveName = PBMoves.getName(poke.moves[forgetMove].id)
                    pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
                    pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",poke.name,oldMoveName))
                    pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",poke.name,PBMoves.getName(newmoves[index])))
                    poke.moves[forgetMove] = PBMove.new(newmoves[index])
                    break
                  end
                end
              end
            # Display the description of the new move.
            elsif cmd==1
              pbMessage(_INTL("{1}",pbGetMessage(MessageTypes::MoveDescriptions,newmoves[index])))
            # View the Summary of the selected party member.
            elsif cmd==2
              pbDynAdventureState.pbSummary($Trainer.party,index,@sprites)
            end
          else
            pbMessage(_INTL("{1} can't be taught any other moves.",poke.name))
          end
        elsif Input.trigger?(Input::B)
          break if pbConfirmMessage(_INTL("Move on without tutoring any Pokémon?"))
        end
      end
    end
  end  
  
  #-----------------------------------------------------------------------------
  # Draws all the Pokemon data for a tutor screen.
  #-----------------------------------------------------------------------------
  def pbDrawTutorScreen(pokemon,newmove)
    slot = 1
    textPos = []
    spritex = @xpos+12
    spritey = @ypos+(slot*114)
    @menudisplay.clear
    @changesprites.clear
    if newmove
      @sprites["slotsel"].y = @sprites["pokeslot#{slot}"].y
      @sprites["slotsel"].visible = true
      newtag = [["Graphics/Pictures/Dynamax/lairmenu_slot",@xpos+10,spritey-15,165,0,60,20]]
      pbDrawImagePositions(@changesprites,newtag)
      movedata = pbGetMoveData(newmove)
      type     = movedata[MOVE_TYPE]
      category = movedata[MOVE_CATEGORY]
      totalpp  = movedata[MOVE_TOTAL_PP]
      damage   = movedata[MOVE_BASE_DAMAGE]
      accuracy = movedata[MOVE_ACCURACY]
      damage   = (damage>0) ? damage : "---"
      accuracy = (accuracy>0) ? accuracy : "---"
      typerect = Rect.new(0,type*28,64,28)
      catrect  = Rect.new(0,category*28,64,28)
      @changesprites.blt(spritex-4,spritey+42,@typebitmap.bitmap,typerect)
      @changesprites.blt(spritex-4,spritey+74,@categorybitmap.bitmap,catrect)
      textPos.push([_INTL("{1}",PBMoves.getName(newmove)),spritex-4,spritey+8,0,BASE,SHADOW])
      textPos.push([_INTL("BP: {1}",damage),spritex+72,spritey+40,0,BASE,SHADOW])
      textPos.push([_INTL("AC: {1}",accuracy),spritex+72,spritey+60,0,BASE,SHADOW])
      textPos.push([_INTL("PP: {1}",totalpp),spritex+72,spritey+80,0,BASE,SHADOW])
      for m in 0...pokemon.moves.length
        move = PBMoves.getName(pokemon.moves[m].id)
        xpos = spritex+160
        ypos = (spritey+6)+(m*22)
        textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
      end
    else
      @sprites["slotsel"].visible = false
      textPos.push([_INTL("No moves to learn."),spritex+80,spritey+40,0,SHADOW,BASE])
    end
    pbSetSmallFont(@menudisplay)
    pbDrawTextPositions(@menudisplay,textPos)
  end
  
#===============================================================================
# Max Lair - Prize Screen
#===============================================================================
  def pbPrizeSelect(prizes)
    @sprites["prizesel"].visible = true
    for i in 0...prizes.length
      @sprites["partybg#{i}"].x   = @xpos+100
      @sprites["partybg#{i}"].y  -= 30
      @sprites["partyname#{i}"].x = @sprites["partybg#{i}"].x+37
      @sprites["partyname#{i}"].y = @sprites["partybg#{i}"].y+9
    end
    pbDrawParty(prizes)
    pbMessage(_INTL("You may select one of the captured Pokémon to keep."))
    index    = 0
    maxindex = prizes.length-1
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 190
    @sprites["pokemon"].setPokemonBitmap(prizes[index])
    @sprites["rightarrow"].x = @xpos+60
    @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
    @sprites["rightarrow"].visible = true
    @sprites["prizebg"].visible    = true
    drawTextEx(@statictext,250,-4,400,0,_INTL("Select one Pokémon to keep."),BASE,SHADOW)
    drawTextEx(@statictext,14,346,120,0,_INTL("View PKMN (Z)"),BASE,SHADOW) if index>-1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      # Scrolls up/down through the prize options.
      if Input.trigger?(Input::DOWN)
        pbPlayCancelSE
        Input.update
        index += 1
        index  = 0 if index>maxindex
        @sprites["pokemon"].setPokemonBitmap(prizes[index])
        @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
      elsif Input.trigger?(Input::UP)
        pbPlayCancelSE
        Input.update
        index -= 1
        index  = maxindex if index<0
        @sprites["pokemon"].setPokemonBitmap(prizes[index])
        @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
      # View the Summary of a prize Pokemon.
      elsif Input.trigger?(Input::A) && index>-1
        pbDynAdventureState.pbSummary(prizes,index,@sprites)
      end
      # Select a prize Pokemon.
      if Input.trigger?(Input::C)
        Input.update
        cmd = 0
        cmd = pbShowCommands(["Select","Summary","Back"],cmd)
        # Acquires the selected prize Pokemon.
        if cmd==0
          poke = prizes[index]
          if pbConfirmMessage(_INTL("So, you'd like to take {1} with you?",poke.name))
            pbSEPlay(pbCryFile(poke.species,poke.form))
            pbWait(25)
            pbMessage(_INTL("You returned any remaining captured Pokémon and your rental party."))
            pbNicknameAndStore(poke)
            break
          end
        # View the Summary of the selected Pokemon.
        elsif cmd==1
          pbDynAdventureState.pbSummary(prizes,index,@sprites)
        end
      elsif Input.trigger?(Input::B)
        break if pbConfirmMessage(_INTL("Leave without taking any captured Pokémon with you?"))
      end
    end
  end
end
  
#-------------------------------------------------------------------------------
# Used for accessing various Max Lair menu screens.
#-------------------------------------------------------------------------------
# When params[0]==0; opens rental screen.
# When params[0]==1; opens exchange screen.
# When params[0]==2; opens prize screen.
# When params[0]==3; opens item screen.
# When params[0]==4; opens training screen.
# When params[0]==5; opens tutor screen.
def pbMaxLairMenu(params)
  pbFadeOutIn(99999){
    scene  = MaxLairEventScene.new
    screen = MaxLairScreen.new(scene)
    partysize = $Trainer.party.length
    case params[0]
    when 0; screen.pbStartRentalScreen(params[1],params[2])
    when 1; screen.pbStartSwapScreen(partysize,params[1])
    when 2; screen.pbStartPrizeScreen(params[1])
    when 3; screen.pbStartItemScreen(partysize)
    when 4; screen.pbStartTrainingScreen(partysize)
    when 5; screen.pbStartTutorScreen(partysize)
    end
  }
end

class MaxLairScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartRentalScreen(size,level)
    @scene.pbStartScene(size,level)
    @scene.pbRentalSelect
    @scene.pbEndScene
  end
  
  def pbStartSwapScreen(size,pokemon)
    @scene.pbStartScene(size,nil)
    @scene.pbSwapSelect(pokemon)
    @scene.pbEndScene
  end
  
  def pbStartPrizeScreen(prizes)
    @scene.pbStartScene(prizes.length,nil)
    @scene.pbPrizeSelect(prizes)
    @scene.pbEndScene
  end
  
  def pbStartItemScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbItemSelect
    @scene.pbEndScene
  end
  
  def pbStartTrainingScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbTrainingSelect
    @scene.pbEndScene
  end
  
  def pbStartTutorScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbTutorSelect
    @scene.pbEndScene
  end
end

#-------------------------------------------------------------------------------
# Used for accessing the Max Lair Map screen.
#-------------------------------------------------------------------------------
class LairMapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(map)
    @scene.pbStartMapScene(map)
    @scene.pbEndScene
  end
end

def pbMaxLairMap(map)
  scene  = LairMapScene.new
  screen = LairMapScreen.new(scene)
  screen.pbStartScreen(map)
end