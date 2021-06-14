###############################################################################
# SCClientBattles_Data
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script defines a class and constants defining dialogue around cllient 
# battles. 
###############################################################################



class SCClientBattleDialogue
  # When the battle is over and the player talks again to the client.
  attr_reader :battle_over
  # Normal greeting + asks if the player is ready to fight.
  attr_reader :greeting
  # When the player is not ready to fight yet.
  attr_reader :player_not_ready
  # When the player misses a partner.
  attr_reader :partner_missing
  # When the player has a partner but it's the wrong one.
  attr_reader :wrong_partner
  # When the player shows up with an invalid team.
  attr_reader :invalid_team 
  # When the player wins the battle.
  attr_reader :player_won 
  # When the player loses: ask if they should try again.
  attr_reader :try_again
  # When the player loses and accepts defeat.
  attr_reader :client_won
  # Name of the client 
  attr_reader :client_name
  # Client trainer ID
  attr_reader :trainer_id
  # Dialogue to put at the end of the Event, whether it's a victory or a defeat.
  attr_reader :end_dialogue
  # Script to put at the end of the Event. 
  attr_reader :end_script
  
  
  def initialize(client_name, battle_over, greeting, player_not_ready, partner_missing, 
                  wrong_partner, invalid_team, player_won, try_again, client_won, 
                  trainer_id = nil, special_formatting = nil, end_dialogue = nil, 
                  end_script = nil, end_switch = nil, conditions = nil)
    @client_name = client_name
    @battle_over = battle_over
    @greeting = greeting
    @player_not_ready = player_not_ready
    @partner_missing = partner_missing
    @wrong_partner = wrong_partner
    @invalid_team = invalid_team
    @player_won = player_won
    @try_again = try_again
    @client_won = client_won
    @trainer_id = trainer_id
    @special_formatting = special_formatting
    @end_dialogue = end_dialogue 
    @end_script = end_script 
    
    if end_switch
      @end_switch = (end_switch[0].is_a?(Array) ? end_switch : [end_switch])
    else 
      @end_switch = nil 
    end 
  end 
  
  
  def prepare_formatting(trainer_id)
    if @special_formatting
      @client_name_formated = @special_formatting 
      return 
    end 
    
    @client_name_formated = ""
    
    # If the formatting isn't already included in the 
    case pbGetTrainerTypeData(trainer_id)[7]
    when 0 # Male 
      @client_name_formated = $SCFormattingPersonalities["ClientM"]
    when 1 # Female 
      @client_name_formated = $SCFormattingPersonalities["ClientF"]
    else 
      @client_name_formated = $SCFormattingPersonalities["Client"]
    end 
    
    @client_name_formated.sub!(/Client/, @client_name) if @client_name
    
    # @client_name_formated = _INTL("\\XN[{1}]", @client_name) if !@client_name_formated
  end 
  
  
  def name()
    return @client_name_formated
  end 
  
  
  def format(instance)
    if instance[/\A\\[Ss][Cc]/] 
      # If there is already a formatting (typically when someone else than the client is speaking).
      return instance
    else 
      return self.name() + instance
    end 
  end 
  
  
  def pushTextGeneral(list, instance, indent)
    # If it's list of Event Commands, reimplement this function.
    if instance.is_a?(Array)
      instance.each { |bo| 
        pbPushText(list, self.format(bo), indent)
      }
    else # String
      pbPushText(list, self.format(instance), indent)
    end 
  end 
  
  
  def specificPreparation(event)
    return 0 
  end 
  
  
  def pushBattleOver(list, indent)
    self.pushTextGeneral(list, @battle_over, indent)
  end 
  def pushGreeting(list, indent)
    self.pushTextGeneral(list, @greeting, indent)
  end 
  def pushPlayerNotReady(list, indent)
    self.pushTextGeneral(list, @player_not_ready, indent)
  end 
  def pushPartnerMissing(list, indent)
    self.pushTextGeneral(list, @partner_missing, indent)
  end 
  def pushWrongPartner(list, indent)
    self.pushTextGeneral(list, @wrong_partner, indent)
  end 
  def pushInvalidTeam(list, indent)
    self.pushTextGeneral(list, @invalid_team, indent)
  end 
  def pushPlayerWon(list, indent)
    self.pushTextGeneral(list, @player_won, indent)
  end 
  def pushTryAgain(list, indent)
    self.pushTextGeneral(list, @try_again, indent)
  end 
  def pushClientWon(list, indent)
    self.pushTextGeneral(list, @client_won, indent)
  end 
  def pushEndDialogue(list, indent)
    return if !@end_dialogue
    self.pushTextGeneral(list, @end_dialogue, indent)
  end 
  def pushEndScript(list, indent)
    return if !@end_script
    
    # If it's list of Event Commands, reimplement this function.
    if @end_script.is_a?(Array)
      @end_script.each { |bo| 
        pbPushScript(list, bo, indent)
      }
    else # String
      pbPushScript(list, @end_script, indent)
    end 
  end 
  def pushEndControlSwitch(list, indent)
    return if !@end_switch
    
    if !@end_switch.is_a?(Array)
      raise _INTL("@end_switch should be an array of length 2 or 3, of the form:\n[switch_num, value] or [switch_num_start, switch_num_end, value]\nGiven: {1}", scToStringRec(@end_switch))
    end 
    
    @end_switch.each do |switch_data|
      if switch_data.length == 2
        pbPushControlSwitch(list, switch_data[0], switch_data[1], indent)
        
      elsif switch_data.length == 3
        pbPushControlSwitchBatch(list, switch_data[0], switch_data[1], switch_data[2], indent)
      else 
        raise _INTL("@end_switch should be an array of length 2 or 3, of the form:\n[switch_num, value] or [switch_num_start, switch_num_end, value]\nGiven: {1}", scToStringRec(@end_switch))
      end 
    end 
  end 
