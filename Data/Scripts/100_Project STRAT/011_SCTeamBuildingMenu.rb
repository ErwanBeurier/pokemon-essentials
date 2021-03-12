################################################################################
# 								Team Builder
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
#
# By StCooler
# Based on the GTS System by Hansiec. 
# This script is derived from an old version of the GTS script. As of 2020-11-28, 
# the current version is 3.0.0, but my script was made from version 2.0.0. 
# 
# Contents:
# This script makes a Menu from a team builder. 
# It contains NO online stuff related to GTS. I only needed the menu UI.
#------------------------------------------------------------------------------
# SCTB contains many functions that are useful in the main class; mostly, any 
# list to choose from.
#------------------------------------------------------------------------------
# SCTB_Button is a class used for making buttons.
#------------------------------------------------------------------------------
# SCTeamViewer is the UI to modify/access the teams in the Team Storage.
#------------------------------------------------------------------------------
# SCTeamBuilder is the first UI to see the whole team + nicknames. Also displays 
# the validity of the team for the current tier.
#------------------------------------------------------------------------------
# SCWantedDataComplete is the UI that allows to chose/modify a specific Pokémon 
# in the team.
#------------------------------------------------------------------------------
# SCBaseStats, SCWantedDataIVs and SCWantedDataEVs are deprecated. 
#------------------------------------------------------------------------------
# SCWantedDataStats is the UI to access the base stats of the current Pokémon, 
# and access/modify the EV/IV of the Pokémon.
################################################################################
# Credits: 
#
# This UI system is based on the GTS System (Version 2.0.0) by Hansiec.
################################################################################



module SCTB
	##### Main Method
	def self.open
		$scene = Scene_SCTB.new
		scene = $scene
		scene.main
	end
	
	
	
	def self.orderSpecies(speciesList)
		# Brings up all species of pokemon of the given index of the given sort mode
		commands=[]
		
		for i in speciesList
			commands.push(_INTL("{1}: {2}", i, PBSpecies.getName(i)))# if i > 0
		end
		
		if commands.length == 0
			pbMessage(_INTL("No species found."))
			return [0, 0]
		end
		
		c = pbMessage("Select a species.",commands, -1, nil, 0)
		if c == -1
			return [-1, c]
		end 
		x = speciesList[c]
		
		if x.is_a?(Array)
			x = x[0]
		end
		
		return [x, c]
	end
	
	
	
	def self.filterSpeciesByType(tier, type)
		# Returns a dictionary of the species in the tier with type "type".
		# "type" can be nil, meaning there is no filter. 
		
		all_species = tier.alphabeticSpecies()
		# pbMessage(_INTL("length: {1}", all_species.keys.length))
		return all_species if type == nil 
		
		filtered_dict = {}
		
		for letter in all_species.keys
			for sp in all_species[letter]
				if scSpeciesHasType(sp, -1, type)
					if filtered_dict.keys.include?(letter)
						filtered_dict[letter].push(sp)
					else 
						filtered_dict[letter] = [sp]
					end 
				end 
			end
		end 
		
		return filtered_dict
	end 
  
  
  
  def self.filterSpeciesByRole(tier, role)
		all_species = tier.alphabeticSpecies()
		# pbMessage(_INTL("length: {1}", all_species.keys.length))
		return all_species if role == nil 
		
		filtered_dict = {}
    the_roles = scLoadRolesToPoke
    the_roles = the_roles[role]
    
    return all_species if !the_roles
		
		for letter in all_species.keys
			for sp in all_species[letter]
				if the_roles.include?(sp)
					if filtered_dict.keys.include?(letter)
						filtered_dict[letter].push(sp)
					else 
						filtered_dict[letter] = [sp]
					end 
				end 
			end
		end 
		
		return filtered_dict
  end 
  
  
  
  def self.filterSpeciesByMove(tier, move)
		all_species = tier.alphabeticSpecies()
		# pbMessage(_INTL("length: {1}", all_species.keys.length))
		return all_species if move == nil 
		
		filtered_dict = {}
    sclearnedtr = scLoadLearnedTranspose
		sclearnedtr = sclearnedtr[move]
    
    return all_species if !sclearnedtr
    
		for letter in all_species.keys
			for sp in all_species[letter]
				if sclearnedtr.include?(sp)
					if filtered_dict.keys.include?(letter)
						filtered_dict[letter].push(sp)
					else 
						filtered_dict[letter] = [sp]
					end 
				end 
			end
		end 
		
		return filtered_dict
  end 
  
  
  def self.filterSpeciesByTypeMoveRole(tier, type, move, role)
		all_species = tier.alphabeticSpecies()
		# pbMessage(_INTL("length: {1}", all_species.keys.length))
		return all_species if !type && !move && !role
		
		filtered_dict = {}
    
    sclearnedtr = scLoadLearnedTranspose
		sclearnedtr = sclearnedtr[move] rescue nil 
    
    the_roles = scLoadRolesToPoke
    the_roles = the_roles[role] rescue nil 
    
    num_poke = 0 
    
		for letter in all_species.keys
			for sp in all_species[letter]
        check_type = true 
        check_type = scSpeciesHasType(sp, -1, type) if type 
        
        check_role = true 
        check_role = the_roles.include?(sp) if the_roles
        
        check_move = true 
        check_move = sclearnedtr.include?(sp) if sclearnedtr
        
				if check_type && check_role && check_move
          num_poke += 1
					if filtered_dict.keys.include?(letter)
						filtered_dict[letter].push(sp)
					else 
						filtered_dict[letter] = [sp]
					end 
				end 
			end
		end 
    
    if num_poke == 0
      raise _INTL("No Pokémon found for this set of filters.")
		end 
		return filtered_dict
  end 
	
	
	
	def self.shortTierSpecies(tier, choose_moveset)
		# Shows a menu displaying all the Pokémon in the tier, provided the tier is "small" enough. 
		commands = []
    
    commands.push("Choose moveset") if choose_moveset
		
		# Distinguish between frequent/rare/allowed Pokémon. 
		for sp in tier.frequent_pkmns
			commands.push(_INTL("{1}: {2}", sp, PBSpecies.getName(sp)))
		end 
		
		i_rare = commands.length 
		
		for sp in tier.rare_pkmns
			commands.push(_INTL("{1}: {2}", sp, PBSpecies.getName(sp)))
		end 
		
		i_allowed = commands.length 
		
		for sp in tier.allowed_pkmns
			commands.push(_INTL("{1}: {2}", sp, PBSpecies.getName(sp)))
		end 
		
		c = pbMessage("Select a species.",commands, -1, nil, 0)
		
		if c == -1
			return [nil, -1]
    elsif c == 0 && choose_moveset
      return [-2, 1] # 
		elsif c < i_rare
			# Chose a frequent species.
			x = tier.frequent_pkmns[c]
			return [x, c]
			
		elsif c < i_allowed
			# Chose a rare species. 
			x = tier.rare_pkmns[c - i_rare]
			return [x, c]
		end 
		
		# Chose an allowed species. 
		x = tier.allowed_pkmns[c-i_allowed]
		return [x, c]
	end 
	
	
  
  def self.personalItems(speciesid)
    personal_items = scLoadPersonalItems(speciesid)
    
    return [] if !personal_items
    
    personal_items_filtered = []
    personal_items.each { |pi|
      personal_items_filtered.push(pi[SCFormData::OPTITEM]) if pi[SCFormData::OPTITEM]
      personal_items_filtered.push(pi[SCFormData::REQITEM]) if pi[SCFormData::REQITEM]
    }
    
    return personal_items_filtered
  end 
  
  
  
	def self.itemsMenu(speciesid, pokemon)
		# Generates a two-step menu in order to choose an item for the given 
		# POkémon. 
		# speciesid = the id of the Pokémon.
		# Four types of menu: 
		# - Useful items = the items commonly found in strategic Pokemon.
		# - Berries = all berries. 
		# - Arceus plates 
		# - Other items = other items that could be used.
		# - If the species can hold a Mega-Stone or some personal item (for 
		# example, thick bone for Marowak), then another menu will be added 
		# with the personal items. 
		
		# The lists of item ids. 
		useful_items = [PBItems::LEFTOVERS,
			PBItems::LIFEORB,
			PBItems::HEAVYDUTYBOOTS,
			PBItems::BLACKSLUDGE,
			PBItems::ROCKYHELMET,
			PBItems::CHOICEBAND,
			PBItems::CHOICESPECS,
			PBItems::CHOICESCARF,
			PBItems::ASSAULTVEST,
			PBItems::FOCUSSASH,
			PBItems::AIRBALLOON,
			PBItems::HEATROCK,
			PBItems::DAMPROCK,
			PBItems::SMOOTHROCK,
			PBItems::ICYROCK,
			PBItems::LIGHTCLAY,
			PBItems::FLAMEORB,
			PBItems::WEAKNESSPOLICY,
			PBItems::EJECTBUTTON,
			PBItems::REDCARD,
			PBItems::EVIOLITE]
		
		berries = [
			PBItems::CHERIBERRY,
			PBItems::CHESTOBERRY,
			PBItems::PECHABERRY,
			PBItems::RAWSTBERRY,
			PBItems::ASPEARBERRY,
			PBItems::LEPPABERRY,
			PBItems::ORANBERRY,
			PBItems::PERSIMBERRY,
			PBItems::LUMBERRY,
			PBItems::SITRUSBERRY,
			PBItems::FIGYBERRY,
			PBItems::WIKIBERRY,
			PBItems::MAGOBERRY,
			PBItems::AGUAVBERRY,
			PBItems::IAPAPABERRY,
			PBItems::RAZZBERRY,
			PBItems::BLUKBERRY,
			PBItems::NANABBERRY,
			PBItems::WEPEARBERRY,
			PBItems::PINAPBERRY,
			PBItems::POMEGBERRY,
			PBItems::KELPSYBERRY,
			PBItems::QUALOTBERRY,
			PBItems::HONDEWBERRY,
			PBItems::GREPABERRY,
			PBItems::TAMATOBERRY,
			PBItems::CORNNBERRY,
			PBItems::MAGOSTBERRY,
			PBItems::RABUTABERRY,
			PBItems::NOMELBERRY,
			PBItems::SPELONBERRY,
			PBItems::PAMTREBERRY,
			PBItems::WATMELBERRY,
			PBItems::DURINBERRY,
			PBItems::BELUEBERRY,
			PBItems::OCCABERRY,
			PBItems::PASSHOBERRY,
			PBItems::WACANBERRY,
			PBItems::RINDOBERRY,
			PBItems::YACHEBERRY,
			PBItems::CHOPLEBERRY,
			PBItems::KEBIABERRY,
			PBItems::SHUCABERRY,
			PBItems::COBABERRY,
			PBItems::PAYAPABERRY,
			PBItems::TANGABERRY,
			PBItems::CHARTIBERRY,
			PBItems::KASIBBERRY,
			PBItems::HABANBERRY,
			PBItems::COLBURBERRY,
			PBItems::BABIRIBERRY,
			PBItems::CHILANBERRY,
			PBItems::LIECHIBERRY,
			PBItems::GANLONBERRY,
			PBItems::SALACBERRY,
			PBItems::PETAYABERRY,
			PBItems::APICOTBERRY,
			PBItems::LANSATBERRY,
			PBItems::STARFBERRY,
			PBItems::ENIGMABERRY,
			PBItems::MICLEBERRY,
			PBItems::CUSTAPBERRY,
			PBItems::JABOCABERRY,
			PBItems::ROWAPBERRY,
			PBItems::ROSELIBERRY,
			PBItems::KEEBERRY,
			PBItems::MARANGABERRY]

		arceus_plates = [
			PBItems::FLAMEPLATE,
			PBItems::SPLASHPLATE,
			PBItems::ZAPPLATE,
			PBItems::MEADOWPLATE,
			PBItems::ICICLEPLATE,
			PBItems::FISTPLATE,
			PBItems::TOXICPLATE,
			PBItems::EARTHPLATE,
			PBItems::SKYPLATE,
			PBItems::MINDPLATE,
			PBItems::INSECTPLATE,
			PBItems::STONEPLATE,
			PBItems::SPOOKYPLATE,
			PBItems::DRACOPLATE,
			PBItems::DREADPLATE,
			PBItems::IRONPLATE,
			PBItems::PIXIEPLATE]
		
		other_items = [PBItems::SHELLBELL,
			PBItems::FIREGEM,
			PBItems::WATERGEM,
			PBItems::ELECTRICGEM,
			PBItems::GRASSGEM,
			PBItems::ICEGEM,
			PBItems::FIGHTINGGEM,
			PBItems::POISONGEM,
			PBItems::GROUNDGEM,
			PBItems::FLYINGGEM,
			PBItems::PSYCHICGEM,
			PBItems::BUGGEM,
			PBItems::ROCKGEM,
			PBItems::GHOSTGEM,
			PBItems::DRAGONGEM,
			PBItems::DARKGEM,
			PBItems::STEELGEM,
			PBItems::NORMALGEM,
			PBItems::FAIRYGEM,
			PBItems::GRIPCLAW,
			PBItems::BIGROOT,
			PBItems::WHITEHERB,
			PBItems::EXPERTBELT,
			PBItems::METRONOME,
			PBItems::MUSCLEBAND,
			PBItems::WISEGLASSES,
			PBItems::RAZORCLAW,
			PBItems::SCOPELENS,
			PBItems::WIDELENS,
			PBItems::ZOOMLENS,
			PBItems::KINGSROCK,
			PBItems::RAZORFANG,
			PBItems::QUICKCLAW,
			PBItems::FOCUSBAND,
			PBItems::TOXICORB,
			PBItems::SHEDSHELL,
			PBItems::RINGTARGET,
			PBItems::SEAINCENSE,
			PBItems::WAVEINCENSE,
			PBItems::ROSEINCENSE,
			PBItems::ODDINCENSE,
			PBItems::ROCKINCENSE,
			PBItems::CHARCOAL,
			PBItems::MYSTICWATER,
			PBItems::MAGNET,
			PBItems::MIRACLESEED,
			PBItems::NEVERMELTICE,
			PBItems::BLACKBELT,
			PBItems::POISONBARB,
			PBItems::SOFTSAND,
			PBItems::SHARPBEAK,
			PBItems::TWISTEDSPOON,
			PBItems::SILVERPOWDER,
			PBItems::HARDSTONE,
			PBItems::SPELLTAG,
			PBItems::DRAGONFANG,
			PBItems::BLACKGLASSES,
			PBItems::METALCOAT,
			PBItems::SILKSCARF,
			PBItems::ADRENALINEORB,
			PBItems::THROATSPRAY,
			PBItems::UTILITYUMBRELLA]
		
		sc_normal_type_items = [
			# Normal maxer 
			PBItems::SCNORMALMAXER,
			# Efficiency crystals
			PBItems::SCNORMALCRYSTAL,
			PBItems::SCELECTRICCRYSTAL,
			PBItems::SCFIGHTINGCRYSTAL,
			PBItems::SCFLYINGCRYSTAL,
			PBItems::SCROCKCRYSTAL,
			PBItems::SCDARKCRYSTAL,
			PBItems::SCFIRECRYSTAL,
			PBItems::SCGRASSCRYSTAL,
			PBItems::SCPOISONCRYSTAL,
			PBItems::SCPSYCHICCRYSTAL,
			PBItems::SCSTEELCRYSTAL,
			PBItems::SCWATERCRYSTAL,
			PBItems::SCICECRYSTAL,
			PBItems::SCGROUNDCRYSTAL,
			PBItems::SCBUGCRYSTAL,
			PBItems::SCDRAGONCRYSTAL,
			PBItems::SCFAIRYCRYSTAL,
			PBItems::SCGHOSTCRYSTAL,
			# Coats. 
			PBItems::SCELEMENTALCOAT,
			PBItems::SCMINERALCOAT,
			PBItems::SCSWAMPCOAT,
			PBItems::SCFANTASYCOAT,
			PBItems::SCMINDCOAT,
			PBItems::SCMATERIALCOAT,
			PBItems::SCFORESTCOAT,
			PBItems::SCDEMONICCOAT,
			PBItems::SCAQUATICCOAT
			]
		
		personal_items = self.personalItems(speciesid)
		
    zcrystals = scGetFittingZCrystals(pokemon, false)
    
		# The list of item names (for the menu). 
		useful_items_cmds = []
		berries_cmds = []
		arceus_plates_cmds = []
		other_items_cmds = []
		personal_items_cmds = []
		sc_normal_type_items_cmds = [] 
    zcrystals_cmds = []
		
		for i in useful_items
			useful_items_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in berries
			berries_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in arceus_plates
			arceus_plates_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in other_items
			other_items_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in personal_items
			personal_items_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in sc_normal_type_items
			sc_normal_type_items_cmds.push("#{PBItems.getName(i)}")
		end 
		for i in zcrystals_cmds
			zcrystals_cmds.push("#{PBItems.getName(i)}")
		end 
		
		
		# Then generate the first menu (choose the category of items). 
		options = ["Useful items", "Berries", "Arceus plates", "Other", "Normal-type items", "Z-Crystals"]
		
		if not personal_items.empty?
			options.push("Personal items")
		end 
		op = 0 
		
		while op != -1 
			# op == -1 => cancel. 
			
			op = pbMessage("What kind of item?",options, -1, nil, 0)
			it = -1 
			
			case op
			when 0
				# Useful items
				it = pbMessage("What item?",useful_items_cmds, -1, nil, 0)
			when 1
				# Berries 
				it = pbMessage("What berry?",berries_cmds, -1, nil, 0)
			when 2
				# Arceus plates 
				it = pbMessage("What plate?",arceus_plates_cmds, -1, nil, 0)
			when 3
				# Other items 
				it = pbMessage("What item?",other_items_cmds, -1, nil, 0)
			when 4
				# Normal-type items 
				it = pbMessage("What item?",sc_normal_type_items_cmds, -1, nil, 0)
			when 5
				# Z-Crystals 
				it = pbMessage("What crystal?",zcrystals_cmds, -1, nil, 0)
			when 6
				# Personal items
				if not personal_items.empty?
					it = pbMessage("What item?",personal_items_cmds, -1, nil, 0)
				else
					return -1 
				end 
			else 
				return -1 
			end 
			
			if it != -1
				case op 
				when 0
					return useful_items[it]
				when 1
					return berries[it]
				when 2
					return arceus_plates[it]
				when 3 
					return other_items[it]
				when 4
					return sc_normal_type_items[it]
				when 5
					return zcrystals[it]
				when 6
					return personal_items[it]
				end 
			end 
		end 
		
		return -1 # No item chosen. 
	end 
	
	
	
	def self.formList(speciesid)
		form_list = []
    formData = pbLoadFormToSpecies
    base_species = pbGetSpeciesFromFSpecies(speciesid)[0]
    
    return form_list if !formData[base_species] || formData[base_species].length < 2
    
    formData[base_species].each_index do |i|
      form_name = self.getFormName(base_species, i)
      # form_name = (i == 0 ? "Normal form" : form_name)
      form_list.push([i, form_name, base_species, pbGetFSpeciesFromForm(base_species, i)])
    end 
    
    return form_list
	end 
	
	
	
	def self.getFormName(speciesid, form)
		fspecies = pbGetFSpeciesFromForm(speciesid, form)
    formName = pbGetMessage(MessageTypes::FormNames,fspecies)
    formName = "Normal form" if formName == "" && form == 0
    # pbMessage(_INTL("Form name: \"{1}\"", formName))
    return formName
	end 
	
	
	
	def self.formMenu(speciesid)
		# Displays a hard-coded (yes) list of Pokémon with different forms, allowing to choose betwen forms. 
		# If the form has certain requirements, such as an item or ability, then the requirements are returned.
		
		form_list = self.formList(speciesid)
		required = SCFormData.newEmpty()
    
		if form_list.length < 2
			return required
		end 
		
    form_list_names = []
		
    form_list.each do |pair|
      form_list_names.push(pair[1])
    end 
    
		form = pbMessage("Give what form?",form_list_names, -1, nil, 0)
		
		if form == -1
			return required
		end 
		
    required[SCFormData::SPECIES] = form_list[form][3]
		required[SCFormData::BASESPECIES] = form_list[form][2]
		
    given_requirements = false 
    requiredData = scLoadPersonalItems(speciesid)
    
    if requiredData && requiredData.is_a?(Array)
      requiredData.each do |req|
        next if req[SCFormData::FORM] != form_list[form][0] 
        required = req 
        given_requirements = true 
      end 
    end 
    
    if !given_requirements
      required[SCFormData::FORM] = form_list[form][0]
      required[SCFormData::BASEFORM] = form_list[form][0]
      required[SCFormData::BASESPECIES] = form_list[form][3]
    end 
    
    required[SCFormData::FORMNAME] = form_list[form][1]
    
		return required
	end 
	
	
	
	def self.initData(species_stuff)
		# Returns a formatted list gathering all the information about a moveset. 
		# Takes into consideration the required stuff from SCTB.formMenu. 
    
    data = SCMovesetsData.newEmpty2(species_stuff)
    data[SCMovesetsData::LEVEL] = 120
    return data if !species_stuff
    
    reqs = scLoadFormRequirements(species_stuff)
    return data if !reqs
    
    reqs.each { |req|
      next if req[SCFormData::FORM] != data[SCMovesetsData::FORM]
      
      data[SCMovesetsData::BASEFORM] = req[SCFormData::BASEFORM] #if req[SCFormData::BASEFORM] != req[SCFormData::FORM]
      data[SCMovesetsData::BASESPECIES] = req[SCFormData::BASESPECIES]
      
      data[SCMovesetsData::ITEM] = req[SCFormData::REQITEM] if req[SCFormData::REQITEM]
      data[SCMovesetsData::MOVE1] = req[SCFormData::REQMOVE] if req[SCFormData::REQMOVE]
      data[SCMovesetsData::GENDER] = req[SCFormData::REQGENDER] if req[SCFormData::REQGENDER]
      
      if req[SCFormData::REQABILITY]
        data[SCMovesetsData::ABILITYINDEX] = self.getAbilityIndex(req[SCFormData::REQABILITY], species_stuff)
      end 
    }
    
		return data
	end 
	
	
	
	def self.getAbilitiesFromSpecies(speciesid)
    # Copied from PokeBattle_Pokemon.getAbilityList
    speciesid = pbGetSpeciesFromFSpecies(speciesid)
    formSimple = speciesid[1]
    speciesid = speciesid[0]
    
    ret = []
    abilities = pbGetSpeciesData(speciesid,formSimple,SpeciesAbilities)
    if abilities.is_a?(Array)
      abilities.each_with_index { |a,i| ret.push([a,i]) if a && a>0 }
    else
      ret.push([abilities,0]) if abilities>0
    end
    hiddenAbil = pbGetSpeciesData(speciesid,formSimple,SpeciesHiddenAbility)
    if hiddenAbil.is_a?(Array)
      hiddenAbil.each_with_index { |a,i| ret.push([a,i+2]) if a && a>0 }
    else
      ret.push([hiddenAbil,2]) if hiddenAbil>0
    end
    return ret
	end 
  
  
  
  def self.getAbilityIndex(ability, speciesid)
    ret = self.getAbilitiesFromSpecies(speciesid)
    
    for i in 0...ret.length
      if ret[i][0] == ability
        return ret[i][1]
      end 
    end 
    
    
    return nil 
  end 
  
  
  
  def self.getAbilityFromIndex(ab_i, speciesid)
    ret = self.getAbilitiesFromSpecies(speciesid)
    
    for i in 0...ret.length
      if ret[i][1] == ab_i
        return ret[i][0]
      end 
    end 
    
    return nil 
  end 
  
  
  
  def self.EVIVToStr(eviv)
    return eviv[0].to_s+"/"+eviv[1].to_s+"/"+eviv[2].to_s+"/"+eviv[4].to_s+"/"+eviv[5].to_s+"/"+eviv[3].to_s
  end 
  
  
  
  def self.oneValue(eviv, value)
    eviv.each { |ei|
      return ei if ei == value 
    }
    return nil
  end 
  
  
  
  def self.movesetMenu(speciesid, tier)
    # speciesid if typically a pk[SCMovesetsData::FSPECIES]
    movesetdata = scLoadMovesetsData
    
    
    mvst_commands = ["Cancel"]
    
    movesetdata[speciesid].each { |mvst|
      p = mvst[SCMovesetsData::PATTERN]
      mvst_commands.push(SCMovesetPatterns.getName(p))
    }
    
    m = pbMessage("Choose what moveset?",mvst_commands, 0, nil, 0)
    
    return nil if m == 0
    
    mvst = movesetdata[speciesid][m - 1]
    
    return nil if !mvst 
    
    pokemon = scGenerateMoveset(mvst, $Trainer, tier)
    return convertPartyToList([pokemon])[0]
  end 
