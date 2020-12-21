


module SCRandMusic
  # Exteriors
  Routes = 0
  TownsCities = 1
  # Interiors
  PokemonLeagues = 2
  PokemonCenters = 3
  BattleFacilities = 4
  GymInteriors = 5
  # Trainer Battles 
  TrainerBattles = 6
  BattleFacilityChampions = 7
  GymLeaders = 8
  Champions = 9
  # Wild Battles
  WildBattles = 10
  LegendaryBattles = 11


  def self.set(type)
    case type 
    # Background music - outside of battle.
    when SCRandMusic::Routes, SCRandMusic::TownsCities, SCRandMusic::PokemonLeagues, SCRandMusic::PokemonCenters, SCRandMusic::BattleFacilities, SCRandMusic::GymInteriors
      self.set2(type, -1)
    # Battle musics
    when SCRandMusic::TrainerBattles, SCRandMusic::BattleFacilityChampions, SCRandMusic::GymLeaders, SCRandMusic::WildBattles, SCRandMusic::Champions, SCRandMusic::LegendaryBattles
      self.set2(-1, type)
    end
  end 

  def self.set2(ambiance_type, battle_type)
    case ambiance_type 
    # Background music - outside of battle.
    when SCRandMusic::Routes
      $game_system.setDefaultBGM(self.get_rand_routes)
    when SCRandMusic::TownsCities
      $game_system.setDefaultBGM(self.get_rand_cities)
    when SCRandMusic::PokemonLeagues
      $game_system.setDefaultBGM(self.get_rand_leagues)
    when SCRandMusic::PokemonCenters
      $game_system.setDefaultBGM(self.get_rand_pokecenters)
    when SCRandMusic::BattleFacilities
      $game_system.setDefaultBGM(self.get_rand_battle_facilities)
    when SCRandMusic::GymInteriors
      $game_system.setDefaultBGM(self.get_rand_gyms)
    end
    
    # Battle musics
    case battle_type
    when SCRandMusic::TrainerBattles
      $PokemonGlobal.nextBattleBGM = self.get_rand_trainer_battles
    when SCRandMusic::BattleFacilityChampions
      $PokemonGlobal.nextBattleBGM = self.get_rand_battle_facility_champions
    when SCRandMusic::GymLeaders
      $PokemonGlobal.nextBattleBGM = self.get_rand_gym_leaders
    when SCRandMusic::Champions
      $PokemonGlobal.nextBattleBGM = self.get_rand_champions
    when SCRandMusic::WildBattles
      $PokemonGlobal.nextBattleBGM = self.get_rand_wild_battles
    when SCRandMusic::LegendaryBattles
      $PokemonGlobal.nextBattleBGM = self.get_rand_legendary
    end
  end 

  


  # Routes
  def self.get_rand_routes
    music_list = ["Routes/BW Route 1",
      "Routes/BW Route 2 3 Autumn",
      "Routes/BW Route 2 3 Spring",
      "Routes/BW Route 2 3 Summer",
      "Routes/BW Route 2 3 Winter",
      "Routes/BW Route 4 5 16 Autumn",
      "Routes/BW Route 4 5 16 Spring",
      "Routes/BW Route 4 5 16 Summer",
      "Routes/BW Route 4 5 16 Winter",
      "Routes/BW Route 6 to 9 17 18 Autumn",
      "Routes/BW Route 6 to 9 17 18 Spring",
      "Routes/BW Route 6 to 9 17 18 Summer",
      "Routes/BW Route 6 to 9 17 18 Winter",
      "Routes/BW Route 10",
      "Routes/BW Route 11 to 15 Autumn",
      "Routes/BW Route 11 to 15 Spring",
      "Routes/BW Route 11 to 15 Summer",
      "Routes/BW Route 11 to 15 Winter",
      "Routes/BW Route 23",
      "Routes/BW Route Gate",
      "Routes/BW Skyarrow Bridge",
      "Routes/BW Tubeline Bridge",
      "Routes/BW Village Bridge",
      "Routes/BW2 Marine Tube",
      "Routes/BW2 Route 19 20 Autumn",
      "Routes/BW2 Route 19 20 Spring",
      "Routes/BW2 Route 19 20 Summer",
      "Routes/BW2 Route 19 20 Winter",
      "Routes/BW2 Route 21 22 Autumn",
      "Routes/BW2 Route 21 22 Spring",
      "Routes/BW2 Route 21 22 Summer",
      "Routes/BW2 Route 21 22 Winter",
      "Routes/DPP Route 201 202 219 Day",
      "Routes/DPP Route 201 202 219 Night",
      "Routes/DPP Route 203 204 218 Day",
      "Routes/DPP Route 203 204 218 Night",
      "Routes/DPP Route 205 211 Day",
      "Routes/DPP Route 205 211 Night",
      "Routes/DPP Route 206 to 208 220 221 Day",
      "Routes/DPP Route 206 to 208 220 221 Night",
      "Routes/DPP Route 209 212 222 Day",
      "Routes/DPP Route 209 212 222 Night",
      "Routes/DPP Route 210 214 215 223 224 Day",
      "Routes/DPP Route 210 214 215 223 224 Night",
      "Routes/DPP Route 213 Day",
      "Routes/DPP Route 213 Night",
      "Routes/DPP Route 216 217 Day",
      "Routes/DPP Route 216 217 Night",
      "Routes/DPP Route 225 to 227 Day",
      "Routes/DPP Route 225 to 227 Night",
      "Routes/DPP Route 228 to 230 Day",
      "Routes/DPP Route 228 to 230 Night",
      "Routes/FRLG Route 1 2",
      "Routes/FRLG Route 3 to 10",
      "Routes/FRLG Route 11 to 15",
      "Routes/FRLG Route 16 to 22",
      "Routes/FRLG Route 23",
      "Routes/FRLG Route 24 25",
      "Routes/FRLG Treasure Beach",
      "Routes/FRLG Water Labyrinth",
      "Routes/GSC Indigo Plateau Mt Silver",
      "Routes/GSC Route 1",
      "Routes/GSC Route 2",
      "Routes/GSC Route 3 to 10",
      "Routes/GSC Route 11 to 15",
      "Routes/GSC Route 16 to 22 and 24 25",
      "Routes/GSC Route 26 and 27",
      "Routes/GSC Route 29",
      "Routes/GSC Route 30 to 33",
      "Routes/GSC Route 34 to 37 and 40 41 45 46",
      "Routes/GSC Route 38 39",
      "Routes/GSC Route 42 to 44",
      "Routes/HGSS Route 1",
      "Routes/HGSS Route 2 to 10",
      "Routes/HGSS Route 11 to 15",
      "Routes/HGSS Route 16 to 22",
      "Routes/HGSS Route 24 25",
      "Routes/HGSS Route 26 27",
      "Routes/HGSS Route 28",
      "Routes/HGSS Route 29",
      "Routes/HGSS Route 30 to 33",
      "Routes/HGSS Route 34 to 37 40 41 45 46",
      "Routes/HGSS Route 38 39",
      "Routes/HGSS Route 42 to 44",
      "Routes/HGSS Route 47 48",
      "Routes/LGPE Route 1 2",
      "Routes/LGPE Route 3 to 10 16 18 to 22",
      "Routes/LGPE Route 11 to 15",
      "Routes/LGPE Route 16 to 18",
      "Routes/LGPE Route 23",
      "Routes/LGPE Route 24 25",
      "Routes/ORAS Route 101 to 103",
      "Routes/ORAS Route 104 to 109 115 116",
      "Routes/ORAS Route 110 11 112 114 117 118",
      "Routes/ORAS Route 111 Desert",
      "Routes/ORAS Route 113",
      "Routes/ORAS Route 119 129 to 134",
      "Routes/ORAS Route 120 121 124 to 128",
      "Routes/ORAS Route 122 123",
      "Routes/RBY Route 1 and 2",
      "Routes/RBY Route 3 to 10 and 16 to 22",
      "Routes/RBY Route 11 to 15",
      "Routes/RBY Route 23",
      "Routes/RBY Route 24 and 25",
      "Routes/Route 119 and 131 to 134",
      "Routes/RSE Route 101 to 103",
      "Routes/RSE Route 104 to 109 and 115 116",
      "Routes/RSE Route 110 111 112 114 117 118",
      "Routes/RSE Route 111 Desert",
      "Routes/RSE Route 113",
      "Routes/RSE Route 120 121 and 124 to 128",
      "Routes/RSE Route 122 123",
      "Routes/SM Route 1",
      "Routes/SM Route 2 3",
      "Routes/SM Route 4 to 9",
      "Routes/SM Route 10 to 17",
      "Routes/SS Crown Tundra",
      "Routes/SS Isle of Armor",
      "Routes/SS Route 1 2",
      "Routes/SS Route 3 to 5",
      "Routes/SS Route 6 to 9",
      "Routes/SS Route 10",
      "Routes/SS Wild Area North",
      "Routes/SS Wild Area South",
      "Routes/XY Route 1",
      "Routes/XY Route 2 3",
      "Routes/XY Route 4 to 7 22",
      "Routes/XY Route 8 to 13",
      "Routes/XY Route 14",
      "Routes/XY Route 15 to 17",
      "Routes/XY Route 18 19 21",
      "Routes/XY Route 20",
      "Routes/XY Route Gate",
      "Routes/BW Driftveil Drawbridge",
      "Routes/BW Marvelous Bridge"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Towns & Cities
  def self.get_rand_cities
    music_list = ["Towns Cities/BW Black City",
      "Towns Cities/BW Castelia City",
      "Towns Cities/BW Floccesy Town",
      "Towns Cities/BW Humilau City",
      "Towns Cities/BW Icirrus City",
      "Towns Cities/BW Lacunosa Town",
      "Towns Cities/BW Lentimas Town",
      "Towns Cities/BW Mistralon City",
      "Towns Cities/BW Nacrene City",
      "Towns Cities/BW Nimbasa City",
      "Towns Cities/BW Nimbasa City-2",
      "Towns Cities/BW Nuvema Town",
      "Towns Cities/BW Opelucid City Black",
      "Towns Cities/BW Opelucid City White",
      "Towns Cities/BW Striaton City",
      "Towns Cities/BW Undella Town Spring Autumn Winter",
      "Towns Cities/BW Undella Town Summer",
      "Towns Cities/BW Virbank City",
      "Towns Cities/BW White Forest",
      "Towns Cities/Cerulean City",
      "Towns Cities/Cinnabar Island",
      "Towns Cities/DPP Canalave City Day",
      "Towns Cities/DPP Canalave City Night",
      "Towns Cities/DPP Eterna City Day",
      "Towns Cities/DPP Eterna City Night",
      "Towns Cities/DPP Floaroma Town Day",
      "Towns Cities/DPP Floaroma Town Night",
      "Towns Cities/DPP Hearthome City Day",
      "Towns Cities/DPP Hearthome City Night",
      "Towns Cities/DPP Jubilife City Day",
      "Towns Cities/DPP Jubilife Dity Night",
      "Towns Cities/DPP Oreburgh City Day",
      "Towns Cities/DPP Oreburgh City Night",
      "Towns Cities/DPP Sandgem Town Day",
      "Towns Cities/DPP Sandgem Town Night",
      "Towns Cities/DPP Snowpoint City Day",
      "Towns Cities/DPP Snowpoint City Night",
      "Towns Cities/DPP Solaceon Town Day",
      "Towns Cities/DPP Solaceon Town Night",
      "Towns Cities/DPP Sunnyshore City Day",
      "Towns Cities/DPP Sunnyshore City Night",
      "Towns Cities/DPP Twinleaf Town Day",
      "Towns Cities/DPP Twinleaf Town Night",
      "Towns Cities/DPP Veilstone City Day",
      "Towns Cities/DPP Veilstone City Night",
      "Towns Cities/FRLG Celadon City",
      "Towns Cities/FRLG Cerulean City",
      "Towns Cities/FRLG Cinnabar Island",
      "Towns Cities/FRLG Four Five Island",
      "Towns Cities/FRLG Lavender Town",
      "Towns Cities/FRLG One-Two-Three Island",
      "Towns Cities/FRLG Pallet Town",
      "Towns Cities/FRLG Six Seven Island",
      "Towns Cities/FRLG Vermilion City",
      "Towns Cities/FRLG Viridian City",
      "Towns Cities/GSC Azalea Town",
      "Towns Cities/GSC Celadon City",
      "Towns Cities/GSC Cherrygrove City",
      "Towns Cities/GSC Ecruteak City",
      "Towns Cities/GSC Goldenrod City",
      "Towns Cities/GSC Lavender Town",
      "Towns Cities/GSC New Bark Town",
      "Towns Cities/GSC Pallet Town",
      "Towns Cities/GSC Saffron City",
      "Towns Cities/GSC Vermilion City",
      "Towns Cities/GSC Violet City",
      "Towns Cities/HGSS Azalea City",
      "Towns Cities/HGSS Celadon City",
      "Towns Cities/HGSS Cerulean City",
      "Towns Cities/HGSS Cherrygrove City",
      "Towns Cities/HGSS Cianwood City",
      "Towns Cities/HGSS Cinnabar Island",
      "Towns Cities/HGSS Ecruteak City",
      "Towns Cities/HGSS Goldenrod City",
      "Towns Cities/HGSS Lavender Town",
      "Towns Cities/HGSS New Bark Town",
      "Towns Cities/HGSS Pallet Town",
      "Towns Cities/HGSS Pewter City",
      "Towns Cities/HGSS Vermilion City",
      "Towns Cities/HGSS Violet City",
      "Towns Cities/LGPE Celadon City",
      "Towns Cities/LGPE Cerulean City",
      "Towns Cities/LGPE Cinnabar Island",
      "Towns Cities/LGPE Lavender Town",
      "Towns Cities/LGPE Pallet Town",
      "Towns Cities/LGPE Vermilion City",
      "Towns Cities/LGPE Viridian City",
      "Towns Cities/Motostoke",
      "Towns Cities/ORAS Dewford Town",
      "Towns Cities/ORAS Evergrand City",
      "Towns Cities/ORAS Fallarbor Town",
      "Towns Cities/ORAS Fortree City",
      "Towns Cities/ORAS Lilycove City",
      "Towns Cities/ORAS Littleroot Town",
      "Towns Cities/ORAS Oldale Town",
      "Towns Cities/ORAS Petalburg City",
      "Towns Cities/ORAS Rustboro City",
      "Towns Cities/ORAS Slateport City",
      "Towns Cities/ORAS Sootopolis City",
      "Towns Cities/ORAS Verdanturf Town",
      "Towns Cities/RBY Celadon City",
      "Towns Cities/RBY Lavender Town",
      "Towns Cities/RBY Pallet Town",
      "Towns Cities/RBY Vermillion City",
      "Towns Cities/RBY Viridian City",
      "Towns Cities/RSE Dewford Town",
      "Towns Cities/RSE Evergrand City",
      "Towns Cities/RSE Fallarbor Town",
      "Towns Cities/RSE Fortree City",
      "Towns Cities/RSE Lilycove City",
      "Towns Cities/RSE Littleroot Town",
      "Towns Cities/RSE Oldale Town",
      "Towns Cities/RSE Petalburg City",
      "Towns Cities/RSE Rustboro City",
      "Towns Cities/RSE Slateport City",
      "Towns Cities/RSE Sootopolis City",
      "Towns Cities/RSE Verdanturf Town",
      "Towns Cities/SM Hau'oli City Day",
      "Towns Cities/SM Hau'oli City Night",
      "Towns Cities/SM Heahea City Day",
      "Towns Cities/SM Heahea City Night",
      "Towns Cities/SM Iki Town Day",
      "Towns Cities/SM Iki Town Night",
      "Towns Cities/SM Konikoni City Day",
      "Towns Cities/SM Konikoni City Night",
      "Towns Cities/SM Malie City Day",
      "Towns Cities/SM Malie City Night",
      "Towns Cities/SM Paniola Town Day",
      "Towns Cities/SM Paniola Town Night",
      "Towns Cities/SM Po Town",
      "Towns Cities/SM Seafolk Village Day",
      "Towns Cities/SM Seafolk Village Night",
      "Towns Cities/SM Ultra Megalopolis",
      "Towns Cities/SS Ballonlea",
      "Towns Cities/SS Circhester",
      "Towns Cities/SS Freezington",
      "Towns Cities/SS Hammerlocke",
      "Towns Cities/SS Hulbury",
      "Towns Cities/SS Postwick",
      "Towns Cities/SS Spikemuth",
      "Towns Cities/SS Stow-on-Side",
      "Towns Cities/SS Turffield",
      "Towns Cities/SS Wedgehurst",
      "Towns Cities/SS Wyndon",
      "Towns Cities/XY Anistar City",
      "Towns Cities/XY Aquacorde Town",
      "Towns Cities/XY Camphrier Town",
      "Towns Cities/XY Coumarine City",
      "Towns Cities/XY Cyllage City",
      "Towns Cities/XY Dendemille Town",
      "Towns Cities/XY Kiloude City",
      "Towns Cities/XY Laverre City",
      "Towns Cities/XY Lumiose City",
      "Towns Cities/XY Santalune City",
      "Towns Cities/XY Shalour City",
      "Towns Cities/XY Snowbelle City",
      "Towns Cities/XY Vaniville Town",
      "Towns Cities/BW Accumula Town",
      "Towns Cities/BW Anville Town",
      "Towns Cities/BW Aspertia Town"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  #Wild Battles
  def self.get_rand_wild_battles
    music_list = ["Wild Battles/GSC Battle Wild Pokemon Day",
      "Wild Battles/GSC Battle Wild Pokemon Kanto",
      "Wild Battles/GSC Battle Wild Pokemon Night",
      "Wild Battles/HGSS Battle Wild Pokemon Johto",
      "Wild Battles/HGSS Battle Wild Pokemon Kanto",
      "Wild Battles/LGPE Battle Wild Pokemon",
      "Wild Battles/ORAS Battle Wild Pokemon",
      "Wild Battles/RBY Battle Wild Pokemon",
      "Wild Battles/RSE Battle Wild Pokemon",
      "Wild Battles/SM Battle Wild Pokemon",
      "Wild Battles/SS Battle Wild Pokemon",
      "Wild Battles/USUM Battle Wild Pokemon",
      "Wild Battles/XY Battle Wild Pokemon",
      "Wild Battles/BW Battle Wild Pokemon",
      "Wild Battles/BW2 Battle Wild Pokemon",
      "Wild Battles/DPP Battle Wild Pokemon",
      "Wild Battles/FRLG Battle Wild Pokemon"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Trainer Battles
  def self.get_rand_trainer_battles
    music_list = ["Trainer Battles/RBY Trainer Battle 1",
      "Trainer Battles/RBY Trainer Battle 2",
      "Trainer Battles/RBY Trainer Battle 3",
      "Trainer Battles/RBY Trainer Battle 4",
      "Trainer Battles/RSE Trainer Battle 1",
      "Trainer Battles/RSE Trainer Battle 2",
      "Trainer Battles/SM Trainer Battle",
      "Trainer Battles/USUM Trainer Battle",
      "Trainer Battles/XY Trainer Battle",
      "Trainer Battles/BW Trainer Battle 1",
      "Trainer Battles/BW Trainer Battle 2",
      "Trainer Battles/DPP Trainer Battle",
      "Trainer Battles/GSC Trainer Battle 1",
      "Trainer Battles/GSC Trainer Battle 2"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Pokémon League
  def self.get_rand_leagues
    music_list = ["Pokémon League/FRLG Pokemon League - Agatha's Room",
      "Pokémon League/FRLG Pokemon League - Bruno's Room",
      "Pokémon League/FRLG Pokemon League - Lorelei's Room",
      "Pokémon League/FRLG Pokemon League",
      "Pokémon League/GSC Pokemon League",
      "Pokémon League/HGSS Pokemon League",
      "Pokémon League/LGPE Pokemon League",
      "Pokémon League/ORAS Pokemon League Inner",
      "Pokémon League/ORAS Pokemon League",
      "Pokémon League/RBY Pokemon League - Agatha's Room",
      "Pokémon League/RBY Pokemon League - Bruno's Room",
      "Pokémon League/RBY Pokemon League - Lorelei's Room",
      "Pokémon League/RBY Pokemon League",
      "Pokémon League/RSE Pokemon League Inner",
      "Pokémon League/RSE Pokemon League",
      "Pokémon League/SM Pokemon League Inner",
      "Pokémon League/SM Pokemon League",
      "Pokémon League/SS Pokemon League",
      "Pokémon League/XY Pokemon League",
      "Pokémon League/BW Pokemon League",
      "Pokémon League/DPP Pokemon League Day",
      "Pokémon League/DPP Pokemon League Inner",
      "Pokémon League/DPP Pokemon League Night"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Pokemon Centers
  def self.get_rand_pokecenters
    music_list = ["Pokémon Centers/LGPE Pokemon Center",
      "Pokémon Centers/ORAS Pokemon Center",
      "Pokémon Centers/RBY Pokemon Center",
      "Pokémon Centers/RSE Pokemon Center",
      "Pokémon Centers/SM Pokemon Center",
      "Pokémon Centers/SS Pokemon Center",
      "Pokémon Centers/XY Pokemon Center",
      "Pokémon Centers/BW Pokemon Center",
      "Pokémon Centers/DPP Pokemon Center Day",
      "Pokémon Centers/DPP Pokemon Center Night",
      "Pokémon Centers/FRLG Pokemon Center Network",
      "Pokémon Centers/FRLG Pokemon Center",
      "Pokémon Centers/GSC Pokemon Center",
      "Pokémon Centers/HGSS Pokemon Center"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Gym Themes
  def self.get_rand_gyms
    music_list = ["Gym Themes/BW2 Mistralton City Gym",
      "Gym Themes/BW2 Nimbasa City Gym",
      "Gym Themes/BW2 Opelucid City Gym",
      "Gym Themes/BW2 Virbank City Gym",
      "Gym Themes/DPP Gym Theme",
      "Gym Themes/FRLG Gym Theme",
      "Gym Themes/GSC Gym Theme",
      "Gym Themes/HGSS Gym Theme",
      "Gym Themes/LGPE Gym Theme",
      "Gym Themes/ORAS Gym Theme",
      "Gym Themes/RBY Gym Theme",
      "Gym Themes/RSE Gym Theme",
      "Gym Themes/SM Kantonian Gym",
      "Gym Themes/SM Thrifty Megamart",
      "Gym Themes/SM Totem Pokemon Appears",
      "Gym Themes/SM Trial Site",
      "Gym Themes/SS Gym Lobby",
      "Gym Themes/SS Gym Mission",
      "Gym Themes/XY Gym Theme",
      "Gym Themes/BW Gym Theme",
      "Gym Themes/BW2 Castelia City Gym",
      "Gym Themes/BW2 Driftveil City Gym",
      "Gym Themes/BW2 Gym Stage",
      "Gym Themes/BW2 Humilau City Gym"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Gym Leaders
  def self.get_rand_gym_leaders
    music_list = ["Gym Leaders/BW2 PWT Kanto Gym Leader",
      "Gym Leaders/BW2 PWT Sinnoh Gym Leader",
      "Gym Leaders/BW2 Unova Gym Leader",
      "Gym Leaders/DPP Sinnoh Gym Leader",
      "Gym Leaders/FRLG Kanto Gym Leader",
      "Gym Leaders/GSC Johto Gym Leader",
      "Gym Leaders/GSC Kanto Gym Leader",
      "Gym Leaders/HGSS Johto Gym Leader",
      "Gym Leaders/HGSS Kanto Gym Leader",
      "Gym Leaders/LGPE Kanto Gym Leader",
      "Gym Leaders/ORAS Hoenn Gym Leader",
      "Gym Leaders/RBY Gym Leader",
      "Gym Leaders/RSE Hoenn Gym Leader",
      "Gym Leaders/SM Island Kahuna",
      "Gym Leaders/SM Totem Pokemon",
      "Gym Leaders/SS Enchant Gigantamax Dynamax",
      "Gym Leaders/SS Galar Gym Leader",
      "Gym Leaders/SS Gym Leader Piers",
      "Gym Leaders/XY Kalos Gym Leader",
      "Gym Leaders/XY Successor Korrina",
      "Gym Leaders/BW Final Pokemon",
      "Gym Leaders/BW Unova Gym Leader",
      "Gym Leaders/BW2 Final Pokemon",
      "Gym Leaders/BW2 PWT Hoenn Gym Leader",
      "Gym Leaders/BW2 PWT Johto Gym Leader"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Battle Facilities Champions
  def self.get_rand_battle_facility_champions
    music_list = ["Battle Facilities Champions/BW2 Battle Kanto Champion Blue",
      "Battle Facilities Champions/BW2 Battle Kanto Gym Leader",
      "Battle Facilities Champions/BW2 Battle Sinnoh Champion Cynthia",
      "Battle Facilities Champions/BW2 Battle Sinnoh Gym Leader",
      "Battle Facilities Champions/BW2 Battle Unova Champion Alder",
      "Battle Facilities Champions/BW2 Unova Gym Leader",
      "Battle Facilities Champions/SM Battle Legend Red Blue",
      "Battle Facilities Champions/BW Battle Subway Boss",
      "Battle Facilities Champions/BW Battle Subway Trainer",
      "Battle Facilities Champions/BW2 Battle Hoenn Champion Steven & Wallace",
      "Battle Facilities Champions/BW2 Battle Hoenn Gym Leader",
      "Battle Facilities Champions/BW2 Battle Johto Champion Lance & Red",
      "Battle Facilities Champions/BW2 Battle Johto Gym Leader"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Battle Facilities
  def self.get_rand_battle_facilities
    music_list = [
      "Battle Facilities/BW2 Battle Pokemon World Tournament",
      "Battle Facilities/BW2 Black Tower Lobby",
      "Battle Facilities/BW2 Black Tower",
      "Battle Facilities/BW2 Pokemon World Tournament Lobby",
      "Battle Facilities/BW2 Pokemon World Tournament",
      "Battle Facilities/BW2 White Treehollow Lobby",
      "Battle Facilities/BW2 White Treehollow",
      "Battle Facilities/Crystal Battle Tower Lobby",
      "Battle Facilities/Crystal Battle Tower",
      "Battle Facilities/DPP Battle Park Day",
      "Battle Facilities/DPP Battle Park Night",
      "Battle Facilities/DPP Battle Tower Tycoon Palmer",
      "Battle Facilities/DPP Battle Tower",
      "Battle Facilities/Emerald Battle Arena",
      "Battle Facilities/Emerald Battle Dome Lobby",
      "Battle Facilities/Emerald Battle Dome",
      "Battle Facilities/Emerald Battle Factory",
      "Battle Facilities/Emerald Battle Frontier Brain",
      "Battle Facilities/Emerald Battle Frontier",
      "Battle Facilities/Emerald Battle Palace",
      "Battle Facilities/Emerald Battle Pike",
      "Battle Facilities/Emerald Battle Pyramid Summit",
      "Battle Facilities/Emerald Battle Pyramid",
      "Battle Facilities/Emerald Battle Tower",
      "Battle Facilities/FRLG Trainer Tower Lobby",
      "Battle Facilities/HGSS Battle Arcade",
      "Battle Facilities/HGSS Battle Castle",
      "Battle Facilities/HGSS Battle Factory",
      "Battle Facilities/HGSS Battle Frontier (unknown)",
      "Battle Facilities/HGSS Battle Frontier Brain",
      "Battle Facilities/HGSS Battle Frontier",
      "Battle Facilities/HGSS Battle Hall",
      "Battle Facilities/HGSS Battle Tower",
      "Battle Facilities/ORAS Battle Chatelaine",
      "Battle Facilities/ORAS Battle Resort",
      "Battle Facilities/Platinium Battle Arcade",
      "Battle Facilities/Platinium Battle Castle",
      "Battle Facilities/Platinium Battle Factory",
      "Battle Facilities/Platinium Battle Frontier (unknown)",
      "Battle Facilities/Platinium Battle Frontier Brain",
      "Battle Facilities/Platinium Battle Hall",
      "Battle Facilities/RFLG Trainer Tower",
      "Battle Facilities/RS Battle Tower",
      "Battle Facilities/SM Battle Tree",
      "Battle Facilities/SS Battle Tower Trainer",
      "Battle Facilities/SS Battle Tower",
      "Battle Facilities/XY Battle Chateau",
      "Battle Facilities/XY Battle Chatelaine",
      "Battle Facilities/BW Battle Subway",
      "Battle Facilities/BW Gear Station"
    ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Champion Themes
  def self.get_rand_champions
    music_list = [
      "Champion Themes/DPP Cynthia Intro",
      "Champion Themes/DPP Cynthia Theme",
      "Champion Themes/FRLG Kanto Champion Blue Theme",
      "Champion Themes/GSC Red Lance Theme",
      "Champion Themes/HGSS Red Lance Theme",
      "Champion Themes/LGPE Kanto Champion Blue Theme",
      "Champion Themes/ORAS Steven Theme",
      "Champion Themes/ORAS Unknown Probably Wallace",
      "Champion Themes/RBY Kanto Champion Blue Theme",
      "Champion Themes/RSE Steven Wallace Theme",
      "Champion Themes/SM Hau Theme",
      "Champion Themes/SM Professor Kukui Theme",
      "Champion Themes/SM Red Theme",
      "Champion Themes/SS Leon Theme",
      "Champion Themes/XY Diantha Theme",
      "Champion Themes/B2W2 Champion Iris Theme",
      "Champion Themes/B2W2 Cynthia Theme",
      "Champion Themes/B2W2 Kanto Champion Blue Theme",
      "Champion Themes/B2W2 Red Lance Theme",
      "Champion Themes/BW Alder Theme"
      ]
    
    return scsample(music_list, 1)
  end 
  
  
  
  # Legendary Pokémons
  def self.get_rand_legendary
    music_list = [
      "Legendary Pokémon/DPP Dialga Palkia",
      "Legendary Pokémon/DPP Giratina",
      "Legendary Pokémon/DPP Heatran Darkrai",
      "Legendary Pokémon/DPP Uxie Azelf Mesprit",
      "Legendary Pokémon/FRLG Deoxys",
      "Legendary Pokémon/FRLG Mewtwo",
      "Legendary Pokémon/GSC Three Beasts",
      "Legendary Pokémon/HGSS Entei",
      "Legendary Pokémon/HGSS Groudon Kyogre Rayquaza",
      "Legendary Pokémon/HGSS Ho-Oh",
      "Legendary Pokémon/HGSS Lugia",
      "Legendary Pokémon/HGSS Raikou",
      "Legendary Pokémon/HGSS Suicune",
      "Legendary Pokémon/ORAS Deoxys",
      "Legendary Pokémon/ORAS Groudon Kyogre Rayquaza",
      "Legendary Pokémon/ORAS Primal",
      "Legendary Pokémon/ORAS Three Titans",
      "Legendary Pokémon/RSE Groudon Kyogre Rayquaza",
      "Legendary Pokémon/RSE Mew",
      "Legendary Pokémon/RSE Three Titans",
      "Legendary Pokémon/SM Solgaleo Lunala",
      "Legendary Pokémon/SM Tapu",
      "Legendary Pokémon/SM Ultra Beast",
      "Legendary Pokémon/SS Eternatus 2",
      "Legendary Pokémon/SS Eternatus 3",
      "Legendary Pokémon/SS Eternatus",
      "Legendary Pokémon/SS Mysterious Being",
      "Legendary Pokémon/SS Zacian Zamazenta",
      "Legendary Pokémon/USUM Dusk Mane Dawn Wings Necrozma",
      "Legendary Pokémon/USUM Tapu",
      "Legendary Pokémon/USUM Ultra Beast",
      "Legendary Pokémon/USUM Ultra Necrozma",
      "Legendary Pokémon/XY Mewtwo",
      "Legendary Pokémon/XY Xerneas Yveltal",
      "Legendary Pokémon/B2W2 White Black Kyurem",
      "Legendary Pokémon/BW Cobalion Virizion Terrakion",
      "Legendary Pokémon/BW Kyurem",
      "Legendary Pokémon/BW Reshiram Zekrom",
      "Legendary Pokémon/DPP Arceus"
      ]
    
    return scsample(music_list, 1)
  end 
  
end 
