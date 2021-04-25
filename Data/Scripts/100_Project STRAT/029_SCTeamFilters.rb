################################################################################
# SCTeamFilters
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of Team and Moveset filters, that 
# allow the generation of teams in SCTiers following a certain theme (like 
# Rain, Trick Room, or Carboniferous). 
# 
# Content: 
# - The class SCMovesetFilter, that defines how a moveset is to be filtered. 
# - The class SCTeamFilter that contains six (or less) Moveset filters.
# - A few subclasses of Team Filter for very "light" filters.
# - The module SCMovesetFilters that defines some constant Moveset Filters that 
#   serve as elementary bricks for Tema filter.
# - The module SCTeamFilters that defines some constant filters for teams (Rain, 
#   Trick Room, etc.)
################################################################################




class SCMovesetFilter
  attr_accessor :debug
  attr_reader :specific
  
  def initialize(pattern, role, move, type1)
    # The rest of the attributes is to be set later. 
    
    # Constraint on the Pokémon
    @stat_total_interval = nil # Will be list of two values [min, max]
    @stat_intervals = Array.new(6, nil) # Array of list of two values 
    @type1 = type1 
    @type2 = nil 
    @ability = nil
    
    # Constraint on the Moveset
    @role = nil
    self.setRole(role) if role
    @pattern = pattern
    @specific = false
    @move = move # Only ONE move, or a list of possible move and if one fits, it's ok. 
  end 
  
  
  def clone 
    the_clone = SCMovesetFilter.new(@pattern, @role, @move, @type1)
    
    the_clone.makeSpecific if @specific
    the_clone.setTypes(@type1, @type2)
    
    for s in 0...6
      next if !@stat_intervals[s]
      the_clone.setStatInterval(s, @stat_intervals[s][0], @stat_intervals[s][1])
    end 
    
    the_clone.setStatTotalInterval(@stat_total_interval[0], @stat_total_interval[1]) if @stat_total_interval 
    
    return
  end 
  
  
  def isEmpty?()
    return false if @stat_total_interval
    
    for i in 0...6
      return false if @stat_intervals[i]
    end 
    
    return false if @type1
    return false if @type2
    
    return false if @role
    return false if @pattern
    return false if @move
    
    return true 
  end 
  
  
  def makeSpecific ; @specific = true ; end 
  def setStatTotalInterval(minimum, maximum) ; @stat_total_interval = [minimum, maximum] ; end   
  def setStatInterval(stat, minimum, maximum) ; @stat_intervals[stat] = [minimum, maximum] ; end
  def setTypes(type1, type2 = nil) ; @type1 = type1 ; @type2 = type2 ; end 
  def resetTypes() ; @type1 = nil ; @type2 = nil ; end
  def setAbility(ability) ; @ability = (ability.is_a?(Array) ? ability : [ability]) ; end 
  
  
  # Roles 
  def setRole(role)
    if role.is_a?(Array)
      @role = role.clone
    elsif role % 10 == 0 
      @role = Array.new(4) { |i| role + i }
    else 
      @role = role 
    end 
  end 
  
  
  # All the different checks.
  def hasTheRightStats(species_data)
    # Check stat total
    if @stat_total_interval
      total = 0
      species_data[SpeciesBaseStats].each { |bs| total += bs }
      return false if @stat_total_interval[0] > total || @stat_total_interval[1] < total 
    end 
    
    # Check each stat. 
    @stat_intervals.each_with_index { |interval, s|
      next if !interval
      return false if interval[0] > species_data[SpeciesBaseStats][s] || interval[1] < species_data[SpeciesBaseStats][s]
    }
    
    return true 
  end 
  
  
  def hasTheRightTypes(species_data)
    return false if @type1 && species_data[SpeciesType1] != @type1 && species_data[SpeciesType2] != @type1
    return false if @type2 && species_data[SpeciesType1] != @type2 && species_data[SpeciesType2] != @type2
    return true 
  end 
  
  
  def canHaveTheRightRole(fspecies)
    if @role 
      the_roles = scLoadRolesToPoke
      
      if @role.is_a?(Array)
        # Array of roles IDs; it's an OR
        one_of = false 
        @role.each { |r|
          one_of = true if the_roles[r].include?(fspecies)
        }
        return false if !one_of
      else 
        return false if !the_roles[@role].include?(fspecies)
      end 
    end 
    
    return true
  end 
  
  
  def hasTheRightRole(moveset)
    return true if @role == 0 
    if @role 
      if @role.is_a?(Array)
        # Array of roles IDs; it's an OR
        return @role.include?(moveset[SCMovesetsData::ROLE])
      else 
        return @role == moveset[SCMovesetsData::ROLE]
      end 
    end 
    return true
  end 
  
  
  def canHaveTheRightPattern(fspecies)
    if @pattern
      the_patterns = scLoadPatternsToPoke
      
      if @pattern.is_a?(Array)
        # Array of roles IDs; it's an OR
        one_of = false 
        @pattern.each { |p|
          one_of = true if the_patterns[p].include?(fspecies)
        }
        return false if !one_of
      else 
        return false if !the_patterns[@pattern].include?(fspecies)
      end 
    end 
    
    return true 
  end 
  
  
  def hasTheRightPattern(moveset)
    if @pattern 
      if @pattern.is_a?(Array)
        # Array of patterns IDs; it's an OR
        return @pattern.include?(moveset[SCMovesetsData::PATTERN])
      else 
        return @pattern == moveset[SCMovesetsData::PATTERN]
      end 
    end 
    return true
  end 

  
  def canLearnMoves(fspecies)
    return true if !@move
    
    learned = scLoadLearnedMoves[fspecies]
    if @move.is_a?(Array)
      return false if (@move & learned).length == 0
    else 
      return false if !learned.include?(@move)
    end 
    return true 
  end 
  
  
  def hasTheRightMoves(moveset)
    # Note: only checks if contains at least ONE of the wanted moves. 
    return true if !@move
    
    for j in SCMovesetsData::MOVE1..SCMovesetsData::MOVE4
      next if !moveset[j]
      if @move.is_a?(Array)
        # If contains one of the wanted moves. 
        return true if (@move & moveset[j]).length > 0
      else 
        return true if moveset[j].include?(@move)
      end 
    end 
    
    return false
  end 
  
  
  def hasTheRightAbility(moveset, species_data)
    # First step: check if the species has the ability. 
    return true if !@ability
    
    hidden_abils = species_data[SpeciesHiddenAbility]
    hidden_abils = [hidden_abils] if !hidden_abils.is_a?(Array)
    abils = species_data[SpeciesAbilities]
    abils = [abils] if !abils.is_a?(Array)
    return false if ((abils + hidden_abils) & @ability).length == 0
    
    # Second step: check if the moveset requires the very same ability.
    mv_ab = moveset[SCMovesetsData::ABILITYINDEX]
    
    if mv_ab
      # Then the ability is required. Check if it fits the pattern. 
      if mv_ab == 0 || mv_ab == 1
        return false if !@ability.include?(abils[mv_ab])
      else 
        return false if !@ability.include?(hidden_abils[mv_ab])
      end 
    else 
      # The Pokémon has the right ability + the moveset doesn't require any.
      ab = nil 
      abils.each_with_index { |abil, i| 
        if @ability.include?(abil)
          ab = i
          break 
        end 
      }
      if !ab 
        hidden_abils.each_with_index { |abil, i| 
          if @ability.include?(abil)
            ab = i + 2
            break 
          end 
        }
      end 
      moveset[SCMovesetsData::ABILITYINDEX] = ab
    end 
    
    return true 
  end 
  
  
  def fitsRole?(role)
    return true if !@role 
    return true if role == 0 # Any roles. 
    
    role_convert = []
    
    case role
    when 10, 20, 30, 40
      role_convert = [role + 1, role + 2, role + 3]
    when 15 # Means wanted a lead but couldn't find any. Try offensive.
      role_convert = [21, 22, 23]
    else 
      role_convert = [role]
    end 
    
    if @role.is_a?(Array)
      return (role_convert & @role).length > 0
    else 
      return role_convert.include?(@role)
    end 
  end 
  
  
  # An instance of pkmndata, in which all the choices are made.
  def fitsSpecies?(species, form)
    # return true if self.isEmpty?
    species_data = pbGetSpeciesData(species, form)
    fspecies = pbGetFSpeciesFromForm(species, form)
    
    return false if !self.hasTheRightStats(species_data)
    return false if !self.hasTheRightTypes(species_data)
    return false if !self.canHaveTheRightRole(fspecies)
    return false if !self.canHaveTheRightPattern(fspecies)
    return false if !self.canLearnMoves(fspecies)
    
    return true 
  end 
  
  
  def fitsMoveset?(moveset, allowed_errors = 0)
    # return true if self.isEmpty?
    # Just in case the team generation doesn't find anything, allow the moveset to not perfectly fit the filter.
    error_count = 0
    # @debug = moveset[SCMovesetsData::BASESPECIES] == PBSpecies::TORKOAL && @ability[0] == PBAbilities::DROUGHT
    
    
    # Avoid Distorsion setters if the filter doesn't require it.
    error_count += 1 if !@specific && moveset[SCMovesetsData::SPECIFIC] 
    
    # The fast: 
    pbMessage("Testing role") if @debug 
    error_count += 1 if !self.hasTheRightRole(moveset)
    return false if allowed_errors < error_count
    pbMessage("testing pattern") if @debug 
    error_count += 1 if !self.hasTheRightPattern(moveset)
    return false if allowed_errors < error_count
    pbMessage("Testing moves") if @debug 
    error_count += 1 if !self.hasTheRightMoves(moveset)
    return false if allowed_errors < error_count
    
    # The slow: 
    species = moveset[SCMovesetsData::BASESPECIES]
    form = moveset[SCMovesetsData::FORM] || 0 
    species_data = pbGetSpeciesData(species, form)
    
    pbMessage("Testing stats") if @debug 
    error_count += 1 if !self.hasTheRightStats(species_data)
    return false if allowed_errors < error_count
    pbMessage("Testing types") if @debug 
    error_count += 1 if !self.hasTheRightTypes(species_data)
    return false if allowed_errors < error_count
    pbMessage("Testing Ability") if @debug 
    error_count += 1 if !self.hasTheRightAbility(moveset, species_data)
    return false if allowed_errors < error_count
    
    pbMessage("Fits!") if @debug 
    return true 
  end 
  
  
  def self.specByAbility(*args)
    filter = SCMovesetFilter.new(nil, nil, nil, nil)
    filter.setAbility(args)
    filter.makeSpecific
    return filter 
  end 
  
  
  def self.specByType(type)
    filter = SCMovesetFilter.new(nil, nil, nil, type)
    filter.makeSpecific
    return filter 
  end 
