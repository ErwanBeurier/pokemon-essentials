# Tests for Pokémon STRAT


# Arguments des Proc: 

# lowHP / halfHP / smlDamage / bigDamage
#   Proc { |battle, args| WITH args = [move, target] } 
#       move is nil in pbReduceHP, because it's HP reduction without moves. 
# 
# notEff / superEff
#  Proc { |battle, args| WITH args = [move, user, target] }
# 
# fainted: 
#   Proc { |battle, battler| ... }
# 
# attack / zmove / maxMove: 
#   Proc { |battle, args| WITH: args = [move, user] }
# 
# gmaxBefore / dynamaxBefore / gmaxAfter / dynamaxAfter / ultraBefore / ultraAfter / mega
#   Proc { |battle, battler| ... }
# 
# loss / endspeech:
#   Proc { |battle, nada| ... }
# 
# recall
#   Proc { |battle, battler| ... }
#       The battler that leaves. 
# 
# item: 
#   Proc { |battle, args| WITH: args = [battler, item] }
# 
# assistAfter / assistBefore # Can be used twice! 
#   Proc { |battle, battler| ... }
#       The assistance caller. 
# 
# phenixFire
#   Proc { |battle, battler| ... }
# 
# commandXXX
#   Proc { |battle, idxBattler| ... }
#       First step: set the command index at the start of the turn.
#       Second step: play the command with the given index. 
# 
# switchXXX
#   Proc { |battle, args| WITH: args = [idxBattler, party, enemies] }
#       First step: set the switch index at the start of the turn.
#       Second step: give the Pokémon to force the siwtch. Append the index of the Pokémon to switch in the args. 





class PokeBattle_Scene
  def pbHideOpponen2(idxTrainer=0)
    pbHideOpponent(idxTrainer + 1)
  end 
end 



