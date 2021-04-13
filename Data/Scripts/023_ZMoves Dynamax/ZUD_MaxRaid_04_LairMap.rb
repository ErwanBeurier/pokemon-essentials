#===============================================================================
#
# Max Lair Map Script - by Lucidious89
#  For -Pokemon Essentials v18.1-
#
#===============================================================================
#
# ZUD_MaxRaid_04: Lair Map
#
#===============================================================================
# The following is meant as an add-on for the ZUD Plugin for v18.1.
# This script handles the map scene during a Dynamax Adventure.
#
#===============================================================================
# SECTION 1 - MAP TILE COORDINATES
#-------------------------------------------------------------------------------
# This section contains the map coordinates for all special tiles on a Max Lair
# map. Input any necessary coordinates for custom maps in this section.
#===============================================================================
# SECTION 2 - MAP UTILITIES
#-------------------------------------------------------------------------------
# This section handles various code required for specific map functions.
#===============================================================================
# SECTION 3 - MAP SPRITES
#-------------------------------------------------------------------------------
# This section sets up all of the sprites that are required for a Max Lair map.
#===============================================================================
# SECTION 4 - MAP MOVEMENT
#-------------------------------------------------------------------------------
# This section handles all code related to movement and positioning while
# navigating a Max Lair map.
#===============================================================================

################################################################################
# SECTION 1 - MAP TILE COORDINATES
#===============================================================================
# Sets up the initial coordinates of all Max Lair map sprites and tiles.
#===============================================================================
class DynAdventureState
  
  def pbSetMapTiles(map)
    #---------------------------------------------------------------------------
    # Variables for X axis coordinates.
    #---------------------------------------------------------------------------
    _A,_B,_C,_D,_E,_F,_G,_H,_I  = 0,32,64,96,128,160,192,224,256
    _J,_K,_L,_M,_N,_O,_P,_Q,_R  = 288,320,352,384,416,448,480,512,544
    _S,_T,_U,_V,_W,_X,_Y,_Z     = 576,608,640,672,704,736,768,800
    #---------------------------------------------------------------------------
    # Variables for Y axis coordinates.
    #---------------------------------------------------------------------------
    _01,_02,_03,_04,_05,_06,_07 = 352,320,288,256,224,192,160
    _08,_09,_10,_11,_12,_13,_14 = 128,96,64,32,0,-32,-64
    _15,_16,_17,_18,_19,_20,_21 = -96,-128,-160,-192,-224,-256,-288
    _22,_23,_24,_25,_26,_27,_28 = -320,-352,-384,-416,-448,-480,-512
    case map
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 00
    #---------------------------------------------------------------------------
    when 0
      @entryPoint     = [_I,_01]
      @mapStart       = [_I,_06]
      @mapPathsUL     = [[_G,_14],[_O,_14],[_O,_18]]
      @mapPathsUR     = [[_K,_10],[_C,_14],[_C,_18]]
      @mapPathsDL     = []
      @mapPathsDR     = []
      @mapPathsUD     = []
      @mapPathsLR     = [[_I,_06]]
      @mapPathsULR    = [[_G,_10],[_K,_14]]
      @mapPathsUDL    = [] 
      @mapPathsUDR    = []
      @mapPathsDLR    = []
      @mapPathsUDLR   = []
      @mapPkmnCoords  = [[_G,_07],[_K,_07],[_C,_11],[_G,_12],[_K,_12],[_O,_11],[_C,_16],[_G,_17],[_K,_17],[_O,_16],[_I,_21]]
      @mapTurnUp      = [[_G,_06],[_K,_06],[_C,_10],[_I,_10],[_O,_10],[_K,_11],[_I,_14],[_G,_16],[_E,_18],[_M,_18],[_I,_18]]
      @mapTurnDown    = []
      @mapTurnLeft    = [[_I,_16],[_K,_18],[_O,_21],[_M,_21],[_N,_14]] 
      @mapTurnRight   = [[_I,_11],[_G,_18],[_C,_21],[_E,_21],[_D,_14]]
      @mapTurnRandom  = []
      @mapTurnFlip    = []
      @mapWarpPoint   = [[_H,_18],[_J,_13],[_L,_13],[_B,_18],[_J,_18],[_J,_15],[_H,_15],[_P,_18]]
      @mapEventSwap   = [[_O,_20]]
      @mapEventItems  = [[_D,_10]]
      @mapEventTrain  = [[_N,_10]]
      @mapEventTutor  = [[_C,_20]]
      @mapEventWard   = [[_I,_15]]
      @mapEventHeal   = [[_K,_13]]
      @mapEventRandom = []
      @mapEventBerry  = [[_E,_14],[_M,_14]]
      @mapRoadblock   = [[_J,_14]]
      @mapHiddenTrap  = [[_D,_21],[_N,_21]]
      @mapSwitches    = [[_C,_13],[_O,_13],[_G,_15],[_K,_15]]
      @mapSwitchTargs = [[_D,_14],[_N,_14],[_H,_18],[_J,_13],[_L,_13],[_B,_18],[_J,_18],[_J,_15],[_H,_15],[_P,_18]]
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 01
    #---------------------------------------------------------------------------
    when 1
      @entryPoint     = [_N,_28]
      @mapStart       = [_N,_22]
      @mapPathsUL     = []
      @mapPathsUR     = []
      @mapPathsDL     = []
      @mapPathsDR     = []
      @mapPathsUD     = []
      @mapPathsLR     = []
      @mapPathsULR    = [[_N,_19]]
      @mapPathsUDL    = [[_W,_12]] 
      @mapPathsUDR    = []
      @mapPathsDLR    = [[_N,_22],[_N,_15]]
      @mapPathsUDLR   = [[_I,_22],[_S,_22],[_E,_12],[_G,_10]]
      @mapPkmnCoords  = [ [_G,_22],[_U,_22],[_G,_19],[_U,_19],[_G,_15],[_U,_15],[_H,_05],[_T,_05],[_I,_10],[_S,_10],[_N,_04] ]
      @mapTurnUp      = [[_K,_24],[_Q,_24],[_E,_19],[_W,_19],[_S,_15],[_W,_06],[_I,_15],[_G,_08]]
      @mapTurnDown    = [[_I,_26],[_S,_26],[_N,_25],[_N,_16],[_C,_12],[_C,_10],[_N,_07]]
      @mapTurnLeft    = [[_P,_25],[_Q,_25],[_I,_19],[_P,_16],[_W,_05],[_Y,_10],[_W,_15],[_G,_12],[_I,_08],[_K,_10]] 
      @mapTurnRight   = [[_K,_25],[_L,_25],[_L,_16],[_S,_19],[_Q,_10],[_U,_12],[_E,_15],[_C,_08],[_E,_05]]
      @mapTurnRandom  = [[_W,_10]]
      @mapTurnFlip    = [[_I,_24],[_I,_20],[_S,_24],[_S,_20],[_E,_10]]
      @mapWarpPoint   = [[_E,_22],[_L,_24],[_W,_22],[_P,_24],[_E,_21],[_U,_08],[_W,_21],[_I,_07],[_I,_16],[_L,_15],[_H,_12],[_S,_16],[_P,_15],[_T,_12],[_J,_05],[_L,_07],[_R,_05],[_P,_07]]
      @mapEventSwap   = [[_N,_08],[_F,_05],[_V,_05]]
      @mapEventItems  = [[_U,_09]]
      @mapEventTrain  = [[_D,_08]]
      @mapEventTutor  = [[_H,_08]]
      @mapEventWard   = [[_V,_10]]
      @mapEventHeal   = [[_D,_10]]
      @mapEventRandom = [[_M,_07],[_O,_07]]
      @mapEventBerry  = [[_I,_25],[_S,_25]]
      @mapRoadblock   = [[_N,_13],[_N,_11],[_N,_09]]
      @mapHiddenTrap  = [[_I,_21],[_S,_21],[_D,_12],[_X,_10]]
      @mapSwitches    = [[_L,_22],[_P,_22],[_N,_20],[_E,_20],[_W,_20],[_M,_16],[_O,_16]]
      @mapSwitchTargs = [[_I,_24],[_I,_20],[_S,_24],[_S,_20],[_E,_10],[_W,_06],[_W,_10],[_E,_21],[_W,_21]]
    ############################################################################
    # ADD CUSTOM MAPS BELOW
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 02
    #---------------------------------------------------------------------------
    when 2
      #-------------------------------------------------------------------------
      # Coordinates for the player's default position when the map is loaded.
      # Must only contain a single set of coordinates.
      @entryPoint     = []
      #-------------------------------------------------------------------------
      # Coordinates for the Start Tile.
      # Must only contain a single set of coordinates.
      @mapStart       = []
      #-------------------------------------------------------------------------
      # Coordinates for Selection Tiles.
      @mapPathsUL     = [] # Up/Left directions.
      @mapPathsUR     = [] # Up/Right directions.
      @mapPathsDL     = [] # Down/Left directions.
      @mapPathsDR     = [] # Down/Right directions.
      @mapPathsUD     = [] # Up/Down directions.
      @mapPathsLR     = [] # Left/Right directions.
      @mapPathsULR    = [] # Up/Left/Right directions.
      @mapPathsUDL    = [] # Up/Down/Left directions. 
      @mapPathsUDR    = [] # Up/Down/Right directions.
      @mapPathsDLR    = [] # Down/Left/Right directions.
      @mapPathsUDLR   = [] # All four directions.
      #-------------------------------------------------------------------------
      # Coordinates for Raid Tiles.
      # Always contains 11 sets of coordinates.
      # The first two coordinates are for the lowest ranked species in the lair.
      # The final coordinates are for the lair's Legendary Pokemon.
      @mapPkmnCoords  = [ [],[],[],[],[],[],[],[],[],[],[] ]
      #-------------------------------------------------------------------------
      # Coordinates for Directional Turn Tiles.
      @mapTurnUp      = []
      @mapTurnDown    = []
      @mapTurnLeft    = [] 
      @mapTurnRight   = []
      @mapTurnRandom  = []
      @mapTurnFlip    = []
      #-------------------------------------------------------------------------
      # Coordinates for Warp Tiles.
      # Warp Tiles are linked to each other in the order they're inputted here.
      # So the first Warp Tile will warp to the second Warp Tile, which will Warp to the third, etc.
      # The last Warp Tile entered here will loop back and warp to the first Warp Tile.
      @mapWarpPoint   = []
      #-------------------------------------------------------------------------
      # Coordinates for Event Tiles.
      @mapEventSwap   = [] # Scientist
      @mapEventItems  = [] # Backpacker
      @mapEventTrain  = [] # Blackbelt
      @mapEventTutor  = [] # Ace Trainer
      @mapEventWard   = [] # Channeler
      @mapEventHeal   = [] # Nurse
      @mapEventRandom = [] # Random NPC
      @mapEventBerry  = [] # Berries
      #-------------------------------------------------------------------------
      # Coordinates for Roadblock Tiles.
      @mapRoadblock   = []
      #-------------------------------------------------------------------------
      # Coordinates for Hidden Trap tiles. These tiles are never visible.
      @mapHiddenTrap  = []
      #-------------------------------------------------------------------------
      # Coordinates for Switch Tiles. These always begin in the OFF position.
      @mapSwitches    = []
      #-------------------------------------------------------------------------
      # Coordinates for Switch Target Tiles.
      # Tiles that you want to be revealed when a Switch Tile is triggered go here.
      # Just input the coordinates of a tile above to make it a Switch Target.
      # For example, if you have a Warp Tile at [_A,_01], put those coordinates here
      # and that Warp Tile will only appear when a Switch is flipped to the ON position.
      @mapSwitchTargs = []
      #-------------------------------------------------------------------------
    end
  end
  