end 


class SCClientBattleDialogue_Eddie_1 < SCClientBattleDialogue
  def specificPreparation(event)
    # First page is the camouflage. 
    event.pages[0].move_type = 0
    event.pages[0].trigger = 0 # Action Button
    pbGiveEventPageGraphicTile(event, 0, 105, 7)
    pbPushAnimation(event.pages[0].list, -1, 3, 0)
    pbPushWait(event.pages[0].list, 6, 0)
    pbPushSelfSwitch(event.pages[0].list,"A",true,0)
    pbPushEnd(event.pages[0].list)
    
    # Next page: the usual dialogue. 
    event.pages.push(RPG::Event::Page.new)
    event.pages[1].move_type = 0
    event.pages[1].trigger = 0 # Action Button
    event.pages[1].condition.self_switch_valid = true
    event.pages[1].condition.self_switch_ch = "A"
    event.pages[1].graphic.character_name = "trchar512_Eddie"
    return 1 
  end 
end 


def scTestSpwanEvent(x, y)
  event = RPG::Event.new(x,y)
  event.name = "Client (Waiting)"
  
  key_id = ($game_map.events.keys.max || -1) + 1
  event.id = key_id
  event.x = x
  event.y = y
  event.pages[0].move_type = 0
  event.pages[0].trigger = 0 # Action Button
  
  # event.pages[0].graphic.tile_id = 384 + 8 * 6 + 7
  # pbGiveEventPageGraphicTile(event, 0, 107, 7)
  pbGiveEventPageGraphicTile(event, 0, 6, 7)
  # pbPushText(event.pages[0].list, "Gladys")
  # event.pages[0].condition.self_switch_valid = false
  pbPushAnimation(event.pages[0].list, -1, 3, 0)
  pbPushWait(event.pages[0].list, 6, 0)
  pbPushSelfSwitch(event.pages[0].list,"A",true,0)
  pbPushEnd(event.pages[0].list)
  
  event.pages.push(RPG::Event::Page.new)
  event.pages[1].trigger = 0 # Action Button
  # pbGiveEventPageGraphicTile(event, 1, 7, 7)
  event.pages[1].graphic.character_name = "trchar512_Eddie"
  event.pages[1].condition.self_switch_valid = true
  event.pages[1].condition.self_switch_ch = "A"
  pbPushText(event.pages[1].list, "Monia", 0)
  # pbPushSelfSwitch(event.pages[1].list,"A",false,1)
  pbPushEnd(event.pages[1].list)
  
  
  # creating and adding the Game_Event
  gameEvent = Game_Event.new($game_map.map_id, event, $game_map)
  key_id = ($game_map.events.keys.max || -1) + 1
  gameEvent.id = key_id
  gameEvent.moveto(x,y)
  $game_map.events[key_id] = gameEvent
  # @event_list.push(key_id)
  
  # updating the sprites
  sprite = Sprite_Character.new(Spriteset_Map.viewport,$game_map.events[key_id])
  $scene.spritesets[$game_map.map_id]=Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id]==nil
  $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
