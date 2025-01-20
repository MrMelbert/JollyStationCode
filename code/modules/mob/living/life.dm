/**
 * Handles the biological and general over-time processes of the mob.
 *
 *
 * Arguments:
 * - seconds_per_tick: The amount of time that has elapsed since this last fired.
 * - times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	set waitfor = FALSE

	var/signal_result = SEND_SIGNAL(src, COMSIG_LIVING_LIFE, seconds_per_tick, times_fired)

	if(signal_result & COMPONENT_LIVING_CANCEL_LIFE_PROCESSING) // mmm less work
		return

	if (client)
		var/turf/T = get_turf(src)
		if(!T)
			move_to_error_room()
			var/msg = " was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
			message_admins(ADMIN_LOOKUPFLW(src) + msg)
			send2tgs_adminless_only("Mob", key_name_and_tag(src) + msg, R_ADMIN)
			src.log_message("was found to have no .loc with an attached client.", LOG_GAME)

		// This is a temporary error tracker to make sure we've caught everything
		else if (registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
	else if (registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)

	if(isnull(loc) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(!HAS_TRAIT(src, TRAIT_STASIS))

		if(stat != DEAD)
			//Mutations and radiation
			handle_mutations(seconds_per_tick, times_fired)
			//Breathing, if applicable
			handle_breathing(seconds_per_tick, times_fired)

		handle_diseases(seconds_per_tick, times_fired)// DEAD check is in the proc itself; we want it to spread even if the mob is dead, but to handle its disease-y properties only if you're not.

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return

		if(stat != DEAD)
			//Random events (vomiting etc)
			handle_random_events(seconds_per_tick, times_fired)

		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment, seconds_per_tick, times_fired)
			body_temperature_damage(environment, seconds_per_tick, times_fired)
		if(stat <= SOFT_CRIT && !on_fire)
			temperature_homeostasis(seconds_per_tick, times_fired)

		handle_gravity(seconds_per_tick, times_fired)

	if(stat != DEAD)
		body_temperature_alerts()
	handle_wounds(seconds_per_tick, times_fired)
	if(staminaloss)
		adjustStaminaLoss(-1 * (stat == DEAD ? 100 : 2.5) * seconds_per_tick)
	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(seconds_per_tick, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, seconds_per_tick, times_fired)
	return

/mob/living/proc/body_temperature_damage(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	if(body_temperature > bodytemp_heat_damage_limit \
		&& !HAS_TRAIT(src, TRAIT_RESISTHEAT) \
		&& !has_reagent(/datum/reagent/medicine/pyroxadone, needs_metabolizing = TRUE))
		var/heat_diff = bodytemp_heat_damage_limit - standard_body_temperature
		var/heat_threshold_low = bodytemp_heat_damage_limit + heat_diff * 0.75
		var/heat_threshold_medium = bodytemp_heat_damage_limit + heat_diff * 1.25
		var/heat_threshold_high = bodytemp_heat_damage_limit + heat_diff * 2

		var/firemodifier = round(fire_stacks, 1) * 0.01
		if (!on_fire) // We are not on fire, reduce the modifier
			firemodifier = min(firemodifier, 0) // Note that wetstacks make us take less burn damage

		// convering back and forth so we can apply a multiplier from firestacks without sending temp to the moon
		var/effective_temp = CELCIUS_TO_KELVIN(KELVIN_TO_CELCIUS(body_temperature) * (1 + firemodifier))
		var/burn_damage = HEAT_DAMAGE
		if(effective_temp > heat_threshold_high)
			burn_damage *= 8
			// melbert todo : status effects should handle the damage, not the proc
			apply_status_effect(/datum/status_effect/thermia/hyper/three)
		else if(effective_temp > heat_threshold_medium)
			burn_damage *= 4
			apply_status_effect(/datum/status_effect/thermia/hyper/two)
		else if(effective_temp > heat_threshold_low)
			burn_damage *= 2
			apply_status_effect(/datum/status_effect/thermia/hyper/one)

		if(temperature_burns(burn_damage * seconds_per_tick) > 0 && SPT_PROB(10, seconds_per_tick) && !temperature_insulation && !on_fire)
			var/expected_temp = get_temperature(loc?.return_air())
			var/insulation = get_insulation(expected_temp)
			if(insulation > 0.5 && expected_temp < body_temperature)
				to_chat(src, span_danger("Your clothing is insulating you, keeping you warmer!"))

		if(effective_temp > heat_threshold_medium)
			apply_status_effect(/datum/status_effect/stacking/heat_exposure, 1, heat_threshold_medium)

	// For cold damage, we cap at the threshold if you're dead
	if(body_temperature < bodytemp_cold_damage_limit \
		&& !HAS_TRAIT(src, TRAIT_RESISTCOLD) \
		&& !has_reagent(/datum/reagent/medicine/cryoxadone, needs_metabolizing = TRUE) \
		&& (getFireLoss() < maxHealth || stat != DEAD))
		var/cold_diff = bodytemp_cold_damage_limit - standard_body_temperature
		var/cold_threshold_low = bodytemp_cold_damage_limit + cold_diff * 1.2
		var/cold_threshold_medium = bodytemp_cold_damage_limit + cold_diff * 1.75
		var/cold_threshold_high = bodytemp_cold_damage_limit + cold_diff * 2

		var/cold_damage = COLD_DAMAGE
		if(body_temperature < cold_threshold_high)
			cold_damage *= 8
			// melbert todo : status effects should handle the damage, not the proc
			apply_status_effect(/datum/status_effect/thermia/hypo/three)
		else if(body_temperature < cold_threshold_medium)
			cold_damage *= 4
			apply_status_effect(/datum/status_effect/thermia/hypo/two)
		else if(body_temperature < cold_threshold_low)
			cold_damage *= 2
			apply_status_effect(/datum/status_effect/thermia/hypo/one)

		if(temperature_cold_damage(cold_damage * seconds_per_tick) > 0 && SPT_PROB(10, seconds_per_tick) && !temperature_insulation)
			var/expected_temp = get_temperature(loc?.return_air())
			var/insulation = get_insulation(expected_temp)
			if(insulation > 0.5 && expected_temp > body_temperature)
				to_chat(src, span_danger("Your clothing is insulating you, keeping you colder!"))

/// Applies damage to the mob due to being too cold
/mob/living/proc/temperature_cold_damage(damage)
	return apply_damage(damage, HAS_TRAIT(src, TRAIT_HULK) ? BRUTE : BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

/mob/living/carbon/human/temperature_cold_damage(damage)
	damage *= physiology.cold_mod
	return ..()

/// Applies damage to the mob due to being too hot
/mob/living/proc/temperature_burns(damage)
	return apply_damage(damage, BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

/mob/living/carbon/human/temperature_burns(damage)
	damage *= physiology.heat_mod
	return ..()

/mob/living/proc/body_temperature_alerts()
	// give out alerts based on how the skin feels, not how the body is
	// this gives us an early warning system - since we tend to trend up/down to skin temperature -
	// how we're going to be feeling soon if we don't change our environment
	var/feels_like = get_skin_temperature()

	var/hot_diff = bodytemp_heat_damage_limit - standard_body_temperature
	var/hot_threshold_low = bodytemp_heat_damage_limit - hot_diff * 0.5
	var/hot_threshold_medium = bodytemp_heat_damage_limit
	var/hot_threshold_high = bodytemp_heat_damage_limit + hot_diff
	// Body temperature is too hot, and we do not have resist traits
	if(feels_like > hot_threshold_low && !HAS_TRAIT(src, TRAIT_RESISTHEAT))
		clear_mood_event("cold")
		// Clear cold once we return to warm
		remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		if(feels_like > hot_threshold_high)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
			add_mood_event("hot", /datum/mood_event/overhot)
		else if(feels_like > hot_threshold_medium)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			add_mood_event("hot", /datum/mood_event/hot)
		else
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
			add_mood_event("hot", /datum/mood_event/warm)
		temp_alerts = TRUE

	var/cold_diff = bodytemp_cold_damage_limit - standard_body_temperature
	var/cold_threshold_low = bodytemp_cold_damage_limit - cold_diff * 0.5
	var/cold_threshold_medium = bodytemp_cold_damage_limit
	var/cold_threshold_high = bodytemp_cold_damage_limit + cold_diff
	// Body temperature is too cold, and we do not have resist traits
	if(feels_like < cold_threshold_low && !HAS_TRAIT(src, TRAIT_RESISTCOLD))
		clear_mood_event("hot")
		if(feels_like < cold_threshold_high)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
			add_mood_event("cold", /datum/mood_event/freezing)
		else if(feels_like < cold_threshold_medium)
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
			add_mood_event("cold", /datum/mood_event/cold)
		else
			throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
			add_mood_event("cold", /datum/mood_event/chilly)
		temp_alerts = TRUE
	// Only apply slowdown if the body is cold rather than the skin
	if(body_temperature < cold_threshold_medium && !HAS_TRAIT(src, TRAIT_RESISTCOLD))
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((cold_threshold_medium - body_temperature) / COLD_SLOWDOWN_FACTOR))
	else if(LAZYACCESS(movespeed_modification, "[/datum/movespeed_modifier/cold]"))
		remove_movespeed_modifier(/datum/movespeed_modifier/cold)

	// We are not to hot or cold, remove status and moods
	if(temp_alerts && (feels_like < hot_threshold_low || HAS_TRAIT(src, TRAIT_RESISTHEAT)) && (feels_like > cold_threshold_low || HAS_TRAIT(src, TRAIT_RESISTCOLD)))
		clear_alert(ALERT_TEMPERATURE)
		clear_mood_event("cold")
		clear_mood_event("hot")
		temp_alerts = FALSE

/mob/living/silicon/body_temperature_alerts()
	return // Not yet

/mob/living/proc/handle_mutations(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_diseases(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_wounds(seconds_per_tick, times_fired)
	return

/mob/living/proc/handle_random_events(seconds_per_tick, times_fired)
	return

/**
 * Handle this mob's interactions with the environment
 *
 * By default handles body temperature normalization to the area's temperature,
 * but also handles pressure for many mobs
 *
 * Arguments:
 * * environment: The gas mixture of the area the mob is in, will never be null
 * * seconds_per_tick: The amount of time that has elapsed since this last fired.
 * * times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp = get_temperature(environment)
	var/thermal_protection = get_insulation(loc_temp)
	// calculate a target temperature based on environment vs insulation
	var/equilibrium_temp = loc_temp + (standard_body_temperature - loc_temp) * (thermal_protection * 0.5)
	var/temp_delta = equilibrium_temp - body_temperature
	if(temp_delta == 0)
		return
	if(temp_delta < 0 && on_fire) // do not reduce body temp when on fire
		return

	// Adds a modifier onto how strong insulation is
	// If we are above SBT, we are overheating and sweating, which reduces insulation
	var/protection_modifier = body_temperature > standard_body_temperature + 2 KELVIN ? 0.7 : 1
	var/temp_sign = SIGN(temp_delta)
	var/temp_change =  temp_sign * (1 - (thermal_protection * protection_modifier)) * ((0.1 * max(1, abs(temp_delta))) ** 1.8) * temperature_normalization_speed
	// Cap increase and decrease
	temp_change = temp_change < 0 ? max(temp_change, BODYTEMP_ENVIRONMENT_COOLING_MAX) : min(temp_change, BODYTEMP_ENVIRONMENT_HEATING_MAX)
	adjust_body_temperature(temp_change * seconds_per_tick) // no use_insulation beacuse we account for it manually

/mob/living/silicon/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	return // Not yet

/**
 * Handles this mob internally managing its body temperature (sweating or generating heat)
 *
 * Arguments:
 * * seconds_per_tick: The amount of time that has elapsed since this last fired.
 * * times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/temperature_homeostasis(seconds_per_tick, times_fired)
	if(temperature_homeostasis_speed == 0) // cold blooded creature
		return
	if(!HAS_TRAIT(src, TRAIT_NOHUNGER) && nutrition < (NUTRITION_LEVEL_STARVING / 3))
		return

	// find exactly what temperature we're aiming for
	var/homeostasis_target = standard_body_temperature
	if(LAZYLEN(homeostasis_targets))
		homeostasis_target = 0
		for(var/source in homeostasis_targets)
			homeostasis_target += homeostasis_targets[source]
		homeostasis_target /= LAZYLEN(homeostasis_targets)

	// temperature delta is capped, so you can't attempt to homeostaize from vacuum to standard temp in a second
	var/temp_delta = (homeostasis_target - body_temperature)
	temp_delta = temp_delta < 0 ? max(temp_delta, BODYTEMP_HOMEOSTASIS_COOLING_MAX) : min(temp_delta, BODYTEMP_HOMEOSTASIS_HEATING_MAX)
	// note: Because this scales by metabolism efficiency, being well fed boosts your homeostasis, and being poorly fed reduces it
	var/natural_change = temp_delta * metabolism_efficiency * temperature_homeostasis_speed
	if(natural_change == 0)
		return

	var/sigreturn = SEND_SIGNAL(src, COMSIG_LIVING_HOMEOSTASIS, natural_change, seconds_per_tick)
	if(sigreturn & HOMEOSTASIS_HANDLED)
		return

	var/min = natural_change < 0 ? homeostasis_target : 0
	var/max = natural_change > 0 ? homeostasis_target : INFINITY
	// calculates how much nutrition decay per kelvin of temperature change
	// while having this scale may be confusing, it's to make sure that stepping into an extremely cold environment (space)
	// doesn't immediately drain nutrition to zero in under a minute
	// at 0.25 kelvin, nutrition_per_kelvin is 2.5. at 1, it's ~1.5, and at 4, it's 1.
	var/nutrition_per_kelvin = round(2.5 / ((abs(natural_change) / 0.25) ** 0.33), 0.01)

	adjust_body_temperature(natural_change * seconds_per_tick, min_temp = min, max_temp = max) // no use_insulation beacuse this is internal
	if(!(sigreturn & HOMEOSTASIS_NO_HUNGER))
		adjust_nutrition(-1 * HOMEOSTASIS_HUNGER_MULTIPLIER * HUNGER_FACTOR * nutrition_per_kelvin * abs(natural_change) * seconds_per_tick)

/mob/living/silicon/temperature_homeostasis(seconds_per_tick, times_fired)
	return // Not yet

/**
 * Get the fullness of the mob
 *
 * This returns a value form 0 upwards to represent how full the mob is.
 * The value is a total amount of consumable reagents in the body combined
 * with the total amount of nutrition they have.
 * This does not have an upper limit.
 */
