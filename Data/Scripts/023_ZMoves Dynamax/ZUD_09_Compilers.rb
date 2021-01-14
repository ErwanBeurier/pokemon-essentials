#===============================================================================
#
# ZUD_09: Compilers
#
#===============================================================================
# This script adds new compilers that compile Z-Move/Dynamax data from their
# appropriate PBS files, so that this data may be utilized by various ZUD
# functions. This also rewrites areas of NPC Trainer's metadata and other NPC
# related data to allow for Dynamax functions to be set on opposing trainers in
# the trainers PBS file (or edited in-game through the debug editor).
#
#===============================================================================
# SECTION 1 - Z-MOVE COMPILER
#-------------------------------------------------------------------------------
# This section compiles data so that it may be read from the ZUD_zmoves PBS file.
# All Z-Move compatibility and other relevant data is obtained from this file.
#===============================================================================
# SECTION 2 - DYNAMAX COMPILER
#-------------------------------------------------------------------------------
# This section compiles data so that it may be read from the ZUD_dynamax PBS file.
# All Gigantamax compatibility and other relevant data is obtained from this file.
#===============================================================================
# SECTION 3 - NPC DATA REWRITES
#-------------------------------------------------------------------------------
# This section rewrites code related to NPC Trainer metadata, as well as code 
# associated with compiling trainer data. This is done to allow for NPC's to
# utilize Dynamax mechanics.
#===============================================================================

################################################################################
# SECTION 1 - Z-MOVE COMPILER
#===============================================================================
# Gets the compatibility data from ZUD_zmoves.
#===============================================================================
module PBZMove
  ZCRYSTAL    = 0
  REQ_TYPE    = 1
  REQ_MOVE    = 2
  REQ_SPECIES = 3
  ZMOVE       = 4
end 

#-------------------------------------------------------------------------------
# Compile Z-Move data.
#-------------------------------------------------------------------------------
def pbCompileZMoveCompatibility
  records   = {}
  records["order"] = [] # For the decompiler.
  pbCompilerEachPreppedLine("PBS/ZUD_zmoves.txt") { |line,lineno|
    record = []
    lineRecord = pbGetCsvRecord(line,lineno,[0,"eEEEe",
       PBItems,   # Z-Crystal in the bag
       PBTypes,   # Move type required for the Z-Move 
       PBMoves,   # Specific move required for the Z-Move 
       PBSpecies, # Specific species required for the Z-Move
       PBMoves])  # The Z-Move
    if !lineRecord[PBZMove::REQ_TYPE] && !lineRecord[PBZMove::REQ_MOVE] && !lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (you need to specify a type, or a move + species).\r\n{1}",FileLineData.linereport)
    end
    if lineRecord[PBZMove::REQ_TYPE] && lineRecord[PBZMove::REQ_MOVE] && lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (do not specifiy a type + a move + a species).\r\n{1}",FileLineData.linereport)
    end
    records[lineRecord[PBZMove::ZCRYSTAL]] = [] if !records[lineRecord[PBZMove::ZCRYSTAL]]
    records[lineRecord[PBZMove::ZCRYSTAL]].push(lineRecord)
    records["order"].push(lineRecord)
  }
  save_data(records,"Data/ZUD_zmoves.dat")
end 