end 




class SCTeamFilter
	attr_reader :name
  
  
  def initialize(name, fixed_roles = nil, roles = nil)
    @name = name # Mainly for debug. 
    @filters = Array.new(6) # nil until set. 
    @fixed_roles = fixed_roles # Give a list of 0 if the filters already define the roles. 
    @roles = roles
  end 
  
  
  def setMovesetFilter(i, mvstfilter)
    @filters[i] = mvstfilter
  end 
  
  
  def setMovesetFilters(*args)
    raise _INTL("Error: cannot set more than 6 filters; given {1}", args.length) if args.length > 6
    i = 0 
    for arg in args
      @filters[i] = arg
      i += 1
    end 
  end 
  
  
  def checkFilter(i, movesetdata, allowed_errors = 0)
    return true if !@filters[i]
    
    return @filters[i].fitsMoveset?(movesetdata, allowed_errors)
  end
  
  
  def getShuffledRoles(for_database = false)
    return Array.new(6, 0) if !@fixed_roles && !@roles
    
    ret = @fixed_roles if @fixed_roles && !@roles
    ret = @roles if !@fixed_roles && @roles
    
    if for_database && @fixed_roles && @roles
      ret = @fixed_roles + @roles
    elsif @fixed_roles && @roles 
      ret = @fixed_roles + scsample(@roles, @roles.length)
    end 
    
    if ret.length != 6 
      raise _INTL("Erroneous Team Filter: {1} doesn't have the right number of roles + fixed roles (got {2}, expected 6)", @name, ret.length)
    end 
    
    return ret
  end 
  
  
  def eachFittingMoveset(movesetdata, fspecies, role, allowed_errors)
    # pk_movesets = The list of Movesets of the given Pokémon 
    # pbMessage("Coucou Ledian") if fspecies == PBSpecies::LEDIAN
    @filters.each_with_index { |filter, ind|
      next if filter && !filter.fitsRole?(role)
      
      if role == 0 # Then we don't care about the role. 
        movesetdata[fspecies][0].each { |mv|
          mv = mv.clone
          # pbMessage("LEDIANNNNNNNN") if fspecies == PBSpecies::LEDIAN && mv[SCMovesetsData::MOVE1][0] == PBMoves::CARBONIFEROUS
          res = checkFilter(ind, mv, allowed_errors)
          yield mv, ind, filter if res
          # pbMessage(_INTL("res = {1}", res)) if fspecies == PBSpecies::LEDIAN && mv[SCMovesetsData::MOVE1][0] == PBMoves::CARBONIFEROUS
        }
      else 
        SCTeamFilter.eachConvertedRole(role) { |r| 
          next if !movesetdata[fspecies][r]
          # pbMessage("Gladyyyyyyyyyyys") if fspecies == PBSpecies::LEDIAN
          
          movesetdata[fspecies][r].each { |mv| 
            mv = mv.clone
            yield mv, ind, filter if checkFilter(ind, mv, allowed_errors)
          }
        }
      end 
    }
  end 
  
  
  def self.eachConvertedRole(role)
    role_convert = [] 
    case role
    when 10, 20, 30, 40
      role_convert = [role + 1, role + 2, role + 3]
    when 15 # Means wanted a lead but couldn't find any. Try offensive.
      role_convert = [21, 22, 23]
    else 
      role_convert = [role]
    end 
    role_convert.each { |r| yield r }
  end 
  
  
  def vary()
    return self
  end 
