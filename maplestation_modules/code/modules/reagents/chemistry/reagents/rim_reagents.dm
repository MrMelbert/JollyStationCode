// -- Rimworld inspired reagents. --

// Component chem
/datum/reagent/neutroamine
	name = "Neutroamine"
	description = "A component chem often used in outer rim planets to make a variety of medicines and drugs."
	reagent_state = LIQUID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#9dffff"
	ph = 9.4

/datum/chemical_reaction/neutroamine
	results = list(/datum/reagent/neutroamine = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/mercury = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

// Luciferium. Exremely addictive, very strong pain relief
/datum/reagent/medicine/luciferium
	name = "Luciferium"
	description = "An incredibly powerful, addictive, and dangerous concoction of mechanites from the outer planets of the Spinward. \
		Drastically improves the user's bodily functions but will cause eventual death if mechanite cohesion is not sustained with continuous dosage. \
		Once used, the presence and effects of the mechanites are irreversible, leading to the nickname \'Devil's Bargain\' by many."
	taste_description = "dread"
	reagent_state = SOLID
	color = "#a80008"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 12
	ph = 12.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/luciferium = 33) // 3 units = addiction
	pain_modifier = 0.8

/datum/reagent/medicine/luciferium/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	// Increases movement speed very slightly
	user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/luciferium)
	// Helps stabilize the person / blood flow
	ADD_TRAIT(user, TRAIT_ANTICONVULSANT, type)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT, type)
	ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, type)
	ADD_TRAIT(user, TRAIT_COAGULATING, type)
	// Improved blood filtration (resistance to diseases)
	ADD_TRAIT(user, TRAIT_VIRUS_CONTACT_IMMUNE, type)
	ADD_TRAIT(user, TRAIT_VIRUS_RESISTANCE, type)
	// Slight improved vision
	ADD_TRAIT(user, TRAIT_NIGHT_VISION, type)
	user.add_consciousness_modifier(type, 20)

/datum/reagent/medicine/luciferium/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	stop_effects(user)

/datum/reagent/medicine/luciferium/overdose_start(mob/living/user)
	. = ..()
	stop_effects(user)

/datum/reagent/medicine/luciferium/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(!(methods & (PATCH|INGEST))) // If we're not ingested, delete ourselves.
		exposed_mob.reagents.remove_reagent(type, reac_volume)
	if(methods & INJECT)
		exposed_mob.visible_message(span_warning("The [name] nanomachine web disintegrates upon injection into [exposed_mob]!"))

/datum/reagent/medicine/luciferium/on_mob_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	if(overdosed)
		return ..()

	// Heals pain and tons of damage (based on purity)
	user.cause_pain(BODY_ZONES_ALL, -2 * REM * seconds_per_tick)
	user.adjustBruteLoss(-5 * REM * seconds_per_tick, FALSE)
	user.adjustFireLoss(-5 * REM * seconds_per_tick, FALSE)
	user.adjustOxyLoss(-3 * REM * seconds_per_tick, FALSE)
	user.adjustToxLoss(-3 * REM * seconds_per_tick, FALSE, TRUE)
	adjust_bleed_wounds(user, seconds_per_tick)
	if(user.blood_volume < BLOOD_VOLUME_NORMAL)
		user.blood_volume = min(user.blood_volume + (5 * REM * seconds_per_tick), BLOOD_VOLUME_NORMAL)

	// Improves / fixes eyesight
	user.adjust_eye_blur(-4 SECONDS * REM * seconds_per_tick)
	user.adjust_temp_blindness(-4 SECONDS * REM * seconds_per_tick)
	user.adjustOrganLoss(ORGAN_SLOT_EYES, -3 * REM * seconds_per_tick )

	// Removes scars
	if(SPT_PROB(8, seconds_per_tick))
		var/datum/scar/scar_to_remove = pick(user.all_scars)
		if(scar_to_remove)
			LAZYREMOVE(user.all_scars, scar_to_remove)

	// Can cure permanent traumas
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3 * REM * seconds_per_tick)
	if(SPT_PROB(5, seconds_per_tick))
		var/static/list/curable_traumas = shuffle(subtypesof(/datum/brain_trauma/severe) + subtypesof(/datum/brain_trauma/mild))
		for(var/trauma in curable_traumas)
			if(user.has_trauma_type(trauma))
				user.cure_trauma_type(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
				break

	// Can cure wounds, too
	if(SPT_PROB(6, seconds_per_tick))
		var/list/shuffled_wounds = shuffle(user.all_wounds)
		for(var/datum/wound/wound as anything in shuffled_wounds)
			wound.remove_wound()
			break

	. = ..()
	return TRUE

/**
 * Slow and stop blood loss.
 */
/datum/reagent/medicine/luciferium/proc/adjust_bleed_wounds(mob/living/carbon/user, seconds_per_tick)
	if(HAS_TRAIT(user, TRAIT_NOBLOOD) || !LAZYLEN(user.all_wounds))
		return

	var/datum/wound/bloodiest_wound
	for(var/datum/wound/iter_wound as anything in user.all_wounds)
		if(iter_wound.blood_flow)
			if(iter_wound.blood_flow > bloodiest_wound?.blood_flow)
				bloodiest_wound = iter_wound

	if(bloodiest_wound)
		bloodiest_wound.blood_flow = max(0, bloodiest_wound.blood_flow - (0.5 * REM * seconds_per_tick))

/**
 * Stop the effects of the chem.
 */
/datum/reagent/medicine/luciferium/proc/stop_effects(mob/living/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_NOSOFTCRIT, type))
		return

	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/luciferium)
	REMOVE_TRAIT(user, TRAIT_ANTICONVULSANT, type)
	REMOVE_TRAIT(user, TRAIT_VIRUS_CONTACT_IMMUNE, type)
	REMOVE_TRAIT(user, TRAIT_VIRUS_RESISTANCE, type)
	REMOVE_TRAIT(user, TRAIT_NOSOFTCRIT, type)
	REMOVE_TRAIT(user, TRAIT_NOCRITDAMAGE, type)
	REMOVE_TRAIT(user, TRAIT_NIGHT_VISION, type)
	REMOVE_TRAIT(user, TRAIT_COAGULATING, type)
	user.remove_consciousness_modifier(type)

