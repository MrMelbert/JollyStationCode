/mob/living/carbon/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(damageoverlaytemp)
		update_damage_hud()
		damageoverlaytemp = 0

	if(HAS_TRAIT(src, TRAIT_STASIS))
		. = ..()
		reagents?.handle_stasis_chems(src, seconds_per_tick, times_fired)
	else
		//Reagent processing needs to come before breathing, to prevent edge cases.
		handle_dead_metabolization(seconds_per_tick, times_fired) //Dead metabolization first since it can modify life metabolization.
		handle_organs(seconds_per_tick, times_fired)

		. = ..()
		if(QDELETED(src))
			return

		if(.) //not dead
			handle_blood(seconds_per_tick, times_fired)

		if(stat != DEAD)
			handle_brain_damage(seconds_per_tick, times_fired)

	if(stat != DEAD)
		handle_bodyparts(seconds_per_tick, times_fired)

	if(. && mind) //. == not dead
		for(var/key in mind.addiction_points)
			var/datum/addiction/addiction = SSaddiction.all_addictions[key]
			addiction.process_addiction(src, seconds_per_tick, times_fired)
	if(stat != DEAD)
		return TRUE

///////////////
// BREATHING //
///////////////

// Start of a breath chain, calls [carbon/proc/breathe()]
/mob/living/carbon/handle_breathing(seconds_per_tick, times_fired)
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return

	var/next_breath = 4
	var/obj/item/organ/internal/lungs/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(lungs?.damage > lungs?.high_threshold)
		next_breath -= 1
	if(heart?.damage > heart?.high_threshold)
		next_breath -= 1

	if((times_fired % next_breath) == 0 || failed_last_breath)
		// Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		breathe(seconds_per_tick, times_fired, failed_last_breath ? 1 : next_breath)
		if(failed_last_breath)
			add_mood_event("suffocation", /datum/mood_event/suffocation)
		else
			clear_mood_event("suffocation")
	else if(isobj(loc))
		var/obj/location_as_object = loc
		location_as_object.handle_internal_lifeform(src, 0)

// Second link in a breath chain, calls [carbon/proc/check_breath()]
/mob/living/carbon/proc/breathe(seconds_per_tick, times_fired, next_breath = 4)
	var/datum/gas_mixture/environment = loc?.return_air()
	var/datum/gas_mixture/breath

	if(!HAS_TRAIT(src, TRAIT_ASSISTED_BREATHING))
		if(stat == HARD_CRIT && !internal && !external) // being on internals function as a ventilator + also makes anesthetic function (revisit later)
			losebreath = max(losebreath, 1)
		else if(HAS_TRAIT(src, TRAIT_LABOURED_BREATHING))
			losebreath += (1 / next_breath)

	if(losebreath < 1)
		var/pre_sig_return = SEND_SIGNAL(src, COMSIG_CARBON_ATTEMPT_BREATHE, seconds_per_tick, times_fired)
		if(pre_sig_return & BREATHE_BLOCK_BREATH)
			return

		if(pre_sig_return & BREATHE_SKIP_BREATH)
			losebreath = max(losebreath, 1)

	// Suffocate
	var/skip_breath = FALSE
	if(losebreath >= 1)
		losebreath -= 1
		if(prob(10) && consciousness > 10)
			pain_emote("gasp", 1 SECONDS)
		if(isobj(loc))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)
		skip_breath = TRUE

	// Breathe from internals or externals (name is misleading)
	else if(internal || external)
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(breath == SKIP_INTERNALS) //in case of 0 pressure internals
			breath = get_breath_from_surroundings(environment, BREATH_VOLUME)

		else if(isobj(loc)) //Breathe from loc as obj again
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)

	// Breathe from air
	else
		breath = get_breath_from_surroundings(environment, BREATH_VOLUME)

	check_breath(breath, skip_breath)

	if(breath)
		exhale_breath(breath)

/mob/living/carbon/proc/exhale_breath(datum/gas_mixture/breath)
	if(SEND_SIGNAL(src, COMSIG_CARBON_BREATH_EXHALE, breath) & BREATHE_EXHALE_HANDLED)
		return
	loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	return HAS_TRAIT(src, TRAIT_NOBREATH)

/**
 * This proc tests if the lungs can breathe, if the mob can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * This proc expects a lungs organ in order to breathe successfully, but does not defer any work to it.
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 * * skip_breath: Used to differentiate between a failed breath and a lack of breath.
 * A mob suffocating due to being in a vacuum may be treated differently than a mob suffocating due to lung failure.
 */
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath, skip_breath = FALSE)
	return

/// Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = body_temperature

/**
 * Attempts to take a breath from the external or internal air tank.
 *
 * Return a gas mixture datum if a breath was taken
 * Return null if there was no gas inside the tank or no gas was distributed
 * Return SKIP_INTERNALS to skip using internals entirely and get a normal breath
 */
/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(invalid_internals())
		// Unexpectely lost breathing apparatus and ability to breathe from the internal air tank.
		cutoff_internals()
		return SKIP_INTERNALS

	if (external)
		. = external.remove_air_volume(volume_needed)
	else if (internal)
		. = internal.remove_air_volume(volume_needed)
	else
		// Return without taking a breath if there is no air tank.
		stack_trace("get_breath_from_internal called on a mob without internals or externals")
		return SKIP_INTERNALS

	return .

/**
 * Attempts to take a breath from the surroundings.
 *
 * Returns a gas mixture datum if a breath was taken.
 * Returns null if there was no gas in the surroundings or no gas was distributed.
 */
/mob/living/carbon/proc/get_breath_from_surroundings(datum/gas_mixture/environment, volume_needed)
	if(isobj(loc)) //Breathe from loc as object
		var/obj/loc_as_obj = loc
		. = loc_as_obj.handle_internal_lifeform(src, volume_needed)

	else if(isturf(loc)) //Breathe from loc as turf
		. = loc.remove_air((environment?.total_moles() * BREATH_PERCENTAGE) || 0)

	return .

/mob/living/carbon/proc/handle_blood(seconds_per_tick, times_fired)
	return

/mob/living/carbon/proc/handle_bodyparts(seconds_per_tick, times_fired)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. |= limb.on_life(seconds_per_tick, times_fired)

/mob/living/carbon/proc/handle_organs(seconds_per_tick, times_fired)
	if(stat == DEAD)
		for(var/obj/item/organ/internal/organ in organs)
			// On-death is where organ decay is handled
			if(organ?.owner) // organ + owner can be null due to reagent metabolization causing organ shuffling
				organ.on_death(seconds_per_tick, times_fired)
			// We need to re-check the stat every organ, as one of our others may have revived us
			if(stat != DEAD)
				break
		return

	// NOTE: organs_slot is sorted by GLOB.organ_process_order on insertion
	for(var/slot in organs_slot)
		// We don't use get_organ_slot here because we know we have the organ we want, since we're iterating the list containing em already
		// This code is hot enough that it's just not worth the time
		var/obj/item/organ/internal/organ = organs_slot[slot]
		if(organ?.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
			organ.on_life(seconds_per_tick, times_fired)


/mob/living/carbon/handle_diseases(seconds_per_tick, times_fired)
	for(var/datum/disease/disease as anything in diseases)
		if(QDELETED(disease)) //Got cured/deleted while the loop was still going.
			continue
		if(SPT_PROB(disease.infectivity, seconds_per_tick))
			disease.spread()
		if(stat != DEAD || disease.process_dead)
			disease.stage_act(seconds_per_tick, times_fired)

/mob/living/carbon/handle_wounds(seconds_per_tick, times_fired)
	for(var/datum/wound/wound as anything in all_wounds)
		if(!wound.processes) // meh
			continue
		wound.handle_process(seconds_per_tick, times_fired)

/mob/living/carbon/handle_mutations(time_since_irradiated, seconds_per_tick, times_fired)
	if(!dna?.temporary_mutations.len)
		return

	for(var/mut in dna.temporary_mutations)
		if(dna.temporary_mutations[mut] < world.time)
			if(mut == UI_CHANGED)
				if(dna.previous["UI"])
					dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UI")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UF_CHANGED)
				if(dna.previous["UF"])
					dna.unique_features = merge_text(dna.unique_features,dna.previous["UF"])
					updateappearance(mutcolor_update=1, mutations_overlay_update=1)
					dna.previous.Remove("UF")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UE_CHANGED)
				if(dna.previous["name"])
					real_name = dna.previous["name"]
					name = real_name
					dna.previous.Remove("name")
				if(dna.previous["UE"])
					dna.unique_enzymes = dna.previous["UE"]
					dna.previous.Remove("UE")
				if(dna.previous["blood_type"])
					dna.human_blood_type = find_blood_type(dna.previous["blood_type"])
					dna.previous.Remove("blood_type")
				dna.temporary_mutations.Remove(mut)
				continue
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM?.timeout)
			dna.remove_mutation(HM.type)

