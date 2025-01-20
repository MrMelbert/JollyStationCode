// -- Modular deep skrell species --
/// GLOB list of head tentacle sprites / options
GLOBAL_LIST_EMPTY(deep_head_tentacles_list)

// The datum for deep_skrell.
/datum/species/deep_skrell
	name = "Deep Skrell"
	plural_form = "Deep Skrells"
	id = SPECIES_DEEP_SKRELL
	inherent_traits = list(TRAIT_MUTANT_COLORS, TRAIT_LIGHT_DRINKER, TRAIT_EMPATH, TRAIT_BADTOUCH, TRAIT_NIGHT_VISION, TRAIT_WEBBED_HANDS)
	external_organs = list(/obj/item/organ/external/head_tentacles = "Long")
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/skrell
	exotic_bloodtype = /datum/blood_type/crew/skrell
	species_pain_mod = 1.2


	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skrell,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skrell,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/deep_skrell,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skrell,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skrell,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/deep_skrell,
	)

	mutanteyes = /obj/item/organ/internal/eyes/deep_skrell
	mutanttongue = /obj/item/organ/internal/tongue/deep_skrell
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

/datum/species/deep_skrell/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.missing_eye_file = 'maplestation_modules/icons/mob/skrell_eyes.dmi'

/datum/species/deep_skrell/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.missing_eye_file = initial(C.missing_eye_file)
	return ..()

/datum/species/deep_skrell/get_species_description()
	return "deep_skrell are a semi-aquatic species hailing from tropical worlds."

/datum/species/deep_skrell/get_species_lore()
	return list("deep_skrell lore.")

/datum/species/deep_skrell/create_pref_unique_perks()
	var/list/perks = list()

	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "wine-bottle",
		SPECIES_PERK_NAME = "Light Drinkers",
		SPECIES_PERK_DESC = "skrell naturally don't get along with alcohol \
			and find themselves getting inebriated very easily.",
	))
	return perks

/datum/species/deep_skrell/create_pref_blood_perks()
	var/list/perks = list()

	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Exotic Blood",
		SPECIES_PERK_DESC = "The Skrell have a unique \"S\" type blood. Instead of \
			regaining blood from iron, they regenerate it from copper.",
	))

	return perks

// Preset deep_skrell species
/mob/living/carbon/human/species/deep_skrell
	race = /datum/species/deep_skrell

// Organ for deep_skrell head tentacles.
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
	if(istype(human.head) && (human.head.flags_inv))
		return FALSE
	if(istype(human.wear_mask) && (human.wear_mask.flags_inv))
		return FALSE
	var/obj/item/bodypart/head/our_head = human.get_bodypart(BODY_ZONE_HEAD)
	if(!IS_ORGANIC_LIMB(our_head))
		return FALSE
	return TRUE

/datum/bodypart_overlay/mutant/head_tentacles/get_global_feature_list()
	return GLOB.head_tentacles_list

/datum/species/human/deep_skrell/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(istype(chem, /datum/reagent/toxin/carpotoxin))
		var/datum/reagent/toxin/carpotoxin/fish = chem
		fish.toxpwr = 0


/obj/item/bodypart/arm/left/skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.5
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/arm/right/skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.5
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/head/deep_skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.5
	is_dimorphic = 0
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'
	head_flags = HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/leg/left/skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.5
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/leg/right/skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.5
	icon_greyscale = 'maplestation_modules/icons/mob/skrell_parts_greyscale.dmi'

/obj/item/bodypart/chest/deep_skrell
	limb_id = SPECIES_DEEP_SKRELL
	brute_modifier = 0.8
	burn_modifier = 1.
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

/obj/item/organ/internal/eyes/deep_skrell
	name = "Deep Skrellian eyes"
	desc = "The four large eyes of a Deep Skrell."
	icon_state = "eyes_deep"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	eye_overlay_file = 'maplestation_modules/icons/mob/skrell_eyes.dmi'
	eye_icon_state = "deep_eyes"
	visual = TRUE
	zone = BODY_ZONE_PRECISE_EYES
	slot = ORGAN_SLOT_EYES
	flash_protect = FLASH_PROTECTION_SENSITIVE

