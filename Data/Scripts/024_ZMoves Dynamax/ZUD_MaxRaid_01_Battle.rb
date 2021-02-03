#===============================================================================
#
# Max Raid Battle Script - by Lucidious89
#  For -Pokemon Essentials v18.dev-
#
#===============================================================================
# The following is meant as an add-on for the ZUD Plugin for v18.dev.
# This adds all of the battle mechanics necessary for compatibility with
# Max Raid Battles. Keep in mind that the ZUD Plugin is required for
# this to be installed.
#
# This script does not, however, add the ability to create Raid Dens. 
# All code related to setting up events for dens or accessing the Max Raid Database 
# is handled in the ZUD_MaxRaid_02_Events script that should be installed with this.
#
#===============================================================================
#
# ZUD_MaxRaid_01: Battle
#
#===============================================================================
# This script adds all of the actual gameplay mechanics necessary for Max Raid
# battles, and rewrites certain things to allow for compatibility.
#
#===============================================================================
# SECTION 1 - CUSTOMIZATION
#-------------------------------------------------------------------------------
# This section handles all of the user settings for Max Raid Battles. Here, you
# can manually control things such as the default raid size and raid shield HP.
#===============================================================================
# SECTION 2 - MAX RAID MECHANICS
#-------------------------------------------------------------------------------
# This section handles all of the code additions or changes required for allowing
# Max Raid Battles to function.
#===============================================================================
# SECTION 3 - MAX RAID VISUALS
#-------------------------------------------------------------------------------
# This section handles all of the new visuals required for Max Raid Battles,
# such as changes to a Raid Pokemon's databox and raid shields.
#===============================================================================
# SECTION 4 - MOVE UPDATES
#-------------------------------------------------------------------------------
# This section rewrites code for certain moves to allow for compatibility with
# Max Raid Battles.
#===============================================================================

################################################################################
# SECTION 1 - CUSTOMIZATION
#===============================================================================
# Settings related to Max Raid Battles.
#===============================================================================
# Max Raid Settings
#-------------------------------------------------------------------------------
MAXRAID_SIZE   = 3     # The base number of Pokemon you may have out in a Max Raid.
MAXRAID_KOS    = 4     # The base number of KO's a Max Raid Pokemon needs beat you.
MAXRAID_TIMER  = 10    # The base number of turns you have in a Max Raid battle.
MAXRAID_SHIELD = 2     # The base number of hit points Max Raid shields have.
#-------------------------------------------------------------------------------
# Switch Numbers
#-------------------------------------------------------------------------------
MAXRAID_SWITCH = 38    # The switch number used to toggle Max Raid battles.
HARDMODE_RAID  = 39    # The switch number used to toggle Hard Mode raids.
#-------------------------------------------------------------------------------
# Variable Numbers
#-------------------------------------------------------------------------------
# Note: MAXRAID_PKMN must not have any variable numbers after it used for 
# anything, that's why it's purposely set to a high number.
#-------------------------------------------------------------------------------
REWARD_BONUSES = 15    # The variable number used to store Raid Reward Bonuses.
MAXRAID_PKMN   = 500   # The base variable number used to store a Raid Pokemon.


################################################################################
# SECTION 2 - MAX RAID MECHANICS
#===============================================================================
# Initializes effects for Max Raid battles.
#===============================================================================
module PBEffects
  RaidShield    = 210  # The current HP for a Max Raid Pokemon's shields.
  ShieldCounter = 211  # The counter for triggering Raid Shields and other effects.
  KnockOutCount = 212  # The counter for KO's a Raid Pokemon needs to end the raid.
end

class PokeBattle_Battler
  alias __MaxRaid__pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    __MaxRaid__pbInitEffects(batonpass)
    @effects[PBEffects::MaxRaidBoss]   = false
    @effects[PBEffects::RaidShield]    = -1
    @effects[PBEffects::ShieldCounter] = -1
    @effects[PBEffects::KnockOutCount] = -1
    if $game_switches[MAXRAID_SWITCH] && (@battle.wildBattle? && opposes?)
      timerbonus = 0                      if @battle.pbSideSize(0)>=3
      timerbonus = ((level+5)/20).ceil+1  if @battle.pbSideSize(0)==2
      timerbonus = ((level+5)/10).floor+1 if @battle.pbSideSize(0)==1
      @effects[PBEffects::Dynamax]       = 1+MAXRAID_TIMER
      @effects[PBEffects::Dynamax]      += timerbonus if level>20
      @effects[PBEffects::Dynamax]       = 6 if @effects[PBEffects::Dynamax]<6
      @effects[PBEffects::Dynamax]       = 26 if @effects[PBEffects::Dynamax]>26
      @effects[PBEffects::ShieldCounter] = 1
      @effects[PBEffects::ShieldCounter] = 2 if level>35
      @effects[PBEffects::KnockOutCount] = MAXRAID_KOS
      @effects[PBEffects::KnockOutCount] = MAXRAID_KOS-1 if level>55
      @effects[PBEffects::KnockOutCount] = 1 if MAXRAID_KOS<1
      @effects[PBEffects::KnockOutCount] = 6 if MAXRAID_KOS>6
      @effects[PBEffects::RaidShield]    = 0
      @effects[PBEffects::BaseMoves]     = [@moves[0],@moves[1],@moves[2],@moves[3]]
      @effects[PBEffects::MaxRaidBoss]   = true
    end
  end

