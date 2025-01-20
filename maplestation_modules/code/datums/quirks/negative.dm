// -- Bad modular quirks. --

// Rebalance of existing quirks
/datum/quirk/item_quirk/nearsighted
	value = -2

/datum/quirk/bad_touch
	value = -2

/datum/quirk/numb
	value = -2 // This is a small buff but a large nerf so it's balanced at a relatively low cost
	desc = "You don't feel pain as much as others. \
		It's harder to pinpoint which parts of your body are injured, and \
		you are immune to some effects of pain - possibly to your detriment."

// Modular quirks
// More vulnerabile to pain (increased pain modifier)
/datum/quirk/pain_vulnerability
	name = "Hyperalgesia"
	desc = "You're less resistant to pain - Your pain naturally decreases slower and you receive more overall."
	icon = FA_ICON_USER_INJURED
	value = -6
	gain_text = span_danger("You feel sharper.")
	lose_text = span_notice("You feel duller.")
	medical_record_text = "Patient has Hyperalgesia, and is more susceptible to pain stimuli than most."
	mail_goodies = list(/obj/item/temperature_pack/cold)

/datum/quirk/pain_vulnerability/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.set_pain_mod(PAIN_MOD_QUIRK, 1.15)

/datum/quirk/pain_vulnerability/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.unset_pain_mod(PAIN_MOD_QUIRK)

// More vulnerable to pain + get pain from more actions (Glass bones and paper skin)
/datum/quirk/allodynia
	name = "Allodynia"
	desc = "Your nerves are extremely sensitive - you may receive pain from things that wouldn't normally be painful, such as hugs."
	icon = FA_ICON_TIRED
	value = -10
	gain_text = span_danger("You feel fragile.")
	lose_text = span_notice("You feel less delicate.")
	medical_record_text = "Patient has Allodynia, and is extremely sensitive to touch, pain, and similar stimuli."
	mail_goodies = list(/obj/item/temperature_pack/cold, /obj/item/temperature_pack/heat)
	COOLDOWN_DECLARE(time_since_last_touch)

/datum/quirk/allodynia/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.set_pain_mod(PAIN_MOD_QUIRK, 1.2)
	RegisterSignals(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(cause_body_pain))

/datum/quirk/allodynia/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.unset_pain_mod(PAIN_MOD_QUIRK)
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/**
 * Causes pain to arm zones if they're targeted, and the chest zone otherwise.
 *
 * source - quirk_holder / the mob being touched
 * toucher - the mob that's interacting with source (pulls, hugs, etc)
 */
/datum/quirk/allodynia/proc/cause_body_pain(datum/source, mob/living/toucher)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, time_since_last_touch))
		return

	if(quirk_holder.stat != CONSCIOUS)
		return

	to_chat(quirk_holder, span_danger("[toucher] touches you, causing a wave of sharp pain throughout your [parse_zone(toucher.zone_selected)]!"))
	actually_hurt(toucher.zone_selected, 9)

/**
 * Actually cause the pain to the target limb, causing a visual effect, emote, and a negative moodlet.
 *
 * zone - the body zone being affected
 * amount - the amount of pain being added
 */
/datum/quirk/allodynia/proc/actually_hurt(zone, amount)
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!istype(carbon_holder))
		return

	new /obj/effect/temp_visual/annoyed(quirk_holder.loc)
	carbon_holder.cause_pain(zone, amount)
	INVOKE_ASYNC(quirk_holder, TYPE_PROC_REF(/mob/living, pain_emote))
	quirk_holder.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	COOLDOWN_START(src, time_since_last_touch, 30 SECONDS)

#define CANE_BASIC "Cane (Black)"
#define CANE_MEDICAL "Cane (Medical)"
#define CANE_WOODEN "Cane (Wooden)"
#define NO_CANE "None"

#define INTENSITY_LOW "Low (1/5th of a second)"
#define INTENSITY_MEDIUM "Medium (2/5ths of a second)"
#define INTENSITY_HIGH "High (3/5ths of a second)"

#define SIDE_LEFT "Left"
#define SIDE_RIGHT "Right"
#define SIDE_RANDOM "Random"

/datum/quirk/limp
	name = "Limp"
	desc = "You have a limp, making you slower and less agile."
	icon = FA_ICON_WALKING
	value = -4
	gain_text = span_danger("You feel a limp.")
	lose_text = span_notice("You feel less of a limp.")
	medical_record_text = "Patient has a limp in one of their legs."

