/// --- Fax Machines. ---
/// GLOB list of all fax machines.
GLOBAL_LIST_EMPTY(fax_machines)

/// Cooldown for fax time between faxes.
#define FAX_COOLDOWN_TIME 3 MINUTES

/// The time between alerts that the machine contains an unread message.
#define FAX_UNREAD_ALERT_TIME 3 MINUTES

/// The max amount of chars displayed in a fax message
#define MAX_DISPLAYED_PAPER_CHARS 475

/// Fax machine design, for techwebs.
/datum/design/board/fax_machine
	name = "Machine Design (Fax Machine Board)"
	desc = "The circuit board for a Fax Machine."
	id = "fax_machine"
	build_path = /obj/item/circuitboard/machine/fax_machine
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_SECURITY

/// Fax machine circuit.
/obj/item/circuitboard/machine/fax_machine
	name = "Fax Machine (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/fax_machine
	req_components = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stack/sheet/glass = 1,
		)

/// Fax machine. Sends messages, recieves messages, sends paperwork, recieves paperwork.
/obj/machinery/fax_machine
	name = "fax machine"
	desc = "A machine made to send faxes and process paperwork. You unbelievably boring person."
	icon = 'jollystation_modules/icons/obj/machines/fax.dmi'
	icon_state = "fax"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	req_one_access = list(ACCESS_HEADS, ACCESS_LAWYER)
	circuit = /obj/item/circuitboard/machine/fax_machine
	/// Whether this fax machine is locked.
	var/locked = TRUE
	/// The area string this fax machine is set to.
	var/room_tag
	/// Whether this fax machine can recieve paperwork to process on SSeconomy ticks.
	var/can_recieve = FALSE
	/// Whether we have an unread message
	var/unread_message = FALSE
	/// The paper stored that we can send to admins.
	var/obj/item/paper/stored_paper
	/// The paper recieved that was sent FROM admins.
	var/obj/item/paper/recieved_paper
	/// List of all paperwork we have in this fax machine.
	var/list/obj/item/paper/processed/recieved_paperwork
	/// Max amount of paperwork we can hold. Any more and the UI gets less readable.
	var/max_paperwork = 8
	/// Cooldown between sending faxes
	COOLDOWN_DECLARE(fax_cooldown)

/obj/machinery/fax_machine/Initialize()
	. = ..()
	GLOB.fax_machines += src
	room_tag = get_area_name(src, TRUE) // no proper or improper tags on this
	name = "[get_area_name(src, FALSE)] [name]"

/obj/machinery/fax_machine/full/Initialize()
	. = ..()
	for(var/i in 1 to 8)
		if(LAZYLEN(recieved_paperwork) >= max_paperwork)
			continue
		LAZYADD(recieved_paperwork, generate_paperwork(src))

/obj/machinery/fax_machine/Destroy()
	eject_all_paperwork()
	eject_stored_paper()
	eject_recieved_paper()

	GLOB.fax_machines -= src
	return ..()

/obj/machinery/fax_machine/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "_FaxMachine", name)
		ui.open()

