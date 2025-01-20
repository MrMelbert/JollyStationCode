// -- Language preference and UI.

// These defines are used in the UI be careful updating them.
#define ADD_SPOKEN_LANGUAGE "Add spoken language"
#define ADD_UNDERSTOOD_LANGUAGE "Add understood language"
#define REMOVE_SPOKEN_LANGUAGE "Remove spoken language"
#define REMOVE_UNDERSTOOD_LANGUAGE "Remove understood language"

/datum/preferences/proc/migrate_quirks_to_language_menu(list/save_data)
	var/datum/preference_middleware/language/update = locate() in middleware
	var/datum/preference/languages/language_pref = GLOB.preference_entries[/datum/preference/languages]

	// random quirks
	if("Bilingual" in all_quirks)
		var/picked_lang = GLOB.language_types_by_name[save_data["bilingual_language"]]?.type
		if(picked_lang && (picked_lang in language_pref.selectable_languages))
			update.add_language_to_user(picked_lang, ADD_SPOKEN_LANGUAGE)
			update.add_language_to_user(picked_lang, ADD_UNDERSTOOD_LANGUAGE)

	if("Trilingual" in all_quirks)
		pass() // nothing to do about this

	if("Foreigner" in all_quirks)
		update.add_language_to_user(/datum/language/uncommon, ADD_SPOKEN_LANGUAGE)
		update.add_language_to_user(/datum/language/uncommon, ADD_UNDERSTOOD_LANGUAGE)
		update.add_language_to_user(/datum/language/common, REMOVE_SPOKEN_LANGUAGE)
		update.add_language_to_user(/datum/language/common, REMOVE_UNDERSTOOD_LANGUAGE)

	// the old prefs
	var/other_lang = text2path(save_data["language"])
	if(other_lang && (other_lang in language_pref.selectable_languages))
		update.add_language_to_user(other_lang, ADD_SPOKEN_LANGUAGE)
		update.add_language_to_user(other_lang, ADD_UNDERSTOOD_LANGUAGE)

/datum/preference/languages
	savefile_key = "language"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_NAMES // needs to happen after species, so name works
	can_randomize = FALSE

	/// List of languages you can pick.
	var/list/selectable_languages = list(
		/datum/language/common,
		/datum/language/impdraconic,
		/datum/language/isatoa,
		/datum/language/piratespeak,
		/datum/language/shadowtongue,
		/datum/language/uncommon,
		/datum/language/yangyu,
		// these should be auto filled
		/datum/language/moffic,
		/datum/language/nekomimetic,
		/datum/language/draconic,
		/datum/language/skrell,
		// these are iffy
		/datum/language/voltaic,
		/datum/language/calcic,
	)
	/// Languages not rendered in the UI under any circumstances.
	var/list/dont_show_languages = list(
		/datum/language/aphasia,
		/datum/language/codespeak,
		/datum/language/drone,
		/datum/language/xenocommon,
	)
	/// Max # of languages you can add to your character.
	var/max_spoken_languages = 1
	/// Max # of languages you can understand.
	var/max_understood_languages = 2

/datum/preference/languages/create_default_value()
	return null

/datum/preference/languages/deserialize(list/input, datum/preferences/preferences)
	if(!islist(input))
		return null

	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	var/datum/language_holder/species_holder = GLOB.prototype_language_holders[species.species_language_holder]
	var/list/sanitized_input = list()
	for(var/key in input)
		for(var/lang_text in input[key])
			var/lang = istext(lang_text) ? text2path(lang_text) : lang_text
			if(!ispath(lang, /datum/language))
				continue
			switch(key)
				if(ADD_SPOKEN_LANGUAGE)
					if(!(lang in selectable_languages))
						continue
					if(lang in species_holder.spoken_languages)
						continue
					if(length(sanitized_input[key]) >= max_spoken_languages)
						continue

				if(ADD_UNDERSTOOD_LANGUAGE)
					if(!(lang in selectable_languages))
						continue
					if(lang in species_holder.understood_languages)
						continue
					if(length(sanitized_input[key]) >= max_understood_languages)
						continue

				if(REMOVE_SPOKEN_LANGUAGE)
					if(!(lang in species_holder.spoken_languages))
						continue

				if(REMOVE_UNDERSTOOD_LANGUAGE)
					if(!(lang in species_holder.understood_languages))
						continue

			LAZYADD(sanitized_input[key], lang)

	return sanitized_input

/datum/preference/languages/is_valid(value)
	return islist(value) || isnull(value)

/datum/preference/languages/apply_to_human(mob/living/carbon/human/target, value)
	if(isdummy(target) || !islist(value))
		return

	// this needs to be delayed because it's tied to the mind (and we probably don't have that created yet)
	if(target.mind)
		add_mind_languages(target, value)
	else
		RegisterSignals(target, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED), PROC_REF(comsig_add_mind_languages), TRUE)
	// this is fine to do now, though
	remove_species_languages(target, value)

/datum/preference/languages/proc/comsig_add_mind_languages(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(!target.client)
		return

	UnregisterSignal(target, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED))
	add_mind_languages(target, target.client.prefs.read_preference(/datum/preference/languages))

