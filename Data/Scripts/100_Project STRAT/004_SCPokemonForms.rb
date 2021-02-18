###############################################################################
# SCPokemonForms
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains the description of the new Mega-evolutions, so that 
# my new Gengar doesn't Mega-Evolve in the same Mega Gengar as the original 
# form. 
# Thanks to Golisopod-User (on GitHub) for the implementation of the way to 
# handle Mega-evolutoins depending on form (the problem existed for Slowbro; 
# Galarian Slowbro cannot mega-evolve). This is the same script I'm using here.
###############################################################################

MultipleForms.register(:BEEDRILL,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:BEEDRILLITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:GENGAR,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:GENGARITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:PIDGEOT,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2, 4].include?(pkmn.form) &&  pkmn.hasItem?(:PIDGEOTITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3, 5].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:GYARADOS,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2, 4, 6, 8].include?(pkmn.form) &&  pkmn.hasItem?(:GYARADOSITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3, 5, 7, 9].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:AERODACTYL,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:AERODACTYLITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:ALTARIA,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:ALTARIANITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:GLALIE,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:GLALITITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})

MultipleForms.register(:AUDINO,{
  "getSpecificMegaForm" => proc { |pkmn|
    next pkmn.form + 1 if [0, 2].include?(pkmn.form) &&  pkmn.hasItem?(:AUDINITE)
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next pkmn.form - 1 if [1, 3].include?(pkmn.form)
    next
  }
})
















