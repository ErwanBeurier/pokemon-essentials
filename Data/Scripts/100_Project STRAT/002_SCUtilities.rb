###############################################################################
# SCUtilities
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains a few functions that I find useful, or whose existing 
# implementation I don't like.
###############################################################################



#------------------------------------------------------------------------------
# Returns a random subset of n non-repeated elements from the array.
#------------------------------------------------------------------------------
def scsample(a, n)
  n = a.length if n < 0
  
	if n == 1 && a.is_a?(Array) && a.length >= 1
		return a[rand(a.length)]
	end 
	
  indices = scsamplei(a, n)
	a_sample = []
	
	# raise _INTL("indices.length = {1}, a.length = {2}", indices.length, a.length)
	
	indices.each { |i| a_sample.push(a[i]) }
	
	return a_sample
end 



def scsamplei(a, n)
  # Returns the choice of indices of elements of a. 
	if !a.is_a?(Array)
		raise _INTL("In scsample: not an array.")
	end 
	if a.length == 0
		raise _INTL("In scsample: empty array.")
	end 
  
  n = a.length if n > a.length
  
	cpt = 0
	indices = []
	
	for o in a
		indices.push(cpt)
		cpt += 1
	end 
	
	for i in 0...cpt
		j = rand(cpt)
		temp = indices[j]
		indices[j] = indices[i]
		indices[i] = temp 
	end 
  
  return indices[0...n] 
end 



# -----------------------------------------------------------------------------
# DEBUG TOOLS 
# -----------------------------------------------------------------------------
# Debug tool: string showing the content of the given d 
# Used to scan Arrays of Hashes of Arrays.
def scToStringRec(d)
  if d.is_a?(Array)
    s = "[ "
    d.each { |val|
      temp = scToStringRec(val)
      s += _INTL("{1} ; ", temp)
    }
    s += "]"
    return s
  
  elsif d.is_a?(Hash)
    s = "{"
    put_comma = false
    d.each { |k,v|
      temp = scToStringRec(v)
      s += ", " if put_comma
      s += _INTL("{1} => {2}", k, temp)
      put_comma = true 
    }
    s += "}\n"
    return s
  elsif d.is_a?(PBDynAdventureRoom)
    return d.desc 
  else 
    return _INTL("{1}", d)
  end 
end 

# Debug tool: string showing the content of the given d 
# Used to scan Arrays of Hashes of Arrays.
# Prints the result in a file. 
def scToString(d, title = nil, filename = "errorlog.txt", silent = false)
  File.open(filename, "a") { |f|
    f.write(title + "\n") if title.is_a?(String)
    f.write(scToStringRec(d) + "\n")
  }
  pbMessage("Gladys I love you") if !silent
end 

def scLog(d, title = nil)
  scToString(d, title, "errorlog.txt", true)
end 


# -----------------------------------------------------------------------------
# Print all variables and switches in a file. 
# -----------------------------------------------------------------------------
# Allow loops on game variables.
class Game_Variables
  def each_with_index
    @data.each_with_index { |v, i| yield v, i }
  end 
  def length 
    return @data.length 
  end 
end

# Allow loops on game switches.
class Game_Switches
  def each_with_index
    @data.each_with_index { |v, i| yield v, i }
  end 
  def length 
    return @data.length 
  end 
end 

# Prints all game variables and game switches. 
def pbSaveVariablesToTxt
  File.open("variables.txt","w") { |f| 
    f.write(_INTL("#============================================\n"))
    f.write(_INTL("# Date: {1}\n", Time.now))
    f.write(_INTL("#============================================\n"))
    f.write(_INTL("# Variables (length={1})\n", $game_variables.length))
    f.write(_INTL("#============================================\n"))
    
    $game_variables.each_with_index { |val, i|
      f.write(_INTL("{1}= {2}", i.to_s.ljust(5), val))
      f.write("\n")
    }
    
    f.write(_INTL("#============================================\n"))
    f.write(_INTL("# Switches (length={1})\n", $game_switches.length))
    f.write(_INTL("#============================================\n"))
    
    $game_switches.each_with_index { |val, i|
      f.write(_INTL("{1}= {2}", i.to_s.ljust(5), val))
      f.write("\n")
    }
  }
  pbMessage("Done writing variables.txt.")