/datum/preference/languages/proc/add_mind_languages(mob/living/carbon/human/target, list/value = list())
	if(QDELETED(target))
		return
	for(var/lang in value[ADD_SPOKEN_LANGUAGE])
		target.grant_language(lang, SPOKEN_LANGUAGE, LANGUAGE_MIND)
	for(var/lang in value[ADD_UNDERSTOOD_LANGUAGE])
		target.grant_language(lang, UNDERSTOOD_LANGUAGE, LANGUAGE_MIND)

/datum/preference/languages/proc/remove_species_languages(mob/living/carbon/human/target, list/value = list())
	if(QDELETED(target))
		return
	for(var/lang in value[REMOVE_SPOKEN_LANGUAGE])
		target.remove_language(lang, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/lang in value[REMOVE_UNDERSTOOD_LANGUAGE])
		target.remove_language(lang, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)

/datum/preference_middleware/language
	action_delegations = list(
		"set_language" = PROC_REF(set_language),
	)

/datum/preference_middleware/language/proc/add_language_to_user(lang_type, lang_key)
	var/datum/preference/languages/language_pref = GLOB.preference_entries[/datum/preference/languages]
	var/list/existing = preferences.read_preference(/datum/preference/languages) || list()

	if(lang_key == ADD_SPOKEN_LANGUAGE && length(existing[ADD_SPOKEN_LANGUAGE]) >= language_pref.max_spoken_languages)
		return FALSE
	if(lang_key == ADD_UNDERSTOOD_LANGUAGE && length(existing[ADD_UNDERSTOOD_LANGUAGE]) >= language_pref.max_understood_languages)
		return FALSE

	if((lang_key == ADD_SPOKEN_LANGUAGE || lang_key == ADD_UNDERSTOOD_LANGUAGE) && !(lang_type in language_pref.selectable_languages))
		return FALSE

	LAZYADD(existing[lang_key], lang_type)

	preferences.write_preference(GLOB.preference_entries[/datum/preference/languages], existing)

	return TRUE

/datum/preference_middleware/language/proc/remove_language_from_user(lang_type, lang_key)
	var/list/existing = preferences.read_preference(/datum/preference/languages) || list()

	LAZYREMOVE(existing[lang_key], lang_type)

	preferences.write_preference(GLOB.preference_entries[/datum/preference/languages], existing)

	return TRUE

/datum/preference_middleware/language/proc/set_language(list/params, mob/user)
	if(params["deselecting"])
		remove_language_from_user(text2path(params["lang_type"]), params["lang_key"])
		return TRUE

	var/lang_path = text2path(params["lang_type"])
	if(GLOB.language_datum_instances[lang_path])
		add_language_to_user(lang_path, params["lang_key"])
	return TRUE

/datum/preference_middleware/language/on_new_character(mob/user)
	preferences.update_static_data(user)

/datum/preference_middleware/language/get_ui_static_data(mob/user)
	var/list/data = list()

	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	var/datum/language_holder/species_holder = GLOB.prototype_language_holders[species.species_language_holder]
	data["spoken_languages"] = assoc_to_keys(species_holder.spoken_languages)
	data["understood_languages"] = assoc_to_keys(species_holder.understood_languages)
	data["partial_languages"] = species_holder.get_mutually_understood_languages()

	return data

/datum/preference_middleware/language/get_ui_data(mob/user)
	var/list/data = list()

	var/list/selected_languages = preferences.read_preference(/datum/preference/languages)
	data["pref_spoken_languages"] = selected_languages?[ADD_SPOKEN_LANGUAGE] || list()
	data["pref_understood_languages"] = selected_languages?[ADD_UNDERSTOOD_LANGUAGE] || list()
	data["pref_unspoken_languages"] = selected_languages?[REMOVE_SPOKEN_LANGUAGE] || list()
	data["pref_ununderstood_languages"] = selected_languages?[REMOVE_UNDERSTOOD_LANGUAGE] || list()

	return data

/datum/preference_middleware/language/get_constant_data()
	var/list/data = list()

	var/datum/preference/languages/language_pref = GLOB.preference_entries[/datum/preference/languages]

	data["base_languages"] = list()
	for(var/found_language in GLOB.language_datum_instances)
		if(found_language in language_pref.dont_show_languages)
			continue
		var/list/lang_data = list()
		lang_data["type"] = found_language
		lang_data["unlocked"] = (found_language in language_pref.selectable_languages)
		lang_data["name"] = GLOB.language_datum_instances[found_language].name
		lang_data["desc"] = GLOB.language_datum_instances[found_language].desc
		UNTYPED_LIST_ADD(data["base_languages"], lang_data)

	data["max_spoken_languages"] = language_pref.max_spoken_languages
	data["max_understood_languages"] = language_pref.max_understood_languages

	return data

#undef ADD_SPOKEN_LANGUAGE
#undef ADD_UNDERSTOOD_LANGUAGE
#undef REMOVE_SPOKEN_LANGUAGE
#undef REMOVE_UNDERSTOOD_LANGUAGE