/mob/living/proc/get_fullness()
	var/fullness = nutrition
	// we add the nutrition value of what we're currently digesting
	for(var/datum/reagent/consumable/bits in reagents.reagent_list)
		fullness += bits.get_nutriment_factor(src) * bits.volume / bits.metabolization_rate
	return fullness

/**
 * Check if the mob contains this reagent.
 *
 * This will validate the the reagent holder for the mob and any sub holders contain the requested reagent.
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 * * amount (int) checks for having a specific amount of that chemical.
 * * needs_metabolizing (bool) takes into consideration if the chemical is matabolizing when it's checked.
 */
/mob/living/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	return reagents.has_reagent(reagent, amount, needs_metabolizing)


/mob/living/proc/handle_gravity(seconds_per_tick, times_fired)
	if(gravity_state > STANDARD_GRAVITY)
		handle_high_gravity(gravity_state, seconds_per_tick, times_fired)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	animate(get_filter("gravity"), y = 1, time = 10, loop = -1)
	animate(y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity, seconds_per_tick, times_fired)
	if(gravity < GRAVITY_DAMAGE_THRESHOLD) //Aka gravity values of 3 or more
		return

	var/grav_strength = gravity - GRAVITY_DAMAGE_THRESHOLD
	adjustBruteLoss(min(GRAVITY_DAMAGE_SCALING * grav_strength, GRAVITY_DAMAGE_MAXIMUM) * seconds_per_tick)
