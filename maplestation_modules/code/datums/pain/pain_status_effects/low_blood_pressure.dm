/datum/status_effect/low_blood_pressure
	id = "low_blood_pressure"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

/datum/status_effect/low_blood_pressure/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod *= 0.75
	RegisterSignal(owner, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))
	return TRUE

/datum/status_effect/low_blood_pressure/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod /= 0.75
	UnregisterSignal(owner, COMSIG_LIVING_HEALTHSCAN)

/datum/status_effect/low_blood_pressure/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	if(!HAS_TRAIT(owner, TRAIT_STASIS))
		if(SPT_PROB(20, seconds_between_ticks))
			owner.adjust_jitter_up_to(5 SECONDS, 60 SECONDS)
		if(SPT_PROB(10, seconds_between_ticks))
			owner.adjust_dizzy_up_to(5 SECONDS, 60 SECONDS)
		if(SPT_PROB(0.1, seconds_between_ticks))
			owner.emote("faint")
	if(SPT_PROB(10, seconds_between_ticks))
		owner.adjust_eye_blur_up_to(5 SECONDS, 60 SECONDS)

/datum/status_effect/low_blood_pressure/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	render_list += "<span class='alert ml-1'>Hypotension detected.</span><br>"
