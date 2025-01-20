/datum/addiction/opioids
	withdrawal_stage_messages = list(
		"My body aches all over...",
		"I need some pain relief...",
		"It hurts all over...I need some opioids!",
	)

/datum/addiction/opioids/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	if(affected_carbon.pain_controller?.get_total_pain() <= 50 && SPT_PROB(8, seconds_per_tick))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 0.5 * seconds_per_tick)

/datum/addiction/opioids/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	if(affected_carbon.pain_controller?.get_total_pain() <= 100 && SPT_PROB(8, seconds_per_tick))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 1 * seconds_per_tick)

/datum/addiction/opioids/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	if(affected_carbon.pain_controller?.get_total_pain() <= 150 && SPT_PROB(8, seconds_per_tick))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 1.5 * seconds_per_tick)
