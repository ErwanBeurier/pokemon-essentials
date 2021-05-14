# Compatibility patch ZUD and Battle Scripts. 



# Compatibility with ZUD
class PokeBattle_Battler
# Faint Dialogue
  alias __compat__faint pbFaint # Should be the one from ZUD
  def pbFaint(showMessage=true)
    return if @fainted   # Has already fainted properly
    __compat__faint(showMessage)
    return if !fainted? # Just in case __compat__faint stops for this reason. 
    if !opposes?
      TrainerDialogue.display("fainted",@battle,@battle.scene, self)
    else
      TrainerDialogue.display("faintedOpp",@battle,@battle.scene, self)
    end
  end
  
  alias __compat__pbReduceHP pbReduceHP # Should be the one from ZUD
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true,ignoreDynamax=false)
    amt = __compat__pbReduceHP(amt,anim,registerDamage,anyAnim,ignoreDynamax)
    
    if self.hp < (self.totalhp*0.25).floor && !self.damageState.lowHP && self.hp>0
      self.damageState.lowHP = true
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("lowHP",@battle,@battle.scene, [nil, self])
      else
        TrainerDialogue.display("lowHPOpp",@battle,@battle.scene, [nil, self])
      end
    elsif self.hp < (self.totalhp*0.5).floor && self.hp > (self.totalhp*0.25).floor && !self.damageState.halfHP
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("halfHP",@battle,@battle.scene, [nil, self])
      else
        TrainerDialogue.display("halfHPOpp",@battle,@battle.scene, [nil, self])
      end
    end
    
    return amt 
  end 
end 

# Addition of switching.
class PokeBattle_AI
  attr_accessor :commandIndex
  attr_accessor :commandOppIndex
  
  alias __scripted__initialize initialize
  def initialize(battle)
    __scripted__initialize(battle)
    @commandIndex = 0
    @commandOppIndex = 0
  end 
  
  # STRAT Addition: Force a certain command from the enemy.
  alias __scripted__pbDefaultChooseEnemyCommand pbDefaultChooseEnemyCommand
  def pbDefaultChooseEnemyCommand(idxBattler)
    if @commandOppIndex > 0 
      # Specify the index of the command to use. 
      ret = TrainerDialogue.display("commandOpp#{@commandOppIndex}",@battle, @battle.scene, idxBattler)
      if ret 
        @commandOppIndex = 0
        return 
      end 
    end 
    __scripted__pbDefaultChooseEnemyCommand(idxBattler)
  end 
end 


