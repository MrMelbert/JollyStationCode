/**Fever
 * No change to stealth
 * Increases resistance considerably
 * Increases stage speed considerably
 * Increases transmissibility
 * Low level
 * Bonus: Heats up your body
 */

/datum/symptom/fever
	name = "Fever"
	desc = "The virus causes a febrile response from the host, raising its body temperature."
	illness = "Burning Desire"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2
	base_message_chance = 20
	symptom_delay_min = 10
	symptom_delay_max = 30
	threshold_descs = list(
		"Resistance 5" = "Increases fever intensity, fever can overheat and harm the host.",
		"Resistance 10" = "Further increases fever intensity.",
	)
	var/heat_cap = 6 KELVIN

/datum/symptom/fever/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 5)
		heat_cap = 30 KELVIN
		power = 2
	if(A.totalResistance() >= 10)
		heat_cap = 60 KELVIN
		power = 4

/datum/symptom/fever/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(heat_cap <= 6 KELVIN || A.stage < 4)
		to_chat(M, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))
	else
		to_chat(M, span_userdanger("[pick("You feel too hot.", "You feel like your blood is boiling.")]"))
	set_body_temp(A)

/datum/symptom/fever/proc/set_body_temp(datum/disease/advance/disease)
	var/mob/living/affected = disease.affected_mob
	var/new_level = affected.standard_body_temperature + (heat_cap * (disease.stage / disease.max_stages))
	affected.add_homeostasis_level(type, new_level, 0.25 KELVIN * power)

/// Update the body temp change based on the new stage
/datum/symptom/fever/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A)

/// remove the body temp change when removing symptom
/datum/symptom/fever/End(datum/disease/advance/A)
	A.affected_mob?.remove_homeostasis_level(type)