/obj/item/reagent_containers/pill/luciferium
	name = "luciferium pill"
	desc = "A very dangerous medicine that can save the life of the most wounded and scarred of people, at a costly price of \
		permanent reliance on the drug to maintain the mechanite structure it creates."
	icon_state = "pill_syndie"
	list_reagents = list(/datum/reagent/medicine/luciferium = 5)
	rename_with_volume = TRUE

/obj/item/reagent_containers/cup/glass/bottle/luciferium
	name = "luciferium bottle"
	desc = "A bottle of luciferium, an extremely effective but dangerous medicine that can save someone from the brink of death \
		at the cost of permanent reliance on the drug to maintain the mechanite structure it creates."
	volume = 20
	possible_transfer_amounts = list(2, 5, 10, 20)
	list_reagents = list(/datum/reagent/medicine/luciferium = 20)

/datum/reagent/medicine/penoxycyline
	name = "Penoxycyline"
	description = "A standard drug that prevents the user from catching viral or bacterial diseases or infections."
	reagent_state = LIQUID
	color = "#c4b703"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	ph = 8.7

/datum/reagent/medicine/penoxycyline/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	ADD_TRAIT(user, TRAIT_VIRUS_CONTACT_IMMUNE, type)
	ADD_TRAIT(user, TRAIT_VIRUS_RESISTANCE, type)

/datum/reagent/medicine/penoxycyline/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_VIRUS_CONTACT_IMMUNE, type)
	REMOVE_TRAIT(user, TRAIT_VIRUS_RESISTANCE, type)

/datum/chemical_reaction/penoxycyline
	results = list(/datum/reagent/medicine/penoxycyline = 2)
	required_reagents = list(/datum/reagent/neutroamine = 1, /datum/reagent/medicine/spaceacillin = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/obj/item/reagent_containers/pill/penoxycyline
	name = "penoxycyline pill"
	desc = "A standard medicine that prevents the user from catching viral or bacterial diseases or infections."
	icon_state = "pill22"
	list_reagents = list(/datum/reagent/medicine/penoxycyline = 10)
	rename_with_volume = TRUE

/datum/reagent/drug/gojuice
	name = "Go-Juice"
	description = "An effective, but addictive stimulant that blocks pain and increases the user's combat effectiveness and movement speed. \
		Addiction causes increased pain and massively reduced movement speed, but last shorter than most."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#52bb38"
	overdose_threshold = 15
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/gojuice = 30) //25-30 units = addiction
	ph = 5
	pain_modifier = 0.1

/datum/reagent/drug/gojuice/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice)
	user.add_mood_event(type, /datum/mood_event/gojuice)
	ADD_TRAIT(user, TRAIT_NIGHT_VISION, type)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT, type)
	user.add_consciousness_modifier(type, 25)

/datum/reagent/drug/gojuice/on_mob_end_metabolize(mob/living/user)
	. = ..()
	stop_effects(user)

/datum/reagent/drug/gojuice/overdose_start(mob/living/user)
	. = ..()
	stop_effects(user)

/datum/reagent/drug/gojuice/on_mob_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	if(overdosed)
		return ..()

	if(SPT_PROB(33, seconds_per_tick))
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1, 3) * REM * seconds_per_tick)
	user.adjust_drowsiness(-5 SECONDS * REM * seconds_per_tick)
	user.set_jitter_if_lower(8 SECONDS * REM * seconds_per_tick)
	return ..()

/datum/reagent/drug/gojuice/overdose_process(mob/living/user, seconds_per_tick, times_fired)
	if(SPT_PROB(66, seconds_per_tick))
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1, 3) * REM * seconds_per_tick)
	if(SPT_PROB(50, seconds_per_tick))
		user.adjustToxLoss(1 * REM * seconds_per_tick, FALSE)
	. = ..()
	return TRUE

/**
 * Remove the effects of the drug.
 */
