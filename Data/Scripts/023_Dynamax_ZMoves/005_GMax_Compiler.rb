#===============================================================================
# Some constants to help handling the gigantamax data
#===============================================================================
module GMaxData
  FormName = 0
  MaxMoveType = 1
  MaxMove = 2
  Height = 3
  BattlerPlayerX = 4
  BattlerPlayerY = 5
  BattlerEnemyX = 6
  BattlerEnemyY = 7
  BattlerShadowX = 8
  BattlerShadowSize = 9
  
  InfoTypes = {
    "MaxMove"             => [0,                "ee", :PBTypes, :PBMoves],
    "FormName"            => [0,                 "s"],
    "Pokedex"             => [0,                 "s"],
    "BattlerPlayerX"      => [BattlerPlayerX,    "i"],
    "BattlerPlayerY"      => [BattlerPlayerY,    "i"],
    "BattlerEnemyX"       => [BattlerEnemyX,     "i"],
    "BattlerEnemyY"       => [BattlerEnemyY,     "i"],
    "BattlerShadowX"      => [BattlerShadowX,    "i"],
    "BattlerShadowSize"   => [BattlerShadowSize, "u"],
    "Height"              => [Height,            "f"]
  }
end 

module MessageTypes
  # For text storage in the usual dataset of messages.
  GMaxNames = 100
  GMaxPokedex = 101
end 

#===============================================================================
# Compile Gigantamax data
#===============================================================================
def pbCompileGigantamaxData
  # Prepare arrays for compiled data.
  gmaxData = {}
  gmaxNames      = []
  pokedexEntries = []
  speciesID = nil 
  # Read from PBS file.
  pbCompilerEachCommentedLine("PBS/gmaxforms.txt") { |line,lineno|
    if lineno%50==0
      Graphics.update
      Win32API.SetWindowText(_INTL("Processing PBS/gmaxforms.txt (line {1})...",lineno))
    end
    
    if line[/^\s*\[\s*(.*)\s*\]\s*$/]
      # Of the format: [something]
      val = $~[1]
      if val == "MAX MOVES"
        speciesID = -1 
        gmaxData[speciesID] = {}
      else 
        speciesID = parseSpecies(val)
        gmaxData[speciesID] = []
      end 
      
    elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
      # XXX=YYY line
      key = $~[1]
      schema = GMaxData::InfoTypes[key]
      record = pbGetCsvRecord($~[2],key,GMaxData::InfoTypes[key])
      
      case key
      when "MaxMove"
        if speciesID == -1 
          gmaxData[-1][record[0]] = record[1]
        else 
          gmaxData[speciesID][GMaxData::MaxMoveType] = record[0]
          gmaxData[speciesID][GMaxData::MaxMove] = record[1]
        end 
      when "FormName"
        gmaxNames[speciesID] = record
      when "Pokedex"
        pokedexEntries[speciesID] = record
      when "Height"
        gmaxData[speciesID][GMaxData::InfoTypes[key][0]] = (record*10).round
      else 
        gmaxData[speciesID][GMaxData::InfoTypes[key][0]] = record
      end 
    end
  }
  
  save_data(gmaxData,"Data/gmaxforms.dat")
  MessageTypes.addMessages(MessageTypes::GMaxNames,gmaxNames)
  MessageTypes.addMessages(MessageTypes::GMaxPokedex,pokedexEntries)
end 


#===============================================================================
# Decompile Gigantamax data
#===============================================================================
def pbSaveGigantamaxData
  gmaxData = pbLoadGmaxData
  messages = Messages.new("Data/messages.dat") rescue nil
  
  File.open("PBS/gmaxforms.txt", "wb") { |f|
    f.write("# This is part of the Dynamax plugin for Essentials v18.dev.\r\n")
    f.write("# \r\n")
    f.write("# This file is NOT officially an Essentials PBS file.\r\n")
    f.write("# If you want to add a new Gigantamax form, check the README provided with this plugin.\r\n")
    f.write("#-------------------------------\r\n")
    f.write("# Gigantamax Data\r\n")
    f.write("#-------------------------------\r\n")
    
    for i in 1..PBSpecies.maxValueF
      next if !gmaxData[i] # This species doesn't have a Gmax form.
      
      data = gmaxData[i]
      f.write("[" + getConstantName(PBSpecies,i) + "]")
      f.write("\r\n")
      f.write("FormName = " + messages.get(MessageTypes::GMaxNames, i))
      f.write("\r\n")
      if data[GMaxData::MaxMoveType] && data[GMaxData::MaxMove]
        f.write("MaxMove = " + getConstantName(PBTypes, data[GMaxData::MaxMoveType]))
        f.write(","  + getConstantName(PBMoves, data[GMaxData::MaxMove]))
        f.write("\r\n")
      end 
      f.write(sprintf("Height = %.1f",data[GMaxData::Height]/10.0))
      f.write("\r\n")
      f.write(sprintf("Pokedex = %s", csvQuoteAlways(messages.get(MessageTypes::GMaxPokedex, i))))
      f.write("\r\n")
      f.write(sprintf("BattlerPlayerX = %d\r\n", data[GMaxData::BattlerPlayerX]))
      f.write(sprintf("BattlerPlayerY = %d\r\n", data[GMaxData::BattlerPlayerY]))
      f.write(sprintf("BattlerEnemyX = %d\r\n", data[GMaxData::BattlerEnemyX]))
      f.write(sprintf("BattlerEnemyY = %d\r\n", data[GMaxData::BattlerEnemyY]))
      f.write(sprintf("BattlerShadowX = %d\r\n", data[GMaxData::BattlerShadowX]))
      f.write(sprintf("BattlerShadowSize = %d\r\n", data[GMaxData::BattlerShadowSize]))
      f.write("#-------------------------------\r\n")
    end 
    
    # Normal max-moves
    if gmaxData[-1]
      f.write("[MAX MOVES]\r\n")
      for i in 0..PBTypes.maxValue
        next if PBTypes.isPseudoType?(i) || isConst?(i,PBTypes,:SHADOW)
        f.write("MaxMove = " + getConstantName(PBTypes, i))
        f.write(","  + getConstantName(PBMoves, gmaxData[-1][i]))
        f.write("\r\n")
      end 
    end 
  }
end 

$GMaxDatabase = nil 
def pbLoadGmaxData
  # Loads the database only once! 
  if !$GMaxDatabase
    $GMaxDatabase = load_data("Data/gmaxforms.dat")
  end 
  return $GMaxDatabase
end 

def pbGetGMaxMoveFromSpecies(poke,type)
  gmaxData = pbLoadGmaxData
  return nil if !gmaxData[poke.fSpecies]
  if gmaxData[poke.fSpecies][GMaxData::MaxMoveType] == type
    return gmaxData[poke.fSpecies][GMaxData::MaxMove] 
  end 
  return nil 
end

# In replacement for DYNAMAX_MOVES
def pbGetMaxMove(movetype)
  gmaxData = pbLoadGmaxData
  return gmaxData[-1][movetype]
end 

def pbGetGmaxData(pokemon, index)
  # index = one value defined in the module GMaxData
  # pokemon = a PokeBattle_Battler, a PokeBattle_Pokemon or a PBSpecies constant. 
  if pokemon.is_a?(PokeBattle_Pokemon)
    pokemon = pokemon.fSpecies
  elsif pokemon.is_a?(PokeBattle_Battler)
    pokemon = pokemon.pokemon.fSpecies
  end 
  gmaxData = pbLoadGmaxData
  return nil if !gmaxData[pokemon]
  return gmaxData[pokemon][index]
end 
