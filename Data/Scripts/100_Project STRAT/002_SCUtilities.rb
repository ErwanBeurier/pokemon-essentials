###############################################################################
# SCUtilities
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains a few functions that I find useful, or whose existing 
# implementation I don't like.
###############################################################################



#----------------------------------------------------------
# Returns a random subset of n non-repeated elements from 
# the array.
#----------------------------------------------------------
def scsample(a, n)
  n = a.length if n < 0
  
	if n == 1 && a.is_a?(Array) && a.length >= 1
		return a[rand(a.length)]
	end 
	
  indices = scsamplei(a, n)
	a_sample = []
	
	# raise _INTL("indices.length = {1}, a.length = {2}", indices.length, a.length)
	
	indices.each { |i| a_sample.push(a[i]) }
	
	return a_sample
end 



def scsamplei(a, n)
  # Returns the choice of indices of elements of a. 
	if !a.is_a?(Array)
		raise _INTL("In scsample: not an array.")
	end 
	if a.length == 0
		raise _INTL("In scsample: empty array.")
	end 
  
  n = a.length if n > a.length
  
	cpt = 0
	indices = []
	
	for o in a
		indices.push(cpt)
		cpt += 1
	end 
	
	for i in 0...cpt
		j = rand(cpt)
		temp = indices[j]
		indices[j] = indices[i]
		indices[i] = temp 
	end 
  
  return indices[0...n] 
end 














