################################################################################
# SCCastleScripts
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains misc functions related to the castle: the PC, the TV, 
# loading trainer graphics for the random ladder.
################################################################################



#----------------------------------------------------------
# Menu for the PC:
# - Teambuilder 
# - Change tier
# - Tier statistics. 
#----------------------------------------------------------
def scCastlePC
  pbMessage(_INTL("\\SC[Computer]\\se[PC open]{1} booted up the PC.",$Trainer.name))
  loop do
    # commands=["Pokémon storage", "Team builder", "Stats"]
    cmdTeamBuilder = -1 
    cmdStatistics = -1
    cmdChangeTier = -1 
    cmdRealPokemon = -1
    
    commands = []
    commands[cmdTeamBuilder = commands.length] = "Team builder"
    # commands[cmdStatistics = commands.length] = "Battle stats"
    # commands[cmdChangeTier = commands.length] = "Change tier" if !SCSwitch.get(:ForcedTier) 
    commands[cmdRealPokemon = commands.length] = "Change real Pokémon" if SCSwitch.get(:AllowTeamChange)
    commands.push("Log off")
    
    command=pbMessage(_INTL("\\SC[Computer]Which PC should be accessed?"), commands,-1)
    
    # case command 
    # when 0 # Pokémon storage 
      # scene = StorageSystemPC.new
      # scene.access() 
    if cmdTeamBuilder > -1 && command == cmdTeamBuilder # Team builder 
      # scene = SCTeamBuilder.new(true)
      scene = SCTeamViewer.new
      scene.main 
      
    elsif cmdStatistics > -1 && command == cmdStatistics # Stats 
      scBattleStats.menu 
      
    elsif cmdChangeTier >-1 && command == cmdChangeTier # Tier menu
      temp = scSelectTierMenu
      scSetTier(temp, false)
      pbMessage("\\SC[Computer]You are working with the tier: " + scGetTier() + ".")
      
    elsif cmdRealPokemon > -1 && command == cmdRealPokemon # Change the Real Pokémons. 
      
      next if !pbConfirmMessage("\\SC[Computer]Do you want to change the Pokémons that the main character used in his adventure?")
      pbMessage("\\SC[Computer]You can do this only once per game.")
      next if !pbConfirmMessage("\\SC[Computer]Do you want to continue?")
      
      SCStoryPokemon.export
      
      pbMessage("\\SC[Computer]The Pokémons were exported to the file SC_Story_Pokemon_Chosen.txt in the game folder.")
      pbMessage("\\SC[Computer]Edit ONLY the Pokémon species.")
      pbMessage("\\SC[Computer]Write the Pokémon species that you want in CAPITAL letters.")
      
      loop do 
        pbMessage("\\SC[Computer]You can now edit the file SC_Story_Pokemon_Chosen.txt in the game folder.")
        
        next if !pbConfirmMessage("\\SC[Computer]Done?")
        next if !pbConfirmMessage("\\SC[Computer]Import the changes?")
        
        begin 
          SCStoryPokemon.import
          break 
          
        rescue Exception => e
          pbMessage("\\SC[Computer]There was an error in the changes.")
          pbMessage("\\SC[Computer]You most probably made a mistake while editing the file.")
          pbMessage("\\SC[Computer]The game will show an error.")
          pbMessage("\\SC[Computer]Don't panic and try to fix the error in the file.")
          raise e 
        end 
      end 
      
      pbMessage("\\SC[Computer]The changes were imported.")
      pbMessage("\\SC[Computer]You can no longer change them in this game.")
      
      SCSwitch.set(:AllowTeamChange, false)
      
    else 
      break 
    end 
  end
  pbSEPlay("PC close")
  $PokemonTemp.dependentEvents.come_back(false)
end 






def scWatchCastleTV
  list_broadcasts = [
    "\"Mais réveille-toi, connard de Togekiss de merde ! Mais réveille-toi ! MAIS REVEILLE-TOI !\"",
    "Some eyes are staring back at you...",
    "The trainer became angry because he missed five Focus Blasts in a row..."
  ]
  
  pbMessage(list_broadcasts[rand(list_broadcasts.length)])
end 






#----------------------------------------------------------
# Loads the trainer graphics for random battles in the 
# castle.
#----------------------------------------------------------
def scLoadTrainerGraphics(eventopponent, class_i, name_i)
  # Opponent 1: class_i = 53 ; name_i = 54 
  # Opponent 2: class_i = 55 ; name_i = 56
  # Opponent 3: class_i = 57 ; name_i = 58
  client = scFastClient
  filename=sprintf("trchar%03d",client[0])
  eventopponent.character_name = filename
  $game_variables[class_i] = client[0]
  $game_variables[name_i] = client[1]
end 

# Other names I liked: 
# Males: Lóránt, Lörinc
# Females: 

def scFastClient
  return [scsample(SCClientBattles.cleverGuys, 1), "Punching-ball"]
  # return [scsample(SCClientBattles.clients, 1), "Punching-ball"]
end 