/obj/machinery/fax_machine/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/fax_machine/ui_data(mob/user)
	var/list/data = list()

	var/emagged = obj_flags & EMAGGED
	var/list/all_recieved_paperwork = list()
	var/iterator = 1
	for(var/obj/item/paper/processed/paper as anything in recieved_paperwork)
		var/list/found_paper_data = list()
		found_paper_data["title"] = paper.name
		found_paper_data["contents"] = TextPreview(remove_all_tags(paper.info), MAX_DISPLAYED_PAPER_CHARS)
		found_paper_data["required_answer"] = paper.required_question
		found_paper_data["ref"] = REF(paper)
		found_paper_data["num"] = iterator++
		all_recieved_paperwork += list(found_paper_data)
	if(all_recieved_paperwork.len)
		data["recieved_paperwork"] = all_recieved_paperwork

	if(stored_paper)
		var/list/stored_paper_data = list()
		stored_paper_data["title"] = stored_paper.name
		//stored_paper_data["raw_contents"] = stored_paper.info
		stored_paper_data["contents"] = TextPreview(remove_all_tags(stored_paper.info), MAX_DISPLAYED_PAPER_CHARS)
		stored_paper_data["ref"] = REF(stored_paper_data)
		data["stored_paper"] = stored_paper_data

	if(recieved_paper)
		var/list/recieved_paper_data = list()
		recieved_paper_data["title"] = recieved_paper.name
		//recieved_paper_data["raw_contents"] = recieved_paper.info
		recieved_paper_data["contents"] = TextPreview(remove_all_tags(recieved_paper.info), MAX_DISPLAYED_PAPER_CHARS)
		recieved_paper_data["source"] = recieved_paper.was_faxed_from
		recieved_paper_data["ref"] = REF(recieved_paper)
		data["recieved_paper"] = recieved_paper_data

	if(emagged)
		var/emagged_text = ""
		for(var/i in 1 to rand(4, 7))
			emagged_text += pick("!","@","#","$","%","^","&")
		data["display_name"] = emagged_text
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/obj/item/card/id/our_id = human_user.wear_id?.GetID()
		data["display_name"] = our_id?.registered_name || "\[REDACTED\]"
	else if(issilicon(user))
		data["display_name"] = user.real_name
	else
		data["display_name"] = "\[REDACTED\]"

	var/admin_destination = (emagged ? SYNDICATE_FAX_MACHINE : CENTCOM_FAX_MACHINE)
	var/list/possible_destinations = list()
	possible_destinations += admin_destination
	for(var/obj/machinery/fax_machine/machine as anything in GLOB.fax_machines)
		possible_destinations += machine.room_tag
	data["destination_options"] = possible_destinations
	data["default_destination"] = admin_destination
	data["can_send_cc_messages"] = (allowed(user) || emagged) && COOLDOWN_FINISHED(src, fax_cooldown)
	data["can_recieve"] = can_recieve
	data["emagged"] = emagged
	data["unread_message"] = unread_message

	return data

/obj/machinery/fax_machine/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("un_emag_machine")
			to_chat(usr, span_notice("You restore [src]'s routing information to Central Command."))
			obj_flags &= ~EMAGGED

		if("toggle_recieving")
			can_recieve = !can_recieve

		if("read_last_recieved")
			unread_message = FALSE

		if("send_stored_paper")
			send_stored_paper(usr, params["destination_machine"])

		if("print_recieved_paper")
			eject_recieved_paper(usr, FALSE)

		if("print_select_paperwork")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			eject_select_paperwork(usr, paper, FALSE)

		if("print_all_paperwork")
			eject_all_paperwork_with_delay(usr)

		if("delete_select_paperwork")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			delete_select_paperwork(paper)

		if("check_paper")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			check_paperwork(paper, usr)

	return TRUE

/obj/machinery/fax_machine/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(locked && !issilicon(user))
		to_chat(user, span_warning("[src]'s maintenance panel is ID locked. Swipe your ID to unlock it."))
		return FALSE
	return ..()

/obj/machinery/fax_machine/attackby(obj/item/weapon, mob/user, params)
	if(!isliving(user))
		return ..()

	if(istype(weapon, /obj/item/paper/processed))
		insert_processed_paper(weapon, user)
		return
	else if(istype(weapon, /obj/item/paper))
		var/obj/item/paper/inserted_paper = weapon
		if(inserted_paper.was_faxed_from in GLOB.admin_fax_destinations)
			to_chat(user, span_warning("[inserted_paper.was_faxed_from]'s papers cannot be re-faxed."))
			return
		else
			insert_paper(inserted_paper, user)
			return

	if(weapon.GetID())
		if(check_access(weapon.GetID()))
			locked = !locked
			balloon_alert(user, "[locked ? "maintenance panel locked" : "maintenance panel unlocked"]")
			return

	return ..()