#===============================================================================
# Handles success checks for moves used in Max Raid Battles.
#===============================================================================
  def pbSuccessCheckMaxRaid(move,user,target)
    if $game_switches[MAXRAID_SWITCH]
      #-------------------------------------------------------------------------
      # Max Raid Boss Pokemon are immune to specified moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::MaxRaidBoss]
        if move.function=="0F4" || # Bug Bite/Pluck
           move.function=="0F5" || # Incinerate
           move.function=="0F0" || # Knock Off
           move.function=="06C" || # Super Fang
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Specified moves fail when used by Max Raid Boss Pokemon.
      #-------------------------------------------------------------------------
      if user.effects[PBEffects::MaxRaidBoss]
        if move.function=="0E1" || # Final Gambit
           move.function=="0E2" || # Memento
           move.function=="0E7" || # Destiny Bond
           move.function=="0EB" || # Roar/Whirlwind
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Max Raid Shields block status moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::RaidShield]>0 && move.statusMove?
        @battle.pbDisplay(_INTL("But it failed!"))
        ret = false
      end
      return ret
    end
  end
  
  #-----------------------------------------------------------------------------
  # Ends multi-hit moves early if Raid Pokemon is defeated mid-attack.
  #-----------------------------------------------------------------------------
  def pbBreakRaidMultiHits(targets,hits)
    breakmove = false
    if $game_switches[MAXRAID_SWITCH]
      targets.each do |t|
        breakmove = true if t.hp<=1 && hits>0
      end
    end
    return true if breakmove
  end
  
  #-----------------------------------------------------------------------------
  # Max Raid Pokemon can use Belch without consuming a berry.
  #-----------------------------------------------------------------------------
  def belched?
    return true if @effects[PBEffects::MaxRaidBoss]
    return @battle.belch[@index&1][@pokemonIndex]
  end

  #-----------------------------------------------------------------------------
  # Deals damage to a Raid Pokemon's shields through Max Guard (only in 1v1 raids).
  #-----------------------------------------------------------------------------
  def pbRaidShieldBreak(move,target)
    if @battle.pbSideSize(0)==1 && move.maxMove? && move.damagingMove? &&
       target.effects[PBEffects::MaxRaidBoss] && target.effects[PBEffects::RaidShield]>0
      @battle.pbDisplay(_INTL("{1}'s mysterious barrier took the hit!",target.pbThis))
      target.effects[PBEffects::RaidShield]-=1
      @battle.scene.pbRefresh
    end
  end
  
