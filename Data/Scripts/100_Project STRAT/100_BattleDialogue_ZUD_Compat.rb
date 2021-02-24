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
      TrainerDialogue.display("fainted",@battle,@battle.scene)
    else
      TrainerDialogue.display("faintedOpp",@battle,@battle.scene)
    end
  end
  
  alias __compat__pbReduceHP pbReduceHP # Should be the one from ZUD
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true,ignoreDynamax=false)
    amt = __compat__pbReduceHP(amt,anim,registerDamage,anyAnim,ignoreDynamax)
    
    if self.hp < (self.totalhp*0.25).floor && !self.damageState.lowHP && self.hp>0
      self.damageState.lowHP = true
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("lowHP",@battle,@battle.scene)
      else
        TrainerDialogue.display("lowHPOpp",@battle,@battle.scene)
      end
    elsif self.hp < (self.totalhp*0.5).floor && self.hp > (self.totalhp*0.25).floor && !self.damageState.halfHP
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("halfHP",@battle,@battle.scene)
      else
        TrainerDialogue.display("halfHPOpp",@battle,@battle.scene)
      end
    end
    
    return amt 
  end 
end 

