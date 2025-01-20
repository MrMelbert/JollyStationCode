// -- Go-Juice addiction --
// Progresses slightly faster

#define PAIN_MOD_GOJUICE_ADDICT "gojuice_addict"

/datum/addiction/gojuice
	name = "go-juice"
	addiction_gain_threshold = 450
	addiction_loss_threshold = 100
	addiction_loss_per_stage = list(1, 1.5, 2, 3)
	high_sanity_addiction_loss = 1
	withdrawal_stage_messages = list(
		"I feel slow... I need some Go-Juice.",
		"Everything is slowing down... I could use some Go-Juice!",
		"I need Go-Juice, this is unbearable!",
	)
	light_withdrawal_moodlet = /datum/mood_event/gojuice_addiction_light
	medium_withdrawal_moodlet = /datum/mood_event/gojuice_addiction_medium
	severe_withdrawal_moodlet = /datum/mood_event/gojuice_addiction_heavy

/datum/addiction/gojuice/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.set_pain_mod(PAIN_MOD_GOJUICE_ADDICT, 1.5)
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice_addiction)
	affected_carbon.add_max_consciousness_value(type, 145)
	affected_carbon.add_consciousness_modifier(type, -5)

/datum/addiction/gojuice/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	affected_carbon.adjust_nutrition(-HUNGER_FACTOR * seconds_per_tick)

/datum/addiction/gojuice/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	affected_carbon.become_nearsighted(type)
	affected_carbon.set_pain_mod(PAIN_MOD_GOJUICE_ADDICT, 2)
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice_addiction)
	affected_carbon.add_max_consciousness_value(type, 140)
	affected_carbon.add_consciousness_modifier(type, -10)

/datum/addiction/gojuice/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	affected_carbon.adjust_nutrition(-HUNGER_FACTOR * seconds_per_tick)
	if(SPT_PROB(66, seconds_per_tick))
		affected_carbon.adjust_drowsiness_up_to(2 SECONDS * REM * seconds_per_tick, 10 SECONDS)
	if(SPT_PROB(8, seconds_per_tick))
		affected_carbon.adjust_confusion(10 SECONDS)

/datum/addiction/gojuice/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	affected_carbon.set_pain_mod(PAIN_MOD_GOJUICE_ADDICT, 3)
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice_addiction)
	affected_carbon.add_max_consciousness_value(type, 130)
	affected_carbon.add_consciousness_modifier(type, -20)

/datum/addiction/gojuice/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, seconds_per_tick)
	. = ..()
	affected_carbon.adjust_nutrition(-HUNGER_FACTOR * seconds_per_tick)
	if(SPT_PROB(75, seconds_per_tick))
		affected_carbon.adjust_drowsiness_up_to(2 SECONDS * REM * seconds_per_tick, 20 SECONDS)
	if(SPT_PROB(8, seconds_per_tick))
		affected_carbon.adjust_confusion(16 SECONDS)

/datum/addiction/gojuice/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.cure_nearsighted(type)
	affected_carbon.unset_pain_mod(PAIN_MOD_GOJUICE_ADDICT)
	affected_carbon.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/gojuice_addiction)
	affected_carbon.remove_consciousness_modifier(type)
	affected_carbon.remove_max_consciousness_value(type)
