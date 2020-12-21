class SCBattleStatistics 
  
  def initialize
    @content = {}
    # dictionary: tier -> 3-tuple (num_victories, num_defeats, total_matches)
    @content["GLOBAL"] = [0, 0, 0]
    @tier_list = [] # this is basically @content.keys without "GLOBAL"
    @total_matches = 0 
  end 
  
  def logBattle(is_victory, tier)
    if !@content.keys.include?(tier)
      @content[tier] = [0, 0, 0]
      @tier_list.push(tier)
    end 
    
    if is_victory
      @content[tier][0] += 1
      @content["GLOBAL"][0] += 1
    else 
      @content[tier][1] += 1
      @content["GLOBAL"][1] += 1
    end 
    
    @content[tier][2] += 1 
    @content["GLOBAL"][2] += 1 
    @total_matches += 1 
  end 
  
  def logV(tier = nil) # Short version for script in Event
    if tier == nil 
      tier = scGetTier()
    end 
    
    self.logBattle(true, tier)
  end 
  
  def logD(tier = nil) # Short version for script in Event 
    if tier == nil 
      tier = scGetTier()
    end 
    
    self.logBattle(false, tier)
  end 
  
  def data(tier)
    # Returns a list of size 5:
    # 0 => num of victories
    # 1 => num of defeats 
    # 2 => num of battles
    # 3 => percentage of victories 
    # 4 => percentage of defeats 
    # 5 => percentage of matchs in this tier. 
    return nil if @content.keys.include?(tier)
    
    d = Array.new(@content[tier])
    
    perc = (@content[tier][0] / @content[tier][2] * 1000).floor / 10
    # *1000 to obtain per mil, and then floor so that per mil is an 
    # integer, and / 10 so that we obtain a percentage with only one digit
    # after the comma !
    d.push(perc)
    d.push(100 - perc)
    
    perc2 = (@content[tier][2] / @total_matches * 1000).floor / 10
    d.push(perc2)
    
    return d
  end 
  
  def printData(tier)
    d = self.data(tier)
    
    if d == nil 
      Kernel.pbMessage(_INTL("You haven't done any battle in this tier!"))
      return 
    end 
    
    Kernel.pbMessage(_INTL("Tier {1}: {2}% of victories ({3} victories in {4} matches).", tier, d[3], d[0], d[2]) )
    Kernel.pbMessage(_INTL("{1}% of matches ({2} matches in {3} in total).", d[5], d[2], @total_matches))
  end 
  
  def menu
    tier_commands = ["Cancel"] + @tier_list
    
    loop do 
      c = Kernel.pbMessage("Choose a tier.", tier_commands, 0)
      
      if c == 0
        return 
      else 
        self.printData(tier_commands[c])
      end 
    end 
  end 
end 




def scRequireClients(num, next_switch)
	# Tell the game that the story will move after having fought at least a certain number of clients. 
	# num = minimum number of clients to fight.
	# next_switch = the ID of the switch that, when set to "true", will trigger the next event in the story. 
	
	$game_variables[62] = num # Required number of clients 
	$game_variables[63] = 0 # reset the number of clients alread fought. 
	$game_variables[64] = next_switch
	
	# Show Manager.
	$game_switches[79] = true 
	
end 




def scLogClientBattleResult()
	$game_variables[63] += 1
	
	if $game_variables[62] <= $game_variables[63]
		# if True, then the next event in the story should start. 
		i = $game_variables[64]
		$game_switches[i] = true 
		
		# Remove Manager. 
		$game_switches[79] = false 
	end
end 
