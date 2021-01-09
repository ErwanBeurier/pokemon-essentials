



module SCClientBattles
  # This module defines the tools, and hard-coded lists of constants that will be used by SCClientBattlesHandler and SCStadium
  Player = -100
  AnyPartner = -200
  Cameraman = 230
  CameramanStr = "230_1"
  
  
  def self.loadGraphics(event, trainerid)
    filename = ""
    if trainerid == SCClientBattles::Cameraman
      # Cameraman
      filename="trchar" + SCClientBattles::CameramanStr
    else 
      filename=sprintf("trchar%03d",trainerid)
    end 
    bitmap=AnimatedBitmap.new("Graphics/Characters/"+filename)
    bitmap.dispose
    event.character_name=filename
	end 
  
  
  
  def self.loadGraphicsPk(event, pokemonid)
    species = pbGetSpeciesFromFSpecies(pokemonid)
    filename = ""
    filename=sprintf("%03d",species[0])
    # if species[1] == 0 
    # else
      # filename=sprintf("%03d_%d",species[0],species[1]) # These do not necessarily exist, even if the form exists, because Mega-evolutions are not supposed to be seen overworld.
    # end 
    bitmap=AnimatedBitmap.new("Graphics/Characters/" + filename)
    bitmap.dispose
    event.character_name=filename
	end 

  
  
  def self.clients
    ret = [
      # FRLG trainers
      PBTrainers::AROMALADY,
      PBTrainers::BEAUTY,
      PBTrainers::BIKER,
      PBTrainers::BIRDKEEPER,
      PBTrainers::BUGCATCHER,
      PBTrainers::BURGLAR,
      PBTrainers::CHANELLER,
      PBTrainers::CUEBALL,
      PBTrainers::ENGINEER,
      PBTrainers::FISHERMAN,
      PBTrainers::GAMBLER,
      PBTrainers::GENTLEMAN,
      PBTrainers::HIKER,
      PBTrainers::JUGGLER,
      PBTrainers::LADY,
      PBTrainers::PAINTER,
      PBTrainers::POKEMANIAC,
      PBTrainers::POKEMONBREEDER,
      PBTrainers::ROCKER,
      PBTrainers::RUINMANIAC,
      PBTrainers::SAILOR,
      PBTrainers::SCIENTIST,
      PBTrainers::SUPERNERD,
      PBTrainers::TAMER,
      PBTrainers::BLACKBELT,
      PBTrainers::CRUSHGIRL,
      PBTrainers::CAMPER,
      PBTrainers::PICNICKER,
      PBTrainers::COOLTRAINER_M,
      PBTrainers::COOLTRAINER_F,
      PBTrainers::YOUNGSTER,
      PBTrainers::LASS,
      PBTrainers::POKEMONRANGER_M,
      PBTrainers::POKEMONRANGER_F,
      PBTrainers::PSYCHIC_M,
      PBTrainers::PSYCHIC_F,
      PBTrainers::SWIMMER_M,
      PBTrainers::SWIMMER_F,
      PBTrainers::SWIMMER2_M,
      PBTrainers::SWIMMER2_F,
      PBTrainers::TUBER_M,
      PBTrainers::TUBER_F,
      PBTrainers::TUBER2_M,
      PBTrainers::TUBER2_F,
      PBTrainers::TEAMROCKET_M,
      PBTrainers::TEAMROCKET_F,
      # Trainers from BW
      PBTrainers::BW_BATTLEGIRL,
      PBTrainers::BW_BIKER,
      PBTrainers::BW_BLACKBELT,
      PBTrainers::BW_FISHERMAN,
      PBTrainers::BW_HIKER,
      PBTrainers::BW_OFFICELADY,
      PBTrainers::BW_PSYCHIC_F,
      PBTrainers::BW_PSYCHIC_M,
      PBTrainers::BW_ROUGHNECK,
      PBTrainers::BW_SCIENTIST,
      PBTrainers::BW_SWIMMER_M,
      PBTrainers::BW_SWIMMER_F,
      # Trainers from DPP
      PBTrainers::DPP_BIRDKEEPER,
      PBTrainers::DPP_CAMPER,
      PBTrainers::DPP_LADY,
      PBTrainers::DPP_PAINTER,
      PBTrainers::DPP_PICNICKER,
      PBTrainers::DPP_ROCKER,
      PBTrainers::DPP_RUINMANIAC,
      PBTrainers::DPP_SAILOR,
      PBTrainers::DPP_SUPERNERD,
      PBTrainers::DPP_TUBER_M,
      PBTrainers::DPP_TUBER_F,
      PBTrainers::DPP_TUBER2_M,
      PBTrainers::DPP_TUBER2_F,
      PBTrainers::DPP_BREEDER,
      # Trainers from HGSS
      PBTrainers::HGSS_ACETRAINER_F,
      PBTrainers::HGSS_ACETRAINER_M,
      PBTrainers::HGSS_BEAUTY,
      PBTrainers::HGSS_BIRDKEEPER,
      PBTrainers::HGSS_BUGCATCHER,
      PBTrainers::HGSS_BURGLAR,
      PBTrainers::HGSS_GENTLEMAN,
      PBTrainers::HGSS_MEDIUM,
      PBTrainers::HGSS_SUPERNERD,
      PBTrainers::HGSS_SWIMMER_F,
      # Unnamed trainers from Sun/Moon
      PBTrainers::SM_YOUNGSTER,
      PBTrainers::SM_LASS,
      PBTrainers::SM_RISINGSTAR_M,
      PBTrainers::SM_RISINGSTAR_F,
      PBTrainers::SM_PRESCHOOLER_M,
      PBTrainers::SM_PRESCHOOLER_F,
      PBTrainers::SM_YOUNGSTER2,
      PBTrainers::SM_LASS2,
      PBTrainers::SM_OFFICEMAN,
      PBTrainers::SM_OFFICEWOMAN,
      PBTrainers::SM_BREEDER_M,
      PBTrainers::SM_BREEDER_F,
      PBTrainers::SM_BEAUTY,
      PBTrainers::SM_HIKER,
      PBTrainers::SM_TOURIST,
      PBTrainers::SM_AETHEREMPLOYEE_M,
      PBTrainers::SM_AETHEREMPLOYEE_F,
      PBTrainers::SM_AETHEREMPLOYEE_M,
      PBTrainers::SM_AETHEREMPLOYEE_F,
      # Ruby/Sapphire/Emerald
      PBTrainers::RSE_TEAMAQUA_GRUNT_M,
      PBTrainers::RSE_TEAMAQUA_GRUNT_F,
      PBTrainers::RSE_TEAMMAGMA_GRUNT_M,
      PBTrainers::RSE_TEAMMAGMA_GRUNT_F,
      PBTrainers::RSE_AROMALADY,
      PBTrainers::RSE_BATTLEGIRL,
      PBTrainers::RSE_BEAUTY,
      PBTrainers::RSE_BIRDKEEPER,
      PBTrainers::RSE_BLACKBELT,
      PBTrainers::RSE_BUGCATCHER,
      PBTrainers::RSE_BUGMANIAC,
      PBTrainers::RSE_CAMPER,
      PBTrainers::RSE_COLLECTOR,
      PBTrainers::RSE_COOLTRAINER_F,
      PBTrainers::RSE_COOLTRAINER_M,
      PBTrainers::RSE_DRAGONTAMER,
      PBTrainers::RSE_EXPERT_M,
      PBTrainers::RSE_EXPERT_F,
      PBTrainers::RSE_FISHERMAN,
      PBTrainers::RSE_HEXMANIAC,
      PBTrainers::RSE_HIKER,
      PBTrainers::RSE_KINDLER,
      PBTrainers::RSE_LADY,
      PBTrainers::RSE_LASS,
      PBTrainers::RSE_NINJABOY,
      PBTrainers::RSE_PARASOLLADY,
      PBTrainers::RSE_PICNICKER,
      PBTrainers::RSE_POKEFAN_F,
      PBTrainers::RSE_POKEFAN_M,
      PBTrainers::RSE_BREEDER_F,
      PBTrainers::RSE_BREEDER_M,
      PBTrainers::RSE_RANGER_F,
      PBTrainers::RSE_RANGER_M,
      PBTrainers::RSE_PSYCHIC_F,
      PBTrainers::RSE_PSYCHIC_M,
      PBTrainers::RSE_RICHBOY,
      PBTrainers::RSE_RUINMANIAC,
      PBTrainers::RSE_SAILOR,
      PBTrainers::RSE_SCHOOLKID,
      PBTrainers::RSE_SWIMMER_F,
      PBTrainers::RSE_SWIMMER_M,
      PBTrainers::RSE_TRIATHLETE1_F,
      PBTrainers::RSE_TRIATHLETE1_M,
      PBTrainers::RSE_TRIATHLETE2_F,
      PBTrainers::RSE_TRIATHLETE2_M,
      PBTrainers::RSE_TRIATHLETE3_F,
      PBTrainers::RSE_TRIATHLETE3_M,
      PBTrainers::RSE_TUBER_F,
      PBTrainers::RSE_TUBER_M,
      PBTrainers::RSE_YOUNGSTER
    ]
    
    return ret 
  end 
  
  
  
  def self.cleverGuys
    # those with skill == 100
    ret = [
      PBTrainers::LEADER_Brock,
      PBTrainers::LEADER_Misty,
      PBTrainers::LEADER_Surge,
      PBTrainers::LEADER_Erika,
      PBTrainers::LEADER_Koga,
      PBTrainers::LEADER_Sabrina,
      PBTrainers::LEADER_Blaine,
      PBTrainers::LEADER_Giovanni,
      PBTrainers::ELITEFOUR_Lorelei,
      PBTrainers::ELITEFOUR_Bruno,
      PBTrainers::ELITEFOUR_Agatha,
      PBTrainers::ELITEFOUR_Lance,
      PBTrainers::CHAMPION,
      PBTrainers::SM_TRAINER_MASKEDROYAL,
      PBTrainers::SM_TRAINER_PLUMERIA,
      PBTrainers::SM_TRAINER_GUZMA,
      PBTrainers::SM_TRAINER_SYNA,
      PBTrainers::SM_TRAINER_DEXIO,
      PBTrainers::SM_TRAINER_COLRESS,
      PBTrainers::SM_TRAINER_GRIMSLEY,
      PBTrainers::SM_TRAINER_CYNTHIA,
      PBTrainers::SM_TRAINER_ANABEL,
      PBTrainers::SM_TRAINER_WALLY,
      PBTrainers::SM_TRAINER_BLUE,
      PBTrainers::SM_TRAINER_RED,
      PBTrainers::RSE_LEADER_ROXANE,
      PBTrainers::RSE_LEADER_BRAWLY,
      PBTrainers::RSE_LEADER_WATTSON,
      PBTrainers::RSE_LEADER_FLANNERY,
      PBTrainers::RSE_LEADER_NORMAN,
      PBTrainers::RSE_LEADER_WINONA,
      PBTrainers::RSE_LEADER_TATELIZA,
      PBTrainers::RSE_LEADER_JUAN,
      PBTrainers::RSE_ELITEFOUR_SIDNEY,
      PBTrainers::RSE_ELITEFOUR_PHOEBE,
      PBTrainers::RSE_ELITEFOUR_GLACIA,
      PBTrainers::RSE_ELITEFOUR_DRAKE,
      PBTrainers::RSE_ELITEFOUR_WALLACE,
      PBTrainers::RSE_FRONTIERBRAIN_GRETA,
      PBTrainers::RSE_FRONTIERBRAIN_TUCKER,
      PBTrainers::RSE_FRONTIERBRAIN_NOLAND,
      PBTrainers::RSE_FRONTIERBRAIN_LUCY,
      PBTrainers::RSE_FRONTIERBRAIN_SPENSER,
      PBTrainers::RSE_FRONTIERBRAIN_BRANDON,
      PBTrainers::RSE_FRONTIERBRAIN_ANABEL,
      PBTrainers::RSE_TEAMAQUA_LEADER,
      PBTrainers::RSE_TEAMAQUA_ADMIN_F,
      PBTrainers::RSE_TEAMAQUA_ADMIN_M,
      PBTrainers::RSE_TEAMMAGMA_LEADER,
      PBTrainers::RSE_TEAMMAGMA_ADMIN_F,
      PBTrainers::RSE_TEAMMAGMA_ADMIN_M
    ]
    
    return ret 
  end 
  
  
  def self.employeePairs
    ret = []
    
    ret.push([PBTrainers::SC_EMPLOYEE_WESTON, "Weston"])
    ret.push([PBTrainers::SC_EMPLOYEE_YVES, "Yves"])
    ret.push([PBTrainers::SC_EMPLOYEE_CONNOR, "Connor"])
    ret.push([PBTrainers::SC_EMPLOYEE_SEREN, "Seren"])
    ret.push([PBTrainers::SC_EMPLOYEE_FOXY, "Foxy"])
    ret.push([PBTrainers::SC_EMPLOYEE_KATE, "Kate"])
    ret.push([PBTrainers::SC_EMPLOYEE_EVITA, "Evita"])
    
    return ret 
  end 
  
  
  
  def self.employees
    ret = []
    
    ret.push(PBTrainers::SC_EMPLOYEE_WESTON)
    ret.push(PBTrainers::SC_EMPLOYEE_YVES)
    ret.push(PBTrainers::SC_EMPLOYEE_CONNOR)
    ret.push(PBTrainers::SC_EMPLOYEE_SEREN)
    ret.push(PBTrainers::SC_EMPLOYEE_FOXY)
    ret.push(PBTrainers::SC_EMPLOYEE_KATE)
    ret.push(PBTrainers::SC_EMPLOYEE_EVITA)
    
    return ret 
  end 
  
  
  
  def self.getEmployeeName(employee)
    self.employeePairs.each { |pair|
      return pair[1] if pair[0] == employee
    }
    return "Employee"
  end 
  
  
  
  def self.getEmployeeConst(employee)
    self.employeePairs.each { |pair|
      return pair[0] if pair[1] == employee
    }
    return PBTrainers::COOLTRAINER_M
  end 
  
  
  
  def self.hypedTier
    return nil if !$game_variables[SCVar::HypedTier].is_a?(String)
    return $game_variables[SCVar::HypedTier]
  end 
  
  
  
  def self.setHypedTier(tier)
    $game_variables[SCVar::HypedTier] = tier
  end 
  
  
  
  def self.reinitHypedTier
    self.setHypedTier(nil)
  end 
  
  
  
  def self.biasedTiers
    tiers = scLoadTierData
    tier_list = []
    
    # All tiers appear once. 
    for t in tiers["TierList"]
      if tiers[t]["Category"] != "Random" and t != "OTF"
        tier_list.push(t)
      end 
      
      if t == 0 or t == "0"
        File.open("log.txt", "w") { |f| 
          for stuff in tier_list[t]
            f.write stuff + "\n"
          end 
        }
        pbMessage("Some debug is written in log.txt")
      end 
    end 
    
    
    # FE is more prestigious tier, so most people want this tier. 
    # However, their may be a hype for another tier throughout the game. 
    # The hyped tier is in a game_variable[205]
    l = tier_list.length
    
    while tier_list.length < 2 * l 
      # tier_list.push("Random") # Tier of the day. 
      tier_list.push("FE") # Most prestigious tier 
      
      if SCClientBattles.hypedTier
        tier_list.push(SCClientBattles.hypedTier)
      else 
        tier_list.push("FE")
      end 
    end 
    
    return tier_list
  end 
  
  def self.biasedFormats
    ret = Array.new(40, "1v1")
    ret += Array.new(3, "2v2")
    ret += Array.new(2, "3v3")
    ret += Array.new(1, "4v4")
    ret += Array.new(1, "5v5")
    ret += Array.new(3, "6v6")
    return ret 
  end 