end




################################################################################
# SCTB Scenes
# By Hansiec
# Scenes For SCTB
################################################################################

######## SCTB Buttons, A Basic options button for our SCTB System
# Note by StCooler: except for the indentation, I haven't changed anything here. 
class SCTB_Button < SpriteWrapper
	
	def initialize(x,y,name="",index=0,viewport=nil)
		super(viewport)
		@index=index
		@name=name
		@selected=false
		self.x=x
		self.y=y
		update
	end
	
	
	
	def dispose
		super
	end
	
	

	def refresh
		self.bitmap.dispose if self.bitmap
		self.bitmap = Bitmap.new("Graphics/Pictures/GTS/Options_bar")
		pbSetSystemFont(self.bitmap)
		textpos=[
			[@name,self.bitmap.width/2,1,2,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(self.bitmap,textpos)
	end
	
	
	
	def update
		refresh
		super
	end
	
end




###############################################################################
# SCTeamViewer
# 
# First class. 
# Displays all the teams in the PC. Click on a team to modify it. 
###############################################################################

class SCTeamViewer
	
	
	def initialize
		@valid = nil
		@exit = false
		
		# Index of the first displayed team (between 0 and scTeamStorage.maxIndex - 1)
		@index_upper = scTeamStorage.maxIndex - 2
		# Index of the last displayed team (should be @index_upper + 2)
		@index_lower = @index_upper + 2 
		
		# Index of the "selector" (between 0 and 2)
		@index = 0
	end
	
	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Teams",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
			#    ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
			#    Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
  
	
	
	def create_spriteset
		# Loads and seets the sprites. 
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
    
    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		# First three teams  
		
		for i in 0...3
			k = i.to_s
			kt = k+"t"
			ktt = k+"tt"
			
			@sprites[k] = IconSprite.new
			@sprites[k].setBitmap("Graphics/Pictures/GTS/tb_team_preview")
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= @sprites[k].bitmap.width / 2
			@sprites[k].y = 84 + i * 100

			# The text part 
			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 35)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y 
			
			# The team part. 
			for j in 0...6
				kttj = ktt + j.to_s
				@sprites[kttj] = IconSprite.new
				@sprites[kttj].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
					@sprites[k].bitmap.height - 35)
				@sprites[kttj].x = @sprites[k].x + j * 64
				@sprites[kttj].y = @sprites[k].y + 35
			end 
		end 
		
		
		bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		@sprites["selection_l"] = IconSprite.new
		# @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_l"].bitmap = Bitmap.new(16, 108)
		@sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		# @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
		@sprites["selection_l"].bitmap.blt(0, 108-23, bit, Rect.new(0, 16, 16, 32))

		@sprites["selection_r"] = IconSprite.new
		# @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_r"].bitmap = Bitmap.new(16, 108)
		@sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		# @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
		@sprites["selection_r"].bitmap.blt(0, 108-23, bit, Rect.new(16, 16, 32, 32))

		drawSelector
		drawWantedData
	end
	
	
	
	def drawSelector
		@sprites["selection_l"].x = @sprites["#{@index}"].x-2
		@sprites["selection_l"].y = @sprites["#{@index}"].y-2
		@sprites["selection_r"].x = @sprites["#{@index}"].x+
			@sprites["#{@index}"].bitmap.width-18
		@sprites["selection_r"].y = @sprites["#{@index}"].y-2
	end 
	
	
	
	def drawWantedData
		drawHeader
		
		for i in 0..2
			printTeam(i)
		end 		
	end
	
	
	
	def printTeam(displayed_index)
		# displayed_index should be 0, 1 or 2 
		
		k = displayed_index.to_s
		kt = k+"t"
		ktt = k+"tt"
		
		@sprites[kt].bitmap.clear
		
		s = "[" + scTeamStorage.tierAt(@index_upper + displayed_index) + "] "
		s += scTeamStorage.nameAt(@index_upper + displayed_index)
		
		pbSetSystemFont(@sprites[kt].bitmap)
		textpos=[
			[s, 35, 4, 0, Color.new(248,248,248), Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites[kt].bitmap,textpos)
		
		der_sprites = scTeamStorage.partySpritesAt(@index_upper + displayed_index)
		
		for i in 0...6
			ktti = ktt + i.to_s 
			@sprites[ktti].bitmap.clear
			@sprites[ktti].bitmap = Bitmap.new(64, 64)
			@sprites[ktti].bitmap.blt(0,0, AnimatedBitmap.new(der_sprites[i]).deanimate, Rect.new(0, 0, 64, 64))
			@sprites[ktti].x = @sprites[k].x + i * 64
			@sprites[ktti].y = @sprites[k].y + 35
		end 
	end 
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		#Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		Graphics.transition
		return @party  
	end
	
	

	def update
		pbUpdateSpriteHash(@sprites)

		drawSelector
		
		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#@wanted_data = -1
			@exit = true
		end

		if Input.trigger?(Input::C)
			pbPlayDecisionSE
			do_command
		end

		if Input.trigger?(Input::UP)
			@index -= 1
			if @index < 0
				@index = 0
				if @index_upper > 0
					@index_upper -= 1
					@index_lower -= 1
					# self.drawWantedData
					self.create_spriteset
				end 
			end
		end
		if Input.trigger?(Input::DOWN)
			@index += 1
			if @index > 2
				@index = 2
				if @index_lower < scTeamStorage.maxIndex
					@index_upper += 1
					@index_lower += 1
					# self.drawWantedData
					self.create_spriteset
				end 
			end
		end
	end
	

	
	def do_command
		
		# @index will be between 0 and 2 
		
		team_index = @index_upper + @index
		
		if scTeamStorage.isEmptyTeam?(team_index)
			options = ["New", "Random", "Import current", "Cancel"]
			res = pbMessage("Do what?", options, -1)
			
			tier_choice = scGetTier()
			
			# Choose the type of team: 
			
			if res == 0 or res == 1
				res2 = pbMessage("Use current tier? (" + tier_choice + ")", ["Yes", "No"], -1)
				
				if res2 == 1
					# Change tier. 
					tier_choice = scSelectTierMenu
					tier_choice = scGetTier() if tier_choice == ""
					pbMessage("Chosen tier: " + tier_choice + ".")
				end 
			end 
				
			if res == 0
        # New team. 
				Graphics.freeze
				scene = SCTeamBuilder.new(false, scTeamStorage.partyAt(team_index), tier_choice)
				data = scene.main
				scTeamStorage.modifyTeam(team_index, "Empty", data, tier_choice)
				create_spriteset
				Graphics.transition
			elsif res == 1
				team_types = ["Random", "Hyper-offense", "Offense", "Balanced", "Defensive", "Stall"]
        
				# if < 0: choose at random.
				# if = 0: Hyper Offense (Lead + 4 offensive + anything)
				# if = 1: Offensive (Lead + 3 offensive + 2 defensive)
				# if = 2: Balanced (Lead + 2 Offensive + 3 defensive)
				# if = 3: Defensive (Lead + Offensive + 4 defensive)
				# if = 4: Stall (5 defensive + Anything)
				
				team_type = pbMessage("Generate what type of team?", team_types, -1)
				
				if team_type > -1
					# didn't cancel. 
					while team_type > -1
						pbMessage(_INTL("Generated team will be {1}.",team_types[team_type]))
						
						team_type -= 1 
						# Generate random team for the current tier. 
						rand_party = scGenerateTeamRand($Trainer, team_type, nil, nil, tier_choice)
						rand_party = convertPartyToList(rand_party)
						
						scTeamStorage.modifyTeam(team_index, "Empty", rand_party, tier_choice)
						
						create_spriteset
						Graphics.transition
						
						keep_team = pbMessage("Keep this team?", ["Yes", "No"], 0)
						
						if keep_team == 0 
							pbMessage("Generated team for tier " + tier_choice + "!")
							break
						else
							team_type = pbMessage("Generate what type of team?", team_types, -1)
						end 
					end 
				end 
      elsif res == 2 
        # Import current. 
				Graphics.freeze
				scTeamStorage.modifyTeam(team_index, "Empty", convertPartyToList($Trainer.party), scGetTier())
				create_spriteset
				Graphics.transition
			end 
			
		else 
			options = ["Load", "Modify", "Rename", "Duplicate", "Change tier", "Replace with current", "Delete"]
      options.push("Export") if $DEBUG
      options.push("Cancel")
			
			res = pbMessage("Do what?", options, -1)
			
			
			if res == 0
				# Load 
				scene = SCTeamBuilder.new(false, scTeamStorage.partyAt(team_index), scTeamStorage.tierAt(team_index))
				scene.create_team(scTeamStorage.partyAt(team_index))
				
			elsif res == 1
				# Modify party
				Graphics.freeze
				scene = SCTeamBuilder.new(false, scTeamStorage.partyAt(team_index), scTeamStorage.tierAt(team_index))
				@sprites["background"].dispose
				data = scene.main
				scTeamStorage.modifyPartyAt(team_index, data)
				create_spriteset
				Graphics.transition
				
			elsif res == 2
				# Rename 
				temp=pbMessageFreeText("Select the name of the team.","Empty",false,20)
				scTeamStorage.modifyNameAt(team_index, temp)
				
				k = @index.to_s 
				kt = k + "t" 
				
				@sprites[kt].bitmap.clear
				
				pbSetSystemFont(@sprites[kt].bitmap)
				textpos=[
					[temp, @sprites[k].x+10, 4, 0, Color.new(248,248,248), Color.new(40,40,40)],
				]
				pbDrawTextPositions(@sprites[kt].bitmap,textpos)
				
			elsif res == 3
				# Duplicate 
				new_index = scTeamStorage.duplicateAt(team_index)
				temp = pbMessage("Modify the duplicated team?", ["Yes", "No"], 1)
				
				if temp == 0
					# Modify party
					Graphics.freeze
					scene = SCTeamBuilder.new(false, scTeamStorage.partyAt(new_index), scTeamStorage.tierAt(new_index))
					@sprites["background"].dispose
					data = scene.main
					scTeamStorage.modifyPartyAt(team_index, data)
					create_spriteset
					Graphics.transition
				end 
				
			elsif res == 4 
				# Change tier
				tier_choice = scSelectTierMenu
				
				if tier_choice == ""
					tier_choice = scGetTier()
				else 
					scTeamStorage.modifyTierAt(team_index, tier_choice) 
				end 
				
				Graphics.freeze
				pbMessage("Chosen tier: " + tier_choice + ".")
				create_spriteset
				Graphics.transition
				
				
			elsif res == 5
        # Import current. 
				Graphics.freeze
				scTeamStorage.modifyTeam(team_index, "Empty", convertPartyToList($Trainer.party), scGetTier())
				create_spriteset
				Graphics.transition

			elsif res == 6
				# Delete 
				caution = "Are you sure you want to delete the party " + scTeamStorage.nameAt(team_index)
				res = pbMessage(caution, ["Yes", "No"], 1)
				
				if res == 0
					pbMessage("Ok, it's your call!")
					scTeamStorage.deleteTeam(team_index)
					create_spriteset
					Graphics.transition
				end 
      elsif res == 7 && $DEBUG 
        # Export team
        scTeamStorage.export(team_index)
			end 
			
		end 
		
		# drawWantedData
	end 
  
  
	
	def pbEndScene
		pbFadeOutAndHide(@sprites)
		@exit=true
		pbDisposeSpriteHash(@sprites)
		pbRefreshSceneMap
	end
end 




###############################################################################
# SCTeamBuilder
# 
# First part of the menu for building a team. 
# Prints a summary of the team under construction and allows the access to 
# the SCWantedData menu (modification of a Pokémon). 
# By StCooler. 
###############################################################################

class SCTeamBuilder
	
	def initialize(currentParty = true, party = nil, tier = nil, force_valid = false)
		@party = [] 
		
		# This will allow, in the create_team functin, to check if a 
		# species changed. 
		# Do not store the Pokémons in the PC if the species did not change 
		@original_party_species = [0,0,0,0,0,0] 
		@tier = tier 
		@tier = scGetTier() if !tier
		@force_valid = force_valid		
		
		if currentParty
			@party = convertPartyToList($Trainer.party) 
		elsif party 
			@party = party 
		end 
			
		if @party.length < 6 
			for i in @party.length...6
				@party[i] = SCTB.initData(nil)
			end 
			
			# 0 = Species 
			# 1 = Min level (not used)
			# 2 = Level 
			# 3 = Gender 
			# 4 = Ability 
			# 5 = Items 
			# 6 = Nature 
			# 7 = Nickname 
			# 8 = IVs 
			# 9 = moves 
			# 10 = EVs 
			# 11 = Shiny
			# 12 = Form (unimplemented)
			# pkmn_data = []
		end 
		
		
		for i in 0...6
			@original_party_species[i] = @party[i][0]
		end 
		
		# scConvertPartyToString(@party)
		
		@valid = nil
		@exit = false
		
		@index = 0
    
    @index_row = 0
    @index_column = 0
	end

	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Team builder",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
			#    ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
			#    Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
  
	
	
	def create_spriteset
		# Loads and seets the sprites. 
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
    
    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		# POKEMONS 
		
		for i in 0...6
			k = i.to_s
			kt = k+"t"
			ktt = k+"tt"
			
			# @sprites[k] = IconSprite.new
			# @sprites[k].setBitmap("Graphics/Pictures/GTS/pokemon_bar")
			# @sprites[k].x = Graphics.width / 2
			# @sprites[k].x -= @sprites[k].bitmap.width / 2
			# @sprites[k].y = 50 + i * 38
			@sprites[k] = IconSprite.new
			@sprites[k].bitmap = Bitmap.new(96, 96)
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= 192*3 * 3 /8
			@sprites[k].x += (i%3) * 192*3 / 4
			@sprites[k].y = (i < 3 ? 50 : 50+96)
			@sprites[k].zoom_x = 0.5
			@sprites[k].zoom_y = @sprites[k].zoom_x
      

			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y

			@sprites[ktt] = IconSprite.new
			@sprites[ktt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktt].x = @sprites[k].x
			@sprites[ktt].y = @sprites[k].y
		end 
		
		
		# Generate a random team ? Not yet! 
		
		
		# Check validity of team for current tier.
		@sprites["6"] = IconSprite.new
		@sprites["6"].setBitmap("Graphics/Pictures/GTS/tb_validity")
		@sprites["6"].x = Graphics.width / 2
		@sprites["6"].x -= @sprites["6"].bitmap.width / 2
		@sprites["6"].y = 306

		@sprites["6t"] = IconSprite.new
		@sprites["6t"].bitmap = Bitmap.new(@sprites["6"].bitmap.width, 
			@sprites["6"].bitmap.height)
		@sprites["6t"].x = @sprites["6"].x
		@sprites["6t"].y = @sprites["6"].y

		@sprites["6tt"] = IconSprite.new
		@sprites["6tt"].bitmap = Bitmap.new(@sprites["6"].bitmap.width, 
			@sprites["6"].bitmap.height)
		@sprites["6tt"].x = @sprites["6"].x
		@sprites["6tt"].y = @sprites["6"].y
		
		# Finish team. 
		@sprites["7"] = IconSprite.new
		@sprites["7"].setBitmap("Graphics/Pictures/GTS/Search_bar")
		@sprites["7"].x = Graphics.width / 2
		@sprites["7"].x -= @sprites["7"].bitmap.width / 2
		@sprites["7"].y = 346

		@sprites["7t"] = IconSprite.new
		@sprites["7t"].bitmap = Bitmap.new(@sprites["7"].bitmap.width, 
			@sprites["7"].bitmap.height)
		@sprites["7t"].x = @sprites["7"].x
		@sprites["7t"].y = @sprites["7"].y

		@sprites["7tt"] = IconSprite.new
		@sprites["7tt"].bitmap = Bitmap.new(@sprites["7"].bitmap.width, 
			@sprites["7"].bitmap.height)
		@sprites["7tt"].x = @sprites["7"].x
		@sprites["7tt"].y = @sprites["7"].y
		
		
		# for i in 0...6
			# k = i.to_s + "tt"
			# pbSetSystemFont(@sprites[k].bitmap)
			# textpos=[          
				# ["Pkmn " + (i+1).to_s,30,0,0,Color.new(248,248,248),Color.new(40,40,40)],
			# ]
			# pbDrawTextPositions(@sprites[k].bitmap,textpos)
		# end 
		
		pbSetSystemFont(@sprites["7tt"].bitmap)
		textpos=[          
			["Finish party!",
			# @sprites["4"].bitmap.width / 2, 2,2,Color.new(248,248,248),
			@sprites["7"].bitmap.width / 2,0,2,Color.new(248,248,248),
			Color.new(40,40,40)],       
		]
		pbDrawTextPositions(@sprites["7tt"].bitmap,textpos)
		
		
		bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		@sprites["selection_l_u"] = IconSprite.new
		@sprites["selection_l_u"].bitmap = Bitmap.new(16, 23)
		@sprites["selection_l_u"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    
		@sprites["selection_l_d"] = IconSprite.new
		@sprites["selection_l_d"].bitmap = Bitmap.new(16, 23)
		@sprites["selection_l_d"].bitmap.blt(0, 0, bit, Rect.new(0, 16, 16, 32))

		@sprites["selection_r_u"] = IconSprite.new
		@sprites["selection_r_u"].bitmap = Bitmap.new(16, 23)
		@sprites["selection_r_u"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))

		@sprites["selection_r_d"] = IconSprite.new
		@sprites["selection_r_d"].bitmap = Bitmap.new(16, 23)
		@sprites["selection_r_d"].bitmap.blt(0, 0, bit, Rect.new(16, 16, 32, 32))
		# @sprites["selection_l"] = IconSprite.new
		# @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		# @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		# @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))

		# @sprites["selection_r"] = IconSprite.new
		# @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		# @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		# @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    drawSelector
		drawWantedData
	end
	
  
  
  def drawSelector
		# @sprites["selection_l"].x = @sprites["#{@index}"].x-2
		# @sprites["selection_l"].y = @sprites["#{@index}"].y-2
		# @sprites["selection_r"].x = @sprites["#{@index}"].x+
		# @sprites["#{@index}"].bitmap.width-18
		# @sprites["selection_r"].y = @sprites["#{@index}"].y-2
		@sprites["selection_l_u"].x = @sprites["#{@index}"].x-2
		@sprites["selection_l_u"].y = @sprites["#{@index}"].y-2
    
    if @index < 6
      @sprites["selection_l_d"].x = @sprites["#{@index}"].x-2
      # @sprites["selection_l_d"].y = 192
      @sprites["selection_l_d"].y = @sprites["#{@index}"].y+
        @sprites["#{@index}"].bitmap.height * 3 / 4 + 2
    else 
      @sprites["selection_l_d"].x = @sprites["#{@index}"].x-2
      # @sprites["selection_l_d"].y = 192
      @sprites["selection_l_d"].y = @sprites["#{@index}"].y+
        @sprites["#{@index}"].bitmap.height-18
    end 
    
    if @index < 6
      @sprites["selection_r_u"].x = @sprites["#{@index}"].x+
        @sprites["#{@index}"].bitmap.width * 3 / 4 + 2
      @sprites["selection_r_u"].y = @sprites["#{@index}"].y-2
    else 
      @sprites["selection_r_u"].x = @sprites["#{@index}"].x+
        @sprites["#{@index}"].bitmap.width-18
      @sprites["selection_r_u"].y = @sprites["#{@index}"].y-2
    end 
    
    if @index < 6
      @sprites["selection_r_d"].x = @sprites["#{@index}"].x+
        @sprites["#{@index}"].bitmap.width * 3 / 4 + 2
      @sprites["selection_r_d"].y = @sprites["#{@index}"].y+
        @sprites["#{@index}"].bitmap.height * 3 / 4 + 2
    else 
      @sprites["selection_r_d"].x = @sprites["#{@index}"].x+
        @sprites["#{@index}"].bitmap.width-18
      @sprites["selection_r_d"].y = @sprites["#{@index}"].y+
        @sprites["#{@index}"].bitmap.height-18
    end 
  end 
	
	
	def drawWantedData
		drawHeader
		
		# Just prints the Pokemon names, with no further detail. 
		for i in 0...6
			k = i.to_s + "t"
			@sprites[k].bitmap.clear
			if (not @party[i].empty?) && @party[i][0]
				#s = PBItems.getName(@wanted_data[SCMovesetsData::ITEM]) 
        
        @sprites[i.to_s].bitmap = pbLoadSpeciesBitmap(@party[i][0], 
                              @party[i][SCMovesetsData::GENDER], 
                              @party[i][SCMovesetsData::FORM], 
                              @party[i][SCMovesetsData::SHINY]).bitmap
        @sprites[i.to_s].zoom_x = 0.75
        @sprites[i.to_s].zoom_y = @sprites[i.to_s].zoom_x

        
        
        species_name = PBSpecies.getName(@party[i][SCMovesetsData::SPECIES])
        nickname = nil
        
        if @party[i][SCMovesetsData::NICKNAME] && @party[i][SCMovesetsData::NICKNAME] != ""
          nickname = @party[i][SCMovesetsData::NICKNAME]
        end 
        
        # name_nickname = (nickname ? _INTL("{1} ({2})", species_name, nickname) : species_name)
        name_nickname = species_name if !nickname
        
				pbSetSystemFont(@sprites[k].bitmap)
				textpos=[          
					[name_nickname,275,4,2,Color.new(248,248,248),Color.new(40,40,40)],
				]
				pbDrawTextPositions(@sprites[k].bitmap,textpos)
			end 
		end 
		
		
		# Validity !
		
		@sprites["6t"].bitmap.clear
		
		@valid = partyListIsValidForTier(@party, false, @tier)
		
		validity_test = ""
		
		if @valid == nil
			validity_test = ""
		elsif @valid
			validity_test = "Currently valid for " + @tier
		else
			validity_test = "Currently not valid for " + @tier
		end 
		
		# pbSetSystemFont(@sprites["6t"].bitmap)
		# textpos=[          
			# [validity_test,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
		# ]
		# pbDrawTextPositions(@sprites["6t"].bitmap,textpos)
		
		pbSetSystemFont(@sprites["6t"].bitmap)
		textpos=[          
			[validity_test,
			#@sprites["4"].bitmap.width / 2, 2,2,Color.new(248,248,248),
			@sprites["6"].bitmap.width / 2,4,2,Color.new(248,248,248),
			Color.new(40,40,40)],       
		]
		pbDrawTextPositions(@sprites["6t"].bitmap,textpos)

	end
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		#Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		Graphics.transition
		return @party  
	end
	
	
	
	def update
		pbUpdateSpriteHash(@sprites)

		drawSelector

		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#@wanted_data = -1
			@exit = true
		end

		if Input.trigger?(Input::C)
			pbPlayDecisionSE
			do_command
		end

		if Input.trigger?(Input::UP)
      case @index_row 
      when 0 # First line of the team
        @index_row = 3 # Get on Finish Party
        @index = 7
      when 1 # Second line of the team 
        @index_row = 0 # Got to first line 
        @index = @index_row * 3 + @index_column
      when 2 # Validity line 
        @index_row = 1 # Get on the second line.
        @index = @index_row * 3 + @index_column 
      else # Finish party 
        @index_row = 2 # Get on validity line
        @index = 6
      end 
		end
		if Input.trigger?(Input::DOWN)
      case @index_row 
      when 0 # First line of the team
        @index_row += 1 # Get on the second line.
        @index = @index_row * 3 + @index_column 
      when 1 # Second line of the team 
        @index_row = 2 # Get on validity line
        @index = 6
      when 2 # Validity line 
        @index_row = 3 # Get on Finish Party
        @index = 7
      else # Finish party 
        @index_row = 0 
        @index = @index_row * 3 + @index_column
      end 
		end
		if Input.trigger?(Input::LEFT)
      if @index < 6
        @index_column -= 1
        @index_column = 2 if @index_column < 0
        @index = @index_row * 3 + @index_column
      end 
		end
		if Input.trigger?(Input::RIGHT)
      if @index < 6
        @index_column += 1
        @index_column = 0 if @index_column > 2
        @index = @index_row * 3 + @index_column
      end 
		end
	end
	
	
  
	def checkIfPokeValid(pkmn_data)
		# Checks if we have filled enough data to the Pokemons. 
		# FOR DEBUG!
		# return [] 
		msgs = []
		
		# [-1, 1, 120, -1, 0, -1, nil, "", Array.new(6, 31), Array.new(4, -1), Array.new(6, 0), false, 0]
		
		# 0 = Species 
		if !pkmn_data[SCMovesetsData::BASESPECIES]
			msgs.push("No Pokémon is defined.")
			return msgs 
		end 
		
		# 1 = Min level (not used)
		# 2 = Level 
		if pkmn_data[SCMovesetsData::LEVEL] && (pkmn_data[SCMovesetsData::LEVEL] < 1 || pkmn_data[SCMovesetsData::LEVEL] > 120)
			msgs.push(_INTL("Given level is {1} (min: 1, max: 120)", pkmn_data[SCMovesetsData::LEVEL]))
		end 
		
		# 3 = Gender 
		# DC; it's auto-filled.
		
		# 4 = Ability 
		# DC; it's auto-filled.
		
		# 5 = Items 
		if !pkmn_data[SCMovesetsData::ITEM]
			msgs.push("No item is defined.")
		end
		
		# 6 = Nature 
		if !pkmn_data[SCMovesetsData::NATURE]
			msgs.push("No nature is defined.")
		end
		
		# 7 = Nickname
		# DC; auto-filled.
		
		# 8 = IVs 
		if SCTB.oneValue(pkmn_data[SCMovesetsData::IV], nil)
			msgs.push("No IVs are defined.")
		else 
			for i in 0...6
				if pkmn_data[SCMovesetsData::IV][i] < 0 or pkmn_data[SCMovesetsData::IV][i] > 31
					msgs.push("Given IV is: {1} (min: 0, max: 31)", pkmn_data[SCMovesetsData::IV][i])
					break 
				end 
			end 
		end
		
		# 9 = moves 
		if !pkmn_data[SCMovesetsData::MOVE1] && !pkmn_data[SCMovesetsData::MOVE2] && !pkmn_data[SCMovesetsData::MOVE3] && !pkmn_data[SCMovesetsData::MOVE4]
			msgs.push("No moves are defined.")
		end 
		
				
		# 10 = EVs 
		if SCTB.oneValue(pkmn_data[SCMovesetsData::EV], nil)
			msgs.push("No EVs are defined.")
		else 
			total = 0
			
			for i in 0...6
				if pkmn_data[SCMovesetsData::EV][i] < 0 or pkmn_data[SCMovesetsData::EV][i] > 255
					msgs.push("Given EV is: {1} (min: 0, max: 255)", pkmn_data[SCMovesetsData::EV][i])
					break 
				end 
				total += pkmn_data[SCMovesetsData::EV][i]
			end 
			
			if total > 510 or total < 0
				msgs.push(_INTL("Total of EVs is: {1} (min: 0, max: 510)", total))
			end 
		end
		# 11 = Shiny
		# 12 = Form

		return msgs 
	end 
	
	
	
	def do_command
		if @index >= 0 and @index < 6
			scene = SCWantedDataComplete.new(@party[@index], @tier)
			@party[@index] = scene.main 
		
		elsif @index == 6 
			@valid = partyListIsValidForTier(@party, true, @tier)
			
		elsif @index == 7
			canDo=true
			
			# Check if a Pokémon is valid. 
			for i in 0...6
				msgs = checkIfPokeValid(@party[i])
				next if msgs.empty?
				
				
				canDo = false if @force_valid 
				
				pbMessage(_INTL("Problems with Pokémon {1}:", i+1))
				
				for msg in msgs
					pbMessage(msg)
				end 
			end 
			
			# create_team(@party)
			
			@exit = canDo 
			
		end 
		
		drawWantedData
	end 
	
	
	
	def create_team(party = nil)
		# Gives this team to the Player.
    
		party = @party if party == nil 
		
		new_team = [] 
		for pkmn in party
			next if !pkmn[0]
      # Form is handled at the creation of the Pokémon. 
      base_species = pkmn[SCMovesetsData::BASESPECIES] != nil ? pkmn[SCMovesetsData::BASESPECIES] : pkmn[SCMovesetsData::SPECIES]
			pokemon = PokeBattle_Pokemon.new(base_species,pkmn[SCMovesetsData::LEVEL], $Trainer)
			
			# Give gender; 0 if male and 1 if female 
			if pkmn[SCMovesetsData::GENDER]
				pokemon.setGender(pkmn[SCMovesetsData::GENDER])
			end 
			
			# Give ability 
			if pkmn[SCMovesetsData::ABILITYINDEX]
				pokemon.setAbility(pkmn[SCMovesetsData::ABILITYINDEX])
			end 
			
			# Give item 
			if pkmn[SCMovesetsData::ITEM]
				pokemon.item = pkmn[SCMovesetsData::ITEM]
			end 
			
			# Give nature 
			if pkmn[SCMovesetsData::NATURE]
				pokemon.setNature(pkmn[SCMovesetsData::NATURE])
			end 
			
			# Give nickname 
			if pkmn[SCMovesetsData::NICKNAME] && pkmn[SCMovesetsData::NICKNAME] != ""
				pokemon.name = pkmn[SCMovesetsData::NICKNAME]
			end 
			
			for i in 0...6
				pokemon.iv[i] = pkmn[SCMovesetsData::IV][i]
				pokemon.ev[i] = pkmn[SCMovesetsData::EV][i]
			end 
			
			# Check if it has moves. If not, then the moves will be given by the level. 
			for i in 0...4
				if pkmn[SCMovesetsData::MOVE1 + i]
					pokemon.moves[i] = PBMove.new(pkmn[SCMovesetsData::MOVE1 + i])
				end 
			end 
			
			# Shiny 
			if pkmn[SCMovesetsData::SHINY] == true
				pokemon.makeShiny 
			end 
			
			pokemon.calcStats 
			
			new_team.push(pokemon)
		end 
		
		
		
		# Store the current team in the PC.
		for pk in 0...$Trainer.party.length
			if new_team.length > pk and @original_party_species[pk] != new_team[pk].species 
				if pbBoxesFull?
					pbMessage(_INTL("Boxes are full."))
					pbMessage(_INTL("Adding a new box."))
					$PokemonStorage.addBox
				end 
				pbStorePokemon($Trainer.party[pk])
			end 
		end 
		
		
		# And replace the team with the new one:
		$Trainer.party = new_team
		
    # Store the tier of the team, just to warn the player in case they fight in another tier.
    scSetTierOfTeam(@tier)
    
		pbMessage("Done!")
		
	end 
	
end 




def convertPartyToList(party)
	# Here, party is a real party ($Trainer.party, for example)
	party_list = []
	
	for pk in party 
		pkmn = SCTB.initData(pk.fSpecies)
		
		# Min level 
		# pkmn[1] # Useless
		
		# Actual level 
		pkmn[SCMovesetsData::LEVEL] = pk.level
		
		# Gender 
		# pkmn[SCMovesetsData::GENDER] = pk.gender
    # Don't give gender. 
		
		# Ability (number between 0 and 2)
		pkmn[SCMovesetsData::ABILITYINDEX] = pk.abilityIndex
		pkmn[SCMovesetsData::ABILITY] = pk.ability
		
		# The item is already an ID !
		pkmn[SCMovesetsData::ITEM] = pk.item 
		
		# Nature 
		pkmn[SCMovesetsData::NATURE] = pk.nature
		
		# Nickname 
		
		if pk.name == PBSpecies.getName(pk.species)
			pkmn[SCMovesetsData::NICKNAME] = "" 
    else
      pkmn[SCMovesetsData::NICKNAME] = pk.name
		end 
		
		# IVs			
		for i in 0...6
			pkmn[SCMovesetsData::IV][i] = pk.iv[i]
		end 
		
		# Moves 			
		for i in 0...4
			if pk.moves[i]
				pkmn[SCMovesetsData::MOVE1 + i] = pk.moves[i].id
			else
				pkmn[SCMovesetsData::MOVE1 + i] = nil
			end 
		end 
		
		# EVs
		for i in 0...6
			pkmn[SCMovesetsData::EV][i] = pk.ev[i]
		end 
		
		# Shiny 
		pkmn[SCMovesetsData::SHINY] = pk.isShiny?
		
		# Form 
		
		# pkmn[SCMovesetsData::FORM] = pk.form
		# pkmn[SCMovesetsData::BASEFORM] = pk.form
    # pkmn[SCMovesetsData::FORMNAME] = SCTB.getFormName(pk.species, pk.form)
		# pkmn[SCMovesetsData
		party_list.push(pkmn)
	end 
	
	return party_list
end 
	



def scAdaptCurrentTeam
	# Short function 
	tb = SCTeamBuilder.new(true, nil, nil, true)
	tb.main 
	tb.create_team(nil)
end 




###############################################################################
# SCWantedDataComplete
# 
# Code derived from the GTSWantedData class.
# Allows the modification of all the stuff for a given Pokémon of the team.
# By StCooler. 
###############################################################################

class SCWantedDataComplete 
	# Displays a menu in which you can create a Pokémon member of the Team. 
	
	def initialize(data=nil, tier=nil)
		@exit = false
		@wanted_data = SCTB.initData(nil)
		@wanted_data = data if data!=nil
		@index = 0 # Line 
		@column = 0 
		tier = scGetTier() if !tier
		@tier = loadTier(tier)
		@base_stats = []
		@species_name = "????"
		@filter_by_type = nil 
    @filter_by_move = nil 
    @filter_by_role = nil 
    @old_filter_by_type = nil
    @old_filter_by_role = nil
    @old_filter_by_move = nil
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @dict_of_species = {} 
    
		resetMoves
	end
	
	
	
	def getBaseStats
		if !@wanted_data[SCMovesetsData::FSPECIES]
			return [] 
		end 
    return pbGetSpeciesData(@wanted_data[SCMovesetsData::BASESPECIES],@wanted_data[SCMovesetsData::FORM],SpeciesBaseStats)
	end
	
	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Pokemon Wanted Data",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
	
	
	
	def create_spriteset
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
    
    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		
		# SPECIES 
		@sprites["0"] = IconSprite.new
		@sprites["0"].setBitmap("Graphics/Pictures/GTS/tb_Pokemon_bar")
		@sprites["0"].x = Graphics.width / 2
		@sprites["0"].x -= @sprites["0"].bitmap.width / 2
		@sprites["0"].y = 44

		@sprites["0t"] = IconSprite.new
		@sprites["0t"].bitmap = Bitmap.new(@sprites["0"].bitmap.width, 
			@sprites["0"].bitmap.height)
		@sprites["0t"].x = @sprites["0"].x
		@sprites["0t"].y = @sprites["0"].y

		@sprites["0tt"] = IconSprite.new
		@sprites["0tt"].bitmap = Bitmap.new(@sprites["0"].bitmap.width, 
			@sprites["0"].bitmap.height)
		@sprites["0tt"].x = @sprites["0"].x
		@sprites["0tt"].y = @sprites["0"].y
		
    # Types 
    @sprites["type2"] = IconSprite.new
    @sprites["type2"].bitmap = Bitmap.new(64, 28)
    @sprites["type2"].x = 370 + 64
    @sprites["type2"].y = 15
    # @sprites["type2"].src_rect.height = 28
    # @sprites["type2"].src_rect.y = temp_types[1]*28
    
    @sprites["type1"] = IconSprite.new
    @sprites["type1"].bitmap = Bitmap.new(64, 28)
    @sprites["type1"].x = 370
    @sprites["type1"].y = 15
    # @sprites["type1"].src_rect.height = 28
    # @sprites["type1"].src_rect.y = temp_types[0]*28
    
		# Nature + Form
		@sprites["1"] = IconSprite.new
		@sprites["1"].setBitmap("Graphics/Pictures/GTS/Gender_bar")
		@sprites["1"].x = Graphics.width / 2
		@sprites["1"].x -= @sprites["1"].bitmap.width / 2
		@sprites["1"].y = 82

		@sprites["1t"] = IconSprite.new
		@sprites["1t"].bitmap = Bitmap.new(@sprites["1"].bitmap.width, 
			@sprites["1"].bitmap.height)
		@sprites["1t"].x = @sprites["1"].x
		@sprites["1t"].y = @sprites["1"].y

		@sprites["1tt"] = IconSprite.new
		@sprites["1tt"].bitmap = Bitmap.new(@sprites["1"].bitmap.width, 
			@sprites["1"].bitmap.height)
		@sprites["1tt"].x = @sprites["1"].x
		@sprites["1tt"].y = @sprites["1"].y
		
		# Item + ability 
		@sprites["2"] = IconSprite.new
		@sprites["2"].setBitmap("Graphics/Pictures/GTS/Level_bar")
		@sprites["2"].x = Graphics.width / 2
		@sprites["2"].x -= @sprites["2"].bitmap.width / 2
		@sprites["2"].y = 120

		@sprites["2t"] = IconSprite.new
		@sprites["2t"].bitmap = Bitmap.new(@sprites["2"].bitmap.width, 
			@sprites["2"].bitmap.height)
		@sprites["2t"].x = @sprites["2"].x
		@sprites["2t"].y = @sprites["2"].y

		@sprites["2tt"] = IconSprite.new
		@sprites["2tt"].bitmap = Bitmap.new(@sprites["2"].bitmap.width, 
			@sprites["2"].bitmap.height)
		@sprites["2tt"].x = @sprites["2"].x
		@sprites["2tt"].y = @sprites["2"].y
		
		# Move 1 + Move 2 
		@sprites["3"] = IconSprite.new
		@sprites["3"].setBitmap("Graphics/Pictures/GTS/tb_colored")
		@sprites["3"].x = Graphics.width / 2
		@sprites["3"].x -= @sprites["3"].bitmap.width / 2
		@sprites["3"].y = 158

		@sprites["3t"] = IconSprite.new
		@sprites["3t"].bitmap = Bitmap.new(@sprites["3"].bitmap.width, 
			@sprites["3"].bitmap.height)
		@sprites["3t"].x = @sprites["3"].x
		@sprites["3t"].y = @sprites["3"].y

		@sprites["3tt"] = IconSprite.new
		@sprites["3tt"].bitmap = Bitmap.new(@sprites["3"].bitmap.width, 
			@sprites["3"].bitmap.height)
		@sprites["3tt"].x = @sprites["3"].x
		@sprites["3tt"].y = @sprites["3"].y
		
		# Move 3 + Move 4 
		@sprites["4"] = IconSprite.new
		@sprites["4"].setBitmap("Graphics/Pictures/GTS/tb_colored")
		@sprites["4"].x = Graphics.width / 2
		@sprites["4"].x -= @sprites["4"].bitmap.width / 2
		@sprites["4"].y = 196

		@sprites["4t"] = IconSprite.new
		@sprites["4t"].bitmap = Bitmap.new(@sprites["4"].bitmap.width, 
			@sprites["4"].bitmap.height)
		@sprites["4t"].x = @sprites["4"].x
		@sprites["4t"].y = @sprites["4"].y

		@sprites["4tt"] = IconSprite.new
		@sprites["4tt"].bitmap = Bitmap.new(@sprites["4"].bitmap.width, 
			@sprites["4"].bitmap.height)
		@sprites["4tt"].x = @sprites["4"].x
		@sprites["4tt"].y = @sprites["4"].y
		
		# EVs + IVs 
		@sprites["5"] = IconSprite.new
		@sprites["5"].setBitmap("Graphics/Pictures/GTS/ability_bar")
		@sprites["5"].x = Graphics.width / 2
		@sprites["5"].x -= @sprites["5"].bitmap.width / 2
		@sprites["5"].y = 234

		@sprites["5t"] = IconSprite.new
		@sprites["5t"].bitmap = Bitmap.new(@sprites["5"].bitmap.width, 
			@sprites["5"].bitmap.height)
		@sprites["5t"].x = @sprites["5"].x
		@sprites["5t"].y = @sprites["5"].y

		@sprites["5tt"] = IconSprite.new
		@sprites["5tt"].bitmap = Bitmap.new(@sprites["5"].bitmap.width, 
			@sprites["5"].bitmap.height)
		@sprites["5tt"].x = @sprites["5"].x
		@sprites["5tt"].y = @sprites["5"].y
		
		# Nickname + Shiny 
		@sprites["6"] = IconSprite.new
		@sprites["6"].setBitmap("Graphics/Pictures/GTS/ability_bar")
		@sprites["6"].x = Graphics.width / 2
		@sprites["6"].x -= @sprites["6"].bitmap.width / 2
		@sprites["6"].y = 272

		@sprites["6t"] = IconSprite.new
		@sprites["6t"].bitmap = Bitmap.new(@sprites["6"].bitmap.width, 
			@sprites["6"].bitmap.height)
		@sprites["6t"].x = @sprites["6"].x
		@sprites["6t"].y = @sprites["6"].y

		@sprites["6tt"] = IconSprite.new
		@sprites["6tt"].bitmap = Bitmap.new(@sprites["6"].bitmap.width, 
			@sprites["6"].bitmap.height)
		@sprites["6tt"].x = @sprites["6"].x
		@sprites["6tt"].y = @sprites["6"].y
		
		# Level + gender 
		@sprites["7"] = IconSprite.new
		@sprites["7"].setBitmap("Graphics/Pictures/GTS/ability_bar")
		@sprites["7"].x = Graphics.width / 2
		@sprites["7"].x -= @sprites["7"].bitmap.width / 2
		@sprites["7"].y = 310

		@sprites["7t"] = IconSprite.new
		@sprites["7t"].bitmap = Bitmap.new(@sprites["7"].bitmap.width, 
			@sprites["7"].bitmap.height)
		@sprites["7t"].x = @sprites["7"].x
		@sprites["7t"].y = @sprites["7"].y
		
		@sprites["7tt"] = IconSprite.new
		@sprites["7tt"].bitmap = Bitmap.new(@sprites["7"].bitmap.width, 
			@sprites["7"].bitmap.height)
		@sprites["7tt"].x = @sprites["7"].x
		@sprites["7tt"].y = @sprites["7"].y
		
		# Generate Pokemon. 
		@sprites["8"] = IconSprite.new
		@sprites["8"].setBitmap("Graphics/Pictures/GTS/validation_bar")
		@sprites["8"].x = Graphics.width / 2
		@sprites["8"].x -= @sprites["8"].bitmap.width / 2
		@sprites["8"].y = 348

		@sprites["8t"] = IconSprite.new
		@sprites["8t"].bitmap = Bitmap.new(@sprites["8"].bitmap.width, 
			@sprites["8"].bitmap.height)
		@sprites["8t"].x = @sprites["8"].x
		@sprites["8t"].y = @sprites["8"].y

		@sprites["8tt"] = IconSprite.new
		@sprites["8tt"].bitmap = Bitmap.new(@sprites["8"].bitmap.width, 
			@sprites["8"].bitmap.height)
		@sprites["8tt"].x = @sprites["8"].x
		@sprites["8tt"].y = @sprites["8"].y

		# Background I guess. 
		@sprites["9"] = SCTB_Button.new(Graphics.width/2, 290, "Back")
		@sprites["9"].x -= @sprites["5"].bitmap.width / 2
		@sprites["9"].y = 386

		# pbSetSystemFont(@sprites["7tt"].bitmap)
		# textpos2=[          
			# ["Other",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
		# ]
		# pbDrawTextPositions(@sprites["7tt"].bitmap,textpos2)

		pbSetSystemFont(@sprites["8tt"].bitmap)
		textpos=[          
			["Validate Pokémon",
			#@sprites["4"].bitmap.width / 2, 2,2,Color.new(248,248,248),
			@sprites["8"].bitmap.width / 2,2,2,Color.new(248,248,248),
			Color.new(40,40,40)],       
		]
		pbDrawTextPositions(@sprites["8tt"].bitmap,textpos)

		bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		@sprites["selection_l"] = IconSprite.new
		@sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		@sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))

		@sprites["selection_r"] = IconSprite.new
		@sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		@sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
		
		

		drawSelector
		drawWantedData
	end
	
	
	
	def drawSelector
		if @index == 0 or @index == 8
			@sprites["selection_l"].x = @sprites["#{@index}"].x-2
			@sprites["selection_l"].y = @sprites["#{@index}"].y-2
			@sprites["selection_r"].x = @sprites["#{@index}"].x+ 
				@sprites["#{@index}"].bitmap.width-18
			@sprites["selection_r"].y = @sprites["#{@index}"].y-2
			
			if @index == 0
				@column = 1 
			end 
		elsif @column == 0
			@sprites["selection_l"].x = @sprites["#{@index}"].x-2
			@sprites["selection_l"].y = @sprites["#{@index}"].y-2
			@sprites["selection_r"].x = @sprites["#{@index}"].x+
				(@sprites["#{@index}"].bitmap.width / 2) - 9
			@sprites["selection_r"].y = @sprites["#{@index}"].y-2
			
		else
			@sprites["selection_l"].x = @sprites["#{@index}"].x-2 + @sprites["#{@index}"].bitmap.width / 2
			@sprites["selection_l"].y = @sprites["#{@index}"].y-2
			@sprites["selection_r"].x = @sprites["#{@index}"].x+ 
				@sprites["#{@index}"].bitmap.width-18
			@sprites["selection_r"].y = @sprites["#{@index}"].y-2
		end 
	end 
	
	
	
	def getMoveFor(integer)
    return "Empty" if !integer
		return integer if integer.is_a?(String)
		return PBMoves.getName(integer)
	end
	
	
	
	def drawWantedData
		
		drawHeader
		
		# Write the species name. 
		@sprites["0t"].bitmap.clear
			
		pbSetSystemFont(@sprites["0t"].bitmap)
		textpos=[
			["Species", 110, 4, 2, Color.new(248,248,248), Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["0t"].bitmap,textpos)
		
		
		pbSetSystemFont(@sprites["0t"].bitmap)
		textpos=[          
			[@species_name,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["0t"].bitmap,textpos)
		
		
		if @wanted_data[SCMovesetsData::SPECIES]
			
			# ---------------------------------
			# Nature
			# Line 2, column 1
			@sprites["1t"].bitmap.clear
			
			s = "No nature given"
			s = ("Nature: " + PBNatures.getName(@wanted_data[SCMovesetsData::NATURE])) if @wanted_data[SCMovesetsData::NATURE]
			pbSetSystemFont(@sprites["1t"].bitmap)
			textpos=[
				[s, 110, 4, 2, Color.new(248,248,248), Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["1t"].bitmap,textpos)
			
			
      
      # ---------------------------------
      # Types 
      
      temp_types = scGetSpeciesTypes(@wanted_data[SCMovesetsData::SPECIES], @wanted_data[SCMovesetsData::FORM])
      
      @sprites["type2"].bitmap = nil 
      @sprites["type1"].bitmap = nil 
      
      if temp_types[1] && temp_types[0] != temp_types[1]
        @sprites["type1"] = IconSprite.new
        @sprites["type1"].bitmap = @typeBitmap.bitmap
        @sprites["type1"].src_rect.height = 28
        @sprites["type1"].src_rect.y = temp_types[0]*28
        @sprites["type1"].x = 370
        @sprites["type1"].y = 15
        
        @sprites["type2"] = IconSprite.new
        @sprites["type2"].bitmap = @typeBitmap.bitmap
        @sprites["type2"].x = 370 + 64
        @sprites["type2"].y = 15
        @sprites["type2"].src_rect.height = 28
        @sprites["type2"].src_rect.y = temp_types[1]*28
      else 
        @sprites["type2"] = IconSprite.new
        @sprites["type2"].bitmap = @typeBitmap.bitmap
        @sprites["type2"].x = 370 + 64
        @sprites["type2"].y = 15
        @sprites["type2"].src_rect.height = 28
        @sprites["type2"].src_rect.y = temp_types[0]*28
      end 
      
      
      
			# ---------------------------------
			# Form 
			# Line 2, column 2 
      form_name = @wanted_data[SCMovesetsData::FORMNAME]
      if !form_name || form_name == ""
        form_name = SCTB.getFormName(@wanted_data[SCMovesetsData::BASESPECIES], @wanted_data[SCMovesetsData::FORM])
        @wanted_data[SCMovesetsData::FORMNAME] = form_name
      end 
			pbSetSystemFont(@sprites["1t"].bitmap)
			textpos=[
				[form_name,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["1t"].bitmap,textpos)
			
			
			
			# ---------------------------------
			# Item 
			# Line 3, column 1 
			
			@sprites["2t"].bitmap.clear
			
			s = "No item"
			s = PBItems.getName(@wanted_data[SCMovesetsData::ITEM]) if @wanted_data[SCMovesetsData::ITEM]
			pbSetSystemFont(@sprites["2t"].bitmap)
			textpos=[          
				[s,110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["2t"].bitmap,textpos)
			
			
			# ---------------------------------
			# Ability 
			# Line 3, column 2
			@wanted_data[SCMovesetsData::ABILITYINDEX]=0 if !@wanted_data[SCMovesetsData::ABILITYINDEX]
      @wanted_data[SCMovesetsData::ABILITY] = SCTB.getAbilityFromIndex(
                                                @wanted_data[SCMovesetsData::ABILITYINDEX], 
                                                @wanted_data[SCMovesetsData::FSPECIES])
      begin 
			lr = PBAbilities.getName(@wanted_data[SCMovesetsData::ABILITY]) 
      rescue 
        raise _INTL("Species {2}, Form {3}, ability index {1}, ability {4}", 
                                                @wanted_data[SCMovesetsData::ABILITYINDEX], 
                                                @wanted_data[SCMovesetsData::SPECIES], 
                                                @wanted_data[SCMovesetsData::FORM],
                                                @wanted_data[SCMovesetsData::ABILITY].class.name)
      end 
			pbSetSystemFont(@sprites["2t"].bitmap)
			textpos=[          
				[lr,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["2t"].bitmap,textpos)
			
			
			# ---------------------------------
			# Moves
      
			# Move 1
			# Line 4, column 1 
			@sprites["3t"].bitmap.clear
			
			pbSetSystemFont(@sprites["3t"].bitmap)
			textpos=[          
				[getMoveFor(@wanted_data[SCMovesetsData::MOVE1]),110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["3t"].bitmap,textpos)
			
			
			# Move 2
			# Line 4, column 2 
			pbSetSystemFont(@sprites["3t"].bitmap)
			textpos=[          
				[getMoveFor(@wanted_data[SCMovesetsData::MOVE2]),325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["3t"].bitmap,textpos)
			
			# Move 3 
			# Line 5, column 1 
			@sprites["4t"].bitmap.clear

			pbSetSystemFont(@sprites["4t"].bitmap)
			textpos=[          
				[getMoveFor(@wanted_data[SCMovesetsData::MOVE3]),110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["4t"].bitmap,textpos)
			
			# Move 4
			# Line 5, column 2 
			pbSetSystemFont(@sprites["4t"].bitmap)
			textpos=[          
				[getMoveFor(@wanted_data[SCMovesetsData::MOVE4]),325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["4t"].bitmap,textpos)
			
			
			# ---------------------------------
			# EVs  
			# Line 6, column 1 
			@sprites["5t"].bitmap.clear
			
			pbSetSystemFont(@sprites["5t"].bitmap)
			qq=SCTB.EVIVToStr(@wanted_data[SCMovesetsData::EV])
			textpos=[          
				[qq,110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["5t"].bitmap,textpos)
			
			
			# ---------------------------------
			# IVs 
			# Line 6, column 2
			pbSetSystemFont(@sprites["5t"].bitmap)
			qq=SCTB.EVIVToStr(@wanted_data[SCMovesetsData::IV])
			textpos=[          
				[qq,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["5t"].bitmap,textpos)
			
			
			# ----------------------------------
			# Nickname 
			# Line 7, column 1
			@sprites["6t"].bitmap.clear
			
      nickname = (@wanted_data[SCMovesetsData::NICKNAME] ? @wanted_data[SCMovesetsData::NICKNAME] : "")
			pbSetSystemFont(@sprites["6t"].bitmap)
			textpos=[          
				[nickname,110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["6t"].bitmap,textpos)
			
			
			# ----------------------------------
			# Shiny
			# Line 7, column 2
			s = "Not shiny"
			s = "Shiny" if @wanted_data[SCMovesetsData::SHINY]
			pbSetSystemFont(@sprites["6t"].bitmap)
			textpos=[          
			[s,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["6t"].bitmap,textpos)
			
			
			
			# ----------------------------------
			# Level 
			# Line 8, column 1
			@sprites["7t"].bitmap.clear
			
			pbSetSystemFont(@sprites["7t"].bitmap)
			textpos=[          
				["Level: " + @wanted_data[SCMovesetsData::LEVEL].to_s,110,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["7t"].bitmap,textpos)
			
			
			# ----------------------------------
			# Gender 
      genderdata = scGender(@wanted_data[SCMovesetsData::BASESPECIES], @wanted_data[SCMovesetsData::FORM], true)
			
			g = "Random" 
      if genderdata.length == 1
        g = genderdata[0]
      elsif [0,1].include?(@wanted_data[SCMovesetsData::GENDER])
        g = genderdata[@wanted_data[SCMovesetsData::GENDER]]
      end 
			
			pbSetSystemFont(@sprites["7t"].bitmap)
			textpos=[          
				[g,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites["7t"].bitmap,textpos)
			

		end 
	end
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		#Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		Graphics.transition
		return @wanted_data 
	end
	
	
	
	def update
		pbUpdateSpriteHash(@sprites)

		drawSelector
		
		
		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#@wanted_data = -1
			@exit = true
		end

		if Input.trigger?(Input::C)
			pbPlayDecisionSE
			do_command
		end

		if Input.trigger?(Input::UP)
			@index -= 1
			if @index < 0
				@index = 8
			end
		end
		if Input.trigger?(Input::DOWN)
			@index += 1
			if @index > 8
				@index = 0
			end
		end
		
		if Input.trigger?(Input::RIGHT)
			@column = 1 - @column
			# if @column == 2
				# @column = 0
				# self.showBaseStats
			# end 
		end 
		
		if Input.trigger?(Input::LEFT)
			@column = 1 - @column
			# if @column == -1
				# @column = 1
				# self.showBaseStats
			# end 
		end 
	end
	
	
	
	def resetMoves
		@species_name = "????"
		@base_stats = [] 
		
		if @wanted_data[SCMovesetsData::SPECIES]
			@base_stats = self.getBaseStats
			@species_name = PBSpecies.getName(@wanted_data[SCMovesetsData::SPECIES])
			
			# This file is made in scCompileSCLearnedMoves
			# It uses PBS/sclearned.txt, generated by generate_movesets.py. 
			all_moves = scLoadLearnedMoves
			# Should be species -> list of moves. 
			@moves = []
      @numbermoves=all_moves[@wanted_data[SCMovesetsData::FSPECIES]]
      @numbermoves=all_moves[@wanted_data[SCMovesetsData::BASESPECIES]] if !@numbermoves
      @numbermoves=all_moves[@wanted_data[SCMovesetsData::SPECIES]] if !@numbermoves
      
			
			for mv in @numbermoves
				@moves.push(PBMoves.getName(mv))
			end 
			
		end 
	end 
	
	
  
  def updateDictOfSpecies
    return if @dict_of_species.keys.length > 0 && 
              @old_filter_by_type == @filter_by_type && 
              @old_filter_by_role == @filter_by_role && 
              @old_filter_by_move == @filter_by_move
    
    begin 
    @dict_of_species = SCTB.filterSpeciesByTypeMoveRole(@tier, @filter_by_type, @filter_by_move, @filter_by_role)
    @old_filter_by_type = @filter_by_type
    @old_filter_by_role = @filter_by_role
    @old_filter_by_move = @filter_by_move
    rescue 
    pbMessage("Filters yielded no Pokémon.")
    # Revert to old filters
    @filter_by_type = @old_filter_by_type
    @filter_by_role = @old_filter_by_role
    @filter_by_move = @old_filter_by_move
    end 
  end 
  
  
	
	def do_command
		if @index == 0
			# Species select 
			msg = ""
      commands2 = ["Cancel"]
      
      # Change species 
      if @tier.numAllowed() < 50
        s = SCTB.shortTierSpecies(@tier, @wanted_data[SCMovesetsData::FSPECIES])
        if s[0] && s[0] > 0
          @wanted_data = SCTB.initData(s[0])
          resetMoves
        elsif s[0] && s[0] == -2 
          # Choose moveset
            temp = SCTB.movesetMenu(@wanted_data[SCMovesetsData::FSPECIES], @tier)
            @wanted_data = temp if temp 
        end 
      else
        # Choose Pokemons by letter. 
        updateDictOfSpecies
        
        while true
          filter_by_type_index = 1 # index of the option "type filter", might change if option to choose a moveset
          filter_by_move_index = 2 # index of the option "move filter", might change if option to choose a moveset
          filter_by_role_index = 3 # index of the option "role filter", might change if option to choose a moveset
          choose_moveset_command = false 
          commands2 = ["Cancel"]
          
          if @wanted_data[SCMovesetsData::SPECIES]
            commands2.push("Choose moveset")
            choose_moveset_command = true
            filter_by_type_index += 1
            filter_by_move_index += 1
            filter_by_role_index += 1
          end 
          
          commands2.push("Type filter")
          commands2.push("Move filter")
          commands2.push("Role filter")
          
          alphabet = ["A","B","C","D","E","F",
                "G","H","I","J","K","L",
                "M","N","O","P","Q","R",
                "S","T","U","V","W","X",
                "Y","Z"]

          for letter in alphabet
            # For correct order. 
            if @dict_of_species.keys.include?(letter)
              commands2.push(letter)
            end 
          end
          
          msg = "Choose a letter (" + self.filterMessage + ")"
          c2 = pbMessage(msg, commands2, -1, nil, 1)
          
          if c2 == 0 
            break 
            
          elsif choose_moveset_command && c2 == 1
            temp = SCTB.movesetMenu(@wanted_data[SCMovesetsData::FSPECIES], @tier)
            @wanted_data = temp if temp 
            break 
            
          elsif c2 == filter_by_type_index
            # Filter Pokémons by type. 
            list_types = ["(None)", "Bug", "Dark", "Dragon", "Electric", "Fairy", 
                "Fighting", "Fire", "Flying", "Ghost", "Grass", 
                "Ground", "Ice", "Normal", "Poison", "Psychic", 
                "Rock", "Steel", "Water"]
            
            cmd = pbMessage("Which type do you want?", list_types, -1)
            
            if cmd > 0
              @filter_by_type = getConst(PBTypes,list_types[cmd].upcase)
            elsif cmd == 0 
              @filter_by_type = nil 
            end 
            
            updateDictOfSpecies
            
          elsif c2 == filter_by_move_index
            # Filter Pokémons by move. 
            move_menu = scLoadMoveMenu
            cmd = 1
            while cmd > 0 
              cmd = pbMessage("Choose a move to filter with.", ["None"] + alphabet, -1)
              
              if cmd > 0
                letter = alphabet[cmd-1]
                @filter_by_move = pbChooseList(move_menu[letter],0,0)
                @filter_by_move = nil if @filter_by_move == 0 
              elsif cmd == 0 
                @filter_by_move = nil 
              end 
              break 
            end 
            
            updateDictOfSpecies
            
          elsif c2 == filter_by_role_index
            # Filter Pokémons by role. 
            role_menu = scLoadRolesToPoke
            
            big_role = 1
            categ = 1
            
            while big_role > 0 && categ > 0
              # Big role 
              big_role = pbMessage("Choose a role.", 
                    ["None", "Lead", "Offensive", "Defensive", "Other"], -1)
              
              break if big_role == -1
              
              if big_role == 0 # No filter 
                @filter_by_role = nil 
                break 
              end 
              
              # Category 
              categ = pbMessage("Choose a role.", 
                    ["All", "Physical", "Special", "Mixed"], -1)
              break if categ == -1
              
              # if categ == 0 # No filter 
                # @filter_by_role = nil 
                # break 
              # end 
              
              @filter_by_role = big_role * 10 + categ
              break 
            end 
            
            updateDictOfSpecies
            
          elsif c2 > filter_by_role_index
            letter = commands2[c2]
            s = SCTB.orderSpecies(@dict_of_species[letter])
            
            if s[0] > 0
              @wanted_data = SCTB.initData(s[0])
              resetMoves
              
              ans = pbMessage("Choose moveset?", ["Yes", "No"], 1)
              
              if ans == 0
                temp = SCTB.movesetMenu(@wanted_data[SCMovesetsData::FSPECIES], @tier)
                @wanted_data = temp if temp 
              end 
              break 
            end 
          end
        end 
      end 
			
		elsif @index == 1
			# Nature + Form 
			
			if @column == 0
				# Nature 
				
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting a nature.")
				else
          commands = []
          commands.push(_INTL("Cancel"))
          (PBNatures.getCount).times do |i|
            statUp   = PBNatures.getStatRaised(i)
            statDown = PBNatures.getStatLowered(i)
            if statUp!=statDown
              text = _INTL("{1} (+{2}, -{3})",PBNatures.getName(i),
                 PBStats.getNameBrief(statUp),PBStats.getNameBrief(statDown))
            else
              text = _INTL("{1} (---)",PBNatures.getName(i))
            end
            commands.push(text)
          end
					# Break
					temp=pbMessage("Select a nature.",commands)
					@wanted_data[SCMovesetsData::NATURE]=temp - 1 if temp > 0
				end
			else
				# Form 
				
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting a form.")
				else
					result = SCTB.formMenu(@wanted_data[SCMovesetsData::BASESPECIES])
					
					if result[SCFormData::BASESPECIES]
          
            fspecies = pbGetFSpeciesFromForm(result[SCFormData::BASESPECIES], result[SCFormData::FORM])
            @wanted_data = SCTB.initData(fspecies) # Requirements are handled in this funciotn.
            
						# @wanted_data[SCMovesetsData::FORM] = result[SCFormData::FORM]
						# @wanted_data[SCMovesetsData::BASESPECIES] = result[SCFormData::BASESPECIES]
            # @wanted_data[SCMovesetsData::FORMNAME] = result[SCFormData::FORMNAME]
						# # [ 0: Form, 1: Item, 2: Ability, 3: Move, 4: Gender, 5: Form name, 6: asks for move reinit]
						
						# # Item :
						# if result[SCFormData::REQITEM]
							# @wanted_data[SCMovesetsData::ITEM] = result[SCFormData::REQITEM]
						# end 
						
						# # Ability :
            # if result[SCFormData::REQABILITY]
              # @wanted_data[SCMovesetsData::ABILITYINDEX] = SCTB.getAbilityIndex(result[SCFormData::REQABILITY], @wanted_data[SCMovesetsData::FSPECIES])
            # end 
						
						# # Gender :
						# if result[SCFormData::REQGENDER]
							# @wanted_data[SCMovesetsData::GENDER] = result[SCFormData::REQGENDER]
						# end 
						
						# # Move :
            # @wanted_data[SCMovesetsData::MOVE1] = nil
            # @wanted_data[SCMovesetsData::MOVE2] = nil 
            # @wanted_data[SCMovesetsData::MOVE3] = nil 
            # @wanted_data[SCMovesetsData::MOVE4] = nil 
            
            resetMoves
            
						if result[SCFormData::REQMOVE]
							@wanted_data[SCMovesetsData::MOVE1] = result[SCFormData::REQMOVE]
						end 
            
            drawWantedData
            
            pbMessage("Due to form change, the moves where reinitialised.")
            
            
            ans = pbMessage("Choose moveset?", ["Yes", "No"], 1)
            
            if ans == 0
              temp = SCTB.movesetMenu(@wanted_data[SCMovesetsData::FSPECIES], @tier)
              @wanted_data = temp if temp 
            end 

					end 
				end
			end 
			
		elsif @index == 2
			# Item + Ability
			
			if @column == 0
				# Item 
				
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting an item.")
				else
					res = SCTB.itemsMenu(@wanted_data[SCMovesetsData::BASESPECIES], @wanted_data)
					@wanted_data[SCMovesetsData::ITEM] = res if res != -1
				end
			else 
				# Ability
				
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting an ability.")
				else
					ret = SCTB.getAbilitiesFromSpecies(@wanted_data[SCMovesetsData::FSPECIES])
					ary=[]
					
					for i in 0...ret.length
						ary.push(PBAbilities.getName(ret[i][0]))
					end
          choice = pbMessage("Which ability would you like?", ary)
					@wanted_data[SCMovesetsData::ABILITYINDEX] = ret[choice][1]
					@wanted_data[SCMovesetsData::ABILITY] = ret[choice][0]
				end
			end 
			
			
		elsif @index == 3
			# Moves 1 and 2 
			
			m=pbMessage("Choose a move.",@moves, -1)
			if m > -1
        move = self.chooseHiddenPower(@numbermoves[m])
        @wanted_data[SCMovesetsData::MOVE1 + @column]=move if move 
			end 
			
			
		elsif @index == 4
			# Moves 3 and 4
			
			m=pbMessage("Choose a move.",@moves,-1)
			if m>-1 
        move = self.chooseHiddenPower(@numbermoves[m])
				@wanted_data[SCMovesetsData::MOVE3 + @column]= move if move
			end 
			
		elsif @index == 5
			# EVs + IVs 
			
			if @column == 0
				# EVs 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting EVs.")
				else
					for i in 0..8
						k = i.to_s
						@sprites[k+"t"].bitmap.clear
					end
					# scene=SCWantedDataEVs.new(@wanted_data)
					scene=SCWantedDataStats.new(@wanted_data, @base_stats, 0)
					@wanted_data=scene.main
					Graphics.freeze
					create_spriteset
					Graphics.transition
					loop do
						Graphics.update
						Input.update
						update
						break if @exit
					end
				end
			else 
				# IVs 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before selecting IVs.")
				else
					for i in 0..8
						next if i == 7 # There is no 7th sprite. 
						k = i.to_s
						@sprites[k+"t"].bitmap.clear
					end
					# scene=SCWantedDataIVs.new(@wanted_data)
					scene=SCWantedDataStats.new(@wanted_data, @base_stats, 1)
					@wanted_data=scene.main
					Graphics.freeze
					create_spriteset
					Graphics.transition
					loop do
						Graphics.update
						Input.update
						update
						break if @exit
					end
				end
			end 
			
			
		elsif @index == 6
			# Nickname + Shiny 
			
			if @column == 0
				# Nickname 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before giving a nickname.")
				else
					# Break (message,currenttext,passwordbox,maxlength
					temp=pbMessageFreeText("Select a nickname.","",false,12)
					@wanted_data[SCMovesetsData::NICKNAME]=temp
				end 
			else 
				# Shiny 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before saying if it is shiny.")
				else
					cmds = ["Yes", "No"]
					
					ans = pbMessage("Should the Pokémon be shiny?", cmds)
					@wanted_data[SCMovesetsData::SHINY] = false 
					@wanted_data[SCMovesetsData::SHINY] = true if ans == 0 or ans == "Yes"
				end 
			end 
		
		elsif @index == 7
			# Level + Gender 
			
			if @column == 0
				# Level 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before choosing its level.")
				else
					params=ChooseNumberParams.new
					params.setRange(0, 120)
					params.setDefaultValue(@wanted_data[SCMovesetsData::LEVEL])
					params.setCancelValue(@wanted_data[SCMovesetsData::LEVEL])
					f=pbMessageChooseNumber(
					_INTL("Set the level (max. 120)."),params) { }
					@wanted_data[SCMovesetsData::LEVEL]=f
				end 
			else 
				# Gender 
				if !@wanted_data[SCMovesetsData::SPECIES]
					pbMessage("Select a species before choosing its gender.")
				else
					cmds=scGender(@wanted_data[SCMovesetsData::BASESPECIES], @wanted_data[SCMovesetsData::FORM], true)
          cmds.push("Random") if cmds.length == 2
          
					@wanted_data[SCMovesetsData::GENDER] = pbMessage("Which gender do you want?", cmds)
					
          @wanted_data[SCMovesetsData::GENDER] = nil if cmds.length == 1
          @wanted_data[SCMovesetsData::GENDER] = nil if @wanted_data[SCMovesetsData::GENDER] == 2
				end 
			end 
			
		elsif @index == 8
			canDo=true
			if !@wanted_data[SCMovesetsData::SPECIES]
				pbMessage("No species is defined.")
				canDo=false
			end
			if !@wanted_data[SCMovesetsData::ITEM]
				pbMessage("No item is defined.")
				canDo=false
			end
			if !@wanted_data[SCMovesetsData::NATURE]
				pbMessage("No nature is defined.")
				canDo=false
			end
			if !@wanted_data[SCMovesetsData::NICKNAME]
				@wanted_data[SCMovesetsData::NICKNAME] = ""
			end
			# if @wanted_data[SCMovesetsData::EV][0]
				# pbMessage("No EVs are defined.")
				# canDo=false
			# end
			if !@wanted_data[SCMovesetsData::MOVE1] && !@wanted_data[SCMovesetsData::MOVE2] && !@wanted_data[SCMovesetsData::MOVE3] && !@wanted_data[SCMovesetsData::MOVE4]
				pbMessage("No moves are defined.")
				canDo=false
			end
			
			@exit=true
		end
		
		drawWantedData
	end
	
  
  
  def filterMessage
    msg = _INTL("Current filters: ")
    
    if !@filter_by_move && !@filter_by_role && !@filter_by_type
      msg += "none." 
    else 
      msg_move = (@filter_by_move ? PBMoves.getName(@filter_by_move) : "all moves")
      msg_type = (@filter_by_type ? PBTypes.getName(@filter_by_type) : "all types")
      
      
      msg_role = "all roles"
      
      if @filter_by_role
        case @filter_by_role % 10
        when 1 
          msg_role += "physical "
        when 2
          msg_role += "special "
        else 
          msg_role += "mixed "
        end 
        
        case (@filter_by_role / 10).floor
        when 1 
          msg_role = "lead"
        when 2
          msg_role = "offensive"
        when 3 
          msg_role = "defensive"
        else 
          msg_role = "other"
        end 
      end 
      
      msg = _INTL("{1}, {2}, {3}", msg_type, msg_move, msg_role)
    end 
    
    return msg 
  end 
	
  
  def chooseHiddenPower(move)
    return move if move != PBMoves::HIDDENPOWER
    
    hp_choice = ["(None)", "Bug", "Dark", "Dragon", "Electric", "Fairy", 
                "Fighting", "Fire", "Flying", "Ghost", "Grass", 
                "Ground", "Ice", "Normal", "Poison", "Psychic", 
                "Rock", "Steel", "Water"]
    
    chosen_hp = [nil, 
      PBMoves::HIDDENPOWERBUG,
      PBMoves::HIDDENPOWERDARK,
      PBMoves::HIDDENPOWERDRAGON,
      PBMoves::HIDDENPOWERELECTRIC,
      PBMoves::HIDDENPOWERFAIRY,
      PBMoves::HIDDENPOWERFIGHTING,
      PBMoves::HIDDENPOWERFIRE,
      PBMoves::HIDDENPOWERFLYING,
      PBMoves::HIDDENPOWERGHOST,
      PBMoves::HIDDENPOWERGRASS,
      PBMoves::HIDDENPOWERGROUND,
      PBMoves::HIDDENPOWERICE,
      PBMoves::HIDDENPOWERNORMAL,
      PBMoves::HIDDENPOWERPOISON,
      PBMoves::HIDDENPOWERPSYCHIC,
      PBMoves::HIDDENPOWERROCK,
      PBMoves::HIDDENPOWERSTEEL,
      PBMoves::HIDDENPOWERWATER
      ]
    choice = pbMessage(_INTL("Choose what type for {1}?", PBMoves.getName(move)), hp_choice, 0, nil, 0)
    return chosen_hp[choice]
  end 
  
  
	
	def showBaseStats
		if @wanted_data[SCMovesetsData::FSPECIES]
			for i in 0..8
				k = i.to_s
				@sprites[k+"tt"].bitmap.clear
				@sprites[k+"t"].bitmap.clear
			end
			scene=SCBaseStats.new(@wanted_data[SCMovesetsData::BASESPECIES], @wanted_data[SCMovesetsData::FORM], @species_name, @wanted_data[SCMovesetsData::FORMNAME], @base_stats)
			scene.main
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
	end 
end




def scSpeciesHasType(speciesid, form, type)
  if form == -1 
    speciesid = pbGetSpeciesFromFSpecies(speciesid)
    form = speciesid[1]
    speciesid = speciesid[0]
  end 
	return true if type==nil 
	types = scGetSpeciesTypes(speciesid, form)
	return types.include?(type)
end 




def scGetSpeciesTypes(speciesid, formSimple)
  ret1 = pbGetSpeciesData(speciesid,formSimple,SpeciesType1)
  ret2 = pbGetSpeciesData(speciesid,formSimple,SpeciesType2)
  ret = [ret1]
  ret.push(ret2) if ret2 && ret2!=ret1
  return ret
end 




def scConvertPartyToString(party)
	File.open("Eggs/scresult.txt", "w") do |f|
		for i in 0...6
			# Species 
			species_name = pbGetSpeciesConst(party[i][0])
			s = species_name + ","
			# Level 
			s += party[i][2].to_s + ","
			# Gender 
			s += party[i][3].to_s + ","
			# 4 = Ability 
			s += party[i][4].to_s + ","
			# 5 = Items 
			if party[i][5] > 0
				s += pbGetItemConst(party[i][5]) + ","
			else 
				s += ","
			end 
			# 6 = Nature 
			if party[i][6] >= 0
				s += getConstantName(PBNatures,party[i][6]) + ","
			else 
				s += "," 
			end 
			# 7 = Nickname 
			s += party[i][7] + ","
			# 8 = IVs 
			for iv in party[i][8]
				s += iv.to_s + ","
			end 
			# 9 = moves 
			for mv in party[i][9]
				if mv > -1
					s += pbGetMoveConst(mv) + ","							
				else 
					s += ","
				end 
			end 
			# 10 = EVs 
			for iv in party[i][10]
				s += iv.to_s + ","
			end 
			
			# 11 = Shiny
			s += party[i][11].to_s + ","
			# 12 = Form (unimplemented)
			s += party[i][12].to_s
			
			f.puts(s)
		end 
	end 
end 




def scGender(speciesid, formSimple, want_string)
  ret = []
  genderRate = pbGetSpeciesData(speciesid,formSimple,SpeciesGenderRate)
  case genderRate
  when PBGenderRates::AlwaysMale;   ret = [0] ; ret2 = ["Male"]
  when PBGenderRates::AlwaysFemale; ret = [1] ; ret2 = ["Female"]
  when PBGenderRates::Genderless;   ret = [2] ; ret2 = ["Genderless"]
  else
    ret = [0, 1]
    ret2 = ["Male", "Female"]
  end
  # Return gender for species that can be male or female
  
  return ret2 if want_string
  return ret 
end 




###############################################################################
# SCBaseStats - DEPRECATED
# 
# Prints the base stats of the Pokemon + its types. 
# Class called in SCWantedDataComplete. 
###############################################################################

class SCBaseStats
	
	def initialize(speciesid, form, species_name, form_name, base_stats)
		@exit = false
		@speciesid = speciesid
		@species_name = species_name
		@form_name = (form_name ? form_name : "")
		@base_stats = base_stats
    @form = form
	end
	
	
	
	def drawTypes
		types = scGetSpeciesTypes(@speciesid, @form)
		
		@sprites["Ttt"].bitmap.clear
		pbSetSystemFont(@sprites["Ttt"].bitmap)
		textpos=[          
			[PBTypes.getName(types[0]),80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["Ttt"].bitmap,textpos)
		
		if !types[1] || types[0] == types[1]
			types[1] = ""
		else 
			types[1] = PBTypes.getName(types[1])
		end 
		
		@sprites["Tt"].bitmap.clear
		pbSetSystemFont(@sprites["Tt"].bitmap)
		textpos=[          
			[types[1],350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["Tt"].bitmap,textpos)
	end
	
	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Base stats",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
	
	
	
	def create_spriteset
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")

    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		# For Species + form. 
		sprites_other = ["A", "T"]
		for i in 0...2
			k = sprites_other[i]
			kt = k + "t"
			ktt = kt + "t"
			@sprites[k] = IconSprite.new
			@sprites[k].setBitmap("Graphics/Pictures/GTS/iv_bar")
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= @sprites[k].bitmap.width / 2
			@sprites[k].y = 50 + i*40 

			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y

			@sprites[ktt] = IconSprite.new
			@sprites[ktt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktt].x = @sprites[k].x
			@sprites[ktt].y = @sprites[k].y
		end 
		
		# For base stats.
		for i in 0...6
			k = i.to_s 
			kt = k + "t"
			ktt = kt + "t"
			
			@sprites[k] = IconSprite.new
			@sprites[k].setBitmap("Graphics/Pictures/GTS/iv_bar")
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= @sprites[k].bitmap.width / 2
			@sprites[k].y = 130 + 40 * i

			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y

			@sprites[ktt] = IconSprite.new
			@sprites[ktt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktt].x = @sprites[k].x
			@sprites[ktt].y = @sprites[k].y
		end 
		
		
		
		# @sprites["6"] = SCTB_Button.new(Graphics.width/2, 290, "Back")
		# @sprites["6"].x -= @sprites["5"].bitmap.width / 2
		# @sprites["6"].y = 386
		
		
		# stats_name = ["HP", "Attack", "Defense", "Speed", "Sp. Atk", "Sp. Def"]
		
		# for i in 0...6
			# ktt = i.to_s + "tt"
			# pbSetSystemFont(@sprites[ktt].bitmap)
			# textpos=[          
				# [stats_name[i],80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
			# ]
			# pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
		# end 
		
		
		# bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		# @sprites["selection_l"] = IconSprite.new
		# @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		# @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		# @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))

		# @sprites["selection_r"] = IconSprite.new
		# @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		# @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		# @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))

		# @sprites["selection_l"].x = @sprites["#{@index}"].x-2
		# @sprites["selection_l"].y = @sprites["#{@index}"].y-2
		# @sprites["selection_r"].x = @sprites["#{@index}"].x+
		# @sprites["#{@index}"].bitmap.width-18
		# @sprites["selection_r"].y = @sprites["#{@index}"].y-2

		drawWantedData
	end
	
	
	
	def drawWantedData
		
		drawHeader
		
		# Name + form name. 
		@sprites["Att"].bitmap.clear
		pbSetSystemFont(@sprites["Att"].bitmap)
		textpos=[          
			[@species_name,80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["Att"].bitmap,textpos)
		
		@sprites["At"].bitmap.clear
		pbSetSystemFont(@sprites["At"].bitmap)
		textpos=[          
			[@form_name,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["At"].bitmap,textpos)
		
		
		# Types:
		drawTypes
		
		
		stats_name = ["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
		
		for i in 0...6
			kt = i.to_s + "t"
			ktt = kt + "t"
			
			@sprites[ktt].bitmap.clear
			pbSetSystemFont(@sprites[ktt].bitmap)
			textpos=[          
				[stats_name[i],80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
			
			
			i_prime = scToDumbIndex(i)
			
			@sprites[kt].bitmap.clear
			pbSetSystemFont(@sprites[kt].bitmap)
			textpos=[          
				[@base_stats[i_prime].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[kt].bitmap,textpos)
		end 

	end 
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		
		Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		
		return @wanted_data
	end
	
	
	
	def update
		if !@sprites
			@sprites = {}

			@sprites["background"] = IconSprite.new
			@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
		end

		pbUpdateSpriteHash(@sprites) 

		# @sprites["selection_l"].x = @sprites["#{@index}"].x-2
		# @sprites["selection_l"].y = @sprites["#{@index}"].y-2
		# @sprites["selection_r"].x = @sprites["#{@index}"].x+
		# @sprites["#{@index}"].bitmap.width-18
		# @sprites["selection_r"].y = @sprites["#{@index}"].y-2

		if Input.trigger?(Input::B) || Input.trigger?(Input::C) || Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
			pbPlayCancelSE
			#  @wanted_data #= -1
			@exit = true
		end
	end
	
	
	
	def real_index
		return scToDumbIndex(@index)
	end 
end




###############################################################################
# SCWantedDataIVs - DEPRECATED
# 
# Code derived from the GTSWantedDataIVs class.
# Submenu for the team builder. 
# Allows the modification of the IVs of a given Pokémon. 
# A subclass of this class is made for EVs.
# By StCooler. 
###############################################################################

class SCWantedDataIVs
	
	def initialize(data)
		@exit = false
		@wanted_data = data
		@index = 0
		@max_value = 31 # For IVs, the max value is 31
		@default_value = 31 # For IVs, the default value is 31. 
		@stat_name = "IV"
		@index_main_data = SCMovesetsData::IV # 8 for IVs, 10 for EVs. 
		# These two attributes are meant to be changed for EVs. 
		@value_choices_text = ["31", "30", "0", "Other"]
		@value_choices = [31, 30, 0]
	end
	
	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Choice of " + @stat_name + "s",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
	
	
	
	def create_spriteset
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
    
    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		
		for i in 0...6
			k = i.to_s 
			kt = k + "t"
			ktt = kt + "t"
			
			@sprites[k] = IconSprite.new
			@sprites[k].setBitmap("Graphics/Pictures/GTS/iv_bar")
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= @sprites[k].bitmap.width / 2
			@sprites[k].y = 45 * i + 50
			
			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y

			@sprites[ktt] = IconSprite.new
			@sprites[ktt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktt].x = @sprites[k].x
			@sprites[ktt].y = @sprites[k].y
		end 
		
		
		@sprites["6"] = SCTB_Button.new(Graphics.width/2, 290, "Back")
		@sprites["6"].x -= @sprites["5"].bitmap.width / 2
		@sprites["6"].y = 45 * 6 + 50 
		
		stats_name = ["HP", "Attack", "Defense", "Speed", "Sp. Atk", "Sp. Def"]
		
		for i in 0...6
			ktt = i.to_s + "tt"
			pbSetSystemFont(@sprites[ktt].bitmap)
			textpos=[          
				[stats_name[i],40,0,0,Color.new(248,248,248),Color.new(40,40,40)]
			]
			pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
		end 
		
		
		bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		@sprites["selection_l"] = IconSprite.new
		@sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		@sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))

		@sprites["selection_r"] = IconSprite.new
		@sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		@sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))

		@sprites["selection_l"].x = @sprites["#{@index}"].x-2
		@sprites["selection_l"].y = @sprites["#{@index}"].y-2
		@sprites["selection_r"].x = @sprites["#{@index}"].x+
		@sprites["#{@index}"].bitmap.width-18
		@sprites["selection_r"].y = @sprites["#{@index}"].y-2

		drawWantedData
	end
	
	
	
	def drawWantedData
		
		drawHeader
		
		if !@wanted_data[@index_main_data].is_a?(Array)
			@wanted_data[@index_main_data]=[]
			for i in 0..5
				@wanted_data[@index_main_data][i]= @default_value
			end
		end
		
		stats_name = ["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
		
		for i in 0...6
			kt = i.to_s + "t"
			ktt = kt + "t"
			
      
      # ESSAYER DE TOUT METTRE SUR UN MEME ECRAN ? 
      
      
			# @sprites[ktt].bitmap.clear
			# pbSetSystemFont(@sprites[ktt].bitmap)
			# textpos=[          
				# [stats_name[i],40,0,0,Color.new(248,248,248),Color.new(40,40,40)],
			# ]
			# pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
			
			
			i_prime = scToDumbIndex(i)
			
			@sprites[kt].bitmap.clear
			pbSetSystemFont(@sprites[kt].bitmap)
			textpos=[          
				[@wanted_data[@index_main_data][i_prime].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[kt].bitmap,textpos)
		end 

	end 
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		
		Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		
		return @wanted_data
	end
	
	
	
	def update
		if !@sprites
			@sprites = {}

			@sprites["background"] = IconSprite.new
			@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
		end

		pbUpdateSpriteHash(@sprites) 

		@sprites["selection_l"].x = @sprites["#{@index}"].x-2
		@sprites["selection_l"].y = @sprites["#{@index}"].y-2
		@sprites["selection_r"].x = @sprites["#{@index}"].x+
		@sprites["#{@index}"].bitmap.width-18
		@sprites["selection_r"].y = @sprites["#{@index}"].y-2

		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#  @wanted_data #= -1
			@exit = true
		end

		if Input.trigger?(Input::C)
			pbPlayDecisionSE
			do_command
		end

		if Input.trigger?(Input::UP)
			@index -= 1
			if @index < 0
				@index = 6
			end
		end
		
		if Input.trigger?(Input::DOWN)
			@index += 1
			if @index > 6
				@index = 0
			end
		end
	end
	
	
	
	def do_command
		if @index >= 0 && @index <= 5
			cmd2=@index
			stats=["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
			
			ev_str = _INTL("Set the " + @stat_name + " for {1} (max. {2}).",stats[cmd2], @max_value)
			
			res = pbMessage(ev_str, @value_choices_text, -1, nil, 0)
			
			r_index = self.real_index
			
			if res == 0 or res == 1 or res == 2 
				@wanted_data[@index_main_data][r_index]=@value_choices[res]
				
			else # res == 2
				params = ChooseNumberParams.new
				params.setRange(0,@max_value)
				params.setDefaultValue(@wanted_data[@index_main_data][r_index])
				params.setCancelValue(@wanted_data[@index_main_data][r_index])
				f=pbMessageChooseNumber(ev_str, params) { }
				@wanted_data[@index_main_data][r_index]=f
			end 
		else
			@exit = true 
		end
		
		drawWantedData
	end
	
	
  
	def real_index
		return scToDumbIndex(@index)
	end 
end




def scToDisplayedIndex(i)
	# Conversion between the dumb Pokémon Essentials listing (HP, Atk, Def, Speed, Sp.Atk, Sp.Def)
	# to the intuitive, displayed listing (HP, Atk, Def, Sp.Atk, Sp.Def, Speed)
	indices = [0, 1, 2, 5, 3, 4]
	return indices[i]
end 




def scToDumbIndex(i)
	# Conversion between the intuitive, displayed listing (HP, Atk, Def, Sp.Atk, Sp.Def, Speed), 
	# to the dumb Pokémon Essentials listing (HP, Atk, Def, Speed, Sp.Atk, Sp.Def)
	indices = [0, 1, 2, 4, 5, 3]
	return indices[i]
end 




class SCWantedDataEVs < SCWantedDataIVs
	
	def initialize(data)
		super(data)
		@exit = false
		@wanted_data = data
		@index = 0
		@max_value = 255 # For IVs, the max value is 31
		@default_value = 0 # For IVs, the default value is 31. 
		@stat_name = "EV"
		@index_main_data = SCMovesetsData::EV # 8 for IVs, 10 for EVs 
		@value_choices_text = ["252", "6", "0", "Other"]
		@value_choices = [252, 6, 0]
	end
	
end




###############################################################################
# SCWantedDataStats
# 
# Code derived from the GTSWantedDataIVs class.
# Submenu for the team builder. 
# Allows the modification of the EVs and IVs of a given Pokémon. 
# Allows to see the base stats as well. 
###############################################################################


class SCWantedDataStats
	
	def initialize(data, base_stats, column)
		@exit = false
		@wanted_data = data
		@index = 0
    @column = column # 0 if EV, 1 if IV. 
    @base_stats = base_stats
		# These two attributes are meant to be changed for EVs. 
  end
	
	
	
	def drawHeader
		pbSetSystemFont(@sprites["header"].bitmap)
		textpos=[          
			["Choice of EVs & IVs",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
		]
		pbDrawTextPositions(@sprites["header"].bitmap,textpos)
	end 
	
	
	
	def create_spriteset
		pbDisposeSpriteHash(@sprites) if @sprites
		@sprites = {}
		
		@sprites["background"] = IconSprite.new
		@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
    
    @sprites["header"] = IconSprite.new
    @sprites["header"].bitmap = Bitmap.new(@sprites["background"].bitmap.width, @sprites["background"].bitmap.height)
    @sprites["header"].x = @sprites["background"].x
    @sprites["header"].y = @sprites["background"].y 
    
		drawHeader
		
		
		for i in 0...6
			k = i.to_s 
			kt = k + "t"
			ktt = kt + "t"
			kttt = ktt + "t"
			ktttt = kttt + "t"
			
			@sprites[k] = IconSprite.new
			@sprites[k].setBitmap("Graphics/Pictures/GTS/stat_bar")
			@sprites[k].x = Graphics.width / 2
			@sprites[k].x -= @sprites[k].bitmap.width / 2
			@sprites[k].y = 45 * i + 50
			
			@sprites[kt] = IconSprite.new
			@sprites[kt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kt].x = @sprites[k].x
			@sprites[kt].y = @sprites[k].y

			@sprites[ktt] = IconSprite.new
			@sprites[ktt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktt].x = @sprites[k].x
			@sprites[ktt].y = @sprites[k].y

			@sprites[kttt] = IconSprite.new
			@sprites[kttt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[kttt].x = @sprites[k].x
			@sprites[kttt].y = @sprites[k].y

			@sprites[ktttt] = IconSprite.new
			@sprites[ktttt].bitmap = Bitmap.new(@sprites[k].bitmap.width, 
				@sprites[k].bitmap.height)
			@sprites[ktttt].x = @sprites[k].x
			@sprites[ktttt].y = @sprites[k].y
		end 
		
		
		@sprites["6"] = SCTB_Button.new(Graphics.width/2, 290, "Back")
		@sprites["6"].x -= @sprites["5"].bitmap.width / 2
		@sprites["6"].y = 45 * 6 + 50 
		
		stats_name = ["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
		
		for i in 0...6
			ktt = i.to_s + "tt"
			pbSetSystemFont(@sprites[ktt].bitmap)
			textpos=[          
				[stats_name[i],40,0,0,Color.new(248,248,248),Color.new(40,40,40)]
			]
			pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
		end 
		
		
		bit = Bitmap.new("Graphics/Pictures/GTS/Select")
		@sprites["selection_l"] = IconSprite.new
		@sprites["selection_l"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
		@sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))

		@sprites["selection_r"] = IconSprite.new
		@sprites["selection_r"].bitmap = Bitmap.new(16, 46)
		@sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
		@sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))

		drawSelector

		drawWantedData
	end
	
  
  
	def drawSelector
    if @index == 6
      @sprites["selection_l"].x = @sprites["#{@index}"].x-2
      @sprites["selection_l"].y = @sprites["#{@index}"].y-2
      @sprites["selection_r"].x = @sprites["#{@index}"].x+
        @sprites["#{@index}"].bitmap.width-18
      @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    else 
      @sprites["selection_l"].x = @sprites["#{@index}"].x + 250 + 90 * @column - 2
      @sprites["selection_l"].y = @sprites["#{@index}"].y-2
      @sprites["selection_r"].x = @sprites["#{@index}"].x + 250 + 90 * (@column + 1) -18
      # @sprites["#{@index}"].bitmap.width-18
      @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    end 
	end 
  
	
  
	def drawWantedData
		
		drawHeader
		
		if !@wanted_data[SCMovesetsData::EV].is_a?(Array)
			@wanted_data[SCMovesetsData::EV]=[]
			for i in 0..5
				@wanted_data[SCMovesetsData::EV][i]= 0
			end
		end
    
		if !@wanted_data[SCMovesetsData::IV].is_a?(Array)
			@wanted_data[SCMovesetsData::IV]=[]
			for i in 0..5
				@wanted_data[SCMovesetsData::IV][i]= 31
			end
		end
		
		stats_name = ["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
		
		for i in 0...6
			kt = i.to_s + "t"
			ktt = kt + "t"
			kttt = ktt + "t"
			ktttt = kttt + "t"			
      
      # ESSAYER DE TOUT METTRE SUR UN MEME ECRAN ? 
      
      
			# @sprites[ktt].bitmap.clear
			# pbSetSystemFont(@sprites[ktt].bitmap)
			# textpos=[          
				# [stats_name[i],40,0,0,Color.new(248,248,248),Color.new(40,40,40)],
			# ]
			# pbDrawTextPositions(@sprites[ktt].bitmap,textpos)
			
			
			i_prime = scToDumbIndex(i)
      
      
			# Base stats 
			@sprites[kt].bitmap.clear
			pbSetSystemFont(@sprites[kt].bitmap)
			textpos=[ 
				[@base_stats[i_prime].to_s,200,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[kt].bitmap,textpos)
      
			
      # EVs 
			@sprites[kttt].bitmap.clear
			pbSetSystemFont(@sprites[kttt].bitmap)
			textpos=[
				[@wanted_data[SCMovesetsData::EV][i_prime].to_s,295,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[kttt].bitmap,textpos)
      
			
      # IVs 
			@sprites[ktttt].bitmap.clear
			pbSetSystemFont(@sprites[ktttt].bitmap)
			textpos=[
				[@wanted_data[SCMovesetsData::IV][i_prime].to_s,380,4,2,Color.new(248,248,248),Color.new(40,40,40)],
			]
			pbDrawTextPositions(@sprites[ktttt].bitmap,textpos)
		end 

	end 
	
	
	
	def main
		if !@exit
			Graphics.freeze
			create_spriteset
			Graphics.transition
			loop do
				Graphics.update
				Input.update
				update
				break if @exit
			end
		end
		
		Graphics.freeze
		pbDisposeSpriteHash(@sprites)
		
		return @wanted_data
	end
	
	
	
	def update
		if !@sprites
			@sprites = {}

			@sprites["background"] = IconSprite.new
			@sprites["background"].setBitmap("Graphics/Pictures/GTS/gts background")
		end

		pbUpdateSpriteHash(@sprites) 

		drawSelector

		if Input.trigger?(Input::B)
			pbPlayCancelSE
			#  @wanted_data #= -1
			@exit = true
		end

		if Input.trigger?(Input::C)
			pbPlayDecisionSE
			do_command
		end

		if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
			@column = 1 - @column
		end

		if Input.trigger?(Input::UP)
			@index -= 1
			if @index < 0
				@index = 6
			end
		end
		
		if Input.trigger?(Input::DOWN)
			@index += 1
			if @index > 6
				@index = 0
			end
		end
	end
	
	
	
	def do_command
		if @index >= 0 && @index <= 5
      cmd2=@index
      stats=["HP","Attack","Defense","Sp. Atk","Sp. Def","Speed"]
      
      if @column == 0 # EVS 
        ev_str = _INTL("Set the EVs for {1} (max. {2}).",stats[cmd2], 252)
        res = pbMessage(ev_str, ["252", "6", "0", "Other"], -1, nil, 0)
        
        r_index = self.real_index
        
        if res == 0 or res == 1 or res == 2 
          @wanted_data[SCMovesetsData::EV][r_index]=[252, 6, 0][res]
          
        else # res == 2
          params = ChooseNumberParams.new
          params.setRange(0,252)
          params.setDefaultValue(@wanted_data[SCMovesetsData::EV][r_index])
          params.setCancelValue(@wanted_data[SCMovesetsData::EV][r_index])
          f=pbMessageChooseNumber(ev_str, params) { }
          @wanted_data[SCMovesetsData::EV][r_index]=f
        end 
        
      else # IVs 
        iv_str = _INTL("Set the IVs for {1} (max. {2}).",stats[cmd2], 31)
        res = pbMessage(iv_str, ["31", "30", "0", "Other"], -1, nil, 0)
        
        r_index = self.real_index
        
        if res == 0 or res == 1 or res == 2 
          @wanted_data[SCMovesetsData::IV][r_index]=[31, 30, 0][res]
          
        else # res == 2
          params = ChooseNumberParams.new
          params.setRange(0,31)
          params.setDefaultValue(@wanted_data[SCMovesetsData::IV][r_index])
          params.setCancelValue(@wanted_data[SCMovesetsData::IV][r_index])
          f=pbMessageChooseNumber(iv_str, params) { }
          @wanted_data[SCMovesetsData::IV][r_index]=f
        end 
      end 
		else
			@exit = true 
		end
		
		drawWantedData
	end
	
	
  
	def real_index
		return scToDumbIndex(@index)
	end 
end














