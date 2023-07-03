// Override of holywater's on_mob_life.
// Turns out holywater never calls parent anyways, crazy
/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	if(!data)
		data = list("misc" = 0)

	if(!user.mind || !IS_CULTIST(user))
		return ..() // Don't need to care if they're not an advanced cultist really

	var/datum/antagonist/advanced_cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/advanced_cult)
	if(!istype(cult_datum))
		return ..() // We're dealing with a normal cultist so we don't need to bother

	user.adjust_jitter_up_to(4 SECONDS * seconds_per_tick, 20 SECONDS)

	for(var/datum/action/spell as anything in cult_datum.our_magic?.spells)
		var/deleted_a_spell = FALSE
		// 12% chance per tick to lose innate spells
		if(istype(spell, /datum/action/innate/cult) && SPT_PROB(12, seconds_per_tick))
			deleted_a_spell = TRUE
			qdel(spell)

		// 6% chance per tick to lose item spells
		if(istype(spell, /datum/action/item_action) && (spell.target in user.get_all_contents()) && SPT_PROB(6, seconds_per_tick))
			deleted_a_spell = TRUE
			qdel(spell)

		if(deleted_a_spell)
			to_chat(user, cult_datum.cultist_style.our_cult_span("Your magic falters as holy water scours your body!", bold = TRUE, large = TRUE))

	data["misc"] += seconds_per_tick SECONDS * REM
	if(data["misc"] >= (25 SECONDS)) // ~10 units
		user.adjust_stutter_up_to(4 SECONDS * seconds_per_tick, 20 SECONDS)
		user.set_dizzy_if_lower(10 SECONDS)

		if(SPT_PROB(10, seconds_per_tick))
			user.say(cult_datum.cultist_style.pick_deconversion_line(), forced = "holy water")

			if(SPT_PROB(15, seconds_per_tick))
				user.visible_message(
					span_danger("[user] starts having a seizure!"),
					span_userdanger("You have a seizure!")
					)

				user.set_jitter_if_lower(10 SECONDS)
				user.Paralyze(6 SECONDS)
				to_chat(user, cult_datum.cultist_style.our_cult_span(cult_datum.cultist_style.pick_god_shame_line(), bold = TRUE, large = TRUE))

	if(data["misc"] >= (1 MINUTES)) // ~24 units
		// We're a cult master
		if(istype(cult_datum, /datum/antagonist/advanced_cult/master))
			var/datum/antagonist/deconverted_cult_master/new_datum = user.mind.add_antag_datum(/datum/antagonist/deconverted_cult_master)
			if(new_datum)
				// Transfer the advanced antag datum over
				new_datum.linked_advanced_datum = cult_datum.linked_advanced_datum
				new_datum.linked_advanced_datum.linked_antagonist = new_datum
				new_datum.linked_advanced_datum.can_use_ui = FALSE
				new_datum.name = cult_datum.name
				new_datum.old_theme = cult_datum.cultist_style.name
				// ...And null it over when it's done so it doesn't get qdel'd
				cult_datum.linked_advanced_datum = null

		user.mind.remove_antag_datum(cult_datum.type)
		user.Unconscious(15 SECONDS)
		user.remove_status_effect(/datum/status_effect/jitter)
		var/amount_stutter = user.get_timed_status_effect_duration(/datum/status_effect/speech/stutter)
		user.adjust_stutter(amount_stutter * 0.5) // Ah fuck I can't believe you've done this
		holder.remove_reagent(type, volume)
		return

	current_cycle++
	holder.remove_reagent(type, 1 * REAGENTS_METABOLISM * seconds_per_tick)
