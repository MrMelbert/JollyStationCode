/datum/addiction/psychite
	name = "psychoid"
	withdrawal_stage_messages = list(
		"Some Psychoid would be great right now...",
		"Ugh, I need some Psychoid!",
		"Get me some Psychoid! I can't take this!",
	)
	light_withdrawal_moodlet = /datum/mood_event/psychite_addiction_light
	medium_withdrawal_moodlet = /datum/mood_event/psychite_addiction_medium
	severe_withdrawal_moodlet = /datum/mood_event/psychite_addiction_heavy

/datum/addiction/psychite/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/reagent/psychite_addiction)
	affected_carbon.add_max_consciousness_value(type, 140)

/datum/addiction/psychite/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	if(SPT_PROB(8, seconds_per_tick))
		affected_carbon.adjust_confusion(10 SECONDS)
	if(SPT_PROB(10, seconds_per_tick))
		affected_carbon.adjust_stutter_up_to(6 SECONDS, 30 SECONDS)

/datum/addiction/psychite/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	if(SPT_PROB(8, seconds_per_tick))
		affected_carbon.adjust_confusion(24 SECONDS)
	if(SPT_PROB(15, seconds_per_tick))
		affected_carbon.adjust_stutter_up_to(10 SECONDS, 50 SECONDS)

/datum/addiction/psychite/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/psychite_addiction)
	affected_carbon.remove_max_consciousness_value(type)