################################################################################
# SECTION 2 - MAP UTILITIES
#===============================================================================
# Various functions used while on a Max Lair map.
#===============================================================================
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbFadeOutIn(99999) {
      pbUpdate
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      pbBGMFade(1.0)
      pbSEPlay("Door exit")
    }
  end
    
  def pbUpdateLairHP
    for i in 0...@maxHearts
     if @knockouts>i; @sprites["hpcount#{i}"].src_rect.set(0,0,34,30)   
     else; @sprites["hpcount#{i}"].src_rect.set(34,0,68,30)
     end
    end
  end
  
  def pbMapIntro
    pbWait(50)
    boss = @lairSpecies.length-1
    pbAutoMapPosition(@sprites["mapPokemon#{boss}"],2)
    pbWait(15)
    poke = pbGetSpeciesFromFSpecies(@bossSpecies)
    pbPlayDynamaxCry(poke[0],poke[1])
    pbWait(15)
    pbMessage(_INTL("There's a strong {1}-type reaction coming from within the den!",@bosstype))
    pbAutoMapPosition(@player,4)
  end
  
  def pbHideUISprites
    @arrow0.visible                = false
    @arrow1.visible                = false
    @arrow2.visible                = false
    @arrow3.visible                = false
    @cursor.visible                = false
    @sprites["select"].visible     = false
    @sprites["options"].visible    = false
    @sprites["return"].visible     = false
    @sprites["uparrow"].visible    = false
    @sprites["downarrow"].visible  = false
    @sprites["leftarrow"].visible  = false
    @sprites["rightarrow"].visible = false
  end
  
  def pbChangePokeOpacity(fade=true)
    for i in 0...@mapPkmnCoords.length
      poke = @sprites["pokemon#{i}"]
      if fade; poke.opacity = 100
      else;    poke.opacity = 255
      end
    end
  end
  
  def pbClearTile
    coords = [@player.x,@player.y]
    for sprite in @mapSprites
      next if sprite==@player
      next if sprite==@startTile
      next if sprite==@sprites["background"]
      tile = [sprite.x,sprite.y]
      sprite.visible = false if coords==tile
    end
  end
      
  def pbCursorReact
    select = nil
    coords = [@cursor.x+16,@cursor.y+16]
    @cursor.src_rect.set(0,0,64,64)
    for sprite in @mapSprites
      mapCoords = [sprite.x,sprite.y]
      next if !sprite.visible
      next if pbHiddenTrapTile?(mapCoords)
      withinXRange = (coords[0]<=mapCoords[0]+20 && coords[0]>=mapCoords[0]-20)
      withinYRange = (coords[1]<=mapCoords[1]+20 && coords[1]>=mapCoords[1]-20)
      select = mapCoords if withinXRange && withinYRange
    end
    return select
  end
  
  def pbBattleLairPokemon(index)
    if @sprites["pokemon#{index}"].visible
      advanced = false
      species  = @lairSpecies[index]
      species  = pbGetMaxRaidSpecies(species,3)[0]
      gmax     = pbGmaxSpecies?(species[0],species[1])
      nextlvl  = (species[0]==@bossSpecies) ? 5 : 0
      level    = $Trainer.party[0].level + nextlvl
      lairpoke = pbGetFSpeciesFromForm(species[0],species[1])
      $game_variables[MAXRAID_PKMN]  = [species[0],species[1],species[2],level,gmax]
      $game_switches[MAXRAID_SWITCH] = true
      pbFadeOutIn(99999) {
        pbMessage(_INTL("\\me[Max Raid Intro]You ventured deeper into the lair...\\wt[34] ...\\wt[34] ...\\wt[60]!\\wtnp[8]")) if !($DEBUG && Input.press?(Input::CTRL))
        @sprites["pokemon#{index}"].color.alpha = 0
        @sprites["pokemon#{index}"].visible  = false
        @sprites["poketype#{index}"].visible = false
        pbWildBattle(species[0],level)
      }
      @bossBattled = true if lairpoke==@bossSpecies
      advanced = true if !ended?
      pbUpdateLairHP if advanced
      pbAutoMapPosition(@player,2) if advanced
    end
  end
  
  
