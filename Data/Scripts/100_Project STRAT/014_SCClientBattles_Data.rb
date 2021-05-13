###############################################################################
# SCClientBattles_Data
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# 
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
  
  def initialize(client_name, battle_over, greeting, player_not_ready, partner_missing, 
                  wrong_partner, invalid_team, player_won, try_again, client_won, special_formatting = nil)
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
    @special_formatting = special_formatting
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
      @client_name_formated = scsample($SCFormattingPersonalities["ClientM"], 1)
    when 1 # Female 
      @client_name_formated = scsample($SCFormattingPersonalities["ClientF"], 1)
    else 
      @client_name_formated = scsample($SCFormattingPersonalities["Client"], 1)
    end 
    
    @client_name_formated = _INTL("\\XN[{1}]", @client_name) if !@client_name_formated
  end 
  
  
  def name()
    return @client_name_formated
  end 
  
  def pushBattleOver(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @battle_over.is_a?(Array)
      @battle_over.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @battle_over, indent)
    end 
  end 
  def pushGreeting(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @greeting.is_a?(Array)
      @greeting.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @greeting, indent)
    end 
  end 
  def pushPlayerNotReady(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @player_not_ready.is_a?(Array)
      @player_not_ready.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @player_not_ready, indent)
    end 
  end 
  def pushPartnerMissing(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @partner_missing.is_a?(Array)
      @partner_missing.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @partner_missing, indent)
    end 
  end 
  def pushWrongPartner(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @wrong_partner.is_a?(Array)
      @wrong_partner.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @wrong_partner, indent)
    end 
  end 
  def pushInvalidTeam(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @invalid_team.is_a?(Array)
      @invalid_team.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @invalid_team, indent)
    end 
  end 
  def pushPlayerWon(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @player_won.is_a?(Array)
      @player_won.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @player_won, indent)
    end 
  end 
  def pushTryAgain(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @try_again.is_a?(Array)
      @try_again.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @try_again, indent)
    end 
  end 
  def pushClientWon(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @client_won.is_a?(Array)
      @client_won.each { |bo| pbPushText(list, self.name() + bo, indent) }
    else # String
      pbPushText(list, self.name() + @client_won, indent)
    end 
  end 
  
end 






module SCClientBattleDialogues
  # -------------------------------------------------------
  # Random client dialogues.
  # -------------------------------------------------------
  # Several instances of dialogues just so that the clients 
  # don't always say the same lines
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
      _INTL("Please take a team that is valid for \V[{1}].", SCVar::Tier),
      _INTL("I cannot lose like this..."),
      _INTL("Try again?"),
      ["Thank you for letting me win!", "I know you let me win, of course, I am not delusional."]
    )
  
  def self.get_random_usual
    usuals = [Usual1, Usual2]
    return usuals[rand(usuals.length)]
  end 
  
  # -------------------------------------------------------
  # Story dialogues
  # -------------------------------------------------------
  # New instances that are story-related. 
  
end 