end 





class SCDummyTeamFilter < SCTeamFilter
  # Team filters without 
  
  SixDifferentTypes = 0
  ThreeDifferentTypes = 1
  TripleTypes = 2
  
  
  def vary(mode = 0)
    chosen_types = []
    
    case mode
    when ThreeDifferentTypes
      # Three types, appearing twice.
      chosen_types = scsample(PBTypes.getRegularTypeList(), 3)
      chosen_types = chosen_types + chosen_types
      
    when TripleTypes
      # Three times the same type, and three other types 
      # = Four types, one of which appears three times instead of one. 
      chosen_types = scsample(PBTypes.getRegularTypeList(), 4)
      chosen_types.push(chosen_types[0])
      chosen_types.push(chosen_types[0])
      
    else #when SixDifferentTypes
      # Six different types.
      chosen_types = scsample(PBTypes.getRegularTypeList(), 6)
    end 
    
    variation = SCTeamFilter.new(@name, @fixed_roles.clone, @roles.clone)
    
    s = "" 
    for i in 0...6
      c = SCMovesetFilter.new(nil, nil, nil, chosen_types[i])
      variation.setMovesetFilter(i, c)
      s += _INTL("{1}", PBTypes.getName(chosen_types[i]))
      s += "-" if i < 5
    end 
    # pbMessage(s)
    
    return variation
  end 
