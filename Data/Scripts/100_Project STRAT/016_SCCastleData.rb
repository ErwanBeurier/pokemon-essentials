

class SCCastleData
	# I group this in one class in order to instantiate only one class in the PokemonLoad and PokemonSave scripts. 
	attr_reader(:storage)
	attr_reader(:stats)
	attr_reader(:totd_handler)
  attr_reader(:client_battles)
	
	def initialize
		@storage = SCTeamStorage.new 
		@stats = SCBattleStatistics.new
		@totd_handler = SCTierOfTheDayHandler.new 
    @client_battles = SCClientBattlesGenerator.new
	end 
	
end 




def scTeamStorage
	return $CastleHandler.storage 
end 


def scBattleStats
	return $CastleHandler.stats
end 


def scTOTDHandler
	return $CastleHandler.totd_handler
end 

def scClientBattles
  return $CastleHandler.client_battles
end  
