#===============================================================================
#
# ZUD_05: Move Data
#
#===============================================================================
# This script handles new move classes introduced for handling Z-Moves/Max Moves.
#
#===============================================================================
# SECTION 1 - Z-MOVE CLASS
#-------------------------------------------------------------------------------
# This section contains the Z-Move class, which handles all Z-Moves. Effects for
# status Z-Moves can be found here. Add any custom status moves to the appropriate
# arrays in def PokeBattle_ZMove.pbZStatus to add a Z-Move effect to that status
# move. When ADD_NEW_ZMOVES is set to "true", new Gen 8 status moves will be 
# given a Z-Move effect, too.
#===============================================================================
# SECTION 2 - MAX MOVE CLASS
#-------------------------------------------------------------------------------
# This section contains the Max Move class, which handles all Max Moves. You can
# use pbMaxMoveBaseDamage(oldmove,displaymove=nil) to display the base damage of
# Max Moves even outside of battle (such as in the Summary), but you must set
# "displaymove" to a Max Move to do so.
#===============================================================================

################################################################################
# SECTION 1 - Z-MOVE CLASS
#===============================================================================
# The class that handles Z-Moves.
#===============================================================================
class PokeBattle_ZMove < PokeBattle_Move
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)

  def initialize(battle,move,pbmove)
    super(battle, pbmove)
    @category   = move.category
    @oldmove    = move
    @oldname    = move.name
    @status     = @oldmove.statusMove?
    if @status
      @name     = "Z-" + move.name
      @oldmove.name = @name
    end 
    @baseDamage = pbZMoveBaseDamage(move) if @baseDamage==1
    @short_name = (@name.length > 15 && SHORTEN_MOVES) ? @name[0..12] + "..." : @name
    @flags = (@flags[/z/] ? @flags : @flags + "z") # Z-Status moves
  end
  
  #=============================================================================
  # Converts move's power into Z-Move power.
  #=============================================================================
  def pbZMoveBaseDamage(oldmove)
    if @status
      return 0
    #---------------------------------------------------------------------------
    # Becomes Z-Move with 180 BP (OHKO moves).
    #---------------------------------------------------------------------------
    elsif oldmove.function == "070"
      return 180 
    end 
    #---------------------------------------------------------------------------
    # Specific moves with specific values.
    #--------------------------------------------------------------------------- 
    case @oldmove.id
    when getID(PBMoves,:MEGADRAIN)
      return 120
    when getID(PBMoves,:WEATHERBALL)  
      return 160
    when getID(PBMoves,:HEX)
      return 160
    when getID(PBMoves,:GEARGRIND)  
      return 180
    when getID(PBMoves,:VCREATE)  
      return 220
    when getID(PBMoves,:FLYINGPRESS)
      return 170
    when getID(PBMoves,:COREENFORCER)
      return 140
    end 
    #---------------------------------------------------------------------------
    # All other moves scale based on their BP.
    #---------------------------------------------------------------------------
    check=@oldmove.baseDamage
    if check <56
      return 100
    elsif check <66
      return 120
    elsif check <76
      return 140
    elsif check <86
      return 160
    elsif check <96
      return 175
    elsif check <101
      return 180
    elsif check <111
      return 185
    elsif check <126
      return 190
    elsif check <131
      return 195
    else
      return 200
    end
  end
  
  #-----------------------------------------------------------------------------
  # Uses a Z-Move. Status moves have the Z-Move flag added to them.
  #-----------------------------------------------------------------------------
  def pbUse(battler, simplechoice=nil, specialUsage=false)
    battler.pbBeginTurn(self)
    zchoice = @battle.choices[battler.index]
    if simplechoice
      zchoice = simplechoice
    end
    @specialUseZMove = specialUsage
    if @status
      # Targeted status Z-Moves here.
      zchoice[2] = @oldmove
      oldflags = zchoice[2].flags
      zchoice[2].flags = oldflags + "z"
      battler.pbUseMove(zchoice, specialUsage)
      zchoice[2].flags = oldflags
      @oldmove.name = @oldname
    else
      zchoice[2] = self
      battler.pbUseMove(zchoice, specialUsage)
      battler.pbReducePPOther(@oldmove)
    end
    battler.lastMoveUsedIsZMove = true
  end 
  
  #-----------------------------------------------------------------------------
  # Gets a Z-Move based on the inputted move and Z-Crystal.
  #-----------------------------------------------------------------------------
  def PokeBattle_ZMove.pbFromOldMoveAndCrystal(battle,battler,move,crystal)
    return move if move.is_a?(PokeBattle_ZMove)
    newpoke   = battler.effects[PBEffects::TransformPokemon]
    pokemon   = battler.effects[PBEffects::Transform] ? newpoke : battler.pokemon
    zmovedata = pbGetZMoveDataIfCompatible(pokemon,crystal,move)
    pbmove    = nil
    if !zmovedata || move.statusMove?
      pbmove    = PBMove.new(move.id)
      pbmove.pp = 1 
      return PokeBattle_ZMove.new(battle,move,pbmove)
    end 
    z_move_id    = zmovedata[PBZMove::ZMOVE]
    pbmove       = PBMove.new(z_move_id)
    moveFunction = pbGetMoveData(pbmove.id,MOVE_FUNCTION_CODE) || "Z000"
    className    = sprintf("PokeBattle_Move_%s",moveFunction)
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle,move,pbmove)
    end
    return PokeBattle_ZMove.new(battle,move,pbmove)
  end
  
  #-----------------------------------------------------------------------------
  # Type-changing Abilities aren't triggered by Z-Moves.
  #-----------------------------------------------------------------------------
  def pbBaseType(user)
    return @type if !@status
    return super(user)
  end
  
  #-----------------------------------------------------------------------------
  # Protection moves don't fully negate Z-Moves.
  #-----------------------------------------------------------------------------
  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Protect] || 
       opponent.effects[PBEffects::Obstruct] ||
       opponent.effects[PBEffects::KingsShield] ||
       opponent.effects[PBEffects::SpikyShield] ||
       opponent.effects[PBEffects::BanefulBunker] ||
       opponent.effects[PBEffects::MatBlock]
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",opponent.pbThis))
      return damagemult/4
    else      
      return damagemult
    end    
  end    
  
  #=============================================================================
  # Effects for Z-Status moves.
  # Effects for Gen 8 status moves are added when ADD_NEW_ZMOVES is "true".
  #=============================================================================
  def PokeBattle_ZMove.pbZStatus(battle, move,attacker)
    boost = ""
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Attack.
    #---------------------------------------------------------------------------
    atk1   = [:BULKUP,:HONECLAWS,:HOWL,:LASERFOCUS,:LEER,:MEDITATE,:ODORSLEUTH,
              :POWERTRICK,:ROTOTILLER,:SCREECH,:SHARPEN,:TAILWHIP,:TAUNT,:TOPSYTURVY,
              :WILLOWISP,:WORKUP]
    atk2   = [:MIRRORMOVE]
    atk3   = [:SPLASH]
    if ADD_NEW_ZMOVES
      atk1 += [:COACHING]
    end
    atkID1 = []; atkID2 = []; atkID3 = []
    for i in atk1; atkID1.push(getID(PBMoves,i)); end
    for i in atk2; atkID2.push(getID(PBMoves,i)); end
    for i in atk3; atkID3.push(getID(PBMoves,i)); end
    # Z-Curse raises Attack if user is a non-Ghost.
    if move==getID(PBMoves,:CURSE) && !attacker.pbHasType?(:GHOST)
      atkID1.push(move)
    end
    atkStage = 1 if atkID1.include?(move)
    atkStage = 2 if atkID2.include?(move)
    atkStage = 3 if atkID3.include?(move)
    if atkStage
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::ATTACK,atkStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if atkStage==2
        boost = " drastically" if atkStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Attack{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Defense.
    #---------------------------------------------------------------------------
    def1   = [:AQUARING,:BABYDOLLEYES,:BANEFULBUNKER,:BLOCK,:CHARM,:DEFENDORDER,
              :FAIRYLOCK,:FEATHERDANCE,:FLOWERSHIELD,:GRASSYTERRAIN,:GROWL,:HARDEN,
              :MATBLOCK,:NOBLEROAR,:PAINSPLIT,:PLAYNICE,:POISONGAS,:POISONPOWDER,
              :QUICKGUARD,:REFLECT,:ROAR,:SPIDERWEB,:SPIKES,:SPIKYSHIELD,:STEALTHROCK,
              :STRENGTHSAP,:TEARFULLOOK,:TICKLE,:TORMENT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,
              :WIDEGUARD,:WITHDRAW]
    def2   = []
    def3   = []
    if ADD_NEW_ZMOVES
      def1 += [:OCTOLOCK]
    end
    defID1 = []; defID2 = []; defID3 = []
    for i in def1; defID1.push(getID(PBMoves,i)); end
    for i in def2; defID2.push(getID(PBMoves,i)); end
    for i in def3; defID3.push(getID(PBMoves,i)); end
    defStage = 1 if defID1.include?(move)
    defStage = 2 if defID2.include?(move)
    defStage = 3 if defID3.include?(move)
    if defStage
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::DEFENSE,defStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if defStage==2
        boost = " drastically" if defStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Defense{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Sp.Atk.
    #---------------------------------------------------------------------------
    spatk1 = [:CONFUSERAY,:ELECTRIFY,:EMBARGO,:FAKETEARS,:GEARUP,:GRAVITY,:GROWTH,
              :INSTRUCT,:IONDELUGE,:METALSOUND,:MINDREADER,:MIRACLEEYE,:NIGHTMARE,
              :PSYCHICTERRAIN,:REFLECTTYPE,:SIMPLEBEAM,:SOAK,:SWEETKISS,:TEETERDANCE,
              :TELEKINESIS]
    spatk2 = [:HEALBLOCK,:PSYCHOSHIFT]
    spatk3 = []
    if ADD_NEW_ZMOVES
      spatk1 += [:MAGICPOWDER]
    end
    spatkID1 = []; spatkID2 = []; spatkID3 = []
    for i in spatk1; spatkID1.push(getID(PBMoves,i)); end
    for i in spatk2; spatkID2.push(getID(PBMoves,i)); end
    for i in spatk3; spatkID3.push(getID(PBMoves,i)); end
    spatkStage = 1 if spatkID1.include?(move)
    spatkStage = 2 if spatkID2.include?(move)
    spatkStage = 3 if spatkID3.include?(move)
    if spatkStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::SPATK,spatkStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if spatkStage==2
        boost = " drastically" if spatkStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Sp. Atk{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Sp.Def.
    #---------------------------------------------------------------------------
    spdef1 = [:CHARGE,:CONFIDE,:COSMICPOWER,:CRAFTYSHIELD,:EERIEIMPULSE,:ENTRAINMENT,
              :FLATTER,:GLARE,:INGRAIN,:LIGHTSCREEN,:MAGICROOM,:MAGNETICFLUX,:MEANLOOK,
              :MISTYTERRAIN,:MUDSPORT,:SPOTLIGHT,:STUNSPORE,:THUNDERWAVE,:WATERSPORT,
              :WHIRLWIND,:WISH,:WONDERROOM]
    spdef2 = [:AROMATICMIST,:CAPTIVATE,:IMPRISON,:MAGICCOAT,:POWDER]
    spdef3 = []
    if ADD_NEW_ZMOVES
      spdef1 += [:CORROSIVEGAS,:DECORATE]
    end
    spdefID1 = []; spdefID2 = []; spdefID3 = []
    for i in spdef1; spdefID1.push(getID(PBMoves,i)); end
    for i in spdef2; spdefID2.push(getID(PBMoves,i)); end
    for i in spdef3; spdefID3.push(getID(PBMoves,i)); end
    spdefStage = 1 if spdefID1.include?(move)
    spdefStage = 2 if spdefID2.include?(move)
    spdefStage = 3 if spdefID3.include?(move)
    if spdefStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::SPDEF,spdefStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if spdefStage==2
        boost = " drastically" if spdefStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Sp. Def{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Speed.
    #---------------------------------------------------------------------------
    speed1 = [:AFTERYOU,:AURORAVEIL,:ELECTRICTERRAIN,:ENCORE,:GASTROACID,:GRASSWHISTLE,
              :GUARDSPLIT,:GUARDSWAP,:HAIL,:HYPNOSIS,:LOCKON,:LOVELYKISS,:POWERSPLIT,
              :POWERSWAP,:QUASH,:RAINDANCE,:ROLEPLAY,:SAFEGUARD,:SANDSTORM,:SCARYFACE,
              :SING,:SKILLSWAP,:SLEEPPOWDER,:SPEEDSWAP,:STICKYWEB,:STRINGSHOT,:SUNNYDAY,
              :SUPERSONIC,:TOXICTHREAD,:WORRYSEED,:YAWN]
    speed2 = [:ALLYSWITCH,:BESTOW,:MEFIRST,:RECYCLE,:SNATCH,:SWITCHEROO,:TRICK]
    speed3 = []
    if ADD_NEW_ZMOVES
      speed1 += [:COURTCHANGE,:TARSHOT]
    end
    speedID1 = []; speedID2 = []; speedID3 = []
    for i in speed1; speedID1.push(getID(PBMoves,i)); end
    for i in speed2; speedID2.push(getID(PBMoves,i)); end
    for i in speed3; speedID3.push(getID(PBMoves,i)); end
    speedStage = 1 if speedID1.include?(move)
    speedStage = 2 if speedID2.include?(move)
    speedStage = 3 if speedID3.include?(move)  
    if speedStage
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::SPEED,speedStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if speedStage==2
        boost = " drastically" if speedStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Speed{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Accuracy.
    #---------------------------------------------------------------------------
    acc1   = [:COPYCAT,:DEFENSECURL,:DEFOG,:FOCUSENERGY,:MIMIC,:SWEETSCENT,:TRICKROOM]
    acc2   = []
    acc3   = []
    accID1 = []; accID2 = []; accID3 = []
    for i in acc1; accID1.push(getID(PBMoves,i)); end
    for i in acc2; accID2.push(getID(PBMoves,i)); end
    for i in acc3; accID3.push(getID(PBMoves,i)); end
    accStage = 1 if accID1.include?(move)
    accStage = 2 if accID2.include?(move)
    accStage = 3 if accID3.include?(move)
    if accStage
      if attacker.pbCanRaiseStatStage?(PBStats::ACCURACY,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::ACCURACY,accStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if accStage==2
        boost = " drastically" if accStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Accuracy{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise Evasion.
    #---------------------------------------------------------------------------
    eva1   = [:CAMOFLAUGE,:DETECT,:FLASH,:KINESIS,:LUCKYCHANT,:MAGNETRISE,:SANDATTACK,
              :SMOKESCREEN]
    eva2   = []
    eva3   = []
    evaID1 = []; evaID2 = []; evaID3 = []
    for i in eva1; evaID1.push(getID(PBMoves,i)); end
    for i in eva2; evaID2.push(getID(PBMoves,i)); end
    for i in eva3; evaID3.push(getID(PBMoves,i)); end
    evaStage = 1 if evaID1.include?(move)
    evaStage = 2 if evaID2.include?(move)
    evaStage = 3 if evaID3.include?(move)
    if evaStage
      if attacker.pbCanRaiseStatStage?(PBStats::EVASION,attacker)
        attacker.pbRaiseStatStageBasic(PBStats::EVASION,speedStage)
        battle.pbCommonAnimation("StatUp",attacker)
        boost = " sharply"     if evaStage==2
        boost = " drastically" if evaStage==3
        battle.pbDisplayBrief(_INTL("{1} boosted its Evasion{2} using its Z-Power!",attacker.pbThis,boost))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that raise all stats.
    #---------------------------------------------------------------------------
    stat1  = [:CELEBRATE,:CONVERSION,:FORESTSCURSE,:GEOMANCY,:HAPPYHOUR,:HOLDHANDS,
              :PURIFY,:SKETCH,:TRICKORTREAT]
    stat2  = []
    stat3  = []
    if ADD_NEW_ZMOVES
      stat1 += [:TEATIME]
    end
    statID1 = []; statID2 = []; statID3 = []
    for i in stat1; statID1.push(getID(PBMoves,i)); end
    for i in stat2; statID2.push(getID(PBMoves,i)); end
    for i in stat3; statID3.push(getID(PBMoves,i)); end
    statStage = 1 if statID1.include?(move)
    statStage = 2 if statID2.include?(move)
    statStage = 3 if statID3.include?(move)
    if statStage
      showAnim = true
      for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
        if attacker.pbCanRaiseStatStage?(stat,attacker)
          attacker.pbRaiseStatStageBasic(stat,statStage)
          if showAnim
            battle.pbCommonAnimation("StatUp",attacker)
            boost = " sharply"     if statStage==2
            boost = " drastically" if statStage==3
            battle.pbDisplayBrief(_INTL("{1} boosted its stats{2} using its Z-Power!",attacker.pbThis,boost))
          end
          showAnim = false
        end
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that returns lowered stats to normal.
    #---------------------------------------------------------------------------
    reset  = [:ACIDARMOR,:AGILITY,:AMNESIA,:ATTRACT,:AUTOTOMIZE,:BARRIER,:BATONPASS,
              :CALMMIND,:COIL,:COTTONGUARD,:COTTONSPORE,:DARKVOID,:DISABLE,:DOUBLETEAM,
              :DRAGONDANCE,:ENDURE,:FLORALHEALING,:FOLLOWME,:HEALORDER,:HEALPULSE,
              :HELPINGHAND,:IRONDEFENSE,:KINGSSHIELD,:LEECHSEED,:MILKDRINK,:MINIMIZE,
              :MOONLIGHT,:MORNINGSUN,:NASTYPLOT,:PERISHSONG,:PROTECT,:QUIVERDANCE,
              :RAGEPOWDER,:RECOVER,:REST,:ROCKPOLISH,:ROOST,:SHELLSMASH,:SHIFTGEAR,
              :SHOREUP,:SLACKOFF,:SOFTBOILED,:SPORE,:SUBSTITUTE,:SWAGGER,:SWALLOW,
              :SWORDSDANCE,:SYNTHESIS,:TAILGLOW]
    if ADD_NEW_ZMOVES
      reset += [:LIFEDEW,:OBSTRUCT,:JUNGLEHEALING]
    end
    resetID = []
    for i in reset; resetID.push(getID(PBMoves,i)); end
    if resetID.include?(move)
      showMsg = true
      for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                   PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        if attacker.stages[stat]<0
          attacker.stages[stat]=0
          if showMsg
            battle.pbDisplayBrief(_INTL("{1} returned its decreased stats to normal using its Z-Power!",attacker.pbThis))
            showMsg = false
          end
        end
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that heal HP.
    #---------------------------------------------------------------------------
    heal1  = [:AROMATHERAPY,:BELLYDRUM,:CONVERSION2,:HAZE,:HEALBELL,:MIST,:PSYCHUP,
              :REFRESH,:SPITE,:STOCKPILE,:TELEPORT,:TRANSFORM]
    heal2  = [:MEMENTO,:PARTINGSHOT]
    healID1 = []; healID2 = []
    if ADD_NEW_ZMOVES
      heal1 += [:CLANGOROUSSOUL,:NORETREAT,:STUFFCHEEKS]
    end
    for i in heal1; healID1.push(getID(PBMoves,i)); end
    for i in heal2; healID2.push(getID(PBMoves,i)); end
    # Z-Curse fully restores HP if user is a Ghost-type.
    if move==getID(PBMoves,:CURSE) && attacker.pbHasType?(:GHOST)
      healID1.push(move)
    end
    if healID1.include?(move) && attacker.hp<attacker.totalhp
      attacker.pbRecoverHP(attacker.totalhp,false)
      battle.pbDisplayBrief(_INTL("{1} restored its HP using its Z-Power!",attacker.pbThis))
    end
    if healID2.include?(move)
      attacker.effects[PBEffects::ZHeal] = true
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that boosts critical hit rate.
    #---------------------------------------------------------------------------
    crit = [:ACUPRESSURE,:FORESIGHT,:HEARTSWAP,:SLEEPTALK,:TAILWIND]
    critID = []
    for i in crit; critID.push(getID(PBMoves,i)); end
    if critID.include?(move)
      if attacker.effects[PBEffects::FocusEnergy]<=0
        attacker.effects[PBEffects::FocusEnergy] = 2
        battle.pbDisplayBrief(_INTL("{1} boosted its critical hit ratio using its Z-Power!",attacker.pbThis))
      end
    end
    #---------------------------------------------------------------------------
    # Z-Status moves that cause misdirection.
    #---------------------------------------------------------------------------
    center = [:DESTINYBOND,:GRUDGE]
    centerID = []
    for i in center; centerID.push(getID(PBMoves,i)); end
    if centerID.include?(move)
      battle.eachSameSideBattler do |b|
        b.effects[PBEffects::FollowMe]   = false
        b.effects[PBEffects::RagePowder] = false  
      end
      attacker.effects[PBEffects::FollowMe] = true
      battle.pbDisplayBrief(_INTL("{1} became the center of attention using its Z-Power!",attacker.pbThis))
    end
  end
end

#===============================================================================
# Gets Z-Move or Z-Crystal of a given type.
#===============================================================================
class PokeBattle_Battler
  def pbZMoveFromType(type)
    zmovecomps = pbLoadZMoveCompatibility
    zmovecomps["order"].each { |comp|
      next if !comp[PBZMove::REQ_TYPE]
      next if comp[PBZMove::REQ_TYPE] != type
      return comp[PBZMove::ZMOVE]
    }
    return nil 
  end
  
  def pbZCrystalFromType(type)
    zmovecomps = pbLoadZMoveCompatibility
    zmovecomps["order"].each { |comp|
      next if !comp[PBZMove::REQ_TYPE]
      next if comp[PBZMove::REQ_TYPE] != type
      return comp[PBZMove::ZCRYSTAL]
    }
    return nil 
  end
end


################################################################################
# SECTION 2 - MAX MOVE CLASS
#===============================================================================
# The class that handles Max Moves.
#===============================================================================
class PokeBattle_MaxMove < PokeBattle_Move
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)
  
  def initialize(battle,move,pbmove)
    super(battle,pbmove)
    @category   = move.category
    @oldmove    = move
    @oldname    = move.name
    @baseDamage = pbMaxMoveBaseDamage(@oldmove) if @baseDamage==1
    @short_name = (@name.length>15 && SHORTEN_MOVES) ? @name[0..12] + "..." : @name
  end
  
  def pbUse(battler,simplechoice=nil,specialUsage=false)
    battler.pbBeginTurn(self)  
    dchoice = @battle.choices[battler.index]
    if simplechoice
      dchoice = simplechoice
    end    
    dchoice[2] = self
    battler.pbUseMove(dchoice)
    battler.pbReducePPOther(@oldmove)
  end 
  
  #-----------------------------------------------------------------------------
  # Gets a Max Move based on the inputted move.
  #-----------------------------------------------------------------------------
  def PokeBattle_MaxMove.pbFromOldMove(battle,battler,move)
    return move if move.is_a?(PokeBattle_MaxMove)
    pbmove       = nil
    newpoke      = battler.effects[PBEffects::TransformPokemon]
    pokemon      = battler.effects[PBEffects::Transform] ? newpoke : battler.pokemon
    comp1        = pbGetMaxMove(move.type)
    comp2        = pbGetGMaxMoveFromSpecies(pokemon,move.type)
    maxmove_id   = getID(PBMoves,comp1)
    maxmove_id   = getID(PBMoves,comp2) if comp2 && battler.gmaxFactor?
    maxmove_id   = getID(PBMoves,:MAXGUARD) if move.statusMove?
    pbmove       = PBMove.new(maxmove_id)
    moveFunction = pbGetMoveData(pbmove.id,MOVE_FUNCTION_CODE) || "D000"
    className    = sprintf("PokeBattle_Move_%s",moveFunction)
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle,pbmove) if moveFunction=="D001"
      return Object.const_get(className).new(battle,move,pbmove)
    end
    return PokeBattle_MaxMove.new(battle,move,pbmove)
  end
  
  #-----------------------------------------------------------------------------
  # Protection moves don't fully negate Max Moves.
  # G-Max One Blow and G-Max Rapid Flow ignore protection moves completely.
  #-----------------------------------------------------------------------------
  def pbModifyDamage(damagemult,attacker,opponent)
    # Max Moves that ignore Protect don't have their damage reduced.
    if isConst?(@id,PBMoves,:GMAXONEBLOW) || 
       isConst?(@id,PBMoves,:GMAXRAPIDFLOW)
      return damagemult 
    end
    # Protect fails to fully protect against Max Moves.
    if opponent.effects[PBEffects::Protect] || 
       opponent.effects[PBEffects::Obstruct] ||
       opponent.effects[PBEffects::KingsShield] ||
       opponent.effects[PBEffects::SpikyShield] ||
       opponent.effects[PBEffects::BanefulBunker] ||
       opponent.pbOwnSide.effects[PBEffects::MatBlock]
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",opponent.pbThis))
      return damagemult/4
    else      
      return damagemult
    end
  end
end

#===============================================================================
# Gets the base power of a move when converted into a Max Move.
#===============================================================================
def pbMaxMoveBaseDamage(oldmove,displaymove=nil)
  realmove  = true if oldmove.is_a?(PokeBattle_Move)
  moveid    = realmove ? oldmove.id         : pbGetMoveData(oldmove,MOVE_ID)
  movetype  = realmove ? oldmove.type       : pbGetMoveData(oldmove,MOVE_TYPE)
  movepower = realmove ? oldmove.baseDamage : pbGetMoveData(oldmove,MOVE_BASE_DAMAGE)
  function  = realmove ? oldmove.function   : pbGetMoveData(oldmove,MOVE_FUNCTION_CODE)
  #-----------------------------------------------------------------------------
  # Max Moves with a set BP in moves.txt PBS file.
  # This is only used for displaying move data in the Summary.
  #-----------------------------------------------------------------------------
  if displaymove
    displaypower = pbGetMoveData(displaymove,MOVE_BASE_DAMAGE)
    return displaypower if displaypower>1
  end
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 130 BP. (OHKO Moves)
  #-----------------------------------------------------------------------------
  if function=="070"
    return 130
  end
  case moveid
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 70 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:ARMTHRUST)
    return 70
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 75 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:SEISMICTOSS) ||
       getID(PBMoves,:COUNTER)
    return 75
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 80 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:DOUBLEKICK) ||
       getID(PBMoves,:TRIPLEKICK)
    return 80
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 100 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:FURYSWIPES) ||
       getID(PBMoves,:NIGHTSHADE) ||
       getID(PBMoves,:FINALGAMBIT) ||
       getID(PBMoves,:METALBURST) ||
       getID(PBMoves,:MIRRORCOAT) ||
       getID(PBMoves,:SUPERFANG) ||
       getID(PBMoves,:BEATUP) ||
       getID(PBMoves,:FLING) ||
       getID(PBMoves,:LOWKICK) ||
       getID(PBMoves,:PRESENT) ||
       getID(PBMoves,:REVERSAL) ||
       getID(PBMoves,:SPITUP)
    return 100
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 120 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:DOUBLEHIT)
    return 120
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 130 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:BULLETSEED) ||
       getID(PBMoves,:BONERUSH) ||
       getID(PBMoves,:ICICLESPEAR) ||
       getID(PBMoves,:PINMISSILE) ||
       getID(PBMoves,:ROCKBLAST) ||
       getID(PBMoves,:TAILSLAP) ||
       getID(PBMoves,:BONEMERANG) ||
       getID(PBMoves,:DRAGONDARTS) ||
       getID(PBMoves,:GEARGRIND) ||
       getID(PBMoves,:SURGINGSTRIKES) ||
       getID(PBMoves,:ENDEAVOR) ||
       getID(PBMoves,:ELECTROBALL) ||
       getID(PBMoves,:FLAIL) ||
       getID(PBMoves,:GRASSKNOT) ||
       getID(PBMoves,:GYROBALL) ||
       getID(PBMoves,:HEATCRASH) ||
       getID(PBMoves,:HEAVYSLAM) ||
       getID(PBMoves,:POWERTRIP) ||
       getID(PBMoves,:STOREDPOWER)
    return 130
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 140 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:DOUBLEIRONBASH) ||
       getID(PBMoves,:CRUSHGRIP)
    return 140
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 150 BP.
  #-----------------------------------------------------------------------------
  when getID(PBMoves,:ERUPTION) ||
       getID(PBMoves,:WATERSPOUT)
    return 150
  end
  #-----------------------------------------------------------------------------
  # All other moves scale based on their BP.
  #-----------------------------------------------------------------------------
  if movepower <45
    basedamage = 90
    reduce     = 20
  elsif movepower <55
    basedamage = 100
    reduce     = 25
  elsif movepower <65
    basedamage = 110
    reduce     = 30
  elsif movepower <75
    basedamage = 120
    reduce     = 35
  elsif movepower <110
    basedamage = 130
    reduce     = 40
  elsif movepower <150
    basedamage = 140
    reduce     = 45
  elsif movepower >=150
    basedamage = 150
    reduce     = 50
  end
  #-------------------------------------------------------------------------
  # Fighting/Poison Max Moves have reduced BP.
  #-------------------------------------------------------------------------
  if movetype==1 || movetype==3
    basedamage -= reduce
  end
  return basedamage
end

#===============================================================================
# Gets the Max Move or G-Max Move of a given move type.
#===============================================================================
def pbGetMaxMove(movetype)
  gmaxData = pbLoadGmaxData
  return gmaxData[-1][movetype]
end 

def pbGetGMaxMoveFromSpecies(poke,movetype)
  gmaxData = pbLoadGmaxData
  fSpecies = poke.fSpecies
  fSpecies = pbGetFSpeciesFromForm(poke.species,0) if poke.isSpecies?(:ALCREMIE)
  return nil if !gmaxData[fSpecies]
  if gmaxData[fSpecies][GMaxData::MaxMoveType] == movetype
    return gmaxData[fSpecies][GMaxData::MaxMove] 
  end 
  return nil 
end