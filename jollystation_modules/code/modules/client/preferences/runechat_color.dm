// Allows the player to select a runechat color.
/datum/preference/color/runechat_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "runechat_color"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/runechat_color/create_default_value()
	return "#aaaaaa"

/datum/preference/color/runechat_color/apply_to_human(mob/living/carbon/human/target, value)
	if(value == create_default_value())
		return

	target.chat_color = value
	target.chat_color_darkened = value
	target.chat_color_name = target

/datum/preference/color/runechat_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(value))
		return FALSE

	return TRUE