end 





def scGenerateHiddenPowerConversion
  # Generates a table that associates types with IV combinations.
  types = []
  for i in 0..PBTypes.maxValue
    next if PBTypes.isPseudoType?(i)
    next if isConst?(i,PBTypes,:NORMAL) || isConst?(i,PBTypes,:SHADOW)
    types.push(i)
  end
  
  File.open("hidden_power.txt", "w") { |f|
    # Header
    f.write("Type".ljust(10))
    f.write("HP".ljust(4))
    f.write("Atk".ljust(4))
    f.write("Def".ljust(4))
    f.write("Spd".ljust(4))
    f.write("SpA".ljust(4))
    f.write("SpD".ljust(4))
    f.write("\n")
    
    for num in 0..63
      iv = Array.new(6,30)
      
      for j in 0..5
        iv[j] += (num >> j) &1 # Note: inverted order:
      end 
      
      type = scHiddenPower2(iv, types)
      
      f.write(PBTypes.getName(type).ljust(10))
      
      for j in 0..5
        f.write(iv[j].to_s.ljust(4))
      end 
      f.write("\n")
    end
  }
  pbMessage("Written.")
end 


def scHiddenPower2(iv, types)
  # NOTE: This allows Hidden Power to be Fairy-type (if you have that type in
  #       your game). I don't care that the official games don't work like that.
  idxType = 0
  idxType |= (iv[PBStats::HP]&1)
  idxType |= (iv[PBStats::ATTACK]&1)<<1
  idxType |= (iv[PBStats::DEFENSE]&1)<<2
  idxType |= (iv[PBStats::SPEED]&1)<<3
  idxType |= (iv[PBStats::SPATK]&1)<<4
  idxType |= (iv[PBStats::SPDEF]&1)<<5
  idxType = (types.length-1)*idxType/63
  return types[idxType]
end



def pbControlledWildBattle(species, level, moves = nil, ability = nil, 
                          nature = nil, gender = nil, item = nil, shiny = nil, 
                          dynamax = false, gmax = false,
                          outcomeVar=1, canRun=true, canLose=false)
  # Create an instance
  species = getConst(PBSpecies, species)
  pkmn = PokeBattle_Pokemon.new(species, level)
  
  # Give moves.
  # Should be a list of moves:
  if moves
    for i in 0...4
      pkmn.moves[i] = PBMove.new(getConst(PBMoves,moves[i])) if moves[i]
    end 
  end 
  
  # Give ability
  # NOTE that the ability should be 0, 1 or 2.
  pkmn.setAbility(ability) if [0, 1, 2].include?(ability)
  
  # Give nature
  pkmn.setNature(nature) if nature
  
  # Give gender
  # 0 if male, 1 if female.
  pkmn.setGender(gender) if gender
  
  # Give item 
  pkmn.item = item if item 
  
  # Shiny or not.
  pkmn.makeShiny if shiny
  
  # Handle the dynamax and gmax forms.
  dynamax = dynamax || gmax
  if dynamax
    pbResetRaidSettings
    setBattleRule(sprintf("%dv%d",MAXRAID_SIZE,1))
    $game_switches[MAXRAID_SWITCH] = true 
    storedPkmn = pbMapInterpreter.get_character(0).id + MAXRAID_PKMN
    pkmn.giveGMaxFactor if pkmn.hasGmax? && gmax
    $game_variables[storedPkmn] = pkmn
  end 
  
  # Start the battle.
  # This is copied from pbWildBattle. 
  
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(pkmn)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  
  # Reset dynamax stuff.
  pbResetRaidSettings
  
  return (decision!=2 && decision!=5)
end




# -----------------------------------------------------------------------------
# Displays the number of the animatin
# -----------------------------------------------------------------------------


def pbFindAnimationIndex(wanted_anim= nil, showMessage = true)
  
  wanted_anim = pbMessageFreeText("What animation do you want?","",false,30) if !wanted_anim

  l = []
  animations = pbLoadBattleAnimations
  return if !animations
  animations.each_with_index do |a, i|
    next if !a || !a.name.include?(wanted_anim)
    l.push([i, a.name])
  end
  if l.length > 0
    if showMessage
      s = ""
      l.each_with_index { |a, i| 
        s += "\n" if i > 0
        s += a[0].to_s
        s += ": " 
        s += a[1].to_s
      }
      pbMessage(_INTL("{1} are at index {2}", wanted_anim, s))
    end 
    return true 
  end 
  pbMessage(_INTL("{1} was not found.", wanted_anim)) if showMessage
  return false 
