/// GLOB list of armwings sprites / options
GLOBAL_LIST_EMPTY(arm_wings_list)
/// GLOB list of other features (ears, tails)
GLOBAL_LIST_EMPTY(avian_ears_list)
// GLOBAL_LIST_EMPTY(tails_list_avian)

/datum/species/ornithid
	// the biggest bird
	name = "\improper Ornithid"
	plural_form = "Ornithids"
	id = SPECIES_ORNITHID
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS)
	inherent_traits = list(
		TRAIT_LIGHT_DRINKER,
		TRAIT_TACKLING_WINGED_ATTACKER,
	)
	use_skintones = TRUE
	mutanttongue = /obj/item/organ/internal/tongue/ornithid
	external_organs = list(
		/obj/item/organ/external/wings/functional/arm_wings = "Monochrome",
		/obj/item/organ/external/plumage = "Hermes"
	//
	//	/obj/item/organ/external/tail/avian = "[-TODO-]",
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ornithid, // NYI
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ornithid, // NYI
		BODY_ZONE_HEAD = /obj/item/bodypart/head/, // just because they are still *partially* human, or otherwise human resembling
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/,
	)
	payday_modifier = 0.75
	species_pain_mod = 1.20 // Fuck it, this will fill a niche that isn't implemented yet.
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	species_cookie = /obj/item/food/semki/healthy // humans get chocolate, lizards get meat. What do birds get? Seed.
	meat = /obj/item/food/meat/slab/chicken
	skinned_type = /obj/item/stack/sheet/animalhide/human
	toxic_food = SUGAR // chocolate is toxic to birds.
	disliked_food = DAIRY | CLOTH | GROSS // although these guys are human decendant, a holdover causes dairy to be a little screwy.
	liked_food = FRUIT | SEAFOOD | NUTS | BUGS // birds like dice(d) nuts. Also bugs.

	inert_mutation = /datum/mutation/human/dwarfism
	species_language_holder = /datum/language_holder/yangyu // doing this because yangyu is really just, mostly unused otherwise.

// defines limbs/bodyparts.

/obj/item/bodypart/arm/left/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'maplestation_modules/icons/mob/ornithid_parts_greyscale.dmi' // NYI! THIS IS A PLACEHOLDER BECAUSE OF MAPLE MODULARITY
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'


/obj/item/bodypart/arm/right/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'maplestation_modules/icons/mob/ornithid_parts_greyscale.dmi' // NYI! THIS IS A PLACEHOLDER BECAUSE OF MAPLE MODULARITY
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

// section for lore/perk descs
/datum/species/ornithid/get_species_lore()
	return list(
		"bird lore"
	)

/datum/species/ornithid/get_species_description()
	return "Ornithids are a collective group of various human descendant or otherwise resembling sentient avian beings." // i'll get to this later kek

/datum/species/ornithid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "dove",
			SPECIES_PERK_NAME = "Airborne",
			SPECIES_PERK_DESC = "Is it a bird? is it a plane? Of course its a bird you dumbass, \
				Ornithids are lightweight winged avians, and can, as a result, fly.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Wind Elemental Alignment",
			SPECIES_PERK_DESC = "|NYI| Naturally one with the skies, Ornithids enjoy higher proficiency with Wind magic. \
				However, despite their Human origins, they suffer a malus with Earth magic.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "feather",
			SPECIES_PERK_NAME = "Lightweights",
			SPECIES_PERK_DESC = "As a result of their reduced average weight, \
				Ornithids have a lower alcohol tolerance. Pansies.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "note-medical",
			SPECIES_PERK_NAME = "Hyper-Sensitive Nerves",
			SPECIES_PERK_DESC = "Ornithids have incredibly sensistive nerves compared to their human counterparts, \
				Taking 1.2x pain, 1.5x damage to their ears, and get stunned for 2x longer when flying.", // the 2x stun length only applies when flying, and is inherited from functional wings.
		),
	)
	return to_add