end 




###############################################################################
# 
#                         Random client dialogues.
# 
# -----------------------------------------------------------------------------
# Several instances of dialogues just so that the clients don't always say the 
# same lines + they react to the story progress. 
###############################################################################
module SCClientBattleDialogues
  Usual1 = SCClientBattleDialogue.new("Client",
      _INTL("Thank you for your time \\PN!"),
      _INTL("Hi \\PN!\\nReady to fight?"),
      _INTL("No problem. I want a good fight!"),
      _INTL("But... I wanted you to team up with one of your friends..."),
      _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner),
      _INTL("But... Your team is not valid..."),
      _INTL("Well done!"),
      _INTL("Try again?"),
      _INTL("That's unbelievable, I won!")
    )
  
  Usual2 = SCClientBattleDialogue.new("Client",
      _INTL("What a battle \\PN!"),
      ["I'm happy to finally meet you!", "Let's start?"],
      _INTL("Please hurry up, I don't have much time!"),
      _INTL("But... I wanted you to team up with someone of your team..."),
      _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner),
      _INTL("Please take a team that is valid for \\V[{1}].", SCVar::Tier),
      _INTL("I cannot lose like this..."),
      _INTL("Try again?"),
      ["Thank you for letting me win!", "I know you let me win, of course, I am not delusional."]
    )
  
  def self.get_random_usual
    usuals = [Usual1, Usual2]
    return usuals[rand(usuals.length)]
  end 
end 

  
###############################################################################
# 
#                         Story dialogues.
# 
# -----------------------------------------------------------------------------
# Instances that give story-related dialogue to clients. 
###############################################################################