/obj/machinery/fax_machine/attack_hand(mob/user, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		eject_stored_paper(user, FALSE)
		return TRUE
	return ..()

/obj/machinery/fax_machine/examine(mob/user)
	. = ..()
	if(stored_paper)
		. += span_notice("Right click to remove the stored fax.")

/*
 * Send [stored_paper] from [user] to [destinatoin].
 * if [destination] is an admin fax machine, send it to admins.
 * Otherwise, send it to the corresponding fax machine in the world, looking for (room_tag == [destination])
 *
 * returns TRUE if the fax was sent.
 */
/obj/machinery/fax_machine/proc/send_stored_paper(mob/living/user, destination)
	if((machine_stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE))
		return FALSE

	if(!stored_paper || !length(stored_paper.info) || !COOLDOWN_FINISHED(src, fax_cooldown))
		balloon_alert_to_viewers("fax failed to send")
		playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
		return FALSE

	var/message = "INCOMING FAX: FROM \[[station_name()]\], AUTHOR \[[user]\]: "
	message += remove_all_tags(stored_paper.info)
	message += LAZYLEN(stored_paper.stamped) ? " --- The message is stamped." : ""
	if(destination in GLOB.admin_fax_destinations)
		message_admins("[ADMIN_LOOKUPFLW(user)] sent a fax to [destination].")
		send_fax_to_admins(user, message, ((obj_flags & EMAGGED) ? "crimson" : "orange"), destination)
	else
		var/found_a_machine = FALSE
		for(var/obj/machinery/fax_machine/machine as anything in GLOB.fax_machines)
			if(machine == src)
				continue
			if(machine.room_tag == destination && machine.recieve_paper(stored_paper.better_copy(), room_tag))
				message_admins("[ADMIN_LOOKUPFLW(user)] sent a fax to [ADMIN_VERBOSEJMP(machine)].")
				found_a_machine = TRUE
				break
		if(!found_a_machine)
			balloon_alert_to_viewers("destination not found")
			playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
			return FALSE

	to_chat(user, span_notice("Fax sent. Dispensing paper for personal record keeping. Thank you for using the Nanotrasen Approved Faxing Device!"))
	eject_stored_paper()
	flick("faxsend", src)
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, FALSE)
	COOLDOWN_START(src, fax_cooldown, FAX_COOLDOWN_TIME)
	use_power(active_power_usage)

/*
 * Send the content of admin faxes to admins directly.
 * [sender] - the mob who sent the fax
 * [fax_contents] - the contents of the fax
 * [destination_color] - the color of the span that encompasses [destination_string]
 * [destination_string] - the string that says where this fax was sent (syndiate or centcom)
 */
/obj/machinery/fax_machine/proc/send_fax_to_admins(mob/sender, fax_contents, destination_color, destination_string)
	var/message = copytext_char(sanitize(fax_contents), 1, MAX_MESSAGE_LEN)
	deadchat_broadcast(" has sent a fax to: [destination_string], with the message: \"[message]\" at [span_name("[get_area_name(sender, TRUE)]")].", span_name("[sender.real_name]"), sender, message_type = DEADCHAT_ANNOUNCEMENT)
	to_chat(GLOB.admins, span_adminnotice("<b><font color=[destination_color]>FAX TO [destination_string]: </font>[ADMIN_FULLMONTY(sender)] [ADMIN_FAX_REPLY(src)]:</b> [message]"), confidential = TRUE)

/datum/admins/Topic(href, href_list)
	. = ..()
	if(href_list["FaxReply"])
		var/obj/machinery/fax_machine/source = locate(href_list["FaxReply"]) in GLOB.fax_machines
		source.admin_create_fax(usr)

/obj/machinery/fax_machine/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_SEND_FAX, "Send fax to this machine")
	VV_DROPDOWN_OPTION(VV_SEND_MARKED_FAX, "Send marked paper as fax")

/obj/machinery/fax_machine/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_SEND_FAX])
		admin_create_fax(usr)
	if(href_list[VV_SEND_MARKED_FAX])
		var/obj/item/paper/marked_paper = usr.client?.holder?.marked_datum
		if(isnull(marked_paper))
			to_chat(usr, span_warning("You have no marked datum, or something went wrong."))
			return
		if(!istype(marked_paper))
			to_chat(usr, span_warning("You don't have a paper marked."))
			return
		if(tgui_alert(usr, "Do you want to send [marked_paper] to [src]?", "Send Fax", list("Yes", "Cancel")) == "Cancel")
			return
		var/source = input(usr, "Who's sending this fax? Leave blank for default name", "Send Fax") as null | text
		if(recieve_paper(marked_paper, source))
			to_chat(usr, span_notice("Fax successfully sent."))
		else
			to_chat(usr, span_danger("Fax failed to send."))