end 







class SCStadium 
  # This class defines the properties of a Stadium. Also stores the clients/employees. 
  attr_reader(:map_id)
  attr_reader(:name)
  attr_reader(:center_y)
  attr_reader(:x_employee)
  attr_reader(:x_client)
  attr_reader(:reserved)
  attr_reader(:ind)
  attr_reader(:for_player)
  attr_reader(:format)
  attr_reader(:tier)
  
  
  def initialize(map_id, ind, name, center_y, x_employee, x_client, audience_pos)
    # Fixed stats 
    @map_id = map_id
    @ind = ind # Index in the list of stadiums. 
    @name = name 
    @center_y = center_y
    @x_employee = x_employee
    @x_client = x_client
    # List of pairs [x, y] setting the available positions for audience
    @audience_pos = audience_pos.clone
    
    reinit
  end 
  
  
  
  def reinit
    @reserved = false
    @employee_side = []
    @client_side = []
    @employee_pokemons = []
    @client_pokemons = []
    @tier = nil 
    @format = "1v1"
    @for_player = false
    @is_double_single = false # Doble battle but with single trainers. (1 per side, but 2 Pokémons per side)
  end 
  
  
  
  def playerPartner
    return nil if !@for_player
    return nil if @employee_side.length == 1
    
    return @employee_side[1]
  end 
  
  
  
  def addEmployee(employee)
    # employee can be either:
    # - A PBTrainers constant defining an unamed client 
    # - A PBTrainers constant defining a real employee of the Castle
    # - The constant SCClientBattles::Player representing the player. 
    
    raise _INTL("Error: trying to add more than two employees!") if @employee_side.length >= 2
    
    x = @x_employee
    y = @center_y
    y = @center_y + 1 if @employee_side.length == 1
    
    @for_player = true if employee == SCClientBattles::Player
    
    @employee_side.push([employee, x, y])
    @reserved = true 
  end 
  
  
  
  def makeDouble
    @is_double_single = true
  end 
  
  
  
  def addClient(client)
    # client will be a PBTrainers constant defining an unamed client 
    
    raise _INTL("Error: trying to add more than two clients!") if @client_side.length >= 2
    
    x = @x_client
    y = @center_y
    y = @center_y + 1 if @client_side.length == 1
    
    @client_side.push([client, x, y])
    @reserved = true 
  end 
  
  
  
  def client(i)
    return @client_side[i][0]
  end
  
  
  def setTier(tier)
    @tier = tier 
    
		tier_instance = loadTier(tier)
		
		# Fake teams just to display some Pokemons. 
    @client_pokemons = tier_instance.fastRandSpecies(2)
    @employee_pokemons = tier_instance.fastRandSpecies(2)
  end 
  
  def setFormat(format)
    @format = format 
    @format = "1v1" if !format 
  end 
  

  def showCharacters(client1, client2, employee1, employee2)
    return if !@reserved
    
    checks = Array.new(5, false)
    
    if @employee_side[0][0] == SCClientBattles::Player
      pbMapInterpreter.pbSetSelfSwitch(client1.id,"A",true) if @client_side[0]
      pbMapInterpreter.pbSetSelfSwitch(client2.id,"A",true) if @client_side[1]
      # pbMessage("Your client is here.")
      pbUpdateSceneMap # Otherwise the client doesn't appear. 
    end 
    
    if @employee_side[0] && @employee_side[0][0] != SCClientBattles::Player
      SCClientBattles.loadGraphics(employee1, @employee_side[0][0])
      employee1.moveto(@employee_side[0][1], @employee_side[0][2])
      employee1.turn_right
    end 
    if @employee_side[1] && @employee_side[0][0] != SCClientBattles::Player
      SCClientBattles.loadGraphics(employee2, @employee_side[1][0])
      employee2.moveto(@employee_side[1][1], @employee_side[1][2])
      employee2.turn_right
    end 
    if @client_side[0]
      SCClientBattles.loadGraphics(client1, @client_side[0][0])
      client1.moveto(@client_side[0][1], @client_side[0][2])
      client1.turn_left
    end 
    if @client_side[1]
      SCClientBattles.loadGraphics(client2, @client_side[1][0])
      client2.moveto(@client_side[1][1], @client_side[1][2])
      client2.turn_left
    end 
  end 
  
  
  
  def showAudience(*events)
    return if !@reserved
    
    # e = 0 
    # events.each { |event| 
      
    # }
  end 
  
  
  
  def showPokemons(employee_pk1, employee_pk2, client_pk1, client_pk2)
    return if !@reserved
    return if @for_player
    
    if @employee_side[0]
      SCClientBattles.loadGraphicsPk(employee_pk1, @employee_pokemons[0])
      employee_pk1.moveto(@employee_side[0][1] + 1, @employee_side[0][2])
      employee_pk1.turn_right
    end 
    if @employee_side[1] || @is_double_single
      SCClientBattles.loadGraphicsPk(employee_pk2, @employee_pokemons[1])
      employee_pk2.moveto(@employee_side[0][1] + 1, @employee_side[0][2] + 1)
      employee_pk2.turn_right
    end 
    if @client_side[0]
      SCClientBattles.loadGraphicsPk(client_pk1, @client_pokemons[0])
      client_pk1.moveto(@client_side[0][1] - 1, @client_side[0][2])
      client_pk1.turn_left
    end 
    if @client_side[1] || @is_double_single
      SCClientBattles.loadGraphicsPk(client_pk2, @client_pokemons[1])
      client_pk2.moveto(@client_side[0][1] - 1, @client_side[0][2] + 1)
      client_pk2.turn_left
    end 
  end 
