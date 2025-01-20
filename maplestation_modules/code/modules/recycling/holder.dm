// -- File to make disposals hurt when people tumble through them --
/datum/config_entry/number/disposals_damage_multiplier
	default = 1

/datum/config_entry/number/disposals_damage_chance
	default = 10
	min_val = 0
	max_val = 100

/datum/config_entry/number/disposals_pain_chance
	default = 10
	min_val = 0
	max_val = 100

/obj/structure/disposalholder/try_expel(datum/move_loop/source, succeed, visual_delay)
	. = ..()
	if(!current_pipe && active)
		return

	// Checks if there's an outlet so it doesn't keep trying to damage you there.
	if(locate(/obj/structure/disposaloutlet) in get_turf(src))
		return

	for(var/mob/living/trashed_individual in src)
		if(prob(20))
			playsound(loc, 'sound/effects/clang.ogg', 30, TRUE, FALSE)
		else if(CONFIG_GET(number/disposals_damage_chance))
			trashed_individual.apply_damage(2 * CONFIG_GET(number/disposals_damage_multiplier), BRUTE)
			playsound(loc, 'sound/effects/wounds/crack2.ogg', 50, TRUE, FALSE)
		else if(CONFIG_GET(number/disposals_pain_chance))
			var/mob/living/carbon/carbon_trashed = trashed_individual
			playsound(loc, 'sound/effects/wounds/crack1.ogg', 50, TRUE, FALSE)
			carbon_trashed.sharp_pain(pick(BODY_ZONES_ALL), 4 * CONFIG_GET(number/disposals_damage_multiplier), BRUTE)