/datum/species/deep_skrell/on_species_gain(mob/living/carbon/new_deep_skrell, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = new_deep_skrell.get_item_by_slot(ITEM_SLOT_BACK)
	if(!istype(bag, /obj/item/storage/back_tentacles))
		if(new_deep_skrell.dropItemToGround(bag)) //returns TRUE even if its null
			new_deep_skrell.equip_to_slot_or_del(new /obj/item/storage/back_tentacles(new_deep_skrell), ITEM_SLOT_BACK)
/// i stole snail code

/datum/species/deep_skrell/on_species_loss(mob/living/carbon/former_deep_skrell, datum/species/new_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = former_deep_skrell.get_item_by_slot(ITEM_SLOT_BACK)
	if(istype(bag, /obj/item/storage/back_tentacles))
		bag.emptyStorage()
		former_deep_skrell.temporarilyRemoveItemFromInventory(bag, TRUE)
		qdel(bag)

/obj/item/storage/back_tentacles
	name = "Back tentacles"
	desc = "Your back tentacles! You're able to hold items with them!"
	icon_state = "back_tentacles"
	icon = 'maplestation_modules/icons/mob/skrell_organs.dmi'
	///worn_icon = 'maplestation_modules/icons/mob/deep_skrell.dmi'
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	color =
	storage_type = /datum/storage/backpack

/obj/item/storage/back_tentacles/visual_equipped(mob/living/carbon/human/user, slot)


/obj/item/storage/back_tentacles/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_BACKPACK_REPLACEMENT)

/datum/species/deep_skrell/proc/on_death(mob/living/died, gibbed)
	SIGNAL_HANDLER
	died.drop_all_contents()

/datum/quirk/webbedhands
	name = "Webbed Hands"
	desc = "Your fingers are connected by a waterproof webbing. Useful for swimming! Less so for wearing gloves..."
	value = -6
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	gain_text = span_danger("Your fingers have grown webbing!")
	lose_text = span_notice("The webbing has retracted back into your hands.")
	medical_record_text = "Patient has webbed hands."
	mob_trait = WEBBED_HANDS
	hardcore_value = 4
	var/datum/weakref/gloves

/datum/quirk/gloves/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/gloves/equipped_gloves = human_holder.back
	if(istype(equipped_gloves))
		quirk_holder.add_mood_event("webbed_hands", /datum/mood_event/webbed_hands)
		RegisterSignal(human_holder.back, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequipped_gloves))
	else
		RegisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/quirk/webbedhands/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM)

	var/obj/item/clothing/equipped_gloves = gloves?.resolve()
	if(equipped_gloves)
		UnregisterSignal(equipped_gloves, COMSIG_ITEM_POST_UNEQUIP)
		quirk_holder.clear_mood_event("webbed_hands")

/// Signal handler for when the quirk_holder equips an item. If it's gloves, adds the webbed_hands mood event.
/datum/quirk/badback/proc/on_equipped_item(mob/living/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS) || !istype(equipped_item, /obj/item/clothing/gloves))
		return

	quirk_holder.add_mood_event("webbed_hands", /datum/mood_event/webbed_hands)
	RegisterSignal(equipped_item, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequipped_backpack))
	UnregisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM)
	gloves = WEAKREF(equipped_item)

/// Signal handler for when the quirk_holder unequips an equipped gloves. Removes the webbed_hands mood event.
/datum/quirk/badback/proc/on_unequipped_gloves(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_ITEM_POST_UNEQUIP)
	quirk_holder.clear_mood_event("webbed_hands")
	gloves = null
	RegisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/mood_event/webbed_hands
	description = "Gloves compress the webbing between your fingers painfully!"
	mood_change = -13

