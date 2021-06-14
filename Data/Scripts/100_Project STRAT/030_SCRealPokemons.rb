###############################################################################
# SCRealPokemons
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# Contains story-related scripts. Pokémons that the player character owned and 
# used in his past life.
###############################################################################


class PokeBattle_Trainer
  attr_reader :sc_following
  attr_accessor :sc_realpokemon_species
  attr_accessor :sc_realpokemons
  attr_reader :sc_backup_party
  
  
  def scGetFollowing
    return nil if !@sc_following
    if !SCSwitch.get(:UseRealPokemons) && (!@sc_backup_party || @sc_backup_party.length == 0)
      @sc_backup_party = [@sc_realpokemons[@sc_following]]
    elsif SCSwitch.get(:UseRealPokemons) && (!@party || @party.length == 0)
      @party = [@sc_realpokemons[@sc_following]]
    end 
    return self.firstAblePokemon if SCSwitch.get(:UseRealPokemons)
    return @sc_realpokemons[@sc_following] # if !SCSwitch.get(:UseRealPokemons)
  end 
  
  
  def scSetFollowing(poke_id, event_id)
    # poke_id should be a SCStoryPokemon constant (Starter, Totem, and so on)
    @sc_following = poke_id
    if !SCSwitch.get(:UseRealPokemons) #&& (!@sc_backup_party || @sc_backup_party.length == 0)
      @sc_backup_party = [@sc_realpokemons[@sc_following]]
    elsif SCSwitch.get(:UseRealPokemons) #&& (!@party || @party.length == 0)
      @party = [@sc_realpokemons[@sc_following]]
    end 
    $game_map.events[event_id].event.name = "FollowerPkmn"
    pbPokemonFollow(event_id)
    for s in SCStoryPokemon::Starter..SCStoryPokemon::Totem
      SCSwitch.set(SCSwitch::StarterFollowing + s, (poke_id == s))
    end 
    $game_map.refresh
  end 
  
  
  def scInsertInParty(poke_id)
    if SCSwitch.get(:UseRealPokemons)
      @party.push(@sc_realpokemons[poke_id])
    else 
      @sc_backup_party.push(@sc_realpokemons[poke_id])
    end 
    
    for s in SCStoryPokemon::Starter..SCStoryPokemon::Totem
      SCSwitch.set(SCSwitch::StarterFollowing + s, true) if poke_id == s
    end 
    $game_map.refresh
  end 
  
  
  def scMakeRealPokemons(force = false)
    return if (!@sc_realpokemons || @sc_realpokemons.length == 0) && !force
    @sc_realpokemons = []
    # Creates the Pokémons based on the species.
    @sc_realpokemon_species.each_with_index do |species, i|
      @sc_realpokemons[i] = scGenerateMovesetFast(species, 20)
    end 
  end 
  
  
  def scUseRealPokemons
    if SCSwitch.get(:UseRealPokemons)
      raise _INTL("Mismatch: wanted to use Real Pokémons while the party is already made of them.")
    end 
    
    temp = @party
    @party = @sc_backup_party
    @sc_backup_party = temp 
    
    # if !@party
      # @party = [@sc_realpokemons[@sc_following]]
    # end 
    SCSwitch.set(:UseRealPokemons, true)
    # $game_map.refresh
  end 
  
  
  def scUseFakePokemons
    if !SCSwitch.get(:UseRealPokemons)
      raise _INTL("Mismatch: wanted to use Fake Pokémons while the party is already made of them.")
    end 
    
    temp = @party
    @party = @sc_backup_party
    @sc_backup_party = temp 
    
    SCSwitch.set(:UseRealPokemons, false)
    
    warn_player = (@sc_backup_party.length > 1)
    
    @sc_backup_party = [@sc_backup_party[@sc_following]]
    
    for s in SCStoryPokemon::Starter..SCStoryPokemon::Totem
      SCSwitch.set(SCSwitch::StarterFollowing + s, (@sc_following == s))
    end 
    pbMessage("\\SC[Game]You let your Pokémon roam on your land.") if warn_player
    # $game_map.refresh
  end 
end 



class Game_Event
  attr_reader :event
end 



