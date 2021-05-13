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
    if event.is_a?(Game_Event)
      event.character_name="Following/" + filename
    else 
      event.pages[0].graphic.character_name="Following/" + filename
    end 
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
    ret.push([PBTrainers::SC_EMPLOYEE_HETTIE, "Hettie"])
    
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
    ret.push(PBTrainers::SC_EMPLOYEE_HETTIE)
    
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
  
  
  
  
  def self.smallTiers
    tiers = scLoadTierData
    tier_list = []
    
    # All 
    for t in tiers["TierList"]
      next if scTiersWithLegendaries.include?(t) && !scLegendaryAllowed?
      
      if tiers[t]["Category"] == "Micro-tier" && tiers[t]["Category"] != "Base stats tiers"
        tier_list.push(t)
      end 
      
      if t == 0 or t == "0"
        File.open("log.txt", "w") { |f| 
          for stuff in tiers[t]
            f.write stuff + "\n"
          end 
        }
        pbMessage("Some debug is written in log.txt")
      end 
    end 
    
    return tier_list
  end 
  
  
  
  def self.biasedTiers
    tiers = scLoadTierData
    tier_list = []
    
    # All tiers appear once. 
    for t in tiers["TierList"]
      next if scTiersWithLegendaries.include?(t) && !scLegendaryAllowed?
      
      if tiers[t]["Category"] != "Random" and t != "OTF"
        tier_list.push(t)
      end 
      
      if t == 0 or t == "0"
        File.open("log.txt", "w") { |f| 
          for stuff in tiers[t]
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
  
  
  
  def self.biasedFormatAll
    ret = Array.new(40, "1v1")
    ret += Array.new(3, "2v2")
    ret += Array.new(2, "3v3")
    
    if SCSwitch.get(SCSwitch::AllowBigFormats)
      ret += Array.new(1, "4v4")
      ret += Array.new(1, "5v5")
      ret += Array.new(3, "6v6")
    end 
    
    return scsample(ret, 1)
  end 
  
  
  
  def self.biasedFormat2
    ret = Array.new(10, "2v2")
    ret += Array.new(2, "3v3")
    
    if SCSwitch.get(SCSwitch::AllowBigFormats)
      ret += Array.new(1, "4v4")
      ret += Array.new(1, "5v5")
      ret += Array.new(3, "6v6")
    end 
    
    return scsample(ret, 1)
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
  attr_accessor(:disallowAllMechanics)
  attr_accessor(:battleRoyale)
  
  
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
    @disallowAllMechanics = false
    @battleRoyale = false
    
    @audience_events = {}
  end 
  
  
  
  def playerPartner
    return nil if !@for_player
    return nil if @employee_side.length == 1
    return nil if @battleRoyale
    
    return @employee_side[1]
  end 
  
  
  
  def addEmployee(employee)
    # employee can be either:
    # - A PBTrainers constant defining an unamed client 
    # - A PBTrainers constant defining a real employee of the Castle
    # - The constant SCClientBattles::Player representing the player. 
    
    raise _INTL("Error: trying to add more than two employees!") if @employee_side.length >= 3
    
    x = @x_employee
    y = @center_y
    y = @center_y + 1 if @employee_side.length == 1
    y = @center_y - 1 if @employee_side.length == 2
    
    @for_player = true if employee == SCClientBattles::Player
    
    @employee_side.push([employee, x, y, @employee_facing])
    @reserved = true 
  end 
  
  
  
  def clientOpp(i)
    return @employee_side[i][0]
  end 
  
  
  
  def makeDouble
    @is_double_single = true
  end 
  
  
  
  def addClient(client)
    # client will be a PBTrainers constant defining an unamed client 
    
    raise _INTL("Error: trying to add more than two clients!") if @client_side.length >= 3
    
    x = @x_client
    y = @center_y
    y = @center_y + 1 if @client_side.length == 1
    y = @center_y - 1 if @client_side.length == 2
    
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
  
  
  
  def spawnAudience(x, y, facing)
    if @audience_events[x] && @audience_events[x][y]
      # creating and adding the Game_Event
      gameEvent = Game_Event.new($game_map.map_id, @audience_events[x][y], $game_map)
      key_id = ($game_map.events.keys.max || -1) + 1
      gameEvent.id = key_id
      gameEvent.moveto(x,y)
      $game_map.events[key_id] = gameEvent
      @event_list.push(key_id)
      
      # updating the sprites
      sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
      $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
      $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
      return 
    end 
    
    
    trainer_id = SCClientBattles.clients
    trainer_id = trainer_id[rand(trainer_id.length)]
    
    
    audience_text = "Niiiiice!"
    
    # For battles without player.
    audience_texts_not_player = ["This is a nice combat!", 
                                "What a misplay!", 
                                "Nice anticipation!", 
                                "How could you always miss those High Jump Kicks?",
                                "I've bet on the left player.",
                                "I've bet on the right player.",
                                _INTL("This is the tier {1}.", @tier),
                                "Wooho!"]
    
    # For battles with the player - Before the battle
    audience_texts_before = ["I would love to have the level to battle you!", 
                            "I expect nothing but perfection from you."]
                        
    # For battles with the player - After the battle - Victory
    audience_texts_victory = ["You're not the best for no reason.", 
                              "You're brilliant!",
                              "What a nice battle!"]
                        
    # For battles with the player - After the battle - Defeat
    audience_texts_loss = ["I guess the tier wasn't at your advantage...", 
                          "What a disappointment..."]
                        
    # For battles with the player - After the battle - Both
    audience_texts_both = ["Nice fight!",
                          "Twas a nice battle!"]
    audience_texts_loss += audience_texts_both
    audience_texts_victory += audience_texts_both
    
    
    # Now create the event. 
    event = RPG::Event.new(x,y)
    event.name = "Audience"
    
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
    
    # Insert the commands. 
    if @for_player
      indent = 0
      pbPushBranch(event.pages[0].list,"$game_switches[SCSwitch::RandBattleDone]", indent)
      # Battle is over. 
      
      pbPushBranch(event.pages[0].list,"$game_switches[SCSwitch::ClientBattleResult]", indent+1)
      pbPushText(event.pages[0].list,scsample(audience_texts_victory, 1), indent+2) # It was a victory.
      pbPushElse(event.pages[0].list,indent+2)
      pbPushText(event.pages[0].list,scsample(audience_texts_loss, 1), indent+2) # It was a loss. 
      pbPushBranchEnd(event.pages[0].list, indent+2)
      
      pbPushElse(event.pages[0].list,indent+1)
      
      # Before battle. 
      pbPushText(event.pages[0].list,scsample(audience_texts_before, 1), indent+1)
      
      pbPushBranchEnd(event.pages[0].list, indent+1)
      pbPushMoveRoute(event.pages[0].list, 0, [facing])
      
      pbPushEnd(event.pages[0].list, indent)
      
    else 
      # Just show some text. 
      pbPushText(event.pages[0].list, scsample(audience_texts_not_player, 1))
      pbPushMoveRoute(event.pages[0].list, 0, [facing])
      pbPushEnd(event.pages[0].list)
    end 
    
    SCClientBattles.loadGraphics(event, trainer_id)
    
    # creating and adding the Game_Event
    gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
    key_id = ($game_map.events.keys.max || -1) + 1
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    $game_map.events[key_id] = gameEvent
    @event_list.push(key_id)
    @audience_events[x] = {} if !@audience_events[x]
    @audience_events[x][y] = event
    
    # updating the sprites
    sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
    $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
    $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
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
  
  
  
  def spawnClientWaiting(x, y, facing, trainer_id, employee_side = false)
    
    dia = scClientBattles.dialogue # Dialogue modifiers.
    dia.prepare_formatting(trainer_id)
    
    event = RPG::Event.new(x,y)
    event.name = "Client (Waiting)"
    
    key_id = ($game_map.events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    event.pages[0].move_type = 0
    event.pages[0].trigger = 0 # Action Button
    
    
    # tp_x = where to teleport the player rather than making it turn around the trainer. 
    # Should be "in front" of the trainer. 
    tp_x = x    
    tp_y = y
    
    facing2 = facing
    case facing
    when PBMoveRoute::TurnLeft  ; facing2 = 4 ; tp_x += (employee_side ? 1 : -1)
    when PBMoveRoute::TurnDown  ; facing2 = 2 ; tp_y += (employee_side ? -1 : 1)
    when PBMoveRoute::TurnRight ; facing2 = 6 ; tp_x += (employee_side ? -1 : 1)
    when PBMoveRoute::TurnUp    ; facing2 = 8 ; tp_y += (employee_side ? 1 : -1)
    end 
    
    event.pages[0].graphic.direction = facing2
    
    # Check if Battle is over: 
    indent = 0
    pbPushBranch(event.pages[0].list,"$game_switches[SCSwitch::RandBattleDone]", indent)
    dia.pushBattleOver(event.pages[0].list, indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # Greeting 
    dia.pushGreeting(event.pages[0].list, indent)
    pbPushShowChoices(event.pages[0].list, [["Yes", "No"], 1], indent)
    pbPushWhenBranch(event.pages[0].list, 0, indent+1)
    pbPushWhenBranch(event.pages[0].list, 1, indent+1)
    dia.pushPlayerNotReady(event.pages[0].list, indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    # Check partner.
    pbPushBranch(event.pages[0].list,"scClientBattles.clientWantsPartner", indent)
    indent += 1
    
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerHasPartner", indent)
    dia.pushPartnerMissing(event.pages[0].list, indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerHasRightPartner", indent)
    pbPushScript(event.pages[0].list,"scClientBattles.storeWantedPartner", indent+1)
    dia.pushWrongPartner(event.pages[0].list, indent+1)
    pbPushExit(event.pages[0].list, indent+1) # Exit event processing.
    pbPushBranchEnd(event.pages[0].list, indent+1)
    
    indent -= 1
    pbPushBranchEnd(event.pages[0].list, indent + 1) # End of Check partner. 
    
    # Check if team is valid.
    pbPushBranch(event.pages[0].list,"!scClientBattles.playerValidTeam", indent)
    dia.pushInvalidTeam(event.pages[0].list, indent+1)
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
    dia.pushPlayerWon(event.pages[0].list, indent)
    
    pbPushElse(event.pages[0].list, indent)
    # Case 2: Defeat
    # Store the result and propose to try again.
    pbPushScript(event.pages[0].list,
      _INTL("$game_variables[{1}] = false", SCSwitch::ClientBattleResult), indent)
    
    pbPushChangeColorTone(event.pages[0].list,-255,-255,-255,20,indent)
    pbPushWait(event.pages[0].list,20, indent)
  
    dia.pushTryAgain(event.pages[0].list, indent)
    
    if dia.client_won
      # With accept defeat. 
      pbPushShowChoices(event.pages[0].list, [["Try again", "Change team", "Accept defeat"], 0], indent)
    else
      # Without accept defeat.
      pbPushShowChoices(event.pages[0].list, [["Try again", "Change team"], 0], indent)
    end 
    
    # Defeat: try again 
    pbPushWhenBranch(event.pages[0].list, 0, indent+1) 
    pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
    pbPushWait(event.pages[0].list,20, indent+1)
    pbPushJumpToLabel(event.pages[0].list, "Start the battle", indent+1)
    
    # Defeat: change team, and try again
    pbPushWhenBranch(event.pages[0].list, 1, indent+1) 
    pbPushScript(event.pages[0].list, _INTL("scAdaptCurrentTeam"), indent+1)
    pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
    pbPushWait(event.pages[0].list,20, indent+1)
    pbPushJumpToLabel(event.pages[0].list, "Start the battle", indent+1)
    
    # Defeat: accept defeat, if allowed. 
    if dia.client_won
      pbPushWhenBranch(event.pages[0].list, 2, indent+1)
      pbPushChangeColorTone(event.pages[0].list, 0, 0, 0, 20, indent+1)
      pbPushWait(event.pages[0].list,20, indent+1)
      pbPushMoveRoute(event.pages[0].list, 0, route_player[0..1], indent+1)
      pbPushWaitForMoveCompletion(event.pages[0].list, indent+1)
      dia.pushClientWon(event.pages[0].list, indent+1)
    end 
    
    # End choices.
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
      for i in 0..2
        next if !@client_side[i]
        spawnClientWaiting(@client_side[i][1], @client_side[i][2], 
                          @client_side[i][3], @client_side[i][0])
      end 
      for i in 0..2
        next if !@employee_side[i]
        next if @employee_side[i][0] == SCClientBattles::Player
        spawnClientWaiting(@employee_side[i][1], @employee_side[i][2], 
                          @employee_side[i][3], @employee_side[i][0], true)
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
    displayPokemon(@client_side[0], true, @client_pokemons[1]) if @client_side[1] || @is_double_single
    displayPokemon(@employee_side[0], false, @employee_pokemons[0])
    displayPokemon(@employee_side[0], true, @employee_pokemons[1]) if @employee_side[1] || @is_double_single
    
    
    # Spawn the audience. 
    if @audience_events.keys.length == 0
      # Make a new audience 
      half_audience = (@audience_pos.length / 2).floor
      real_audience = scsample(@audience_pos, half_audience)
      
      for data in real_audience
        spawnAudience(data[0], data[1], data[2])
      end 
    else 
      # Audience already loaded. 
      @audience_events.each do |x, other|
        other.each do |y, event|
          spawnAudience(x, y, nil)
        end 
      end 
    end 
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
    
    @panel = nil
    
    initStadiums
  end 
  
  
  
  def initStadiums
    # -----------------------
    # Stadiums
    # -----------------------
    audience = []
    for i in 0...2
      audience.push([1, 3+i, PBMoveRoute::TurnRight])
      audience.push([6, 3+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([2+i, 5, PBMoveRoute::TurnUp]) if i != 2
    end 
    @stadiums["Castle"].push(SCStadium.new("Castle", 0, "West stadium", 
                                3, 2, 5, PBMoveRoute::TurnLeft, audience))
    audience = []
    for i in 0...2
      audience.push([8, 3+i, PBMoveRoute::TurnRight])
      audience.push([13, 3+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([9+i, 5, PBMoveRoute::TurnUp]) if i != 2
    end 
    @stadiums["Castle"].push(SCStadium.new("Castle", 1, "Center stadium", 
                                3, 9, 12, PBMoveRoute::TurnLeft, audience))
    
    # -----------------------
    # Gardens
    # -----------------------
    #                   East 
    # Near 
    #
    #
    # South 
    # 
    audience = []
    for i in 0...3
      audience.push([12, 13+i, PBMoveRoute::TurnRight])
      audience.push([17, 13+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([13+i, 16, PBMoveRoute::TurnUp])
    end 
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 0, "Near stadium", 
                              14, 13, 16, PBMoveRoute::TurnLeft, audience))
    audience = []
    for i in 0...6
      next if i == 2 || i == 3
      audience.push([13 + i, 23, PBMoveRoute::TurnDown])
      audience.push([13 + i, 25, PBMoveRoute::TurnDown])
    end 
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 1, "South stadium", 
                              28, 14, 17, PBMoveRoute::TurnLeft, audience))
    
    @stadiums["Gardens"].push(SCStadium.new("Gardens", 2, "East stadium", 
                              11, 32, 35, PBMoveRoute::TurnLeft, 
                              SCClientBattlesGenerator.audienceXY(31, 10)))
    
    
    # -----------------------
    # Cliff 
    # -----------------------
    #               5
    #         3
    #    2       4 
    # 
    #          1
    audience = []
    for i in 0...3
      audience.push([22, 25+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([18+i, 24, PBMoveRoute::TurnDown])
      audience.push([18+i, 28, PBMoveRoute::TurnUp])
    end
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 0, "Stadium 1", 
                              26, 18, 21, PBMoveRoute::TurnLeft, audience))
    audience = []
    for i in 0...3
      audience.push([10, 17+i, PBMoveRoute::TurnRight])
      audience.push([15, 17+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([11+i, 20, PBMoveRoute::TurnUp])
    end
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 1, "Stadium 2", 
                              18, 11, 14, PBMoveRoute::TurnLeft, audience))
    # audience = []
    # for i in 0...3
      # audience.push([15, 12+i, PBMoveRoute::TurnRight])
      # audience.push([20, 12+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([16+i, 11, PBMoveRoute::TurnDown])
      # audience.push([16+i, 15, PBMoveRoute::TurnUp])
    # end
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 2, "Stadium 3", 
                              13, 16, 19, PBMoveRoute::TurnLeft, 
                              SCClientBattlesGenerator.audienceXY(15, 12)))
    # audience = []
    # for i in 0...3
      # audience.push([22, 17+i, PBMoveRoute::TurnRight])
      # audience.push([27, 17+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([23+i, 16, PBMoveRoute::TurnDown])
      # audience.push([23+i, 20, PBMoveRoute::TurnUp])
    # end
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 3, "Stadium 4", 
                              18, 23, 26, PBMoveRoute::TurnLeft, 
                              SCClientBattlesGenerator.audienceXY(22, 17)))
    audience = []
    for i in 0...3
      audience.push([38, 8+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...2
      audience.push([33, 9+i, PBMoveRoute::TurnRight])
    end 
    for i in 0...4
      audience.push([34+i, 7, PBMoveRoute::TurnDown])
      audience.push([34+i, 11, PBMoveRoute::TurnUp])
    end
    @stadiums["Cliff"].push(SCStadium.new("Cliff", 4, "Stadium 5", 
                              9, 34, 37, PBMoveRoute::TurnLeft, audience))
    
    
    # -----------------------
    # Forest A 
    # -----------------------
    #  2
    #      1
    #             4
    #    3 
    audience = []
    for i in 0...3
      audience.push([28, 15+i, PBMoveRoute::TurnRight])
      next if i == 1
      audience.push([23, 15+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([24+i, 14, PBMoveRoute::TurnDown])
      audience.push([24+i, 18, PBMoveRoute::TurnUp])
    end
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 0, "Stadium 1", 
                              16, 24, 27, PBMoveRoute::TurnLeft, audience))
    audience = []
    for i in 0...3
      audience.push([17, 9+i, PBMoveRoute::TurnRight])
      next if i == 1
      audience.push([12, 9+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([13+i, 8, PBMoveRoute::TurnDown])
      audience.push([13+i, 12, PBMoveRoute::TurnUp])
    end
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 1, "Stadium 2", 
                              10, 13, 17, PBMoveRoute::TurnLeft, audience))
    # audience = []
    # for i in 0...3
      # audience.push([20, 28+i, PBMoveRoute::TurnRight])
      # audience.push([25, 28+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([21+i, 27, PBMoveRoute::TurnDown])
      # audience.push([21+i, 31, PBMoveRoute::TurnUp])
    # end
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 2, "Stadium 3", 
                              29, 21, 24, PBMoveRoute::TurnLeft, 
                              SCClientBattlesGenerator.audienceXY(20, 28)))
    # audience = []
    # for i in 0...3
      # audience.push([35, 23+i, PBMoveRoute::TurnRight])
      # audience.push([40, 23+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([36+i, 22, PBMoveRoute::TurnDown])
      # audience.push([36+i, 26, PBMoveRoute::TurnUp])
    # end
    @stadiums["Forest A"].push(SCStadium.new("Forest A", 3, "Stadium 4", 
                              24, 36, 39, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(35, 23)))
    
    
    # -----------------------
    # Forest B 
    # -----------------------
    #   2   3
    #   1   4 
    #         5
    # audience = []
    # for x in [14, 25]
      # for y in [13, 19]
        # audience.push([])
        # for i in 0...3
          # audience[-1].push([x, y+i, PBMoveRoute::TurnRight])
          # audience[-1].push([x+5, y+i, PBMoveRoute::TurnLeft])
        # end 
        # for i in 0...4
          # audience[-1].push([x+1+i, y-1, PBMoveRoute::TurnDown])
          # audience[-1].push([x+1+i, y+3, PBMoveRoute::TurnUp])
        # end
      # end 
    # end 
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 0, "Stadium 1", 
                              20, 15, 18, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(14, 19)))
    # audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 1, "Stadium 2", 
                              14, 15, 18, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(14, 13)))
    # audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 2, "Stadium 3", 
                              14, 26, 29, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(25, 13)))
    # audience = []
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 3, "Stadium 4", 
                              20, 26, 29, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(25, 19)))
    audience = []
    for i in 0...3
      audience.push([37, 29+i, PBMoveRoute::TurnRight])
      next if i == 0
      audience.push([42, 29+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([38+i, 28, PBMoveRoute::TurnDown])
      audience.push([38+i, 32, PBMoveRoute::TurnUp])
    end
    @stadiums["Forest B"].push(SCStadium.new("Forest B", 4, "Remote stadium", 
                              30, 38, 41, PBMoveRoute::TurnLeft, audience))
    
    # -----------------------
    # Beach 
    # -----------------------
    #  2
    #     1        3
    audience = []
    for i in 0...3
      audience.push([20, 19+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([16+i, 18, PBMoveRoute::TurnDown]) if i != 0
      audience.push([16+i, 22, PBMoveRoute::TurnUp])
    end
    @stadiums["Beach"].push(SCStadium.new("Beach", 0, "Stadium 1", 
                              20, 16, 19, PBMoveRoute::TurnLeft, audience))
    # audience = []
    # for i in 0...3
      # audience.push([10, 14+i, PBMoveRoute::TurnRight])
      # audience.push([15, 14+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([11+i, 13, PBMoveRoute::TurnDown])
      # audience.push([11+i, 17, PBMoveRoute::TurnUp])
    # end
    @stadiums["Beach"].push(SCStadium.new("Beach", 1, "Stadium 2", 
                              15, 11, 14, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(10, 14)))
    # audience = []
    # for i in 0...3
      # audience.push([31, 18+i, PBMoveRoute::TurnRight])
      # audience.push([36, 18+i, PBMoveRoute::TurnLeft])
    # end 
    # for i in 0...4
      # audience.push([32+i, 17, PBMoveRoute::TurnDown])
      # audience.push([32+i, 21, PBMoveRoute::TurnUp])
    # end
    @stadiums["Beach"].push(SCStadium.new("Beach", 2, "Stadium 3", 
                              19, 32, 35, PBMoveRoute::TurnLeft,
                              SCClientBattlesGenerator.audienceXY(31, 18)))
    
    
    # -----------------------
    # Stadium 
    # -----------------------
    @stadiums["Stadium"] = []
    audience = []
    for x in 13..21
      next if x == 17
      for y in [9, 11, 13, 15]
        audience.push([x, y, PBMoveRoute::TurnDown])
      end 
    end 
    @stadiums["Stadium"].push(SCStadium.new("", 0, "Great Stadium", 
                              19, 15, 18, PBMoveRoute::TurnLeft, audience))
  end 
  
  
  
  def self.audienceXY(top_x, top_y)
    audience = []
    
    for i in 0...3
      audience.push([top_x, top_y+i, PBMoveRoute::TurnRight])
      audience.push([top_x+5, top_y+i, PBMoveRoute::TurnLeft])
    end 
    for i in 0...4
      audience.push([top_x+1+i, top_y-1, PBMoveRoute::TurnDown])
      audience.push([top_x+1+i, top_y+3, PBMoveRoute::TurnUp])
    end
    
    return audience
  end 
  
  
  
  def reinit
    for mp in @stadiums.keys
      @stadiums[mp].each { |st| st.reinit }
      @reserved_stadiums[mp] = []
    end 
    
    @dialogue = SCClientBattleDialogues.get_random_usual
    @panel = Panel.new
    
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
      
    elsif playerNextStadium.battleRoyale && playerNextStadium.format == "2v2"
      res = scBattleRoyale(playerNextStadium.client(0), "Client", 
              playerNextStadium.client(1), "Client", 
              playerNextStadium.clientOpp(1), "Client")
    elsif playerNextStadium.battleRoyale && playerNextStadium.format == "3v3"
      res = scBattleRoyale(playerNextStadium.client(0), "Client", 
              playerNextStadium.client(1), "Client", 
              playerNextStadium.client(2), "Client", 
              playerNextStadium.clientOpp(1), "Client", 
              playerNextStadium.clientOpp(2), "Client")
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
  
  
  
  # def generateBattles(player_tier, player_format, player_with_partner, player_special_rules, mute = false)
  def generateBattles(player_client, mute = false)
    # reinit
    
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
        is_double = (!@player_map && player_client.format == "2v2") || (@player_map && rand(10) < 3)
        is_double_with_partner = is_double && ((!@player_map && player_client.withPartner) || (@player_map && rand(10) < 3))
        
        # Choose the tier in the biased list. 
        if !@player_map
          @stadiums[mp][si].setTier(player_client.tier)
        else 
          tier = scsample(tier_list, 1)
          @stadiums[mp][si].setTier(tier)
        end 
        
        # Number of clients per side. 
        num_per_side = (is_double_with_partner ? 2 : 1)
        
        if !@player_map && player_client.battleRoyale 
          num_per_side = 2 if player_client.format == "2v2" 
          num_per_side = 3 if player_client.format == "3v3" 
        end 
        
        # Give clients: 
        chosen_clients = scsample(@client_classes, num_per_side)
        chosen_clients = [chosen_clients] if chosen_clients.is_a?(Integer)
        chosen_clients.each { |cli| @stadiums[mp][si].addClient(cli) }
        
        # Opponents of clients: player, employees, or other clients. 
        chosen_opponents = [] 
        
        # player_map will be String (not nil) when the player is affected a battle.
        # If nil, then it's not affected a battle.
        if !@player_map || (rand(100) < 25 && @available_employees.length >= num_per_side)
          # Choose the guys on the opposite side. 
          if !@player_map && player_client.battleRoyale
            chosen_opponents.push(@available_employees.pop())
            for num in 1...num_per_side
              chosen_opponents.push(scsample(@client_classes, 1))
            end 
          else 
            for num in 0...num_per_side
              chosen_opponents.push(@available_employees.pop())
            end 
          end 
          
          
          # If these are undefined, then we need to set them. The player will always be the first employee chosen. 
          if !@player_map
            @available_employees.delete(SCClientBattles::AnyPartner)
            @player_map = mp 
            @player_stadium = si
            # Formats 
            @stadiums[mp][si].setFormat(player_client.format)
            player_client.setSpecialRules(self)
            @stadiums[mp][si].disallowAllMechanics = player_client.disallowAllMechanics
            @stadiums[mp][si].battleRoyale = player_client.battleRoyale
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
  
  
  
  def panel
    return if !pbConfirmMessage("See client requests?")
    
    reinit if scGetSwitch(:RandBattleDone)
    ret = @panel.show
    self.generateBattles(ret) if ret
    displayStadiums("Castle") if ret
  end 
  
  
  class PlayersClient
    attr_reader :tier
    attr_reader :format
    attr_reader :battleRoyale
    attr_reader :withPartner
    attr_reader :inverseBattle
    attr_reader :changingTerrain
    attr_reader :changingWeather
    attr_accessor :disallowAllMechanics
    
    def initialize(tier, format, withPartner, battleRoyale = false, inverseBattle = false, 
                  changingTerrain = false, changingWeather = false, disallowAllMechanics = false)
      @tier = tier 
      @format = format 
      @withPartner = withPartner
      @battleRoyale = battleRoyale
      @inverseBattle = inverseBattle
      @changingTerrain = changingTerrain
      @changingWeather = changingWeather
      @disallowAllMechanics = disallowAllMechanics
    end 
    
    def panelName
      s = _INTL("Req: {1} in {2}", @tier, @format)
      s += " (p)" if @withPartner
      s += " BR" if @battleRoyale
      s += " CT" if @changingTerrain
      s += " CW" if @changingWeather
      s += " inv" if @inverseBattle
      s += " DAM" if @disallowAllMechanics
      return s 
    end 
    
    def panelDesc
      # The line to be displayed on the panel 
      s = _INTL("Request: tier {1}", loadTierNoStorage(@tier).name)
      s += _INTL(" in Battle Royale") if @battleRoyale
      s += _INTL(" in Inverse Battle") if @inverseBattle
      s += _INTL(" with Changing Terrain") if @changingTerrain
      s += _INTL(" with Changing Weather") if @changingWeather
      s += _INTL(" with format {1}", @format)
      s += _INTL(" with partner") if @withPartner
      s += _INTL(" without mechanics") if @disallowAllMechanics
      s += "." 
      return s 
    end 
    
    def setSpecialRules(client_battles)
      client_battles.setSpecialRules("battleRoyale") if @battleRoyale
      client_battles.setSpecialRules("inverseBattle") if @inverseBattle
      client_battles.setSpecialRules("changingTerrain") if @changingTerrain
      client_battles.setSpecialRules("changingWeather") if @changingWeather
    end 
  end 
  
  
  class Panel
    def initialize
      @content = []
      @content_names = []
      @content_desc = []
      @chosen = nil 
      
      ["FEL", "FE"].each do |fe|
        next if fe == "FEL" && !scLegendaryAllowed?
        
        # First case: Always FE, 1v1 
        @content.push(PlayersClient.new(fe, "1v1", false))
        
        # Second case: FE + other format (2v2, etc)
        format = SCClientBattles.biasedFormat2 # Biased 2v2, 3v3 and so on.
        with_partner = (format == "2v2" && rand(100)< 50)
        @content.push(PlayersClient.new(fe, format, with_partner))
        
        # Third case: Battle Royale (2v2 or 3v3)
        format = (rand(2) == 1 ? "2v2" : "3v3")
        @content.push(PlayersClient.new(fe, format, false, true))
      end
      
      # Two among: Mono / Bi / LC / NFE
      big_tiers = ["MONO", "BI", "NE", "LC"]
      num_tiers = 2
      
      if scLegendaryAllowed?
        big_tiers += ["UBER", "MONOL", "BIL"]
        num_tiers += 1
      end 
      
      chosen_tiers = scsample(big_tiers, num_tiers)
      chosen_tiers.each do |tier|
        @content.push(PlayersClient.new(tier, "1v1", false))
      end 
      
      # Two among the small tiers. 
      small_tiers = SCClientBattles.smallTiers
      chosen_tiers = scsample(small_tiers, 2)
      chosen_tiers.each do |tier|
        @content.push(PlayersClient.new(tier, "1v1", false))
      end 
      
      # The tier of the day.
      @tier_of_the_day_index = @content.length
      @content.push(PlayersClient.new(scTOTDHandler.get(), "1v1", false))
      
      # Full random
      @full_random_index = @content.length
      all_tiers = big_tiers + small_tiers
      rand_tier = scsample(all_tiers, 1)
      
      battle_royale = scGetSwitch(:AllowBattleRoyales) && rand(10) < 3 
      
      formats = ["2v2", "3v3"]
      formats += ["4v4", "5v5", "6v6"] if !battle_royale && scGetSwitch(:AllowBigFormats)
      format = scsample(formats, 1)
      
      @content.push(PlayersClient.new(rand_tier, format, false, battle_royale, 
                      scGetSwitch(:AllowInverseBattles) && rand(10) < 2, 
                      scGetSwitch(:AllowChangingTerrain) && rand(10) < 1, 
                      scGetSwitch(:AllowChangingWeather) && rand(10) < 1,
                      rand(10) < 1)) # Disallow all mechanics
      
      @content_names = []
      @content_desc = []
      
      @content.each_with_index do |c, i|
        if i == @full_random_index
          @content_names.push("Surprise client")
        else
          @content_names.push(c.panelName)
        end 
        
        @content_desc.push(c.panelDesc)
      end 
    end 
    
    
    def show
      ret = pbShowCommandsWithHelp(nil, @content_names, @content_desc, -1, 0)
      return if ret == -1
      return if @chosen
      @chosen = ret
      return @content[@chosen]
    end 
  end 
end 




