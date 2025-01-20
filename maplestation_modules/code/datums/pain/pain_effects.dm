// -- Pain effects - mood and modifiers. --

/atom/movable/screen/fullscreen/pain
	icon = 'maplestation_modules/icons/hud/screen_full.dmi'
	icon_state = "painoverlay"
	layer = UI_DAMAGE_LAYER

/mob/living/proc/flash_pain_overlay(severity = 1, time = 1 SECONDS)
	if(screens["pain"])
		return
	overlay_fullscreen("pain", /atom/movable/screen/fullscreen/pain, severity)
	clear_fullscreen("pain", time)

/datum/movespeed_modifier/pain
	id = MOVESPEED_ID_PAIN
	movetypes = GROUND

// >= 100 total pain
/datum/movespeed_modifier/pain/light
	multiplicative_slowdown = 0.1

// >= 200 total pain
/datum/movespeed_modifier/pain/medium
	multiplicative_slowdown = 0.2

// >= 300 total pain
/datum/movespeed_modifier/pain/heavy
	multiplicative_slowdown = 0.35

// >= 400 total pain
/datum/movespeed_modifier/pain/crippling
	multiplicative_slowdown = 0.5

/datum/actionspeed_modifier/pain
	id = ACTIONSPEED_ID_PAIN

// >= 100 total pain
/datum/actionspeed_modifier/pain/light
	multiplicative_slowdown = 0.2

// >= 200 total pain
/datum/actionspeed_modifier/pain/medium
	multiplicative_slowdown = 0.2

// >= 300 total pain
/datum/actionspeed_modifier/pain/heavy
	multiplicative_slowdown = 0.35

// >= 400 total pain
/datum/actionspeed_modifier/pain/crippling
	multiplicative_slowdown = 0.5

/datum/mood_event/light_pain
	description = "It aches."
	mood_change = -3

/datum/mood_event/med_pain
	description = "I feel very sore."
	mood_change = -6

/datum/mood_event/heavy_pain
	description = "It hurts!"
	mood_change = -10

/datum/mood_event/crippling_pain
	description = "STOP THE PAIN!"
	mood_change = -15

// Applied when you go under the knife with anesthesia
/datum/mood_event/anesthetic
	description = "Thank science for modern medicine."
	mood_change = 2
	timeout = 6 MINUTES

// Applied by most surgeries if you get operated on without anesthetics
/datum/mood_event/surgery
	description = "They're operating on me while I'm awake!"
	mood_change = -6
	timeout = 3 MINUTES

// Applied by some surgeries that are especially bad without anesthetics
/datum/mood_event/surgery/major
	description = "THEY'RE CUTTING ME OPEN!!"
	mood_change = -10
	timeout = 6 MINUTES

/datum/mood_event/narcotic_light
	description = "I feel numb."
	mood_change = 4
	timeout = 3 MINUTES

/**
 * Obviousnly not all ailments of a mob are treatable while dead,
 * so we need to apply a "buffer" status effect post-revival
 * to offset some the consciousness penalties of these ailments while they are treated
 *
 * This is only applied via defibbing, not via other methods of revival.
 */
/datum/status_effect/recent_defib
	duration = 60 SECONDS
	id = "recent_defib"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// Base amount of consciousness / max consciousness to give the patient
	var/base_con = 15

/datum/status_effect/recent_defib/on_apply()
	owner.add_consciousness_modifier(id, base_con)
	owner.add_max_consciousness_value(id, base_con)
	return TRUE

/datum/status_effect/recent_defib/on_remove()
	if(QDELING(owner))
		return
	owner.remove_consciousness_modifier(id)
	owner.remove_max_consciousness_value(id)
	owner.apply_status_effect(/datum/status_effect/revival_sickess)

/datum/status_effect/recent_defib/tick(seconds_between_ticks)
	var/deciseconds_remaining = duration - world.time
	if(deciseconds_remaining <= 0)
		return
	var/seconds_elapsed = round((initial(duration) - deciseconds_remaining) / (1 SECONDS), 1)

	// Bonus for being defibbed decays over time
	owner.add_consciousness_modifier(id, base_con - (seconds_elapsed * 0.25))
	// Consciousness returns over time
	owner.add_max_consciousness_value(id, base_con + (seconds_elapsed))

/datum/mood_event/revival_sickess
	description = "Back from the beyond the brink..."
	mood_change = -3

/datum/mood_event/revival_sickess/add_effects(mob/living/adder)
	if(adder.has_quirk(/datum/quirk/apathetic))
		mood_change = 0

/**
 * For a period after revival, you suffer from res sickness, gotta get back on your feet.
 */
/datum/status_effect/revival_sickess
	duration = 5 MINUTES
	id = "revival_sickess"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	tick_interval = -1
	remove_on_fullheal = TRUE
	/// Tracks how much max consciousness penalty to give the patient
	var/max_con = 75

/datum/status_effect/revival_sickess/on_apply()
	if(owner.stat == DEAD)
		return FALSE

	owner.add_mood_event(id, /datum/mood_event/revival_sickess, owner)
	owner.add_max_consciousness_value(id, max_con)
	addtimer(CALLBACK(src, PROC_REF(improve)), 1 MINUTES, TIMER_DELETE_ME)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(died_again))
	return TRUE

/datum/status_effect/revival_sickess/on_remove()
	if(QDELING(owner))
		return
	owner.clear_mood_event(id)
	owner.remove_max_consciousness_value(id)
	UnregisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(died_again))

/datum/status_effect/revival_sickess/proc/improve()
	if(max_con >= 100)
		qdel(src)
		return

	max_con += 5
	owner.add_max_consciousness_value(id, max_con)
	addtimer(CALLBACK(src, PROC_REF(improve)), 1 MINUTES, TIMER_DELETE_ME)

/datum/status_effect/revival_sickess/proc/died_again(...)
	SIGNAL_HANDLER
	qdel(src)