#===============================================================================
# Handles effects triggered upon using a move in Max Raid Battles.
#===============================================================================
  def pbProcessRaidEffectsOnHit(move,user,targets,hitNum) # Added to def pbProcessMoveHit
    targets.each do |b|
      if $game_switches[MAXRAID_SWITCH] && 
         b.effects[PBEffects::MaxRaidBoss] && 
         b.effects[PBEffects::KnockOutCount]>0
        shieldbreak = 1
        shieldbreak = 2 if move.powerMove? && move.damagingMove?
        if hitNum>0
          shieldbreak = 0
        end
        #-----------------------------------------------------------------------
        # Initiates Max Raid capture sequence if brought down to 0 HP.
        #-----------------------------------------------------------------------
        if b.hp<=0
          b.effects[PBEffects::RaidShield] = 0
          @battle.scene.pbRefresh
          b.pbFaint if b.fainted?
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon loses shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]>0
          next if !move.damagingMove?
          next if b.damageState.calcDamage==0
          next if shieldbreak==0
          if $DEBUG && Input.press?(Input::CTRL) # Instantly breaks shield.
            shieldbreak = b.effects[PBEffects::RaidShield]
          end
          b.effects[PBEffects::RaidShield] -= shieldbreak
          @battle.scene.pbRefresh
          if b.effects[PBEffects::RaidShield]<=0
            b.effects[PBEffects::RaidShield] = 0
            @battle.pbDisplay(_INTL("The mysterious barrier disappeared!"))
            oldhp = b.hp
            b.hp -= b.totalhp/8
            b.hp  =1 if b.hp<=1
            @battle.scene.pbHPChanged(b,oldhp)
            if b.hp>1
              b.pbLowerStatStage(PBStats::DEFENSE,2,false) 
              b.pbLowerStatStage(PBStats::SPDEF,2,false)
            end
          end
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon gains shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]<=0
          shieldLvl  = MAXRAID_SHIELD
          shieldLvl += 1 if b.level>25
          shieldLvl += 1 if b.level>35
          shieldLvl += 1 if b.level>45
          shieldLvl += 1 if b.level>55
          shieldLvl += 1 if b.level>65
          shieldLvl += 1 if b.level>=70 || $game_switches[HARDMODE_RAID]
          shieldLvl  = 1 if shieldLvl<=0
          shieldLvl  = 8 if shieldLvl>8
          shields1   = b.hp <= b.totalhp/2            # Activates at 1/2 HP
          shields2   = b.hp <= b.totalhp-b.totalhp/5  # Activates at 4/5ths HP
          if (b.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (b.effects[PBEffects::ShieldCounter]==2 && shields2)
            @battle.pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",b.pbThis))
            b.effects[PBEffects::RaidShield] = shieldLvl
            b.effects[PBEffects::ShieldCounter]-=1
            @battle.pbAnimation(getID(PBMoves,:LIGHTSCREEN),b,b)
            @battle.scene.pbRefresh
            @battle.pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",b.pbThis(true)))
          end
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Hard Mode Bonuses (Malicious Wave).
  #-----------------------------------------------------------------------------
  def pbProcessRaidEffectsOnHit2(move,user,targets) # Added to def pbProcessMoveHit
    showMsg = true
    @battle.eachOtherSideBattler(user) do |b|
      if $game_switches[HARDMODE_RAID] || user.level>=70
        if user.effects[PBEffects::MaxRaidBoss] &&
           user.effects[PBEffects::KnockOutCount]>0 &&
           user.effects[PBEffects::RaidShield]<=0 &&
           user.effects[PBEffects::TwoTurnAttack]==0 &&
           move.damagingMove?
          damage = b.totalhp/16 if user.effects[PBEffects::ShieldCounter]>=1
          damage = b.totalhp/8 if user.effects[PBEffects::ShieldCounter]<=0
          oldhp  = b.hp
          if b.hp>0 && !b.fainted?
            @battle.pbDisplay(_INTL("A malicious wave of Dynamax energy rippled from {1}'s attack!",
              user.pbThis(true))) if showMsg
            @battle.pbAnimation(getID(PBMoves,:ACIDARMOR),b,user) if showMsg
            showMsg = false
            @battle.scene.pbDamageAnimation(b)
            b.hp -= damage
            b.hp=0 if b.hp<0
            @battle.scene.pbHPChanged(b,oldhp)
            b.pbFaint if b.fainted?
          end
        end
      end
      break if @battle.decision==3
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows a Raid Pokemon to strike multiple times in a turn.
  #-----------------------------------------------------------------------------
  def pbRaidBossUseMove(choice)
    weakened = true if @effects[PBEffects::ShieldCounter]<2 && level>35
    weakened = true if @effects[PBEffects::ShieldCounter]==0
    if @effects[PBEffects::MaxRaidBoss] && weakened && 
       @battle.pbSideSize(0)>1 && !choice[2].statusMove?
      pbDisplayBaseMoves
      for i in 1...@battle.pbSideSize(0)
        break if @battle.decision==3
        choice[2] = @moves[rand(@moves.length)]
        PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
        PBDebug.logonerr{
          pbUseMove(choice,choice[2]==@battle.struggle)
        }
      end
    end
  end
  
#===============================================================================
# Handles outcomes in Max Raid battles when party Pokemon are KO'd.
#===============================================================================
  def pbRaidKOCounter(target)
    if target.effects[PBEffects::MaxRaidBoss]
      kocounter = PBEffects::KnockOutCount
      target.effects[kocounter] -= 1
      $game_variables[REWARD_BONUSES][1] = false # Perfect Bonus 
      @battle.scene.pbRefresh
      if target.effects[kocounter]>=2
        @battle.pbDisplay(_INTL("The storm raging around {1} is growing stronger!",target.pbThis(true)))
        koboost=true
      elsif target.effects[kocounter]==1
        @battle.pbDisplay(_INTL("The storm around {1} is growing too strong to withstand!",target.pbThis(true)))
        koboost=true
      elsif target.effects[kocounter]==0
        @battle.pbDisplay(_INTL("The storm around {1} grew out of control!",target.pbThis(true)))
        @battle.pbDisplay(_INTL("You were blown out of the den!"))
        pbSEPlay("Battle flee")
        @battle.decision=3
      end
      #-------------------------------------------------------------------------
      # Max Raid - Hard Mode Bonuses (KO Boost).
      #-------------------------------------------------------------------------
      if koboost && ($game_switches[HARDMODE_RAID] || target.level>=70)
        showAnim=true
        if target.pbCanRaiseStatStage?(PBStats::ATTACK,target)
          target.pbRaiseStatStage(PBStats::ATTACK,1,target,showAnim)
          showAnim=false
        end
        if target.pbCanRaiseStatStage?(PBStats::SPATK,target)
          target.pbRaiseStatStage(PBStats::SPATK,1,target,showAnim)
          showAnim=false
        end
      end
      pbWait(20)
    end
  end
  
#===============================================================================
# Initiates the capture/victory sequence vs Max Raid Pokemon.
#===============================================================================
  def pbCatchRaidPokemon(target)
    @battle.pbDisplayPaused(_INTL("{1} is weak!\nThrow a Poké Ball now!",target.pbThis))
    pbWait(20)
    scene  = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ball   = screen.pbChooseItemScreen(Proc.new{|item| pbIsPokeBall?(item) })
    if ball>0
      if pbIsPokeBall?(ball)
        $PokemonBag.pbDeleteItem(ball,1)
        target.pokemon.resetMoves
        if $game_switches[HARDMODE_RAID] || target.level>=70
          randcapture = rand(100)
          if randcapture<20 || ball==getID(PBItems,:MASTERBALL) ||
             ($DEBUG && Input.press?(Input::CTRL))
            @battle.pbThrowPokeBall(target.index,ball,255,false) # Hard Mode capture (20%)
          else
            @battle.pbThrowPokeBall(target.index,ball,0,false)   # Capture failed
            @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
            pbSEPlay("Battle flee")
            @battle.decision=1
          end
        else
          @battle.pbThrowPokeBall(target.index,ball,255,false)   # Normal Mode capture (100%)
        end
      end
    else                                                         # Choose not to capture
      @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
      pbSEPlay("Battle flee")
      @battle.decision=1
    end
  end
end

#===============================================================================
# Prevents capture of a Max Raid Pokemon until defeated.
#===============================================================================
module PokeBattle_BattleCommon
  def pbRaidCaptureFail(battler,ball)
    if !($DEBUG && Input.press?(Input::CTRL))
      if $game_switches[MAXRAID_SWITCH] && battler.hp>1 &&
         battler.effects[PBEffects::MaxRaidBoss]
        @scene.pbThrowAndDeflect(ball,1)
        pbDisplay(_INTL("The ball was repelled by a burst of Dynamax energy!"))
        return true
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Resets a Raid Pokemon upon capture.
  #-----------------------------------------------------------------------------
  def pbResetRaidPokemon(pkmn)
    if $game_switches[MAXRAID_SWITCH]
      pkmn.makeUndynamax
      pkmn.calcStats
      pkmn.pbReversion(false)
      dlvl = rand(3)
      if pkmn.level>65;    dlvl += 6
      elsif pkmn.level>55; dlvl += 5
      elsif pkmn.level>45; dlvl += 4
      elsif pkmn.level>35; dlvl += 3
      elsif pkmn.level>25; dlvl += 2
      end
      pkmn.setDynamaxLvl(dlvl)
      if pkmn.isSpecies?(:ETERNATUS)
        pkmn.removeGMaxFactor
        pkmn.setDynamaxLvl(0)
      end
      $game_switches[MAXRAID_SWITCH] = false
    end
  end
end

#===============================================================================
# Handles changes to damage taken by Max Raid Pokemon.
#===============================================================================
class PokeBattle_Move
  #-----------------------------------------------------------------------------
  # Damage thresholds for activating Max Raid shields.
  #-----------------------------------------------------------------------------
  def pbReduceMaxRaidDamage(target,damage) # Added to def pbReduceDamage
    if target.effects[PBEffects::MaxRaidBoss] && $game_switches[MAXRAID_SWITCH]
      if target.effects[PBEffects::ShieldCounter]>0
        shield = target.effects[PBEffects::ShieldCounter]
        thresh = target.totalhp/5.floor if shield==2
        thresh = target.totalhp/2.floor if shield==1
        hpstop = target.totalhp-thresh
        if target.hp==target.totalhp && damage>thresh
          damage = thresh+1
        elsif target.hp>hpstop && damage>target.hp-thresh
          damage = target.hp-thresh
        elsif target.hp<=thresh
          damage = 1
        end
      end
    end
    return damage
  end

  #-----------------------------------------------------------------------------
  # Max Raid Pokemon take greatly reduced damage while shields are up.
  #-----------------------------------------------------------------------------
  def pbCalcRaidShieldDamage(target,multipliers) # Added to def pbCalcDamageMultipliers
    if target.effects[PBEffects::RaidShield]>0
      multipliers[FINAL_DMG_MULT] /= 24
    end
  end
  
  #-----------------------------------------------------------------------------
  # Max Raid Pokemon immune to additional effects of moves when shields are up.
  #-----------------------------------------------------------------------------
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.effects[PBEffects::MaxRaidBoss] &&
                target.effects[PBEffects::RaidShield]>0
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance>0) ? effectChance : @addlEffect
    if NEWEST_BATTLE_MECHANICS || @function!="0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end
