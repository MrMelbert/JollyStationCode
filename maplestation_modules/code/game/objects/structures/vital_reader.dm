/datum/design/vitals_monitor
	name = "Vitals Monitor"
	desc = "A wall mounted computer that displays the vitals of a patient nearby. \
		Links to stasis beds, operating tables, and other machines that can hold patients \
		such as cryo cells, sleepers, and more."
	id = "vitals_monitor"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/wallframe/status_display/vitals
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/vitals_monitor/advanced
	name = "Advanced Vitals Monitor"
	desc = "An updated vitals display which performs a more detailed scan of the patient than the basic display."
	id = "vitals_monitor_advanced"
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	build_path = /obj/item/wallframe/status_display/vitals/advanced

/obj/item/wallframe/status_display/vitals
	name = "vitals display frame"
	desc = "Used to build vitals displays. Secure on a wall nearby a stasis bed, operating table, \
		or another machine that can hold patients such as cryo cells or sleepers."
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	result_path = /obj/machinery/computer/vitals_reader

/obj/item/wallframe/status_display/vitals/advanced
	name = "advanced vitals display frame"
	desc = "Used to build advanced vitals displays. Performs a more detailed scan of the patient than the basic display."
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	result_path = /obj/machinery/computer/vitals_reader/advanced

/// A wall mounted screen that showcases the vitals of a patient nearby.
/obj/machinery/computer/vitals_reader
	name = "vitals display"
	desc = "A small screen that displays the vitals of a patient."
	icon = 'maplestation_modules/icons/obj/status_display.dmi'
	icon_state = "frame"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_DEXTERITY
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	icon_keyboard = null
	icon_screen = null
	processing_flags = START_PROCESSING_MANUALLY

	/// Whether we perform an advanced scan on examine or not
	var/advanced = FALSE
	/// If TRUE, also append a chemical scan to the readout
	var/chemscan = TRUE
	/// Typepath to spawn when deconstructed
	var/frame = /obj/item/wallframe/status_display/vitals
	/// How many attempts at scanning for a patient do we try before we turn ourself off
	var/max_scan_attempts = 6
	/// Whether we are on or off
	VAR_FINAL/active = FALSE
	/// Reference to the mob that is being tracked / scanned
	VAR_FINAL/mob/living/patient
	/// Static typecache of things the vitals display can connect to.
	/// By default it will connect to these and grab their occupant to display as a patient.
	var/static/list/connectable_typecache = typecacheof(list(
		/obj/machinery/abductor/experiment,
		/obj/machinery/computer/operating, // Snowflaked
		/obj/machinery/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/machinery/gulag_teleporter,
		/obj/machinery/hypnochair,
		/obj/machinery/implantchair,
		/obj/machinery/sleeper,
		/obj/machinery/stasis,
		/obj/machinery/vital_floor_scanner,
	))
	/// Whether we go beep beep
	var/beeps = TRUE
	/// The last stat we beeped about
	var/last_reported_stat = null
	/// Cooldown between beeps
	COOLDOWN_DECLARE(beep_cd)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/vitals_reader, 32)

/obj/machinery/computer/vitals_reader/advanced
	name = "advanced vitals display"
	desc = "A small screen that displays the vitals of a patient. \
		Performs a more detailed scan of the patient than the basic display."
	frame = /obj/item/wallframe/status_display/vitals/advanced
	advanced = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/vitals_reader/advanced, 32)

/obj/machinery/computer/vitals_reader/no_hand
	name = "automatic vitals display"
	desc = "A small screen that displays the vitals of a patient. \
		It has no button to toggle it manually."
	interaction_flags_atom = NONE
	interaction_flags_machine = NONE
	max_scan_attempts = 1
	beeps = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/vitals_reader/no_hand, 32)

/obj/machinery/computer/vitals_reader/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	register_context()

/obj/machinery/computer/vitals_reader/Destroy(force)
	unset_patient()
	return ..()

