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
  attr_accessor :max_raid_adventure
  attr_accessor :max_raid_ranks
end 

# Get the current dynamax adventure. 
def pbGetDynAdventure
  return $PokemonTemp.max_raid_adventure
end 

def isDynAdventure?
  return false if !$PokemonTemp.max_raid_adventure
  return true
end 

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
  level_nums = [4, 3, 4]
  terrain = PBDynAdventureTerrains::Mountain
  ranks = pbGetMaxRaidRanks
  $PokemonTemp.max_raid_adventure = PBDynAdventure.new(level_nums, terrain, ranks)
  $PokemonTemp.max_raid_adventure.showMap
  $PokemonTemp.max_raid_adventure.start
end 


# Handles the transfer of the player into the next room.
# n is the number of the door.
# If the room has 4 rooms, then the doors are numbered from left to right, from 0 to 3. 
def pbDynDoor(n)
  ret = pbGetDynAdventure.door(n)
  $game_player.move_down if !ret
end 

class PokeBattle_Battler
  alias __adventure__pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    __adventure__pbInitEffects(batonpass)
    if $game_switches[MAXRAID_SWITCH] && @battle.wildBattle? && opposes? && isDynAdventure?
      @effects[PBEffects::ShieldCounter] = 0 if pbGetDynAdventure.currentRoom.no_shield
      if pbGetDynAdventure.currentRoom.ko_max && @effects[PBEffects::KnockOutCount] > pbGetDynAdventure.currentRoom.ko_max
        @effects[PBEffects::KnockOutCount] = pbGetDynAdventure.currentRoom.ko_max
      end 
    end
  end
end 

# Class handling a room in the Dynamax adventure.
# Contains info on the Pokémon, displays its type (or the Pokémon if revealed)
class PBDynAdventureRoom
  attr_reader   :type
  attr_accessor :rank
  attr_accessor :next_rooms # list of indicdes of the next rooms you can access from this room. 
  attr_accessor :pokemon # Triple [base species, form, gender]
  
  # Attributes to alter difficulty:
  attr_accessor :shield_max     # Max number of shields. 
  attr_accessor :no_shield      # Completely disallow shields.
  attr_accessor :ko_max         # the player's allowed KOs.
  attr_accessor :dynamax_turns  # the player's dynamax
  attr_accessor :revealed       # If true, the Pokémon is displayed. Otherwise, only one of its types. 
  
  def initialize(next_rooms)
    @next_rooms = next_rooms
    @type = -1 
    @rank = -1 
    @pokemon = nil 
    @species = nil 
    @fSpecies = nil 
    
    @revealed = true
    @no_shield = false 
    @ko_max = nil 
    @shield_max = nil # Unimplemented yet 
    @dynamax_turns = nil # Unimplemented yet
  end 
  
  # Sets the Pokémon, updates the type + species. 
  def pokemon=(value)
    @pokemon = value 
    types = [pbGetSpeciesData(value[0],value[1],SpeciesType1), pbGetSpeciesData(value[0],value[1],SpeciesType2)]
    @type = types[rand(types.length)]
    @species = value[0]
    @fSpecies = pbGetFSpeciesFromForm(value[0], value[1])
  end 
  
  # 
  def PBDynAdventureRoom.boss_room(pokemon)
    room = PBDynAdventureRoom.new([0])
    room.pokemon = pokemon
    room.rank = 6 
    return room 
  end 
  
  
  def empty?
    return @rank < 0 || !@pokemon
  end 
  
  
  def desc
    return _INTL("Empty room") if empty?
    
    if @revealed
      ret = _INTL("Pokémon: {1} ({2} star)", PBSpecies.getName(@species), @rank) if @rank == 1
      ret = _INTL("Pokémon: {1} ({2} stars)", PBSpecies.getName(@species), @rank) if @rank > 0
    else 
      ret = _INTL("Type: {1} ({2} star)", PBTypes.getName(@type), @rank) if @rank == 1
      ret = _INTL("Type: {1} ({2} stars)", PBTypes.getName(@type), @rank) if @rank > 0
    end 
    
    debug = false
    ret += " " + scToStringRec(@next_rooms) if debug 
    
    return ret 
  end 
  
  
  def length
    return @next_rooms.length
  end 
  
  
  def processRoom
    return if empty?
    
    return maxBattle # For now, only max battles.
  end 
  
  
  def maxBattle
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
end 