end

#===============================================================================
# Initializes the conditions of a Max Raid encounter.
#===============================================================================
class PokeBattle_Battle
  alias __MaxRaid__initialize initialize
  def initialize(scene,p1,p2,player,opponent)
    __MaxRaid__initialize(scene,p1,p2,player,opponent)
    if $game_switches[MAXRAID_SWITCH]
      @canRun            = false
      @canLose           = true
      @expGain           = false
      @moneyGain         = false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Prevents switching during a Max Raid battle.
  #-----------------------------------------------------------------------------
  alias _MaxRaid_pbCanSwitch? pbCanSwitch?
  def pbCanSwitch?(idxBattler,idxParty=-1,partyScene=nil)
    if $game_switches[MAXRAID_SWITCH] && !@battlers[idxBattler].fainted?
      partyScene.pbDisplay(_INTL("Intense waves of Dynamax Energy prevents switching!")) if partyScene
      return false
    end
    _MaxRaid_pbCanSwitch?(idxBattler,idxParty,partyScene)
  end
  
#===============================================================================
# Handles the end of round effects of certain Max Raid conditions.
#===============================================================================
  def pbEORMaxRaidEffects(priority) # Added to def pbEndOfRoundPhase
    if $game_switches[MAXRAID_SWITCH]
      priority.each do |b|
        next if !b.effects[PBEffects::MaxRaidBoss]
        next if b.effects[PBEffects::KnockOutCount]==0
        #-----------------------------------------------------------------------
        # The Raid Pokemon starts using Max Moves after its shield triggers.
        #-----------------------------------------------------------------------
        b.pbDisplayPowerMoves(2) if b.effects[PBEffects::ShieldCounter]<2 && b.level>35
        b.pbDisplayPowerMoves(2) if b.effects[PBEffects::ShieldCounter]==0
        #-----------------------------------------------------------------------
        # Raid Shield thresholds for effect damage.
        #-----------------------------------------------------------------------
        if b.effects[PBEffects::RaidShield]<=0 && b.hp>1
          shieldLvl  = MAXRAID_SHIELD
          shieldLvl += 1 if b.level>25
          shieldLvl += 1 if b.level>35
          shieldLvl += 1 if b.level>45
          shieldLvl += 1 if b.level>55
          shieldLvl += 1 if b.level>65
          shieldLvl += 1 if b.level>=70 || $game_switches[HARDMODE_RAID]
          shieldLvl  = 1 if shieldLvl<=0
          shieldLvl  = 8 if shieldLvl>8
          shields1   = b.hp <= b.totalhp/2             # Activates at 1/2 HP
          shields2   = b.hp <= b.totalhp-b.totalhp/5   # Activates at 4/5ths HP
          if (b.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (b.effects[PBEffects::ShieldCounter]==2 && shields2)
            pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",b.pbThis))
            b.effects[PBEffects::RaidShield] = shieldLvl
            b.effects[PBEffects::ShieldCounter]-=1
            @scene.pbRefresh
            pbAnimation(getID(PBMoves,:LIGHTSCREEN),b,b)
            pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",b.pbThis(true)))
          end
        end
        #-----------------------------------------------------------------------
        # Hard Mode Bonuses (Invigorating Wave).
        #-----------------------------------------------------------------------
        if $game_switches[HARDMODE_RAID] || b.level>=70      
          if b.effects[PBEffects::ShieldCounter]==0 && b.hp <= b.totalhp/2
            pbDisplay(_INTL("{1} released an invigorating wave of Dynamax energy!",b.pbThis))
            pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
            pbCommonAnimation("StatUp",b)
            pbDisplay(_INTL("{1} got powered up!",b.pbThis))
            for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
              if b.pbCanRaiseStatStage?(stat,b)
                b.pbRaiseStatStageBasic(stat,1,true)
              end
            end
            b.stages[PBStats::ACCURACY]=0 if b.stages[PBStats::ACCURACY]<0
            b.stages[PBStats::EVASION]=0 if b.stages[PBStats::EVASION]<0
            b.effects[PBEffects::ShieldCounter]-=1
          end
          #---------------------------------------------------------------------
          # Hard Mode Bonuses (HP Regeneration).
          #---------------------------------------------------------------------
          next if b.effects[PBEffects::RaidShield]<=0 || b.effects[PBEffects::HealBlock]>0
          next if b.hp == b.totalhp || b.hp==1 
          b.pbRecoverHP((b.totalhp/16).floor)
          pbDisplay(_INTL("{1} regenerated a little HP behind the mysterious barrier!",b.pbThis))
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updates the raid scene at the end of each round and checks various counters.
  #-----------------------------------------------------------------------------
  def pbRaidUpdate(boss)
    if $game_switches[MAXRAID_SWITCH]
      @scene.pbRefresh
      if boss.effects[PBEffects::MaxRaidBoss]
        $game_variables[REWARD_BONUSES][0] = boss.effects[PBEffects::Dynamax] # Timer Bonus
        boss.eachOpposing do |opp|
          $game_variables[REWARD_BONUSES][2] = false if opp.level >= boss.level+5  # Fairness Bonus
        end
        if boss.effects[PBEffects::Dynamax]<=1 && boss.effects[PBEffects::KnockOutCount]>0
          pbDisplayPaused(_INTL("The storm around {1} grew out of control!",boss.pbThis(true)))
          pbDisplay(_INTL("You were blown out of the den!"))
          pbSEPlay("Battle flee")
          @decision=3
        end
      end
    end
  end
  
#===============================================================================
# Handles the attack phase effects of certain Max Raid conditions.
#===============================================================================
  def pbAttackPhaseRaidBoss
    pbPriority.each do |b|
      next unless b.effects[PBEffects::MaxRaidBoss]
      #-------------------------------------------------------------------------
      # Neutralizing Wave
      #-------------------------------------------------------------------------
      randnull=pbRandom(10)
      neutralize=true if randnull<10
      neutralize=true if b.status>0 && randnull<6 
      neutralize=true if b.effects[PBEffects::RaidShield]>0 && randnull<3 
      if neutralize && b.hp < b.totalhp-b.totalhp/5
        pbDisplay(_INTL("{1} released a neutralizing wave of Dynamax energy!",b.pbThis))
        pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
        pbDisplay(_INTL("All stat increases and Abilities of your Pokémon were nullified!"))
        if b.status>0
          b.pbCureStatus(false)
          pbDisplay(_INTL("{1}'s status returned to normal!",b.pbThis))
        end
        b.effects[PBEffects::Attract]=-1
        b.effects[PBEffects::LeechSeed]=-1
        b.eachOpposing do |p|
          p.effects[PBEffects::GastroAcid] = true
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                    PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            p.stages[i]=0 if p.stages[i]>0
          end
        end
      end
      #-------------------------------------------------------------------------
      # Hard Mode Bonuses (Immobilizing Wave)
      #-------------------------------------------------------------------------
      if $game_switches[HARDMODE_RAID] || b.level>=70
        if b.effects[PBEffects::ShieldCounter]==-1 &&
           b.effects[PBEffects::RaidShield]<=0
          pbDisplay(_INTL("{1} released an immense wave of Dynamax energy!",b.pbThis))
          pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
          b.eachOpposing do |p|  
            if p.effects[PBEffects::Dynamax]>0
              pbDisplay(_INTL("{1} is unaffected!",p.pbThis))
            else
              pbDisplay(_INTL("The oppressive force immobilized {1}!",p.pbThis))
              p.lastRoundMoved = @turnCount
            end
          end
          b.effects[PBEffects::ShieldCounter]-=1
        end
      end
    end
  end
  
#===============================================================================
# Replaces the "Run" command with "Cheer" during Max Raid battles.
#===============================================================================
  def pbRegisterCheer(idxBattler)
    @choices[idxBattler][0] = :Cheer
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end
  
  def pbCheerMenu(idxBattler)
    return pbRegisterCheer(idxBattler)
  end
  
  def pbAttackPhaseCheer
    pbPriority.each do |b|
      next unless @choices[b.index][0]==:Cheer && !b.fainted?
      b.lastMoveFailed = false # Counts as a successful move for Stomping Tantrum
      pbCheer(b.index)
    end
  end
  
  #-----------------------------------------------------------------------------
  # The effects for the Cheer command used in battle.
  #-----------------------------------------------------------------------------
  def pbCheer(idxBattler)
    battler     = @battlers[idxBattler]
    boss        = battler.pbDirectOpposing(true)
    side        = battler.idxOwnSide
    owner       = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainerName = pbGetOwnerName(idxBattler)
    dmaxInUse   = false
    eachSameSideBattler(battler) do |b|
      dmaxInUse = true if b.dynamax?
    end
    #---------------------------------------------------------------------------
    # Builds a list of eligible Cheer effects and determines which to use.
    #---------------------------------------------------------------------------
    cheerEffects     = []
    cheerNoEffect    = 0
    cheerStatBoost   = 1
    cheerReflect     = 2
    cheerLightScreen = 3
    cheerHealParty   = 4
    cheerShieldBreak = 5
    cheerDynamax     = 6
    if $game_variables[REWARD_BONUSES][1]==false
      cheered = 0
      eachSameSideBattler(battler) do |b|
        next if @choices[b.index][0] != :Cheer
        cheered += 1
      end
      #-------------------------------------------------------------------------
      # Effects for a single Cheer.
      #-------------------------------------------------------------------------
      if cheered==1
        cheerEffects.push(cheerStatBoost)
        cheerEffects.push(cheerReflect)     if battler.pbOwnSide.effects[PBEffects::Reflect]==0
        cheerEffects.push(cheerLightScreen) if battler.pbOwnSide.effects[PBEffects::LightScreen]==0
        if boss.effects[PBEffects::KnockOutCount]<2 || boss.effects[PBEffects::Dynamax]<5
          if cheered==pbPlayerBattlerCount
            cheerEffects.push(cheerHealParty)   if b.hp < b.totalhp/2
            cheerEffects.push(cheerShieldBreak) if boss.effects[PBEffects::RaidShield]>0
            cheerEffects.push(cheerDynamax)     if !dmaxInUse && @dynamax[side][owner]!=-1
          end
        else
          cheerEffects.push(cheerNoEffect)
        end
      #-------------------------------------------------------------------------
      # Effects for a double Cheer.
      #-------------------------------------------------------------------------
      elsif cheered==2
        eachSameSideBattler(battler) do |b|
          cheerEffects.push(cheerHealParty) if b.hp < b.totalhp/2
        end
        if cheered==pbPlayerBattlerCount
          if boss.effects[PBEffects::KnockOutCount]<2 || boss.effects[PBEffects::Dynamax]<5
            cheerEffects.push(cheerShieldBreak) if boss.effects[PBEffects::RaidShield]>0
            cheerEffects.push(cheerDynamax)     if !dmaxInUse && @dynamax[side][owner]!=-1
          end
        end
        cheerEffects.push(cheerStatBoost) if cheerEffects.length==0
      #-------------------------------------------------------------------------
      # Effects for a triple Cheer or more.
      #-------------------------------------------------------------------------
      elsif cheered>=3
        if !dmaxInUse && @dynamax[side][owner]!=-1
          cheerEffects.push(cheerDynamax)
        elsif boss.effects[PBEffects::RaidShield]>0
          cheerEffects.push(cheerShieldBreak)
        end
        cheerEffects.push(cheerStatBoost) if cheerEffects.length==0
      end
      #-------------------------------------------------------------------------
    else
      cheerEffects.push(cheerNoEffect)
    end
    partyPriority = []
    pbPriority.each do |b|
      next if b.opposes?
      next if @choices[b.index][0] != :Cheer
      partyPriority.push(b)
    end
    randeffect = cheerEffects[rand(cheerEffects.length)]
    pbDisplay(_INTL("{1} cheered for {2}!",trainerName,battler.pbThis(true)))
    if randeffect!=cheerNoEffect
      msgD1 = _INTL("{1}'s Dynamax Band absorbed a little of the surrounding Dynamax Energy!",trainerName)
      msgD2 = _INTL("{1}'s Dynamax Band absorbed even more of the surrounding Dynamax Energy!",trainerName)
      msgE1 = _INTL("{1}'s cheering was powered up by all the Dynamax Energy!",trainerName)
      msgE2 = _INTL("{1}'s continuous cheering grew in power!",trainerName)
      if battler==partyPriority.first
        pbDisplay(msgD1) if randeffect==cheerDynamax
        pbDisplay(msgE1) if randeffect!=cheerDynamax
      else
        pbDisplay(msgD2) if randeffect==cheerDynamax
        pbDisplay(msgE2) if randeffect!=cheerDynamax
      end
    end
    case randeffect
    #---------------------------------------------------------------------------
    # Cheer Effect: No effect.
    #---------------------------------------------------------------------------
    when cheerNoEffect
      pbDisplay(_INTL("The cheer echoed feebly around the area..."))
    #---------------------------------------------------------------------------
    # Cheer Effect: Applies Reflect on the user's side.
    #---------------------------------------------------------------------------
    when cheerReflect
      pbAnimation(getID(PBMoves,:REFLECT),battler,battler)
      battler.pbOwnSide.effects[PBEffects::Reflect] = 5
      pbDisplay(_INTL("Reflect raised {1}'s Defense!",battler.pbTeam(true)))
    #---------------------------------------------------------------------------
    # Cheer Effect: Applies Light Screen to the user's side.
    #---------------------------------------------------------------------------
    when cheerLightScreen
      pbAnimation(getID(PBMoves,:LIGHTSCREEN),battler,battler)
      battler.pbOwnSide.effects[PBEffects::LightScreen] = 5
      pbDisplay(_INTL("Light Screen raised {1}'s Special Defense!",battler.pbTeam(true)))
    #---------------------------------------------------------------------------
    # Cheer Effect: Restores the HP and status of each ally Pokemon.
    # Only eligible when at least one party member is below 50% HP.
    #---------------------------------------------------------------------------
    when cheerHealParty
      if battler==partyPriority.last
        eachSameSideBattler(battler) do |b|
          if b.hp < b.totalhp
            b.pbRecoverHP((b.totalhp).floor)
            pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
          end
          status = b.status
          b.pbCureStatus(false)
          case status
          when PBStatuses::BURN
            pbDisplay(_INTL("{1} was healed of its burn!",b.pbThis))  
          when PBStatuses::POISON
            pbDisplay(_INTL("{1} was cured of its poison!",b.pbThis))  
          when PBStatuses::PARALYSIS
            pbDisplay(_INTL("{1} was cured of its paralysis!",b.pbThis))
          when PBStatuses::SLEEP
            pbDisplay(_INTL("{1} woke up!",b.pbThis)) 
          when PBStatuses::FROZEN
            pbDisplay(_INTL("{1} thawed out!",b.pbThis)) 
          end
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Raises a random stat for each ally Pokemon.
    # The number of stages raised is based on how many Cheers were used.
    #---------------------------------------------------------------------------
    when cheerStatBoost
      if battler==partyPriority.last
        eachSameSideBattler(battler) do |b|
          stats = [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                   PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          stat  = stats[rand(stats.length)]
          if b.pbCanRaiseStatStage?(stat,b,nil,true)
            b.pbRaiseStatStage(stat,cheered,b)
          end
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Removes the Raid Pokemon's shield.
    # Only eligible when the Raid Timer or KO Counter is low.
    #---------------------------------------------------------------------------
    when cheerShieldBreak
      if battler==partyPriority.last
        @scene.pbDamageAnimation(boss)
        boss.effects[PBEffects::RaidShield] = 0
        @scene.pbRefresh
        pbDisplay(_INTL("The mysterious barrier disappeared!"))
        oldhp = boss.hp
        boss.hp -= boss.totalhp/8
        boss.hp  =1 if boss.hp<=1
        @scene.pbHPChanged(boss,oldhp)
        if boss.hp>1
          boss.pbLowerStatStage(PBStats::DEFENSE,2,false) 
          boss.pbLowerStatStage(PBStats::SPDEF,2,false)
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Replenishes the player's ability to Dynamax.
    # Only eligible when the Raid Timer or KO Counter is low.
    #---------------------------------------------------------------------------
    when cheerDynamax
      if battler==partyPriority.last
        @dynamax[side][owner] = -1
        pbSEPlay(sprintf("Anim/Lucky Chant"))
        pbWait(10)
        pbDisplay(_INTL("{1}'s Dynamax Band was fully recharged!\nDynamax is now usable again!",trainerName))
        pbWait(10)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Gets the correct Fight Menu buttons during Max Raid battles.
#-------------------------------------------------------------------------------
class CommandMenuDisplay < BattleMenuBase
  MODES = [
     [0,2,1,3],   # 0 = Regular battle
     [0,2,1,9],   # 1 = Regular battle with "Cancel" instead of "Run"
     [0,2,1,4],   # 2 = Regular battle with "Call" instead of "Run"
     [5,7,6,3],   # 3 = Safari Zone
     [0,8,1,3],   # 4 = Bug Catching Contest
     [0,2,1,10]   # 5 = Max Raid Battle with "Cheer" instead of "Run"
  ]
end

class TargetMenuDisplay < BattleMenuBase
  MODES = [
     [0,2,1,3],   # 0 = Regular battle
     [0,2,1,9],   # 1 = Regular battle with "Cancel" instead of "Run"
     [0,2,1,4],   # 2 = Regular battle with "Call" instead of "Run"
     [5,7,6,3],   # 3 = Safari Zone
     [0,8,1,3],   # 4 = Bug Catching Contest
     [0,2,1,10]   # 5 = Max Raid Battle with "Cheer" instead of "Run"
  ]
end

class PokeBattle_Scene
  def pbCommandMenu(idxBattler,firstAction)
    shadowTrainer = (hasConst?(PBTypes,:SHADOW) && @battle.trainerBattle?)
    maxRaidBattle = $game_switches[MAXRAID_SWITCH]
    varCommand, mode = _INTL("Run"),    0 if firstAction
    varCommand, mode = _INTL("Cancel"), 1 if !firstAction
    varCommand, mode = _INTL("Call"),   2 if shadowTrainer
    varCommand, mode = _INTL("Cheer"),  5 if maxRaidBattle
    cmds = [
       _INTL("What will\n{1} do?",@battle.battlers[idxBattler].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       varCommand
    ]
    ret = pbCommandMenuEx(idxBattler,cmds,mode)
    ret = 4 if ret==3 && shadowTrainer     # Convert "Run" to "Call"
    if !($DEBUG && Input.press?(Input::CTRL))
      ret = 5 if ret==3 && maxRaidBattle   # Convert "Run" to "Cheer"
    end
    ret = -1 if ret==3 && !firstAction     # Convert "Run" to "Cancel"
    return ret
  end
end


################################################################################
# SECTION 3 - MAX RAID VISUALS
#===============================================================================
# Handles databox visuals for Max Raid Pokemon in battle.
#===============================================================================
class PokemonDataBox < SpriteWrapper
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = ((@battler.index%2)==0)
    #---------------------------------------------------------------------------
    # Sets a raid battle box for a Max Raid Pokemon.
    #---------------------------------------------------------------------------
    if $game_switches[MAXRAID_SWITCH]
      if sideSize==1
        bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                      "Graphics/Pictures/Dynamax/databox_maxraid"][@battler.index%2]
        if onPlayerSide
          @showHP  = true
          @showExp = true
        end
      else
        bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                      "Graphics/Pictures/Dynamax/databox_maxraid"][@battler.index%2]
      end
    #---------------------------------------------------------------------------                
    else
      if sideSize==1
        bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                      "Graphics/Pictures/Battle/databox_normal_foe"][@battler.index%2]
        if onPlayerSide
          @showHP  = true
          @showExp = true
        end
      else
        bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                      "Graphics/Pictures/Battle/databox_thin_foe"][@battler.index%2]
      end
    end
    @databoxBitmap  = AnimatedBitmap.new(bgFilename)
    if onPlayerSide
      @spriteX = Graphics.width - 244
      @spriteY = Graphics.height - 192
      @spriteBaseX = 34
    else
      @spriteX = -16
      @spriteY = 36
      @spriteBaseX = 16
    end
    #---------------------------------------------------------------------------
    # Compatibility with Modular Battle Scene.
    #---------------------------------------------------------------------------
    if defined?(PCV)
      case sideSize
      when 2
        @spriteX += [  0,   0,  0,  0][@battler.index]
        @spriteY += [-20, -34, 34, 20][@battler.index]
      when 3
        @spriteX += [  0,   0,  0,  0,  0,  0][@battler.index]
        @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
      when 4
        @spriteX += [  0,  0,  0,  0,  0,   0,  0,  0][@battler.index]
        @spriteY += [-88,-46,-42,  0,  4,  46, 50, 92][@battler.index]
      when 5
        @spriteX += [   0,  0,  0,  0,  0,  0,  0,  0,  0,  0][@battler.index]
        @spriteY += [-134,-46,-88,  0,-42, 46,  4, 92, 50,138][@battler.index]
      end
    #---------------------------------------------------------------------------
    else
      case sideSize
      when 2
        @spriteX += [-12,  12,  0,  0][@battler.index]
        @spriteY += [-20, -34, 34, 20][@battler.index]
      when 3
        @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
        @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
      end
    end
  end
  
  def initializeOtherGraphics(viewport)
    @numbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/icon_numbers"))
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp"))
    @expBarBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_exp"))
    #---------------------------------------------------------------------------
    # Max Raid Displays
    #---------------------------------------------------------------------------
    @raidNumbersBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num"))
    @raidNumbersBitmap1 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num1"))
    @raidNumbersBitmap2 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num2"))
    @raidNumbersBitmap3 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num3"))
    @raidBar            = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_bar"))
    @shieldHP           = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_shield"))
    #---------------------------------------------------------------------------
    @hpNumbers = BitmapSprite.new(124,16,viewport)
    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    @hpBar = SpriteWrapper.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar"] = @hpBar
    @expBar = SpriteWrapper.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    @contents = BitmapWrapper.new(@databoxBitmap.width,@databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150+((@battler.index)/2)*5
    pbSetSystemFont(self.bitmap)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
    #---------------------------------------------------------------------------
    # Max Raid Displays
    #---------------------------------------------------------------------------
    @raidNumbersBitmap.dispose
    @raidNumbersBitmap1.dispose
    @raidNumbersBitmap2.dispose
    @raidNumbersBitmap3.dispose
    @raidBar.dispose
    @shieldHP.dispose
    #---------------------------------------------------------------------------
    @contents.dispose
    super
  end
  
  #=============================================================================
  # Draws the timer and ko numbers during a Max Raid battle.
  #=============================================================================
  def pbDrawRaidNumber(counter,number,btmp,startX,startY,align=0)
    n = (number==-1) ? [10] : number.to_i.digits
    if (counter==0 && number<=MAXRAID_TIMER/8) ||
       (counter==1 && number<=1)
      charWidth  = @raidNumbersBitmap3.width/11
      charHeight = @raidNumbersBitmap3.height
      numbers    = @raidNumbersBitmap3.bitmap
    elsif (counter==0 && number<=MAXRAID_TIMER/4) ||
          (counter==1 && number<=MAXRAID_KOS/4)
      charWidth  = @raidNumbersBitmap2.width/11
      charHeight = @raidNumbersBitmap2.height
      numbers    = @raidNumbersBitmap2.bitmap
    elsif (counter==0 && number<=MAXRAID_TIMER/2) ||
          (counter==1 && number<=MAXRAID_KOS/2)
      charWidth  = @raidNumbersBitmap1.width/11
      charHeight = @raidNumbersBitmap1.height
      numbers    = @raidNumbersBitmap1.bitmap
    else
      charWidth  = @raidNumbersBitmap.width/11
      charHeight = @raidNumbersBitmap.height
      numbers    = @raidNumbersBitmap.bitmap
    end
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,numbers,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end
  
  #=============================================================================
  # Databox visuals.
  #=============================================================================
  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    textPos   = []
    imagePos  = []
    self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth-116 if nameWidth>116
    #---------------------------------------------------------------------------
    # Sets all battle visuals for a Max Raid Pokemon.
    #---------------------------------------------------------------------------
    if $game_switches[MAXRAID_SWITCH] && @battler.effects[PBEffects::MaxRaidBoss]
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,6,false,Color.new(248,248,248),Color.new(248,32,32)])
      turncount = @battler.effects[PBEffects::Dynamax]-1
      pbDrawRaidNumber(0,turncount,self.bitmap,@spriteBaseX+170,20,1)
      kocount = @battler.effects[PBEffects::KnockOutCount]
      kocount = 0 if kocount<0
      pbDrawRaidNumber(1,kocount,self.bitmap,@spriteBaseX+199,20,1)
      if @battler.effects[PBEffects::RaidShield]>0
        shieldHP   =   @battler.effects[PBEffects::RaidShield]
        shieldLvl  =   MAXRAID_SHIELD
        shieldLvl += 1 if @battler.level>25
        shieldLvl += 1 if @battler.level>35
        shieldLvl += 1 if @battler.level>45
        shieldLvl += 1 if @battler.level>55
        shieldLvl += 1 if @battler.level>65
        shieldLvl += 1 if @battler.level>=70 || $game_switches[HARDMODE_RAID]
        shieldLvl  = 1 if shieldLvl<=0
        shieldLvl  = 8 if shieldLvl>8
        offset     = (121-(2+shieldLvl*30/2))
        self.bitmap.blt(@spriteBaseX+offset,59,@raidBar.bitmap,Rect.new(0,0,2+shieldLvl*30,12)) 
        self.bitmap.blt(@spriteBaseX+offset,59,@shieldHP.bitmap,Rect.new(0,0,2+shieldHP*30,12))
      end
    #---------------------------------------------------------------------------
    else
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,6,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
      case @battler.displayGender
      when 0
        textPos.push([_INTL("♂"),@spriteBaseX+126,6,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
      when 1
        textPos.push([_INTL("♀"),@spriteBaseX+126,6,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
      end
      imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
      pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
    end
    pbDrawTextPositions(self.bitmap,textPos)
    if @battler.shiny?
      shinyX = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
      imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
    end
    if @battler.mega?
      imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
    elsif @battler.primal?
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      if isConst?(@battler.pokemon.species,PBSpecies,:KYOGRE)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+primalX+16,34])
      elsif isConst?(@battler.pokemon.species,PBSpecies,:GROUDON)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+primalX+16,34])
      end
    elsif @battler.dynamax?
      imagePos.push(["Graphics/Pictures/Dynamax/icon_dynamax",@spriteBaseX+8,34])
    end
    if @battler.owned? && @battler.opposes?(0) && !@battler.dynamax?
      imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
    end
    if @battler.status>0
      s = @battler.status
      s = 6 if s==PBStatuses::POISON && @battler.statusCount>0   # Badly poisoned
      imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,36,
         0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
    end
    pbDrawImagePositions(self.bitmap,imagePos)
    refreshHP
    refreshExp
  end