end 




class SCRandomTeamFilter
  attr_reader :name
  
  def initialize()
    @name = "Random"
    @generating = [SCTeamFilters::HyperOffense, 
                  SCTeamFilters::Offense, 
                  SCTeamFilters::Balanced, 
                  SCTeamFilters::Defensive, 
                  SCTeamFilters::Stall]
  end 
  
  def choose()
    return @generating[rand(@generating.length)]
  end 
end 




module SCMovesetFilters
  GeneralLead = SCMovesetFilter.new(nil, 10, nil, nil)
  GeneralPhysicalLead = SCMovesetFilter.new(nil, 11, nil, nil)
  GeneralSpecialLead = SCMovesetFilter.new(nil, 12, nil, nil)
  GeneralMixedLead = SCMovesetFilter.new(nil, 13, nil, nil)
  
  GeneralOffensive = SCMovesetFilter.new(nil, 20, nil, nil)
  GeneralPhysicalOffensive = SCMovesetFilter.new(nil, 21, nil, nil)
  GeneralSpecialOffensive = SCMovesetFilter.new(nil, 22, nil, nil)
  GeneralMixedOffensive = SCMovesetFilter.new(nil, 23, nil, nil)
  
  GeneralDefensive = SCMovesetFilter.new(nil, 30, nil, nil)
  GeneralPhysicalDefensive = SCMovesetFilter.new(nil, 31, nil, nil)
  GeneralSpecialDefensive = SCMovesetFilter.new(nil, 32, nil, nil)
  GeneralMixedDefensive = SCMovesetFilter.new(nil, 33, nil, nil)
  
  GeneralSupport = SCMovesetFilter.new(nil, 40, nil, nil)
  GeneralPhysicalSupport = SCMovesetFilter.new(nil, 41, nil, nil)
  GeneralSpecialSupport = SCMovesetFilter.new(nil, 42, nil, nil)
  GeneralMixedSupport = SCMovesetFilter.new(nil, 43, nil, nil)
  
  begin 
  CarboniferousSetter = SCMovesetFilter.new(nil, nil, PBMoves::CARBONIFEROUS, nil)
  CarboniferousSetter.makeSpecific
  CarboniferousBug = SCMovesetFilter.new(nil, nil, nil, PBTypes::BUG)
  
  MagneticTerrainSetter = SCMovesetFilter.new(nil, nil, PBMoves::MAGNETICTERRAIN, nil)
  MagneticTerrainSetter.makeSpecific
  MagneticTerrainElectric = SCMovesetFilter.new(nil, nil, nil, PBTypes::ELECTRIC)
  MagneticTerrainSteel = SCMovesetFilter.new(nil, nil, nil, PBTypes::STEEL)
  
  TrickRoomSetter = SCMovesetFilter.new(nil, nil, PBMoves::TRICKROOM, nil)
  TrickRoomSetter.makeSpecific
  TrickRoomOffense = SCMovesetFilter.new(nil, 20, nil, nil)
  TrickRoomOffense.setStatInterval(PBStats::SPEED, 0, 60)
  
  
  RainSetter = SCMovesetFilter.new(nil, nil, nil, nil)
  RainSetter.setAbility(PBAbilities::DRIZZLE)
  RainSetter.makeSpecific
  RainEnjoyer1 = SCMovesetFilter.new(nil, nil, nil, nil)
  RainEnjoyer1.setAbility([PBAbilities::RAINDISH, PBAbilities::HYDRATION, PBAbilities::SWIFTSWIM])
  RainEnjoyer1.makeSpecific
  RainEnjoyer2 = SCMovesetFilter.new(nil, nil, nil, PBTypes::STEEL)
  
  SunSetter = SCMovesetFilter.new(nil, nil, nil, nil)
  SunSetter.setAbility(PBAbilities::DROUGHT)
  SunSetter.makeSpecific
  SunEnjoyer1 = SCMovesetFilter.new(nil, nil, nil, nil)
  SunEnjoyer1.setAbility([PBAbilities::CHLOROPHYLL, PBAbilities::SOLARPOWER, PBAbilities::LEAFGUARD, PBAbilities::FLOWERGIFT])
  SunEnjoyer1.makeSpecific
  SunEnjoyer2 = SCMovesetFilter.new(nil, nil, nil, PBTypes::FIRE)
  
  SandSetter = SCMovesetFilter.new(nil, nil, nil, nil)
  SandSetter.setAbility([PBAbilities::SANDSPIT, PBAbilities::SANDSTREAM])
  SandSetter.makeSpecific
  SandEnjoyer = SCMovesetFilter.new(nil, nil, nil, nil)
  SandEnjoyer.setAbility([PBAbilities::SANDRUSH, PBAbilities::SANDFORCE])
  
  HailSetter = SCMovesetFilter.new(nil, nil, nil, nil)
  HailSetter.setAbility(PBAbilities::SNOWWARNING)
  HailSetter.makeSpecific
  HailEnjoyer1 = SCMovesetFilter.new(nil, nil, nil, nil)
  HailEnjoyer1.setAbility([PBAbilities::ICEBODY, PBAbilities::SLUSHRUSH, PBAbilities::ICEFACE])
  HailEnjoyer2 = SCMovesetFilter.new(nil, nil, [PBMoves::HURRICANE, PBMoves::BLIZZARD], nil)
  HailEnjoyer2.makeSpecific
  
  
  Test1_1 = SCMovesetFilter.new(nil, nil, PBMoves::CALMMIND, nil)
  Test1_2 = SCMovesetFilter.new(nil, nil, nil, PBTypes::FIRE)
  Test1_3 = SCMovesetFilter.new(nil, nil, nil, PBTypes::WATER)
  Test1_4 = SCMovesetFilter.new(SCMovesetPatterns::WELCOMELEADSPE, nil, nil, nil)
  # Test1_4.debug = true
  Test1_5 = SCMovesetFilter.new(nil, 20, nil, PBTypes::GRASS)
  Test1_6 = SCMovesetFilter.new(nil, nil, nil, PBTypes::FIRE)
  rescue
  end 
