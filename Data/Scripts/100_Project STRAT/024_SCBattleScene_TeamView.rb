################################################################################
# SCBattleScene_TeamView
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script contains the implementation of the access to the Party Screen of 
# the opponent. 
################################################################################

class PokeBattle_Scene
  def pbOppPartyScreen(idxBattler)
    # Fade out and hide all sprites
    
    # Get the opponent party:
    idxBattler = @battle.pbGetOpposingIndicesInOrder(idxBattler)[0]
    return false if !idxBattler
    
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Your opponent's team."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Your opponent's team."))
      idxParty = switchScreen.pbChoosePokemon
      if idxParty<0
        break
      end
      # # Choose a command for the selected Pokémon
      # cmdSwitch  = -1
      # cmdSummary = -1
      # commands = []
      # commands[cmdSwitch  = commands.length] = _INTL("Switch In") if modParty[idxParty].able?
      # commands[cmdSummary = commands.length] = _INTL("Summary")
      # commands[commands.length]              = _INTL("Cancel")
      # command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      # if cmdSwitch>=0 && command==cmdSwitch        # Switch In
        # idxPartyRet = -1
        # partyPos.each_with_index do |pos,i|
          # next if pos!=idxParty+partyStart
          # idxPartyRet = i
          # break
        # end
        # break if yield idxPartyRet, switchScreen
      # elsif cmdSummary>=0 && command==cmdSummary   # Summary
        # scene.pbSummary(idxParty,true)
      # end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
    return false 
  end
end 

class PokeBattle_Battle
  def pbOppPartyScreen(idxBattler)
    return @scene.pbOppPartyScreen(idxBattler)
  end 
end 

# Team preview 

def scEntryScreen(number)
  retval = false
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    ret = screen.scPokemonMultipleEntryScreenEx(number)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret!=nil && ret.length>0)
  }
  return retval
end

class PokemonPartyScreen
  def scPokemonMultipleEntryScreenEx(number)
    annot = []
    statuses = [1, 1, 1, 1, 1, 1]
    ordinals = [
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH")
    ]
    return nil if !trainerPartyIsValid
    ret = nil
    addedEntry = false
    for i in 0...@party.length
      statuses[i] = 1
    end
    for i in 0...@party.length
      annot[i] = ordinals[statuses[i]]
    end
    @scene.pbStartScene(@party,_INTL("Choose Pokémon and confirm."),annot,true)
    loop do
      realorder = []
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]] = i+3
      end
      for i in 0...@party.length
        annot[i] = ordinals[statuses[i]]
      end
      @scene.pbAnnotate(annot)
      if realorder.length==number && addedEntry
        @scene.pbSelect(6)
      end
      @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      pkmnid = @scene.pbChoosePokemon
      addedEntry = false
      if pkmnid==6   # Confirm was chosen
        ret = []
        for i in realorder; ret.push(@party[i]); end
        error = []
        pbDisplay(error[0])
        ret = nil
      end
      break if pkmnid<0   # Cancelled
      cmdEntry    = -1
      cmdNoEntry  = -1
      cmdSummary  = -1
      cmdOppParty = -1
      commands = []
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry = commands.length]   = _INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry = commands.length] = _INTL("No Entry")
      end
      pkmn = @party[pkmnid]
      commands[cmdSummary = commands.length]   = _INTL("Summary")
      commands[cmdOppParty = commands.length]  = _INTL("Opp. party")
      commands[commands.length]                = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=number && number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",number))
        else
          statuses[pkmnid] = realorder.length+3
          addedEntry = true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid] = 1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      end
    end
    @scene.pbEndScene
    return ret
  end
end 