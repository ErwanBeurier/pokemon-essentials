# A raid is a random graph of the form:
#
#     Boss
#  /  |  |  \
# O   O  O   O
# \ / \  / \ /
#  O   O   O
#   \ / \ /
#    O   O 
#     \ /
#    Start 
#
# (Note: level 2 does not need to have exactly 2 nodes, nor does level 3 need to have 3 nodes, nor level 4, 4 nodes.)
#
# Five levels: 
# Level 0 = Start (one node)
# Level 4 = Boss (one node)
# Levels 1-3 = Random Pokémons (2 to 4 nodes)
# 
# Start leads to all nodes of level 2, and all nodes of level 4 uniquely lead to the Boss. 
# If Level N has less nodes than level N+1 (or equal), then all nodes lead to 2 or 3 nodes.
# If Level N has strictly more nodes than level N+1, then all nodes lead to "the closest" two nodes. 


# Store the current dynamax adventure
class PokemonTemp
  attr_accessor :dynamax_adventure
  attr_accessor :max_raid_ranks
end 


# Get the current dynamax adventure. 
def pbGetDynAdventure
  return $PokemonTemp.dynamax_adventure
end 


# Check if the player is currently in a Dynamax adventure.
def isDynAdventure?
  return false if !pbGetDynAdventure
  return true
end 


# Generates/gets the ranks (= list of Pokémons that are available in raids).
def pbGetMaxRaidRanks
  if !$PokemonTemp.max_raid_ranks
    $PokemonTemp.max_raid_ranks = {}
    rank1, rank2, rank3, rank4, rank5 = pbGetMaxRaidSpeciesLists()
    $PokemonTemp.max_raid_ranks[1] = rank1
    $PokemonTemp.max_raid_ranks[2] = rank1 + rank2
    $PokemonTemp.max_raid_ranks[3] = rank2 + rank3
    $PokemonTemp.max_raid_ranks[4] = rank3 + rank4
    $PokemonTemp.max_raid_ranks[5] = rank4
    $PokemonTemp.max_raid_ranks[6] = rank5
  end 
  
  return $PokemonTemp.max_raid_ranks
end 


# Create a dynamax adventure: 
# l is the number of levels (NOT including start + boss rooms)
# terrain = one of the terrains defined in PBDynAdventureTerrains. 
def pbGenerateDynAdventure(l = nil, terrain = nil)
  l = rand(3, 5) if !l
  level_nums = Array.new(l) { |i|  rand(PBDynAdventure::ROOMMIN, PBDynAdventure::ROOMMAX) }
  terrain = PBDynAdventureTerrains.random if !terrain
  
  # DEBUG 
  l = 3
  level_nums = [4, 3, 4, 2, 2]
  terrain = PBDynAdventureTerrains::Mountain
  ranks = pbGetMaxRaidRanks
  $PokemonTemp.dynamax_adventure = PBDynAdventure.new(level_nums, terrain, ranks)
  $PokemonTemp.dynamax_adventure.start
end 


# Registers the trickster event to the current Dynamax adventure.
# This should be called in an Autorun event, and event should be get_character(X)
# where X is the event ID of the trickster event. 
def pbDynRegister(event, event_id)
  pbGetDynAdventure.registerTrickster(event, event_id)
end 


# Handles the transfer of the player into the next room.
# n is the number of the door.
# If the room has 4 rooms, then the doors are numbered from left to right, from 
# 0 to 3.
def pbDynDoor(n)
  ret = pbGetDynAdventure.door(n)
  pbGetDynAdventure.terrain.back_move if !ret
end 




# A tiny change that modifies the Shield Count and the KO count to account for 
# the changes made by the trickster.
class PokeBattle_Battler
  alias __adventure__pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    __adventure__pbInitEffects(batonpass)
    if $game_switches[MAXRAID_SWITCH] && @battle.wildBattle? && opposes? && isDynAdventure?
      # Number of shields. 
      if pbGetDynAdventure.currentRoom.no_shield
        @effects[PBEffects::ShieldCounter] = 0 
      else 
        s = pbGetDynAdventure.currentRoom.shield_max
        @effects[PBEffects::ShieldCounter] = [@effects[PBEffects::ShieldCounter], s].min if s
      end 
      # KO count of the adventure
      @effects[PBEffects::KnockOutCount] = [@effects[PBEffects::KnockOutCount], pbGetDynAdventure.ko_count].min
      pbGetDynAdventure.ko_count_battle = @effects[PBEffects::KnockOutCount]
      
      # KO max for the battle (overrides the KO count of the adventure).
      @effects[PBEffects::KnockOutCount] = pbGetDynAdventure.currentRoom.ko_max if pbGetDynAdventure.currentRoom.ko_max 
    end
  end