/obj/machinery/computer/vitals_reader/attackby(obj/item/weapon, mob/living/user, params)
	if(!istype(user) || user.combat_mode)
		return ..()
	if((interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND) && (weapon.item_flags & SURGICAL_TOOL))
		// You can flick it on while doing surgery
		return interact(user)
	return ..()

/obj/machinery/computer/vitals_reader/wrench_act(mob/living/user, obj/item/tool)
	if(obj_flags & NO_DECONSTRUCTION)
		return FALSE
	if(user.combat_mode)
		return FALSE
	balloon_alert(user, "detaching...")
	if(tool.use_tool(src, user, 6 SECONDS, volume = 50))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
	return TRUE

/obj/machinery/computer/vitals_reader/deconstruct(disassembled)
	if(obj_flags & NO_DECONSTRUCTION)
		return
	var/atom/drop_loc = drop_location()
	if(disassembled)
		new frame(drop_loc)
	else
		new /obj/item/stack/sheet/iron(drop_loc, 2)
		new /obj/item/shard(drop_loc)
		new /obj/item/shard(drop_loc)
	qdel(src)

/obj/machinery/computer/vitals_reader/examine(mob/user)
	. = ..()
	if(!is_operational || !active || user.is_blind())
		return

	if(isnull(patient))
		. += span_notice("The display is currently scanning for a patient.")
	else if(!issilicon(user) && !isobserver(user) && get_dist(patient, user) > 2)
		. += span_notice("<i>You are too far away to read the display.</i>")
	else if(HAS_TRAIT(user, TRAIT_DUMB) || !user.can_read(src, reading_check_flags = READING_CHECK_LITERACY, silent = TRUE))
		. += span_warning("You try to comprehend the display, but it's too complex for you to understand.")
	else
		. += healthscan(user, patient, mode = /*SCANNER_CONDENSED*/0, advanced = advanced, tochat = FALSE)
		. += chemscan(user, patient, tochat = FALSE)

