################################################################################
# SCUnorthodoxBattles
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of battles rule changers: 
# - inverse battles (inverses the effectiveness of moves)
# - random terrain / weather (changes the weather/terrain at the end of a turn)
# - disallow all mechanics (+ enable them). 
################################################################################


#==============================================================================
# Inverse Battles
#==============================================================================

class PokeBattle_Battle
  attr_accessor :inverseBattle
  attr_accessor :inverseSTAB
  
  alias __inversebattle__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __inversebattle__init(scene,p1,p2,player,opponent)
    @inverseBattle = false 
    @inverseSTAB = false 
  end 
  
  def invertEffectivenessOne(eff)
    case eff
    when PBTypeEffectiveness::INEFFECTIVE, PBTypeEffectiveness::NOT_EFFECTIVE_ONE
      eff = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
      
    when PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
      eff = PBTypeEffectiveness::NOT_EFFECTIVE_ONE
      
    end 
    return eff 
  end 
  
end 

alias __inversebattle__pbPrepareBattle pbPrepareBattle
def pbPrepareBattle(battle)
  __inversebattle__pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
  # Prepare for inverse battle (invert type effectiveness) (STRAT)
  battle.inverseBattle = battleRules["inverseBattle"] if !battleRules["inverseBattle"].nil?
  # STAB apply to moves with different types (STRAT)
  battle.inverseSTAB = battleRules["inverseSTAB"] if !battleRules["inverseSTAB"].nil?
end 




#==============================================================================
# Random Terrain / Weather
#==============================================================================

class PokeBattle_Battle
  attr_accessor :changingTerrain
  attr_accessor :changingWeather
  
  alias __unorthodox__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __unorthodox__init(scene,p1,p2,player,opponent)
    @changingTerrain = false 
    @changingWeather = false 
  end 
  
  def scSelectRandomTerrain
    terrains = [
      PBBattleTerrains::Electric,
      PBBattleTerrains::Grassy,
      PBBattleTerrains::Misty,
      PBBattleTerrains::Psychic,
      PBBattleTerrains::Magnetic
    ]
    newTerrain = terrains[rand(terrains.length)]
    pbStartTerrain(nil,newTerrain,true)
  end 
  
  
  alias __unorthodox__pbEORTerrain pbEORTerrain
  def pbEORTerrain
    if @changingTerrain
      scSelectRandomTerrain
    else
      __unorthodox__pbEORTerrain
    end 
  end 
  
  def scSelectRandomWeather
    weathers = [
      PBWeather::Sun,
      PBWeather::Rain,
      PBWeather::Sandstorm,
      PBWeather::Hail,
      PBWeather::Fog,
      PBWeather::Tempest
    ]
    newWeather = weathers[rand(weathers.length)]
    pbStartWeather(nil,newWeather,true)
  end 
  
  
  alias __unorthodox__pbEORWeather pbEORWeather
  def pbEORWeather(priority)
    if @changingWeather
      scSelectRandomWeather
    else
      __unorthodox__pbEORWeather(priority)
    end 
  end 
end 

alias __unorthodox__prepare pbPrepareBattle
def pbPrepareBattle(battle)
  __unorthodox__prepare(battle)
  battleRules = $PokemonTemp.battleRules
  # Whether the terrain changes at the end of each turn (default: false) (STRAT)
  battle.changingTerrain = battleRules["changingTerrain"] if !battleRules["changingTerrain"].nil?
  # Whether the weather changes at the end of each turn (default: false) (STRAT)
  battle.changingWeather = battleRules["changingWeather"] if !battleRules["changingWeather"].nil?
end 





#==============================================================================
# Control all mechanics.
#==============================================================================

def scDisableAllMechanics
  $game_switches[NO_Z_MOVE] = true
  $game_switches[NO_ULTRA_BURST] = true
  $game_switches[NO_DYNAMAX] = true
  $game_switches[NO_MEGA_EVOLUTION] = true
  $game_switches[NO_ASSISTANCE] = true
end 

def scEnableAllMechanics
  $game_switches[NO_Z_MOVE] = false
  $game_switches[NO_ULTRA_BURST] = false
  $game_switches[NO_DYNAMAX] = false
  $game_switches[NO_MEGA_EVOLUTION] = false
  $game_switches[NO_ASSISTANCE] = false
