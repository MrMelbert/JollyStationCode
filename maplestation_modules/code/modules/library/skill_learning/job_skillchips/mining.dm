// -- Modular job skillchips. --
// Skillchip for miners that gives pain resistance when off the station's Z level.
/obj/item/skillchip/job/off_z_pain_resistance
	name = "D1GGY skillchip"
	skill_name = "Off Station Pain Resistance"
	skill_description = "For the adventurous in life, this skillchip provides a reduction in pain received when off the station."
	skill_icon = "fist-raised"
	activate_message = span_notice("You feel like you can safely take on the unknown.")
	deactivate_message = span_notice("You feel more vulnerable to the unknown.")

/obj/item/skillchip/job/off_z_pain_resistance/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_z))

/obj/item/skillchip/job/off_z_pain_resistance/on_deactivate(mob/living/carbon/user, silent = FALSE)
	UnregisterSignal(user, COMSIG_MOVABLE_Z_CHANGED)
	user.unset_pain_mod(PAIN_MOD_OFF_STATION)
	return ..()


/**
 * Signal proc for [COMSIG_MOVABLE_Z_CHANGED].
 *
 * Checks if the new Z is valid for the skillchip.
 */
/obj/item/skillchip/job/off_z_pain_resistance/proc/check_z(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(!iscarbon(source) || !isturf(new_turf))
		return

	var/mob/living/carbon/carbon_source = source
	if(is_station_level(new_turf.z))
		if(carbon_source.unset_pain_mod(PAIN_MOD_OFF_STATION))
			to_chat(carbon_source, span_green("Returning to the station, you feel much more vulnerable to incoming pain."))
	else
		if(carbon_source.set_pain_mod(PAIN_MOD_OFF_STATION, 0.5))
			to_chat(carbon_source, span_green("As you depart from the station, you feel more resilient to incoming pain."))

/datum/outfit/job/miner
	skillchips = list(/obj/item/skillchip/job/off_z_pain_resistance)

/obj/item/storage/box/skillchips/cargo
	name = "box of cargo skillchips"
	desc = "Contains spares of every cargo job skillchip."

/obj/item/storage/box/skillchips/cargo/PopulateContents()
	new /obj/item/skillchip/job/off_z_pain_resistance(src)
	new /obj/item/skillchip/job/off_z_pain_resistance(src)

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	. = ..()
	new /obj/item/storage/box/skillchips/cargo(src)