/datum/quirk/limp/add_unique(client/client_source)
	var/cane = client_source?.prefs?.read_preference(/datum/preference/choiced/limp_cane) || NO_CANE
	var/intensity = client_source?.prefs?.read_preference(/datum/preference/choiced/limp_intensity) || INTENSITY_LOW
	var/side = client_source?.prefs?.read_preference(/datum/preference/choiced/limp_side) || SIDE_RANDOM
	if(side == SIDE_RANDOM)
		side = pick(SIDE_LEFT, SIDE_RIGHT)

	switch(cane)
		if(CANE_BASIC)
			give_cane(/obj/item/cane, side)
			mail_goodies |= /obj/item/cane
		if(CANE_MEDICAL)
			give_cane(/obj/item/cane/crutch, side)
			mail_goodies |= /obj/item/cane/crutch
		if(CANE_WOODEN)
			give_cane(/obj/item/cane/crutch/wood, side)
			mail_goodies |= /obj/item/cane/crutch/wood
		if(NO_CANE)
			mail_goodies |= /obj/item/reagent_containers/pill/morphine/diluted

	switch(intensity)
		if(INTENSITY_MEDIUM)
			mail_goodies |= /obj/item/reagent_containers/pill/paracetamol
		if(INTENSITY_HIGH)
			mail_goodies |= /obj/item/reagent_containers/pill/morphine/diluted

	quirk_holder.apply_status_effect(/datum/status_effect/limp/permanent, side, intensity)

/datum/quirk/limp/proc/give_cane(cane_type, side)
	. = FALSE

	var/obj/item/given = new cane_type()
	if(side == SIDE_LEFT)
		. = quirk_holder.put_in_r_hand(given) // reversed (it makes sense just think about it)
	if(side == SIDE_RIGHT)
		. = quirk_holder.put_in_l_hand(given) // reversed (same)
	if(!.)
		. = quirk_holder.put_in_hands(given) // if it fails now, it will dump the ground. acceptable

	return .

/datum/quirk/limp/remove()
	quirk_holder.remove_status_effect(/datum/status_effect/limp/permanent)

/datum/status_effect/limp/permanent
	id = "perma_limp"
	alert_type = null

/datum/status_effect/limp/permanent/on_creation(mob/living/new_owner, side = pick(SIDE_LEFT, SIDE_RIGHT), intensity = INTENSITY_LOW)
	// setting to 150, because adrenaline halves limp chance
	switch(side)
		if(SIDE_LEFT)
			limp_chance_left = 150
		if(SIDE_RIGHT)
			limp_chance_right = 150

	// we can set both since it'll have a 0% chance for the unused side anyways
	switch(intensity)
		if(INTENSITY_LOW)
			slowdown_left = slowdown_right = 0.2 SECONDS
		if(INTENSITY_MEDIUM)
			slowdown_left = slowdown_right = 0.4 SECONDS
		if(INTENSITY_HIGH)
			slowdown_left = slowdown_right = 0.6 SECONDS

	return ..()

/datum/status_effect/limp/permanent/update_limp()
	left = owner.get_bodypart(BODY_ZONE_L_LEG)
	right = owner.get_bodypart(BODY_ZONE_R_LEG)
	next_leg = null


/datum/quirk_constant_data/limp
	associated_typepath = /datum/quirk/limp
	customization_options = list(
		/datum/preference/choiced/limp_cane,
		/datum/preference/choiced/limp_intensity,
		/datum/preference/choiced/limp_side,
	)

/datum/preference/choiced/limp_cane
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "limp_cane"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_generate_icons = TRUE

/datum/preference/choiced/limp_cane/create_default_value()
	return CANE_BASIC

/datum/preference/choiced/limp_cane/init_possible_values()
	return list(CANE_BASIC, CANE_MEDICAL, CANE_WOODEN, NO_CANE)

/datum/preference/choiced/limp_cane/icon_for(value)
	switch(value)
		if(CANE_BASIC)
			return icon(/obj/item/cane::icon, /obj/item/cane::icon_state)
		if(CANE_MEDICAL)
			return icon(/obj/item/cane/crutch::icon, /obj/item/cane/crutch::icon_state)
		if(CANE_WOODEN)
			return icon(/obj/item/cane/crutch/wood::icon, /obj/item/cane/crutch/wood::icon_state)
		if(NO_CANE)
			return icon('icons/hud/screen_gen.dmi', "x")

	return icon('icons/effects/random_spawners.dmi', "questionmark")

/datum/preference/choiced/limp_cane/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/limp::name in preferences.all_quirks

/datum/preference/choiced/limp_cane/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/limp_intensity
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "limp_intensity"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/limp_intensity/create_default_value()
	return INTENSITY_LOW

/datum/preference/choiced/limp_intensity/init_possible_values()
	return list(INTENSITY_LOW, INTENSITY_MEDIUM, INTENSITY_HIGH)

/datum/preference/choiced/limp_intensity/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/limp::name in preferences.all_quirks

/datum/preference/choiced/limp_intensity/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/limp_side
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "limp_side"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/limp_side/create_default_value()
	return SIDE_RANDOM

/datum/preference/choiced/limp_side/init_possible_values()
	return list(SIDE_LEFT, SIDE_RIGHT, SIDE_RANDOM)

/datum/preference/choiced/limp_side/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/limp::name in preferences.all_quirks

/datum/preference/choiced/limp_side/apply_to_human(mob/living/carbon/human/target, value)
	return

#undef CANE_BASIC
#undef CANE_MEDICAL
#undef CANE_WOODEN
#undef NO_CANE

#undef INTENSITY_LOW
#undef INTENSITY_MEDIUM
#undef INTENSITY_HIGH

#undef SIDE_LEFT
#undef SIDE_RIGHT
#undef SIDE_RANDOM
