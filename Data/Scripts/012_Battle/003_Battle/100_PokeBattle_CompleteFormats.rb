class PokeBattle_Battle 
  
  def self.parseBattleMode(mode)
    if mode == "single"
      return [1, 1]
    elsif mode == "double"
      return [2, 2]
    elsif mode == "triple"
      return [3, 3]
    end 
    
    m = mode.match /(\d)v(\d)/
    
    if m && m.length == 3
      return [m[1].to_i, m[2].to_i]
    end 
    
    return [1, 1]
  end 
  
  def self.isValidBattleMode?(mode)
    m = mode.match /(\d)v(\d)/
    return false if m.length != 3 
    
    m1 = m[1].to_i
    m2 = m[2].to_i
    return m1 > 0 && m1 <= 6 && m2 > 0 && m2 <= 6 
  end 
  
  def pbGetOpposingIndicesInOrderComplete(idxBattler)
    # return nil if pbSideSize(0) <= 3 && pbSideSize(1) <= 3 
    case pbSideSize(0)
    # ---------------------------------
    when 1
      case pbSideSize(1)
      when 1
        # 1v1
        #    1
        #    0
        case idxBattler
        when 0; return [1]
        when 1; return [0]
        end 
      when 2
        # 1v2
        #    3 - 1
        #      0
        case idxBattler
        when 0; return [1,3]
        when 1, 3; return [0]
        end 
      when 3 
        # 1v3
        #    5 - 3 - 1
        #        0
        case idxBattler
        when 0; return [3, 5, 1]
        when 1, 3, 5; return [0]
        end 
      when 4
        # 1v4
        #    7 - 5 - 3 - 1
        #          0
        case idxBattler
        when 0; return [5, 3, 1, 7]
        when 1, 3, 5, 7; return [0]
        end 
      when 5
        # 1v5
        #    9 - 7 - 5 - 3 - 1
        #            0
        case idxBattler
        when 0; return [5, 3, 1, 9, 7]
        when 1, 3, 5, 7, 9; return [0]
        end 
      when 6 
        # 1v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #               0
        case idxBattler
        when 0; return [7, 5, 3, 1, 11, 9]
        when 1, 3, 5, 7, 9, 11; return [0]
        end 
      end 
    # ---------------------------------
    when 2
      case pbSideSize(1)
      when 1
        # 2v1
        #      1
        #    0 - 2
        case idxBattler
        when 1; return [0, 2]
        when 0, 2; return [1]
        end 
      when 2
        # 2v2
        #    3 - 1
        #    0 - 2
        case idxBattler
        when 1, 3; return [0, 2]
        when 0, 2; return [1, 3]
        end 
      when 3 
        # 2v3
        #    5 - 3 - 1
        #      0 - 2
        case idxBattler
        when 3, 5; return [0, 2]
        when 1; return [2, 0]
        when 0; return [3, 1, 5]
        when 2; return [3, 1, 5]
        end 
      when 4
        # 2v4
        #    7 - 5 - 3 - 1
        #        0 - 2
        case idxBattler
        when 0; return [7, 5, 3, 1]
        when 2; return [3, 1, 7, 5]
        when 5, 7; return [0, 2]
        when 1, 3; return [2, 0]
        end 
      when 5
        # 2v5
        #    9 - 7 - 5 - 3 - 1
        #          0 - 2 
        case idxBattler
        when 0, 2; return [5, 3, 1, 9, 7]
        when 5, 7, 9; return [0, 2]
        when 1, 3; return [2, 0]
        end 
      when 6 
        # 2v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #             0 - 2
        case idxBattler
        when 0; return [7, 5, 3, 1, 11, 9]
        when 2; return [5, 3, 1, 11, 9, 7]
        when 1, 3, 5; return [2, 0]
        when 7, 9, 11; return [0, 2]
        end 
      end 
    # ---------------------------------
    when 3
      case pbSideSize(1)
      when 1
        # 3v1
        #        1
        #    0 - 2 - 4
        case idxBattler
        when 0, 2, 4; return [1]
        when 1; return [2, 0, 4]
        end 
      when 2
        # 3v2
        #      3 - 1
        #    0 - 2 - 4
        case idxBattler
        when 0, 2; return [3, 1]
        when 4; return [1, 3]
        when 1; return [2, 0, 4]
        when 3; return [2, 0, 4]
        end 
      when 3 
        # 3v3
        #    5 - 3 - 1
        #    0 - 2 - 4
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [4, 2, 0]
        when 2; return [3, 1, 5]
        when 3; return [2, 0, 4]
        when 4; return [1, 5, 3]
        when 5; return [0, 2, 4]
        end 
      when 4
        # 3v4
        #      5 - 3 - 1
        #    0 - 2 - 4 - 6
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [6, 4, 2, 0]
        when 2; return [5, 3, 1]
        when 3; return [2, 4, 6, 0]
        when 4; return [1, 3, 5]
        when 5; return [0, 2, 4, 6]
        when 6; return [1, 3, 5]
        end 
      when 5
        # 3v5
        #        5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [6, 8, 4, 2, 0]
        when 2; return [5, 3, 1]
        when 3; return [2, 4, 6, 0, 8]
        when 4; return [3, 1, 5]
        when 5; return [2, 0, 4, 6, 8]
        when 6; return [1, 3, 5]
        when 8; return [1, 3, 5]
        end 
      when 6 
        # 3v6
        #          5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [6, 8, 10, 4, 2, 0]
        when 2; return [5, 3, 1]
        when 3; return [4, 6, 2, 8, 10, 0]
        when 4; return [3, 1, 5]
        when 5; return [2, 4, 0, 6, 8, 10]
        when 6; return [3, 1, 5]
        when 8; return [1, 3, 5]
        when 10; return [1, 3, 5]
        end 
      end 
    # ---------------------------------
    when 4
      case pbSideSize(1)
      when 1
        # 4v1
        #          1
        #    0 - 2 - 4 - 6
        case idxBattler
        when 0, 2, 4, 6; return [1]
        when 1; return [2, 4, 6, 0]
        end 
      when 2
        # 4v2
        #        3 - 1
        #    0 - 2 - 4 - 6
        case idxBattler
        when 4, 6; return [1, 3]
        when 0, 2; return [3, 1]
        when 1; return [4, 2, 6, 0]
        when 3; return [2, 4, 0, 6]
        end 
      when 3 
        # 4v3
        #      5 - 3 - 1
        #    0 - 2 - 4 - 6
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [6, 4, 2, 0]
        when 2; return [5, 3, 1]
        when 3; return [2, 4, 0, 6]
        when 4; return [1, 3, 5]
        when 5; return [0, 2, 4, 6]
        when 6; return [1, 3, 5]
        end 
      when 4
        # 4v4
        #    7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6
        case idxBattler
        when 0; return [7, 5, 3, 1]
        when 1; return [6, 4, 2, 0]
        when 2; return [5, 7, 3, 1]
        when 3; return [4, 6, 2, 0]
        when 4; return [3, 1, 5, 7]
        when 5; return [2, 0, 4, 6]
        when 6; return [1, 3, 5, 7]
        when 7; return [0, 2, 4, 6]
        end 
      when 5
        # 4v5
        #    9 - 7 - 5 - 3 - 1
        #      0 - 2 - 4 - 6
        case idxBattler
        when 0; return [7, 9, 5, 3, 1]
        when 1; return [6, 4, 2, 0]
        when 2; return [7, 5, 9, 3, 1]
        when 3; return [6, 4, 2, 0]
        when 4; return [5, 3, 1, 7, 9]
        when 5; return [4, 2, 0, 6]
        when 6; return [1, 3, 5, 7, 9]
        when 7; return [0, 2, 4, 6]
        when 9; return [0, 2, 4, 6]
        end 
      when 6 
        # 4v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #         0 - 2 - 4 - 6
        case idxBattler
        when 0; return [9, 11, 7, 5, 3, 1]
        when 1; return [6, 4, 2, 0]
        when 2; return [7, 5, 9, 3, 1, 11]
        when 3; return [6, 4, 2, 0]
        when 4; return [5, 3, 1, 7, 9, 11]
        when 5; return [4, 6, 2, 0]
        when 6; return [1, 3, 5, 7, 9, 11]
        when 7; return [0, 2, 4, 6]
        when 9; return [0, 2, 4, 6]
        when 11; return [0, 2, 4, 6]
        end 
      end 
    # ---------------------------------
    when 5
      case pbSideSize(1)
      when 1
        # 5v1
        #            1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0, 2, 4, 6, 8; return [1]
        when 1; return [2, 4, 6, 0, 8]
        end 
      when 2
        # 5v2
        #          3 - 1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 4, 6, 8; return [1, 3]
        when 0, 2; return [3, 1]
        when 1; return [6, 4, 8, 2, 0]
        when 3; return [2, 4, 0, 6, 8]
        end 
      when 3 
        # 5v3
        #        5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0; return [5, 3, 1]
        when 1; return [6, 8, 4, 2, 0]
        when 2; return [3, 5, 1]
        when 3; return [4, 6, 2, 0, 8]
        when 4; return [3, 1, 5]
        when 5; return [2, 0, 4, 6, 8]
        when 6; return [1, 3, 5]
        when 8; return [1, 3, 5]
        end 
      when 4
        # 5v4
        #      7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0; return [7, 5, 3, 1]
        when 1; return [8, 6, 4, 2, 0]
        when 2; return [7, 5, 3, 1]
        when 3; return [6, 4, 8, 2, 0]
        when 4; return [3, 5, 7, 1]
        when 5; return [2, 4, 0, 6, 8]
        when 6; return [1, 3, 5, 7]
        when 7; return [0, 2, 4, 6, 8]
        end 
      when 5
        # 5v5
        #    9 - 7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0; return [9, 7, 5, 3, 1]
        when 1; return [8, 6, 4, 2, 0]
        when 2; return [7, 5, 9, 3, 1]
        when 3; return [6, 4, 8, 2, 0]
        when 4; return [5, 3, 7, 1, 9]
        when 5; return [4, 2, 6, 0, 8]
        when 6; return [1, 3, 5, 7, 9]
        when 7; return [2, 0, 4, 6, 8]
        when 8; return [1, 3, 5, 7, 9]
        when 9; return [0, 2, 4, 6, 8]
        end 
      when 6 
        # 5v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #       0 - 2 - 4 - 6 - 8
        case idxBattler
        when 0; return [11, 9, 7, 5, 3, 1]
        when 1; return [8, 6, 4, 2, 0]
        when 2; return [9, 11, 7, 5, 3, 1]
        when 3; return [8, 6, 4, 2, 0]
        when 4; return [7, 9, 5, 11, 3, 1]
        when 5; return [4, 6, 8, 2, 0]
        when 6; return [5, 3, 1, 7, 9, 11]
        when 7; return [2, 4, 0, 6, 8]
        when 8; return [1, 3, 5, 7, 9, 11]
        when 9; return [0, 2, 4, 6, 8]
        when 11; return [0, 2, 4, 6, 8]
        end 
      end 
    # ---------------------------------
    when 6
      case pbSideSize(1)
      when 1
        # 6v1
        #               1
        #    0  - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0, 2, 4, 6, 8, 10; return [1]
        when 1; return [6, 4, 8, 2, 10, 0]
        end 
      when 2
        # 6v2
        #             3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0, 2, 4, 6, 8, 10; return [1, 3]
        when 1, 3; return [6, 4, 8, 2, 10, 0]
        end 
      when 3 
        # 6v3
        #          5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0, 2, 4; return [5, 3, 1]
        when 6, 8, 10; return [1, 3, 5]
        when 1; return [8, 6, 10, 4, 2, 0]
        when 3; return [4, 6, 2, 8, 10, 0]
        when 5; return [2, 4, 0, 6, 8, 10]
        end 
      when 4
        # 6v4
        #         7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0; return [7, 5, 3, 1]
        when 1; return [8, 10, 6, 4, 2, 0]
        when 2; return [7, 5, 3, 1]
        when 3; return [6, 4, 8, 10, 2, 0]
        when 4; return [5, 7, 3, 1]
        when 5; return [4, 2, 6, 0, 8, 10]
        when 6; return [3, 5, 1, 7]
        when 7; return [2, 0, 4, 6, 8, 10]
        when 8; return [1, 3, 5, 7]
        when 10; return [1, 3, 5, 7]
        end 
      when 5
        # 6v5
        #       9 - 7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0; return [9, 7, 5, 3, 1]
        when 1; return [10, 8, 6, 4, 2, 0]
        when 2; return [9, 7, 5, 3, 1]
        when 3; return [8, 6, 10, 4, 2, 0]
        when 4; return [7, 5, 9, 3, 1]
        when 5; return [6, 4, 8, 2, 0, 10]
        when 6; return [5, 3, 7, 1, 9]
        when 7; return [4, 2, 6, 0, 8, 10]
        when 8; return [1, 3, 5, 7, 9]
        when 9; return [0, 2, 4, 6, 8, 10]
        when 10; return [1, 3, 5, 7, 9]
        end 
      when 6
        # 6v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        case idxBattler
        when 0; return [11, 9, 7, 5, 3, 1]
        when 1; return [10, 8, 6, 4, 2, 0]
        when 2; return [9, 11, 7, 5, 3, 1]
        when 3; return [8, 6, 10, 4, 2, 0]
        when 4; return [7, 9, 5, 3, 1, 11]
        when 5; return [6, 4, 8, 10, 2, 0]
        when 6; return [5, 7, 3, 1, 11, 9]
        when 7; return [4, 2, 6, 0, 10, 8]
        when 8; return [3, 1, 5, 7, 9, 11]
        when 9; return [2, 0, 4, 6, 8, 10]
        when 10; return [1, 3, 5, 7, 9, 11]
        when 11; return [0, 2, 4, 6, 8, 10]
        end 
      end 
    end 
    return nil 
  end 
  
  def nearBattlersComplete?(idxBattler1,idxBattler2)
    return false if idxBattler1 == idxBattler2
    
    # If diff_abs is even, then they are from the same side, which will allow for easier characterisations. 
    diff_abs = (idxBattler1 - idxBattler2).abs
    return true if diff_abs == 2 # Near because neighbours. 
    return false if [4, 6, 8, 10].include?(diff_abs) # Same side but too far. 
    
    # For difficult cases, just list the pairs of battlers that are not near. 
    pairsArray = []
    
    # In the following, we assume that idxBattler1 != idxBattler2 and different side sizes. 
    # My rule: in 1vX and 2vX, the Pokémons on the first side can hit every Pokémon on the other side.
    # Pokémons become inaccessible starting from 3vX. 
    # If the two sides have the same size: 
    #   If same side: abs(idx1 - idx2) == 2
    #   Facing Pokémon: idx1 + idx2 == maxBattlerIndex 
    #   Diagonal: abs(idx1 + idx2 - max index) == 2
    #   All the rest are too far away. 
    case pbSideSize(0)
    # ---------------------------------
    when 1
      case pbSideSize(1)
      when 1
        # 1v1
        #    1
        #    0
        return true
      when 2
        # 1v2
        #    3 - 1
        #      0
        return true
      when 3 
        # 1v3
        #    5 - 3 - 1
        #        0
        return diff_abs != 4
      when 4
        # 1v4
        #    7 - 5 - 3 - 1
        #          0
        return true 
      when 5
        # 1v5
        #    9 - 7 - 5 - 3 - 1
        #            0
        return true 
      when 6 
        # 1v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #               0
        return true 
      end 
    # ---------------------------------
    when 2
      case pbSideSize(1)
      when 1
        # 2v1
        #      1
        #    0 - 2
        return true 
      when 2
        # 2v2
        #    3 - 1
        #    0 - 2
        return true 
      when 3 
        # 2v3
        #    5 - 3 - 1
        #      0 - 2
        return true
      when 4
        # 2v4
        #    7 - 5 - 3 - 1
        #        0 - 2
        return true 
      when 5
        # 2v5
        #    9 - 7 - 5 - 3 - 1
        #          0 - 2 
        return true 
      when 6 
        # 2v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #             0 - 2
        return true 
      end 
    # ---------------------------------
    when 3
      case pbSideSize(1)
      when 1
        # 3v1
        #        1
        #    0 - 2 - 4
        return true 
      when 2
        # 3v2
        #      3 - 1
        #    0 - 2 - 4
        return true 
      when 3 
        # 3v3
        #    5 - 3 - 1
        #    0 - 2 - 4
        return true if [-2, 0, 2].include?(idxBattler1 + idxBattler2 - maxBattlerIndex)
        return false 
      when 4
        # 3v4
        #    7 - 5 - 3 - 1
        #      0 - 2 - 4
        pairsArray.push([0, 1])
        pairsArray.push([4, 7])
      when 5
        # 3v5
        #    9 - 7 - 5 - 3 - 1
        #        0 - 2 - 4
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([2, 1])
        pairsArray.push([2, 9])
        pairsArray.push([4, 7])
        pairsArray.push([4, 9])
      when 6 
        # 3v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #           0 - 2 - 4
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([2, 1])
        pairsArray.push([2, 11])
        pairsArray.push([4, 9])
        pairsArray.push([4, 11])
      end 
    # ---------------------------------
    when 4
      case pbSideSize(1)
      when 1
        # 4v1
        #          1
        #    0 - 2 - 4 - 6
        return true 
      when 2
        # 4v2
        #        3 - 1
        #    0 - 2 - 4 - 6
        return true
      when 3 
        # 4v3
        #      5 - 3 - 1
        #    0 - 2 - 4 - 6
        pairsArray.push([0, 1])
        pairsArray.push([6, 5])
      when 4
        # 4v4
        #    7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6
        return true if [-2, 0, 2].include?(idxBattler1 + idxBattler2 - maxBattlerIndex)
        return false 
      when 5
        # 4v5
        #    9 - 7 - 5 - 3 - 1
        #      0 - 2 - 4 - 6
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([2, 1])
        pairsArray.push([4, 9])
        pairsArray.push([6, 7])
        pairsArray.push([6, 9])
      when 6 
        # 4v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #         0 - 2 - 4 - 6
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([0, 5])
        pairsArray.push([2, 11])
        pairsArray.push([2, 3])
        pairsArray.push([2, 1])
        pairsArray.push([4, 1])
        pairsArray.push([4, 9])
        pairsArray.push([4, 11])
        pairsArray.push([6, 7])
        pairsArray.push([6, 9])
        pairsArray.push([6, 11])
      end 
    # ---------------------------------
    when 5
      case pbSideSize(1)
      when 1
        # 5v1
        #            1
        #    0 - 2 - 4 - 6 - 8
        return true 
      when 2
        # 5v2
        #          3 - 1
        #    0 - 2 - 4 - 6 - 8
        return true 
      when 3 
        # 5v3
        #        5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        pairsArray.push([0, 1])
        pairsArray.push([2, 1])
        pairsArray.push([6, 5])
        pairsArray.push([8, 5])
      when 4
        # 5v4
        #      7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([2, 1])
        pairsArray.push([6, 7])
        pairsArray.push([8, 5])
        pairsArray.push([8, 7])
      when 5
        # 5v5
        #    9 - 7 - 5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8
        return true if [-2, 0, 2].include?(idxBattler1 + idxBattler2 - maxBattlerIndex)
        return false 
      when 6 
        # 5v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #       0 - 2 - 4 - 6 - 8
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([0, 5])
        pairsArray.push([2, 1])
        pairsArray.push([2, 3])
        pairsArray.push([4, 1])
        pairsArray.push([4, 11])
        pairsArray.push([6, 9])
        pairsArray.push([6, 11])
        pairsArray.push([8, 7])
        pairsArray.push([8, 9])
        pairsArray.push([8, 11])
      end 
    # ---------------------------------
    when 6
      case pbSideSize(1)
      when 1
        # 6v1
        #               1
        #    0  - 2 - 4 - 6 - 8 - 10
        return true 
      when 2
        # 6v2
        #             3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        return true 
      when 3 
        # 6v3
        #          5 - 3 - 1
        #    0 - 2 - 4 - 6 - 8 - 10
        pairsArray.push([0, 1])
        pairsArray.push([2, 1])
        pairsArray.push([8, 5])
        pairsArray.push([10, 5])
      when 4
        # 6v4
        #         7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([2, 1])
        pairsArray.push([2, 3])
        pairsArray.push([4, 1])
        pairsArray.push([6, 7])
        pairsArray.push([8, 5])
        pairsArray.push([8, 7])
        pairsArray.push([10, 5])
        pairsArray.push([10, 7])
      when 5
        # 6v5
        #       9 - 7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        pairsArray.push([0, 1])
        pairsArray.push([0, 3])
        pairsArray.push([0, 5])
        pairsArray.push([2, 1])
        pairsArray.push([2, 3])
        pairsArray.push([4, 1])
        pairsArray.push([6, 9])
        pairsArray.push([8, 7])
        pairsArray.push([8, 9])
        pairsArray.push([10, 5])
        pairsArray.push([10, 7])
        pairsArray.push([10, 9])
      when 6
        # 6v6
        #    11 - 9 - 7 - 5 - 3 - 1
        #    0  - 2 - 4 - 6 - 8 - 10
        return true if [-2, 0, 2].include?(idxBattler1 + idxBattler2 - maxBattlerIndex)
        return false 
      end 
    end 
    
    # See if any pair matches the two battlers being assessed
    pairsArray.each do |pair|
      return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
    end
    return true
  end 
  
  def pbEORShiftDistantBattlers
    # Makes each side compact when a Pokémon is KO and not replaced. 
    return if singleBattle?
    for side in 0..1
      next if pbSideSize(side) == 1
      
      # debug_log = ""
      # @battlers.each do |b|
        # # first scan before 
        # next if !b || b.opposes?(side)
        
        # debug_log += "," if debug_log == ""
        # debug_log += "KO" if b.fainted?
        # debug_log += "--" if !b.fainted?
      # end 
      # pbMessage("before=" + debug_log)
      
      # For example:  0 - 2 - 4 - 6 - 8 - 10
      #                   KO      KO
      # I want:       0 - 4 - 8 - 10 - 2 - 6
      #                                KO  KO 
      # I want to push KO members to the high indices (to the right)
      # And then:     0 - 4 - 8 - 10
      # Reduce the side size accordingly. 
      
      i = 0
      while i < @battlers.length
        b1 = @battlers[i]
        if !b1 || b1.opposes?(side) || !b1.fainted?
          i += 1
          next 
        end 
        
        some_right_alive = false 
        # checks if some battler on the right of battlers[i] is still alive, 
        # in which case continue to loop.
        @battlers.each do |b2|
          # Kind of bubble sort: if b1 is on the right of b2, then ignore; if 
          # b1 is on the left of b2, swap b1 and b2. 
          next if !b2 || b2.opposes?(b1)
          next if b2.index <= b1.index # b1 is on the right of b2
          
          # Here, b1 is on the left of b2. 
          some_right_alive = some_right_alive || !b2.fainted?
          
          pbSwapBattlers(b1.index, b2.index)
        end 
        
        if some_right_alive
          if !@battlers[i].fainted?
            i += 1
          # else 
            # Else the new battler at index i is also fainted, we need to 
            # handle that index i again. No update of i. 
          end 
        else 
          break 
        end 
      end 
      
      debug_log = ""
      new_side_size = 0
      @battlers.each do |b|
        # Second scan 
        next if !b || b.opposes?(side)
        
        new_side_size += 1 if !b.fainted?
        
        debug_log += "," if debug_log == ""
        debug_log += "KO" if b.fainted?
        debug_log += "--" if !b.fainted?
      end 
      # pbMessage("after=" + debug_log)
      # pbMessage(_INTL("new_side_size={1}", new_side_size))
      
      @sideSizes[side] = new_side_size
    end 
    @scene.pbReinitTargetWindow
  end 
