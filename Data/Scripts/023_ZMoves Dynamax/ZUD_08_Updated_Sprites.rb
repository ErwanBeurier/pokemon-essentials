#===============================================================================
#
# ZUD_08: Updated Sprites
#
#===============================================================================
# This script rewrites areas of the Essentials script that handle both the
# icon and battler sprites for Pokemon, to allow for Dynamax functionality.
#
#===============================================================================
# SECTION 1 - BATTLER SPRITES
#-------------------------------------------------------------------------------
# This section rewrites code related to Pokemon sprites and aesthetics in battle
# to allow for Dynamax functionality such as enlarged and reddened sprites,
# Gigantamax sprites, and deepened Dynamax cries.
#===============================================================================
# SECTION 2 - ICON SPRITES
#-------------------------------------------------------------------------------
# This section rewrites code related to Pokemon icon sprites found in the party
# screen and elsewhere to allow for Dynamax functionality. This includes things
# like enlarged and reddened icons and Gigantamax icons.
#===============================================================================

################################################################################
# SECTION 1 - BATTLER SPRITES
#===============================================================================
# Enlarges/colors Pokémon battler sprites when Dynamaxed.
#-------------------------------------------------------------------------------
class PokemonBattlerSprite < RPG::Sprite
  def setPokemonBitmap(pkmn,back=false,oldpkmn=nil)
    @pkmn    = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = pbLoadPokemonBitmap(@pkmn,back,oldpkmn)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites
    #---------------------------------------------------------------------------
    @dynamax = false
    if oldpkmn
      @dynamax = true if oldpkmn.dynamax?
    else
      @dynamax = true if @pkmn.dynamax?
    end
    if @dynamax
      if DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
        if !back
          self.y = self.y+16
        end
      end
      if DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      end
    end
    #---------------------------------------------------------------------------
  end
  
  def pbPlayIntroAnimation(pictureEx=nil)
    return if !@pkmn
    cry = pbCryFile(@pkmn)
    #---------------------------------------------------------------------------
    # Deepens Dynamax cries.
    #---------------------------------------------------------------------------
    if cry
      if @dynamax
        pbSEPlay(cry,100,60)
      else
        pbSEPlay(cry)
      end
    end
    #---------------------------------------------------------------------------
  end
  
  def update(frameCounter=0)
    return if !@_iconBitmap
    @updating = true
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    @spriteYExtra = 0
    if @selected==1
      case (frameCounter/QUARTER_ANIM_PERIOD).floor
      when 1; @spriteYExtra = 2
      when 3; @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites.
    #---------------------------------------------------------------------------
    if @dynamax
      if DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      else
        self.zoom_x = 1
        self.zoom_y = 1
      end
      if DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      else
        self.color = Color.new(0,0,0,0)
      end
    end
    #---------------------------------------------------------------------------
    self.visible = @spriteVisible
    if @selected==2 && @spriteVisible
      case (frameCounter/SIXTH_ANIM_PERIOD).floor
      when 2, 5; self.visible = false
      else;      self.visible = true
      end
    end
    @updating = false
  end
end

class PokemonBattlerShadowSprite < RPG::Sprite
  def setPokemonBitmap(pkmn)
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = pbLoadPokemonShadowBitmap(@pkmn)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    #---------------------------------------------------------------------------
    # Enlarges Dynamax shadows.
    #---------------------------------------------------------------------------
    if DYNAMAX_SIZE && @pkmn.dynamax?
      self.zoom_x = 2
      self.zoom_y = 2
    end
    #---------------------------------------------------------------------------
    pbSetPosition
  end
end

