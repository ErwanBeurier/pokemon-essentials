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