################################################################################
# SECTION 3 - MAP SPRITES
#===============================================================================
# Sets up and draws all relevant map sprites for the Max Lair map.
#===============================================================================
  def pbStartMapScene(map)
    @size        = @lairSpecies.length
    @sprites     = {}
    @viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z  = 99999
    pbSetMapSprites(map)
    @arrow0 = @sprites["arrow0"] = IconSprite.new(0,0,@viewport)
    @arrow0.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow0.src_rect.set(0,0,16,16)
    @arrow1 = @sprites["arrow1"] = IconSprite.new(0,0,@viewport)
    @arrow1.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow1.src_rect.set(16,0,16,16)
    @arrow2 = @sprites["arrow2"] = IconSprite.new(0,0,@viewport)
    @arrow2.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow2.src_rect.set(32,0,16,16)
    @arrow3 = @sprites["arrow3"] = IconSprite.new(0,0,@viewport)
    @arrow3.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow3.src_rect.set(48,0,16,16)
    @cursor = @sprites["cursor"] = IconSprite.new(0,0,@viewport)
    @cursor.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_cursor")
    @cursor.src_rect.set(0,0,64,64)
    @sprites["return"] = IconSprite.new(Graphics.width-119,Graphics.height-77,@viewport)
    @sprites["return"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["return"].src_rect.set(0,0,119,77)
    @sprites["options"] = IconSprite.new(Graphics.width-85,Graphics.height-26,@viewport)
    @sprites["options"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["options"].src_rect.set(175,0,85,26)
    @sprites["select"] = IconSprite.new(126,Graphics.height-36,@viewport)
    @sprites["select"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["select"].src_rect.set(0,77,260,36)
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = Graphics.width/2-14
    @sprites["uparrow"].y = 0
    @sprites["uparrow"].play
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = Graphics.width/2-14
    @sprites["downarrow"].y = Graphics.height-44
    @sprites["downarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2-14
    @sprites["leftarrow"].play
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width-44
    @sprites["rightarrow"].y = Graphics.height/2-14
    @sprites["rightarrow"].play
    @maxHearts = @knockouts
    for i in 0...@maxHearts
      @sprites["hpcount#{i}"] = IconSprite.new(4+(i*34),4,@viewport)
      @sprites["hpcount#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_hearts")
      @sprites["hpcount#{i}"].src_rect.set(0,0,34,30)
    end
    pbHideUISprites
    pbHideSwitchTargs
    pbAutoMapPosition(@player,2,true)
    pbBGMPlay("Dynamax Adventure")
    pbMapIntro if !($DEBUG && Input.press?(Input::CTRL))
    if    @startTile.x>@player.x; direction = 3 
    elsif @startTile.x<@player.x; direction = 2
    elsif @startTile.y>@player.y; direction = 1
    else; direction = 0
    end
    pbMovePlayerIcon(direction)
    pbChooseRoute
  end

#===============================================================================
# Draws all Max Lair map tiles.
#===============================================================================
  def pbSetMapSprites(map)
    pbSetMapTiles(map)
    offset = 4
    @mapSprites  = []
    @pokeSprites = []
    #---------------------------------------------------------------------------
    # Draws the lair map.
    #---------------------------------------------------------------------------
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].bitmap = Bitmap.new(sprintf("Graphics/Pictures/Dynamax/LairMaps/map_%02d",map))
    bgheight = @sprites["background"].bitmap.height
    bgwidth  = @sprites["background"].bitmap.width
    @mapSprites.push(@sprites["background"])
    @upperBounds = -offset
    @lowerBounds = (Graphics.height-bgheight)+offset
    @leftBounds  = -offset
    @rightBounds = (Graphics.width-bgwidth)-offset
    #---------------------------------------------------------------------------
    # Draws the lair's start point tile on the map.
    #---------------------------------------------------------------------------
    @startTile = @sprites["startTile"] = IconSprite.new(@mapStart[0],@mapStart[1],@viewport)
    @startTile.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
    @startTile.src_rect.set(0,0,32,32)
    @mapSprites.push(@startTile)
    #---------------------------------------------------------------------------
    # Draws all Selection tiles on the map.
    #---------------------------------------------------------------------------
    selectionTiles = []
    for i in 0...@mapPathsUL.length
      mapPoints = @mapPathsUL[i]
      tile = @sprites["mapPathUL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUR.length
      mapPoints = @mapPathsUR[i]
      tile = @sprites["mapPathUR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDL.length
      mapPoints = @mapPathsDL[i]
      tile = @sprites["mapPathDL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDR.length
      mapPoints = @mapPathsDR[i]
      tile = @sprites["mapPathDR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUD.length
      mapPoints = @mapPathsUD[i]
      tile = @sprites["mapPathUD#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsLR.length
      mapPoints = @mapPathsLR[i]
      tile = @sprites["mapPathLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsULR.length
      mapPoints = @mapPathsULR[i]
      tile = @sprites["mapPathULR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDL.length
      mapPoints = @mapPathsUDL[i]
      tile = @sprites["mapPathUDL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDR.length
      mapPoints = @mapPathsUDR[i]
      tile = @sprites["mapPathUDR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDLR.length
      mapPoints = @mapPathsDLR[i]
      tile = @sprites["mapPathDLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDLR.length
      mapPoints = @mapPathsUDLR[i]
      tile = @sprites["mapPathUDLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for tile in selectionTiles
      tile.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      tile.src_rect.set(32,0,32,32)
      @mapSprites.push(tile)
    end
    #---------------------------------------------------------------------------
    # Draws all Random Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnRandom.length
      xpos = @mapTurnRandom[i][0]
      ypos = @mapTurnRandom[i][1]
      @sprites["mapTurnRandom#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnRandom#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnRandom#{i}"].src_rect.set(0,32,32,32)
      @mapSprites.push(@sprites["mapTurnRandom#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Flip Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnFlip.length
      xpos = @mapTurnFlip[i][0]
      ypos = @mapTurnFlip[i][1]
      @sprites["mapTurnFlip#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnFlip#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnFlip#{i}"].src_rect.set(32,32,32,32)
      @mapSprites.push(@sprites["mapTurnFlip#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Up Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnUp.length
      xpos = @mapTurnUp[i][0]
      ypos = @mapTurnUp[i][1]
      @sprites["mapTurnUp#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnUp#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnUp#{i}"].src_rect.set(64,32,32,32)
      @mapSprites.push(@sprites["mapTurnUp#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Down Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnDown.length
      xpos = @mapTurnDown[i][0]
      ypos = @mapTurnDown[i][1]
      @sprites["mapTurnDown#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnDown#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnDown#{i}"].src_rect.set(96,32,32,32)
      @mapSprites.push(@sprites["mapTurnDown#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Left Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnLeft.length
      xpos = @mapTurnLeft[i][0]
      ypos = @mapTurnLeft[i][1]
      @sprites["mapTurnLeft#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnLeft#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnLeft#{i}"].src_rect.set(128,32,32,32)
      @mapSprites.push(@sprites["mapTurnLeft#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Right Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnRight.length
      xpos = @mapTurnRight[i][0]
      ypos = @mapTurnRight[i][1]
      @sprites["mapTurnRight#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnRight#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnRight#{i}"].src_rect.set(160,32,32,32)
      @mapSprites.push(@sprites["mapTurnRight#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Warp Point tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapWarpPoint.length
      xpos = @mapWarpPoint[i][0]
      ypos = @mapWarpPoint[i][1]
      @sprites["mapWarpPoint#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapWarpPoint#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapWarpPoint#{i}"].src_rect.set(192,32,32,32)
      @mapSprites.push(@sprites["mapWarpPoint#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Random Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventRandom.length
      xpos = @mapEventRandom[i][0]
      ypos = @mapEventRandom[i][1]
      @sprites["mapEventRandom#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventRandom#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventRandom#{i}"].src_rect.set(0,64,32,32)
      @mapSprites.push(@sprites["mapEventRandom#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Scientist Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventSwap.length
      xpos = @mapEventSwap[i][0]
      ypos = @mapEventSwap[i][1]
      @sprites["mapEventSwap#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventSwap#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventSwap#{i}"].src_rect.set(32,64,32,32)
      @mapSprites.push(@sprites["mapEventSwap#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Backpacker Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventItems.length
      xpos = @mapEventItems[i][0]
      ypos = @mapEventItems[i][1]
      @sprites["mapEventItems#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventItems#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventItems#{i}"].src_rect.set(64,64,32,32)
      @mapSprites.push(@sprites["mapEventItems#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Blackbelt Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventTrain.length
      xpos = @mapEventTrain[i][0]
      ypos = @mapEventTrain[i][1]
      @sprites["mapEventTrain#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventTrain#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventTrain#{i}"].src_rect.set(96,64,32,32)
      @mapSprites.push(@sprites["mapEventTrain#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Ace Trainer Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventTutor.length
      xpos = @mapEventTutor[i][0]
      ypos = @mapEventTutor[i][1]
      @sprites["mapEventTutor#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventTutor#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventTutor#{i}"].src_rect.set(128,64,32,32)
      @mapSprites.push(@sprites["mapEventTutor#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Channeler Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventWard.length
      xpos = @mapEventWard[i][0]
      ypos = @mapEventWard[i][1]
      @sprites["mapEventWard#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventWard#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventWard#{i}"].src_rect.set(160,64,32,32)
      @mapSprites.push(@sprites["mapEventWard#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Nurse Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventHeal.length
      xpos = @mapEventHeal[i][0]
      ypos = @mapEventHeal[i][1]
      @sprites["mapEventHeal#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventHeal#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventHeal#{i}"].src_rect.set(192,64,32,32)
      @mapSprites.push(@sprites["mapEventHeal#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Berry tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventBerry.length
      xpos = @mapEventBerry[i][0]
      ypos = @mapEventBerry[i][1]
      @sprites["mapEventBerry#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventBerry#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventBerry#{i}"].src_rect.set(192,0,32,32)
      @mapSprites.push(@sprites["mapEventBerry#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Roadblock tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapRoadblock.length
      xpos = @mapRoadblock[i][0]
      ypos = @mapRoadblock[i][1]
      rand = rand(12)
      @sprites["mapRoadblock#{i}#{rand}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapRoadblock#{i}#{rand}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapRoadblock#{i}#{rand}"].src_rect.set(160,0,32,32)
      @mapSprites.push(@sprites["mapRoadblock#{i}#{rand}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Switch tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapSwitches.length
      xpos = @mapSwitches[i][0]
      ypos = @mapSwitches[i][1]
      @sprites["mapSwitches#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapSwitches#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapSwitches#{i}"].src_rect.set(96,0,32,32)
      @mapSprites.push(@sprites["mapSwitches#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Switch Target tiles on the map. (No visible sprite)
    #---------------------------------------------------------------------------
    for i in 0...@mapSwitchTargs.length
      xpos = @mapSwitchTargs[i][0]
      ypos = @mapSwitchTargs[i][1]
      @sprites["mapSwitchTargs#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapSwitchTargs#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapSwitchTargs#{i}"].src_rect.set(0,0,0,0)
      @sprites["mapSwitchTargs#{i}"].visible = false
      @mapSprites.push(@sprites["mapSwitchTargs#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Hidden Trap tiles on the map. (No visible sprite)
    #---------------------------------------------------------------------------
    for i in 0...@mapHiddenTrap.length
      xpos = @mapHiddenTrap[i][0]
      ypos = @mapHiddenTrap[i][1]
      rand = rand(6)
      @sprites["mapHiddenTrap#{i}#{rand}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapHiddenTrap#{i}#{rand}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapHiddenTrap#{i}#{rand}"].src_rect.set(0,0,0,0)
      @sprites["mapHiddenTrap#{i}#{rand}"].visible = false if rand(10)<4
      @mapSprites.push(@sprites["mapHiddenTrap#{i}#{rand}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Pokemon event tiles on the map.
    #---------------------------------------------------------------------------
    typeBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    for i in 0...@lairSpecies.length
      xpos = @mapPkmnCoords[i][0]
      ypos = @mapPkmnCoords[i][1]
      @sprites["mapPokemon#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapPokemon#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapPokemon#{i}"].src_rect.set(64,0,32,32)
      @sprites["mapPokemon#{i}"].visible = false
      @mapSprites.push(@sprites["mapPokemon#{i}"])
      poke    = pbGetSpeciesFromFSpecies(@lairSpecies[i])
      species = poke[0]
      form    = poke[1]
      types   = [pbGetSpeciesData(species,form,SpeciesType1), 
                 pbGetSpeciesData(species,form,SpeciesType2)]
      raidtype  = types[rand(types.length)]
      @bosstype = PBTypes.getName(raidtype) if i==(@lairSpecies.length-1)
      pokemon = @sprites["pokemon#{i}"] = PokemonSprite.new(@viewport)
      pokemon.setSpeciesBitmap(species,nil,form)
      pokemon.setOffset(PictureOrigin::Center)
      pokemon.zoom_x = 0.5
      pokemon.zoom_y = 0.5
      pokemon.color.alpha = 255
      pokemon.x = @sprites["mapPokemon#{i}"].x+16
      pokemon.y = @sprites["mapPokemon#{i}"].y-16
      poketype  = @sprites["poketype#{i}"] = IconSprite.new(pokemon.x-32,pokemon.y+20,@viewport)
      poketype.bitmap = Bitmap.new("Graphics/Pictures/types")
      poketype.src_rect.set(0,raidtype*28,64,28)
      @pokeSprites.push(pokemon)
      @pokeSprites.push(poketype)
    end
    #---------------------------------------------------------------------------
    # Draws the player's icon.
    #---------------------------------------------------------------------------
    @player = @sprites["player"] = IconSprite.new(@entryPoint[0],@entryPoint[1],@viewport)
    @player.setBitmap(pbPlayerHeadFile($Trainer.trainertype))
    @mapSprites.push(@player)
    #---------------------------------------------------------------------------
    # Centers all map sprites.
    #---------------------------------------------------------------------------
    @sprites["background"].y = Graphics.height-bgheight
    allSprites = @mapSprites+@pokeSprites
    for sprite in allSprites
      sprite.y+=offset*2
      sprite.x+=8+(offset*2)
    end
  end

  
################################################################################
# SECTION 4 - MAP MOVEMENT
#===============================================================================
# Handles all code related to moving sprites on the Max Lair map.
#===============================================================================
  # Checks for a variety of conditions of the player's current tile.
  def pbCanMoveUp?;      return true if pbRouteSelections.include?(0); end
  def pbCanMoveDown?;    return true if pbRouteSelections.include?(1); end
  def pbCanMoveLeft?;    return true if pbRouteSelections.include?(2); end
  def pbCanMoveRight?;   return true if pbRouteSelections.include?(3); end
  def pbSelectionTile?;  return true if pbRouteSelections; end
  def pbUpTurnTile?;     return true if pbTurnTiles==0;    end
  def pbDownTurnTile?;   return true if pbTurnTiles==1;    end
  def pbLeftTurnTile?;   return true if pbTurnTiles==2;    end
  def pbRightTurnTile?;  return true if pbTurnTiles==3;    end
  def pbRandTurnTile?;   return true if pbTurnTiles==4;    end
  def pbFlipTurnTile?;   return true if pbTurnTiles==5;    end
  def pbSwapEventTile?;  return true if pbEventTiles==0;   end
  def pbItemsEventTile?; return true if pbEventTiles==1;   end
  def pbTrainEventTile?; return true if pbEventTiles==2;   end
  def pbTutorEventTile?; return true if pbEventTiles==3;   end
  def pbWardEventTile?;  return true if pbEventTiles==4;   end
  def pbHealEventTile?;  return true if pbEventTiles==5;   end
  def pbRandEventTile?;  return true if pbEventTiles==6;   end
  def pbBerryEventTile?; return true if pbEventTiles==7;   end
  def pbPokemonTile?;    return true if pbPokemonTiles;    end
  
  #-----------------------------------------------------------------------------
  # Checks if the inputted coordinates match the map's Start Tile.
  #-----------------------------------------------------------------------------
  def pbStartTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    start  = [@startTile.x,@startTile.y]
    return true if coords==start
  end
  
  #-----------------------------------------------------------------------------
  # Returns the index of the Pokemon tile the player is on, if any.
  #-----------------------------------------------------------------------------  
  def pbPokemonTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapPkmnCoords.length
      tile    = @sprites["mapPokemon#{i}"]
      tilepos = [tile.x,tile.y]
      next if coords!=tilepos
      ret = i
    end
    return ret
  end
    
  #-----------------------------------------------------------------------------
  # Code related to Warp Tiles.
  #-----------------------------------------------------------------------------
  # Checks if there's a Warp Tile at the inputted coordinates.
  def pbWarpTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapWarpPoint.length
      tile    = @sprites["mapWarpPoint#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = true
    end
    return ret
  end
  
  # Automatically teleports the player to the next available Warp Tile.
  def pbWarpPlayer
    coords = [@player.x,@player.y]
    if pbWarpTile?(coords)
      for i in 0...@mapWarpPoint.length
        warpTile   = @sprites["mapWarpPoint#{i}"]
        warpCoords = [warpTile.x,warpTile.y]
        if coords==warpCoords
          newpos    = i+1
          newpos    = 0 if newpos>@mapWarpPoint.length-1
          pbWait(20)
          pbSEPlay("Player jump")
          @player.visible = false
          @player.x = @sprites["mapWarpPoint#{newpos}"].x
          @player.y = @sprites["mapWarpPoint#{newpos}"].y
          pbAutoMapPosition(@player,8)
          pbSEPlay("Player jump")
          @player.visible = true
          pbWait(20)
        end
      end
    end
  end  
    
  #-----------------------------------------------------------------------------
  # Code related to Roadblock Tiles.
  #-----------------------------------------------------------------------------
  # Checks if there's a Roadblock Tile at the inputted coordinates.
  def pbRoadblockTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapRoadblock.length
      for j in 0...12
        if @sprites["mapRoadblock#{i}#{j}"]
          tile    = @sprites["mapRoadblock#{i}#{j}"]
          tilepos = [tile.x,tile.y]
          next if !tile.visible
          next if coords!=tilepos
          ret = true
        end
      end
    end
    return ret
  end
  
  # Returns the type of Roadblock that is present at the inputted coordinates.
  def pbRoadblockType(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for event in 0...@mapRoadblock.length
      for type in 0...12
        if @sprites["mapRoadblock#{event}#{type}"]
          tile    = @sprites["mapRoadblock#{event}#{type}"]
          tilepos = [tile.x,tile.y]
          next if coords!=tilepos
          ret = type
        end
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Code related to Hidden Trap Tiles.
  #-----------------------------------------------------------------------------
  # Checks if there's a Hidden Trap Tile at the inputted coordinates.
  def pbHiddenTrapTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapHiddenTrap.length
      for j in 0...6
        if @sprites["mapHiddenTrap#{i}#{j}"]
          tile    = @sprites["mapHiddenTrap#{i}#{j}"]
          tilepos = [tile.x,tile.y]
          next if !tile.visible
          next if coords!=tilepos
          ret = true
        end
      end
    end
    return ret
  end
  
  # Returns the type of Hidden Trap that is present at the inputted coordinates.
  def pbHiddenTrapType(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for event in 0...@mapHiddenTrap.length
      for type in 0...6
        if @sprites["mapHiddenTrap#{event}#{type}"]
          tile    = @sprites["mapHiddenTrap#{event}#{type}"]
          tilepos = [tile.x,tile.y]
          next if coords!=tilepos
          ret = type
        end
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Code related to Switch and Switch Target Tiles.
  #-----------------------------------------------------------------------------
  # Checks if there's a Switch Tile at the inputted coordinates.
  def pbSwitchTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapSwitches.length
      tile    = @sprites["mapSwitches#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = true
    end
    return ret
  end
  
  # Hides the sprites for all tiles that share the coordinates of a Switch Target Tile.
  def pbHideSwitchTargs
    for i in 0...@mapSwitchTargs.length
      tile    = @sprites["mapSwitchTargs#{i}"]
      tilepos = [tile.x,tile.y]
      for sprite in @mapSprites
        next if sprite==@player
        next if sprite==@startTile
        next if sprite==@sprites["background"]
        next if pbPokemonTiles(tilepos)
        next if pbRoadblockTile?(tilepos)
        next if pbHiddenTrapTile?(tilepos)
        coords = [sprite.x,sprite.y]
        sprite.visible = false if coords==tilepos
      end
    end
  end
  
  # Toggles the sprites for all tiles that share the coordinates of a Switch Target Tile.
  def pbToggleSwitchTargs
    pbWait(10)
    pbSEPlay("Voltorb flip tile")
    for i in 0...@mapSwitchTargs.length
      tile    = @sprites["mapSwitchTargs#{i}"]
      tilepos = [tile.x,tile.y]
      for sprite in @mapSprites
        next if sprite==@player
        next if sprite==@startTile
        next if sprite==@sprites["background"]
        next if pbPokemonTiles(tilepos)
        next if pbRoadblockTile?(tilepos)
        next if pbHiddenTrapTile?(tilepos)
        coords = [sprite.x,sprite.y]
        if coords==tilepos
          sprite.visible = (sprite.visible) ? false : true
          toggle = (sprite.visible) ? 128 : 96
        end
      end
    end
    for i in 0...@mapSwitches.length
      @sprites["mapSwitches#{i}"].src_rect.set(toggle,0,32,32)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Returns the type of Turn tile the player is on. (0-5)
  #-----------------------------------------------------------------------------
  def pbTurnTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapTurnUp.length
      tile    = @sprites["mapTurnUp#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 0
    end
    for i in 0...@mapTurnDown.length
      tile    = @sprites["mapTurnDown#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 1
    end
    for i in 0...@mapTurnLeft.length
      tile    = @sprites["mapTurnLeft#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 2
    end
    for i in 0...@mapTurnRight.length
      tile    = @sprites["mapTurnRight#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 3
    end
    for i in 0...@mapTurnRandom.length
      tile    = @sprites["mapTurnRandom#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 4
    end
    for i in 0...@mapTurnFlip.length
      tile    = @sprites["mapTurnFlip#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 5
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Returns the type of Event tile the player is on. (0-7)
  #-----------------------------------------------------------------------------
  def pbEventTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapEventSwap.length
      tile    = @sprites["mapEventSwap#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 0
    end
    for i in 0...@mapEventItems.length
      tile    = @sprites["mapEventItems#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 1
    end
    for i in 0...@mapEventTrain.length
      tile    = @sprites["mapEventTrain#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 2
    end
    for i in 0...@mapEventTutor.length
      tile    = @sprites["mapEventTutor#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 3
    end
    for i in 0...@mapEventWard.length
      tile    = @sprites["mapEventWard#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 4
    end
    for i in 0...@mapEventHeal.length
      tile    = @sprites["mapEventHeal#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 5
    end
    for i in 0...@mapEventRandom.length
      tile    = @sprites["mapEventRandom#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 6
    end
    for i in 0...@mapEventBerry.length
      tile    = @sprites["mapEventBerry#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 7
    end
    return ret
  end
    
  #-----------------------------------------------------------------------------
  # Returns which directions can be chosen on a given Selection tile.
  #-----------------------------------------------------------------------------
  def pbRouteSelections(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapPathsUL.length
      tile    = @sprites["mapPathUL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,2]
    end
    for i in 0...@mapPathsUR.length
      tile    = @sprites["mapPathUR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,3]
    end 
    for i in 0...@mapPathsDL.length
      tile    = @sprites["mapPathDL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,2]
    end
    for i in 0...@mapPathsDR.length
      tile    = @sprites["mapPathDR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,3]
    end
    for i in 0...@mapPathsUD.length
      tile    = @sprites["mapPathUD#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1]
    end 
    for i in 0...@mapPathsLR.length
      tile    = @sprites["mapPathLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [2,3]
    end
    for i in 0...@mapPathsULR.length
      tile    = @sprites["mapPathULR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,2,3]
    end
    for i in 0...@mapPathsUDL.length
      tile    = @sprites["mapPathUDL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,2]
    end
    for i in 0...@mapPathsUDR.length
      tile    = @sprites["mapPathUDR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,3]
    end
    for i in 0...@mapPathsDLR.length
      tile    = @sprites["mapPathDLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,2,3]
    end
    for i in 0...@mapPathsUDLR.length
      tile    = @sprites["mapPathUDLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,2,3]
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Moves the player's icon around the map.
  #-----------------------------------------------------------------------------
  def pbMovePlayerIcon(index=0)
    pbChangePokeOpacity
    moveUp    = true if index==0
    moveDown  = true if index==1
    moveLeft  = true if index==2
    moveRight = true if index==3
    moveStop  = false
    loop do
      #-------------------------------------------------------------------------
      # Move player.
      #-------------------------------------------------------------------------
      pbWait(1)
      if    moveUp;    @player.y -=2
      elsif moveDown;  @player.y +=2
      elsif moveLeft;  @player.x -=2
      elsif moveRight; @player.x +=2
      end
      #-------------------------------------------------------------------------
      # Roadblock Tile triggers.
      #-------------------------------------------------------------------------
      if pbRoadblockTile? && !pbLairObstacles(pbRoadblockType)
        if    moveUp;    moveDown  = true; moveUp    = false
        elsif moveDown;  moveUp    = true; moveDown  = false
        elsif moveLeft;  moveRight = true; moveLeft  = false
        elsif moveRight; moveLeft  = true; moveRight = false
        end
      end
      #-------------------------------------------------------------------------
      # Turn Tile triggers.
      #-------------------------------------------------------------------------
      if pbTurnTiles
        if pbFlipTurnTile?
          if    moveUp;    moveDown  = true; moveUp    = false
          elsif moveDown;  moveUp    = true; moveDown  = false
          elsif moveLeft;  moveRight = true; moveLeft  = false
          elsif moveRight; moveLeft  = true; moveRight = false
          end
        else
          moveUp = moveDown = moveLeft = moveRight = false
          if    pbUpTurnTile?;    moveUp    = true
          elsif pbDownTurnTile?;  moveDown  = true
          elsif pbLeftTurnTile?;  moveLeft  = true
          elsif pbRightTurnTile?; moveRight = true
          elsif pbRandTurnTile?
            randturn  = rand(4)
            moveUp    = true if randturn==0
            moveDown  = true if randturn==1
            moveLeft  = true if randturn==2
            moveRight = true if randturn==3
          end
        end
      end
      #-------------------------------------------------------------------------
      # Event Tile triggers.
      #-------------------------------------------------------------------------
      if pbEventTiles
        if    pbSwapEventTile?;  pbLairEventSwap
        elsif pbItemsEventTile?; pbLairEventItems
        elsif pbTrainEventTile?; pbLairEventTrain
        elsif pbTutorEventTile?; pbLairEventTutor
        elsif pbWardEventTile?;  pbLairEventWard
        elsif pbHealEventTile?;  pbLairEventHeal
        elsif pbRandEventTile?;  pbLairEventRandom
        elsif pbBerryEventTile?; pbLairBerries
        end
      end
      #-------------------------------------------------------------------------
      # Other Tile triggers.
      #-------------------------------------------------------------------------
      pbWarpPlayer if pbWarpTile?
      pbToggleSwitchTargs if pbSwitchTile?
      pbLairTraps(pbHiddenTrapType) if pbHiddenTrapTile?
      moveStop = true if pbSelectionTile? || pbStartTile?
      pbBattleLairPokemon(pbPokemonTiles) if pbPokemonTile?
      pbAutoMapPosition(@player,2) if @player.x<32
      pbAutoMapPosition(@player,2) if @player.x>Graphics.width-32
      pbAutoMapPosition(@player,2) if @player.y<32
      pbAutoMapPosition(@player,2) if @player.y>Graphics.height-32
      break if moveStop || ended?
    end
  end
  
  #-----------------------------------------------------------------------------
  # Automatically scrolls the map to the correct position when needed.
  #-----------------------------------------------------------------------------
  def pbAutoMapPosition(sprite,speed,instant=false)
    xBoundsReached = false
    yBoundsReached = false
    center = [(Graphics.width/2)-16,(Graphics.height/2)+32]
    allSprites = @mapSprites+@pokeSprites
    loop do
      coords = [sprite.x,sprite.y]
      xBoundsReached = true if coords[0]==center[0]
      yBoundsReached = true if coords[1]==center[1]
      #-------------------------------------------------------------------------
      # X axis movement.
      #-------------------------------------------------------------------------
      if !xBoundsReached
        # Target sprite is left of center.
        if coords[0]<center[0]
          if @sprites["background"].x+2*speed>=@leftBounds+2
            xBoundsReached = true
          else
            if (center[0]-coords[0])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.x+=2*speed; end
            else; for i in allSprites; i.x+=1; end
            end
          end
        end
        # Target sprite is right of center.
        if coords[0]>center[0]
          if @sprites["background"].x-2*speed<=@rightBounds+2
            xBoundsReached = true
          else
            if (coords[0]-center[0])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.x-=2*speed; end 
            else; for i in allSprites; i.x-=1; end
            end
          end
        end
      end
      #-------------------------------------------------------------------------
      # Y axis movement.
      #-------------------------------------------------------------------------
      if !yBoundsReached
        # Target sprite is above center.
        if coords[1]<center[1]
          if @sprites["background"].y+2*speed>=@upperBounds+2
            yBoundsReached = true
          else
            if (center[1]-coords[1])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.y+=2*speed; end 
            else; for i in allSprites; i.y+=1; end
            end
          end
        end
        # Target sprite is below center.
        if coords[1]>center[1]
          if @sprites["background"].y-2*speed<=@lowerBounds+2
            yBoundsReached = true
          else
            if (coords[1]-center[1])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.y-=2*speed; end 
            else; for i in allSprites; i.y-=1; end
            end
          end
        end
      end
      break if xBoundsReached && yBoundsReached
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows for free scrolling of the Max Lair map.
  #-----------------------------------------------------------------------------
  def pbLairMapScroll(index)
    pbHideUISprites
    @cursor.x = @player.x-16
    @cursor.y = @player.y-16
    @cursor.visible = true
    @sprites["return"].visible = true
    allSprites = @mapSprites+@pokeSprites
    for i in 0...@mapPkmnCoords.length
      @sprites["mapPokemon#{i}"].visible = true
    end
    loop do
      move = 8
      Graphics.update
      Input.update
      pbUpdate
      @sprites["uparrow"].visible    = true
      @sprites["downarrow"].visible  = true
      @sprites["leftarrow"].visible  = true
      @sprites["rightarrow"].visible = true
      #-------------------------------------------------------------------------
      # Scroll map and cursor upwards.
      #-------------------------------------------------------------------------
      if Input.press?(Input::UP)
        @cursor.y-=move if @cursor.y>0
        if @sprites["background"].y<=(@upperBounds-move)
          for i in allSprites; i.y += move; end
        else
          @sprites["uparrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor downwards.
      #-------------------------------------------------------------------------
      if Input.press?(Input::DOWN)
        @cursor.y+=move if @cursor.y<=Graphics.height-72
        if @sprites["background"].y>=(@lowerBounds+move)
          for i in allSprites; i.y -= move; end
        else
          @sprites["downarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor to the left.
      #-------------------------------------------------------------------------
      if Input.press?(Input::LEFT)
        @cursor.x-=move if @cursor.x>0
        if @sprites["background"].x<=(@leftBounds-move)
          for i in allSprites; i.x += move; end
        else
          @sprites["leftarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor to the right.
      #-------------------------------------------------------------------------
      if Input.press?(Input::RIGHT)
        @cursor.x+=move if @cursor.x<=Graphics.width-72
        if @sprites["background"].x>=(@rightBounds+move)
          for i in allSprites; i.x -= move; end
        else
          @sprites["rightarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Toggle Pokemon sprites.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::A)
        pbPlayCancelSE
        for i in 0...@mapPkmnCoords.length
          mapPoke = @sprites["pokemon#{i}"]
          mapType = @sprites["poketype#{i}"]
          mapPoke.visible = (mapPoke.visible) ? false: true
          mapType.visible = (mapType.visible) ? false: true
        end
      end
      #-------------------------------------------------------------------------
      # Gets tile information.
      #-------------------------------------------------------------------------
      if pbCursorReact.is_a?(Array)
        @cursor.src_rect.set(64,0,64,64)
        if Input.trigger?(Input::C)
          @cursor.x = pbCursorReact[0]-16 
          @cursor.y = pbCursorReact[1]-16
          @cursor.src_rect.set(64,0,64,64)
          newcoords = [@cursor.x+16,@cursor.y+16]
          if pbStartTile?(newcoords)
            pbMessage(_INTL("This is the Start Tile.\nThis will always be the first tile you move towards."))
          elsif pbRouteSelections(newcoords)
            pbMessage(_INTL("This is a Selection Tile.\nLanding on this tile will allow you to choose a new path to travel in."))
            pbMessage(_INTL("The number of paths you can choose from varies with each individual Selection Tile."))
          elsif pbPokemonTiles(newcoords)
            pbMessage(_INTL("This is a Raid Tile.\nPassing over this tile will initiate a battle against a Dynamaxed Pokémon."))
            pbMessage(_INTL("Once captured or defeated, this tile is cleared and the Pokémon cannot be challenged again."))
          elsif pbWarpTile?(newcoords)
            pbMessage(_INTL("This is a Warp Tile.\nLanding on this tile will teleport you to another Warp Tile on the map that is linked to this one."))
          elsif pbRoadblockTile?(newcoords)
            pbMessage(_INTL("This is a Roadblock Tile.\nAn obstacle prevents movement here unless you meet certain criteria."))
            pbMessage(_INTL("Once the obstacle's criteria has been met, this tile will become cleared and you will not be required to clear the obstacle again."))
          elsif pbSwitchTile?(newcoords)
            pbMessage(_INTL("This is a Switch Tile.\nLanding on this tile will flip all switches to the ON position, revealing hidden tiles that are normally inactive."))
            pbMessage(_INTL("Landing on a Switch Tile that is already in the ON position will revert all switches to the OFF position, and any revealed tiles will return to their inactive state."))
          elsif pbTurnTiles(newcoords)==4
            pbMessage(_INTL("This is a Random Turn Tile.\nPassing over this tile may force you into changing course in a random direction."))
          elsif pbTurnTiles(newcoords)==5
            pbMessage(_INTL("This is a Flip Turn Tile.\nLanding on this tile will force you to reverse course and travel in the opposite direction."))
          elsif pbTurnTiles(newcoords)
            pbMessage(_INTL("This is a Directional Tile.\nPassing over this tile will force you to move in the direction it's pointing."))
          elsif pbEventTiles(newcoords)==0
            pbMessage(_INTL("There's a Scientist on this tile.\nScientists have additional rental Pokémon you may add to your party by swapping out an existing party member."))
            pbMessage(_INTL("After encountering a Scientist, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==1
            pbMessage(_INTL("There's a Backpacker on this tile.\nBackpackers carry a random assortment of items that may be given to your party Pokémon to hold."))
          elsif pbEventTiles(newcoords)==2
            pbMessage(_INTL("There's a Blackbelt on this tile.\nBlackbelts have secret training techniques that can power up particular stats of your party Pokémon."))
          elsif pbEventTiles(newcoords)==3
            pbMessage(_INTL("There's an Ace Trainer on this tile.\nAce Trainers can tutor your party Pokémon to teach one of them a new move for a strategical advantage."))
          elsif pbEventTiles(newcoords)==4
            pbMessage(_INTL("There's a Channeler on this tile.\nChannelers will raise your spirit, increasing your heart counter by one."))
            pbMessage(_INTL("After encountering a Channeler, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==5
            pbMessage(_INTL("There's a Nurse on this tile.\nNurses will heal your party Pokémon back to full health."))
            pbMessage(_INTL("After encountering a Nurse, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==6
            pbMessage(_INTL("It's a mystery who you'll find on this tile.\nYou'll never know who you may run into!"))
            pbMessage(_INTL("After encountering this mystery person, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==7
            pbMessage(_INTL("There's a pile of Berries on this tile.\nIf you land on this tile, you'll feed your party Pokémon the Berries to recover some HP."))
            pbMessage(_INTL("This tile will become cleared after consuming the Berries."))
          end
        end
      end
      #-------------------------------------------------------------------------
      # Returns to route selection.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        pbHideUISprites
        for i in 0...@mapPkmnCoords.length
          @sprites["mapPokemon#{i}"].visible = false
          if @sprites["pokemon#{i}"].color.alpha==255
            @sprites["pokemon#{i}"].visible  = true
            @sprites["poketype#{i}"].visible = true
          else
            @sprites["pokemon#{i}"].visible  = false
            @sprites["poketype#{i}"].visible = false
          end
        end
        pbAutoMapPosition(@player,move)
        @sprites["select"].visible  = true
        @sprites["options"].visible = true
        break
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows the player to select a route to take while on a Selection tile.
  #-----------------------------------------------------------------------------
  def pbChooseRoute
    endgame = false
    highlight  = Color.new(255,0,0,200)
    resetcolor = Color.new(0,0,0,0)
    loop do
      break if ended?
      pbAutoMapPosition(@player,2)
      pbChangePokeOpacity(false)
      pbMessage(_INTL("Which path would you like to take?"))
      pbResetRaidSettings
      $PokemonTemp.clearBattleRules
      coords     = [@player.x,@player.y]
      index = 3 if pbCanMoveRight?
      index = 2 if pbCanMoveLeft?
      index = 1 if pbCanMoveDown?
      index = 0 if pbCanMoveUp?
      @arrow0.color = highlight if index==0
      @arrow1.color = highlight if index==1
      @arrow2.color = highlight if index==2
      @arrow3.color = highlight if index==3
      loop do
        Graphics.update
        Input.update
        pbUpdate
        @arrow0.y = @player.y-16
        @arrow1.y = @player.y+32
        @arrow0.x = @arrow1.x = @player.x+8
        @arrow2.x = @player.x-16
        @arrow3.x = @player.x+32
        @arrow2.y = @arrow3.y = @player.y+10
        @arrow0.visible = true if pbCanMoveUp?
        @arrow1.visible = true if pbCanMoveDown?
        @arrow2.visible = true if pbCanMoveLeft?
        @arrow3.visible = true if pbCanMoveRight?
        @sprites["select"].visible  = true
        @sprites["options"].visible = true
        #-----------------------------------------------------------------------
        # Selects between available routes to take.
        #-----------------------------------------------------------------------
        if Input.trigger?(Input::UP) && pbCanMoveUp?
          pbPlayCancelSE
          Input.update
          index = 0
        end
        if Input.trigger?(Input::DOWN) && pbCanMoveDown?
          pbPlayCancelSE
          Input.update
          index = 1
        end
        if Input.trigger?(Input::LEFT) && pbCanMoveLeft?
          pbPlayCancelSE
          Input.update
          index = 2
        end
        if Input.trigger?(Input::RIGHT) && pbCanMoveRight?
          pbPlayCancelSE
          Input.update
          index = 3
        end
        @arrow0.color = (index==0) ? highlight : resetcolor
        @arrow1.color = (index==1) ? highlight : resetcolor
        @arrow2.color = (index==2) ? highlight : resetcolor
        @arrow3.color = (index==3) ? highlight : resetcolor
        #-----------------------------------------------------------------------
        # Confirms a selected route.
        #-----------------------------------------------------------------------
        if Input.trigger?(Input::C)
          if pbConfirmMessage(_INTL("Are you sure you want to take this path?"))
            pbHideUISprites
            pbMovePlayerIcon(index)
            break
          end
        #-----------------------------------------------------------------------
        # Options menu.
        #-----------------------------------------------------------------------
        elsif Input.trigger?(Input::A)
          loop do
            cmd = pbMessage("What would you like to do?",
              ["View Map",
               "View Party",
               "Leave Lair"],-1,nil,0)
            case cmd
            when -1; break
            when  0; pbLairMapScroll(index); break
            when  1; pbSummary($Trainer.party,0,@sprites); break
            when  2
              if pbConfirmMessage(_INTL("End your Dynamax Adventure?\nAny captured Pokémon will be lost."))
                endgame = true
                break
              end
            end
          end
          break if endgame
        end
      end
      break if endgame  
    end
    pbMessage(_INTL("Your Dynamax Adventure is over!"))
    pbEndScene
  end
end