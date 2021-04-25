###############################################################################
# SCRealPokemons
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# Contains story-related scripts. Pokémons that the player character owned and 
# used in his past life.
# 
###############################################################################

module SCStoryPokemon
  module SCRegions
    Kanto = 1
    Johto = 2
    Hoenn = 3
    Sinnoh = 4
    Unova = 5
    Kalos = 6
    Alola = 7 
    Galar = 8
    
    def self.getName(region)
      case region
      when Kanto  ; return "Kanto" 
      when Johto  ; return "Johto" 
      when Hoenn  ; return "Hoenn" 
      when Sinnoh ; return "Sinnoh" 
      when Unova  ; return "Unova" 
      when Kalos  ; return "Kalos" 
      when Alola  ; return "Alola" 
      when Galar  ; return "Galar" 
      else 
        raise _INTL("Invalid SCRegions value: {1}", region)
      end 
    end 
  end 
  
  OwnedPokemons = {}
  OwnedPokemons[SCRegions::Kanto]  = [PBSpecies::CHARIZARD, PBSpecies::VENUSAUR, PBSpecies::BLASTOISE]
  OwnedPokemons[SCRegions::Johto]  = []
  OwnedPokemons[SCRegions::Hoenn]  = []
  OwnedPokemons[SCRegions::Sinnoh] = []
  OwnedPokemons[SCRegions::Unova]  = []
  OwnedPokemons[SCRegions::Kalos]  = []
  OwnedPokemons[SCRegions::Alola]  = []
  OwnedPokemons[SCRegions::Galar]  = []
  
  TotemLegendaries = {}
  TotemLegendaries[SCRegions::Kanto]  = [PBSpecies::MEW, PBSpecies::MEWTWO]
  TotemLegendaries[SCRegions::Johto]  = [PBSpecies::HOOH, PBSpecies::LUGIA]
  TotemLegendaries[SCRegions::Hoenn]  = [PBSpecies::GROUDON, PBSpecies::KYOGRE, PBSpecies::RAYQUAZA]
  TotemLegendaries[SCRegions::Sinnoh] = [PBSpecies::PALKIA, PBSpecies::DIALGA, PBSpecies::GIRATINA]
  TotemLegendaries[SCRegions::Unova]  = [PBSpecies::RESHIRAM, PBSpecies::ZEKROM]
  TotemLegendaries[SCRegions::Kalos]  = [PBSpecies::YVELTAL, PBSpecies::XERNEAS]
  TotemLegendaries[SCRegions::Alola]  = [PBSpecies::SOLGALEO, PBSpecies::LUNALA]
  TotemLegendaries[SCRegions::Galar]  = [PBSpecies::ZACIAN, PBSpecies::ZAMAZENTA]
end 

def scSetupRealPokemons

end 
