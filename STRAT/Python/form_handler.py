# import scpokemon


	


def manual_form_additions(all_pokemons, all_forms):
	all_forms["GROUDON_1"].required_item = "REDORB"
	all_forms["GROUDON_1"].unmega = 0
	
	all_forms["KYOGRE_1"].required_item = "BLUEORB"
	all_forms["KYOGRE_1"].unmega = 0
	
	all_forms["GIRATINA_1"].required_item = "GRISEOUSORB"
	
	all_forms["ROTOM_1"].moves.append("OVERHEAT")
	all_forms["ROTOM_2"].moves.append("HYDROPUMP")
	all_forms["ROTOM_3"].moves.append("BLIZZARD")
	all_forms["ROTOM_4"].moves.append("AIRSLASH")
	all_forms["ROTOM_5"].moves.append("LEAFSTORM")
	
	all_forms["ARCEUS_1"].required_item = "FISTPLATE"
	all_forms["ARCEUS_2"].required_item = "SKYPLATE"
	all_forms["ARCEUS_3"].required_item = "TOXICPLATE"
	all_forms["ARCEUS_4"].required_item = "EARTHPLATE"
	all_forms["ARCEUS_5"].required_item = "STONEPLATE"
	all_forms["ARCEUS_6"].required_item = "INSECTPLATE"
	all_forms["ARCEUS_7"].required_item = "SPOOKYPLATE"
	all_forms["ARCEUS_8"].required_item = "IRONPLATE"
	all_forms["ARCEUS_10"].required_item = "FLAMEPLATE"
	all_forms["ARCEUS_11"].required_item = "SPLASHPLATE"
	all_forms["ARCEUS_12"].required_item = "MEADOWPLATE"
	all_forms["ARCEUS_13"].required_item = "ZAPPLATE"
	all_forms["ARCEUS_14"].required_item = "MINDPLATE"
	all_forms["ARCEUS_15"].required_item = "ICICLEPLATE"
	all_forms["ARCEUS_16"].required_item = "DRACOPLATE"
	all_forms["ARCEUS_17"].required_item = "DREADPLATE"
	all_forms["ARCEUS_18"].required_item = "PIXIEPLATE"
	
	all_forms["GRENINJA_2"].required_ability = "0"
	all_forms["GRENINJA_2"].unmega = 1
	
	all_forms["ZYGARDE_2"].requireAbility("POWERCONSTRUCT")
	all_forms["ZYGARDE_2"].unmega = 0
	
	all_forms["SILVALLY_1"].required_item = "FIGHTINGMEMORY"
	all_forms["SILVALLY_2"].required_item = "FLYINGMEMORY"
	all_forms["SILVALLY_3"].required_item = "POISONMEMORY"
	all_forms["SILVALLY_4"].required_item = "GROUNDMEMORY"
	all_forms["SILVALLY_5"].required_item = "ROCKMEMORY"
	all_forms["SILVALLY_6"].required_item = "BUGMEMORY"
	all_forms["SILVALLY_7"].required_item = "GHOSTMEMORY"
	all_forms["SILVALLY_8"].required_item = "STEELMEMORY"
	all_forms["SILVALLY_10"].required_item = "FIREMEMORY"
	all_forms["SILVALLY_11"].required_item = "WATERMEMORY"
	all_forms["SILVALLY_12"].required_item = "GRASSMEMORY"
	all_forms["SILVALLY_13"].required_item = "ELECTRICMEMORY"
	all_forms["SILVALLY_14"].required_item = "PSYCHICMEMORY"
	all_forms["SILVALLY_15"].required_item = "ICEMEMORY"
	all_forms["SILVALLY_16"].required_item = "DRAGONMEMORY"
	all_forms["SILVALLY_17"].required_item = "DARKMEMORY"
	all_forms["SILVALLY_18"].required_item = "FAIRYMEMORY"
	
	all_forms["NECROZMA_3"].required_move = "ULTRABURST"
	all_forms["NECROZMA_3"].unmega = 0

	all_forms["ZACIAN_1"].required_item = "RUSTEDSWORD"
	all_forms["ZAMAZENTA_1"].required_item = "RUSTEDSHIELD"
	
def rectify_moves(all_pokemons, all_forms):
	if "HEATWAVE" in all_forms["PIDGEOT_4"].moves:
		all_forms["PIDGEOT_4"].moves.remove("HEATWAVE")
	if "HEATWAVE" in all_forms["PIDGEOT_5"].moves:
		all_forms["PIDGEOT_5"].moves.remove("HEATWAVE")
	
	all_forms["PIDGEOT_5"].moves.append("BLIZZARD")
	
	if "PURSUIT" in all_forms["FEAROW_1"].moves:
		all_forms["FEAROW_1"].moves.remove("PURSUIT")
	
	all_pokemons["WISHIWASHI"] = all_forms["WISHIWASHI_1"]
	all_pokemons["WISHIWASHI"].form = 0
	all_forms.pop("WISHIWASHI_1", None)
	
	all_pokemons["MINIOR"] = all_forms["MINIOR_7"]
	all_pokemons["MINIOR"].form = 0
	for i in range(7, 14):
		all_forms.pop("MINIOR_" + str(i), None)
	
	all_forms["ZACIAN_1"].moves.append("BEHEMOTHBLADE")
	all_forms["ZAMAZENTA_1"].moves.append("BEHEMOTHBASH")


