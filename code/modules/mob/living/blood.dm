#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding
// Conversion between internal drunk power and common blood alcohol content
#define DRUNK_POWER_TO_BLOOD_ALCOHOL 0.003

/****************************************************
				BLOOD SYSTEM
****************************************************/

// NON-MODULE CHANGE for blood
// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(seconds_per_tick, times_fired)

	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		remove_max_consciousness_value(BLOOD_LOSS)
		return

	if(body_temperature < BLOOD_STOP_TEMP || HAS_TRAIT(src, TRAIT_HUSK)) //cold or husked people do not pump the blood.
		return

	var/sigreturn = SEND_SIGNAL(src, COMSIG_HUMAN_ON_HANDLE_BLOOD, seconds_per_tick, times_fired)
	if(sigreturn & HANDLE_BLOOD_HANDLED)
		return

	//Blood regeneration if there is some space
	if(!(sigreturn & HANDLE_BLOOD_NO_NUTRITION_DRAIN))
		if(blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			if(satiety > 80)
				nutrition_ratio *= 1.25
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * seconds_per_tick)
			blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * seconds_per_tick), BLOOD_VOLUME_NORMAL)

	//Effects of bloodloss
	if(!(sigreturn & HANDLE_BLOOD_NO_EFFECTS))
		var/word = pick("dizzy","woozy","faint")
		switch(blood_volume)
			if(BLOOD_VOLUME_MAX_LETHAL to INFINITY)
				if(SPT_PROB(7.5, seconds_per_tick))
					to_chat(src, span_userdanger("Blood starts to tear your skin apart. You're going to burst!"))
					investigate_log("has been gibbed by having too much blood.", INVESTIGATE_DEATHS)
					inflate_gib()
			if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(src, span_warning("You feel your skin swelling."))
			if(BLOOD_VOLUME_MAXIMUM to BLOOD_VOLUME_EXCESS)
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(src, span_warning("You feel terribly bloated."))
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(SPT_PROB(2.5, seconds_per_tick))
					to_chat(src, span_warning("You feel [word]."))
				var/threshold = 50 * ((BLOOD_VOLUME_SAFE - blood_volume) / (BLOOD_VOLUME_SAFE - BLOOD_VOLUME_OKAY))
				if(getOxyLoss() < threshold)
					adjustOxyLoss(1)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				add_max_consciousness_value(BLOOD_LOSS, CONSCIOUSNESS_MAX * 0.9)
				add_consciousness_modifier(BLOOD_LOSS, -10)
				adjust_traumatic_shock(0.5 * seconds_per_tick)
				if(getOxyLoss() < 100)
					adjustOxyLoss(2) // Keep in mind if they're still breathing while bleeding - some of this will be recovered
				if(SPT_PROB(2.5, seconds_per_tick))
					set_eye_blur_if_lower(12 SECONDS)
					to_chat(src, span_warning("You feel very [word]."))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				add_max_consciousness_value(BLOOD_LOSS, CONSCIOUSNESS_MAX * 0.6)
				add_consciousness_modifier(BLOOD_LOSS, -20)
				adjust_traumatic_shock(1 * seconds_per_tick)
				if(getOxyLoss() < 150)
					adjustOxyLoss(3)
				set_eye_blur_if_lower(6 SECONDS)
				if(SPT_PROB(7.5, seconds_per_tick))
					Unconscious(rand(2, 6) * 1 SECONDS)
					losebreath += 1
					to_chat(src, span_warning("You feel extremely [word]."))
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				add_max_consciousness_value(BLOOD_LOSS, CONSCIOUSNESS_MAX * 0.2)
				add_consciousness_modifier(BLOOD_LOSS, -50)
				adjust_traumatic_shock(3 * seconds_per_tick)
				set_eye_blur_if_lower(20 SECONDS)
				// Unconscious(10 SECONDS)
				var/how_screwed_are_we = 1 - ((BLOOD_VOLUME_SURVIVE - blood_volume) / BLOOD_VOLUME_SURVIVE)
				adjustOxyLoss(max(5, 50 * how_screwed_are_we))
				// if(!HAS_TRAIT(src, TRAIT_NODEATH))
				// 	investigate_log("has died of bloodloss.", INVESTIGATE_DEATHS)
				// 	death()

	if(blood_volume > BLOOD_VOLUME_OKAY)
		remove_max_consciousness_value(BLOOD_LOSS)
		remove_consciousness_modifier(BLOOD_LOSS)

	// NON-MODULE CHANGE END for blood

	var/temp_bleed = 0
	//Bleeding out
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		var/iter_bleed_rate = iter_part.get_modified_bleed_rate()
		temp_bleed += iter_bleed_rate * seconds_per_tick

		if(iter_part.generic_bleedstacks) // If you don't have any bleedstacks, don't try and heal them
			iter_part.adjustBleedStacks(-1)

	if(temp_bleed)
		bleed(temp_bleed)
		bleed_warn(temp_bleed)

