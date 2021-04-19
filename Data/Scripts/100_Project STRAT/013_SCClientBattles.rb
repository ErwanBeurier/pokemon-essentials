################################################################################
# SCClientBattles
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script allows for the random generation of clients of the player + random 
# fights occuring on the map.
#-------------------------------------------------------------------------------
# Module SCClientBattles defines tools + hard-coded stuff for the other classes 
# to use.
#-------------------------------------------------------------------------------
# Class SCStadium represents a stadium; teleports the events, gives them 
# sprites, and so on.
#-------------------------------------------------------------------------------
# Class SCClientBattlesGenerator contains tools for the generation of clients: 
# clients for the player + random clients battling in the castle.
################################################################################


#-------------------------------------------------------------------------------
# This module defines the tools, and hard-coded lists of constants that will be 
# used by SCClientBattlesHandler and SCStadium
#-------------------------------------------------------------------------------

module SCClientBattles
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
    event.pages[0].graphic.character_name=filename
	end 
  
  
  
  def self.loadGraphicsPk(event, pokemonid)
    species = pbGetSpeciesFromFSpecies(pokemonid)
    filename = ""
    filename=sprintf("%03d",species[0])
    event.pages[0].graphic.character_name="Following/" + filename
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
      next if ["BIL", "MONOL", "FEL", "UBER"].include?(t) && !scLegendaryAllowed?
      
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
    
    
    # FE is the most prestigious tier, so most people want this tier. 
    # However, their may be a hype for another tier throughout the game. 
    # The hyped tier is in a game_variable[205]
    l = tier_list.length
    
    while tier_list.length < 2 * l 
      # tier_list.push("Random") # Tier of the day. 
      tier_list.push("FE") # Most prestigious tier 
      tier_list.push("FEL") if scLegendaryAllowed? # Most prestigious tier 
      
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




#-------------------------------------------------------------------------------
# This class defines the properties of a Stadium. Also stores the clients / 
# employees, and contains methods to display them on the map, together with 
# their Pokémons. 
#-------------------------------------------------------------------------------