FORBIDDENFORMS = ["DARMANITAN_1", 
				"DARMANITAN_3", 
				"MELOETTA_1", 
				"GRENINJA_1", 
				"AEGISLASH_1", 
				"KYUREM_3",
				"CASTFORM_1",
				"CASTFORM_2",
				"CASTFORM_3",
				"CASTFORM_4",
				"CASTFORM_5",
				"KYUREM_4",
				# "WISHIWASHI_1", 
				"ARCEUS_9", 
				"SILVALLY_9", 
				"MINIOR_1", 
				"MINIOR_2", 
				"MINIOR_3", 
				"MINIOR_4", 
				"MINIOR_5", 
				"MINIOR_6", 
				"MIMIKYU_1", 
				"CRAMORANT_1", 
				"CRAMORANT_2", 
				"EISCUE_1", 
				"MORPEKO_1", 
				"ZYGARDE_3",
				"NECROZMA_4"]



FORMS_WITH_DIFFERENT_MOVES = ["RAICHU_1", "SANDSHREW_1", "SANDSLASH_1", "VULPIX_1", "NINETALES_1", "DIGLETT_1", "DUGTRIO_1", "MEOWTH_1", "MEOWTH_2", "PERSIAN_1", "GEODUDE_1", "GRAVELER_1", "GOLEM_1", "PONYTA_1", "RAPIDASH_1", "SLOWPOKE_1", "SLOWBRO_1", "FARFETCHD_1", "GRIMER_1", "MUK_1", "EXEGGUTOR_1", "MAROWAK_1", "WEEZING_1", "ARTICUNO_1", "ZAPDOS_1", "MOLTRES_1", "SLOWKING_1", "CORSOLA_1", "ZIGZAGOON_1", "LINOONE_1"]