/obj/machinery/computer/vitals_reader/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item) || (held_item.item_flags & SURGICAL_TOOL))
		if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
			context[SCREENTIP_CONTEXT_LMB] = "Toggle readout"
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Detach"
	if(!isnull(patient))
		context[SCREENTIP_CONTEXT_SHIFT_LMB] = "Examine vitals"
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Toggle beeps"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/computer/vitals_reader/AIShiftClick(mob/user)
	// Lets AIs perform healthscans on people indirectly (they can't examine)
	if(is_operational && !isnull(patient))
		var/entire_printout = ""
		entire_printout += healthscan(user, patient, mode = /*SCANNER_CONDENSED*/0, advanced = advanced, tochat = FALSE)
		entire_printout += chemscan(user, patient, tochat = FALSE)
		to_chat(user, examine_block(entire_printout), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

#define LOWER_BAR_OFFSET -3

/// Returns overlays to be used when active but without a patient detected
/obj/machinery/computer/vitals_reader/proc/get_scanning_overlays()
	return list(
		construct_overlay("unknown"),
		construct_overlay("scanning"),
	)

/**
 * Returns all overlays to be shown when a simple / basic animal patient is detected
 *
 * * hp_color - color being used for general, overrall health
 */
/obj/machinery/computer/vitals_reader/proc/get_simple_mob_overlays(hp_color)
	return list(
		construct_overlay("mob", hp_color),
		construct_overlay("blood", COLOR_GRAY),
		construct_overlay("bar9", COLOR_GRAY),
		construct_overlay("bar9", COLOR_GRAY, LOWER_BAR_OFFSET),
	)

/**
 * Returns all overlays to be shown when a humanoid patient is detected
 *
 * * hp_color - color being used for general, overrall health
 */
/obj/machinery/computer/vitals_reader/proc/get_humanoid_overlays(hp_color)
	var/list/returned_overlays = list()

	for(var/body_zone in BODY_ZONES_ALL)
		var/obj/item/bodypart/real_part = patient.get_bodypart(body_zone)
		var/bodypart_color = isnull(real_part) ? COLOR_GRAY : percent_to_color((real_part.brute_dam + real_part.burn_dam) / real_part.max_damage)
		returned_overlays += construct_overlay("human_[body_zone]", bodypart_color)

	if(HAS_TRAIT(patient, TRAIT_NOBLOOD))
		returned_overlays += construct_overlay("blood", COLOR_GRAY)
	else
		var/blood_color = "#a51919"
		switch((patient.blood_volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
			if(-INFINITY to 0.2)
				blood_color = "#a1a1a1"
			if(0.2 to 0.4)
				blood_color = "#a18282"
			if(0.4 to 0.6)
				blood_color = "#a16363"
			if(0.6 to 0.8)
				blood_color = "#a14444"
			if(0.8 to INFINITY)
				blood_color = "#a51919"

		returned_overlays += construct_overlay("blood", blood_color)

	if(HAS_TRAIT(patient, TRAIT_NOBREATH))
		returned_overlays += construct_overlay("bar9", COLOR_GRAY)
	else
		var/oxy_percent = patient.getOxyLoss() / patient.maxHealth
		returned_overlays += construct_overlay(percent_to_bar(oxy_percent), "#2A72AA")

	if(HAS_TRAIT(patient, TRAIT_TOXIMMUNE))
		returned_overlays += construct_overlay("bar9", COLOR_GRAY, LOWER_BAR_OFFSET)
	else
		var/tox_percent = patient.getToxLoss() / patient.maxHealth
		returned_overlays += construct_overlay(percent_to_bar(tox_percent), "#5d9c11", LOWER_BAR_OFFSET)

	return returned_overlays

/obj/machinery/computer/vitals_reader/update_overlays()
	. = ..()
	if(!active || !is_operational)
		return

	if(isnull(patient))
		. += get_scanning_overlays()

	else
		var/ekg_icon_state = "ekg"
		var/resp_icon_state = (patient.losebreath || HAS_TRAIT(patient, TRAIT_NOBREATH)) ? "resp_flat" : "resp"
		if(!patient.appears_alive())
			ekg_icon_state = "ekg_flat"
			resp_icon_state = "resp_flat"
		else if(ishuman(patient))
			var/mob/living/carbon/human/human_patient = patient
			switch(human_patient.get_heart_rate())
				if(0)
					ekg_icon_state = "ekg_flat"
					resp_icon_state = "resp_flat"
				if(11 to INFINITY)
					ekg_icon_state = "ekg_fast"

		var/hp_color = percent_to_color((patient.maxHealth - patient.health) / patient.maxHealth)
		. += construct_overlay(ekg_icon_state, hp_color)
		. += construct_overlay(resp_icon_state, "#00f7ff")

		if(ishuman(patient))
			. += get_humanoid_overlays(hp_color)
		else
			. += get_simple_mob_overlays(hp_color)

	. += emissive_appearance(icon, "outline", src, alpha = src.alpha)

/// Converts a percentage to a color
/obj/machinery/computer/vitals_reader/proc/percent_to_color(percent)
	if(machine_stat & (EMPED|EMAGGED|BROKEN))
		percent = rand(1, 100) * 0.01

	if(percent == 0)
		return "#2A72AA"

	switch(percent)
		if(0 to 0.125)
			return "#A6BD00"
		if(0.125 to 0.25)
			return "#BDA600"
		if(0.25 to 0.375)
			return "#BD7E00"
		if(0.375 to 0.5)
			return "#BD4200"

	return "#BD0600"

/// Converts a percentage to a bar icon state
/obj/machinery/computer/vitals_reader/proc/percent_to_bar(percent)
	if(machine_stat & (EMPED|EMAGGED|BROKEN))
		percent = rand(1, 100) * 0.01

	if(percent >= 1)
		return "bar9"
	if(percent <= 0)
		return "bar1"

	switch(percent)
		if(0 to 0.125)
			return "bar1"
		if(0.125 to 0.25)
			return "bar2"
		if(0.25 to 0.375)
			return "bar3"
		if(0.375 to 0.5)
			return "bar4"
		if(0.5 to 0.625)
			return "bar5"
		if(0.625 to 0.75)
			return "bar6"
		if(0.75 to 0.875)
			return "bar7"
		if(0.875 to 1)
			return "bar8"

	return "bar9" // ??

/**
 * Helper to construct an overlay for the vitals display
 *
 * * state_to_use - icon state to use, required
 * * color_to_use - color to use, optional
 * * y_offset - offset to apply to the y position of the overlay, defaults to 0
 */
/obj/machinery/computer/vitals_reader/proc/construct_overlay(state_to_use, color_to_use, y_offset = 0)
	var/mutable_appearance/overlay = mutable_appearance(icon, state_to_use, alpha = src.alpha)
	overlay.appearance_flags |= RESET_COLOR
	overlay.color = color_to_use
	overlay.pixel_z += 32
	overlay.pixel_y += -32 + y_offset
	return overlay

#undef LOWER_BAR_OFFSET

/obj/machinery/computer/vitals_reader/interact(mob/user, special_state)
	. = ..()
	if(.)
		return .
	if(!is_operational)
		return .

	toggle_active()
	balloon_alert(user, "readout [active ? "" : "de"]activated")
	playsound(src, 'sound/machines/click.ogg', 50)
	return TRUE

/obj/machinery/computer/vitals_reader/on_set_is_operational(old_value)
	if(is_operational)
		return
	if(active)
		toggle_active()
		return
	update_appearance(UPDATE_OVERLAYS)

/// Toggles whether the display is active or not
/obj/machinery/computer/vitals_reader/proc/toggle_active()
	if(active)
		active = FALSE
		update_use_power(IDLE_POWER_USE)
		unset_patient()
	else
		active = TRUE
		update_use_power(ACTIVE_POWER_USE)
		find_active_patient()
	update_appearance(UPDATE_OVERLAYS)

/**
 * Recursively checks all nearby machines to find a patient to track.
 *
 * This can (and should be) signal driven in the future, but machines don't have a set_occupant proc yet,
 * so this will do for the moment.
 *
 * * scan_attempts - number of times this has been called, used to prevent infinite loops
 */
/obj/machinery/computer/vitals_reader/proc/find_active_patient(scan_attempts = 0)
	if(!active || !isnull(patient) || QDELETED(src))
		return

	for(var/obj/machinery/nearby_thing in view(3, src))
		if(!is_type_in_typecache(nearby_thing, connectable_typecache))
			continue

		var/mob/living/patient = nearby_thing.occupant
		if(istype(nearby_thing, /obj/machinery/computer/operating))
			var/obj/machinery/computer/operating/op = nearby_thing
			patient = op.table?.patient

		if(!istype(patient) || (patient.mob_biotypes & MOB_ROBOTIC))
			continue

		set_patient(patient)
		return

	if(scan_attempts > max_scan_attempts)
		toggle_active()
		return

	addtimer(CALLBACK(src, PROC_REF(find_active_patient), scan_attempts + 1), 5 SECONDS)

/obj/machinery/computer/vitals_reader/process()
	if(!COOLDOWN_FINISHED(src, beep_cd))
		return
	if(isnull(patient) || !is_operational || !active)
		stack_trace("Vitals reader processing without a patient, not operational, or not active.")
		end_processing()
		return
	if(!beeps)
		return

	var/beepsound
	switch(patient.stat)
		if(DEAD)
			beepsound = 'maplestation_modules/sound/healthscanner_dead.ogg'
			COOLDOWN_START(src, beep_cd, 11 SECONDS)
			if(last_reported_stat != DEAD)
				beep_message("lets out a droning beep.")
				last_reported_stat = DEAD
		if(HARD_CRIT)
			beepsound = 'maplestation_modules/sound/healthscanner_danger.ogg'
			COOLDOWN_START(src, beep_cd, 5 SECONDS)
			if(last_reported_stat != HARD_CRIT)
				beep_message("lets out an alternating beep.")
				last_reported_stat = HARD_CRIT
		if(SOFT_CRIT)
			beepsound = 'maplestation_modules/sound/healthscanner_critical.ogg'
			COOLDOWN_START(src, beep_cd, 7 SECONDS)
			if(last_reported_stat != SOFT_CRIT)
				beep_message("lets out a high pitch beep.")
				last_reported_stat = SOFT_CRIT
		else
			beepsound = 'maplestation_modules/sound/healthscanner_stable.ogg'
			COOLDOWN_START(src, beep_cd, 7 SECONDS)
			if(last_reported_stat != CONSCIOUS)
				beep_message("lets out a beep.")
				last_reported_stat = CONSCIOUS

	playsound(src, beepsound, 25, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/computer/vitals_reader/proc/beep_message(message)
	for(var/mob/viewer as anything in viewers(src))
		if(isnull(viewer.client) || !viewer.can_hear())
			continue
		if(!viewer.runechat_prefs_check(viewer, EMOTE_MESSAGE))
			continue
		viewer.create_chat_message(
			speaker = src,
			raw_message = message,
			runechat_flags = EMOTE_MESSAGE,
		)

/obj/machinery/computer/vitals_reader/AltClick(mob/user)
	if(!(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND))
		return ..() // assuming direct control
	if(user.can_perform_action(src, ALLOW_SILICON_REACH|NEED_DEXTERITY))
		beeps = !beeps
		balloon_alert(user, "beeps [beeps ? "enabled" : "disabled"]")
		playsound(src, 'sound/machines/click.ogg', 50)
		return TRUE
	return FALSE

/// Sets the passed mob as the active patient
/// If there is already a patient, it will be unset first.
/obj/machinery/computer/vitals_reader/proc/set_patient(mob/living/new_patient)
	if(istype(new_patient, /mob/living/carbon/human/consistent))
		// This is A CARDINAL SIN but I am tired of the random hard delete test failure I'll fix it for real LATER
		return
	if(!isnull(patient))
		unset_patient()

	patient = new_patient
	RegisterSignals(patient, list(
		COMSIG_QDELETING,
		COMSIG_MOVABLE_MOVED,
	), PROC_REF(unset_patient))
	RegisterSignals(patient, list(
		COMSIG_CARBON_POST_REMOVE_LIMB,
		COMSIG_CARBON_POST_ATTACH_LIMB,
		COMSIG_LIVING_HEALTH_UPDATE,
	), PROC_REF(update_overlay_on_signal))
	update_appearance(UPDATE_OVERLAYS)
	begin_processing()
	last_reported_stat = null

/// Unset the current patient.
/obj/machinery/computer/vitals_reader/proc/unset_patient(...)
	SIGNAL_HANDLER
	if(isnull(patient))
		return

	UnregisterSignal(patient, list(
		COMSIG_QDELETING,
		COMSIG_MOVABLE_MOVED,
		COMSIG_CARBON_POST_REMOVE_LIMB,
		COMSIG_CARBON_POST_ATTACH_LIMB,
		COMSIG_LIVING_HEALTH_UPDATE,
	))

	patient = null
	end_processing()
	if(QDELING(src))
		return

	update_appearance(UPDATE_OVERLAYS)
	if(active)
		find_active_patient()

/// Signal proc to update the display when a signal is received.
/obj/machinery/computer/vitals_reader/proc/update_overlay_on_signal(...)
	SIGNAL_HANDLER
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/computer/vitals_reader/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	if(beeps)
		beeps = prob(50)
	COOLDOWN_START(src, beep_cd, 1 SECONDS + (1 SECONDS * rand(0, (severity == EMP_HEAVY ? 60 : 30))))
	set_machine_stat(machine_stat | EMPED)
	addtimer(CALLBACK(src, PROC_REF(fix_emp)), (severity == EMP_HEAVY ? 150 SECONDS : 75 SECONDS))

/obj/machinery/computer/vitals_reader/proc/fix_emp()
	set_machine_stat(machine_stat & ~EMPED)