class PBDynAdventure
  ROOMMIN = 2
  ROOMMAX = 5
  MAX_NEXT_ROOM = 5 
  NUM_RANKS = 5 
  
  
  def initialize(level_nums, terrain, all_ranks)
    level_nums.each { |num|
      if num > ROOMMAX || num < ROOMMIN
        raise _INTL("Cannot generate a Max Raid Adventure with {1} rooms (min: {2}, max: {3})", num, ROOMMIN, ROOMMAX)
      end 
    }
    
    @start_x = $game_player.x
    @start_y = $game_player.y
    @start_map = $game_map.map_id
    
    @all_ranks = all_ranks
    
    @terrain = terrain
    @levels = level_nums # List of integers
    @levels = [1] + @levels if @levels[0] != 1 # Only one start. 
    @levels.push(1) if @levels[-1] != 1 # Only one boss. 
    
    # num of links to next level. 
    @min_density = 2
    @max_density = 4
    
    @precomputed_ranks = []
    @current_level = 0
    @current_room = 0 
    @data = [] # Array: level -> room -> PBDynAdventureRoom
    
    generateRanks
    generateRooms
    # scToString(@data)
  end
  
  
  def generateRanks
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
    # Start leads to all rooms of the next level
    # Last rooms always lead to the Boss room
    # Rooms of middle level lead to some of those of the middle level. 
    
    for level in 0...@levels.length-1
      links = PBDynAdventure.pairsToDict(PBDynAdventure.contiguousLinks(@levels[level], @levels[level+1], 1, 2))
      
      @data[level] = []
      links.each { |k, v| 
        @data[level][k] = PBDynAdventureRoom.new(v)
        r = generateRank(level)
        @data[level][k].rank = r
        next if r == 0 
        # begin 
        u = rand(@all_ranks[r].length)
        @data[level][k].pokemon = @all_ranks[r][u]
        # rescue 
        # pbMessage(_INTL("r={1}", r))
        # scToString(@precomputed_ranks)
        # end 
        # if !@data[level][k].pokemon
          # pbMessage(_INTL("level = {1}, r = {2}, k = {3}, u = {4}, ranks = {5}", level, r, k, u, @all_ranks[r].length))
        # end 
      }
    end 
    
    @data[@levels.length-1] = [PBDynAdventureRoom.boss_room(@all_ranks[6][rand(@all_ranks[6].length)])]
  end 
  
  
  def generateRank(level)
    if @precomputed_ranks[level].length == 1
      return @precomputed_ranks[level][0]
    end
    
    i = rand(@precomputed_ranks[level].length)
    return @precomputed_ranks[level][i]
  end 
  
  
  def randType
    return @types[rand(@types.length)]
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
  end 
  
  
  def start
    pos = @terrain.randRoom(@levels[1])
    
    @current_room = 0
    @current_level = 0
    
    pbTranferPlayer(@terrain.mapid, pos[0], pos[1])
  end 
  
  def exit 
    pbTranferPlayer(@start_map, @start_x, @start_y) # DEBUG
    $PokemonTemp.max_raid_adventure = nil 
  end 
  
  
  def currentRoom
    return @data[@current_level][@current_room]
  end 
  
  
  def door(n)
    if self.atBoss?
      # Exit the raid. 
      c = pbMessage("Exit the den?", ["Yes", "No"])
      
      return false if c == 1 
      exit
      return true 
    end 
    
    n_next = @data[@current_level][@current_room].next_rooms[n]
    
    # pbMessage(_INTL("n_next = {1}", n_next))
    msg = _INTL("Go to the {1} room? ({2})", 
                ((@current_level == @levels.length - 2) ? "boss" : "next"), 
                @data[@current_level + 1][n_next].desc)
    c = pbMessage(msg, ["Yes", "No"])
    
    return false if c == 1 # No
    
    @current_room = n_next
    @current_level += 1
    pos = @terrain.randRoom(@data[@current_level][@current_room].length)
    
    pbTranferPlayer(@terrain.mapid, pos[0], pos[1])
    ret = @data[@current_level][@current_room].processRoom
    exit if ret == 2 || ret == 3 # Player failed or Player forfeited.
    return true 
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




class PBDynAdventureTerrain
  attr_reader :mapid
  
  def initialize(mapid, positions)
    # positions = dict: number of exits -> list of pairs of positions in the map
    @positions = positions
    @mapid = mapid
  end 
  
  def randRoom(num_rooms)
    rooms = @positions[num_rooms]
    raise _INTL("No room leading to {1} rooms, in mapid {2}", num_rooms, @mapid) if !rooms
    
    return rooms[rand(rooms.length)]
  end
end 


module PBDynAdventureTerrains
  
  # General case. 
  positions = {}
  num_variants = 8 # number of variants of rooms. 
  
  for i in 0...PBDynAdventure::MAX_NEXT_ROOM
    positions[i+1] = []
    
    for j in 0...num_variants
      positions[i+1].push([13 + 23 * i, 10 + j * 12])
    end 
  end 
  
  Mountain = PBDynAdventureTerrain.new(88, positions)
  Volcano = PBDynAdventureTerrain.new(89, positions)
  Grotto = PBDynAdventureTerrain.new(90, positions)
  # Forest = 
  # ForestDark = 
  # ForestFairy = 
  # Cavern = 
  # GrottoTeleporter = 
  # Mansion = 
  
  def PBDynAdventureTerrains.random
    l = [Mountain, Volcano, Grotto]
    
    return l[rand(l.length)]
  end 
end 



