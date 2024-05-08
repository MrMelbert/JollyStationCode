/datum/status_effect/heart_attack
	id = "heart_attack"
	alert_type = null
	tick_interval = 2 SECONDS
	/// TimerID for the initial knock out
	VAR_FINAL/ko_timer

/datum/status_effect/heart_attack/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(isnull(carbon_owner.dna?.species?.mutantheart))
		return FALSE

	RegisterSignal(owner, COMSIG_SPECIES_GAIN, PROC_REF(species_changed))
	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(block_breath))

	// You get 1 tick of grace before you fall over due to your heart stopping
	ko_timer = addtimer(CALLBACK(src, PROC_REF(delayed_ko)), initial(tick_interval), TIMER_STOPPABLE)
	return TRUE

/datum/status_effect/heart_attack/on_remove()
	deltimer(ko_timer)

	UnregisterSignal(owner, list(
		COMSIG_CARBON_ATTEMPT_BREATHE,
		COMSIG_SPECIES_GAIN,
		SIGNAL_ADDTRAIT(TRAIT_NOBREATH),
		SIGNAL_REMOVETRAIT(TRAIT_NOBREATH),
	))

	if(!QDELING(owner))
		owner.cause_pain(BODY_ZONE_CHEST, -20)
		LAZYREMOVE(owner.consciousness_multipliers, id)
		LAZYREMOVE(owner.max_consciousness_values, id)

/datum/status_effect/heart_attack/proc/delayed_ko()
	ko_timer = null
	update_nobreath()
	RegisterSignals(owner, list(
		SIGNAL_ADDTRAIT(TRAIT_NOBREATH),
		SIGNAL_REMOVETRAIT(TRAIT_NOBREATH),
	), PROC_REF(update_nobreath))

/datum/status_effect/heart_attack/proc/species_changed(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	if(isnull(new_species.mutantheart))
		qdel(src)

/datum/status_effect/heart_attack/proc/update_nobreath(datum/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT(owner, TRAIT_NOBREATH))
		LAZYREMOVE(owner.consciousness_multipliers, id)
		LAZYREMOVE(owner.max_consciousness_values, id)
	else
		LAZYSET(owner.consciousness_multipliers, id, 0.5)
		LAZYSET(owner.max_consciousness_values, id, 30)

/datum/status_effect/heart_attack/proc/block_breath(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_NOBREATH))
		return NONE

	if(prob(10))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "gasp")

	return COMSIG_CARBON_BLOCK_BREATH

/datum/status_effect/heart_attack/tick(seconds_between_ticks)
	if(ko_timer) // Not yet
		return
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_STABLEHEART) || HAS_TRAIT(owner, TRAIT_NOBLOOD) || HAS_TRAIT(owner, TRAIT_STASIS))
		return
	if(owner.has_status_effect(/datum/status_effect/cpr_applied))
		return

	if(!HAS_TRAIT(owner, TRAIT_NOBREATH))
		owner.adjustOxyLoss(4 * seconds_between_ticks)

	// Tissues die without blood circulation
	owner.adjustBruteLoss(1 * seconds_between_ticks)