end 





class SCClientBattlesGenerator
  
  
  
  def initialize
    @map_names = ["Castle", "Cliff", "Forest A", "Forest B", "Beach", "Gardens"] # Not Stadium 
    @stadiums = {}
    
    @client_classes = SCClientBattles.clients
    @employee_classes = SCClientBattles.employees
    @available_employees = []
    @current_clients = {}
    @reserved_stadiums = {}
    
    @player_map = nil 
    @player_stadium = nil 
    
    @map_names.each { |mp|
      @current_clients[mp] = []
      @stadiums[mp] = []
      @reserved_stadiums[mp] = []
    }
    
    # Stadiums
    audience = []
    @stadiums["Castle"].push(SCStadium.new("Castle", 0, "West stadium", 3, 1, 4, audience))
    audience = []
    @stadiums["Castle"].push(SCStadium.new("Castle", 1, "Center stadium", 3, 7, 10, audience))
    
    # Gardens
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 0, "Near stadium", 14, 13, 16, audience))
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 1, "South stadium", 28, 14, 17, audience))
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 2, "East stadium", 11, 32, 35, audience))
    
    
    # Cliff 
    #               5
    #         3
    #    2       4 
    # 
    #          1
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 0, "Stadium 1", 26, 18, 21, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 1, "Stadium 2", 18, 11, 14, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 2, "Stadium 3", 13, 16, 19, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 3, "Stadium 4", 18, 23, 26, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 4, "Stadium 5", 9, 34, 37, audience))
    
    
    # Forest A 
    #  2
    #      1
    #             4
    #    3 
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 0, "Stadium 1", 16, 24, 27, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 1, "Stadium 2", 10, 13, 17, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 2, "Stadium 3", 29, 21, 24, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 3, "Stadium 4", 24, 36, 39, audience))
    
    
    # Forest B 
    #   2   3
    #   1   4 
    #         5
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 0, "Stadium 1", 20, 15, 18, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 1, "Stadium 2", 14, 15, 18, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 2, "Stadium 3", 14, 26, 29, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 3, "Stadium 4", 20, 26, 29, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 4, "Remote stadium", 30, 38, 41, audience))
    
    # Beach 
    #  2
    #     1        3
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 0, "Stadium 1", 20, 16, 19, audience))
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 1, "Stadium 2", 15, 11, 14, audience))
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 2, "Stadium 3", 19, 32, 35, audience))
    
    
    # Stadium 
    #  2
    #     1        3
    @stadiums["Stadium"] = []
    audience = []
    @stadiums["Stadium"].push(SCStadium.new("", 0, "Great Stadium", 19, 15, 18, audience))
  end 
  
  
  
  def reinit
    for mp in @stadiums.keys
      @stadiums[mp].each { |st| st.reinit }
      @reserved_stadiums[mp] = []
    end 
    
    @player_map = nil 
    @player_stadium = nil 
    $game_switches[SCSwitch::RandBattleDone] = false 
  end 
  
  
  
  def getReservedStadium(mapname, reserved_i)
    return nil if !@reserved_stadiums[mapname][reserved_i]
    
    id_stadium = @reserved_stadiums[mapname][reserved_i]
    return @stadiums[mapname][id_stadium]
  end 
  
  
  
  def playerNextStadium
    return @stadiums[@player_map][@player_stadium]
  end 
  
  
  
  def clientWantsPartner
    return playerNextStadium.playerPartner != nil 
  end 
  
  
  
  def playerHasPartner
    return $PokemonGlobal.partner.is_a?(Array)
  end 
  
  
  
  def playerHasRightPartner
    return true if !clientWantsPartner
    return false if !playerHasPartner
    return true if playerNextStadium.playerPartner == SCClientBattles::AnyPartner
    
    return $PokemonGlobal.partner[0] == playerNextStadium.playerPartner
  end 
  
  
  
  def playerValidTeam
    return isValidForTier($Trainer.party, false, playerNextStadium.tier)
  end 
  
  
  
  def playerNextBattleMessage(propose_tier_change = false)
    msg = "Your next client awaits you "
    
    # Map location
    msg += _INTL("at the {1}.", @player_map) if ["Beach", "Cliff"].include?(@player_map)
    msg += _INTL("in the {1}.", @player_map) if ["Castle", "Gardens"].include?(@player_map)
    msg += _INTL("in {1}.", @player_map) if ["Forest A", "Forest B"].include?(@player_map)
    
    # Partner?
    msg2 = "They want to fight you alone."
    partner = playerNextStadium.playerPartner
    
    if partner == SCClientBattles::AnyPartner
			msg2 = _INTL("They want to fight you with whichever partner you choose.")
    elsif partner 
			msg2 = _INTL("They want you to join forces with your employee {1}.", SCClientBattles.getEmployeeName(partner))
    end 
    
    # Tier and format 
    msg3 = _INTL("The requested tier is {1}.", playerNextStadium.tier)
    msg3 = _INTL("The requested tier is {1} with format {2}.", playerNextStadium.tier, playerNextStadium.format) if !partner
    
    pbMessage(msg)
    pbMessage(msg2)
    pbMessage(msg3)
    
    if propose_tier_change and playerNextStadium.tier != scGetTier()
      cmd = pbMessage(_INTL("Set current tier to {1}?", playerNextStadium.tier), ["Yes", "No"])
      if cmd == 0
        scSetTier(playerNextStadium.tier, false)
        pbMessage(_INTL("Current tier is set to {1}.", playerNextStadium.tier))
      else 
        pbMessage(_INTL("Current tier was not altered."))
      end 
    end 
  end 
  
  
  
  def startBattle
    # Generates a battle from the stored event. 
    res = 0
    pbHealAll
    scSetTier(playerNextStadium.tier, false)
    if clientWantsPartner
      res = scDoubleTrainerBattle(playerNextStadium.client(0), "Client", playerNextStadium.client(1), "Client")
    else 
      res = scTrainerBattle(playerNextStadium.client(0), "Client", playerNextStadium.format)
    end 
    pbHealAll
    
    # Rand battle is done
    $game_switches[SCSwitch::RandBattleDone] = true 
    
    return res 
  end 
  
  
  
  def battleIsDone
    return $game_switches[SCSwitch::RandBattleDone]
  end 
  
  
  
  def generateBattles(mute = false)
    reinit
    
    tier_list = SCClientBattles.biasedTiers
    # @client_classes = SCClientBattles.clients
    # @employee_classes = SCClientBattles.employees
    
    # DEBUG
    # map_names_shuffled = ["Cliff"]
    map_names_shuffled = scsample(@map_names, -1) # Shuffle 
    @available_employees = scsample(@employee_classes + [SCClientBattles::AnyPartner], -1) # Shuffle 
    @available_employees.push(SCClientBattles::Player)
    
    # Loop over maps. 
    map_names_shuffled.each do |mp|
      num_events = rand(2) + 1
      # num_events = 2 
      stadium_indices = scsamplei(@stadiums[mp], num_events)
      
      # In the map, loop over randomly chosen stadiums. 
      stadium_indices.each do |si| 
        @reserved_stadiums[mp].push(si)
        # Double Battle but with single trainer.
        is_double = rand(100) < 30 
        is_double_with_partner = is_double && rand(100) < 50 
        
        # Choose the tier in the biased list. 
        tier = scsample(tier_list, 1)
        @stadiums[mp][si].setTier(tier)
        
        # Number of clients per side. 
        num_per_side = (is_double_with_partner ? 2 : 1)
        
        # Give clients: 
        chosen_clients = scsample(@client_classes, num_per_side)
        chosen_clients = [chosen_clients] if chosen_clients.is_a?(Integer)
        chosen_clients.each { |cli| @stadiums[mp][si].addClient(cli) }
        
        # Opponents of clients: player, employees, or other clients. 
        chosen_opponents = [] 
        
        # player_map will be String (not nil) when the player is affected a battle.
        if !@player_map || (rand(100) < 25 && @available_employees.length >= num_per_side)
          for num in 0...num_per_side
            chosen_opponents.push(@available_employees.pop())
          end 
          
          # If these are undefined, then we need to set them. The player will always be the first employee chosen. 
          if !@player_map
            @available_employees.delete(SCClientBattles::AnyPartner)
            @player_map = mp 
            @player_stadium = si
            # Formats 
            @stadiums[mp][si].setFormat(scsample(SCClientBattles.biasedFormats, 1)) if num_per_side == 1 && !is_double
            @stadiums[mp][si].setFormat("2v2") if num_per_side == 1 && is_double
          end 
        else 
          chosen_opponents = scsample(@client_classes, num_per_side)
        end 
        
        chosen_opponents = [chosen_opponents] if chosen_opponents.is_a?(Integer)
        chosen_opponents.each { |opp| @stadiums[mp][si].addEmployee(opp) }
        
        @stadiums[mp][si].makeDouble if is_double && !is_double_with_partner
      end 
    end 
    
    # Warn the player. 
    playerNextBattleMessage(true) if !mute
  end 
end 








def scTestClientBattles
  scClientBattles.generateBattles(false)
end 