//Silicon stuff
/mob/living/silicon
	has_initial_mana_pool = TRUE

/mob/living/silicon/get_initial_mana_pool_type()
	return /datum/mana_pool/mob/living/silicon

/datum/mana_pool/mob/living/silicon
	maximum_mana_capacity = 25


//Carbon stuff
/mob/living/carbon
	has_initial_mana_pool = TRUE

/mob/living/carbon/get_initial_mana_pool_type()
	return /datum/mana_pool/mob/living/carbon

/mob/living/carbon/human/dummy
	has_initial_mana_pool = FALSE

/datum/mana_pool/mob/living/carbon
	maximum_mana_capacity = CARBON_BASE_MANA_CAPACITY

	exponential_decay_divisor = BASE_CARBON_MANA_EXPONENTIAL_DIVISOR

// carbons have softcap mults, this adds it to the pool.
/mob/living/carbon/initialize_mana_pool()
	var/datum/mana_pool/mob/living/carbon/our_pool = ..()

	our_pool.softcap *= get_mana_softcap_mult(mana_pool)

	return our_pool

/mob/living/carbon/proc/get_mana_softcap_mult(datum/mana_pool/pool)
	SHOULD_BE_PURE(TRUE)

	var/mult = 1

	if (mob_biotypes & MOB_ROBOTIC)
		mult *= ROBOTIC_MANA_SOFTCAP_MULT

	return mult

/mob/living/carbon/proc/get_max_mana_capacity_mult()
	SHOULD_BE_PURE(TRUE)

	var/mult = 1

	return mult

/mob/living/carbon/proc/safe_adjust_personal_mana(amount_to_adjust)
// proc for adjusting mana without going over the softcap
	if(mana_pool) // playing it safe, does nothing if you have no mana pool
		if(amount_to_adjust < 0) // if the amount is negative
			if(mana_pool.amount > -amount_to_adjust) // not risking negatives
				mana_pool.adjust_mana(amount_to_adjust)
		else
			if(mana_pool.amount < mana_pool.softcap)
				mana_pool.adjust_mana(amount_to_adjust)

/mob/living/carbon/proc/adjust_personal_mana(amount_to_adjust)
// proc for adjusting mana that CAN go over the softcap
	if(mana_pool) // playing it safe, does nothing if you have no mana pool
		if(amount_to_adjust < 0) // if the amount is negative - you *should* use the above if you know its gonna go into the negatives, though.
			if(mana_pool.amount > -amount_to_adjust) // not risking negatives
				mana_pool.adjust_mana(amount_to_adjust)
		else
			mana_pool.adjust_mana(amount_to_adjust)
