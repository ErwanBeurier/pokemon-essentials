
original_pbs_pokemon = "..\\PBS\\pokemon.txt"
new_pbs_pokemon = "..\\..\\PBS\\pokemon.txt"
merged_pbs_pokemon = "..\\..\\PBS\\pokemon_merged.txt"


# Take the Eggmoves from the old, original pokemon file.
original_egg_moves = {}

with open(original_pbs_pokemon, "r") as f:
	poke = ""
	
	for line in f:
		line = line.replace("\r","")
		line = line.replace("\n","")
		line = line.replace(" ","")
		
		if line.startswith("InternalName="):
			poke = line.replace("InternalName=","")
		elif line.startswith("EggMoves="):
			original_egg_moves[poke] = line.replace("EggMoves=","").split(",")



# Take the Eggmoves from the new, updated pokemon file.
new_egg_moves = {}
new_lines = []

with open(new_pbs_pokemon, "r") as f:
	poke = ""
	
	for line in f:
		# print(line)
		line = line.replace("\r","")
		line = line.replace("\n","")
		
		if line.startswith("InternalName"):
			temp = line.replace(" ","")
			poke = temp.replace("InternalName=","")
		elif line.startswith("EggMoves"):
			temp = line.replace(" ","")
			new_egg_moves[poke] = temp.replace("EggMoves=","").split(",")
			merged = new_egg_moves[poke] + original_egg_moves[poke]
			merged = list(set(merged))
			merged.sort()
			line = "EggMoves = " + ",".join(merged)
			
		# Merge the two lines.
		new_lines.append(line)

# Write the resulting file:
with open(merged_pbs_pokemon, "w") as f:
	for line in new_lines:
		f.write(line + "\n")

print("Done")