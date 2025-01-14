/datum/species/werewolf
	name = "werewolf"
	id = SPECIES_WEREWOLF
	inherent_traits = list(
		TRAIT_USES_SKINTONES,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_AUGMENTS,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_PUSHIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_PRIMITIVE,
		TRAIT_CAN_STRIP,
		TRAIT_CHUNKYFINGERS
	)
	mutanttongue = /obj/item/organ/internal/tongue/werewolf
	mutantears = /obj/item/organ/internal/ears/cat/werewolf
	mutanteyes = /obj/item/organ/internal/eyes/werewolf
	mutantbrain = /obj/item/organ/internal/brain/werewolf
	mutantliver = /obj/item/organ/internal/liver/werewolf
	mutantheart = /obj/item/organ/internal/heart/werewolf
	external_organs = list(
		/obj/item/organ/external/tail/cat = "Cat", // todo: add custom wolf tail
	)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/werewolf,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/werewolf,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/werewolf,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/werewolf,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/werewolf,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/werewolf,
	)

/obj/item/organ/internal/brain/werewolf
	name = "werewolf brain"
	desc = "a strange mixture of a human and wolf brain"
	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_PRIMITIVE, TRAIT_CAN_STRIP) // you may be a raging monster, but you still retain traits of your normal self
	// also you can just inject clever mutation and get the first two traits anyways *shrug

/obj/item/organ/internal/brain/werewolf/get_attacking_limb(mob/living/carbon/human/target)
	if(target.body_position == LYING_DOWN)
		return owner.get_bodypart(BODY_ZONE_HEAD) // performs a "maul" attack which does increased melee damage
	return ..()

/datum/species/werewolf/prepare_human_for_preview(mob/living/carbon/human/human)
	human.set_haircolor("#bb9966", update = FALSE) // brown
	human.set_hairstyle("Business Hair", update = TRUE)

/* this shouldn't be a roundstart/base species players can choose, and is instead obtainable mid round
feel free to update this section if any of the three below can be accessed out of character set up. */
/datum/species/werewolf/get_species_description()
	return "N/A"

/datum/species/human/get_species_lore()
	return list(
		"N/A",
	)

/datum/species/werewolf/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Werewolves are monstrous humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your larger form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Werewolves are more sensitive to loud sounds, such as flashbangs.",
		))

	return to_add