/// Has each bodypart update its bleed/wound overlay icon states
/mob/living/carbon/proc/update_bodypart_bleed_overlays()
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		iter_part.update_part_wound_overlay()

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt, drip = TRUE)
	if((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	blood_volume = max(blood_volume - amt, 0)

	if(drip && isturf(loc) && prob(sqrt(amt) * BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, (amt <= 10))

/mob/living/carbon/human/bleed(amt, drip = TRUE)
	amt *= physiology.bleed_mod
	return ..()

/// A helper to see how much blood we're losing per tick
/mob/living/carbon/proc/get_bleed_rate()
	var/bleed_amt = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/iter_bodypart = X
		bleed_amt += iter_bodypart.get_modified_bleed_rate()
	return bleed_amt

/mob/living/carbon/human/get_bleed_rate()
	. = ..()
	. *= physiology.bleed_mod

/**
 * bleed_warn() is used to for carbons with an active client to occasionally receive messages warning them about their bleeding status (if applicable)
 *
 * Arguments:
 * * bleed_amt- When we run this from [/mob/living/carbon/human/proc/handle_blood] we already know how much blood we're losing this tick, so we can skip tallying it again with this
 * * forced-
 */
/mob/living/carbon/proc/bleed_warn(bleed_amt = get_bleed_rate(), forced = FALSE)
	// NON-MODULE CHANGE for blood
	if(!client || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	if((!COOLDOWN_FINISHED(src, bleeding_message_cd) || HAS_TRAIT(src, TRAIT_KNOCKEDOUT)) && !forced)
		return

	var/bleeding_severity = ""
	var/next_cooldown = BLEEDING_MESSAGE_BASE_CD

	switch(bleed_amt)
		if(-INFINITY to 0)
			return
		if(0 to 1)
			bleeding_severity = "You feel light trickles of blood across your skin"
			next_cooldown *= 2.5
		if(1 to 3)
			bleeding_severity = "You feel a small stream of blood running across your body"
			next_cooldown *= 2
		if(3 to 5)
			bleeding_severity = "You skin feels clammy from the flow of blood leaving your body"
			next_cooldown *= 1.7
		if(5 to 7)
			bleeding_severity = "Your body grows more and more numb as blood streams out"
			next_cooldown *= 1.5
		if(7 to INFINITY)
			bleeding_severity = "Your heartbeat thrashes wildly trying to keep up with your bloodloss"

	var/rate_of_change = ", but it's getting better." // if there's no wounds actively getting bloodier or maintaining the same flow, we must be getting better!
	if(HAS_TRAIT(src, TRAIT_COAGULATING)) // if we have coagulant, we're getting better quick
		rate_of_change = ", but it's clotting up quickly!"
	else
		// flick through our wounds to see if there are any bleeding ones getting worse or holding flow (maybe move this to handle_blood and cache it so we don't need to cycle through the wounds so much)
		for(var/datum/wound/iter_wound as anything in all_wounds)
			if(!iter_wound.blood_flow)
				continue
			var/iter_wound_roc = iter_wound.get_bleed_rate_of_change()
			switch(iter_wound_roc)
				if(BLOOD_FLOW_INCREASING) // assume the worst, if one wound is getting bloodier, we focus on that
					rate_of_change = ", <b>and it's getting worse!</b>"
					break
				if(BLOOD_FLOW_STEADY) // our best case now is that our bleeding isn't getting worse
					rate_of_change = ", and it's holding steady."
				if(BLOOD_FLOW_DECREASING) // this only matters if none of the wounds fit the above two cases, included here for completeness
					continue

	to_chat(src, span_warning("[bleeding_severity][rate_of_change]"))
	COOLDOWN_START(src, bleeding_message_cd, next_cooldown)

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		BP.setBleedStacks(0)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

// NON-MODULE CHANGE : Blood rework

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	var/datum/blood_type/blood = get_blood_type()
	if(isnull(blood) || !AM.reagents)
		return FALSE
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	blood_volume -= amount
	AM.reagents.add_reagent(blood.reagent_type, amount, blood.get_blood_data(src), body_temperature)
	return TRUE

// /mob/living/proc/get_blood_data()
// 	return null

// /mob/living/carbon/get_blood_data()
// 	if(get_blood_type()?.reagent_type != /datum/reagent/blood) //actual blood reagent
// 		return null

// 	var/list/blood_data = list()
// 	//set the blood data
// 	blood_data["viruses"] = list()

// 	for(var/thing in diseases)
// 		var/datum/disease/D = thing
// 		blood_data["viruses"] += D.Copy()

// 	blood_data["blood_DNA"] = dna.unique_enzymes
// 	if(LAZYLEN(disease_resistances))
// 		blood_data["resistances"] = disease_resistances.Copy()
// 	var/list/temp_chem = list()
// 	for(var/datum/reagent/R in reagents.reagent_list)
// 		temp_chem[R.type] = R.volume
// 	blood_data["trace_chem"] = list2params(temp_chem)
// 	if(mind)
// 		blood_data["mind"] = mind
// 	else if(last_mind)
// 		blood_data["mind"] = last_mind
// 	if(ckey)
// 		blood_data["ckey"] = ckey
// 	else if(last_mind)
// 		blood_data["ckey"] = ckey(last_mind.key)

// 	if(!HAS_TRAIT_FROM(src, TRAIT_SUICIDED, REF(src)))
// 		blood_data["cloneable"] = 1
// 	blood_data["blood_type"] = dna.human_blood_type
// 	blood_data["gender"] = gender
// 	blood_data["real_name"] = real_name
// 	blood_data["features"] = dna.features
// 	blood_data["factions"] = faction
// 	blood_data["quirks"] = list()
// 	for(var/V in quirks)
// 		var/datum/quirk/T = V
// 		blood_data["quirks"] += T.type
// 	return blood_data

/mob/living/proc/get_blood_type()
	RETURN_TYPE(/datum/blood_type)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	return find_blood_type(/datum/blood_type/animal)

/mob/living/basic/get_blood_type()
	// All basic mobs are noblood but we should still pretend
	return find_blood_type(/datum/blood_type/animal)

/mob/living/simple_animal/get_blood_type()
	// Same here
	return find_blood_type(/datum/blood_type/animal)

/mob/living/silicon/get_blood_type()
	return find_blood_type(/datum/blood_type/oil)

/mob/living/simple_animal/bot/get_blood_type()
	return find_blood_type(/datum/blood_type/oil)

/mob/living/basic/bot/get_blood_type()
	return find_blood_type(/datum/blood_type/oil)

/mob/living/basic/drone/get_blood_type()
	return find_blood_type(/datum/blood_type/oil)

/mob/living/carbon/alien/get_blood_type()
	if(HAS_TRAIT(src, TRAIT_HUSK) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	return find_blood_type(/datum/blood_type/xenomorph)

/mob/living/carbon/human/get_blood_type()
	if(HAS_TRAIT(src, TRAIT_HUSK) || isnull(dna) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return null
	if(check_holidays(APRIL_FOOLS) && is_clown_job(mind?.assigned_role))
		return find_blood_type(/datum/blood_type/clown)
	return find_blood_type(dna.species.exotic_bloodtype || dna.human_blood_type)

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/blood_turf = get_turf(src), small_drip)
	return get_blood_type()?.make_blood_splatter(src, blood_turf, small_drip)

/mob/living/proc/do_splatter_effect(splat_dir = pick(GLOB.cardinals))
	var/obj/effect/temp_visual/dir_setting/bloodsplatter/splatter = new(get_turf(src), splat_dir)
	splatter.color = get_blood_type()?.color

// NON-MODULE CHANGE END

/mob/living/proc/get_blood_alcohol_content()
	var/blood_alcohol_content = 0
	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	if(!isnull(inebriation))
		blood_alcohol_content = round(inebriation.drunk_value * DRUNK_POWER_TO_BLOOD_ALCOHOL, 0.01)

	return blood_alcohol_content

#undef BLOOD_DRIP_RATE_MOD
#undef DRUNK_POWER_TO_BLOOD_ALCOHOL
