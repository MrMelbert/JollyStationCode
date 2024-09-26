/// Hypo and Hyperthermia status effects.
/datum/status_effect/thermia
	id = "thermia"
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 3 SECONDS
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	/// Flat penalty of consciousness applied over time
	var/consciousness_mod = 0
	var/max_consciousness_mod = 0
	var/datum/weakref/alert_ref
	COOLDOWN_DECLARE(update_cd)

/datum/status_effect/thermia/on_apply()
	if(consciousness_mod)
		owner.remove_consciousness_modifier(id, 0)
	if(max_consciousness_mod)
		owner.add_max_consciousness_value(id, UPPER_CONSCIOUSNESS_MAX)

	give_alert()
	COOLDOWN_START(src, update_cd, 6 SECONDS)
	return TRUE

/datum/status_effect/thermia/on_remove()
	owner.remove_consciousness_modifier(id)
	owner.remove_max_consciousness_value(id)
	owner.clear_alert(ALERT_TEMPERATURE)
	owner.clear_mood_event(id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cold)

/datum/status_effect/thermia/tick(seconds_between_ticks)
	if(!COOLDOWN_FINISHED(src, update_cd))
		return

	// Counts up from 0 to [consciousness_mod]
	if(consciousness_mod)
		var/current_mod = -1 * owner.remove_consciousness_modifier(id)
		if(current_mod >= consciousness_mod)
			return
		owner.add_consciousness_modifier(id, (-1 * (min(consciousness_mod, current_mod + 5))))

	// Counts down from 150 to [max_consciousness_mod]
	if(max_consciousness_mod && COOLDOWN_FINISHED(src, update_cd))
		var/current_mod = owner.remove_max_consciousness_value(id)
		if(current_mod <= max_consciousness_mod)
			return
		owner.add_max_consciousness_value(id, (max(max_consciousness_mod, current_mod - 10)))

	COOLDOWN_START(src, update_cd, 9 SECONDS)

/// Manually applying alerts, rather than using the api for it, becuase we need to apply "severity" argument
/datum/status_effect/thermia/proc/give_alert()
	return

/datum/status_effect/thermia/hypo
	var/slowdown_mod

/datum/status_effect/thermia/hypo/on_creation(mob/living/new_owner, slowdown_mod = 1)
	src.slowdown_mod = slowdown_mod
	return ..()

/datum/status_effect/thermia/hypo/on_apply()
	. = ..()
	owner.add_mood_event(id, /datum/mood_event/cold)
	// Apply cold slow down
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = slowdown_mod)

/datum/status_effect/thermia/hypo/one
	consciousness_mod = 5

/datum/status_effect/thermia/hypo/one/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)

/datum/status_effect/thermia/hypo/two
	consciousness_mod = 10

/datum/status_effect/thermia/hypo/two/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)

/datum/status_effect/thermia/hypo/three
	consciousness_mod = 20
	max_consciousness_mod = HARD_CRIT_THRESHOLD

/datum/status_effect/thermia/hypo/three/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)

/datum/status_effect/thermia/hyper

/datum/status_effect/thermia/hyper/on_apply()
	. = ..()
	owner.add_mood_event(id, /datum/mood_event/hot)
	//Remove any slowdown from the cold.
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cold)

/datum/status_effect/thermia/hyper/one
	consciousness_mod = 5

/datum/status_effect/thermia/hyper/one/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)

/datum/status_effect/thermia/hyper/two
	consciousness_mod = 10

/datum/status_effect/thermia/hyper/two/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)

/datum/status_effect/thermia/hyper/three
	consciousness_mod = 20
	max_consciousness_mod = HARD_CRIT_THRESHOLD

/datum/status_effect/thermia/hyper/three/give_alert()
	return owner.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