end 




# Tiny changes to control the Dynamax. 
class PokeBattle_Battle
  # Forbids Dynamax if the Trickster tricked the player.
  alias __adventure__pbCanDynamax pbCanDynamax?
  def pbCanDynamax?(idxBattler)
    return false if isDynAdventure? && pbGetDynAdventure.currentRoom.dynamax_turns == 0 
    return __adventure__pbCanDynamax(idxBattler)
  end
  
  # Register the KO count for the whole adventure. 
  alias __adventure__pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    if isDynAdventure?
      @battlers.each do |b|
        next if !b.effects[PBEffects::MaxRaidBoss]
        kocount = pbGetDynAdventure.ko_count_battle # Allowed KO's at start.
        kocount -= b.effects[PBEffects::KnockOutCount] # Remaining allowed KO's at the end of the battle.
        pbGetDynAdventure.ko_count -= kocount if kocount > 0 
        break 
      end 
    end 
    __adventure__pbEndOfBattle
  end
end 




# Class handling a room in the Dynamax adventure.
# Contains info on the Pokémon, displays its type (or the Pokémon if revealed),
# or the ID of trickster.
class PBDynAdventureRoom
  attr_reader   :type           # Type of the Pokémon, displayed by default on the map.
  attr_reader   :other_type     # Second type, just for the trickster. 
  attr_accessor :rank           # Rank of the Max Raid that's inside the room.
  attr_accessor :next_rooms     # List of indices of the next rooms you can access from this room. 
  attr_accessor :pokemon        # Triple [base species, form, gender] (as contained in max_raid_ranks.
  attr_reader   :level          # Level of the room in the adventure.
  attr_reader   :index          # Index of the room in the level.
  # Attributes to alter difficulty:
  attr_accessor :shield_max       # Max number of shields (shield level is handled elsewhere)
  attr_accessor :no_shield        # Completely disallow shields.
  attr_reader   :shield_level_mod # Modifier of the shield level. 
  attr_accessor :ko_max           # The player's allowed KOs before being expelled of the adventure.
  attr_accessor :dynamax_turns    # The player's dynamax.
  attr_reader   :poke_revealed    # If true, the Pokémon is displayed. Otherwise, only one of its types. 
  attr_reader   :hidden_type      # If true, then the content of this room is hidden. 
  attr_accessor :trickster        # Index of the trick that the trickster will play. 
  
  
  def initialize(next_rooms, level, index)
    @next_rooms = next_rooms
    @type = -1 
    @rank = -1 
    @pokemon = nil 
    @species = nil 
    @fSpecies = nil 
    @level = level 
    @index = index 
    
    @poke_revealed = false
    @no_shield = false 
    @shield_level_mod = 0 
    @ko_max = nil 
    @shield_max = nil 
    @dynamax_turns = nil 
    @hidden_type = false
    @trickster = nil 
  end 
  
  
  def pokemon=(value)
    # Sets the Pokémon, updates the type + species. 
    @pokemon = value 
    types = [pbGetSpeciesData(value[0],value[1],SpeciesType1), pbGetSpeciesData(value[0],value[1],SpeciesType2)]
    i = rand(types.length)
    @type = types[i]
    @other_type = types[1-i]
    @species = value[0]
    @fSpecies = pbGetFSpeciesFromForm(value[0], value[1])
    @trickster = nil 
  end 
  
  
  def PBDynAdventureRoom.boss_room(pokemon, level)
    # Shortcut for creation of the Boss room. 
    room = PBDynAdventureRoom.new([0], level, 0)
    room.pokemon = pokemon
    room.rank = 6 
    return room 
  end 
  
  
  def empty?
    # Empty if no Pokémon and no Trickster inside. 
    return (!@pokemon && !@trickster)
  end 
  
  
  def desc
    # Returns the string describing the content of the room. Takes into account 
    # whether the room is revealed or not.
    return _INTL("Empty room") if empty?
    return _INTL("Hidden content") if @hidden_type
    
    if @trickster
      ret = _INTL("The trickster is in this room.")
    elsif @poke_revealed
      ret = _INTL("Pokémon: {1} ({2} star)", PBSpecies.getName(@species), @rank) if @rank == 1
      ret = _INTL("Pokémon: {1} ({2} stars)", PBSpecies.getName(@species), @rank) if @rank > 0
    elsif @type && !@hidden_type
      ret = _INTL("Type: {1} ({2} star)", PBTypes.getName(@type), @rank) if @rank == 1
      ret = _INTL("Type: {1} ({2} stars)", PBTypes.getName(@type), @rank) if @rank > 0
    else 
      ret = _INTL("Hidden content")
    end 
    
    debug = false
    ret += " " + scToStringRec(@next_rooms) if debug 
    
    return ret 
  end 
  
  
  def length
    return @next_rooms.length
  end 
  
  
  def processRoom(event, trickster)
    # event = the event representing the trickster.
    # trickster = the PBDynTrickster instance of the adventure (handles how 
    # tricks are played).
    
    return if empty?
    
    if @trickster
      event.moveto($game_player.x, $game_player.y - 2)
      event.move_down
      ret = trickster.play(self, @trickster)
      event.moveto(0, 1)
      
      return ret 
    end 
    
    return maxBattle
  end 
  
  
  def maxBattle
    # Short function to generate a battle without the 
    lvl = [15, 30, 40, 50, 60, 75][@rank-1] + rand(5)
    gmax = rand(10) < 5
    
    pbResetRaidSettings
    setBattleRule("canLose")
    setBattleRule("cannotRun")
    setBattleRule("noPartner")
    setBattleRule(sprintf("%dv%d",MAXRAID_SIZE,1))
    
    $game_switches[MAXRAID_SWITCH] = true 
    $game_variables[MAXRAID_PKMN] = @pokemon + [lvl,gmax]
    ret = pbWildBattleCore(@pokemon[0], lvl)
    pbResetRaidSettings
    $PokemonTemp.clearBattleRules
    for i in $Trainer.party; i.heal; end
    
    # Save the result of the battle in a Game Variable (1 by default)
    #    0 - Undecided or aborted
    #    1 - Player won
    #    2 - Player lost
    #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
    #    4 - Wild Pokémon was caught
    #    5 - Draw
    return ret 
  end 
  
  
  def setShields(num_shields)
    @shield_max = num_shields
    @no_shield = (num_shields == 0)
  end 
  
  
  def setShieldLevelModifier(shield_level_mod)
    @shield_level_mod = shield_level_mod
  end 
  
  
  def reveal
    @poke_revealed = true 
    @hidden_type = false
  end 
  
  
  def hide
    @hidden_type = true
    @poke_revealed = false 
  end 
  
  
  def type
    if @hidden_type || @trickster || empty?
      return 9 # ??? type 
    else 
      return @type 
    end 
  end 
  
  
  def gwidth # graphic width 
    return 64 
  end 
  
  
  def gheight # graphic height. 
    if @poke_revealed && @pokemon
      return 64
    else 
      return 28 
    end 
  end 
