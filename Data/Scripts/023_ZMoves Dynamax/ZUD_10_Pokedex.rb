#===============================================================================
#
# ZUD_10: Pokedex
#
#===============================================================================
# This script rewrites areas of the Essentials script that handle the Pokédex 
# so as to add Gigantamax data (Gigantamax sprites, name, height, dex entry).
#
#===============================================================================
# SECTION 1 - POKEDEX
#-------------------------------------------------------------------------------
# This section rewrites the Pokédex code to add Gigantamax forms to the Form 
# Dex, and display some info (height, dex entry). 
#===============================================================================


################################################################################
# SECTION 1 - POKEDEX
#===============================================================================
# Adds the Gigantamax forms to the Pokédex.
#-------------------------------------------------------------------------------

class PokemonPokedexInfo_Scene
  #---------------------------------------------------------------------------
  # Adds a new attribute to allow for Gmax Pokémons to be displayed. 
  #---------------------------------------------------------------------------
  alias __old__pbStartScene pbStartScene
  def pbStartScene(dexlist,index,region)
    __old__pbStartScene(dexlist,index,region)
    @gmax = false 
  end 
  
  #---------------------------------------------------------------------------
  # Adds Gigantamax forms to Available forms.
  #---------------------------------------------------------------------------
  alias __old__pbGetAvailableForms pbGetAvailableForms
  def pbGetAvailableForms
    available = __old__pbGetAvailableForms
    
    for i in 0...available.length
      available[i][3] = false
    end 
    possibleforms = []
    gmaxData = pbLoadGmaxData
    formdata = pbLoadFormToSpecies
    if formdata[@species]
      for i in 0...formdata[@species].length
        fSpecies = pbGetFSpeciesFromForm(@species,i)
        next if !gmaxData[fSpecies]
        
        # this fSpecies has a gigantamax. 
        formname = pbGetMessage(MessageTypes::GMaxNames,fSpecies)
        genderRate = pbGetSpeciesData(fSpecies,i,SpeciesGenderRate)
        if i==0 || (formname && formname!="")
          multiforms = true if i>0
          case genderRate
          when PBGenderRates::AlwaysMale,
               PBGenderRates::AlwaysFemale,
               PBGenderRates::Genderless
            gendertopush = (genderRate==PBGenderRates::AlwaysFemale) ? 1 : 0
            if $Trainer.formseen[@species][gendertopush][i] || DEX_SHOWS_ALL_FORMS
              gendertopush = 2 if genderRate==PBGenderRates::Genderless
              possibleforms.push([i,gendertopush,formname])
            end
          else   # Both male and female
            for g in 0...2
              if $Trainer.formseen[@species][g][i] || DEX_SHOWS_ALL_FORMS
                possibleforms.push([i,g,formname])
                # i = form index 
                # g = genders
                # formname = form name 
                break if (formname && formname!="")
              end
            end
          end
        end 
      end 
    end 
    
    for thisform in possibleforms
      # Push to available array
      gendertopush = (thisform[1]==2) ? 0 : thisform[1]
      available.push([thisform[2],0,thisform[0], true])
    end
    return available
  end
  
  #---------------------------------------------------------------------------
  # Updates the sprites to display. Handles Gigantamax. 
  #---------------------------------------------------------------------------
  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender  = ($Trainer.formlastseen[@species][0] rescue 0)
    @form    = ($Trainer.formlastseen[@species][1] rescue 0)
    @gmax    = ($Trainer.formlastseen[@species][2] rescue false)
    @sprites["infosprite"].setSpeciesBitmap(@species,(@gender==1),@form, false, false, false, false, @gmax)
    if @sprites["formfront"]
      @sprites["formfront"].setSpeciesBitmap(@species,(@gender==1),@form, false, false, false, false, @gmax)
    end
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species,(@gender==1),@form,false,false,true, false, @gmax)
      @sprites["formback"].y = 256
      fSpecies = pbGetFSpeciesFromForm(@species,@form)
      @sprites["formback"].y += (pbLoadSpeciesMetrics[MetricBattlerPlayerY][fSpecies] || 0)*2
    end
    if @sprites["formicon"]
      @sprites["formicon"].pbSetParams(@species,@gender,@form,false,@gmax)
    end
  end
  
  #---------------------------------------------------------------------------
  # Allows Gigantamax to appear in the Form Dex. 
  #---------------------------------------------------------------------------
  def pbChooseForm
    index = 0
    for i in 0...@available.length
      if @available[i][1]==@gender && @available[i][2]==@form && @available[i][3]==@gmax
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex!=index
        $Trainer.formlastseen[@species][0] = @available[index][1]
        $Trainer.formlastseen[@species][1] = @available[index][2]
        $Trainer.formlastseen[@species][2] = @available[index][3]
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index>0)
        @sprites["downarrow"].visible = (index<@available.length-1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index+@available.length-1)%@available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index+1)%@available.length
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end
  
  #---------------------------------------------------------------------------
  # Draws the page, including Gigantamax. 
  #---------------------------------------------------------------------------
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form && i[3]==@gmax
        formname = i[0]; break
      end
    end
    textpos = [
       [PBSpecies.getName(@species),Graphics.width/2,Graphics.height-88,2,base,shadow],
       [formname,Graphics.width/2,Graphics.height-56,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end
  
  #---------------------------------------------------------------------------
  # Updates the first page, displaying Pokédex description + height.
  #---------------------------------------------------------------------------
  def drawPageInfo
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    imagepos = []
    if @brief
      imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"),0,0])
    end
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][4]>0
      indexNumber = @dexlist[@index][4]
      indexNumber -= 1 if @dexlist[@index][5]
      indexText = sprintf("%03d",indexNumber)
    end
    textpos = [
       [_INTL("{1}{2} {3}",indexText," ",PBSpecies.getName(@species)),
          246,42,0,Color.new(248,248,248),Color.new(0,0,0)],
       [_INTL("Height"),314,158,0,base,shadow],
       [_INTL("Weight"),314,190,0,base,shadow]
    ]
    if $Trainer.owned[@species]
      speciesData = pbGetSpeciesData(@species,@form)
      fSpecies = pbGetFSpeciesFromForm(@species,@form)
      # Write the kind
      kind = pbGetMessage(MessageTypes::Kinds,fSpecies)
      kind = pbGetMessage(MessageTypes::Kinds,@species) if !kind || kind==""
      textpos.push([_INTL("{1} Pokémon",kind),246,74,0,base,shadow])
      # Write the height and weight
      height = speciesData[SpeciesHeight] || 1
      weight = speciesData[SpeciesWeight] || 1
      if @gmax
        gmaxheight = pbGetGmaxData(fSpecies,GMaxData::Height)
        height = gmaxheight rescue pbGetGmaxData(@species,GMaxData::Height) rescue height
      end 
      if pbGetCountry==0xF4   # If the user is in the United States
        inches = (height/0.254).round
        pounds = (weight/0.45359).round
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),460,158,1,base,shadow])
        if @gmax
          textpos.push([_ISPRINTF("????.? lbs."),494,190,1,base,shadow])
        else
          textpos.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),494,190,1,base,shadow])
        end
      else
        textpos.push([_ISPRINTF("{1:.1f} m",height/10.0),470,158,1,base,shadow])
        if @gmax
          textpos.push([_ISPRINTF("????.? kg"),482,190,1,base,shadow])
        else
          textpos.push([_ISPRINTF("{1:.1f} kg",weight/10.0),482,190,1,base,shadow])
        end 
      end
      # Draw the Pokédex entry text
      message_dex_index = (@gmax ? MessageTypes::GMaxPokedex : MessageTypes::Entries)
      entry = pbGetMessage(message_dex_index,fSpecies)
      entry = pbGetMessage(message_dex_index,@species) if !entry || entry==""
      drawTextEx(overlay,40,240,Graphics.width-(40*2),4,entry,base,shadow)
      # Draw the footprint
      footprintfile = pbPokemonFootprintFile(@species,@form)
      if footprintfile
        footprint = BitmapCache.load_bitmap(footprintfile)
        overlay.blt(226,138,footprint,footprint.rect)
        footprint.dispose
      end
      # Show the owned icon
      imagepos.push(["Graphics/Pictures/Pokedex/icon_own",212,44])
      # Draw the type icon(s)
      type1 = speciesData[SpeciesType1] || 0
      type2 = speciesData[SpeciesType2] || type1
      type1rect = Rect.new(0,type1*32,96,32)
      type2rect = Rect.new(0,type2*32,96,32)
      overlay.blt(296,120,@typebitmap.bitmap,type1rect)
      overlay.blt(396,120,@typebitmap.bitmap,type2rect) if type1!=type2
    else
      # Write the kind
      textpos.push([_INTL("????? Pokémon"),246,74,0,base,shadow])
      # Write the height and weight
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_INTL("???'??\""),460,158,1,base,shadow])
        textpos.push([_INTL("????.? lbs."),494,190,1,base,shadow])
      else
        textpos.push([_INTL("????.? m"),470,158,1,base,shadow])
        textpos.push([_INTL("????.? kg"),482,190,1,base,shadow])
      end
    end
    # Draw all text
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
  end
  
  def pbPlayCrySpeciesMax
    if @gmax 
      pbPlayDynamaxCry(@species,@form)
    else 
      pbPlayCrySpecies(@species,@form)
    end 
  end 
  
  def pbScene
    pbPlayCrySpeciesMax
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCrySpeciesMax if @page==1
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        if @page==2   # Area
#          dorefresh = true
        elsif @page==3   # Forms
          if @available.length>1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? pbPlayCrySpeciesMax : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? pbPlayCrySpeciesMax : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end

  def pbSceneBrief
    pbPlayCrySpeciesMax
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCrySpeciesMax
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
  end
end 
