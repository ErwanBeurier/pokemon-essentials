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
$SCFormattingPersonalities["UnnamedPlayer"] = "\\W[speech hgss 4]"
$SCFormattingPersonalities["Player"] = "\\xn[\\PN,,,,,,,,speech hgss 4]" + $SCFormattingPersonalities["UnnamedPlayer"]
$SCFormattingPersonalities["\\PN"] = $SCFormattingPersonalities["Player"]
# Rachel (Manager)
$SCFormattingPersonalities["Rachel"] = "\\xn[Rachel,,,,,,,,speech hgss 7]\\W[speech hgss 7]"
$SCFormattingPersonalities["Manager"] = $SCFormattingPersonalities["Rachel"]
# Yves (archaeologist)
$SCFormattingPersonalities["Yves"] = "\\xn[Yves,,,,,,,,speech pl 1]\\W[speech pl 1]"
# Mikhail (bug-type specialist)
$SCFormattingPersonalities["Mikhail"] = "\\xn[Mikhail,,,,,,,,speech dp 21]\\W[speech dp 21]"
# Totem
$SCFormattingPersonalities["Totem"] = "\\xn[Totem,,,,,,,,speech dp 2]\\W[speech dp 2]"
# Seren (rival)
$SCFormattingPersonalities["Seren"] = "\\xn[Seren,,,,,,,,speech dp 22]\\W[speech dp 22]"
# Foxy (hostess)
$SCFormattingPersonalities["Foxy"] = "\\xn[Foxy,,,,,,,,speech dp 9]\\W[speech dp 9]"
# Hettie (higher formats specialist)
$SCFormattingPersonalities["Hettie"] = "\\xn[Hettie,,,,,,,,speech hgss 21]\\W[speech hgss 21]"
# Client (Male)
$SCFormattingPersonalities["ClientM"] = "\\xn[Client,,,,,,,,speech dp 14]\\W[speech dp 14]"
# Client (Female)
$SCFormattingPersonalities["ClientF"] = "\\xn[Client,,,,,,,,speech dp 13]\\W[speech dp 13]"
# Client (Undefined/Other)
$SCFormattingPersonalities["Client"] = "\\xn[Client,,,,,,,,speech dp 11]\\W[speech dp 11]"
# Poacher (Male)
$SCFormattingPersonalities["PoacherM"] = "\\xn[Poacher,,,,,,,,speech dp 14]\\W[speech dp 14]"
# Poacher (Female)
$SCFormattingPersonalities["PoacherF"] = "\\xn[Poacher,,,,,,,,speech dp 13]\\W[speech dp 13]"
# Maeve / Lorant
$SCFormattingPersonalities["Maeve"] = "\\xn[Maeve,,,,,,,,speech hgss 23]\\W[speech hgss 23]"
$SCFormattingPersonalities["MaeveUnnamed"] = $SCFormattingPersonalities["Maeve"]
$SCFormattingPersonalities["MaeveUnnamed"].sub(/Maeve/, "Woman")
$SCFormattingPersonalities["Lorant"] = "\\xn[Lorànt,,,,,,,,speech hgss 22]\\W[speech hgss 22]"
$SCFormattingPersonalities["Lorànt"] = $SCFormattingPersonalities["Lorant"]
# Characters: 
$SCFormattingPersonalities["Oak"] = "\\xn[Oak,,,,,,,,speech hgss 24]\\W[speech hgss 24]"
$SCFormattingPersonalities["Derek"] = "\\xn[Derek,,,,,,,,speech dp 23]\\W[speech dp 23]"
# Eddie (ninja fan)
$SCFormattingPersonalities["Eddie"] = "\\xn[Eddie,,,,,,,,speech dp 14]\\W[speech dp 14]"
# Game
$SCFormattingPersonalities["Computer"] = "\\W[speech hgss 2]"
$SCFormattingPersonalities["Game"] = "\\W[speech hgss 2]"
$SCFormattingPersonalities["Tutorial"] = "\\xn[Tutorial,,,,,,,,speech hgss 2]" + $SCFormattingPersonalities["Game"]
$SCFormattingPersonalities["Diary"] = "\\W[speech hgss 1]"


def scMessageDisplaySubstitution(text)
  text.gsub!(/\\[Ss][Cc]\[([\w\s]+)\]/) {
    # Get the name 
    param = $1
    # Get the formatting 
    s = $SCFormattingPersonalities[param]
    if s && param == "Totem"
      s.sub(/Totem/, SCStoryPokemon.get(:Totem).name)
    end 
    # Choose the formatting (for clients)
    s = scsample(s, 1) if s.is_a?(Array)
    # In case the formatting is undefined, use this. 
    s = _INTL("\\xn[{1}]", param) if !s
    next s
  }
  return text 
end 


def scNamedClientFormat(name, gender)
  s = "" 
  
  if gender == 0 || gender == "m"
    s = $SCFormattingPersonalities["ClientM"]
  elsif gender == 1 || gender == "f"
    s = $SCFormattingPersonalities["ClientF"]
  else 
    s = $SCFormattingPersonalities["Client"]
  end 
  
  return s.sub(/Client/, name)
end 