end 




module SCTeamFilters
  HyperOffense = SCDummyTeamFilter.new("Hyper Offense", [10], [21, 21, 22, 22, 0])
  Offense = SCDummyTeamFilter.new("Offense", [10], [20, 21, 22, 31, 32])
  Balanced = SCDummyTeamFilter.new("Balanced", [10], [21, 22, 31, 32, 40])
  Defensive = SCDummyTeamFilter.new("Defensive", [], [21, 22, 31, 31, 32, 32])
  Stall = SCDummyTeamFilter.new("Stall", [], [31, 31, 32, 32, 30, 0])
  Random = SCRandomTeamFilter.new()
  
  begin 
  Carboniferous = SCTeamFilter.new("Carboniferous", [0, 0, 0, 0, 0, 0])
  Carboniferous.setMovesetFilters(SCMovesetFilters::CarboniferousSetter, 
                                  SCMovesetFilters::CarboniferousBug,
                                  SCMovesetFilters::CarboniferousBug, 
                                  SCMovesetFilters::CarboniferousBug)
                                  
  TrickRoom = SCTeamFilter.new("Trick Room", [0, 0, 0, 0, 0, 0])
  TrickRoom.setMovesetFilters(SCMovesetFilters::TrickRoomSetter, 
                              SCMovesetFilters::TrickRoomOffense, 
                              SCMovesetFilters::TrickRoomOffense, 
                              SCMovesetFilters::TrickRoomSetter,
                              SCMovesetFilters::TrickRoomSetter,
                              SCMovesetFilters::TrickRoomOffense)
  
  Rain = SCTeamFilter.new("Rain", [0, 0, 20, 20, 20, 0])
  Rain.setMovesetFilters(SCMovesetFilters::RainSetter, 
                        SCMovesetFilters::RainEnjoyer1,
                        SCMovesetFilters::RainEnjoyer1,
                        SCMovesetFilters::RainSetter,
                        SCMovesetFilters::RainEnjoyer2)
  
  Sun = SCTeamFilter.new("Sun", [0, 0, 20, 20, 20, 0])
  Sun.setMovesetFilters(SCMovesetFilters::SunSetter, 
                        SCMovesetFilters::SunEnjoyer1,
                        SCMovesetFilters::SunEnjoyer1,
                        SCMovesetFilters::SunSetter,
                        SCMovesetFilters::SunEnjoyer2)
  
  Hail = SCTeamFilter.new("Hail", [0, 0, 20, 20, 20, 0])
  Hail.setMovesetFilters(SCMovesetFilters::HailSetter, 
                        SCMovesetFilters::HailEnjoyer1,
                        SCMovesetFilters::HailSetter,
                        SCMovesetFilters::HailEnjoyer2)
  
  Sand = SCTeamFilter.new("Sand", [0, 0, 20, 20, 20, 0])
  Sand.setMovesetFilters(SCMovesetFilters::SandSetter, 
                        SCMovesetFilters::SandEnjoyer,
                        SCMovesetFilters::SandSetter)
  
  MagneticTerrain = SCTeamFilter.new("Magnetic Terrain", [0, 0, 20, 20, 20, 0])
  MagneticTerrain.setMovesetFilters(SCMovesetFilters::MagneticTerrainSetter, 
                                SCMovesetFilters::MagneticTerrainElectric,
                                SCMovesetFilters::MagneticTerrainSteel, 
                                SCMovesetFilters::MagneticTerrainSetter)

  Test1 = SCTeamFilter.new("Test1", [10], [20, 21, 22, 31, 32])
  Test1.setMovesetFilters(SCMovesetFilters::Test1_1, SCMovesetFilters::Test1_2, 
                          SCMovesetFilters::Test1_3, SCMovesetFilters::Test1_4, 
                          SCMovesetFilters::Test1_5, SCMovesetFilters::Test1_6)
  rescue 
  end 
  
  
  
  def self.getList(tierid)
    ret = []
    
    ret = [SCTeamFilters::Random, SCTeamFilters::HyperOffense, 
            SCTeamFilters::Offense, SCTeamFilters::Balanced, 
            SCTeamFilters::Defensive, SCTeamFilters::Stall]
    
    if ["FE", "FEL", "UBER"].include?(tierid)
      # Allowed for very big tiers.
      ret.push(SCTeamFilters::Carboniferous)
      ret.push(SCTeamFilters::TrickRoom)
      ret.push(SCTeamFilters::Rain)
      ret.push(SCTeamFilters::Sun)
      ret.push(SCTeamFilters::Sand)
      # ret.push(SCTeamFilters::Test1)
      ret.push(SCTeamFilters::Hail)
    end
    
    if ret.length == 0
    end 
    
    return ret 
  end 
  
end 