###############################################################################
# SCGenerateBattle
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script mainly contains scripts to generate random battles with 
# different formats. 
###############################################################################






def scLoadRandomTrainer(trainerID, trainerName)
  opponent = PokeBattle_Trainer.new(trainerName,trainerID)
  opponent.setForeignID($Trainer)
  party = scGenerateTeamRand(opponent)
  return [opponent, [], party, ""]
end 



def scTrainerBattle(trainerID, trainerName, format = "single", endSpeech=nil,
                    trainerPartyID=-1, canLose=true, outcomeVar=1)
  setBattleRule(format) if format
  endSpeech = "..." if !endSpeech
  return pbTrainerBattle(trainerID, trainerName, endSpeech, false, trainerPartyID, canLose, outcomeVar)
end 



def scDoubleTrainerBattle(trainerID1, trainerName1, trainerID2, trainerName2, format = "2v2",
                          trainerPartyID1=-1, endSpeech1 = nil, trainerPartyID2=-1, endSpeech2=nil,
                          canLose=true, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule(format)
  # Perform the battle
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end



def scTripleTrainerBattle(trainerID1, trainerName1, trainerID2, trainerName2, trainerID3, trainerName3, 
                          format = "triple",
                          trainerPartyID1 = -1, endSpeech1 = nil , trainerPartyID2 = -1, endSpeech2 = nil, 
                          trainerPartyID3 = -1, endSpeech3 = nil, canLose = true, outcomeVar = 1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule(format)
  # Perform the battle
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
     [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end