end 

class PokeBattle_Scene
  
  def pbReinitTargetWindow
    @sprites["targetWindow"] = TargetMenuDisplay.new(@viewport,200,@battle.sideSizes)
    pbRefresh
  end 
end 


class PokeBattle_Battle
  #=============================================================================
  # Shifting a battler to another position in a battle larger than double.
  # Ask which side. 
  #=============================================================================
  
  def pbAskShift(idxBattler)
    return nil if pbSideSize(idxBattler) <= 3
    
    maxIndex = nil 
    
    case pbSideSize(idxBattler)
    when 4 
      # 4v4
      #    7 - 5 - 3 - 1
      #    0 - 2 - 4 - 6
      maxIndex = 6 + (idxBattler % 2)
    when 5
      # 5v5 
      #    9 - 7 - 5 - 3 - 1
      #    0 - 2 - 4 - 6 - 8
      maxIndex = 8 + (idxBattler % 2)
    when 6 
      # 6v6
      #    11 - 9 - 7 - 5 - 3 - 1
      #    0  - 2 - 4 - 6 - 8 - 10
      maxIndex = 10 + (idxBattler % 2)
    end 
    
    left = (idxBattler < 2 ? nil : idxBattler - 2)
    right = (maxIndex == idxBattler ? nil : idxBattler + 2)
    
    if left && right
      # Can choose a side. 
      ret = @scene.pbShowCommands("Shift left or right?", ["Left", "Right"],-1)
      
      case ret 
      when 0 
        return left 
      when 1
        return right 
      else 
        return -1
      end 
    end 
    return nil 
  end 
  
  def pbRegisterShift(idxBattler)
    idxOther = pbAskShift(idxBattler)
    return false if idxOther == -1 # Asked left or right, and chose "Cancel"
    @choices[idxBattler][0] = :Shift
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = idxOther
    return true
  end
end 

