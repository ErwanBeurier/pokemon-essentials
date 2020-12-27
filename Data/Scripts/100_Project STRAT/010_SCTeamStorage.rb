


# def scEmptyPokemonData(speciesid)
  # return 
# end 



class SCTeamStorage
	# Storage of Teams. 
	
	def initialize
		@content = [] 
		@last_i = 0
		
		self.addEmptyTeam
		self.addEmptyTeam
		self.addEmptyTeam
	end 
	
	
	def addTeam(name, party, tier)
		slot = self.newEmptySlot
		slot["Name"] = name 
		slot["Party"] = party # Party list
		slot["Tier"] = tier
		# @content.push(slot)
		self.modifyTeam(self.lastNonEmptyIndex + 1, name, party, tier)
	end 
	
	
	def deleteTeam(index)
		@content.delete_at(index)
	end 
	
	
	def modifyTeam(index, name, party, tier)
		if index > @last_i
			for i in 0...(index - @last_i)
				self.addEmptyTeam
			end 
			
			@last_i = index 
		end 
		
		@content[index]["Name"] = name 
		@content[index]["Party"] = party 
		@content[index]["Tier"] = tier
	end 
	
	
	def modifyPartyAt(index, party)
		@content[index]["Party"] = party 
	end 
	
	def modifyNameAt(index, name)
		@content[index]["Name"] = name 
	end 
	
	def modifyTierAt(index, tier)
		@content[index]["Tier"] = tier
	end 
	
	
	
	def duplicateAt(index)
		self.addTeam(self.nameAt(index), self.partyAt(index), self.tierAt(index))
		return @last_i  
	end 
	
	
	def newEmptySlot
		party = [] 
		
		for i in 0...6
			party.push(self.emptyPokemonData(nil))
		end 
		
		slot = {"Name"=> "", 
				"Party"=> party, 
				"Tier"=> "OTF"}
		
		return slot 
	end 
	
	def partySpritesAt(index)
		while index > self.maxIndex
			self.addEmptyTeam
		end 
		
		icon_file_names = []
		
		for i in 0...6
			if !@content[index]["Party"][i][0]
				icon_file_names.push("Graphics/Icons/icon000")
			else 
				speciesid = @content[index]["Party"][i][SCMovesetsData::SPECIES]
				gender = @content[index]["Party"][i][SCMovesetsData::GENDER]
				shiny = @content[index]["Party"][i][SCMovesetsData::SHINY]
				form = @content[index]["Party"][i][SCMovesetsData::BASEFORM]
				shadow = false 
				icon_file = pbCheckPokemonIconFiles([speciesid, (gender==1),shiny, form, shadow])
				icon_file_names.push(icon_file)
			end 
		end 
		
		return icon_file_names
		
	end 
	
	def partyAt(index)
		return self.getDataAt(index, "Party")
	end 
	
	def nameAt(index)
		return self.getDataAt(index, "Name")
	end 
	
	def tierAt(index)
		return self.getDataAt(index, "Tier")
	end 
	
	def getDataAt(index, key)
		while index > self.maxIndex
			self.addEmptyTeam
		end 
		
		return @content[index][key]
	end 
	
	def numTeams
		return @content.length
	end 
	
	def maxIndex
		return @content.length - 1
	end 
	
	
	
	def emptyPokemonData(speciesid)
		# return SCMovesetsData.newEmpty2(speciesid)
		return SCTB.initData(speciesid)
	end 
	
	
	def addEmptyTeam
		slot = self.newEmptySlot
		slot["Name"] = "Team " + @content.length.to_s 
		@content.push(slot)
	end 
	
	
	def isEmptyTeam?(index)
    return true if !@content[index]
		for i in 0...6
			if @content[index]["Party"][i][SCMovesetsData::SPECIES]
				return false 
			end 
		end 
		
		return true 
	end 
	
	def lastNonEmptyIndex
		max_i = 0 
		
		for i in 0...@content.length
			if !self.isEmptyTeam?(i)
				max_i = i 
			end 
		end 
		
		while max_i > @content.length - 2 
			self.addEmptyTeam
		end 
		
		@last_i = max_i
		
		return max_i
	end 
	
  
  def export(index)
    return if self.isEmptyTeam?(index)
    
    s = "#-------------------------------\r\n"
    s += "[POKEMONTRAINER_Red,Player,X]\r\n"
    s += "LoseText = \"" + @content[index]["Name"] + "\"\r\n"

    for pklist in @content[index]["Party"]
      s += scConvertMovesetToString(pklist, true, false)
    end 
    
    File.open("PBS/scmovesets.txt","a") { |f|
      f.write(s)
    }
    pbMessage(_INTL("Your team {1} is exported.", @content[index]["Name"]))
  end 

end 