end 




# Class handling the whole Dynamax adventure.
# Should be created in pbGenerateDynAdventure rather than manually here. 
class PBDynAdventure
  ROOMMIN = 2
  ROOMMAX = 5
  MAX_NEXT_ROOM = 5 
  NUM_RANKS = 5 
  
  attr_reader   :levels # List of the number of rooms per level. 
  attr_reader   :map # The map of the Dynamax. 
  attr_accessor :ko_count # Number of KO allowed in the adventure. 
  attr_accessor :ko_count_battle # Number of KO allowed at the start of a battle. 
  attr_reader   :terrain 
  
  def initialize(level_nums, terrain, all_ranks)
    level_nums.each { |num|
      if num > ROOMMAX || num < ROOMMIN
        raise _INTL("Cannot generate a Max Raid Adventure with {1} rooms (min: {2}, max: {3})", num, ROOMMIN, ROOMMAX)
      end 
    }
    
    # Player starting position, to return to at the end.
    @start_x = $game_player.x
    @start_y = $game_player.y
    @start_map = $game_map.map_id
    
    # The database of ranks.
    @all_ranks = all_ranks
    
    # Data about the adventure.
    @terrain = terrain
    @levels = level_nums # List of integers
    @levels = [1] + @levels if @levels[0] != 1 # Only one start. 
    @levels.push(1) if @levels[-1] != 1 # Only one boss. 
    @precomputed_ranks = []
    @data = [] # Array: level -> room -> PBDynAdventureRoom
    
    # num of links to next level. 
    @min_density = 2
    @max_density = 4
    
    # Current position of the player in the adventure.
    @current_level = 0
    @current_room = 0 
    
    # Trickster
    @trickster = PBDynTrickster.new(self)
    @trickster_id = nil # Event ID. 
    @trickster_event = nil # Trickster event. Should be initialized with pbDynRegister or registerTrickster.
    
    # Generates the content of the adventure. 
    generateRanks
    generateRooms
    resetKOCount
    
    # Generates the map of the adventure. 
    @map = PBDynAdventureMap.new(self)
  end
  
  
  def resetKOCount
    @ko_count = @levels.length
  end 
  
  
  def registerTrickster(event, event_id)
    # Generates the Trickster + registers the trickster events on the map. 
    @trickster_event = event 
    @trickster_id = event_id
  end 
  
  
  def generateRanks
    # Generates the ranks per level. 
    # Levels can have one or two ranks to be chosen from. 
    quotient = ((@levels.length-2) / NUM_RANKS).to_i + 1
    
    @precomputed_ranks = []
    
    for rank in 1..NUM_RANKS
      @precomputed_ranks += Array.new(quotient, [rank])
      @precomputed_ranks += Array.new(quotient, [rank, rank + 1]) if rank < NUM_RANKS
    end 
    
    # Generally, there will be more rnaks than levels. Delete some items in 
    # the Array so that @precomputed_ranks have the same length as levels.
    
    while @precomputed_ranks.length > @levels.length - 2
      i = rand(@precomputed_ranks.length)
      @precomputed_ranks.delete_at(i)
    end 
    
    @precomputed_ranks.unshift([0]) # Start
    @precomputed_ranks.push([6]) # Boss
  end 
  
  
  def generateRooms
    # Based on the generated ranks, fills the rooms with Pokémons or Trickster.
    # Start leads to all rooms of the next level
    # Last rooms always lead to the Boss room
    # Rooms of middle level lead to some of those of the middle level. 
    
    for level in 0...@levels.length-1
      links = PBDynAdventure.pairsToDict(PBDynAdventure.contiguousLinks(@levels[level], @levels[level+1], 1, 2))
      
      @data[level] = []
      links.each { |k, v| 
        @data[level][k] = PBDynAdventureRoom.new(v, level, k)
        r = generateRank(level) # DEBUG 
        # r = 0
        @data[level][k].rank = r
        
        if r == 0 
          next if level == 0 # Start. 
          
          # Trickster. 
          @data[level][k].trickster = @trickster.randTrick
        else 
          # Pokémon 
          u = rand(@all_ranks[r].length)
          @data[level][k].pokemon = @all_ranks[r][u]
        end 
      }
    end 
    
    # Boss room. 
    poke = @all_ranks[6][rand(@all_ranks[6].length)]
    @data[@levels.length-1] = [PBDynAdventureRoom.boss_room(poke, @levels.length-1)]
  end 
  
  
  def generateRank(level)
    # Generates the rank of the level, based on the precomputed_ranks. 
    if level > 0 && level < @levels.length-1 && rand(10) < 1
      # Trickster
      return 0 
    end 
    
    if @precomputed_ranks[level].length == 1
      return @precomputed_ranks[level][0]
    end
    
    i = rand(@precomputed_ranks[level].length)
    return @precomputed_ranks[level][i]
  end 
  
  
  def PBDynAdventure.contiguousLinks(r1, r2, var, l=nil)
    # r1 = number of rooms of level i 
    # r2 = number of rooms of level i+1
    # var = the actual number will be between l-var and l+var. var should be 1 or 2
    # returns: list of pairs represneting links
    if r1 > r2
      # Use the same function, but invert the links afterwards.
      inverted_links = PBDynAdventure.contiguousLinks(r2, r1, var, l)
      
      links = []
      inverted_links.each { |pair| links.push([pair[1], pair[0]]) }
      return links
    elsif r1 == 1
      # Start
      links = [] 
      for i in 0...r2
        links.push([0, i])
      end 
      return links 
    end 
    
    links = []

    ratio = (r2/r1).to_i + 1
    
    var = 0 if var >= ratio
    var = 0 if var < 0
    
    for i in 0...r1 
      start_j = [(ratio-1)*i, 0].max
      
      temp_l = ratio
      temp_l += rand(2 * var) if var > 0
      temp_l = [temp_l, l].max
      end_j = [ratio*i + temp_l, r2].min
      start_j -= 1 if end_j - start_j == 1 && end_j == r2 
      end_j += 1 if end_j - start_j == 1 && end_j < r2
      
      # Random offset: 
      offset = 0
      offset -= rand(2 * var) if var > 0 && i != 0 && i != r1-1
      start_j += offset
      end_j += offset
      
      for j in start_j...end_j
        links.push([i, j])
      end 
    end 
    # scToString(links)
    return links
  end 
  
  
  def PBDynAdventure.pairsToDict(pairs)
    # transforms:
    # [0, 0], [0, 1], [0, 2], [2, 3], [2, 4]
    # into 
    # 0 -> [0, 1, 2], 2 -> [3, 4]
    dict = {}
    pairs.each { |pair|
      dict[pair[0]] = [] if !dict[pair[0]]
      dict[pair[0]].push(pair[1])
    }
    return dict
  end 
  
  
  def PBDynAdventure.dictToPairs(dict)
    # transforms:
    # 0 -> [0, 1, 2], 2 -> [3, 4]
    # into 
    # [0, 0], [0, 1], [0, 2], [2, 3], [2, 4]
    pairs = []
    dict.each do |key, listval|
      listval.each { |val| pairs.push([key, val]) }
    end
    return pairs 
  end 
  
  
  def atStart? ; return @current_level == 0 ; end 
  def atBoss? ; return @current_level == @levels.length-1 ; end 
  def level ; return @current_level ; end 
  def room ; return @current_room ; end
  
  
  def showMap
    # background tat depends on the environment (forest, grotto, etc.)
    # graph: types + 
    # How to handle maps too big for the screen?
    @map.main
  end 
  
  
  def eachRoom(first_level=nil, last_level=nil)
    # Iterator on the rooms between the given levels. 
    first_level = 0 if !first_level
    last_level = @data.length if !last_level
    
    @data.each_with_index { |rooms, lvl|
      next if lvl < first_level
      break if lvl > last_level
      
      rooms.each_with_index { |room, i|
        yield room, lvl, i
      }
    }
  end
  
  
  def eachNextRoom(level, room_i)
    # Iterator on the rooms that are accessible from the room at the given 
    # level and room index. 
    @data[level][room_i].next_rooms.each { |r| 
      yield @data[level+1][r], level + 1, r
    }
  end 
  
  
  def eachNextRoom2(room)
    # Iterator on the rooms that are accessible from the room at the given 
    # level and room index. 
    self.eachNextRoom(room.level, room.index) { |r|
      yield r 
    }
  end 
  
  
  def bossRoom
    yield @data[@levels.length-1][0]
  end 
  
  
  def start
    # Starts the Dynamax adventure
    pos = @terrain.randRoom(@levels[1])
    
    @current_room = 0
    @current_level = 0
    
    pbTranferPlayer(@terrain.mapid, pos[0], pos[1])
    $PokemonBag.pbStoreItem(:DYNAMAXMAP,1)
    showMap
  end 
  
  
  def exit 
    # Returns the player to the starting point. 
    pbTranferPlayer(@start_map, @start_x, @start_y) # DEBUG
    $PokemonTemp.dynamax_adventure = nil 
    $PokemonBag.pbDeleteItem(:DYNAMAXMAP)
    @map.dispose
  end 
  
  
  def currentRoom
    return @data[@current_level][@current_room]
  end 
  
  
  def door(n)
    # Handles the access to door n of the current room. 
    if self.atBoss?
      # Exit the raid. 
      c = pbMessage("Exit the den?", ["Yes", "No"])
      
      return false if c == 1 
      exit
      return true 
    end 
    
    # Propose going to the next room; tell the player what's inside the next 
    # room.
    n_next = @data[@current_level][@current_room].next_rooms[n]
    
    msg = _INTL("Go to the {1} room? ({2})", 
                ((@current_level == @levels.length - 2) ? "boss" : "next"), 
                @data[@current_level + 1][n_next].desc)
    c = pbMessage(msg, ["Yes", "No"])
    
    return false if c == 1 # No
    
    # Go the the next room. 
    @current_room = n_next
    @current_level += 1
    pos = @terrain.randRoom(@data[@current_level][@current_room].length)
    
    pbTranferPlayer(@terrain.mapid, pos[0], pos[1])
    ret = @data[@current_level][@current_room].processRoom(@trickster_event, @trickster)
    exit if ret == 2 || ret == 3 # Player failed or Player forfeited.
    return true 
  end 
  
  
  def transferToRandomRoomSameLevel
    # For the trickster
    available_rooms = []
    @data[@current_level].each_with_index { |rooms, r|
      available_rooms.push(r) if r != @current_room
    }
    
    @current_room = available_rooms[rand(available_rooms.length)]
    pos = @terrain.randRoom(@data[@current_level][@current_room].length)
    pbTranferPlayer(@terrain.mapid, pos[0], pos[1])
    
    ret = @data[@current_level][@current_room].processRoom(@trickster_event, @trickster)
    exit if ret == 2 || ret == 3 # Player failed or Player forfeited.
  end 
  
  
  def changeNextRooms(room)
    # For the trickster
    eachNextRoom2(room) { |next_room, level, k|
      rk = @data[level][k].rank
      u = rand(@all_ranks[rk].length)
      next_room.pokemon = @all_ranks[rk][u]
    }
  end 
  
  
  def pbTranferPlayer(mapid, x, y, direction = $game_player.direction)
    pbFadeOutIn {
      $game_temp.player_new_map_id    = mapid
      $game_temp.player_new_x         = x
      $game_temp.player_new_y         = y
      $game_temp.player_new_direction = direction
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
  end 
end




# Draws the map of the Dynamax adventure. 
class PBDynAdventureMap 
  
  def initialize(adventure)
    @adventure = adventure
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999+1
    @sprites = {}
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @exit = false 
    @level_start = 0
    @level_end = @level_start + 4
    @lines = []
  end 
  
  
  def create_spriteset 
    # Creates the sprites. 
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].bitmap = Bitmap.new("Graphics/Pictures/introbg")
    
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 20
    @sprites["uparrow"].y = 44
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 20
    @sprites["downarrow"].y = 298
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    
    
    drawTypes
    drawGraph 
    drawCursors
    
  end 
  
  
  def drawTypes
    # Draws the types, or the Pokémons on the map. 
    @adventure.eachRoom(@level_start - 1, @level_end + 1) do |room, lvl, r|
      s = "room" + lvl.to_s + "-" + r.to_s
      
      r_width = ((512 - @adventure.levels[lvl] * 64) / (@adventure.levels[lvl] + 1)).floor
      l = @level_end - lvl 
      
      @sprites[s] = getRoomGraphics(room)
      @sprites[s].x = r_width * (r + 1) + 64 * r
      @sprites[s].y = 55 + l*69 - (room.poke_revealed ? 32 : 14)
      @sprites[s].z = 2
    end 
  end 
  
  
  def drawGraph 
    # Draws lines. 
    @sprites["tree"] = Sprite.new(@viewport)
    @sprites["tree"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["tree"].z = 1 
    # @sprites["tree"].visible = false 
    
    @lines = [] 
    @adventure.eachRoom(@level_start - 1, @level_end) do |room, lvl, r|
      next if lvl == @adventure.levels.length - 1
      s1 = "room" + lvl.to_s + "-" + r.to_s
      
      x1 = @sprites[s1].x + (room.gwidth / 2)
      y1 = @sprites[s1].y + (room.gheight / 2)
      
      @adventure.eachNextRoom(lvl, r) { |room2, lvl2, r2|
      # room.next_rooms.each { |r2|
        s2 = "room" + lvl2.to_s + "-" + r2.to_s
        
        x2 = @sprites[s2].x + (room2.gwidth / 2)
        y2 = @sprites[s2].y + (room2.gheight / 2)
        drawLine(x1, y1, x2, y2)
        drawLine(x1+1, y1, x2+1, y2)
        drawLine(x1-1, y1, x2-1, y2)
      }
    end 
  end 
  
  
  def drawLine(x1, y1, x2, y2)
    # Draws a line. 
    color = Color.new(0,0,0)
    
    if (x1 - x2).abs < (y1-y2).abs
      for y in [y1, y2].min...[y1, y2].max
        x = (y - y1) * (x2 - x1) / (y2 - y1) + x1
        @sprites["tree"].bitmap.set_pixel(x, y, color)
      end 
    else
      for x in [x1, x2].min...[x1, x2].max
        y = (x - x1) * (y2 - y1) / (x2 - x1) + y1
        @sprites["tree"].bitmap.set_pixel(x, y, color)
      end 
    end 
  end 
  
  
  def getRoomGraphics(room)
    # Returns the sprites to show: Pokémon if revealed, or type. 
    if room.poke_revealed && room.pokemon
      ret = PokemonSpeciesIconSprite.new(0,@viewport)
      ret.pbSetParams(room.pokemon[0],room.pokemon[2],room.pokemon[1])
      return ret 
    else 
      type = room.type 
      
      # Make the sprite. 
      ret = Sprite.new(@viewport)
      ret.bitmap = @typebitmap.bitmap
      ret.src_rect.height = 28
      ret.src_rect.y = type*28
      return ret 
    end 
  end 
  
  
  def drawCursors
    if @level_end < @adventure.levels.length - 1
      @sprites["uparrow"].visible = true
    end 
    if @level_start > 0 
      @sprites["downarrow"].visible = true
    end 
  end 
  
  
  def update 
		pbUpdateSpriteHash(@sprites)
    
		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#@wanted_data = -1
			@exit = true
		end
    
    if Input.trigger?(Input::UP) && @level_end < @adventure.levels.length - 1
      @level_end += 1
      @level_start += 1
      pbPlayCursorSE
      create_spriteset
    end 
    
    if Input.trigger?(Input::DOWN) && @level_start > 0
      @level_end -= 1
      @level_start -= 1
      pbPlayCursorSE
      create_spriteset
    end 
  end 
  
  
	def main
    @exit = false 
		if !@exit
			# Graphics.freeze
      pbFadeOutIn {
        create_spriteset
      }
			# Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
    pbFadeOutAndHide(@sprites)
		# Graphics.freeze
		pbDisposeSpriteHash(@sprites)
    # @viewport.dispose
		# Graphics.transition
	end
  
  
  def dispose 
		pbDisposeSpriteHash(@sprites) if @sprites 
    @viewport.dispose
  end 
end 




# Tricks the player, sometimes positively and sometimes negatively. 
class PBDynTrickster
  def initialize(adventure)
    @adventure = adventure
    
    # All positive: 
    @cancel_all_shields = 0
    @reduce_shields_by_one = 0
    @reveal_boss = 0
    @reveal_next_rooms = 0
    @give_boss_second_type = 0
    @reset_ko_count = 0
    @increase_dynamax_turns = 0
    @increase_dynamax_turns_boss = 0
    @ko_max_adventure_increase = 0
    @ko_max_room_increase = 0
    
    # All negative: 
    @move_to_different_room = 0
    @forbid_dynamax_next_room = 0
    @hide_next_rooms = 0
    @change_next_rooms = 0
    @ko_max_adventure_decrease = 0
    @ko_max_room_decrease = 0
    
    # Probabilities.
    @probs = []
    @probs[@cancel_all_shields = @probs.length]        = 1
    @probs[@reduce_shields_by_one = @probs.length]     = 5
    @probs[@reveal_boss = @probs.length]               = 2
    @probs[@reveal_next_rooms = @probs.length]         = 5
    @probs[@give_boss_second_type = @probs.length]     = 2
    @probs[@reset_ko_count = @probs.length]            = 3
    @probs[@increase_dynamax_turns = @probs.length]    = 3
    @probs[@increase_dynamax_turns_boss = @probs.length] = 3
    @probs[@move_to_different_room = @probs.length]    = 2
    @probs[@forbid_dynamax_next_room = @probs.length]  = 3
    @probs[@hide_next_rooms = @probs.length]           = 5
    @probs[@change_next_rooms = @probs.length]         = 1
    @probs[@ko_max_adventure_increase = @probs.length] = 1
    @probs[@ko_max_room_increase = @probs.length]      = 3
    @probs[@ko_max_adventure_decrease = @probs.length] = 1
    @probs[@ko_max_room_decrease = @probs.length]      = 3
    
    # Compute the probabilities
    @prob_sum = 0
    @probs.each { |p| @prob_sum += p }
  end 
  
  
  def randTrick
    choice = rand(@prob_sum)
    the_trick = -1 
    cumul = 0 
    
    @probs.each_with_index do |prob, i| 
      cumul += prob 
      
      if cumul >= choice
        the_trick = i - 1
        break 
      end 
    end 
    
    # pbMessage(_INTL("choice={1}, the_trick={2}, cumul={3}", choice, the_trick, cumul))
    return the_trick
  end 
  
  
  def play(room, choice)
    case choice
    # -------------------------------------------
    when @cancel_all_shields
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.setShields(0)
      }
      pbMessage("You're lucky, I cancelled the shields of all the Pokémon in the next rooms.")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @reduce_shields_by_one
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.setShieldLevelModifier(-1)
      }
      pbMessage("You're lucky, I decreased the shield level of all the Pokémon in the next rooms.")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @reveal_boss
      pbMessage("Want some good news?")
      @adventure.bossRoom { |r| 
        r.reveal 
        pbMessage(_INTL("I know who the boss of this adventure is! It's {1}!", PBSpecies.getName(r.pokemon[0])))
      }
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @reveal_next_rooms
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.reveal
      }
      pbMessage("Let me check your map...")
      pbMessage("I marked all the Pokémon of the next rooms!")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @give_boss_second_type
      @adventure.bossRoom { |r| 
        pbMessage(_INTL("I know who the boss of this adventure is!"))
        pbMessage(_INTL("But I'm not giving you that information."))
        pbMessage(_INTL("I can tell you that the boss' second type is: {1}.", PBTypes.getName(r.other_type)))
        pbMessage(_INTL("Good luck champ!"))
      }
    # -------------------------------------------
    when @reset_ko_count
      @adventure.resetKOCount
      pbMessage("Hi!")
      pbMessage("I reset the KO count for the adventure!")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @ko_max_room_increase
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.ko_max += 2
      }
      pbMessage("Hi!")
      pbMessage("You are allowed two more KO's in the next rooms!")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @ko_max_adventure_increase
      @adventure.ko_count += 2
      pbMessage("Hi!")
      pbMessage("You are allowed two more KO's in your adventure!")
      pbMessage("Good luck champ!")
    
    # -------------------------------------------
    when @ko_max_room_decrease
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.ko_max -= 1
      }
      pbMessage("Hi!")
      pbMessage("You are allowed one less KO in the next rooms!")
      pbMessage("Muahahahaha!")
    
    # -------------------------------------------
    when @ko_max_adventure_decrease
      @adventure.ko_count -= 1
      
      pbMessage("Hi!")
      pbMessage("I decrased your KO count by one!")
      pbMessage("Muahahahaha!")
      
    # -------------------------------------------
    when @increase_dynamax_turns
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.dynamax_turns = DYNAMAX_TURNS + 1
      }
      pbMessage("Lucky you! You get one more Dynamax turn if you dynamax in the next rooms!")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @increase_dynamax_turns_boss
      @adventure.bossRoom { |r| 
        r.dynamax_turns = DYNAMAX_TURNS + 2
      }
      pbMessage("Lucky you! You get two more Dynamax turns if you dynamax at the boss!")
      pbMessage("Good luck champ!")
      
    # -------------------------------------------
    when @move_to_different_room
      pbMessage("Surprise!")
      pbMessage("I'm moving you to another random room!")
      pbMessage("3")
      pbMessage("2")
      pbMessage("1")
      pbMessage("Poof!")
      @adventure.transferToRandomRoomSameLevel
      
    # -------------------------------------------
    when @forbid_dynamax_next_room
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.dynamax_turns = 0
      }
      pbMessage("Surprise!")
      pbMessage("You are not allowed to Dynamax in the next rooms!")
      pbMessage("Muahahahaha!")
      
    # -------------------------------------------
    when @hide_next_rooms
      @adventure.eachNextRoom2(room) { |r, lvl, i| 
        r.hide
      }
      pbMessage("Let me check your map...")
      pbMessage("I've hidden all the Pokémon of the next rooms!")
      pbMessage("Muahahahaha!")
      
    # -------------------------------------------
    when @change_next_rooms
      @adventure.changeNextRooms(room)
      pbMessage("Let me check your map...")
      pbMessage("I've changed all the Pokémons of the next rooms!")
      pbMessage("I don't know if I should laugh or not...")
    end 
  end 