module SCClientBattleDialogues
  #----------------------------------------------------------------------------
  # Lorant dialogue (little adventurer)
  #----------------------------------------------------------------------------
  Lorant_1 = SCClientBattleDialogue.new("Lorànt",
    _INTL("..."),
    [_INTL("Hello \\PN!"), 
      _INTL("It's an honour to finally meet you!"), 
      _INTL("I am Lorànt, I am your biggest fan!"), 
      _INTL("You're my hero."),
      _INTL("\\SC[Player]... Thanks."),
      _INTL("The way you beat Team Rocket on your own, it was inspirational."),
      _INTL("I'm sorry, I assume you hear that all the time!"),
      _INTL("Let's go?")],
    [_INTL("No problem. Take your time!"),
      _INTL("I'm too excited, sorry.")],
    _INTL("But... I wanted you to team up with one of your friends..."), # Should not happen.
    _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner), # Should not happen. 
    _INTL("But... Your team is not valid..."),
    [_INTL("Wow, you deserve your reputation!"),
      _INTL("It was a pleasure to fight you."),
      _INTL("I know it's not my greatest feat of strength, but tell me."),
      _INTL("Do you believe I can be as strong as you someday?"),
      _INTL("If I keep training hard, I mean."),
      _INTL("\\SC[Player]Sure you can. Just don't give up."),
      _INTL("\\SC[Player]One day we'll fight again, and you might beat me!"),
      _INTL("Thank you!"),
      _INTL("Mom wouldn't believe in me."),
      _INTL("\\SC[Player]What do you mean?"),
      _INTL("..."),
      _INTL("\\SC[Player]Was this battle a test to prove something to your parents?"),
      _INTL("..."),
      _INTL("\\SC[Player]Something they disagree with?"),
      _INTL("..."),
      _INTL("\\SC[Player]Do you plan to go on an adventure?"),
      _INTL("..."),
      _INTL("\\SC[Player]Sure you do."),
      _INTL("You think I'm stupid, don't you?"),
      _INTL("\\SC[Player]Stupid, no. Immature, absolutely."),
      _INTL("Why?"),
      _INTL("\\SC[Player]What do your parents say?"),
      _INTL("\\SC[Player]Whatever they say, you should listen to them."),
      _INTL("..."),
      _INTL("\\SC[Player]Team Rocket is still out there. They don't care about killing your Pokémon."),
      _INTL("\\SC[Player]You don't want to risk losing your friends. Trust me."),
      _INTL("..."),
      _INTL("\\SC[Player]This amusement park was built so that trainers can fight with whatever Pokémon they want."),
      _INTL("\\SC[Player]Here, you cannot \"kill\" a Pokémon, because they are modified Porygon."),
      _INTL("\\SC[Player]They don't \"live\", and you can replace them easily with a new download."),
      _INTL("\\SC[Player]Real Pokémon do die."),
      _INTL("..."),
      _INTL("\\SC[Player]Don't go on an adventure."),
      _INTL("\\SC[Player]This is what I would say if I met my young self."),
      _INTL("\\SC[Player]Just don't."),
      _INTL("..."),
      _INTL("\\SC[Player]You have potential though. You should try to fight me again, or my friends."),
      _INTL("\\SC[Player]If you come back, I'll give you a discount."),
      _INTL("\\SC[Player]This way, I'll be sure that you're not roaming around.")
      ],
      _INTL("I must not lose. Try again?"),
      nil,
      PBTrainers::SC_CHARACTER_LORANT,
      "\\SC[Lorant]",
      nil, 
      "scRequireClients(2, 219)", 
      [217, false]
  )
  
  
  #----------------------------------------------------------------------------
  # Beatriz dialogue (fan of Seren)
  #----------------------------------------------------------------------------
  Beatriz_1 = SCClientBattleDialogue.new("Client",
    # battle_over
    [_INTL("You're strong, I cannot deny it."), 
      _INTL("But Seren is probably better than you.")
    ],
    # greeting
    [_INTL("Hello."), 
      _INTL("\\SC[Player]Hello."), 
      _INTL("Is it too late to choose my opponent? I wanted to fight Seren..."), 
      _INTL("\\SC[Player]You cannot choose."), 
      _INTL("\\SC[Player]We do not want clients to fight us based on their preferences."), 
      _INTL("\\SC[Player]Generally clients want to fight me specifically though."), 
      _INTL("I believe Seren is better than you."), 
      _INTL("\\SC[Player]I can't argue against that."),
      _INTL("Whatever. Let's start?")
    ],
    # player_not_ready
    _INTL("Ok, I'll be waiting here."),
    # partner_missing
    nil, 
    # wrong_partner
    nil,
    # invalid_team
    _INTL("But, your team is not valid..."),
    # player_won, 
    [_INTL("Of course you would win."),
      _INTL("I guess I'm still far from reaching Seren's level as well.")
    ],
    # try_again
    _INTL("Try again?"),
    # client_won
    [_INTL("Of course I won."),
      _INTL("I guess you're far from Seren's level.")
    ],
    # trainer_id
    PBTrainers::SC_CHARACTER_BEATRIZ,
    # special_formatting
    nil, 
    # end_dialogue
    [_INTL("\\SC[Player]*Sigh*"),
      _INTL("What?"),
      _INTL("\\SC[Player]Do you know why we don't test each other?"),
      _INTL("Because you already know the results?"),
      _INTL("\\SC[Player]Because we have the same level of skill."),
      _INTL("\\SC[Player]When you are at a certain level, victories and defeats boil down to preparation and choice of team."),
      _INTL("\\SC[Player]It's almost chance."),
      _INTL("I don't believe you."),
      _INTL("\\SC[Player]That's why you don't hear us say \"one is better than the other\", but rather, \"one won against the other\"."),
      _INTL("\\SC[Player]Because maybe the result of the next battle is opposite. And it often is."),
      _INTL("I don't believe you. For me, it's just a matter of respect."), 
      _INTL("You are friends, and you don't want to upset anyone.")
    ],
    # end_script
    nil, 
    # end_switch 
    [[232, true], [243, true]]
  )
  
  
  #----------------------------------------------------------------------------
  # Eddie dialogue (ninja boy)
  #----------------------------------------------------------------------------
  Eddie_1 = SCClientBattleDialogue_Eddie_1.new("Client", 
    # battle_over
    ["\\SC[Player]I must admit, your intro is original.",
      "\\SC[Eddie]It takes years of hard work.",
      "\\SC[Player]Years? But you're like... Twelve!",
      "\\SC[Eddie]Yeah... I got the best teacher in the world, my daddy!"
      ],
    # greeting
    ["Hahaha!", "You found me!", 
      "\\SC[Player]I was wondering what that rock was...",
      "I am Eddie, I am your biggest fan!",
      "\\SC[Eddie]... I am thinking, you must hear that all the time.",
      "\\SC[Player]It's true, but it always feels good to hear that.",
      "\\SC[Eddie]Let's go?"
      ],
    # player_not_ready
    "\\SC[Eddie]No problem!",
    # partner_missing
    _INTL("\\SC[Eddie]But... I wanted you to team up with one of your friends..."), # Should not happen.
    # wrong_partner
    _INTL("\\SC[Eddie]But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner), # Should not happen. 
    # invalid_team
    _INTL("\\SC[Eddie]But... Your team is not valid..."),
    # player_won
    [_INTL("\\SC[Eddie]That was a lesson in Pokémon battles!"),
      _INTL("\\SC[Player]You were fine, don't worry."),
      _INTL("\\SC[Player]You're still young, you have all the time to improve."),
      _INTL("\\SC[Player]And you don't need to fight if you can camouflage!")
    ],
    # try_again 
      _INTL("Try again?"),
    # client_won
    [_INTL("\\SC[Player]You were excellent."),
      _INTL("\\SC[Eddie]Thank you!!!"),
      _INTL("\\SC[Player]You're still young, you have plenty of time to become even better."),
      _INTL("\\SC[Player]One day you'll become as good as you are with camouflage."),
      _INTL("\\SC[Eddie]Wow!!!!")
    ],
    # trainer_id
    PBTrainers::SC_CHARACTER_EDDIE,
    # nil,
    # special_formatting
    nil,
    # end_dialogue
    nil,
    # end_script
    nil,
    # end_switch
    [[246, true], [247, false], [248, true]]
    )
    
  # Name = SCClientBattleDialogue.new(client_name, 
    # battle_over, 
    # greeting, 
    # player_not_ready, 
    # partner_missing, 
    # wrong_partner, 
    # invalid_team, 
    # player_won, 
    # try_again, 
    # client_won, 
    # trainer_id = nil, 
    # special_formatting = nil, 
    # end_dialogue = nil, 
    # end_script = nil, 
    # end_switch = nil)
end 


###############################################################################
# 
#                    Specific instances of client requests.
# 
# -----------------------------------------------------------------------------
# Instances that force the next client request. 
###############################################################################

module SCClientRequests
  Beatriz_1 = SCClientBattlesGenerator::PlayersClient.new("FE", "1v1")
  # Eddie_1 = SCClientBattlesGenerator::PlayersClient.new("FE", "1v1", "Beach")
end 