#-------------------------------------------------------------------------------
# Decompile Z-Move data.
#-------------------------------------------------------------------------------
def pbSaveZMoveCompatibility
  zmovecomps = pbLoadZMoveCompatibility
  return if !zmovecomps
  zmovecomps = zmovecomps["order"]
  return if !zmovecomps
  File.open("PBS/ZUD_zmoves.txt","wb") { |f|
    f.write("# This is part of the Z-Moves plugin for Essentials v18.dev.\r\n")
    f.write("# \r\n")
    f.write("# This file is NOT officially an Essentials PBS file.\r\n")
    f.write("# If you want to add a new Z-Move, check the README provided with this plugin.\r\n")
    f.write("# Order: Z-Crystal, Type, Specific move, Specific fspecies, Z-Move ID\r\n")
    f.write("#-------------------------------\r\n")
    zmovecomps.each { |comp| 
      f.write(sprintf("%s,%s,%s,%s,%s",
         getConstantName(PBItems,comp[PBZMove::ZCRYSTAL]),
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
  return load_data("Data/ZUD_zmoves.dat")
end 

#-------------------------------------------------------------------------------
# Gets Z-Move compatibility data.
#-------------------------------------------------------------------------------
def pbGetZMoveDataIfCompatible(pokemon,zcrystal,basemove=nil)
  # pokemon  = The pokemon being checked for compatibility.
  # zcrystal = The specific Z-Crystal item being checked.
  # basemove = The base move to be transformed. For use in battle.
  zmovecomps = pbLoadZMoveCompatibility
  return nil if !zmovecomps || !zmovecomps[zcrystal]
  zmovecomps[zcrystal].each { |comp|
    reqmove    = false
    reqtype    = false
    reqspecies = false
    # Checks type, if required.
    if comp[PBZMove::REQ_TYPE]
      if basemove
        reqtype=true if basemove.type==comp[PBZMove::REQ_TYPE]
      else 
        for move in pokemon.moves
          reqtype=true if move.type==comp[PBZMove::REQ_TYPE]
        end 
      end
    else 
      reqtype = true 
    end 
    # Checks move, if required.
    if comp[PBZMove::REQ_MOVE]
      if basemove
        reqmove=true if basemove.id==comp[PBZMove::REQ_MOVE]
      else 
        for move in pokemon.moves
          reqmove=true if move.id==comp[PBZMove::REQ_MOVE]
        end
      end 
    else 
      reqmove = true
    end 
    # Checks for species, if required.
    if comp[PBZMove::REQ_SPECIES]
      reqspecies = true if comp[PBZMove::REQ_SPECIES] == pokemon.fSpecies
    else 
      reqspecies = true 
    end 
    return comp if reqtype && reqmove && reqspecies
  }
  return nil 
end


################################################################################
# SECTION 2 - DYNAMAX COMPILER
#===============================================================================
# Gets the compatibility data from ZUD_dynamax.
#===============================================================================
module GMaxData
  FormName          = 0
  MaxMoveType       = 1
  MaxMove           = 2
  Height            = 3
  BattlerPlayerX    = 4
  BattlerPlayerY    = 5
  BattlerEnemyX     = 6
  BattlerEnemyY     = 7
  BattlerShadowX    = 8
  BattlerShadowSize = 9
  
  InfoTypes = {
    "MaxMove"             => [0,                 "ee", :PBTypes, :PBMoves],
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
  GMaxNames   = 100
  GMaxPokedex = 101
end 

#===============================================================================
# Compile Dynamax data.
#===============================================================================
def pbCompileGigantamaxData
  # Prepare arrays for compiled data.
  gmaxData = {}
  gmaxNames      = []
  pokedexEntries = []
  speciesID = nil 
  pbCompilerEachCommentedLine("PBS/ZUD_dynamax.txt") { |line,lineno|
    if lineno%50==0
      Graphics.update
      Win32API.SetWindowText(_INTL("Processing PBS/ZUD_dynamax.txt (line {1})...",lineno))
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
  save_data(gmaxData,"Data/ZUD_dynamax.dat")
  MessageTypes.addMessages(MessageTypes::GMaxNames,gmaxNames)
  MessageTypes.addMessages(MessageTypes::GMaxPokedex,pokedexEntries)
end 


#===============================================================================
# Decompile Dynamax data.
#===============================================================================
def pbSaveGigantamaxData
  gmaxData = pbLoadGmaxData
  messages = Messages.new("Data/messages.dat") rescue nil
  File.open("PBS/ZUD_dynamax.txt", "wb") { |f|
    f.write("# This is part of the Dynamax plugin for Essentials v18.dev.\r\n")
    f.write("# \r\n")
    f.write("# This file is NOT officially an Essentials PBS file.\r\n")
    f.write("# If you want to add a new Gigantamax form, check the README provided with this plugin.\r\n")
    f.write("#-------------------------------\r\n")
    f.write("# Gigantamax Data\r\n")
    f.write("#-------------------------------\r\n")
    for i in 1..PBSpecies.maxValueF
      next if !gmaxData[i]
      data = gmaxData[i]
      f.write("[" + getConstantName(PBSpecies,i) + "]")
      f.write("\r\n")
      f.write("FormName = " + messages.get(MessageTypes::GMaxNames, i))
      f.write("\r\n")
      if data[GMaxData::MaxMoveType] && data[GMaxData::MaxMove]
        f.write("MaxMove = " + getConstantName(PBTypes,data[GMaxData::MaxMoveType]))
        f.write(","  + getConstantName(PBMoves,data[GMaxData::MaxMove]))
        f.write("\r\n")
      end 
      f.write(sprintf("Height = %.1f",data[GMaxData::Height]/10.0))
      f.write("\r\n")
      f.write(sprintf("Pokedex = %s", csvQuoteAlways(messages.get(MessageTypes::GMaxPokedex,i))))
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
    f.write("# Max Move Compatibility\r\n")
    f.write("#-------------------------------\r\n")
    if gmaxData[-1]
      f.write("[MAX MOVES]\r\n")
      for i in 0..PBTypes.maxValue
        next if PBTypes.isPseudoType?(i) || isConst?(i,PBTypes,:SHADOW)
        f.write("MaxMove = " + getConstantName(PBTypes,i))
        f.write(","  + getConstantName(PBMoves,gmaxData[-1][i]))
        f.write("\r\n")
      end 
    end 
  }
end

$GMaxDatabase = nil 
def pbLoadGmaxData
  if !$GMaxDatabase
    $GMaxDatabase = load_data("Data/ZUD_dynamax.dat")
  end 
  return $GMaxDatabase
end

#-------------------------------------------------------------------------------
# Get Gigantamax compatibility data.
#-------------------------------------------------------------------------------
def pbGetGmaxData(pokemon,index)
  # index   = A value defined in the module GMaxData.
  # pokemon = A PokeBattle_Battler, a PokeBattle_Pokemon or a PBSpecies constant. 
  if pokemon.is_a?(PokeBattle_Pokemon)
    pokemon = pokemon.fSpecies
  elsif pokemon.is_a?(PokeBattle_Battler)
    pokemon = pokemon.pokemon.fSpecies
  end 
  gmaxData = pbLoadGmaxData
  return nil if !gmaxData[pokemon]
  return gmaxData[pokemon][index]
end


################################################################################
# SECTION 3 - NPC DATA REWRITES
#===============================================================================
# Adds Dynamax properties to existing data structures for compatibility.
#===============================================================================
TPACEPKMN   = 15
TPDYNAMAX   = 16
TPGMAX      = 17
#########################################################
# CUSTOM MECHANICS                                      #
#=======================================================#
# Add custom mechanics to be used by NPC trainers here. #
# Only neccessary if your mechanic needs to check for   #
# certain attributes not already listed.                #
# Adjust the numbering of TPLOSETEXT accordingly.       #
#=======================================================#
TPCUSTOM    = 18                                        #
#-------------------------------------------------------#
TPLOSETEXT  = 19
TPMAXLENGTH = TPLOSETEXT-1

module TrainersMetadata
  InfoTypes = {
    "Items"     => [0,           "eEEEEEEE", :PBItems, :PBItems, :PBItems, :PBItems,
                                             :PBItems, :PBItems, :PBItems, :PBItems],
    "Pokemon"   => [TPSPECIES,   "ev", :PBSpecies,nil],   # Species, level
    "Item"      => [TPITEM,      "e", :PBItems],
    "Moves"     => [TPMOVES,     "eEEE", :PBMoves, :PBMoves, :PBMoves, :PBMoves],
    "Ability"   => [TPABILITY,   "u"],
    "Gender"    => [TPGENDER,    "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                        "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
    "Form"      => [TPFORM,      "u"],
    "Shiny"     => [TPSHINY,     "b"],
    "Nature"    => [TPNATURE,    "e", :PBNatures],
    "IV"        => [TPIV,        "uUUUUU"],
    "Happiness" => [TPHAPPINESS, "u"],
    "Name"      => [TPNAME,      "s"],
    "Shadow"    => [TPSHADOW,    "b"],
    "Ball"      => [TPBALL,      "u"],
    "EV"        => [TPEV,        "uUUUUU"],
    "TrainerAce"=> [TPACEPKMN,   "b"],                 # Trainer's Ace Pokemon (True/False) 
    "DynamaxLvl"=> [TPDYNAMAX,   "u"],                 # Dynamax levels (0-10)
    "Gigantamax"=> [TPGMAX,      "b"],                 # G-Max Factor (True/False)
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Add the NPC data for your custom battle mechanics here.
    #===========================================================================
    "Custom"    => [TPCUSTOM,    "b"],                 # Simple true/false example
    #---------------------------------------------------------------------------
    "LoseText"  => [TPLOSETEXT,  "s"]
  }
end

#===============================================================================
# Adds Dynamax properties to NPC Trainers's data.
#===============================================================================
def pbLoadTrainer(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  return scLoadRandomTrainer(trainerid, trainername) if partyid < 0 # For random teams
  success = false
  items = []
  party = []
  opponent = nil
  trainers = pbLoadTrainersData
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    thispartyid   = trainer[4]
    next if thistrainerid!=trainerid || name!=trainername || thispartyid!=partyid
    items = trainer[2].clone
    name = pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVAL_NAMES
      next if !isConst?(trainerid,PBTrainers,i[0]) || !$game_variables[i[1]].is_a?(String)
      name = $game_variables[i[1]]
      break
    end
    loseText = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    opponent = PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer)
    # Load up each Pokémon in the trainer's party
    for poke in trainer[3]
      species = pbGetSpeciesFromFSpecies(poke[TPSPECIES])[0]
      level = poke[TPLEVEL]
      pokemon = pbNewPkmn(species,level,opponent,false)
      if poke[TPFORM]
        pokemon.forcedForm = poke[TPFORM] if MultipleForms.hasFunction?(pokemon.species,"getForm")
        pokemon.formSimple = poke[TPFORM]
      end
      pokemon.setItem(poke[TPITEM]) if poke[TPITEM]
      if poke[TPMOVES] && poke[TPMOVES].length>0
        for move in poke[TPMOVES]
          pokemon.pbLearnMove(move)
        end
      else
        pokemon.resetMoves
      end
      pokemon.setAbility(poke[TPABILITY] || 0)
      g = (poke[TPGENDER]) ? poke[TPGENDER] : (opponent.female?) ? 1 : 0
      pokemon.setGender(g)
      (poke[TPSHINY]) ? pokemon.makeShiny : pokemon.makeNotShiny
      n = (poke[TPNATURE]) ? poke[TPNATURE] : (pokemon.species+opponent.trainertype)%(PBNatures.maxValue+1)
      pokemon.setNature(n)
      for i in 0...6
        if poke[TPIV] && poke[TPIV].length>0
          pokemon.iv[i] = (i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]
        else
          pokemon.iv[i] = [level/2,PokeBattle_Pokemon::IV_STAT_LIMIT].min
        end
        if poke[TPEV] && poke[TPEV].length>0
          pokemon.ev[i] = (i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]
        else
          pokemon.ev[i] = [level*3/2,PokeBattle_Pokemon::EV_LIMIT/6].min
        end
      end
      pokemon.happiness = poke[TPHAPPINESS] if poke[TPHAPPINESS]
      pokemon.name = poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused = poke[TPBALL] if poke[TPBALL]
      (poke[TPACEPKMN]) ? pokemon.makeAcePkmn : pokemon.notAcePkmn
      pokemon.setDynamaxLvl(poke[TPDYNAMAX] || 0)
      (poke[TPGMAX]) ? pokemon.giveGMaxFactor : pokemon.removeGMaxFactor
      ##########################################################################
      # CUSTOM MECHANICS
      #=========================================================================
      # Add any criteria to an NPC's Pokemon that is required by your custom
      # battle mechanics here. Below is a simple example of adding a custom
      # attribute to a Pokemon if TPCUSTOM was set to "true".
      #=========================================================================
      #if poke[TPCUSTOM]
      #  pokemon.addCustomAttribute
      #end
      #-------------------------------------------------------------------------
      pokemon.calcStats
      pokemon.hp = pokemon.totalhp
      party.push(pokemon)
    end
    success = true
    break
  end
  return success ? [opponent,items,party,loseText] : nil
end

#===============================================================================
# Assigns Dynamax properties to NPC Trainers through in-game editor.
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname,initsetting)
    initsetting = [0,10] if !initsetting
    oldsetting = []
    for i in 0...TPMAXLENGTH
      if i==TPMOVES
        for j in 0...4
          oldsetting.push((initsetting[TPMOVES]) ? initsetting[TPMOVES][j] : nil)
        end
      else
        oldsetting.push(initsetting[i])
      end
    end
    mLevel = PBExperience.maxLevel
    properties = [
       [_INTL("Species"),SpeciesProperty,_INTL("Species of the Pokémon.")],
       [_INTL("Level"),NonzeroLimitProperty.new(mLevel),_INTL("Level of the Pokémon (1-{1}).",mLevel)],
       [_INTL("Held item"),ItemProperty,_INTL("Item held by the Pokémon.")],
       [_INTL("Move 1"),MoveProperty2.new(oldsetting),_INTL("First move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 2"),MoveProperty2.new(oldsetting),_INTL("Second move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 3"),MoveProperty2.new(oldsetting),_INTL("Third move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 4"),MoveProperty2.new(oldsetting),_INTL("Fourth move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Ability"),LimitProperty2.new(5),_INTL("Ability flag. 0=first ability, 1=second ability, 2-5=hidden ability.")],
       [_INTL("Gender"),GenderProperty.new,_INTL("Gender of the Pokémon.")],
       [_INTL("Form"),LimitProperty2.new(999),_INTL("Form of the Pokémon.")],
       [_INTL("Shiny"),BooleanProperty2,_INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Nature"),NatureProperty,_INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),IVsProperty.new(PokeBattle_Pokemon::IV_STAT_LIMIT),_INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),LimitProperty2.new(255),_INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Nickname"),StringProperty,_INTL("Name of the Pokémon.")],
       [_INTL("Shadow"),BooleanProperty2,_INTL("If set to true, the Pokémon is a Shadow Pokémon.")],
       [_INTL("Ball"),BallProperty.new(oldsetting),_INTL("The kind of Poké Ball the Pokémon is kept in.")],
       [_INTL("EVs"),EVsProperty.new(PokeBattle_Pokemon::EV_STAT_LIMIT),_INTL("Effort values for each of the Pokémon's stats.")],
       # Values used for Dynamax
       [_INTL("Trainer Ace"),BooleanProperty2,_INTL("If set to true, this is the trainer's ace Pokémon.")],
       [_INTL("Dynamax Lv."),LimitProperty2.new(10),_INTL("Dynamax level of the Pokémon (1-10).")],
       [_INTL("Gigantamax"),BooleanProperty2,_INTL("If set to true, the Pokémon has Gigantamax Factor.")]
    ]
    ############################################################################
    # CUSTOM MECHANICS
    #===========================================================================
    # Adds the ability to set custom battle mechanics on NPC Trainer's Pokemon
    # using the in-game editor. Below is an example of adding a boolean property
    # to the list of attributes that can be set on a trainer's Pokemon.
    #===========================================================================
    #properties.push([_INTL("Custom"),BooleanProperty2,_INTL("If set to true, adds Custom attribute.")])
    #---------------------------------------------------------------------------
    pbPropertyList(settingname,oldsetting,properties,false)
    return nil if !oldsetting[TPSPECIES] || oldsetting[TPSPECIES]==0
    ret = []
    moves = []
    for i in 0...oldsetting.length
      if i>=TPMOVES && i<TPMOVES+4
        ret.push(nil) if i==TPMOVES
        moves.push(oldsetting[i])
      else
        ret.push(oldsetting[i])
      end
    end
    moves.compact!
    ret[TPMOVES] = moves if moves.length>0
    ret.pop while ret.last.nil? && ret.size>0
    return ret
  end
end

def pbSaveTrainerBattles
  data = pbLoadTrainersData
  return if !data
  File.open("PBS/trainers.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for trainer in data
      trtypename = getConstantName(PBTrainers,trainer[0]) rescue pbGetTrainerConst(trainer[0]) rescue nil
      next if !trtypename
      f.write("\#-------------------------------\r\n")
      # Section
      trainername = trainer[1] ? trainer[1].gsub(/,/,";") : "???"
      if trainer[4]==0
        f.write(sprintf("[%s,%s]\r\n",trtypename,trainername))
      else
        f.write(sprintf("[%s,%s,%d]\r\n",trtypename,trainername,trainer[4]))
      end
      # Trainer's items
      if trainer[2] && trainer[2].length>0
        itemstring = ""
        for i in 0...trainer[2].length
          itemname = getConstantName(PBItems,trainer[2][i]) rescue pbGetItemConst(trainer[2][i]) rescue nil
          next if !itemname
          itemstring.concat(",") if i>0
          itemstring.concat(itemname)
        end
        f.write(sprintf("Items = %s\r\n",itemstring)) if itemstring!=""
      end
      # Lose texts
      if trainer[5] && trainer[5]!=""
        f.write(sprintf("LoseText = %s\r\n",csvQuoteAlways(trainer[5])))
      end
      # Pokémon
      for poke in trainer[3]
        species = getConstantName(PBSpecies,poke[TPSPECIES]) rescue pbGetSpeciesConst(poke[TPSPECIES]) rescue ""
        f.write(sprintf("Pokemon = %s,%d\r\n",species,poke[TPLEVEL]))
        if poke[TPNAME] && poke[TPNAME]!=""
          f.write(sprintf("    Name = %s\r\n",poke[TPNAME]))
        end
        if poke[TPFORM]
          f.write(sprintf("    Form = %d\r\n",poke[TPFORM]))
        end
        if poke[TPGENDER]
          f.write(sprintf("    Gender = %s\r\n",(poke[TPGENDER]==1) ? "female" : "male"))
        end
        if poke[TPSHINY]
          f.write("    Shiny = yes\r\n")
        end
        if poke[TPSHADOW]
          f.write("    Shadow = yes\r\n")
        end
        if poke[TPMOVES] && poke[TPMOVES].length>0
          movestring = ""
          for i in 0...poke[TPMOVES].length
            movename = getConstantName(PBMoves,poke[TPMOVES][i]) rescue pbGetMoveConst(poke[TPMOVES][i]) rescue nil
            next if !movename
            movestring.concat(",") if i>0
            movestring.concat(movename)
          end
          f.write(sprintf("    Moves = %s\r\n",movestring)) if movestring!=""
        end
        if poke[TPABILITY]
          f.write(sprintf("    Ability = %d\r\n",poke[TPABILITY]))
        end
        if poke[TPITEM] && poke[TPITEM]>0
          item = getConstantName(PBItems,poke[TPITEM]) rescue pbGetItemConst(poke[TPITEM]) rescue nil
          f.write(sprintf("    Item = %s\r\n",item)) if item
        end
        if poke[TPNATURE]
          nature = getConstantName(PBNatures,poke[TPNATURE]) rescue nil
          f.write(sprintf("    Nature = %s\r\n",nature)) if nature
        end
        if poke[TPIV] && poke[TPIV].length>0
          f.write(sprintf("    IV = %d",poke[TPIV][0]))
          if poke[TPIV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPEV] && poke[TPEV].length>0
          f.write(sprintf("    EV = %d",poke[TPEV][0]))
          if poke[TPEV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPHAPPINESS]
          f.write(sprintf("    Happiness = %d\r\n",poke[TPHAPPINESS]))
        end
        if poke[TPBALL]
          f.write(sprintf("    Ball = %d\r\n",poke[TPBALL]))
        end
        if poke[TPACEPKMN]
          f.write("    TrainerAce = yes\r\n")
        end
        if poke[TPDYNAMAX]
          f.write(sprintf("    DynamaxLvl = %d\r\n",poke[TPDYNAMAX]))
        end
        if poke[TPGMAX]
          f.write("    Gigantamax = yes\r\n")
        end
        ########################################################################
        # CUSTOM MECHANICS
        #=======================================================================
        # Saves any custom attribute to an NPC Trainer's Pokemon once set in the
        # in-game editor. Below is an example of a simple yes/no attribute.
        #=======================================================================
        #if poke[TPCUSTOM]
        #  f.write("    CustomAttribute = yes\r\n")
        #end
        #-----------------------------------------------------------------------
      end
    end
  }
end

#===============================================================================
# Compile individual trainers
#===============================================================================
def pbCompileTrainers
  trainer_info_types = TrainersMetadata::InfoTypes
  mLevel = PBExperience.maxLevel
  trainerindex    = -1
  trainers        = []
  trainernames    = []
  trainerlosetext = []
  pokemonindex    = -2
  oldcompilerline   = 0
  oldcompilerlength = 0
  pbCompilerEachCommentedLine("PBS/trainers.txt") { |line,lineno|
    if line[/^\s*\[\s*(.+)\s*\]\s*$/]
      # Section [trainertype,trainername] or [trainertype,trainername,partyid]
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
      end
      if pokemonindex==-1
        raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}",FileLineData.linereport)
      end
      section = pbGetCsvRecord($~[1],lineno,[0,"esU",PBTrainers])
      trainerindex += 1
      trainertype = section[0]
      trainername = section[1]
      partyid     = section[2] || 0
      trainers[trainerindex] = [trainertype,trainername,[],[],partyid,nil]
      trainernames[trainerindex] = trainername
      pokemonindex = -1
    elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
      # XXX=YYY lines
      if trainerindex<0
        raise _INTL("Expected a section at the beginning of the file.\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
      end
      settingname = $~[1]
      schema = trainer_info_types[settingname]
      next if !schema
      record = pbGetCsvRecord($~[2],lineno,schema)
      # Error checking in XXX=YYY lines
      case settingname
      when "Pokemon"
        if record[1]>mLevel
          raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[1],mLevel,FileLineData.linereport)
        end
      when "Moves"
        record = [record] if record.is_a?(Integer)
        record.compact!
      when "Ability"
        if record>5
          raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5).\r\n{2}",record,FileLineData.linereport)
        end
      when "IV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::IV_STAT_LIMIT
          raise _INTL("Bad IV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::IV_STAT_LIMIT,FileLineData.linereport)
        end
      when "EV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::EV_STAT_LIMIT
          raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
        end
        evtotal = 0
        for i in 0...6
          evtotal += (i<record.length) ? record[i] : record[0]
        end
        if evtotal>PokeBattle_Pokemon::EV_LIMIT
          raise _INTL("Total EVs are greater than allowed ({1})\r\n{2}",PokeBattle_Pokemon::EV_LIMIT,FileLineData.linereport)
        end
      when "Happiness"
        if record>255
          raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record,FileLineData.linereport)
        end
      when "Name"
        if record.length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
          raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
        end
      when "DynamaxLvl"
        if record>10
          raise _INTL("Bad Dynamax Level: {1} (must be 0-10).\r\n{2}",record,FileLineData.linereport)
        end
      end
      # Record XXX=YYY setting
      case settingname
      when "Items"   # Items in the trainer's Bag, not the held item
        record = [record] if record.is_a?(Integer)
        record.compact!
        trainers[trainerindex][2] = record
      when "LoseText"
        trainerlosetext[trainerindex] = record
        trainers[trainerindex][5] = record
      when "Pokemon"
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        trainers[trainerindex][3][pokemonindex][TPSPECIES] = record[0]
        trainers[trainerindex][3][pokemonindex][TPLEVEL]   = record[1]
      else
        if pokemonindex<0
          raise _INTL("Pokémon hasn't been defined yet!\r\n{1}",FileLineData.linereport)
        end
        trainers[trainerindex][3][pokemonindex][schema[0]] = record
      end
    else
      # Old compiler - backwards compatibility is SUCH fun!
      if pokemonindex==-1 && oldcompilerline==0
        raise _INTL("Unexpected line format, started new trainer while previous trainer has no Pokémon\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline==0   # Started an old trainer section
        oldcompilerlength = 3
        oldcompilerline   = 0
        trainerindex += 1
        trainers[trainerindex] = [0,"",[],[],0]
        pokemonindex = -1
      end
      oldcompilerline += 1
      case oldcompilerline
      when 1   # Trainer type
        record = pbGetCsvRecord(line,lineno,[0,"e",PBTrainers])
        trainers[trainerindex][0] = record
      when 2   # Trainer name, version number
        record = pbGetCsvRecord(line,lineno,[0,"sU"])
        record = [record] if record.is_a?(Integer)
        trainers[trainerindex][1] = record[0]
        trainernames[trainerindex] = record[0]
        trainers[trainerindex][4] = record[1] if record[1]
      when 3   # Number of Pokémon, items
        record = pbGetCsvRecord(line,lineno,[0,"vEEEEEEEE",nil,PBItems,PBItems,
                                PBItems,PBItems,PBItems,PBItems,PBItems,PBItems])
        record = [record] if record.is_a?(Integer)
        record.compact!
        oldcompilerlength += record[0]
        record.shift
        trainers[trainerindex][2] = record if record
      else   # Pokémon lines
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        record = pbGetCsvRecord(line,lineno,
           [0,"evEEEEEUEUBEUUSBUBUBU",PBSpecies,nil, PBItems,PBMoves,PBMoves,PBMoves,
                                  PBMoves,nil,{"M"=>0,"m"=>0,"Male"=>0,"male"=>0,
                                  "0"=>0,"F"=>1,"f"=>1,"Female"=>1,"female"=>1,
                                  "1"=>1},nil,nil,PBNatures,nil,nil,nil,nil,nil,
                                  nil,nil,nil,nil]) # TrainerAce, DynamaxLvl, G-Max, Custom
        # Error checking (the +3 is for properties after the four moves)
        for i in 0...record.length
          next if record[i]==nil
          case i
          when TPLEVEL
            if record[i]>mLevel
              raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[i],mLevel,FileLineData.linereport)
            end
          when TPABILITY+3
            if record[i]>5
              raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPIV+3
            if record[i]>31
              raise _INTL("Bad IV: {1} (must be 0-31)\r\n{2}",record[i],FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPEV+3
            if record[i]>PokeBattle_Pokemon::EV_STAT_LIMIT
              raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",record[i],PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPHAPPINESS+3
            if record[i]>255
              raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPNAME+3
            if record[i].length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
              raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record[i],PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
            end
          when TPDYNAMAX+3
            if record[i]>10
              raise _INTL("Bad Dynamax Level: {1} (must be 0-10)\r\n{2}",record[i],FileLineData.linereport)
            end
          end
        end
        # Write data to trainer array
        for i in 0...record.length
          next if record[i]==nil
          if i>=TPMOVES && i<TPMOVES+4
            if !trainers[trainerindex][3][pokemonindex][TPMOVES]
              trainers[trainerindex][3][pokemonindex][TPMOVES] = []
            end
            trainers[trainerindex][3][pokemonindex][TPMOVES].push(record[i])
          else
            d = (i>=TPMOVES+4) ? i-3 : i
            trainers[trainerindex][3][pokemonindex][d] = record[i]
          end
        end
      end
      oldcompilerline = 0 if oldcompilerline>=oldcompilerlength
    end
  }
  save_data(trainers,"Data/trainers.dat")
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText,trainerlosetext)
end