end 




# Small class handling the terrain; just to store the content of the map, how 
# rooms are handled on the map. 
# This class is for the maps where the player enters a door to access another 
# room. For rooms with teleporters, check the next class.
class PBDynAdventureTerrain
  attr_reader   :mapid
  
  
  def initialize(mapid, positions)
    # positions = dict: number of exits -> list of pairs of positions in the map
    @positions = positions
    @mapid = mapid
  end 
  
  
  def randRoom(num_rooms)
    # Chooses a random room among those that lead to num_rooms next rooms.
    rooms = @positions[num_rooms]
    raise _INTL("No room leading to {1} rooms, in mapid {2}", num_rooms, @mapid) if !rooms
    
    return rooms[rand(rooms.length)]
  end
  
  
  def back_move
    $game_player.move_down
  end 
end 




# This class is for the maps where the player talks to a teleporter to access 
# another room. 
class PBDynAdventureTerrainWithTeleporters < PBDynAdventureTerrain
  def back_move
    return 
  end 
end 




# Module containing constants for terrains (instances of PBDynAdventureTerrain).
module PBDynAdventureTerrains
  
  # General case. 
  positions = {}
  
  for i in 0...PBDynAdventure::MAX_NEXT_ROOM
    # General positions
    # 8 variants, regular rooms 
    positions[i+1] = []
    
    for j in 0...8 
      positions[i+1].push([13 + 23 * i, 10 + j * 12])
    end 
    
  end 
  
  # Forest maps are wider, have less rooms.
  positions_forests = {}
  positions_forests[1] = Array.new(5) { |i| [14, 10 + j * 16] }
  positions_forests[2] = Array.new(5) { |i| [36, 10 + j * 16] }
  positions_forests[3] = Array.new(5) { |i| [59, 10 + j * 16] }
  positions_forests[4] = Array.new(5) { |i| [85, 12 + j * 16] }
  positions_forests[5] = Array.new(5) { |i| [120, 12 + j * 16] }
  
  
  # Make the terrains. 
  Mountain = PBDynAdventureTerrain.new(88, positions)
  Volcano = PBDynAdventureTerrain.new(89, positions)
  Grotto = PBDynAdventureTerrain.new(90, positions)
  WhiteCave = PBDynAdventureTerrain.new(91, positions)
  Graveyard = PBDynAdventureTerrainWithTeleporters.new(92, positions)
  Ruins = PBDynAdventureTerrainWithTeleporters.new(93, positions)
  Forest = PBDynAdventureTerrain.new(94, positions_forests)
  
  
  # Forests: less rooms, rooms are wider.
  # ForestDark = 
  # ForestFairy = 
  # Cavern = 
  # GrottoTeleporter = 
  # Mansion = 
  
  def PBDynAdventureTerrains.random
    l = [Mountain, Volcano, Grotto, WhiteCave, Graveyard, Ruins]
    
    return l[rand(l.length)]
  end 
end 




# Map of the Dynamax adventure.
ItemHandlers::UseFromBag.add(:DYNAMAXMAP,proc { |item|
  next 0 if !isDynAdventure?
  pbGetDynAdventure.showMap
  next 1 
})