/datum/reagent/drug/gojuice/proc/stop_effects(mob/living/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_NOSOFTCRIT, type))
		return

	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice)
	user.clear_mood_event(type)
	REMOVE_TRAIT(user, TRAIT_NIGHT_VISION, type)
	REMOVE_TRAIT(user, TRAIT_NOSOFTCRIT, type)
	user.remove_consciousness_modifier(type)

/datum/chemical_reaction/gojuice
	results = list(/datum/reagent/drug/gojuice = 3)
	required_reagents = list(/datum/reagent/neutroamine = 1, /datum/reagent/medicine/synaptizine = 1, /datum/reagent/drug/methamphetamine = 1, /datum/reagent/fuel/oil = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_HARD | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING | REACTION_TAG_PAIN

/obj/item/reagent_containers/cup/glass/bottle/gojuice
	name = "go-juice bottle"
	desc = "A small bottle of Go-Juice, an effective but addictive combat stimulant."
	volume = 20
	possible_transfer_amounts = list(2, 5, 10, 20)
	list_reagents = list(/datum/reagent/drug/gojuice = 20)

/datum/reagent/drug/flake
	name = "Flake"
	description = "A hard drug made from the distant psychoid leaf. While easy to produce and potent, it is also incredibly addictive."
	reagent_state = SOLID
	color = "#c9ffbc"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/psychite = 60) //5u = ~190 points
	ph = 2.1

/datum/reagent/drug/flake/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	user.add_mood_event(type, /datum/mood_event/flake)

/datum/reagent/drug/flake/on_mob_end_metabolize(mob/living/user)
	. = ..()
	user.clear_mood_event(type)

/obj/item/reagent_containers/cup/glass/bottle/flake
	name = "flake bottle"
	desc = "A small bottle that contains Flake, a very addictive and often smoked drug produced from psychoid leaves that causes temporary euphoria."
	volume = 20
	possible_transfer_amounts = list(2, 5, 10, 20)
	list_reagents = list(/datum/reagent/drug/flake = 20)

/datum/reagent/drug/yayo
	name = "Yayo"
	description = "A hard drug made from the distant psychoid leaf. Moderatively addictive and causes mild liver damage, but effective at \
		supressing pain, reducing tiredness, and improving the user's mood."
	taste_description = "chalk"
	reagent_state = SOLID
	color = "#e2e2e2"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/psychite = 35) //5u = ~90 points
	ph = 2.4
	pain_modifier = 0.5

/datum/reagent/drug/yayo/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	user.add_mood_event(type, /datum/mood_event/yayo)
	user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/yayo)

/datum/reagent/drug/yayo/on_mob_end_metabolize(mob/living/user)
	. = ..()
	user.clear_mood_event(type)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/yayo)

/datum/reagent/drug/yayo/on_mob_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	if(SPT_PROB(clamp(current_cycle, 5, 80), seconds_per_tick))
		user.adjustOrganLoss(ORGAN_SLOT_LIVER, 1 * REM * seconds_per_tick)
	if(SPT_PROB(30, seconds_per_tick))
		user.AdjustSleeping(-10 SECONDS * REM * seconds_per_tick)
	user.adjust_drowsiness(-12 SECONDS * REM * seconds_per_tick)
	. = ..()
	return TRUE

/obj/item/reagent_containers/cup/glass/bottle/yayo
	name = "yayo bottle"
	desc = "A small bottle that contains Yayo, a powdery drug produced from psychoid leaves snorted to produce a high, suppress pain, and prevent tiredness."
	volume = 20
	possible_transfer_amounts = list(2, 5, 10, 20)
	list_reagents = list(/datum/reagent/drug/yayo = 20)

/datum/reagent/psychite_tea
	name = "Psychite Tea"
	description = "A soothing tea drink made from the distant psychoid leaves. Reduces pain and improves mood slightly, but is slightly addictive - \
		though less addictive than other chemicals that is made via the psychoid leaf (Yayo and Flake)."
	taste_description = "mint tea"
	reagent_state = LIQUID
	color = "#f5ffbc"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/psychite = 10) //5u = ~30 points
	ph = 6.3
	pain_modifier = 0.9

/datum/reagent/psychite_tea/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	user.add_mood_event(type, /datum/mood_event/psychite_tea)

/datum/reagent/psychite_tea/on_mob_end_metabolize(mob/living/user)
	. = ..()
	user.clear_mood_event(type)

/datum/reagent/psychite_tea/on_mob_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	user.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	user.adjust_dizzy(-4 SECONDS * REM * seconds_per_tick)
	user.adjust_jitter(-4 SECONDS * REM * seconds_per_tick)
	user.AdjustSleeping(-20 * REM * seconds_per_tick)
	user.adjust_body_temperature(WARM_DRINK * REM * seconds_per_tick, max_temp = user.standard_body_temperature)
	. = ..()
	return TRUE

/obj/item/reagent_containers/cup/glass/mug/psychite_tea
	name = "psychite tea"
	desc = "A type of Psychite tea brewed from psychoid leaves. Mildly addictive, but improves mood and reduces pain slightly."
	list_reagents = list(/datum/reagent/psychite_tea = 30)
