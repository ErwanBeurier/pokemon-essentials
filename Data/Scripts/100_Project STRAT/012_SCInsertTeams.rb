################################################################################
# SCInsertTeams
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# This script inserts preset teams into the PC for narrative purposes. 
################################################################################


# Reads the database of Teams and inserts the team it finds. 
def scInsertTeamToStorage(tier, id)
  # trainerdata = pbLoadTrainer(PBTrainers::POKEMONTRAINER_Red, "Player", id)
  
  party = []
  team_name = "Unnamed"
  
  trainers = pbLoadTrainersData
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    thispartyid   = trainer[4]
    next if thistrainerid!=PBTrainers::POKEMONTRAINER_Red || name!="Player" || thispartyid!=id
    # LoseText will contain the name of the team. 
    team_name = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    
    # Load up each Pokémon in the trainer's party
    for poke in trainer[3]
      fspecies = pbGetFSpeciesFromForm(poke[TPSPECIES], (poke[TPFORM] ? poke[TPFORM] : 0))
      
      mvstdata = SCTB.initData(fspecies)
      
      mvstdata[SCMovesetsData::LEVEL] = poke[TPLEVEL]
      mvstdata[SCMovesetsData::ITEM] = poke[TPITEM] if poke[TPITEM]
      
      if poke[TPMOVES] && poke[TPMOVES].length>0
        for i in 0...poke[TPMOVES].length
          mvstdata[SCMovesetsData::MOVE1 + i] = poke[TPMOVES][i]
        end
      end
      
      mvstdata[SCMovesetsData::ABILITYINDEX] = (poke[TPABILITY] || 0)
      mvstdata[SCMovesetsData::ABILITY] = SCTB.getAbilityFromIndex(mvstdata[SCMovesetsData::ABILITYINDEX], fspecies)
      
      mvstdata[SCMovesetsData::GENDER] = (poke[TPGENDER]) ? poke[TPGENDER] : ($Trainer.female?) ? 1 : 0
      mvstdata[SCMovesetsData::SHINY] = (poke[TPSHINY] == true)
      mvstdata[SCMovesetsData::NATURE] = poke[TPNATURE] if poke[TPNATURE]
      
      for i in 0...6
        if poke[TPIV] && poke[TPIV].length == 6
          mvstdata[SCMovesetsData::IV][i] = poke[TPIV][i]
        end
        if poke[TPEV] && poke[TPEV].length == 6 
          mvstdata[SCMovesetsData::EV][i] = poke[TPEV][i]
        end
      end
      
      mvstdata[SCMovesetsData::HAPPINESS] = poke[TPHAPPINESS] if poke[TPHAPPINESS]
      mvstdata[SCMovesetsData::NICKNAME] = poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      mvstdata[SCMovesetsData::BALL] = poke[TPBALL] if poke[TPBALL]
      mvstdata[SCMovesetsData::DYNAMAXLEVEL] = poke[TPDYNAMAX] if poke[TPDYNAMAX]
      mvstdata[SCMovesetsData::GMAXFACTOR] = poke[TPGMAX] if poke[TPGMAX]
      
      party.push(mvstdata)
    end
    
    break 
  end
  
	scTeamStorage.addTeam(team_name, party, tier)
end 



# For narrative reasons, force the player to use a specific team.
def scForceTeam(index, msg)
  index = scTeamStorage.lastNonEmptyIndex if !index
  
  SCSwitch.set(SCSwitch::ForcedTeam, true)
  
  SCVar.set(SCVar::ForcedTeamIndex, index)
  SCVar.set(SCVar::ForcedTeamMessage, msg)
end 


# Unforce the team.
def scUnforceTeam
  SCSwitch.set(SCSwitch::ForcedTeam, false)
  
  SCVar.set(SCVar::ForcedTeamIndex, -1)
  SCVar.set(SCVar::ForcedTeamMessage, "")
end 




#==============================================================================
# DEPRECATED.
# Hard-coded way of inserting teams.
#==============================================================================
# Following this scheme: 
# [speciesid, # 		0 = Species 
# 1, # 					1 = Min level (not used)
# 120, # 				2 = Level 
# -1, # 				3 = Gender 
# 0, # 					4 = Ability 
# -1, # 				5 = Items 
# -1, # 				6 = Nature 
# "", # 				7 = Nickname 
# Array.new(6, 31), # 	8 = IVs 
# Array.new(4, -1), # 	9 = moves 
# Array.new(6, 0), # 	10 = EVs 
# false, # 				11 = Shiny
# form_stuff]  # 		12 = Form (unimplemented)



