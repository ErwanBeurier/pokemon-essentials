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