end 


def pbFindMissingAnimations
  missing_moves = {}
  missing_moves["Normal"] = []
  missing_moves["ZMoves"] = []
  missing_moves["MaxMoves"] = []
  
  for i in 1...PBMoves.maxValue
    cname = getConstantName(PBMoves,i) rescue nil
    next if !cname
    if !pbFindAnimationIndex(cname, false)
      # Move not found.
      
      name = PBMoves.getName(i)
      flags = pbGetMoveData(i, MOVE_FLAGS)
      if flags[/z/] # Z-move 
        missing_moves["ZMoves"].push(name)
      elsif flags[/x/] # Max-move
        missing_moves["MaxMoves"].push(_INTL(name))
      else 
        missing_moves["Normal"].push(name)
      end 
    end 
  end 
  missing_moves["Normal"].sort! 
  missing_moves["ZMoves"].sort! 
  missing_moves["MaxMoves"].sort! 
  
  scToString(missing_moves)
end 


def pbFindMissingCommonAnimations
  common_anims = ["Sleep", "Toxic", "Poison", "Burn", "Paralysis", "Frozen", "Confusion", 
                  "Attract", "StatUp", "StatDown", "Powder", "UseItem", "CraftyShield", 
                  "WideGuard", "QuickGuard", "Protect", "Obstruct", "KingsShield",
                  "SpikyShield", "BanefulBunker", "ParentalBond", "FocusPunch", "ShellTrap",
                  "BeakBlast", "LevelUp", "HealingWish", "LunarDance", "Shadow", "MegaEvolution", 
                  "MegaEvolution2", "PrimalKyogre", "PrimalKyogre2", "PrimalGroudon", 
                  "PrimalGroudon2", "SeaOfFire", "SeaOfFireOpp", "LeechSeed", "Bind", 
                  "Clamp", "FireSpin", "MagmaStorm", "SandTomb", "Wrap", "Infestation", 
                  "SnapTrap", "ThunderCage", "Shiny", "HealthUp", "HealthDown", "EatBerry",
                  "Bind", "UnDynamax", "UltraBurst", "UltraBurst2", "ZPower", "Protect", 
                  "VineLash", "VineLashOpp", "Wildfire", "WildfireOpp", "Cannonade", 
                  "CannonadeOpp", "Volcalith", "VolcalithOpp", 
                  "Sun","Rain","Sandstorm","Hail","HarshSun","HeavyRain","StrongWinds",
                  "ShadowSky","Fog","Tempest",
                  "ElectricTerrain","GrassyTerrain","MistyTerrain","PsychicTerrain",
                  "ZHeal", 
                  "WarmWelcome", "PhoenixFireEffect", "MindMandala", "WarMandala","MagneticTerrain"
                  ]
  
  missing_common_anims = []
  
  for canim in common_anims
    if !pbFindAnimationIndex(canim, false)
      # Anim not found. 
      missing_common_anims.push(canim)
    end 
  end 
  # missing_common_anims.sort! 
  
  scToString(missing_common_anims)
end 






class PokemonTemp
  attr_accessor :sc_6x6combination
  
  def eachCombination
    if !@sc_6x6combination
      @sc_6x6combination = []
      for pos0 in 0...6
      for pos1 in 0...6
        next if pos0 == pos1
        for pos2 in 0...6
        next if pos0 == pos2 || pos1 == pos2
        for pos3 in 0...6
          next if pos0 == pos3 || pos1 == pos3 || pos2 == pos3
          for pos4 in 0...6
          next if pos0 == pos4 || pos1 == pos4 || pos2 == pos4 || pos3 == pos4
          for pos5 in 0...6
            next if pos0 == pos5 || pos1 == pos5 || pos2 == pos5 || pos3 == pos5 || pos4 == pos5
            @sc_6x6combination.push([pos0, pos1, pos2, pos3, pos4, pos5])
          end 
          end 
        end 
        end 
      end 
      end 
    end 
    
    @sc_6x6combination.each { |c| yield c }
  end 
end 