def scNewMovesetData(pokeid, ability, nature, item, move1, move2, move3, move4, evs)
	pklist = SCTB.initData(pokeid)
  
  # Ability
  ab = SCTB.getAbilityIndex(ability, pokeid)
  pklist[SCMovesetsData::ABILITY] = ability
  pklist[SCMovesetsData::ABILITYINDEX] = ab
  
  # Nature 
  pklist[SCMovesetsData::NATURE] = nature
  
  # Item 
  pklist[SCMovesetsData::ITEM] = item 
  
  # Moves 
  pklist[SCMovesetsData::MOVE1] = move1
  pklist[SCMovesetsData::MOVE2] = move2
  pklist[SCMovesetsData::MOVE3] = move3
  pklist[SCMovesetsData::MOVE4] = move4
  
  # Stats
  pklist[SCMovesetsData::EV] = evs.clone
	
	return pklist 
end 


def scInsertTeam0001
	team = []
	
	# Big threat #1
	volcarona = scNewMovesetData(
					PBSpecies::VOLCARONA, 2, 
					PBNatures::TIMID, 
					PBItems::HEAVYDUTYBOOTS, 
					PBMoves::QUIVERDANCE, 
					PBMoves::FLAMETHROWER, # Should suffice to kill everything. 
					PBMoves::HIDDENPOWERGROUND, # For Delta Volcarona
					PBMoves::ROOST,
					[6,0,0,252,252,0])
	team.push(volcarona)
	
	# Big threat #2 
	deltavolcarona = scNewMovesetData(
					PBSpecies::DELTAVOLCARONA, 0,
					PBNatures::TIMID,
					PBItems::CHOICESPECS,
					PBMoves::DARKPULSE,
					PBMoves::FLAMETHROWER, 
					PBMoves::ANCIENTPOWER, # For Volcarona
					PBMoves::EARTHPOWER, # For Delta Volcarona 
					[6,0,0,252,252,0])
	team.push(deltavolcarona)
	
	
	# Lead, sets the stealth rocks. 
	wormadam = scNewMovesetData(
					PBSpecies::WORMADAM, 0,
					PBNatures::CALM,
					PBItems::FOCUSSASH,
					PBMoves::FLASHCANNON, 
					PBMoves::TOXIC, 
					PBMoves::STEALTHROCK,
					PBMoves::SUCKERPUNCH, 
					[252,0,0,0,6,252])
	wormadam[12] = [2, "Thrash"] # Steel form 
	team.push(wormadam)
	
	
	# To handle volcarona 
	masquerain = scNewMovesetData(
					PBSpecies::MASQUERAINSC1, 2,
					PBNatures::CALM,
					PBItems::DAMPROCK,
					PBMoves::RAINDANCE, # Anti-volcarona
					PBMoves::HYDROPUMP, 
					PBMoves::BUGBUZZ, 
					PBMoves::STICKYWEB, # Anti-volcarona + delta volcarona 
					[252,0,0,0,6,252]) # Handle damage
	team.push(masquerain)
	
	
	# To handle delta volcarona
	butterfree = scNewMovesetData(
					PBSpecies::BUTTERFREESC2, 2,
					PBNatures::CALM,
					PBItems::LEFTOVERS,
					PBMoves::DRAININGKISS, 
					PBMoves::HIDDENPOWERGROUND, 
					PBMoves::QUIVERDANCE,
					PBMoves::ROOST, 
					[252,0,0,0,6,252]) # Handle damage
	team.push(butterfree)
	
	
	# For fun 
	frosmoth = scNewMovesetData(
					PBSpecies::FROSMOTH, 2,
					PBNatures::MODEST,
					PBItems::LEFTOVERS,
					PBMoves::ICEBEAM, 
					PBMoves::HURRICANE, 
					PBMoves::HIDDENPOWERFIRE,
					PBMoves::QUIVERDANCE, 
					[252,0,0,6,252,0]) # Handle damage
	team.push(frosmoth)
	
	
	scTeamStorage.addTeam("Butterflies", team, "BUTTERFLIES")
end 




















