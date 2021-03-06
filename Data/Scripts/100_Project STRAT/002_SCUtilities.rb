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
      s += _INTL("{1} ", temp)
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


