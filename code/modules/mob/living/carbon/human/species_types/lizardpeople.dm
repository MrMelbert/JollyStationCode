/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "\improper Lizardperson"
	plural_form = "Lizardfolk"
	id = SPECIES_LIZARD
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TACKLING_TAILED_DEFENDER,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	mutant_bodyparts = list("body_markings" = "None", "legs" = "Normal Legs")
	external_organs = list(
		/obj/item/organ/external/horns = "None",
		/obj/item/organ/external/frills = "None",
		/obj/item/organ/external/snout = "Round",
		/obj/item/organ/external/spines = "None",
		/obj/item/organ/external/tail/lizard = "Smooth",
	)
	mutanttongue = /obj/item/organ/internal/tongue/lizard
	coldmod = 1.5
	heatmod = 0.67
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/meat/slab
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = /datum/blood_type/crew/lizard // NON-MODULE CHANGE
	inert_mutation = /datum/mutation/human/firebreath
	death_sound = 'sound/voice/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	digitigrade_customization = DIGITIGRADE_OPTIONAL

	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_normal = (BODYTEMP_NORMAL - 7.5)
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	ass_image = 'icons/ass/asslizard.png'

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

	monkey_type = /datum/species/monkey/lizard

/datum/species/lizard/randomize_features()
	var/list/features = ..()
	features["body_markings"] = pick(GLOB.body_markings_list)
	return features

/datum/species/lizard/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
	)

/datum/species/lizard/get_cough_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/voice/human/female_cough1.ogg',
			'sound/voice/human/female_cough2.ogg',
			'sound/voice/human/female_cough3.ogg',
			'sound/voice/human/female_cough4.ogg',
			'sound/voice/human/female_cough5.ogg',
			'sound/voice/human/female_cough6.ogg',
		)
	return pick(
		'sound/voice/human/male_cough1.ogg',
		'sound/voice/human/male_cough2.ogg',
		'sound/voice/human/male_cough3.ogg',
		'sound/voice/human/male_cough4.ogg',
		'sound/voice/human/male_cough5.ogg',
		'sound/voice/human/male_cough6.ogg',
	)


/datum/species/lizard/get_cry_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/voice/human/female_cry1.ogg',
			'sound/voice/human/female_cry2.ogg',
		)
	return pick(
		'sound/voice/human/male_cry1.ogg',
		'sound/voice/human/male_cry2.ogg',
		'sound/voice/human/male_cry3.ogg',
	)


/datum/species/lizard/get_sneeze_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return 'sound/voice/human/female_sneeze1.ogg'
	return 'sound/voice/human/male_sneeze1.ogg'

/datum/species/lizard/get_laugh_sound(mob/living/carbon/human/lizard)
	return 'sound/voice/lizard/lizard_laugh1.ogg'

/datum/species/lizard/get_physical_attributes()
	return "Lizardpeople can withstand slightly higher temperatures than most species, but they are very vulnerable to the cold \
		and can't regulate their body-temperature internally, making the vacuum of space extremely deadly to them."

/datum/species/lizard/get_species_description()
	return "The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."

/datum/species/lizard/get_species_lore()
	return list(
		"The face of conspiracy theory was changed forever the day mankind met the lizards.",

		"Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. \
		However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" \
		in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",

		"The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, \
		with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",

		"Lizard culture is inherently militaristic, though the influence the military has on lizard culture \
		begins to lessen the further colonies lie from their homeworld - \
		with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",

		"On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. \
		Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
	)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	examine_limb_id = SPECIES_LIZARD
	mutantlungs = /obj/item/organ/internal/lungs/lavaland
	mutantbrain = /obj/item/organ/internal/brain/primitive
	inherent_traits = list(
		TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION,
		TRAIT_MUTANT_COLORS,
		TRAIT_TACKLING_TAILED_DEFENDER,
		TRAIT_VIRUSIMMUNE,
	)
	species_language_holder = /datum/language_holder/lizard/ash
	digitigrade_customization = DIGITIGRADE_FORCED
	examine_limb_id = SPECIES_LIZARD
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/ashwalker,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/ashwalker,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/datum/species/lizard/ashwalker/get_physical_attributes()
	return "Ash Walkers are identical to lizardpeople in almost all aspects. \
		Unlike them, they're always digitigrade, they can breathe Lavaland's often noxious atmosphere and resist viruses. They are usually illiterate."

/*
Lizard subspecies: SILVER SCALED
*/
/datum/species/lizard/silverscale
	name = "Silver Scale"
	id = SPECIES_LIZARD_SILVER
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	inherent_traits = list(
		TRAIT_HOLY,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TACKLING_TAILED_DEFENDER,
		TRAIT_VIRUSIMMUNE,
		TRAIT_WINE_TASTER,
	)
	mutantlungs = null
	damage_modifier = 10 //very light silvery scales soften blows
	species_language_holder = /datum/language_holder/lizard/silver
	mutanttongue = /obj/item/organ/internal/tongue/lizard/silver
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	examine_limb_id = SPECIES_LIZARD
	///stored mutcolor for when we turn back off of a silverscale.
	var/old_mutcolor
	///stored horn color for when we turn back off of a silverscale.
	var/old_horncolor
	///stored eye color for when we turn back off of a silverscale.
	var/old_eye_color_left
	///See above
	var/old_eye_color_right

/datum/species/lizard/silverscale/get_physical_attributes()
	return "Silver Scales are to lizardpeople what angels are to humans. \
		Mostly identical, they are holy, don't breathe, don't get viruses, their hide cannot be pierced, love the taste of wine, \
		and their tongue allows them to turn into a statue, for some reason."

/datum/species/lizard/silverscale/on_species_gain(mob/living/carbon/human/new_silverscale, datum/species/old_species, pref_load)
	old_mutcolor = new_silverscale.dna.features["mcolor"]
	old_horncolor = new_silverscale.dna.features["lizard_horn_color"]
	old_eye_color_left = new_silverscale.eye_color_left
	old_eye_color_right = new_silverscale.eye_color_right
	new_silverscale.dna.features["mcolor"] = "#eeeeee"
	new_silverscale.dna.features["lizard_horn_color"] = "#eeeeee"
	new_silverscale.eye_color_left = "#0000a0"
	new_silverscale.eye_color_right = "#0000a0"
	. = ..()
	new_silverscale.add_filter("silver_glint", 2, list("type" = "outline", "color" = "#ffffff63", "size" = 2))

/datum/species/lizard/silverscale/on_species_loss(mob/living/carbon/human/was_silverscale, datum/species/new_species, pref_load)
	was_silverscale.dna.features["mcolor"] = old_mutcolor
	was_silverscale.dna.features["lizard_horn_color"] = old_horncolor
	was_silverscale.eye_color_left = old_eye_color_left
	was_silverscale.eye_color_right = old_eye_color_right
	was_silverscale.remove_filter("silver_glint")
	return ..()
