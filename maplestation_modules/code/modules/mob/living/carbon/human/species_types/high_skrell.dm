// -- Modular high skrell species --
/// GLOB list of head tentacle sprites / options
GLOBAL_LIST_EMPTY(head_tentacles_list)

// The datum for high_skrell.
/datum/species/high_skrell
	name = "High Skrell"
	plural_form = "High Skrells"
	id = SPECIES_HIGH_SKRELL
	inherent_traits = list(TRAIT_MUTANT_COLORS, TRAIT_LIGHT_DRINKER, TRAIT_EMPATH, TRAIT_BADTOUCH, TRAIT_NIGHT_VISION, TRAIT_SNOB)
	external_organs = list(/obj/item/organ/external/head_tentacles = "Long")
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/skrell
	exotic_bloodtype = /datum/blood_type/crew/skrell
	species_pain_mod = 1.25


	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skrell,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skrell,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/high_skrell,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skrell,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skrell,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/high_skrell,
	)

	mutanteyes = /obj/item/organ/internal/eyes/high_skrell
	mutanttongue = /obj/item/organ/internal/tongue/high_skrell
	mutantbrain = /obj/item/organ/internal/brain/skrell
	mutantlungs = /obj/item/organ/internal/lungs/skrell
	mutantheart = /obj/item/organ/internal/heart/skrell
	mutantliver = /obj/item/organ/internal/liver/skrell
	mutantstomach = /obj/item/organ/internal/stomach/skrell
	mutantears = /obj/item/organ/internal/ears/skrell

/datum/species/skrell/get_species_speech_sounds(sound_type)
	switch(sound_type)
		if(SOUND_QUESTION)
			return string_assoc_list(list('maplestation_modules/sound/voice/huff_ask.ogg' = 120))
		if(SOUND_EXCLAMATION)
			return string_assoc_list(list('maplestation_modules/sound/voice/huff_exclaim.ogg' = 120))
		else
			return string_assoc_list(list('maplestation_modules/sound/voice/huff.ogg' = 120))

/datum/species/high_skrell/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.missing_eye_file = 'maplestation_modules/icons/mob/skrell_eyes.dmi'

/datum/species/high_skrell/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.missing_eye_file = initial(C.missing_eye_file)
	return ..()

/datum/species/high_skrell/get_species_description()
	return "high_skrell are a semi-aquatic species hailing from tropical worlds."

/datum/species/high_skrell/get_species_lore()
	return list("high_skrell lore.")

/datum/species/high_skrell/create_pref_unique_perks()
	var/list/perks = list()

	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "wine-bottle",
		SPECIES_PERK_NAME = "Light Drinkers",
		SPECIES_PERK_DESC = "skrell naturally don't get along with alcohol \
			and find themselves getting inebriated very easily.",
	))
	return perks

/datum/species/high_skrell/create_pref_blood_perks()
	var/list/perks = list()

	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Exotic Blood",
		SPECIES_PERK_DESC = "The Skrell have a unique \"S\" type blood. Instead of \
			regaining blood from iron, they regenerate it from copper.",
	))

	return perks

/datum/species/high_skrell/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = COLOR_GRAY
	human.update_body(is_creating = TRUE)

// Preset high_skrell species
/mob/living/carbon/human/species/high_skrell
	race = /datum/species/high_skrell

// Organ for high_skrell head tentacles.
/obj/item/organ/external/head_tentacles
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HEAD_TENTACLES
	dna_block = DNA_HEAD_TENTACLES_BLOCK
	preference = "feature_head_tentacles"
	bodypart_overlay = /datum/bodypart_overlay/mutant/head_tentacles

/datum/bodypart_overlay/mutant/head_tentacles
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT
	feature_key = "head_tentacles"

/datum/bodypart_overlay/mutant/head_tentacles/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(istype(human.head) && (human.head.flags_inv & HIDEHAIR))
		return FALSE
	if(istype(human.wear_mask) && (human.wear_mask.flags_inv & HIDEHAIR))
		return FALSE
	var/obj/item/bodypart/head/our_head = human.get_bodypart(BODY_ZONE_HEAD)
	if(!IS_ORGANIC_LIMB(our_head))
		return FALSE
	return TRUE

/datum/bodypart_overlay/mutant/head_tentacles/get_global_feature_list()
	return GLOB.head_tentacles_list

/obj/item/bodypart/arm/left/skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/arm/right/skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/head/high_skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	is_dimorphic = 0
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'
	head_flags = HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/leg/left/skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/leg/right/skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/chest/high_skrell
	limb_id = SPECIES_HIGH_SKRELL
	brute_modifier = 1.5
	burn_modifier = 0.8
	is_dimorphic = 0
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/organ/internal/brain/Skrell/on_mob_insert(mob/living/carbon/organ_owner, special)
	.=..()
	if(ishuman(organ_owner))
		return


	var/mob/living/carbon/human/human_owner = owner
	if (organ_owner.mob_mood)
		organ_owner.mob_mood.mood_modifier += 0.75

/obj/item/organ/internal/brain/Skrell/on_mob_remove(mob/living/carbon/organ_owner, special)
	.=..()
	if(ishuman(organ_owner) || QDELETED (organ_owner))
		return


	if (organ_owner.mob_mood)
		organ_owner.mob_mood.mood_modifier -= 0.75

/obj/item/organ/internal/liver/Skrell/on_mob_insert(mob/living/carbon/organ_owner, special)
	.=..()
	if(ishuman(organ_owner))
		return


	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.tox_mod *= 1.75

/obj/item/organ/internal/liver/Skrell/on_mob_remove(mob/living/carbon/organ_owner, special)
	.=..()
	if(ishuman(organ_owner) || QDELETED (organ_owner))
		return


	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.tox_mod *= 0.75

/obj/item/organ/internal/heart/skrell
	name = "Skrellian heart"
	desc = "A blue heart able to filter the copper based blood of the Skrell."
	icon_state = "heart-on"
	base_icon_state = "heart"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

/obj/item/organ/internal/lungs/skrell

	name = "Skrellian lungs"
	desc = "The lungs of a Skrell, they still have the gills attached."
	icon_state = "lungs"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS

/obj/item/organ/internal/liver/skrell
	name = "Skrellian liver"
	desc = "The source for the Skrell's weakness to alcohol."
	icon_state = "liver"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER

/obj/item/organ/internal/stomach/skrell
	name = "Skrellian stomach"
	desc = "A blue stomach, gross!"
	icon_state = "stomach"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH

/obj/item/organ/internal/brain/skrell
	name = "Skrellian brain"
	desc = "The psionic brain of a Skrell."
	icon_state = "brain2"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = TRUE
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN

/obj/item/organ/internal/ears/skrell
	name = "Skrellian ears"
	desc = "Fish ears!"
	icon_state = "ears"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	visual = FALSE
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS

/obj/item/organ/internal/eyes/high_skrell
	name = "High Skrellian eyes"
	desc = "The large eyes of a High Skrell."
	icon_state = "eyes_high"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	eye_overlay_file = 'maplestation_modules/icons/mob/skrell_eyes.dmi'
	eye_icon_state = "high_eyes"
	eye_color_left = ""
	eye_color_right = ""
	zone = BODY_ZONE_PRECISE_EYES
	slot = ORGAN_SLOT_EYES
