
class SCTierOfTheDayHandler
	
	def initialize
		@tier_dict = {}
		# dictionary: tierid -> int
		# Remembers what random tiers were already given and how many times
		@current_tier = nil
    @already_chosen_tiers = []
		@all_tiers = [] 
		tiers = load_data("Data/sctiers.dat")
		
		for tier in tiers["TierList"]
			if tiers[tier]["Category"] == "Random" || tiers[tier]["Category"] == "Micro-tier"
				@tier_dict[tier] = 0 
        @all_tiers.push(tier)
			end 
		end 
		self.pick()
	end 
	
	
	def pick()
		i = rand(@all_tiers.length)
		
		tier = @all_tiers[i]
    @already_chosen_tiers.push(tier)
		@current_tier = tier # Stores the tier of the day. 
		@tier_dict[tier] += 1
	end 
	
	
	def get()
		return @current_tier
	end 
	
	def was_totd(tier)
		return (@tier_dict[tier] != nil) && @tier_dict[tier]
	end 
end 

