#define MONKEY_SPEC_ATTACK_BITE_MISS_CHANCE 25

/datum/species/monkey
	name = "\improper Monkey"
	id = SPECIES_MONKEY
	external_organs = list(
		/obj/item/organ/external/tail/monkey = "Monkey",
	)
	mutanttongue = /obj/item/organ/internal/tongue/monkey
	mutantbrain = /obj/item/organ/internal/brain/primate
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	inherent_traits = list(
		TRAIT_GUN_NATURAL,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_SHIFTY_EYES, // NON-MODULE CHANGE: monkey are shifty
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
	)
	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/grown/banana
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)
	fire_overlay = "monkey"
	gib_anim = "gibbed-m"

	payday_modifier = 1.5
	ai_controlled_species = TRUE
	monkey_type = null

/datum/species/monkey/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	passtable_on(human_who_gained_species, SPECIES_TRAIT)
	human_who_gained_species.dna.add_mutation(/datum/mutation/human/race, MUT_NORMAL)
	human_who_gained_species.dna.activate_mutation(/datum/mutation/human/race)
	human_who_gained_species.AddElement(/datum/element/human_biter)

/datum/species/monkey/on_species_loss(mob/living/carbon/human/C)
	. = ..()
	passtable_off(C, SPECIES_TRAIT)
	C.dna.remove_mutation(/datum/mutation/human/race)
	C.RemoveElement(/datum/element/human_biter)

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/monkey)
	return get_sfx(SFX_SCREECH)

/datum/species/monkey/get_physical_attributes()
	return "Monkeys are slippery, can crawl into vents, and are more dextrous than humans.. but only when stealing things. \
		Natural monkeys cannot operate machinery or most tools with their paws, but unusually clever monkeys or those that were once something else can."

/datum/species/monkey/get_species_description()
	return "Monkeys are a type of primate that exist between humans and animals on the evolutionary chain. \
		Every year, on Monkey Day, Nanotrasen shows their respect for the little guys by allowing them to roam the station freely."

/datum/species/monkey/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station Thirteen. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up it? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Monkeys are reverted into normal humans upon being exposed to Mutadone.",
		),
	)

	return to_add

/datum/species/monkey/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add

/obj/item/organ/internal/brain/primate //Ook Ook
	name = "Primate Brain"
	desc = "This wad of meat is small, but has enlaged occipital lobes for spotting bananas."
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_PRIMITIVE) // No literacy or advanced tool usage.
	actions_types = list(/datum/action/item_action/organ_action/toggle_trip)
	/// Will this monkey stumble if they are crossed by a simple mob or a carbon in combat mode? Toggable by monkeys with clients, and is messed automatically set to true by monkey AI.
	var/tripping = TRUE

/datum/action/item_action/organ_action/toggle_trip
	name = "Toggle Tripping"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "lesser_form"
	background_icon_state = "bg_default_on"
	overlay_icon_state = "bg_default_border"

/datum/action/item_action/organ_action/toggle_trip/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/internal/brain/primate/monkey_brain = target
	if(monkey_brain.tripping)
		monkey_brain.tripping = FALSE
		background_icon_state = "bg_default"
		to_chat(monkey_brain.owner, span_notice("You will now avoid stumbling while colliding with people who are in combat mode."))
	else
		monkey_brain.tripping = TRUE
		background_icon_state = "bg_default_on"
		to_chat(monkey_brain.owner, span_notice("You will now stumble while while colliding with people who are in combat mode."))
	build_all_button_icons()

/obj/item/organ/internal/brain/primate/on_mob_insert(mob/living/carbon/primate)
	. = ..()
	RegisterSignal(primate, COMSIG_MOVABLE_CROSS, PROC_REF(on_crossed), TRUE)

/obj/item/organ/internal/brain/primate/on_mob_remove(mob/living/carbon/primate)
	. = ..()
	UnregisterSignal(primate, COMSIG_MOVABLE_CROSS)

