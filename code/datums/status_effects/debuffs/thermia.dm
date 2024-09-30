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

/datum/status_effect/thermia/tick(seconds_between_ticks)
	if(!COOLDOWN_FINISHED(src, update_cd))
		return

	if(owner.body_temperature > owner.bodytemp_cold_damage_limit || owner.body_temperature < owner.bodytemp_heat_damage_limit)
		qdel(src)

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

/datum/status_effect/thermia/hypo

/datum/status_effect/thermia/hypo/one
	consciousness_mod = 5

/datum/status_effect/thermia/hypo/two
	consciousness_mod = 10

/datum/status_effect/thermia/hypo/three
	consciousness_mod = 20
	max_consciousness_mod = HARD_CRIT_THRESHOLD

/datum/status_effect/thermia/hyper

/datum/status_effect/thermia/hyper/one
	consciousness_mod = 5

/datum/status_effect/thermia/hyper/two
	consciousness_mod = 10

/datum/status_effect/thermia/hyper/three
	consciousness_mod = 20
	max_consciousness_mod = HARD_CRIT_THRESHOLD
