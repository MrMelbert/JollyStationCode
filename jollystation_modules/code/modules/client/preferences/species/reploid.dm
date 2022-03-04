/datum/preference/choiced/reploid_limbs
	savefile_key = "reploid_limbs"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE

/datum/preference/choiced/reploid_limbs/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/reploid)

/datum/preference/choiced/reploid_limbs/deserialize(input, datum/preferences/preferences)
	return sanitize_inlist(input, get_choices_serialized(), LIMBS_HUMAN)

/datum/preference/choiced/reploid_limbs/create_default_value()
	return LIMBS_HUMAN

/datum/preference/choiced/reploid_limbs/init_possible_values()
	return assoc_to_keys(GLOB.reploid_limb_id_list) //Located in jollystation_modules/_globalvars/lists/reploid.dm

/datum/preference/choiced/reploid_limbs/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna.species, /datum/species/reploid))
		CRASH("applying reploid limb pref to a non-reploid!")

	var/datum/species/reploid/target_species = target.dna.species

	if(value == LIMBS_IPC)
		target_species.ipc_screen = TRUE //If we're an IPC, we're taking the screen
		target_species.ipc_limbs = TRUE
		target.dna.species.use_skintones = FALSE
		target.dna.species.species_traits -= NOEYESPRITES
		target.dna.species.species_traits -= FACEHAIR
		target.dna.species.species_traits -= HAIR
		target.dna.species.species_traits -= LIPS
	else
		target_species.ipc_screen = FALSE
		target_species.ipc_limbs = FALSE
		target.dna.species.species_traits |= NOEYESPRITES
		target.dna.species.species_traits |= FACEHAIR
		target.dna.species.species_traits |= HAIR
		target.dna.species.species_traits |= LIPS
		target_species.limbs_id = value //IPC limbs are overriden by another value later on

/datum/preference/choiced/reploid_ipc_screen
	savefile_key = "reploid_ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS
	can_randomize = FALSE

/datum/preference/choiced/reploid_ipc_screen/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	if (ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/reploid) && (preferences.read_preference(/datum/preference/choiced/reploid_limbs) == LIMBS_IPC))
		return TRUE

/datum/preference/choiced/reploid_ipc_screen/init_possible_values()
	return assoc_to_keys(GLOB.ipc_screen_list) //Located in jollystation_modules/_globalvars/lists/reploid.dm

/datum/preference/choiced/reploid_ipc_screen/create_default_value()
	var/datum/sprite_accessory/ipc_screen = /datum/sprite_accessory/ipc_screen/blank
	return initial(ipc_screen.name)

/datum/preference/choiced/reploid_ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/species/reploid/target_species = target.dna.species
	if (target_species.ipc_screen == TRUE)
		target.dna.features["ipc_screen"] = value

/datum/preference/choiced/reploid_antenna
	savefile_key = "reploid_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS
	can_randomize = TRUE
	relevant_mutant_bodypart = "reploid_antenna"

/datum/preference/choiced/reploid_antenna/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/reploid)

/datum/preference/choiced/reploid_antenna/init_possible_values()
	return assoc_to_keys(GLOB.reploid_antenna_list) //Located in jollystation_modules/_globalvars/lists/reploid.dm

/datum/preference/choiced/reploid_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["reploid_antenna"] = value

/datum/preference/toggle/reploid_skintones
	savefile_key = "reploid_skintones"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	default_value = TRUE

/datum/preference/toggle/reploid_skintones/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	if (ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/reploid) && (preferences.read_preference(/datum/preference/choiced/reploid_limbs) == LIMBS_HUMAN || preferences.read_preference(/datum/preference/choiced/reploid_limbs) == LIMBS_REPLOID))
		return TRUE

/datum/preference/toggle/reploid_skintones/apply_to_human(mob/living/carbon/human/target, value)
	if(!isreploid(target))
		return

	if(value)
		target.dna.species.species_traits -= MUTCOLORS
		target.dna.species.use_skintones = TRUE
		target.update_body_parts()
	else
		target.dna.species.species_traits |= MUTCOLORS
		target.dna.species.use_skintones = FALSE
		target.update_body_parts()

/datum/preference/choiced/reploid_ipc_limbs
	savefile_key = "reploid_ipc_limbs"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS
	can_randomize = FALSE

/datum/preference/choiced/reploid_ipc_limbs/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	if (ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/reploid) && (preferences.read_preference(/datum/preference/choiced/reploid_limbs) == LIMBS_IPC))
		return TRUE

/datum/preference/choiced/reploid_ipc_limbs/init_possible_values()
	return assoc_to_keys(GLOB.reploid_limbs_ipc_list) //Located in jollystation_modules/_globalvars/lists/reploid.dm

/datum/preference/choiced/reploid_ipc_limbs/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/species/reploid/target_species = target.dna.species
	if(!target_species.ipc_limbs)
		return

	var/datum/reploid_limb/limb_type = GLOB.reploid_limbs_ipc_list[value]
	limb_type.apply_limb_id(target_species)
