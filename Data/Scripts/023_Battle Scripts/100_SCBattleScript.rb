# Tests for Pokémon STRAT



class PokeBattle_Scene
  def pbHideOpponen2(idxTrainer=0, filename=nil)
    pbHideOpponent(idxTrainer + 1, filename)
  end 
end 

module DialogueModule
  
  module Test0
    def self.scSetDialogue
      test1 = "Je vais te sucer tellement fort..."
      test2 = "J'ai vraiment hâte de goûter ton sperme."
      test3 = "Je mouille rien qu'à l'idée de te sucer."
      test4 = "Et d'ailleurs tu goûteras mes pieds."
      test5 = ["Je vais te sucer dix fois de suite.", "Est-ce que tu vas tenir ?"]
      test6 = "Prépare-toi !"
      
      BattleScripting.set("faintedOpp",   test1)
      BattleScripting.set("faintedOpp,2", test2)
      BattleScripting.set("faintedOpp,3", test3)
      BattleScripting.set("faintedOpp,4", test4)
      BattleScripting.set("faintedOpp,5", test5)
      BattleScripting.set("faintedOpp,6", test6)
    end 
  end 
  
  
  module Test1
    def self.scSetDialogue
      test1 = ["Shannon m'a parlé de toi!", "Elle a hâte de goûter ton sperme."]
      test2 = "J'ai vraiment hâte de la rejoindre."
      test3 = "Moi aussi j'aime bien qu'on me lèche les pieds."
      test4 = "On va passer une bonne soirée ensemble. Je suce tellement bien."
      test5 = "En vrai j'adore le sperme, j'adore qu'on me lèche les pieds !"
      test6 = "Je suis tellement heureuse d'être ta pute !"
      
      BattleScripting.set("faintedOpp",   test1)
      BattleScripting.set("faintedOpp,2", test2)
      BattleScripting.set("faintedOpp,3", test3)
      BattleScripting.set("faintedOpp,4", test4)
      BattleScripting.set("faintedOpp,5", test5)
      BattleScripting.set("faintedOpp,6", test6)
    end 
  end 
  
end 


def scSetStoryBattleDialogue
  # This function prepares Mid Battle Dialogs according to the current state 
  # in the story (looking at game switches)
  if $game_switches[83]
    DialogueModule::Test0.scSetDialogue
  elsif $game_switches[84]
    DialogueModule::Test1.scSetDialogue
  end 
end 

