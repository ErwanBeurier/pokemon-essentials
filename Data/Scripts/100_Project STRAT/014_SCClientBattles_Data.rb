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
  attr_accessor :battle_over
  # Normal greeting + asks if the player is ready to fight.
  attr_accessor :greeting
  # When the player is not ready to fight yet.
  attr_accessor :player_not_ready
  # When the player misses a partner.
  attr_accessor :partner_missing
  # When the player has a partner but it's the wrong one.
  attr_accessor :wrong_partner
  # When the player shows up with an invalid team.
  attr_accessor :invalid_team 
  # When the player wins the battle.
  attr_accessor :player_won 
  # When the player loses: ask if they should try again.
  attr_accessor :try_again
  # When the player loses and accepts defeat.
  attr_accessor :client_won
  
  def initialize()
    @battle_over = _INTL("Thank you for your time \\PN!")
    @greeting = _INTL("Hi \\PN!\\nReady to fight?")
    @player_not_ready = _INTL("No problem. I want a good fight!")
    @partner_missing = _INTL("But... I wanted you to team up with one of your friends...")
    @wrong_partner = _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner)
    @invalid_team = _INTL("But... Your team is not valid...")
    @player_won = _INTL("Well done!")
    @try_again = _INTL("Try again?")
    @client_won = _INTL("That's unbelievable, I won!")
  end 
  
  def pushBattleOver(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @battle_over.is_a?(Array)
      @battle_over.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @battle_over, indent)
    end 
  end 
  def pushGreeting(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @greeting.is_a?(Array)
      @greeting.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @greeting, indent)
    end 
  end 
  def pushPlayerNotReady(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @player_not_ready.is_a?(Array)
      @player_not_ready.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @player_not_ready, indent)
    end 
  end 
  def pushPartnerMissing(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @partner_missing.is_a?(Array)
      @partner_missing.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @partner_missing, indent)
    end 
  end 
  def pushWrongPartner(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @wrong_partner.is_a?(Array)
      @wrong_partner.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @wrong_partner, indent)
    end 
  end 
  def pushInvalidTeam(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @invalid_team.is_a?(Array)
      @invalid_team.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @invalid_team, indent)
    end 
  end 
  def pushPlayerWon(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @player_won.is_a?(Array)
      @player_won.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @player_won, indent)
    end 
  end 
  def pushTryAgain(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @try_again.is_a?(Array)
      @try_again.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @try_again, indent)
    end 
  end 
  def pushClientWon(list, indent)
    # If it's list of Event Commands, reimplement this function.
    if @client_won.is_a?(Array)
      @client_won.each { |bo| pbPushText(list, bo, indent) }
    else # String
      pbPushText(list, @client_won, indent)
    end 
  end 
  
end 






module SCClientBattleDialogues
  Usual1 = SCClientBattleDialogue.new()
  
  Usual2 = SCClientBattleDialogue.new()
  Usual2.battle_over = "What a battle \\PN!"
  Usual2.greeting = ["I'm happy to finally meet you!", "Let's start?"]
  Usual2.player_not_ready = "Please hurry up, I don't have much time!"
  Usual2.partner_missing = "But... I wanted you to team up with someone of your team..."
  Usual2.wrong_partner = _INTL("But... I wanted you to team up with \\V[{1}]...", SCVar::WantedPartner)
  Usual2.invalid_team = _INTL("Please take a team that is valid for \V[{1}].", SCVar::Tier)
  Usual2.try_again = "I cannot lose like this..."
  Usual2.client_won = ["Thank you for letting me win!", 
    "I know you let me win, of course, I am not delusional."]
  
  def self.get_random_usual
    usuals = [Usual1, Usual2]
    
    return usuals[rand(usuals.length)]
  end 
  
  # And below, add more story-related stuff. 
  
  
end 