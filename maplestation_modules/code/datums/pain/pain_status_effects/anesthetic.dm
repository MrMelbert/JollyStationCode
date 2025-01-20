/datum/status_effect/drugginess/euphoria
	id = "drugged_euphoria"
	status_type = STATUS_EFFECT_REFRESH
	mood_type = /datum/mood_event/chemical_euphoria

/datum/status_effect/drugginess/euphoria/refresh(mob/living/new_owner, new_duration)
	duration = min(duration + new_duration, world.time + 30 SECONDS)

/datum/status_effect/drugginess/euphoria/tick(seconds_between_ticks)
	. = ..()
	if(SPT_PROB(4, seconds_between_ticks))
		owner.emote(pick("giggle", "laugh"))

/// Anesthetics, for use in surgery - to stop pain.
/datum/status_effect/anesthetic
	id = "anesthetics"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/anesthetics
	tick_interval = -1
	/// World time when the anesthetic was applied
	var/applied_at = -1

/datum/status_effect/anesthetic/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	if(iscarbon(new_owner))
		var/mob/living/carbon/carbon_owner = new_owner
		// if we're NOT on internals or externals, DON'T display an alert, for N2O floods
		if(!carbon_owner.internal && !carbon_owner.external)
			alert_type = null

	src.duration = duration
	return ..()

/datum/status_effect/anesthetic/refresh(mob/living/new_owner, new_duration)
	// Adds duration, but don't go beyond 30 seconds from now, to keep people out of GBJ
	duration = min(duration + new_duration, world.time + 30 SECONDS)

/datum/status_effect/anesthetic/on_apply()
	if(HAS_TRAIT(owner, TRAIT_SLEEPIMMUNE))
		return FALSE
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_SLEEPIMMUNE), PROC_REF(qdel_us))
	owner.add_max_consciousness_value(type, 10)
	owner.set_pain_mod(type, 0.1)
	applied_at = world.time
	return TRUE

/datum/status_effect/anesthetic/on_remove()
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_SLEEPIMMUNE))
	if(!QDELETED(owner))
		owner.remove_max_consciousness_value(type)
		owner.unset_pain_mod(type)
		owner.apply_status_effect(/datum/status_effect/anesthesia_grog, applied_at)

/datum/status_effect/anesthetic/get_examine_text()
	return span_warning("[owner.p_Theyre()] out cold.")

/datum/status_effect/anesthetic/proc/qdel_us(...)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/anesthetics
	name = "Anesthetic"
	desc = "Everything's woozy... The world goes dark... You're on anesthetics. \
		Good luck in surgery! If it's actually surgery, that is."
	icon_state = "paralysis"

/datum/status_effect/anesthesia_grog
	id = "anesthesia_grog"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 MINUTES
	alert_type = null
	remove_on_fullheal = TRUE
	var/strength = 0

/datum/status_effect/anesthesia_grog/on_creation(mob/living/new_owner, anesthesia_appied_at)
	strength = (world.time - anesthesia_appied_at > 1 MINUTES) ? 50 : 90
	return ..()

/datum/status_effect/anesthesia_grog/on_apply()
	owner.add_max_consciousness_value(type, strength)
	owner.set_pain_mod(type, 0.9)
	owner.adjust_drugginess(initial(duration) / 8)
	to_chat(owner, span_warning("You feel[strength <= 90 ? " ":" a bit "]groggy..."))
	return TRUE

/datum/status_effect/anesthesia_grog/on_remove()
	owner.remove_max_consciousness_value(type)
	owner.unset_pain_mod(type)
