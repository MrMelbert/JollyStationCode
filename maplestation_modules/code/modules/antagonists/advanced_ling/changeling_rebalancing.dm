// -- Rebalancing of other ling actions --
// Buffs adrenal sacs so they work like old adrenals. Increased chemical cost to compensate.
/datum/action/changeling/adrenaline
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 40 chemicals."
	chemical_cost = 40

/datum/action/changeling/adrenaline/sting_action(mob/living/user)
	user.adjustStaminaLoss(-75)
	user.set_resting(FALSE, instant = TRUE)
	user.SetStun(0)
	user.SetImmobilized(0)
	user.SetParalyzed(0)
	user.SetKnockdown(0)
	. = ..()

// Disables spread infestation.
/datum/action/changeling/spiders
	dna_cost = -1

// Disables transform sting.
/datum/action/changeling/sting/transformation
	dna_cost = -1

/// Extension of attempt_absorb, for changeling cannot absorb their own spawn
/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/user)
	var/mob/living/target = user.pulling
	var/datum/antagonist/changeling/fresh/their_ling_datum = is_fresh_changeling(target)
	if(their_ling_datum?.granter?.resolve() == user.mind)
		to_chat(user, span_warning("You cannot absorb your own changeling spawn!"))
		return FALSE

	var/datum/action/changeling/grant_powers/powers_action = locate() in user.actions
	if(powers_action?.is_uplifting)
		to_chat(user, span_warning("You are currently uplifting someone!"))
		return FALSE

	var/datum/antagonist/changeling/our_ling_datum = is_any_changeling(user)
	var/datum/advanced_antag_datum/changeling/our_advanced_datum = our_ling_datum?.linked_advanced_datum
	if(our_advanced_datum?.no_hard_absorb) // They shouldn't be able to reach this (no ability), but just in case.
		to_chat(user, span_warning("We gave up the ability to absorb creatures!"))
		return FALSE

	. = ..()


/datum/action/changeling/pheromone_receptors/can_be_used_by(mob/user)
	. = ..()
	if(!.)
		return

	var/static/list/lings_that_cannot_use_this = list(
		/datum/antagonist/changeling/fresh,
		/datum/antagonist/fallen_changeling,
		/datum/antagonist/changeling/headslug,
	)

	var/datum/antagonist/ling_datum = is_any_changeling(user)
	if(ling_datum.type in lings_that_cannot_use_this)
		to_chat(user, span_changeling("You are not developed enough as a changeling to use this!"))
		return FALSE

	return TRUE