/obj/item/organ/internal/brain/primate/proc/on_crossed(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(!tripping)
		return
	if(IS_DEAD_OR_INCAP(owner) || !isliving(crossed))
		return
	var/mob/living/in_the_way_mob = crossed
	if(iscarbon(in_the_way_mob) && !in_the_way_mob.combat_mode)
		return
	if(in_the_way_mob.pass_flags & PASSTABLE)
		return
	in_the_way_mob.knockOver(owner)

/obj/item/organ/internal/brain/primate/get_attacking_limb(mob/living/carbon/human/target)
	return owner.get_bodypart(BODY_ZONE_HEAD)

#undef MONKEY_SPEC_ATTACK_BITE_MISS_CHANCE

/datum/species/monkey/lizard
	name = "\improper Kobold"
	id = SPECIES_MONKEY_LIZARD
	examine_limb_id = SPECIES_LIZARD
	inherent_traits = list(
		// monke
		TRAIT_GUN_NATURAL,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_SHIFTY_EYES, // NON-MODULE CHANGE: monkey are shifty
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
		// unique
		TRAIT_MUTANT_COLORS,
		TRAIT_TACKLING_TAILED_DEFENDER,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	digitigrade_customization = DIGITIGRADE_FORCED
	mutant_bodyparts = list("legs" = DIGITIGRADE_LEGS)
	external_organs = list(
		/obj/item/organ/external/horns = "None",
		/obj/item/organ/external/frills = "None",
		/obj/item/organ/external/snout = "Round",
		/obj/item/organ/external/spines = "None",
		/obj/item/organ/external/tail/lizard = "Smooth",
	)
	mutanttongue = /datum/species/lizard::mutanttongue
	species_cookie = /datum/species/lizard::species_cookie
	meat = /datum/species/lizard::meat
	skinned_type = /datum/species/lizard::skinned_type
	knife_butcher_results = list(/datum/species/lizard::meat = 5, /datum/species/lizard::skinned_type = 1)
	species_language_holder = /datum/language_holder/lizard/ash/primative

	bodytemp_heat_damage_limit = /datum/species/lizard::bodytemp_heat_damage_limit
	bodytemp_cold_damage_limit = /datum/species/lizard::bodytemp_cold_damage_limit
	// Cold blooded
	temperature_normalization_speed = /datum/species/lizard::temperature_homeostasis_speed
	temperature_normalization_speed = /datum/species/lizard::temperature_normalization_speed

	ass_image = /datum/species/lizard::ass_image

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard/lizmonkey,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/lizmonkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/lizmonkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade,
	)

/datum/species/monkey/lizard/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
	)

/datum/species/monkey/lizard/get_laugh_sound(mob/living/carbon/human/lizard)
	return 'sound/voice/lizard/lizard_laugh1.ogg'

/obj/item/bodypart/arm/left/lizard/lizmonkey
	wound_resistance = -10
	unarmed_damage_low = 1
	unarmed_damage_high = 2
	unarmed_effectiveness = 0

/obj/item/bodypart/arm/left/lizard/lizmonkey/Initialize(mapload)
	. = ..()
	name = "kobold [plaintext_zone]"

/obj/item/bodypart/arm/right/lizard/lizmonkey
	wound_resistance = -10
	unarmed_damage_low = 1
	unarmed_damage_high = 2
	unarmed_effectiveness = 0

/obj/item/bodypart/arm/right/lizard/lizmonkey/Initialize(mapload)
	. = ..()
	name = "kobold [plaintext_zone]"

/obj/item/bodypart/chest/lizard/lizmonkey
	wound_resistance = -10

/obj/item/bodypart/chest/lizard/lizmonkey/Initialize(mapload)
	. = ..()
	name = "kobold [plaintext_zone]"

/obj/item/bodypart/head/lizard/lizmonkey
	wound_resistance = -10

/obj/item/bodypart/head/lizard/lizmonkey/Initialize(mapload)
	. = ..()
	name = "kobold [plaintext_zone]"
