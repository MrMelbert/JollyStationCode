/// Sharp pain. Used for a lot of pain at once, as a little of it is healed after the effect runs out.
/datum/status_effect/sharp_pain
	id = "sharp_pain"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS

	/// Amount of pain being given
	var/pain_amount = 0
	/// Type of pain being given
	var/pain_type
	/// The zone or zones we're afflicting
	var/targeted_zone_or_zones
	/// Percentage of pain healed when the effect ends
	var/return_mod = 0.33
	/// Stops all refunds on removal
	var/no_refunds = FALSE

/datum/status_effect/sharp_pain/on_creation(
	mob/living/carbon/human/new_owner,
	targeted_zone_or_zones,
	pain_amount = 0,
	pain_type = BRUTE,
	duration = 1 MINUTES,
	return_mod = 0.33,
)

	src.duration = duration
	src.targeted_zone_or_zones = targeted_zone_or_zones
	src.pain_amount = pain_amount
	src.pain_type = pain_type
	src.return_mod = return_mod
	return ..()

/datum/status_effect/sharp_pain/on_apply()
	if(pain_amount <= 0)
		return FALSE
	// To avoid having 10 sharp pains when someone is hit by a shotgun, we'll just add the pain to an existing sharp pain effect
	for(var/datum/status_effect/sharp_pain/other_pain in owner.status_effects)
		if(other_pain.pain_type != pain_type)
			continue
		if(other_pain.return_mod != return_mod)
			continue
		if(other_pain.targeted_zone_or_zones ~! targeted_zone_or_zones) // equivalence because it may be a list
			continue
		other_pain.duration = max(other_pain.duration, world.time + duration)
		other_pain.pain_amount += pain_amount
		owner.cause_pain(targeted_zone_or_zones, pain_amount, pain_type)
		no_refunds = TRUE
		return FALSE

	owner.cause_pain(targeted_zone_or_zones, pain_amount, pain_type)
	return TRUE

/datum/status_effect/sharp_pain/on_remove()
	if(QDELING(owner) || no_refunds)
		return

	owner.cause_pain(targeted_zone_or_zones, pain_amount * return_mod * -1, pain_type)
	owner.adjust_traumatic_shock(pain_amount * 0.125 * -1, 0)