module SCStoryPokemon
  Kanto = 0
  Johto = 1
  Hoenn = 2
  Sinnoh = 3
  Unova = 4
  Kalos = 5
  Alola = 6 
  Galar = 7
  
  # Indices in the team (NOT in the file)
  Starter = 0 
  CoreStrong = 1 # Strong type against the starter (if Grass then Fire, if )
  CoreWeak = 2 # Weak type againist the starter 
  HalfLegendary = 3
  Ordinary = 4
  Cute = 5
  Badass1 = 6
  Badass2 = 7
  Flying = 8
  Totem = 9
  
  @@db = nil
  @@regions = nil 
  
  
  def self.loadDatabase
    return if @@db 
    @@db = {}
    @@regions = [] 
    region = nil
    section = ""
    value = -1
    
    File.open("SC_Story_Pokemon_0.txt","rb") { |f|
      f.each_line { |line| 
        if !line[/^\#/] && !line[/^\s*$/] # Comments or empty lines
          if line[/^\s*\[\s*(.*)\s*\]\s*$/]   # Of the format: [region]
            region = $~[1]
            @@db[region] = {}
            @@regions.push(region)
          else
            if region==nil
              FileLineData.setLine(line,lineno)
              raise _INTL("Expected a region at the beginning of the file.\r\n{1}",FileLineData.linereport)
            end
            if !line[/^\s*(\w+)\s*=\s*(.*)$/]
              FileLineData.setSection(sectionname,nil,line)
              raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
            end
            section = $~[1]
            data = $~[2]
            @@db[region][section] = []
            specieslist = data.sub(/\s+$/,"").split(",")
            for species in specieslist
              next if !species || species==""
              @@db[region][section].push(parseSpecies(species))
            end
          end
        end
      }
    }
  end 
  
  
  def self.choose
    # Chooses the Pokémons for the rest of the game. 
    SCStoryPokemon.loadDatabase
    
    region = nil 
    s = -1 
    
    while s == -1 
      reg = pbMessage("\\SC[Player]I am from...", @@regions)
      region = @@regions[reg]
      SCVar.set(:RegionOfOrigin, reg)
      SCVar.set(:RegionOfOriginName, region)
      # 0 = Kanto ; 1 = Johto ; 2 = Hoenn ; 3 = Sinnoh ; 4 = Unova ; 5 = Kalos ; 6 = Alola ; 7 = Galar. 
      
      starters = []
      starters.push(PBSpecies.getName(@@db[region]["StarterGrass"][0]))
      starters.push(PBSpecies.getName(@@db[region]["StarterFire"][0]))
      starters.push(PBSpecies.getName(@@db[region]["StarterWater"][0]))
      
      s = pbMessage("\\SC[Player]... and my starter (final evolution) was...", starters, -1)
    end 
    
    $Trainer.sc_realpokemon_species = Array.new(Totem+1)
    
    if s == 0 # Grass 
      $Trainer.sc_realpokemon_species[Starter] = @@db[region]["StarterGrass"][0]
      $Trainer.sc_realpokemon_species[CoreStrong] = scsample(@@db[region]["Fire"], 1)
      $Trainer.sc_realpokemon_species[CoreWeak] = scsample(@@db[region]["Water"], 1)
      
    elsif s == 1 # Fire 
      $Trainer.sc_realpokemon_species[Starter] = @@db[region]["StarterFire"][0]
      $Trainer.sc_realpokemon_species[CoreStrong] = scsample(@@db[region]["Water"], 1)
      $Trainer.sc_realpokemon_species[CoreWeak] = scsample(@@db[region]["Grass"], 1)
      
    else # Water 
      $Trainer.sc_realpokemon_species[Starter] = @@db[region]["StarterWater"][0]
      $Trainer.sc_realpokemon_species[CoreStrong] = scsample(@@db[region]["Grass"], 1)
      $Trainer.sc_realpokemon_species[CoreWeak] = scsample(@@db[region]["Fire"], 1)
      
    end
    
    $Trainer.sc_realpokemon_species[HalfLegendary] = scsample(@@db[region]["HalfLegendary"], 1)
    $Trainer.sc_realpokemon_species[Ordinary] = scsample(@@db[region]["Ordinary"], 1)
    $Trainer.sc_realpokemon_species[Cute] = scsample(@@db[region]["Cute"], 1)
    $Trainer.sc_realpokemon_species[Flying] = scsample(@@db[region]["Flying"], 1)
    $Trainer.sc_realpokemon_species[Totem] = scsample(@@db[region]["Totems"], 1)
    
    ret = scsample(@@db[region]["Badass"], 2)
    $Trainer.sc_realpokemon_species[Badass1] = ret[1]
    $Trainer.sc_realpokemon_species[Badass2] = ret[0]
    
  end 
  
  
  def self.import
    # $Trainer.sc_realpokemons = Array.new(Totem+1)
    
    File.open("SC_Story_Pokemon_Chosen.txt","rb") { |f|
      f.each_line { |line| 
        if line[/^\s*(\w+)\s*=\s*(.*)$/]
          section = $~[1]
          species = $~[2]
          
          species.gsub!(/\s+/,"") # Remove spaces 
          species.gsub!(/\./,"") # Remove dots
          species.gsub!(/-/,"") # Remove dashes.
          
          if species == ""
            raise _INTL("The role {1} cannot be left empty. The error is in the line:\r\n{2}", section, line) 
          end 
          
          species = species.split(",")
          
          if species.length != 1
            raise _INTL("You can enter only one Pokémon per role. The error is in the line:\r\n{2}", section, line) 
          end 
          
          species = species[0]
          species.capitalize!
          
          species = parseSpecies(species)
          
          case section
          when "Starter"
            $Trainer.sc_realpokemon_species[Starter] = species
          when "CoreStrong"
            $Trainer.sc_realpokemon_species[CoreStrong] = species
          when "CoreWeak"
            $Trainer.sc_realpokemon_species[CoreWeak] = species
          when "HalfLegendary"
            $Trainer.sc_realpokemon_species[HalfLegendary] = species
          when "Ordinary"
            $Trainer.sc_realpokemon_species[Ordinary] = species
          when "Cute"
            $Trainer.sc_realpokemon_species[Cute] = species
          when "Flying"
            $Trainer.sc_realpokemon_species[Flying] = species
          when "Totem"
            $Trainer.sc_realpokemon_species[Totem] = species
          when "Badass1"
            $Trainer.sc_realpokemon_species[Badass1] = species
          when "Badass2"
            $Trainer.sc_realpokemon_species[Badass2] = species
          else 
            raise _INTL("Cannot understand line: {1}\r\nThe only correct sections are Starter, CoreStrong, CoreWeak, HalfLegendary, Ordinary, Cute, Flying, Totem, Badass1, Badass2.")
          end 
        end
      }
    }
  end 
  
  
  def self.export
    File.open("SC_Story_Pokemon_Chosen.txt", "wb") { |f|
      f.write("################################################################################\r\n")
      f.write("# This file defines the Pokémons that the main character used during his own\r\n")
      f.write("# adventure, before retiring and making his amusement park.\r\n")
      f.write("# Note that some of these will have a specific role in the story. For immersion\r\n")
      f.write("# purposes, you should choose Pokémons that correspond to the region that you\r\n")
      f.write("# have chosen. Or you can check the file SC_Story_Pokemon_0.txt and choose in the\r\n")
      f.write("# corresponding lists.\r\n")
      f.write("# Please respect the concept of the game and do not put any Legendary or \r\n")
      f.write("# Mythical Pokémons where not needed.\r\n")
      f.write("################################################################################\r\n")
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is your Starter Pokémon, the first Pokémon given to you by the Professor\r\n")
      f.write("# of your region.\r\n")
      sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Starter])
      f.write(sprintf("Starter = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is a Pokémon that has a type advantage over your starter. This Pokémon is\r\n")
      f.write("# not necessarily a starter.\r\n")
      f.write("# If you have chosen the Grass-type starter, this Pokémon should be Fire-type.\r\n")
      f.write("# If you have chosen the Water-type starter, this Pokémon should be Grass-type.\r\n")
      f.write("# If you have chosen the Fire-type starter, this Pokémon should be Water-type.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[CoreStrong])
      f.write(sprintf("CoreStrong = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# Your starter has a type advantage over the following Pokémon.\r\n")
      f.write("# If you have chosen the Grass-type starter, this Pokémon should be Water-type.\r\n")
      f.write("# If you have chosen the Water-type starter, this Pokémon should be Fire-type.\r\n")
      f.write("# If you have chosen the Fire-type starter, this Pokémon should be Grass-type.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[CoreWeak])
      f.write(sprintf("CoreWeak = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is a Pokémon that you find cute. This is typically the Pikachu-like of\r\n")
      f.write("# the region, or some Fairy-type Pokémon.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Cute])
      f.write(sprintf("Cute = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is a Pokémon that you use to fly.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Flying])
      f.write(sprintf("Flying = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is a Pokémon that looks ordinary and common.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Ordinary])
      f.write(sprintf("Ordinary = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# This is the strong Pokémon of the region (the likes of Dragonite, Tyranitar).\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[HalfLegendary])
      f.write(sprintf("HalfLegendary = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# Two other Pokémons that look strong and impressive.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Badass1])
      f.write(sprintf("Badass1 = %s\r\n", sp))
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Badass2])
      f.write(sprintf("Badass2 = %s\r\n", sp))
      
      f.write("#-------------------------------------------------------------------------------\r\n")
      f.write("# The Legendary Pokémon that the main character meets during their journey in\r\n")
      f.write("# his region.\r\n")
      f.write("# If the main character is from Johto, then it should be either Ho-Oh or Lugia.\r\n")
      f.write("# If he is from Hoenn, it should be either Groudon, Kyogre or Rayquaza.\r\n")
      f.write("# If he is from Sinnoh, it should be either Dialga, Palkia or Giratina.\r\n")
      f.write("# If he is from Unova, it should be either Reshiram or Zekrom.\r\n")
      f.write("# If he is from Kalos, it should be either Xerneas or Yveltal.\r\n")
      f.write("# If he is from Alola, it should be either Solgaleo or Lunala.\r\n")
      f.write("# If he is from Galar, it should be either Zacian or Zamazenta.\r\n")
      f.write("# Kanto doesn't have this kind of Legendary Pokémon. Choose either Regigigas or Arceus.\r\n")
      f.write("# NB: Regigigas no longer has its incapacitating ability.\r\n")
      f.write("# NB2: Mewtwo will play a special role in the story, so don't put Mewtwo here.\r\n")
			sp = getConstantName(PBSpecies,$Trainer.sc_realpokemon_species[Totem])
      f.write(sprintf("Totem = %s\r\n", sp))
      f.write("#-------------------------------------------------------------------------------\r\n")
    }
  end 
  
  
  def self.speciesIs(poke_id, species)
    if species.is_a?(Array)
      species.each { |sp| return true if SCStoryPokemon.speciesIs(poke_id, sp) }
      return false
    else 
      species = getID(PBSpecies, species)
    end 
    
    if poke_id.is_a?(Array)
      poke_id.each { |pkid| return true if $Trainer.sc_realpokemon_species[pkid] == species }
      return false
    else 
      poke_id = getID(SCStoryPokemon, poke_id)
      return $Trainer.sc_realpokemon_species[poke_id] == species
    end 
  end 
  
  
  def self.pkmnIs(poke_id, pokemon)
    return false if !pokemon
    poke_id = getID(SCStoryPokemon, poke_id)
    # Checks if the given Pokémon is the poke_id.
    return (pokemon.personalID == $Trainer.sc_realpokemons[poke_id].personalID)
  end 
  
  
  def self.followingIs(poke_id)
    return self.pkmnIs(poke_id, $Trainer.scGetFollowing)
  end 
  
  
  def self.loadGraphics
    # Loads the graphics of all the events. 
    triples = [
      # [map, x, y, id, poke_id]
      # Events in the Player's room
      [43, 5, 3, 9, Starter],
      [43, 9, 3, 11, Cute],
      # Events in the Gardens. 
      [81, 9, 3, 16, Badass1],
      [81, 9, 3, 17, Ordinary],
      [81, 9, 3, 18, Flying],
      # Events in Redwood.
      [95, 9, 3, 4, CoreStrong],
      [95, 9, 3, 5, CoreWeak],
      [95, 9, 3, 6, HalfLegendary],
      [95, 9, 3, 7, Badass2],
      [95, 9, 3, 8, Flying],
      # The totem. 
      [101, 9, 3, 2, Totem], # White grotto
      [106, 9, 3, 2, Totem], # Brown grotto 
      [108, 9, 3, 2, Totem], # Underwater cave
      [109, 9, 3, 2, Totem], # Summit
      [110, 9, 3, 2, Totem], # Lava Grotto 
      [111, 9, 3, 3, Totem] # Deep Forest 
    ]
    # following_event = 8 
    
    triples.each do |triple| 
      map_id = triple[0]
      x = triple[1]
      y = triple[2]
      event_id = triple[3]
      poke_id = triple[4]
      
      next if $game_map.map_id != map_id
      next if SCSwitch.get(SCSwitch::StarterFollowing + poke_id)
      # Do not show the Flying Pokémon in the Gardens before the player goes to Redwood. 
      next if !SCSwitch.get(SCSwitch::UnlockFlyingInGardens) && $game_map.map_id == 81 && poke_id == Flying
      
      # event_id = ($game_map.events.keys.max || -1) + 1
      
      # event = RPG::Event.new(x,y)
      # event.name = _INTL("Pokemon {1}", poke_id)
      # # event.name = "FollowerPkmn"
      
      # # First page: 
      # indent = 0 
      # pbPushText(event.pages[0].list, _INTL("Take {1} with you?", $Trainer.sc_realpokemons[SCStoryPokemon::Starter].name), indent)
      # pbPushShowChoices(event.pages[0].list, [["Yes", "No"], 1], indent)
      # pbPushWhenBranch(event.pages[0].list, 0, indent+1)
      # pbPushScript(event.pages[0].list,_INTL("$Trainer.scSetFollowing({1}, {2})", poke_id, following_event), indent+1)
      # pbPushWhenBranch(event.pages[0].list, 1, indent+1)
      # pbPushBranchEnd(event.pages[0].list, indent+1)
      
      # SCClientBattles.loadGraphicsSpecies(event, $Trainer.sc_realpokemon_species[poke_id])
      
      for event in $game_map.events.values
        next if event.id != event_id
        SCClientBattles.loadGraphicsPoke(event, $Trainer.sc_realpokemons[poke_id])
        # pbMessage(event.character_name)
        # updating the sprites
        sprite = Sprite_Character.new(Spriteset_Map.viewport,event)
        $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
        $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
        break 
      end 
      # # $game_map.events[event_id].update
      # # pbMessage($game_map.events[event_id].event.pages[0].graphic.character_name)
      # gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
      # gameEvent.id = event_id
      # gameEvent.moveto(x,y)
      # $game_map.events[event_id] = gameEvent
    
    end 
  end 
  
  
  def self.get(poke_id)
    poke_id = getID(SCStoryPokemon, poke_id)
    return $Trainer.sc_realpokemons[poke_id]
  end 
  
  
  module FlyingDialogueMode
    AskToFollow = 0
    TakeInParty = 1
    AlreadyInParty = 2 
    Following = 3
  end
  
  
  def self.fly(mode, event_id)
    mode = getID(FlyingDialogueMode, mode) if mode.is_a?(Symbol)
    # return false if for_follower && !SCSwitch.get(SCSwitch::StarterFollowing + SCStoryPokemon::Flying) # Flying is not following
    # return false if pkmn.personalID == @sc_realpokemons[SCStoryPokemon::Flying].personalID # The Pokémon talked to is not following
    # return false if $PokemonTemp.flydata # Can't use Fly here.
    # return if !pbGetMetadata($game_map.map_id,MetadataOutdoor) # Can't use Fly here. 
    
    cmdCastle = -1
    cmdRedwood = -1
    cmdTotem = -1
    cmdTakeInParty = -1
    cmdAskFollow = -1
    cmdTalk = -1
    cmdCancel = -1
    options = []
    
    if $game_map.map_id != 81 && SCSwitch.get(:UnlockFlyingInGardens)
      # If not in Castle Gardens.
      options[cmdCastle = options.length] = "Fly to Castle" 
    end 
    if ![95, 100, 102, 103, 104, 105].include?($game_map.map_id)
      # If not in Redwood.
      options[cmdRedwood = options.length] = "Fly to Redwood" 
    end 
    if ![101, 106, 108, 109, 110, 111].include?($game_map.map_id) 
      # If not in the totem site.
      options[cmdTotem = options.length] = "Fly to \"friend\"" 
    end 
    
    case mode
    when FlyingDialogueMode::AskToFollow
      options[cmdAskFollow = options.length] = "Take in party" 
    when FlyingDialogueMode::TakeInParty
      options[cmdTakeInParty = options.length] = "Take with you"
    when FlyingDialogueMode::Following
      options[cmdTalk = options.length] = "Talk"
    end 
    
    options[cmdCancel = options.length] = "Cancel" 
    
    cmd = pbMessage(_INTL("\\SC[Game]What do you want to do?"), options, cmdCancel+1)
    
    # scMessage("cmd = {1}", cmd)
    flydata = nil
    case cmd 
    when cmdCastle
      flydata = [81, 25, 14]
      SCSwitch.set(:LoadGardens, true)
    when cmdRedwood
      flydata = [95, 24, 20]
      # SCSwitch.set(:LoadGardens, true)
    when cmdTotem
      if SCStoryPokemon.speciesIs(:Totem, :ARCEUS) ||
        SCStoryPokemon.speciesIs(:Totem, :HOOH) ||
        SCStoryPokemon.speciesIs(:Totem, :RAYQUAZA) ||
        SCStoryPokemon.speciesIs(:Totem, :PALKIA) ||
        SCStoryPokemon.speciesIs(:Totem, :DIALGA) ||
        SCStoryPokemon.speciesIs(:Totem, :GIRATINA) ||
        SCStoryPokemon.speciesIs(:Totem, :RESHIRAM) ||
        SCStoryPokemon.speciesIs(:Totem, :ZEKROM) ||
        SCStoryPokemon.speciesIs(:Totem, :YVELTAL) ||
        SCStoryPokemon.speciesIs(:Totem, :SOLGALEO) ||
        SCStoryPokemon.speciesIs(:Totem, :LUNALA)
        # Summit 
        flydata = [109, 17, 15]
        
      elsif SCStoryPokemon.speciesIs(:Totem, :REGIGIGAS)
        # White Grotto
        flydata = [101, 14, 16]
        
      elsif SCStoryPokemon.speciesIs(:Totem, :LUGIA) ||
        SCStoryPokemon.speciesIs(:Totem, :KYOGRE)
        # Underwater Grotto
        flydata = [108, 10, 16]
        
      elsif SCStoryPokemon.speciesIs(:Totem, :GROUDON)
        # Lava Grotto
        flydata = [110, 10, 16]
        
      elsif SCStoryPokemon.speciesIs(:Totem, :XERNEAS) ||
        SCStoryPokemon.speciesIs(:Totem, :ZACIAN) ||
        SCStoryPokemon.speciesIs(:Totem, :ZAMAZENTA)
        # Deep Forest 
        flydata = [111, 14, 19]
        
      else
        # Brown Grotto
        flydata = [109, 14, 16]
      end 
    when cmdAskFollow
      $Trainer.scSetFollowing(SCStoryPokemon::Flying, event_id)
      SCStoryPokemon.loadGraphics
      scMessage("\\SC[Game]{1} will accompany you today!", $Trainer.sc_realpokemons[SCStoryPokemon::Flying].name)
      
    when cmdTakeInParty
      $Trainer.scInsertInParty(SCStoryPokemon::Flying)
      SCStoryPokemon.loadGraphics
      scMessage("\\SC[Game]{1} joins your party!", $Trainer.sc_realpokemons[SCStoryPokemon::Flying].name)
    when cmdTalk
      pbTalkToFollower
    end 
    
    return if !flydata
    
    pbMessage(_INTL("{1} used Fly!",SCStoryPokemon.get(:Flying).name))
    pbFadeOutIn {
      $game_temp.player_new_map_id    = flydata[0]
      $game_temp.player_new_x         = flydata[1]
      $game_temp.player_new_y         = flydata[2]
      $game_temp.player_new_direction = 2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
  end 
end 