/*
 * Admin proc to create a fax (a message) and send it to this machine.
 * [user] is the admin.
 */
/obj/machinery/fax_machine/proc/admin_create_fax(mob/user)
	var/obj/item/paper/sent_paper = new()
	var/fax = stripped_multiline_input(user, "Write your fax to send here.", "Send Fax", max_length = MAX_MESSAGE_LEN)
	if(length(fax))
		sent_paper.info = fax
	else
		to_chat(user, span_warning("No contents inputted."))
		qdel(sent_paper)
		return

	var/title = input(user, "Write the paper's title here. Leave blank for default title", "Send Fax") as null | text
	if(title)
		sent_paper.name = fax

	var/source = input(user, "Who's sending this fax? Leave blank for default name", "Send Fax") as null | text
	sent_paper.update_appearance()
	if(recieve_paper(sent_paper, source))
		to_chat(user, span_notice("Fax successfully sent."))
	else
		to_chat(user, span_danger("Fax failed to send."))

/*
 * Recieve [new_paper] as a fax from [source].
 * Ejects any [recieved_paper] we may have, and sets [recieved_paper] to [new_paper].
 * If [source] is null or empty, we go with a preset name.
 *
 * returns TRUE if the fax was recieved.
 */
/obj/machinery/fax_machine/proc/recieve_paper(obj/item/paper/new_paper, source)
	if(!new_paper)
		return FALSE

	if((machine_stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE))
		return FALSE

	if(isnull(source) || !length(source))
		source = (obj_flags & EMAGGED ? "employer" : CENTCOM_FAX_MACHINE)
	if(recieved_paper)
		eject_recieved_paper()

	new_paper.name = "fax - [new_paper.name]"
	new_paper.was_faxed_from = source
	recieved_paper = new_paper
	recieved_paper.forceMove(src)
	unread_message = TRUE
	alert_recieved_paper(source)

	return TRUE

/*
 * Display an alert that [src] recieved a message from [source].
 */
/obj/machinery/fax_machine/proc/alert_recieved_paper(source)
	if((machine_stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE))
		return FALSE

	if(!unread_message)
		return FALSE

	say(span_robot("Fax recieved from [source]!"))
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, FALSE)
	addtimer(CALLBACK(src, .proc/alert_recieved_paper, source), FAX_UNREAD_ALERT_TIME)

/*
 * Check if [checked_paper] has had its paperwork fulfilled successfully.
 * [checked_paper] is an instance.
 * [user] is the mob who initiated the check.
 *
 * returns TRUE if the paperwork was correct, FALSE otherwise.
 */
/obj/machinery/fax_machine/proc/check_paperwork(obj/item/paper/processed/checked_paper, mob/living/user)
	var/paper_check = checked_paper.check_requirements()
	var/message = ""
	switch(paper_check)
		if(FAIL_NO_STAMP)
			message = "Protocal violated. Paperwork not stamped by official."
		if(FAIL_NOT_DENIED)
			message = "Protocal violated. Discrepancies detected in submitted paperwork."
		if(FAIL_NO_ANSWER)
			message = "Protocal violated. Paperwork unprocessed."
		if(FAIL_QUESTION_WRONG)
			message = "Protocal violated. Paperwork not processed correctly."
		else
			message = "Paperwork successfuly processed. Dispensing payment."

	say(span_robot(message))
	if(paper_check)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		. = FALSE
	else
		new /obj/item/holochip(drop_location(), rand(15, 25))
		playsound(src, 'sound/machines/ping.ogg', 60)
		. = TRUE

	LAZYREMOVE(recieved_paperwork, checked_paper)
	qdel(checked_paper)
	use_power(active_power_usage)

/*
 * Insert [inserted_paper] into the fax machine, adding it to the list of [recieved_paperwork] if possible.
 * [inserted_paper] is an instance.
 * [user] is the mob placing the paper into the machine.
 */
