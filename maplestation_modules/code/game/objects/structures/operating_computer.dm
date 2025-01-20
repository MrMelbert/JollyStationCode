/obj/machinery/computer/operating

/obj/machinery/computer/operating/attackby(obj/item/weapon, mob/living/user, params)
	if(!istype(user) || user.combat_mode)
		return ..()
	if(weapon.item_flags & SURGICAL_TOOL)
		// You can open it while doing surgery
		return interact(user)
	return ..()

/obj/machinery/computer/operating/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	if(!is_operational)
		return

	obj_flags |= EMAGGED
	balloon_alert(user, "safeties overridden")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/computer/operating/on_set_is_operational(old_value)
	if(is_operational)
		return
	// Losing power / getting broken will auto disable anesthesia
	table.safety_disable()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = ..()
	if(isnull(table))
		return data

	var/tank_exists = !isnull(table.attached_tank)
	data["anesthesia"] = list(
		"has_tank" = tank_exists,
		"open" = tank_exists && table.patient?.external == table.attached_tank,
		"can_open_tank" = tank_exists && table.can_have_tank_opened(table.patient),
		"failsafe" = table.failsafe_time == INFINITY ? -1 : (table.failsafe_time / 10),
	)

	if(isnull(table.patient))
		return data

	var/obj/item/organ/patient_brain = table.patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	data["patient"]["brain"] = isnull(patient_brain) ? 100 : ((patient_brain.damage / patient_brain.maxHealth) * 100)
	data["patient"]["bloodVolumePercent"] = round((table.patient.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
	data["patient"]["heartRate"] = table.patient.get_bpm()
	// We can also show pain and stuff here if we want.

	return data

/obj/machinery/computer/operating/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || isnull(table))
		return

	switch(action)
		if("toggle_anesthesia")
			if(iscarbon(usr))
				var/mob/living/carbon/toggler = usr
				if(toggler == table.patient && table.patient_set_at == -1 && table.failsafe_time >= 5 MINUTES)
					to_chat(toggler, span_warning("You feel as if you know better than to do that."))
					return FALSE

			table.toggle_anesthesia()
			return TRUE

		if("set_failsafe")
			table.failsafe_time = clamp(text2num(params["new_failsafe_time"]) * 10, 5 SECONDS, 10 MINUTES)
			return TRUE

		if("disable_failsafe")
			table.failsafe_time = INFINITY
			return TRUE