end


################################################################################
# SECTION 4 - MOVE UPDATES
#===============================================================================
# Updates certain moves that function differently in Max Raid Battles.
#===============================================================================

#===============================================================================
# Two-Turn Attaks (Fly, Dig, Dive, etc.)
#===============================================================================
# Max Raid Pokemon skip charge turn of moves that make them semi-invulnerable.
#-------------------------------------------------------------------------------
class PokeBattle_TwoTurnMove < PokeBattle_Move
  def pbIsChargingTurn?(user)
    @powerHerb = false
    @chargingTurn = false
    @damagingTurn = true
    if user.effects[PBEffects::TwoTurnAttack]==0
      @powerHerb = user.hasActiveItem?(:POWERHERB)
      @chargingTurn = true
      @damagingTurn = @powerHerb
      if user.effects[PBEffects::MaxRaidBoss] &&
         ["0C9","0CA","0CB","0CC","0CD","0CE","14D"].include?(@function)
        @damagingTurn = true
      end
    end
    return !@damagingTurn
  end
end


#===============================================================================
# Self-KO Moves (Self-Destruct, Explosion)
#===============================================================================
# Move fails when used by a Max Raid Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::MaxRaidBoss]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    elsif !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        @battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             user.pbThis,@name,bearer.pbThis(true),bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end
end

#===============================================================================
# Destiny Bond
#===============================================================================
# Move fails when used by a Max Raid Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if NEWEST_BATTLE_MECHANICS && user.effects[PBEffects::DestinyBondPrevious]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.effects[PBEffects::MaxRaidBoss]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Perish Song
#===============================================================================
# Move fails when used by any Pokemon in a Max Raid battle.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if b.effects[PBEffects::PerishSong]>0
      failed = false
      break
    end
    failed = true if $game_switches[MAXRAID_SWITCH]
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Teleport
#===============================================================================
# Move fails when used by any Pokemon in a Max Raid battle.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !@battle.pbCanRun?(user.index) || $game_switches[MAXRAID_SWITCH]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end