/obj/machinery/fax_machine/proc/insert_processed_paper(obj/item/paper/processed/inserted_paper, mob/living/user)
	if(LAZYLEN(recieved_paperwork) >= max_paperwork)
		to_chat(user, span_danger("You cannot place [inserted_paper] into [src], it's full."))
		return

	inserted_paper.forceMove(src)
	LAZYADD(recieved_paperwork, inserted_paper)
	to_chat(user, span_notice("You insert [inserted_paper] into [src], readying it for processing."))

/*
 * Insert [inserted_paper] into the fax machine, setting [stored_paper] to [inserted_paper].
 * [inserted_paper] is an instance.
 * [user] is the mob placing the paper into the machine.
 */
/obj/machinery/fax_machine/proc/insert_paper(obj/item/paper/inserted_paper, mob/living/user)
	inserted_paper.forceMove(src)
	if(stored_paper)
		to_chat(user, span_notice("You take out [stored_paper] from [src] and insert [inserted_paper]."))
		eject_stored_paper(user)
	else
		to_chat(user, span_notice("You insert [inserted_paper] into [src]."))

	stored_paper = inserted_paper

/*
 * Call [proc/eject_select_paperwork] on all papers in [recieved_paperwork].
 * Then null the list after all is done.
 */
/obj/machinery/fax_machine/proc/eject_all_paperwork(mob/living/user)
	for(var/obj/item/paper/processed/paper as anything in recieved_paperwork)
		eject_select_paperwork(user, paper)
	recieved_paperwork = null

/*
 * Recursively call [proc/eject_select_paperwork] on the first index
 * of [recieved_paperwork], applying a delay in between each call.
 *
 * If [user] is specified, pass [user] into the [proc/eject_select_paperwork] call.
 */
/obj/machinery/fax_machine/proc/eject_all_paperwork_with_delay(mob/living/user)
	if(!LAZYLEN(recieved_paperwork))
		SStgui.update_uis(src)
		return

	if(recieved_paperwork[1])
		eject_select_paperwork(user, recieved_paperwork[1], FALSE)
		addtimer(CALLBACK(src, .proc/eject_all_paperwork_with_delay, user), 2 SECONDS)

/*
 * Remove [paper] from the list of [recieved_paperwork] and
 * dispense it into [user]'s hands, if user is supplied.
 *
 * [paper] must be an instance of a paper in the list of paperwork.
 * if [silent] is FALSE, give feedback and play a sound.
 */
/obj/machinery/fax_machine/proc/eject_select_paperwork(mob/living/user, obj/item/paper/processed/paper, silent = TRUE)
	if(!paper)
		return

	if(user && Adjacent(user))
		user.put_in_hands(paper)
	else
		paper.forceMove(drop_location())
	LAZYREMOVE(recieved_paperwork, paper)
	if(!silent)
		flick("faxreceive", src)
		playsound(src, 'sound/machines/ding.ogg', 50, FALSE)
		use_power(active_power_usage)

/*
 * Remove [paper] from the list of [recieved_paperwork] and delete it.
 * [paper] must be an instance of a paper in the list of paperwork.
 */
/obj/machinery/fax_machine/proc/delete_select_paperwork(obj/item/paper/processed/paper)
	LAZYREMOVE(recieved_paperwork, paper)
	qdel(paper)
	use_power(active_power_usage)

/*
 * Eject the [recievestored_paperd_paper].
 * if [user] is supplied, attempt to put it in their hands. Otherwise, drop it to the floor.
 *
 * if [silent] is FALSE, give feedback to people nearbly that a paper was removed.
 */
/obj/machinery/fax_machine/proc/eject_stored_paper(mob/living/user, silent = TRUE)
	if(!stored_paper)
		return

	if(!silent)
		flick("faxreceive", src)
		balloon_alert_to_viewers("removed [stored_paper]")
	if(user && Adjacent(user))
		user.put_in_hands(stored_paper)
	else
		stored_paper.forceMove(drop_location())
	stored_paper = null
	SStgui.update_uis(src)

