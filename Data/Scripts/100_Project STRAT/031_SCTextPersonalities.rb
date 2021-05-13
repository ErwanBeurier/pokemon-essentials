################################################################################
# SCTextPersonalities
# 
# This script is part of Pokémon Project STRAT by StCooler, and is therefore 
# not part of Pokémon Essentials. 
# 
# This script contains the formatting information for message boxes.
################################################################################


$SCFormattingPersonalities = {}
# Player character 
$SCFormattingPersonalities["\\PN"] = "\\xn[\\PN]"
$SCFormattingPersonalities["Player"] = $SCFormattingPersonalities["\\PN"]
# Rachel (Manager)
$SCFormattingPersonalities["Rachel"] = "\\xn[Rachel,ad26d4,3b2a40]"
# Cindy
$SCFormattingPersonalities["Cindy"] = "\\xn[Cindy]"
# Weston (best friend)
$SCFormattingPersonalities["Weston"] = "\\xn[Weston]"
# Yves (archaeologist)
$SCFormattingPersonalities["Yves"] = "\\xn[Yves]"
# Connor (bug-type specialist)
$SCFormattingPersonalities["Connor"] = "\\xn[Connor,ba815d,4d3729]"
# Seren (kinda depressive)
$SCFormattingPersonalities["Seren"] = "\\xn[Seren]"
# Foxy
$SCFormattingPersonalities["Foxy"] = "\\xn[Foxy]"
# Kate
$SCFormattingPersonalities["Kate"] = "\\xn[Kate]"
# Hettie (rival)
$SCFormattingPersonalities["Hettie"] = "\\xn[Hettie]"
# Client (Male)
$SCFormattingPersonalities["ClientM"] = [
            "\\xn[Client,1d34cc,1e286e]", 
            "\\xn[Client,268ed4,0e3854]", 
            "\\xn[Client,589dcc,233f52]", 
            "\\xn[Client,597cc9,22304f]"]
# Client (Female)
$SCFormattingPersonalities["ClientF"] = [
            "\\xn[Client,cc1d80,6b1546]", 
            "\\xn[Client,b251b5,3a1a3b]", 
            "\\xn[Client,bf3bae,381133]", 
            "\\xn[Client,d15289,2e111e]"]
# Client (Undefined/Other)
$SCFormattingPersonalities["Client"] = "\\xn[Client]"


def scMessageDisplaySubstitution(text)
  text.gsub!(/\\[Ss][Cc]\[([\w\s]+)\]/) {
    # Get the name 
    param = $1
    # Get the formatting 
    s = $SCFormattingPersonalities[param]
    # Choose the formatting (for clients)
    s = scsample(s, 1) if s.is_a?(Array)
    # In case the formatting is undefined, use this. 
    s = _INTL("\\xn[{1}]", param) if !s
    next s
  }
  return text 
end 


