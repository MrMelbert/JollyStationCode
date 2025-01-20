/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 5
	agent = "H13N1 flu virion"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	severity = DISEASE_SEVERITY_MINOR
	required_organ = ORGAN_SLOT_LUNGS

/datum/disease/flu/remove_disease()
	affected_mob.remove_consciousness_modifier(type)
	return ..()

/datum/disease/flu/update_stage(new_stage)
	. = ..()
	affected_mob.add_consciousness_modifier(type, -5 * new_stage)

/datum/disease/flu/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your muscles ache."))
				if(prob(20))
					affected_mob.damage_random_bodypart(1)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your stomach hurts."))
				if(prob(20))
					affected_mob.apply_damage(1, TOX)
			if(affected_mob.body_position == LYING_DOWN && SPT_PROB(10, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				stage--
				return

		if(3)
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("sneeze")
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your muscles ache."))
				if(prob(20))
					affected_mob.damage_random_bodypart(1)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your stomach hurts."))
				if(prob(20))
					affected_mob.apply_damage(1, TOX)
			if(affected_mob.body_position == LYING_DOWN && SPT_PROB(7.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				stage--
				return