/*
 * Eject the [recieved_paper].
 * if [user] is supplied, attempt to put it in their hands. Otherwise, drop it to the floor.
 *
 * if [silent] is FALSE, give feedback to people nearbly that a paper was removed.
 */
/obj/machinery/fax_machine/proc/eject_recieved_paper(mob/living/user, silent = TRUE)
	if(!recieved_paper)
		return

	if(!silent)
		flick("faxreceive", src)
		balloon_alert_to_viewers("removed [recieved_paper]")
	if(user && Adjacent(user))
		user.put_in_hands(recieved_paper)
	else
		recieved_paper.forceMove(drop_location())
	recieved_paper = null
	SStgui.update_uis(src)

/obj/machinery/fax_machine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	balloon_alert(user, "routing address overridden")
	playsound(src, 'sound/machines/terminal_alert.ogg', 25, FALSE)
	obj_flags |= EMAGGED

// ----- Paper definitions and subtypes for interactions with the fax machine. -----
/obj/item/paper
	/// Whether this paper was via a fax.
	var/was_faxed_from

/*
 * Make a new instance of [/obj/item/paper] with most of the same vars as [src].
 * Works better / copies more things than the pre-existing [proc/copy] for paper.
 * [paper_to_copy] - an instance of paper.
 *
 * returns a new instance of [/obj/item/paper].
 */
/obj/item/paper/proc/better_copy()
	var/obj/item/paper/new_paper = new()

	new_paper.name = name
	new_paper.desc = desc
	new_paper.info = info
	new_paper.color = color
	new_paper.stamps = LAZYLISTDUPLICATE(stamps)
	new_paper.stamped = LAZYLISTDUPLICATE(stamped)
	new_paper.form_fields = form_fields.Copy()
	new_paper.field_counter = field_counter
	new_paper.update_appearance()

	return new_paper

/obj/item/paper/processed
	name = "\proper classified paperwork"
	desc = "Some classified paperwork sent by the big men themselves."
	/// Assoc list of data related to our paper.
	var/list/paper_data
	/// Question required to be answered for this paper to be marked as correct.
	var/required_question
	/// Answer requires for this paper to be marked as correct.
	var/needed_answer
	/// The last answer supplied by a user.
	var/last_answer
	/// Whether this paper contains errors and must be denied to be marked as correct.
	var/errors_present = FALSE

/obj/item/paper/processed/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/pen) || istype(weapon, /obj/item/toy/crayon))
		INVOKE_ASYNC(src, .proc/answer_question, user)
		return TRUE

	return ..()

/*
 * Called async - Opens up an input for the user to answer the required question.
 */
/obj/item/paper/processed/proc/answer_question(mob/living/user)
	if(!required_question)
		return

	last_answer = input(user, required_question, "Paperwork") as null | text

/*
 * Generate a random question based on our paper's data.
 * This question must be answered by a user for the paper to be marked as correct.
 */
/obj/item/paper/processed/proc/generate_requirements()
	var/list/shuffled_data = shuffle(paper_data)
	for(var/data in shuffled_data)
		if(!shuffled_data[data])
			continue

		needed_answer = shuffled_data[data]
		switch(data)
			if("subject")
				required_question = "Who was the subject of the document?"
			if("time_period")
				required_question = "When did the event in the document occur?"
			if("occasion")
				required_question = "What was the event in the document?"
			if("victim")
				required_question = "Who was the victim of the document?"
			else
				required_question = "This paperwork is incompletable."
		return

/*
 * Check if our paper's been  processed correctly.
 *
 * Returns a failure state if it was not (a truthy value, 1+) or a success state if it was (falsy, 0)
 */
/obj/item/paper/processed/proc/check_requirements()
	if(isnull(last_answer))
		return FAIL_NO_ANSWER
	if(!LAZYLEN(stamped))
		return FAIL_NO_STAMP
	if(last_answer != needed_answer)
		return FAIL_QUESTION_WRONG
	if(errors_present && !("stamp-deny" in stamped))
		return FAIL_NOT_DENIED

	return PAPERWORK_SUCCESS

#undef FAX_COOLDOWN_TIME
#undef FAX_UNREAD_ALERT_TIME
#undef MAX_DISPLAYED_PAPER_CHARS