class PokeBattle_Scene
  def pbAnimationCore(animation,user,target,oppMove=false)
    return if !animation
    @briefMessage = false
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    #---------------------------------------------------------------------------
    # Used for Enlarged Dynamax sprites.
    #---------------------------------------------------------------------------
    if DYNAMAX_SIZE
      oldUserZoomX = (userSprite) ? userSprite.zoom_x : 1
      oldUserZoomY = (userSprite) ? userSprite.zoom_y : 1
      oldTargetZoomX = (targetSprite) ? targetSprite.zoom_x : 1
      oldTargetZoomY = (targetSprite) ? targetSprite.zoom_y : 1
    end
    if DYNAMAX_COLOR
      newcolor  = Color.new(217,29,71,128)
      newcolor2 = Color.new(56,160,193,128) # Calyrex
      oldcolor  = Color.new(0,0,0,0)
      # Colors user's sprite.
      if userSprite && user.dynamax?
        oldUserColor = user.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldUserColor = oldcolor
      end
      # Colors target's sprite.
      if targetSprite && target.dynamax?
        oldTargetColor = target.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldTargetColor = oldcolor
      end
    end
    #---------------------------------------------------------------------------
    animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove)
    userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
       PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
       PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
       oldUserX,oldUserY-userHeight/2,
       oldTargetX,oldTargetY-targetHeight/2)
    animPlayer.start
    loop do
      animPlayer.update
      #-------------------------------------------------------------------------
      # Used for Enlarged Dynamax sprites.
      #-------------------------------------------------------------------------
      if DYNAMAX_SIZE
        userSprite.zoom_x = oldUserZoomX if userSprite
        userSprite.zoom_y = oldUserZoomY if userSprite
        targetSprite.zoom_x = oldTargetZoomX if targetSprite
        targetSprite.zoom_y = oldTargetZoomY if targetSprite
      end
      if DYNAMAX_COLOR
        userSprite.color = oldUserColor if userSprite
        targetSprite.color = oldTargetColor if targetSprite
      end
      #-------------------------------------------------------------------------
      pbUpdate
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
  end
end

#===============================================================================
# Adds Dynamax values to Pokemon battler sprites.
#===============================================================================
class PokemonSprite < SpriteWrapper
  def setSpeciesBitmap(species,female=false,form=0,shiny=false,
                       shadow=false,back=false,egg=false,gmax=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = pbLoadSpeciesBitmap(species,female,form,shiny,shadow,back,egg,gmax) # G-Max Added
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end
end

#-------------------------------------------------------------------------------
# Used for defined Pokemon.
#-------------------------------------------------------------------------------
def pbLoadPokemonBitmap(pokemon,back=false,oldpkmn=nil)
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back,oldpkmn)
end

def pbLoadPokemonBitmapSpecies(pokemon,species,back=false,oldpkmn=nil)
  ret = nil
  if pokemon.egg?
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),pokemon.form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,pokemon.form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    # Loads the correct sprite for Pokemon using Transform on a Gigantamax Pokemon.
    gmax = false
    if oldpkmn
      gmax = true if pokemon.gmax? && oldpkmn.dynamax? && oldpkmn.gmaxFactor?
    else
      gmax = true if pokemon.gmax?
    end
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.female?),
       pokemon.shiny?,(pokemon.form rescue 0),pokemon.shadowPokemon?,gmax])
    alterBitmap = (MultipleForms.getFunction(species,"alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each { |bitmap| alterBitmap.call(pokemon,bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

#-------------------------------------------------------------------------------
# Used for Pokemon species.
#-------------------------------------------------------------------------------
def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,
                        shadow=false,back=false,egg=false,gmax=false) # G-Max Added
  ret = nil
  if egg
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow,gmax]) # G-Max Added
  end
  if bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

#-------------------------------------------------------------------------------
# Checks file pathways for battler sprites.
#-------------------------------------------------------------------------------
def pbCheckPokemonBitmapFiles(params)
  factors = []
  factors.push([6,params[6],false]) if params[6] && params[6]!=false   # gigantamax
  factors.push([5,params[5],false]) if params[5] && params[5]!=false   # shadow
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # gender
  factors.push([3,params[3],false]) if params[3] && params[3]!=false   # shiny
  factors.push([4,params[4],0]) if params[4] && params[4]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies   = 0
  tryGender    = false
  tryShiny     = false
  tryBack      = params[1]
  tryForm      = 0
  tryShadow    = false
  tryGmax      = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies    = newVal
      when 2; tryGender     = newVal
      when 3; tryShiny      = newVal
      when 4; tryForm       = newVal
      when 5; tryShadow     = newVal
      when 6; tryGmax       = newVal
      end
    end
    for j in 0...2
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Battlers/%s%s%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryBack) ? "b" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "",
         (tryGmax) ? "_gmax" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end