module DialogueModule
  
  def self.scDisplayMessage(battle, trainer, *args)
    battle.scene.pbShowOpponent(trainer)
    battle.scene.disappearDatabox
    battle.scene.sprites["messageWindow"].text = ""
    
    # Text.
    args.each { |msg| pbMessage(msg) }
    
    # Remove the Opponent
    battle.scene.pbHideOpponen2(trainer)
    battle.scene.appearDatabox
  end 
  
  # Ask a yes/no question for the last.
  def self.scDisplayAndConfirm(battle, trainer, *args)
    battle.scene.pbShowOpponent(trainer)
    battle.scene.disappearDatabox
    battle.scene.sprites["messageWindow"].text = ""
    
    ret = false
    # Text.
    args.each_with_index do |msg, i| 
      if i == args.length - 1
        ret = pbConfirmMessage(msg)
      else 
        pbMessage(msg)
      end 
    end 
    
    # Remove the Opponent
    battle.scene.pbHideOpponen2(trainer)
    battle.scene.appearDatabox
    
    return ret
  end 
  
  
  module AssistanceTutorial
    # Teach the assistance to the Manager. 
    def self.set
      # Tell that you need the Soul-Link + prepare the switch.
      BattleScripting.set("turnStart0", Proc.new { |battle| 
        DialogueModule.scDisplayMessage(battle, 0, 
          "\\SC[Rachel]So, how do I call for Assistance?",
          "\\SC[Player]First, does your Pokémon hold the Soul-Link?", 
          "\\SC[Rachel]Oh no! Wait, I have to switch!",
          "\\SC[Player]Ok. I will just skip my turn now.")
        
        # Ask for the next command.
        battle.battleAI.commandOppIndex = 1 
        battle.battleAI.commandIndex = 1 
      })
      
      # Skip turn for the player
      BattleScripting.set("command1", Proc.new { |battle, idxBattler| 
        # Nada. 
      })
      
      # Force the switch for the opponent
      BattleScripting.set("commandOpp1", Proc.new { |battle, idxBattler| 
        # Preparation.
        enemies = []
        party = battle.pbParty(idxBattler)
        party.each_with_index do |_p,i|
          enemies.push(i) if battle.pbCanSwitchLax?(idxBattler,i)
        end
        if enemies.length > 0
          # Find the Pokémon with the Soul-Link 
          soullink = -1 
          enemies.each do |i|
            pkmn = party[i]
            if pkmn.item == PBItems::SOULLINK
              soullink = i 
              break
            end 
          end 
          raise _INTL("No Soul-Link user") if soullink == -1
          battle.pbRegisterSwitch(idxBattler,soullink)
        else 
          raise _INTL("No Enemy found in party!")
        end 
      })
      
      # Now ask what to do.
      BattleScripting.set("turnStart1", Proc.new { |battle| 
        
        DialogueModule.scDisplayMessage(battle, 0, 
          "\\SC[Rachel]Now, what do I do?",
          "\\SC[Player]You need to toggle the Assistance, just right now.",
          "\\SC[Player]Choose which Pokémon to use.",
          "\\SC[Rachel]Ok! And then?",
          "\\SC[Player]Then choose any move like you normally would, then you'll have to choose the move of the Assistance later.",
          "\\SC[Rachel]Alright!",
          "\\SC[Player]You will likely knock out my Pokémon, so I will switch.",
          "\\SC[Player]I need this one for later."
        )
        
        battle.battleAI.commandOppIndex = 2
        battle.battleAI.commandIndex = 2
      })
      
      # Trigger the Assistance.
      BattleScripting.set("commandOpp2", Proc.new { |battle, idxBattler| 
        battle.pbRegisterAssistance(idxBattler)
        battle.battleAI.pbChooseMoves(idxBattler)
      })
      
      # Force the switch for the player
      BattleScripting.set("command2", Proc.new { |battle, idxBattler| 
        # Preparation.
        battle.pbPartyScreen(idxBattler,true,false,true)
      })
      
      # Now ask what to do.
      BattleScripting.set("turnStart2", Proc.new { |battle| 
        $game_switches[NO_ASSISTANCE] = false
        DialogueModule.scDisplayMessage(battle, 0, 
          "\\SC[Rachel]Yeeeeeees!",
          "\\SC[Rachel]That was awesome!",
          "\\SC[Rachel]I'm going to use it every time!",
          "\\SC[Player]I'm glad you like it!",
          "\\SC[Player]But now, I need to make sure you understand it.",
          "\\SC[Player]Explain me how to use the Assistance.",
          "\\SC[Rachel]Ok!!",
          "\\SC[Rachel]So, first, you need a Pokémon with the Soul-Link."
          )
        if battle.battlers[0].item != PBItems::SOULLINK
          battle.battleAI.commandIndex = 3
          battle.battleAI.commandOppIndex = 3
          SCVar.set(:GeneralTemp, 3)
          DialogueModule.scDisplayMessage(battle, 0, 
            "\\SC[Rachel]Oh, you don't! Switch to a Pokémon with the Soul-Link!",
            "\\SC[Rachel]I will skip my turn."
            )
        else 
          battle.battleAI.commandIndex = 4
          SCVar.set(:GeneralTemp, 4)
          DialogueModule.scDisplayMessage(battle, 0, 
            "\\SC[Rachel]Oh, you do!",
            "\\SC[Rachel]Now press the Z button to trigger the Assistance!"
            )
        end 
        # battle.decision = 1
        # battle.pbEndOfBattle
      })
      
      # Switch back the first Pokémon. 
      BattleScripting.set("command3", Proc.new { |battle, idxBattler| 
        # Preparation.
        battle.scene.pbPartyScreen(idxBattler,false) { |idxParty,partyScene|
          next false if !battle.pbCanSwitchLax?(idxBattler,idxParty,partyScene)
          next false if idxParty<0
          
          if battle.pbParty(idxBattler)[idxParty].item != PBItems::SOULLINK
            battle.pbDisplay(_INTL("Choose a Pokémon with the Soul-Link."))
            next false
          end 
          
          next false if !battle.pbRegisterSwitch(idxBattler,idxParty)
          next true
        }
      })
      
      # Skip turn if the player has to switch.
      BattleScripting.set("commandOpp3", Proc.new { |battle, idxBattler| 
        # Nada 
      })
      
      # After switch
      BattleScripting.set("turnEnd2", Proc.new { |battle| 
        if SCVar.get(:GeneralTemp) == 3
          # The previous turn, the player switched.
          battle.battleAI.commandIndex = 4
          DialogueModule.scDisplayMessage(battle, 0, 
            "\\SC[Rachel]Now that you have a Pokémon with the Soul-Link, press the Z button to trigger the Assistance!"
            )
        end 
      })
      
      # Force use of assistance.
      BattleScripting.set("command4", Proc.new { |battle, idxBattler| 
        battle.scene.pbFightMenu(idxBattler, false, false, false, false, true) { |cmd|
          case cmd
          when -6   # Assistance 
            if !battle.pbRegisteredAssistance?(idxBattler)
              DialogueModule.scDisplayMessage(battle, 0,
                _INTL("\\SC[Rachel]Now choose a Pokémon to assist {1}!", 
                  battle.battlers[idxBattler].pbThis(false))
                )
              battle.pbToggleRegisteredAssistance(idxBattler)
              DialogueModule.scDisplayMessage(battle, 0,
                "\\SC[Rachel]Now choose a move to use!",
                _INTL("\\SC[Rachel]You will be asked later what move the Assistance will use!", 
                  battle.battlers[idxBattler].pbThis)
                )
            else 
              DialogueModule.scDisplayMessage(battle, 0,
                "\\SC[Rachel]Do not cancel the Assistance, I'm trying to explain you how it works!"
                )
            end
            next false 
          else
            if !battle.pbRegisteredAssistance?(idxBattler)
              DialogueModule.scDisplayMessage(battle, 0,
                "\\SC[Rachel]Press Z to trigger the Assistance!"
                )
              next false
            end 
            next false if cmd<0 || !battle.battlers[idxBattler].moves[cmd] ||
                                    battle.battlers[idxBattler].moves[cmd].id<=0
            next false if !battle.pbRegisterMove(idxBattler,cmd)
            next false if !battle.singleBattle? &&
               !battle.pbChooseTarget(battle.battlers[idxBattler],battle.battlers[idxBattler].moves[cmd])
            ret = true
          end
          next true
        }
      })
      
      # After Assistance comment
      BattleScripting.set("assistAfter", Proc.new { |battle, user| 
          ret = false
          trainer = 0 
          battle.scene.pbShowOpponent(trainer)
          battle.scene.disappearDatabox
          battle.scene.sprites["messageWindow"].text = ""
          
          # Text.
          pbMessage("\\SC[Player]Unlike Z-Moves or Dynamax, you can use Assistance several times in a battle.")
          pbMessage(_INTL("\\SC[Player]You need to wait {1} turns before re-using it.", ASSISTANCE_RELOAD_DURATION))
          pbMessage("\\SC[Rachel]This is great!")
          pbMessage("\\SC[Player]So you can use and you can explain, seems to me that you understand Assistance!")
          pbMessage("\\SC[Rachel]Thank you Senpai!")
          pbMessage("\\SC[Player]...")
          ret = pbConfirmMessage("\\SC[Rachel]Do you wish to continue the battle?")
          
          if ret 
            pbMessage("\\SC[Rachel]I'll do my best!")
            
            # Remove the Opponent
            battle.scene.pbHideOpponen2(trainer)
            battle.scene.appearDatabox
          else 
            pbMessage("\\SC[Rachel]As you wish!")
            battle.decision = 5 # Draw 
            # battle.pbEndOfBattle
          end 
      })
      
      # End speech
      BattleScripting.set("endspeech", "You are the strongest.")
      
      BattleScripting.set("loss", Proc.new { |battle| 
        if battle.decision == 5
          # Draw (prematurely stopped)
          DialogueModule.scDisplayMessage(battle, 0, 
            "Ok, I have some work today.",
            "So do you, boss!"
          )
        else 
          # Loss
          DialogueModule.scDisplayMessage(battle, 0, 
            "Admit it, you let me win!",
            "Ok, I have some work today.",
            "So do you, boss!"
          )
        end 
      })
    end 
  end 
  
  
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

