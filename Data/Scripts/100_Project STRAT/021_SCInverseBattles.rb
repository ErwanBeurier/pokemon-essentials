$InverseBattle = false 


def scMakeInverseBattle
  $InverseBattle = true 
end 



class PBTypes
  # Inverse type effectiveness. 
  def PBTypes.getEffectiveness(attackType,targetType)
    return PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if !targetType || targetType<0
    
    ret = PBTypes.loadTypeData[2][attackType*(PBTypes.maxValue+1)+targetType]
    
    if $InverseBattle
      case ret
      when PBTypeEffectiveness::INEFFECTIVE, PBTypeEffectiveness::NOT_EFFECTIVE_ONE
        ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
        
      when PBTypeEffectiveness::SUPER_EFFECTIVE_ONE
        ret = PBTypeEffectiveness::NOT_EFFECTIVE_ONE
        
      end 
    end 
    return ret 
  end
end 



class PokeBattle_Battle 
  # Revert Inverse Battle. 
  alias __inversebattle__pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    ret = __inversebattle__pbEndOfBattle
    $InverseBattle = false
    return ret 
  end 
end 







