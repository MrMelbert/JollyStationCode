/datum/preference/numeric/active_loadout
	savefile_key = "active_loadout"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	minimum = 1
	maximum = MAX_LOADOUTS

/datum/preference/numeric/active_loadout/create_default_value()
	return minimum

/datum/preference/numeric/active_loadout/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/loadout
	savefile_key = "loadout_list"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_LOADOUT
	can_randomize = FALSE
	// Loadout preference is an assoc list [item_path] = [loadout item information list]
	//
	// it may look something like
	// - list(/obj/item/glasses = list())
	// or
	// - list(/obj/item/plush/lizard = list("name" = "Tests-The-Loadout", "color" = "#FF0000"))

// Loadouts are applied with job equip code.
/datum/preference/loadout/apply_to_human(mob/living/carbon/human/target, value)
	return

// Default value is null - the loadout list is a lazylist
/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return null

/datum/preference/loadout/is_valid(value)
	return isnull(value) || islist(value)

// Sanitize on load to ensure no invalid paths from older saves get in
/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
	for(var/i in 1 to length(input))
		if(islist(input[i]))
			input[i] = sanitize_loadout_list(input[i])

	return input

/**
 * Removes all invalid paths from loadout lists.
 * This is a general sanitization for preference loading.
 *
 * Returns a list, or null if empty
 */
/datum/preference/loadout/proc/sanitize_loadout_list(list/passed_list) as /list
	var/list/sanitized_list
	for(var/path in passed_list)
		// Loading from json has each path in the list as a string that we need to convert back to typepath
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(!ispath(real_path, /obj/item))
			continue
		if(!istype(GLOB.all_loadout_datums[real_path], /datum/loadout_item))
			continue

		// Set into sanitize list using converted path key
		var/list/data = passed_list[path]
		LAZYSET(sanitized_list, real_path, LAZYLISTDUPLICATE(data))

	return sanitized_list

/datum/preferences/update_character(current_version, list/save_data)
	. = ..()
	if(current_version < 43.1)
		save_loadout(src, save_data?["loadout_list"])