end 






#==============================================================================
# Battle Royale
# Every one fight everyone.
#==============================================================================
class PokeBattle_Battle
  attr_accessor :battleRoyale
  
  alias __battleroyale__init initialize
  def initialize(scene,p1,p2,player,opponent)
    __battleroyale__init(scene,p1,p2,player,opponent)
    @battleRoyale = false 
  end 
  
  
  def makeBattleRoyale
    @battleRoyale = true 
  end 
  
  # def transferTrainersForBattleRoyale
    # return if !@battleRoyale
    # # Transfers all other trainers to opponents.
    # for t in 0...@player.length
      # next if t == 0
      # @opponent.push(@player[t])
    # end 
    # # Deletes other trainers.
    # @player = [@player[0]]
  # end 
  
  # To include to pbStartBattleSendOut
  def pbStartBattleRoyaleSendOut
    showError = false
    if @opponent.length == 2
      if @player.length == 2 # 2v2
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are starting a Battle Royale against {1}, {2} and {3}!",
           @opponent[0].fullname,@opponent[1].fullname,@player[1].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname,@player[1].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname,@player[1].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname,@opponent[1].fullname,@player[1].fullname))
          end
        end
      elsif @player.length == 1 # 1v2
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are starting a Battle Royale against {1} and {2}!",
           @opponent[0].fullname,@opponent[1].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname,@opponent[1].fullname))
          end
        end
      else 
        showError = true
      end
    elsif @opponent.length == 3
      if @player.length == 2 # 2v3
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are starting a Battle Royale against {1}, {2}, {3} and {4}!",
           @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname,@player[1].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,
            @opponent[1].fullname,@opponent[2].fullname,@player[1].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,
            @opponent[1].fullname,@opponent[2].fullname,@player[1].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname,
              @opponent[1].fullname,@opponent[2].fullname,@player[1].fullname))
          end
        end
      else
        showError = true
      end 
    else 
      showError = true
    end 
    raise _INTL("Battle Royale is undefined for opponent size {1} / ally size {2}", @opponent.length, @player.length) if showError
  end 
  # Also edited the function pbEORShiftDistantBattlers in 025_SCPokeBattle_CompleteFormats
  
  # alias __battleroyale__opposes opposes?
  # def opposes?(idxBattler1,idxBattler2=0)
    # idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
    # idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
    # return idxBattler1 != idxBattler2 if @battleRoyale
    # return __battleroyale__opposes(idxBattler1,idxBattler2)
  # end
  
  alias __battleroyale__nearBattlers nearBattlers?
  def nearBattlers?(idxBattler1,idxBattler2)
    # Everyone is near.
    return idxBattler1!=idxBattler2 if @battleRoyale
    return __battleroyale__nearBattlers(idxBattler1,idxBattler2)
  end 
  
  alias __battleroyale__pbGetOwnerIndexFromBattlerIndex pbGetOwnerIndexFromBattlerIndex
  def pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @battleRoyale
      return (idxBattler - (idxBattler % 2)) / 2
    end 
    return __battleroyale__pbGetOwnerIndexFromBattlerIndex(idxBattler)
  end 
  
  alias __battleroyale__pbGetOwnerFromBattlerIndex pbGetOwnerFromBattlerIndex
  def pbGetOwnerFromBattlerIndex(idxBattler)
    if @battleRoyale
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return (idxBattler % 2 == 1) ? @opponent[idxTrainer] : @player[idxTrainer]
    end 
    return __battleroyale__pbGetOwnerFromBattlerIndex(idxBattler)
  end
  
  # Only used for the purpose of an error message when one trainer tries to
  # switch another trainer's Pokémon.
  alias __battleroyale__pbGetOwnerFromPartyIndex pbGetOwnerFromPartyIndex
  def pbGetOwnerFromPartyIndex(idxBattler,idxParty)
    if @battleRoyale
      idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
      return (idxBattler % 2 == 1) ? @opponent[idxTrainer] : @player[idxTrainer]
    end 
    return __battleroyale__pbGetOwnerFromPartyIndex(idxBattler,idxParty)
  end
  
  alias __battleroyale__pbGetOwnerName pbGetOwnerName
  def pbGetOwnerName(idxBattler)
    if @battleRoyale
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return (idxBattler % 2 == 0) ? @player[idxTrainer].name : @opponent[idxTrainer].name
    end 
    return __battleroyale__pbGetOwnerName(idxBattler)
  end

  alias __battleroyale__pbParty pbParty
  def pbParty(idxBattler)
    if @battleRoyale
      return (idxBattler % 2 == 1) ? @party2 : @party1
    end 
    return __battleroyale__pbParty(idxBattler)
  end

  alias __battleroyale__pbOpposingParty pbOpposingParty
  def pbOpposingParty(idxBattler)
    if @battleRoyale
      return (idxBattler % 2 == 1) ? @party1 : @party2
    end 
    return __battleroyale__pbOpposingParty(idxBattler)
  end

  alias __battleroyale__pbPartyOrder pbPartyOrder
  def pbPartyOrder(idxBattler)
    if @battleRoyale
      return (idxBattler % 2 == 1) ? @party2order : @party1order
    end 
    return __battleroyale__pbPartyOrder(idxBattler)
  end

  alias __battleroyale__pbPartyStarts pbPartyStarts
  def pbPartyStarts(idxBattler)
    if @battleRoyale
      return (idxBattler % 2 == 1) ? @party2starts : @party1starts
    end 
    return __battleroyale__pbPartyStarts(idxBattler)
  end
  
  # Should I include this ?
  alias __battleroyale__eachSameSideBattler eachSameSideBattler
  def eachSameSideBattler(idxBattler=0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    if @battleRoyale
      @battlers.each { |b| yield b if b && !b.fainted? && b.index%2 == idxBattler%2 }
    else 
      __battleroyale__eachSameSideBattler(idxBattler) { |b| yield b }
    end 
  end

  alias __battleroyale__eachOtherSideBattler eachOtherSideBattler
  def eachOtherSideBattler(idxBattler=0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    if @battleRoyale
      @battlers.each { |b| yield b if b && !b.fainted? && b.index%2 != idxBattler%2 }
    else 
      __battleroyale__eachOtherSideBattler(idxBattler) { |b| yield b }
    end 
  end
  
  alias __battleroyale__pbEORShiftDistantBattlers pbEORShiftDistantBattlers
  def pbEORShiftDistantBattlers
    # No shifting needed in Battle Royale because everyone is close to everyone.
    return if @battleRoyale 
    return __battleroyale__pbEORShiftDistantBattlers
  end 
end 

class PokeBattle_Battler
  alias __battleroyale__opposes2 opposes?
  def opposes?(i=0)
    i = i.index if i.respond_to?("index")
    return @index != i if @battle.battleRoyale
    return __battleroyale__opposes2(i)
  end
  
  def oppositeSide?(i=0) # New function. 
    return __battleroyale__opposes2(i)
  end 
  
  
  # Returns whether the given position/battler is near to self.
  alias __battleroyale__near near?
  def near?(i)
    i = i.index if i.respond_to?("index")
    return @index != i if @battleRoyale
    return __battleroyale__near(i)
  end
  
  alias __battleroyale__pbThis pbThis
  def pbThis(lowerCase=false)
    if @battle.battleRoyale && opposes?
      case @index
      when 1 
        return _INTL("{1}'s {2}",@battle.opponent[0].name, name) 
      when 2
        return _INTL("{1}'s {2}",@battle.player[1].name, name) 
      when 3
        return _INTL("{1}'s {2}",@battle.opponent[1].name, name) 
      when 4
        return _INTL("{1}'s {2}",@battle.player[2].name, name) 
      when 5
        return _INTL("{1}'s {2}",@battle.opponent[2].name, name) 
      end 
    end 
    return __battleroyale__pbThis(lowerCase)
  end
  
  alias __battleroyale__pbTeam pbTeam
  def pbTeam(lowerCase=false)
    if @battle.battleRoyale && opposes?
      trainer_name = (lowerCase ? "the" : "The") + " opponent's"
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(@index)
      
      if idxBattler % 2 == 0
        trainer_name = @battle.player[idxTrainer].name
      else 
        trainer_name = @battle.opponent[idxTrainer].name
      end 
      
      return _INTL("{1}'s team",trainer_name, name)
    end 
    return __battleroyale__pbTeam(lowerCase)
  end 
end 

alias __battleroyale__prepare pbPrepareBattle
def pbPrepareBattle(battle)
  __battleroyale__prepare(battle)
  battleRules = $PokemonTemp.battleRules
  # Battle Royale mode.
  battle.makeBattleRoyale if battleRules["battleRoyale"]
end 




# def scBattleRoyale(trainerID1, trainerName1, trainerID2, trainerName2, trainerID3 = nil, trainerName3 = nil,
                  # trainerPartyID1=-1, endSpeech1 = nil, trainerPartyID2=-1, endSpeech2=nil, 
                  # trainerPartyID3=-1, endSpeech3 = nil, canLose=true, outcomeVar=1)
  # # Set some battle rules
  # setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  # setBattleRule("canLose") if canLose
  # setBattleRule("notinternal")
  # setBattleRule("battleRoyale")
  
  # # Take care of partners and such.
  # if $PokemonGlobal.partner
    # setBattleRule("2v2")
  # elsif !trainerID3.nil? && !trainerName3.nil?
    # pbRegisterPartner(trainerID3,trainerName3,trainerPartyID3)
    # setBattleRule("2v2")
  # else 
    # setBattleRule("1v2")
  # end
  
  # # Music management: the default BGM interferes with battle music
  # bgm = $game_system.getPlayingBGM
  # $game_system.setDefaultBGM(nil)
  
  # # Perform the battle
  # pbHealAll
  # decision = pbTrainerBattleCore(
     # [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     # [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
  # )
  # pbHealAll
  
  # # Music management: the default BGM interferes with battle music
  # $game_system.setDefaultBGM(bgm)
  
  # pbDeregisterPartner
  # # Return true if the player won the battle, and false if any other result
  # return (decision==1)
# end


def scBattleRoyale(trainerID1, trainerName1, trainerID2, trainerName2, 
                  trainerID3 = nil, trainerName3 = nil, trainerID4 = nil, trainerName4 = nil,
                  trainerPartyID1=-1, endSpeech1 = nil, trainerPartyID2=-1, endSpeech2=nil, 
                  trainerPartyID3=-1, endSpeech3 = nil, trainerPartyID4=-1, endSpeech4 = nil, 
                  canLose=true, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("notinternal")
  setBattleRule("battleRoyale")
  
  threeOnOppositeSide = false
  
  if !trainerID4.nil? && !trainerName4.nil?
    # Four trainers, last one is on the player's side. 
    pbRegisterPartner(trainerID4,trainerName4,trainerPartyID4)
    setBattleRule("2v3")
    threeOnOppositeSide = true
    
  elsif !trainerID3.nil? && !trainerName3.nil?
    if $PokemonGlobal.partner
      threeOnOppositeSide = true
      setBattleRule("2v3")
    else 
      # Last trainer, put it on the player's side. 
      pbRegisterPartner(trainerID3,trainerName3,trainerPartyID3)
      setBattleRule("2v2")
    end 
  elsif $PokemonGlobal.partner
    setBattleRule("2v2")
  else 
    setBattleRule("1v2")
  end
  
  # Take care of partners and such.
  if !trainerID4.nil? && !trainerName4.nil?
  elsif $PokemonGlobal.partner.nil?
    raise _INTL("Error: scBattleRoyale5 either requires 4 trainers or a partner.\nSpecify a partner or give trainerID4 and trainerName4.")
  end
  
  # Music management: the default BGM interferes with battle music
  bgm = $game_system.getPlayingBGM
  $game_system.setDefaultBGM(nil)
  
  # Perform the battle
  pbHealAll
  if threeOnOppositeSide
    decision = pbTrainerBattleCore(
       [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
       [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
       [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
    )
  else 
    decision = pbTrainerBattleCore(
       [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
       [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
    )
  end 
  pbHealAll
  
  # Music management: the default BGM interferes with battle music
  $game_system.setDefaultBGM(bgm)
  
  pbDeregisterPartner
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end