/**
 * Handles calling metabolization for dead people.
 * Due to how reagent metabolization code works this couldn't be done anywhere else.
 *
 * Arguments:
 * - seconds_per_tick: The amount of time that has elapsed since the last tick.
 * - times_fired: The number of times SSmobs has ticked.
 */
/mob/living/carbon/proc/handle_dead_metabolization(seconds_per_tick, times_fired)
	if(stat != DEAD)
		return
	reagents?.metabolize(src, seconds_per_tick, times_fired, can_overdose = TRUE, liverless = TRUE, dead = TRUE) // Your liver doesn't work while you're dead.

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	. = ..()
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(HAS_TRAIT(src, TRAIT_RESISTHIGHPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * physiology.pressure_mod * physiology.brute_mod * seconds_per_tick
				adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert(ALERT_PRESSURE)

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
				clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = LOW_PRESSURE_DAMAGE * physiology.pressure_mod * physiology.brute_mod * seconds_per_tick
				adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)

/**
 * Have two mobs share body heat between each other.
 * Account for the insulation and max temperature change range for the mob
 *
 * vars:
 * * M The mob/living/carbon that is sharing body heat
 */
/mob/living/carbon/proc/share_bodytemperature(mob/living/carbon/M)
	var/temp_diff = body_temperature - M.body_temperature
	if(temp_diff > 0) // you are warm share the heat of life
		M.adjust_body_temperature((temp_diff * 0.5) * 0.075 KELVIN, use_insulation = TRUE) // warm up the giver
		adjust_body_temperature((temp_diff * -0.5) * 0.075 KELVIN, use_insulation = TRUE) // cool down the reciver

	else // they are warmer leech from them
		adjust_body_temperature((temp_diff * -0.5) * 0.075 KELVIN, use_insulation = TRUE) // warm up the reciver
		M.adjust_body_temperature((temp_diff * 0.5) * 0.075 KELVIN, use_insulation = TRUE) // cool down the giver

///////////
//Stomach//
///////////

/mob/living/carbon/get_fullness()
	var/fullness = nutrition

	var/obj/item/organ/internal/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly) //nothing to see here if we do not have a stomach
		return fullness

	for(var/bile in belly.reagents.reagent_list)
		var/datum/reagent/bits = bile
		if(istype(bits, /datum/reagent/consumable))
			var/datum/reagent/consumable/goodbit = bile
			fullness += goodbit.get_nutriment_factor(src) * goodbit.volume / goodbit.metabolization_rate
			continue
		fullness += 0.6 * bits.volume / bits.metabolization_rate //not food takes up space

	return fullness

/mob/living/carbon/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	. = ..()
	if(.)
		return
	var/obj/item/organ/internal/stomach/belly = get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!belly)
		return FALSE
	return belly.reagents.has_reagent(reagent, amount, needs_metabolizing)

/////////
//LIVER//
/////////

///Check to see if we have the liver, if not automatically gives you last-stage effects of lacking a liver.

/mob/living/carbon/proc/handle_liver(seconds_per_tick, times_fired)
	if(isnull(has_dna()))
		return

	var/obj/item/organ/internal/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		return

	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, seconds_per_tick, times_fired, can_overdose = TRUE, liverless = TRUE)

	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_LIVERLESS_METABOLISM))
		return

	adjustToxLoss(0.6 * seconds_per_tick, forced = TRUE)
	adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 0.5* seconds_per_tick)

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/internal/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver?.organ_flags & ORGAN_FAILING)
		return TRUE

////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage(seconds_per_tick, times_fired)
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life(seconds_per_tick, times_fired)

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || IS_ROBOTIC_ORGAN(heart))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (HAS_TRAIT(src, TRAIT_NOBLOOD) || isnull(dna.species.mutantheart))) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be suprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.is_beating())
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/**
 * Causes the mob to either start or stop having a heart attack.
 *
 * status - Pass TRUE to start a heart attack, or FALSE to stop one.
 *
 * Returns TRUE if heart status was changed (heart attack -> no heart attack, or visa versa)
 */
/mob/living/carbon/proc/set_heartattack(status)
	if(status && !can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return FALSE

	if(status)
		return heart.Stop()

	return heart.Restart()