################################################################################
# SECTION 2 - ICON SPRITES
#===============================================================================
# Enlarges Pokemon icon sprites in the party menu when Dynamaxed.
#-------------------------------------------------------------------------------
class PokemonPartyPanel < SpriteWrapper
  def pbDynamaxSize
    if DYNAMAX_SIZE
      largeicons = true if @pokemon.gmax? && GMAX_XL_ICONS
      if @pokemon.dynamax? && !largeicons
        @pkmnsprite.zoom_x = 1.5 
        @pkmnsprite.zoom_y = 1.5
      else
        @pkmnsprite.zoom_x = 1
        @pkmnsprite.zoom_y = 1
      end
    end
  end
  def pbDynamaxColor
    if DYNAMAX_COLOR
      if @pokemon.dynamax?
        alpha_div = (1.0 - self.color.alpha.to_f / 255.0)
        r_base = 217
        g_base = 29
        b_base = 71
        if @pokemon.isSpecies?(:CALYREX)
          r_base = 56
          g_base = 160
          b_base = 193
        end 
        r = (r_base.to_f * alpha_div).floor
        g = (g_base.to_f * alpha_div).floor 
        b = (b_base.to_f * alpha_div).floor 
        a = 128 + self.color.alpha / 2
        @pkmnsprite.color = Color.new(r,g,b,a)
      else
        @pkmnsprite.color = self.color
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Used for Pokemon species.
#-------------------------------------------------------------------------------
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :gmax

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = 0
    @gmax         = 0
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    refresh
  end
  
  # Gigantamax value for icon sprites.
  def gmax=(value)
    @gmax = value
    refresh
  end
  
  # Set Gigantamax icon sprites with true/false parameters.
  def pbSetParams(species,gender,form,shiny=false,gmax=false)
    @species   = species
    @gender    = gender
    @form      = form
    @shiny     = shiny
    @gmax      = gmax
    refresh
  end
  
  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = pbCheckPokemonIconFiles([@species,(@gender==1),@shiny,@form,false,@gmax]) # G-Max Added
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width/@animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end  
   
#-------------------------------------------------------------------------------
# Checks file pathways for icon sprites.
#-------------------------------------------------------------------------------
def pbPokemonIconFile(pokemon)
  return pbCheckPokemonIconFiles([pokemon.species,pokemon.female?,         # Species, Gender
                                  pokemon.shiny?,(pokemon.form rescue 0),  # Shiny, Form
                                  pokemon.shadowPokemon?,pokemon.gmax?],   # Shadow, G-Max   
                                  pokemon.egg?)                            # Egg
end

def pbCheckPokemonIconFiles(params,egg=false)
  species = params[0]
  if egg
    bitmapFileName = sprintf("Graphics/Icons/icon%segg_%d",getConstantName(PBSpecies,species),params[3]) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/icon%03degg_%d",species,params[3])
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/icon%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Icons/iconEgg")
          end
        end
      end
    end
    return pbResolveBitmap(bitmapFileName)
  end
  factors = []
  factors.push([5,params[5],false]) if params[5] && params[5]!=false   # gmax
  factors.push([4,params[4],false]) if params[4] && params[4]!=false   # shadow
  factors.push([1,params[1],false]) if params[1] && params[1]!=false   # gender
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # shiny
  factors.push([3,params[3],0]) if params[3] && params[3]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies    = 0
  tryGender     = false
  tryShiny      = false
  tryForm       = 0
  tryShadow     = false
  tryGmax       = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies    = newVal
      when 1; tryGender     = newVal
      when 2; tryShiny      = newVal
      when 3; tryForm       = newVal
      when 4; tryShadow     = newVal
      when 5; tryGmax       = newVal
      end
    end
    for j in 0...2
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Icons/icon%s%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "",
         (tryGmax) ? "_gmax" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end