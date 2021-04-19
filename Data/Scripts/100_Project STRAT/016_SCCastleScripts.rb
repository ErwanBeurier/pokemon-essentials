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
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
  loop do
    # commands=["Pokémon storage", "Team builder", "Stats"]
    commands=["Team builder", "Stats"]
    commands.push("Change tier") 
    commands.push("Log off")
    
    command=pbMessage(_INTL("Which PC should be accessed?"), commands,commands.length)
    
    case command 
      # when 0 # Pokémon storage 
        # scene = StorageSystemPC.new
        # scene.access() 
      when 0 # Team builder 
        # scene = SCTeamBuilder.new(true)
        scene = SCTeamViewer.new
        scene.main 
      when 1 # Stats 
        scBattleStats.menu 
        # pbMessage("Unimplemented yet.")
      when 2 
        temp = scSelectTierMenu
        scSetTier(temp, false)
        pbMessage("You are working with the tier: " + scGetTier() + ".")
      else 
        break 
    end 
  end
  pbSEPlay("PC close")
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