class SCStadium 
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
  
  
  def initialize(map_id, ind, name, center_y, x_employee, x_client, client_facing, audience_pos)
    # Fixed stats 
    @map_id = map_id
    @ind = ind # Index in the list of stadiums. 
    @name = name 
    @center_y = center_y
    @x_employee = x_employee
    @x_client = x_client
    # List of pairs [x, y] setting the available positions for audience
    @audience_pos = audience_pos.clone
    @event_list = []
    @client_facing = client_facing
    case @client_facing
    when PBMoveRoute::TurnLeft  ; @employee_facing = PBMoveRoute::TurnRight
    when PBMoveRoute::TurnRight ; @employee_facing = PBMoveRoute::TurnLeft
    when PBMoveRoute::TurnDown  ; @employee_facing = PBMoveRoute::TurnUp
    when PBMoveRoute::TurnUp    ; @employee_facing = PBMoveRoute::TurnDown
    end
    
    reinit
  end 
  
  
  
  def reinit
    deleteScene
    # @event_list = [] # List of event IDs generated by this Stadium.
    
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
    
    @employee_side.push([employee, x, y, @employee_facing])
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
    
    @client_side.push([client, x, y, @client_facing])
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
  
  
  
  def spawnClientBusy(x, y, facing, trainer_id) # Not for Player
    event = RPG::Event.new(x,y)
    event.name = "Client (Busy)"
    
    key_id = ($game_map.events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    event.pages[0].move_type = 0
    event.pages[0].trigger = 0 # Action Button
    
    facing2 = facing
    case facing
    when PBMoveRoute::TurnLeft  ; facing2 = 4
    when PBMoveRoute::TurnDown  ; facing2 = 2
    when PBMoveRoute::TurnRight ; facing2 = 6
    when PBMoveRoute::TurnUp    ; facing2 = 8
    end 
    
    event.pages[0].graphic.direction = facing2
    
    pbPushText(event.pages[0].list,_INTL("(This client is busy)"))
    pbPushMoveRoute(event.pages[0].list, 0, [facing])
    pbPushEnd(event.pages[0].list)
    
    SCClientBattles.loadGraphics(event, trainer_id)
    
    # creating and adding the Game_Event
    gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
    key_id = ($game_map.events.keys.max || -1) + 1
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    $game_map.events[key_id] = gameEvent
    @event_list.push(key_id)
    
    # updating the sprites
    sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
    $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
    $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
  end 
  
  
  
  def spawnClientWaiting(x, y, facing, trainer_id)
    event = RPG::Event.new(x,y)
    event.name = "Client (Waiting)"
    
    key_id = ($game_map.events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    event.pages[0].move_type = 0
    event.pages[0].trigger = 0 # Action Button
    
    dia = scClientBattles.dialogue # Dialogue modifiers.
    
    # tp_x = where to teleport the player rather than making it turn around the trainer. 
    # Should be "in front" of the trainer. 
    tp_x = x    
    tp_y = y
    
    facing2 = facing
    case facing
    when PBMoveRoute::TurnLeft  ; facing2 = 4 ; tp_x -= 1
    when PBMoveRoute::TurnDown  ; facing2 = 2 ; tp_y += 1
    when PBMoveRoute::TurnRight ; facing2 = 6 ; tp_x += 1
    when PBMoveRoute::TurnUp    ; facing2 = 8 ; tp_y -= 1
    end 
    
    event.pages[0].graphic.direction = facing2
    
    # Check if Battle is over: 
    indent = 0
    pbPushBranch(event.pages[0].list,"$game_switches[SCSwitch::RandBattleDone]", indent)
    # pbPushText(event.pages[0].list,_INTL("Thank you for your time \\PN!"), indent+1)
    dia.pushBattleOver(event.pages[0].list, indent+1)
    pbPushText(event.pages[0].list,_INTL("Thank you for your time \\PN!"), indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # Greeting 
    # pbPushText(event.pages[0].list,_INTL("Hi \\PN!\\nReady to fight?"), indent)
    dia.pushGreeting(event.pages[0].list, indent)
    pbPushShowChoices(event.pages[0].list, [["Yes", "No"], 1], indent)
    pbPushWhenBranch(event.pages[0].list, 0, indent+1)
    pbPushWhenBranch(event.pages[0].list, 1, indent+1)
    # pbPushText(event.pages[0].list, _INTL("No problem. I want a good fight!"), indent+1)
    dia.pushPlayerNotReady(event.pages[0].list, indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # Check partner.
    pbPushBranch(event.pages[0].list,"scClientBattles.clientWantsPartner", indent)
    indent += 1
    
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerHasPartner", indent)
    dia.pushPartnerMissing(event.pages[0].list, indent+1)
    # pbPushText(event.pages[0].list,_INTL("But... I wanted you to team up with one of your friends..."), indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerHasRightPartner", indent)
    pbPushScript(event.pages[0].list,"scClientBattles.storeWantedPartner", indent+1)
    dia.pushWrongPartner(event.pages[0].list, indent+1)
    # pbPushText(event.pages[0].list,
      # _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner), indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    indent -= 1
    pbPushBranchEnd(event.pages[0].list, indent + 1) # End of Check partner. 
    
    # Check if team is valid.
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerValidTeam", indent)
    pbPushText(event.pages[0].list,_INTL("But... Your team is not valid..."), indent+1)
    dia.pushInvalidTeam(event.pages[0].list, indent+1)
    # pbPushText(event.pages[0].list,_INTL("But... Your team is not valid..."), indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1) 
    
    # Move the player to the right place. 
    # Part 1: teleport the player in front of the trainer. 
    pbPushBranch(event.pages[0].list,_INTL("$game_player.x != {1} || $game_player.y != {2}", tp_x, tp_y), indent)
    pbPushEventLocation(event.pages[0].list, -1, 0, tp_x, tp_y, facing, indent+1)
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # Part 2: Player walks away // trainer faces the right direction. 
    pbPushMoveRoute(event.pages[0].list, 0, [facing], indent)
    
    route_player = []
    case facing # Move away in the direction that the trainer faces, and then face backwards. 
    when PBMoveRoute::TurnLeft
      route_player = [PBMoveRoute::Left, PBMoveRoute::Left, PBMoveRoute::TurnRight]
    when PBMoveRoute::TurnDown
      route_player = [PBMoveRoute::Down, PBMoveRoute::Down, PBMoveRoute::TurnUp]
    when PBMoveRoute::TurnRight
      route_player = [PBMoveRoute::Right, PBMoveRoute::Right, PBMoveRoute::TurnLeft]
    when PBMoveRoute::TurnUp
      route_player = [PBMoveRoute::Up, PBMoveRoute::Up, PBMoveRoute::TurnDown]
    end 
    pbPushMoveRoute(event.pages[0].list, -1, route_player, indent)
    pbPushWaitForMoveCompletion(event.pages[0].list, indent)
    
    # Start the battle
    pbPushLabel(event.pages[0].list, "Start the battle", indent)
    
    pbPushBranch(event.pages[0].list,"scClientBattles.startBattle", indent)
    # Case 1: victory
    # Store the result and move the trainer to the player. 
    indent += 1
    
    pbPushScript(event.pages[0].list,
      _INTL("$game_variables[{1}] = true", SCSwitch::ClientBattleResult), indent)
    pbPushMoveRoute(event.pages[0].list, 0, route_player[0..1], indent)
    pbPushWaitForMoveCompletion(event.pages[0].list, indent)
    # pbPushText(event.pages[0].list,_INTL("Well done!"), indent)
    dia.pushPlayerWon(event.pages[0].list, indent)
    
    pbPushElse(event.pages[0].list, indent)
    # Case 2: Defeat
    # Store the result and propose to try again.
    pbPushScript(event.pages[0].list,
      _INTL("$game_variables[{1}] = false", SCSwitch::ClientBattleResult), indent)
    
    pbPushChangeColorTone(event.pages[0].list,-255,-255,-255,20,indent)
    
    dia.pushTryAgain(event.pages[0].list, indent)
    # pbPushText(event.pages[0].list,_INTL("Try again?"), indent)
    pbPushShowChoices(event.pages[0].list, [["Try again", "Change team", "Accept defeat"], 2], indent)
    # Defeat: try again 
    pbPushWhenBranch(event.pages[0].list, 0, indent+1) 
    pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
    pbPushJumpToLabel(event.pages[0].list, "Start the battle", indent+1)
    
    # Defeat: change team, and try again
    pbPushWhenBranch(event.pages[0].list, 1, indent+1) 
    pbPushScript(event.pages[0].list, _INTL("scAdaptCurrentTeam"), indent+1)
    pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
    pbPushJumpToLabel(event.pages[0].list, "Start the battle", indent+1)
    
    # Defeat: accept defeat
    pbPushWhenBranch(event.pages[0].list, 2, indent+1)
    pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
    pbPushMoveRoute(event.pages[0].list, 0, route_player[0..1], indent+1)
    pbPushWaitForMoveCompletion(event.pages[0].list, indent+1)
    # pbPushText(event.pages[0].list,_INTL("That's unbelievable, I won!"), indent+1)
    dia.pushClientWon(event.pages[0].list, indent+1)
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    indent -= 1
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # End of script, log the result. 
    pbPushScript(event.pages[0].list, _INTL("scLogClientBattleResult()"), indent+1)
    pbPushEnd(event.pages[0].list)
    
    SCClientBattles.loadGraphics(event, trainer_id)
    
    # creating and adding the Game_Event
    gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
    key_id = ($game_map.events.keys.max || -1) + 1
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    $game_map.events[key_id] = gameEvent
    @event_list.push(key_id)
    
    # updating the sprites
    sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
    $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
    $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
  end 
  
  
  
  def spawnPokemon(x, y, facing, species) # Not for Player
    event = RPG::Event.new(x,y)
    event.name = "Client Pokémon"
    
    key_id = ($game_map.events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    event.pages[0].trigger = 0 # Action Button
    event.pages[0].step_anime = true
    
    case facing
    when PBMoveRoute::TurnLeft ; facing = 4
    when PBMoveRoute::TurnDown ; facing = 2
    when PBMoveRoute::TurnRight ; facing = 6
    when PBMoveRoute::TurnUp ; facing = 8
    end 
    
    event.pages[0].graphic.direction = facing
    event.pages[0].direction_fix = true
    
    SCClientBattles.loadGraphicsPk(event, species)
    
    # Event content
    pbPushText(event.pages[0].list,_INTL("(You should not interfere in a Pokémon battle)"))
    pbPushEnd(event.pages[0].list)
    
    # creating and adding the Game_Event
    gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
    key_id = ($game_map.events.keys.max || -1) + 1
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    $game_map.events[key_id] = gameEvent
    @event_list.push(key_id)
    
    # updating the sprites
    sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
    $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
    $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
  end 
  
  
  
  def displayScene
    return if !@reserved
    
    # Show the clients.
    @for_player = @employee_side[0] && @employee_side[0][0] == SCClientBattles::Player
    
    if @for_player
      # Only spawn clients that battle the player.
      for i in 0..1
        next if !@client_side[i]
        spawnClientWaiting(@client_side[i][1], @client_side[i][2], 
                          @client_side[i][3], @client_side[i][0])
      end 
      return 
    end 
    
    # Spawn the clients (or employees + clients)
    for i in 0..1
      next if !@employee_side[i]
      spawnClientBusy(@employee_side[i][1], @employee_side[i][2], 
                      @employee_side[i][3], @employee_side[i][0])
    end 
    for i in 0..1
      next if !@client_side[i]
      spawnClientBusy(@client_side[i][1], @client_side[i][2], 
                      @client_side[i][3], @client_side[i][0])
    end 
    
    # Spawn the Pokémons
    displayPokemon(@client_side[0], false, @client_pokemons[0])
    displayPokemon(@client_side[0], @client_side[1] || @is_double_single, @client_pokemons[1])
    displayPokemon(@employee_side[0], false, @employee_pokemons[0])
    displayPokemon(@employee_side[0], @employee_side[1] || @is_double_single, @employee_pokemons[1])
  end 
  
  
  
  def displayPokemon(client_side, is_double_single, species)
    return if !client_side || !species
    
    x = client_side[1]
    y = client_side[2]
    facing = client_side[3]
    
    case facing
    when PBMoveRoute::TurnDown
      y += 1
      x += 1 if is_double_single
    when PBMoveRoute::TurnLeft
      y += 1 if is_double_single
      x -= 1 
    when PBMoveRoute::TurnRight
      y += 1 if is_double_single
      x += 1
    when PBMoveRoute::TurnUp
      y -= 1
      x += 1 if is_double_single
    end 
    
    # return x, y, facing 
    spawnPokemon(x, y, facing, species)
  end 
  
  
  
  def deleteScene
    for id in @event_list
      $game_map.removeThisEventfromMap(id)
    end 
    @event_list = []
  end 
  
end 




#-------------------------------------------------------------------------------
# A few methods to make Events. 
# Used in the Stadium "spawn" methods.
#-------------------------------------------------------------------------------

def pbPushEventLocation(list,event_id, type_method, x, y, direction, indent = 0)
  # type_method:
  #   0 if direct appointment (x and y are the coordinates)
  #   1 if the real coordinates are stored in $game_variables[x] and $game_variables[y]
  #   2 if y is nil and x is another event. 
  # direction: Should be a PBMoveRoute::TurnDown, TurnUp, TurnLeft, TurnRight, or directly the right numbers.
  case direction
  when PBMoveRoute::TurnDown ; direction = 2
  when PBMoveRoute::TurnUp ; direction = 8
  when PBMoveRoute::TurnRight ; direction = 6
  when PBMoveRoute::TurnLeft ; direction = 4
  end 
  list.push(RPG::EventCommand.new(202,indent,[event_id, type_method, x, y, direction]))
end


def pbPushShowChoices(list,choices, indent = 0)
  # Choices = list of choices (should be less than 4)
  list.push(RPG::EventCommand.new(102,indent,choices))
end


def pbPushWhenBranch(list, param, indent = 0)
  # A branch to handle the choices.
  list.push(RPG::EventCommand.new(0,indent,[]))
  list.push(RPG::EventCommand.new(402,indent-1,[param]))
end 


def pbPushWaitForMoveCompletion(list, indent=0)
  pbPushEvent(list,210,[],indent)
end 


def pbPushLabel(list, label, indent = 0)
  pbPushEvent(list,118,[label],indent)
end 


def pbPushJumpToLabel(list, label, indent = 0)
  pbPushEvent(list,119,[label],indent)
end 


def pbPushChangeColorTone(list, r, g, b, num_frames, indent = 0)
  pbPushEvent(list,223,[Tone.new(r,g,b),num_frames], indent)
end 




#-------------------------------------------------------------------------------
# The class that contains the staidums + the final methods to display the 
# clients and such + the generation of clients. 
#-------------------------------------------------------------------------------


class SCClientBattlesGenerator
  attr_reader :dialogue
  
  def initialize
    @map_names = ["Castle", "Cliff", "Forest A", "Forest B", "Beach", "Gardens"] # Not Stadium 
    @stadiums = {}
    @dialogue = nil 
    
    @client_classes = SCClientBattles.clients
    @employee_classes = SCClientBattles.employees
    @available_employees = []
    @current_clients = {}
    @reserved_stadiums = {}
    
    @player_map = nil 
    @player_stadium = nil 
    @special_rules = [] # For the next battle.
    
    @map_names.each { |mp|
      @current_clients[mp] = []
      @stadiums[mp] = []
      @reserved_stadiums[mp] = []
    }
    
    # Stadiums
    audience = []
    @stadiums["Castle"].push(SCStadium.new("Castle", 0, "West stadium", 
                                3, 1, 4, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Castle"].push(SCStadium.new("Castle", 1, "Center stadium", 
                                3, 7, 10, PBMoveRoute::TurnLeft, audience))
    
    # Gardens
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 0, "Near stadium", 
                              14, 13, 16, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 1, "South stadium", 
                              28, 14, 17, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 2, "East stadium", 
                              11, 32, 35, PBMoveRoute::TurnLeft, audience))
    
    
    # Cliff 
    #               5
    #         3
    #    2       4 
    # 
    #          1
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 0, "Stadium 1", 
                              26, 18, 21, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 1, "Stadium 2", 
                              18, 11, 14, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 2, "Stadium 3", 
                              13, 16, 19, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 3, "Stadium 4", 
                              18, 23, 26, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 4, "Stadium 5", 
                              9, 34, 37, PBMoveRoute::TurnLeft, audience))
    
    
    # Forest A 
    #  2
    #      1
    #             4
    #    3 
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 0, "Stadium 1", 
                              16, 24, 27, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 1, "Stadium 2", 
                              10, 13, 17, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 2, "Stadium 3", 
                              29, 21, 24, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 3, "Stadium 4", 
                              24, 36, 39, PBMoveRoute::TurnLeft, audience))
    
    
    # Forest B 
    #   2   3
    #   1   4 
    #         5
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 0, "Stadium 1", 
                              20, 15, 18, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 1, "Stadium 2", 
                              14, 15, 18, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 2, "Stadium 3", 
                              14, 26, 29, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 3, "Stadium 4", 
                              20, 26, 29, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 4, "Remote stadium", 
                              30, 38, 41, PBMoveRoute::TurnLeft, audience))
    
    # Beach 
    #  2
    #     1        3
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 0, "Stadium 1", 
                              20, 16, 19, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 1, "Stadium 2", 
                              15, 11, 14, PBMoveRoute::TurnLeft, audience))
    audience = []
    @stadiums["Beach"].push(SCStadium.new("Beach", 2, "Stadium 3", 
                              19, 32, 35, PBMoveRoute::TurnLeft, audience))
    
    
    # Stadium 
    #  2
    #     1        3
    @stadiums["Stadium"] = []
    audience = []
    @stadiums["Stadium"].push(SCStadium.new("", 0, "Great Stadium", 
                              19, 15, 18, PBMoveRoute::TurnLeft, audience))
  end 
  
  
  
  def reinit
    for mp in @stadiums.keys
      @stadiums[mp].each { |st| st.reinit }
      @reserved_stadiums[mp] = []
    end 
    
    @dialogue = SCClientBattleDialogues.get_random_usual
    
    @player_map = nil 
    @player_stadium = nil 
    $game_switches[SCSwitch::RandBattleDone] = false 
  end 
  
  
  
  def getReservedStadium(mapname, reserved_i)
    return nil if !@reserved_stadiums[mapname][reserved_i]
    
    id_stadium = @reserved_stadiums[mapname][reserved_i]
    return @stadiums[mapname][id_stadium]
  end 
  
  
  
  def displayStadiums(mapname)
    @reserved_stadiums[mapname].each_with_index { |id_stadium, i|
      next if !@stadiums[mapname][id_stadium].reserved
      
      @stadiums[mapname][id_stadium].displayScene
    }
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
  
  
  
  def storeWantedPartner
    employee = self.playerNextStadium.playerPartner
    partner_name = SCClientBattles.getEmployeeName(employee)
    pbSet(SCVar::WantedPartner, partner_name)
  end 
  
  
  
  def setClientDialogue(dialogue)
    # dialogue = constant from SCClientBattleDialogues
    @dialogue = dialogue
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
    
    msg4 = ""
    first_rule = true
    @special_rules.each { |s| 
      msg4 = "Special rule: "
      if s.length == 1
        msg4 += ", " if !first_rule
        case s[0].downcase
        when "inversebattle"
          msg4 += "Inverse Battles"
        when "inversestab"
          msg4 += "Inverse STABs"
        when "changingterrain"
          msg4 += "Changing Terrain"
        when "changingweather"
          msg4 += "Changing Weather"
        when "battleroyale"
          msg4 += "Battle Royale"
        end 
      # elsif s.length == 2
        first_rule = false
        
      end 
    }
    msg4 += "." if msg4 != ""
    
    pbMessage(msg)
    pbMessage(msg2)
    pbMessage(msg3)
    pbMessage(msg4) if msg4 != ""
    
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
    @special_rules.each { |s|
      setBattleRule(s[0]) if s.length == 1
      setBattleRule(s[0], s[1]) if s.length == 2
    }
    scSetTier(playerNextStadium.tier, false)
    if clientWantsPartner
      res = scDoubleTrainerBattle(playerNextStadium.client(0), "Client", playerNextStadium.client(1), "Client")
    else 
      res = scTrainerBattle(playerNextStadium.client(0), "Client", playerNextStadium.format)
    end 
    pbHealAll
    
    # Rand battle is done
    $game_switches[SCSwitch::RandBattleDone] = true 
    @special_rules = []
    
    return res 
  end 
  
  
  
  def battleIsDone
    return $game_switches[SCSwitch::RandBattleDone]
  end 
  
  
  
  def setSpecialRules(spec_rule_name, spec_rule_value = nil)
    # Rules among: inverse, battleRoyale, changingTerrain and changingWeather
    # Other things to add in Battle Rule.
    s = [spec_rule_name]
    s.push(spec_rule_value) if spec_rule_value
    @special_rules.push(s)
    
    if spec_rule_name.length == 3 && spec_rule_name[1] == "v"
      playerNextStadium.setFormat(spec_rule_name)
    end 
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