def manual_tm_additions(all_tms, all_tms_transposed):
	wanted = ["STOREDPOWER"]
	unwanted = ["HURRICANE"]
	replace_tms("BUTTERFREE", "BUTTERFREE_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["DAZZLINGGLEAM", "MOONLIGHT"]
	unwanted = ["HURRICANE", "ROOST"]
	replace_tms("BUTTERFREE", "BUTTERFREE_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("BUTTERFREE", "BUTTERFREE_3", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("BUTTERFREE", "BUTTERFREE_4", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("BEEDRILL", "BEEDRILL_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("PIDGEOT", "PIDGEOT_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["BLIZZARD"]
	unwanted = ["HEATWAVE"]
	replace_tms("PIDGEOT", "PIDGEOT_4", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["POISONJAB", "TOXICSPIKES"]
	unwanted = ["ICEBEAM", "BLIZZARD", "THUNDER" , "THUNDERBOLT"]
	replace_tms("RATTATA", "RATTATA_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("RATICATE", "RATICATE_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("ARBOK", "ARBOK_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["HYPERVOICE"]
	unwanted = []
	replace_tms("RAICHU", "RAICHU_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("NIDOQUEEN", "NIDOQUEEN_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("NIDOKING", "NIDOKING_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["DRAGONDANCE"]
	unwanted = []
	replace_tms("NIDOQUEEN", "NIDOQUEEN_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("NIDOKING", "NIDOKING_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("NIDOQUEEN", "NIDOQUEEN_3", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("NIDOKING", "NIDOKING_3", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("NINETALES", "NINETALES_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("NINETALES", "NINETALES_3", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("JIGGLYPUFF", "JIGGLYPUFF_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("JIGGLYPUFF", "JIGGLYPUFF_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("WIGGLYTUFF", "WIGGLYTUFF_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("WIGGLYTUFF", "WIGGLYTUFF_2", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["NASTYPLOT"]
	unwanted = ["DOUBLEEDGE"]
	replace_tms("WIGGLYTUFF", "WIGGLYTUFF_3", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("BUTTERFREE", "BUTTERFREE_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["BITE", "CRUNCH"]
	unwanted = []
	replace_tms("ZUBAT", "ZUBAT_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("GOLBAT", "GOLBAT_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("CROBAT", "CROBAT_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("GOLDUCK", "GOLDUCK_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("PONYTA", "PONYTA_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("PONYTA", "PONYTA_3", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("PONYTA", "PONYTA_4", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("RAPIDASH", "RAPIDASH_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("RAPIDASH", "RAPIDASH_3", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("RAPIDASH", "RAPIDASH_4", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("GENGAR", "GENGAR_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["HEATCRASH"]
	unwanted = []
	replace_tms("ONIX", "ONIX_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("ONIX", "ONIX_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MAROWAK", "MAROWAK_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("CHANSEY", "CHANSEY_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = []
	unwanted = []
	replace_tms("BLISSEY", "BLISSEY_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MRMIME", "MRMIME_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("GYARADOS", "GYARADOS_2", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("GYARADOS", "GYARADOS_4", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("GYARADOS", "GYARADOS_6", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("GYARADOS", "GYARADOS_8", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("LAPRAS", "LAPRAS_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("LAPRAS", "LAPRAS_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("AERODACTYL", "AERODACTYL_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("FURRET", "FURRET_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("NOCTOWL", "NOCTOWL_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("LEDIAN", "LEDIAN_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("ARIADOS", "ARIADOS_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["DARKPULSE", "KNOCKOFF"]
	unwanted = ["DAZZLINGGLEAM", "MOONBLAST", "PLAYROUGH"]
	replace_tms("BELLOSSOM", "BELLOSSOM_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MARILL", "MARILL_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("AZUMARILL", "AZUMARILL_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("JUMPLUFF", "JUMPLUFF_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["DRAGONDANCE", "DRACOMETEOR", "OUTRAGE", "DRAGONHAMMER"]
	unwanted = ["BODYSLAM", "DOUBLEEDGE"]
	replace_tms("DUNSPARCE", "DUNSPARCE_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["DRAGONDANCE", "DRACOMETEOR", "OUTRAGE", "DRAGONHAMMER"]
	unwanted = []
	replace_tms("DUNSPARCE", "DUNSPARCE_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("SNUBBULL", "SNUBBULL_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("GRANBULL", "GRANBULL_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("KINGDRA", "KINGDRA_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MASQUERAIN", "MASQUERAIN_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("SLAKING", "SLAKING_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("SKITTY", "SKITTY_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("DELCATTY", "DELCATTY_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("VOLBEAT", "VOLBEAT_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("ILLUMISE", "ILLUMISE_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("ROSELIA", "ROSELIA_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("ROSERADE", "ROSERADE_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["LEECHLIFE", "XSCISSOR"]
	unwanted = ["FIREBLAST", "FIREPUNCH", "FLAMETHROWER", "HEATWAVE", "SCORCHINGSANDS"]
	replace_tms("VIBRAVA", "VIBRAVA_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("FLYGON", "FLYGON_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("ALTARIA", "ALTARIA_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("SEVIPER", "SEVIPER_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MILOTIC", "MILOTIC_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["DRACOMETEOR", "DRAGONRUSH", "DRAGONHAMMER", "DRAGONPULSE"]
	unwanted = ["AIRSLASH", "FLY"]
	replace_tms("TROPIUS", "TROPIUS_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("GLALIE", "GLALIE_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("LUVDISC", "LUVDISC_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("RAMPARDOS", "RAMPARDOS_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("DRAPION", "DRAPION_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("PURRLOIN", "PURRLOIN_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("LIEPARD", "LIEPARD_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("MUSHARNA", "MUSHARNA_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("AUDINO", "AUDINO_2", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = ["PSYCHIC", "PSYSHOCK", "DAZZLINGGLEAM"]
	unwanted = []
	replace_tms("LILLIGANT", "LILLIGANT_1", wanted, unwanted, all_tms, all_tms_transposed)
	wanted = ["SHADOWBALL"]
	unwanted = ["DAZZLINGGLEAM"]
	replace_tms("LILLIGANT_1", "LILLIGANT", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("ARCHEN", "ARCHEN_1", wanted, unwanted, all_tms, all_tms_transposed)
	replace_tms("ARCHEOPS", "ARCHEOPS_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	wanted = []
	unwanted = []
	replace_tms("BRAVIARY", "BRAVIARY_1", wanted, unwanted, all_tms, all_tms_transposed)
	
	






def replace_tms(source_pokemon, target_form, wanted_tms, unwanted_tms, all_tms, all_tms_transposed):
	# if target_form not in all_tms_transposed:
	all_tms_transposed[target_form] = [] 
	
	# Copy common TMs
	for tm in all_tms_transposed[source_pokemon]:
		if not tm in unwanted_tms:
			all_tms_transposed[target_form].append(tm)
			all_tms[tm].append(target_form)
	
	# Add specific TMs 
	for tm in wanted_tms:
		if tm in all_tms:
			all_tms_transposed[target_form].append(tm)
			all_tms[tm].append(target_form)





# if __name__ == "__main__":
	
	# all_forms = load_all_forms()
	
	# print(all_forms[50])