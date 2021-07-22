/// --- Fax Machines. ---
/// GLOB list of all fax machines.
GLOBAL_LIST_EMPTY(fax_machines)

/// Cooldown for fax time between faxes.
#define FAX_COOLDOWN_TIME 3 MINUTES

#define VV_SEND_FAX "send_fax"
#define ADMIN_FAX_REPLY(machine) "(<a href='?_src_=holder;[HrefToken(TRUE)];FaxReply=[REF(machine)]'>FAX</a>)"

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
	desc = "Send faxes and process paperwork, you boring person."
	icon = 'jollystation_modules/icons/obj/machines/fax.dmi'
	icon_state = "fax"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	req_one_access = list(ACCESS_HEADS, ACCESS_LAWYER)
	circuit = /obj/item/circuitboard/machine/fax_machine
	/// Whether this fax machine can recieve paperwork to process on SSeconomy ticks.
	var/can_recieve = FALSE
	/// The paper stored that we can send to admins.
	var/obj/item/paper/stored_paper
	/// The paper recieved that was sent FROM admins.
	var/obj/item/paper/recieved_paper
	/// List of all paperwork we have in this fax machine.
	var/list/obj/item/paper/processed/recieved_paperwork
	/// Cooldown between sending faxes
	COOLDOWN_DECLARE(fax_cooldown)

/obj/machinery/fax_machine/full/Initialize()
	. = ..()
	for(var/i in 1 to 8)
		if(LAZYLEN(recieved_paperwork) >= 8)
			continue
		LAZYADD(recieved_paperwork, generate_paperwork(src))

/obj/machinery/fax_machine/Initialize()
	. = ..()
	GLOB.fax_machines += src

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
		ui = new(user, src, "_FaxMachine")
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
		found_paper_data["contents"] = remove_all_tags(paper.info)
		found_paper_data["required_answer"] = paper.required_question
		found_paper_data["ref"] = REF(paper)
		found_paper_data["num"] = iterator++
		all_recieved_paperwork += list(found_paper_data)
	if(all_recieved_paperwork.len)
		data["recieved_paperwork"] = all_recieved_paperwork

	if(stored_paper)
		var/list/stored_paper_data = list()
		stored_paper_data["title"] = stored_paper.name
		stored_paper_data["contents"] = remove_all_tags(stored_paper.info)
		stored_paper_data["ref"] = REF(stored_paper_data)
		data["stored_paper"] = stored_paper_data

	if(recieved_paper)
		var/list/recieved_paper_data = list()
		recieved_paper_data["title"] = recieved_paper.name
		recieved_paper_data["contents"] = remove_all_tags(recieved_paper.info)
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

	data["can_send_cc_messages"] = (allowed(user) || emagged) && COOLDOWN_FINISHED(src, fax_cooldown)
	data["emagged"] = emagged
	data["can_recieve"] = can_recieve

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

		if("send_stored_paper")
			send_stored_paper(usr)

		if("print_recieved_paper")
			eject_recieved_paper(usr, FALSE)

		if("print_select_paperwork")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			eject_select_paperwork(usr, paper, FALSE)

		if("del_select_paperwork")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			delete_select_paperwork(paper)

		if("print_all_paperwork")
			eject_all_paperwork_with_delay(usr)

		if("check_paper")
			var/obj/item/paper/processed/paper = locate(params["ref"]) in recieved_paperwork
			check_paperwork(paper, usr)

	return TRUE

/obj/machinery/fax_machine/attackby(obj/item/weapon, mob/user, params)
	if(!isliving(user))
		return ..()

	if(istype(weapon, /obj/item/paper/processed))
		insert_processed_paper(weapon, user)
		return
	else if(istype(weapon, /obj/item/paper))
		insert_paper(weapon, user)
		return

	return ..()

/obj/machinery/fax_machine/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		eject_stored_paper(user)
		return TRUE

/obj/machinery/fax_machine/examine(mob/user)
	. = ..()
	if(stored_paper)
		. += span_notice("Right-click to remove the stored paper.")

/obj/machinery/fax_machine/proc/send_stored_paper(mob/living/user)
	if(!stored_paper || !length(stored_paper.info) || !COOLDOWN_FINISHED(src, fax_cooldown))
		to_chat(user, span_danger("Fax failed."))
		playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
		return FALSE

	var/message = "INCOMING FAX: FROM \[[station_name()]\], AUTHOR \[[user]\]: "
	message += remove_all_tags(stored_paper.info)
	message += LAZYLEN(stored_paper.stamped) ? " --- The message is stamped." : ""
	if(obj_flags & EMAGGED)
		send_fax_to_admins(user, message, "crimson", "THE SYNDICATE")
	else
		send_fax_to_admins(user, message, "orange", "CENTCOM")
	to_chat(user, span_notice("Fax sent. Dispensing paper for personal record keeping. Thank you for using the Nanotrasen Approved Faxing Device!"))
	eject_stored_paper()
	flick("faxsend", src)
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, FALSE)
	COOLDOWN_START(src, fax_cooldown, FAX_COOLDOWN_TIME)
	use_power(active_power_usage)

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

/obj/machinery/fax_machine/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_SEND_FAX])
		admin_create_fax(usr)

/obj/machinery/fax_machine/proc/admin_create_fax(mob/user)
	var/obj/item/paper/sent_paper = new()
	var/fax = stripped_multiline_input(user, "Write your fax to send here.", "Send Fax", max_length = MAX_MESSAGE_LEN)
	if(length(fax))
		sent_paper.info = fax
	else
		to_chat(user, span_danger("No contents inputted."))
		qdel(sent_paper)
		return

	var/title = input(user, "Write the paper's title here. Leave blank for default title", "Send Fax") as null | text
	if(title)
		sent_paper.name = fax

	var/source = input(user, "Who's sending this fax? Leave blank for default name", "Send Fax") as null | text
	sent_paper.update_appearance()
	recieve_paper(sent_paper, source)

/obj/machinery/fax_machine/proc/recieve_paper(obj/item/paper/new_paper, source)
	if(!new_paper)
		return
	if(isnull(source) || !length(source))
		source = (obj_flags & EMAGGED ? "employer" : "Central Command")
	if(recieved_paper)
		eject_recieved_paper()

	recieved_paper = new_paper
	recieved_paper.forceMove(src)
	say(span_robot("Fax recieved from [source]!"))
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, FALSE)

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

/obj/machinery/fax_machine/proc/delete_select_paperwork(obj/item/paper/processed/paper)
	LAZYREMOVE(recieved_paperwork, paper)
	qdel(paper)
	use_power(active_power_usage)

/obj/machinery/fax_machine/proc/insert_processed_paper(obj/item/paper/processed/inserted_paper, mob/living/user)
	if(LAZYLEN(recieved_paperwork) >= 8)
		to_chat(user, span_danger("You cannot place [inserted_paper] into [src], it's full."))
		return

	inserted_paper.forceMove(src)
	LAZYADD(recieved_paperwork, inserted_paper)
	to_chat(user, span_notice("You insert [inserted_paper] into [src], readying it for processing."))

/obj/machinery/fax_machine/proc/insert_paper(obj/item/paper/inserted_paper, mob/living/user)
	inserted_paper.forceMove(src)
	if(stored_paper)
		to_chat(user, span_notice("You take out [stored_paper] from [src] and insert [inserted_paper]."))
		eject_stored_paper(user)
	else
		to_chat(user, span_notice("You insert [inserted_paper] into [src]."))

	stored_paper = inserted_paper

/obj/machinery/fax_machine/proc/eject_all_paperwork(mob/living/user)
	for(var/obj/item/paper/processed/paper as anything in recieved_paperwork)
		eject_select_paperwork(user, paper)
	recieved_paperwork = null

/// Recursively ejects the first paper then waits a second until the list is empty
/obj/machinery/fax_machine/proc/eject_all_paperwork_with_delay(mob/living/user)
	if(!LAZYLEN(recieved_paperwork))
		SStgui.update_uis(src)
		return

	if(recieved_paperwork[1])
		eject_select_paperwork(user, recieved_paperwork[1], FALSE)
		addtimer(CALLBACK(src, .proc/eject_all_paperwork_with_delay, user), 2 SECONDS)

/obj/machinery/fax_machine/proc/eject_select_paperwork(mob/living/user, obj/item/paper/processed/paper, silent = TRUE)
	if(!paper)
		return

	if(user)
		user.put_in_hands(paper)
	else
		paper.forceMove(drop_location())
	LAZYREMOVE(recieved_paperwork, paper)
	if(!silent)
		flick("faxreceive", src)
		playsound(src, 'sound/machines/ding.ogg', 50, FALSE)
		use_power(active_power_usage)

/obj/machinery/fax_machine/proc/eject_stored_paper(mob/living/user, silent = TRUE)
	if(!stored_paper)
		return

	if(!silent)
		to_chat(user, span_notice("You remove [stored_paper] from [src]."))
	if(user)
		user.put_in_hands(stored_paper)
	else
		stored_paper.forceMove(drop_location())
	stored_paper = null
	SStgui.update_uis(src)

/obj/machinery/fax_machine/proc/eject_recieved_paper(mob/living/user, silent = TRUE)
	if(!recieved_paper)
		return

	if(!silent)
		to_chat(user, span_notice("You remove [recieved_paper] from [src]."))
	if(user)
		user.put_in_hands(recieved_paper)
	else
		recieved_paper.forceMove(drop_location())
	recieved_paper = null
	SStgui.update_uis(src)

/obj/machinery/fax_machine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	to_chat(user, span_notice("You override the routing address of [src], directing it to the Syndicate."))
	playsound(src, 'sound/machines/terminal_alert.ogg', 25, FALSE)
	obj_flags |= EMAGGED

/datum/controller/subsystem/economy/fire(resumed = 0)
	. = ..()
	send_fax_paperwork()

/datum/controller/subsystem/economy/proc/send_fax_paperwork()
	var/list/area/processed_areas = list()
	for(var/obj/machinery/fax_machine/found_machine as anything in GLOB.fax_machines)
		/// We only send to one fax machine in an area
		var/area/area_loc = get_area(found_machine)
		if(area_loc in processed_areas)
			continue
		processed_areas += area_loc

		if(LAZYLEN(found_machine.recieved_paperwork) >= 8)
			continue
		if(!found_machine.can_recieve)
			continue

		var/num_papers_added = 0
		for(var/i in 1 to rand(0, 4))
			if(LAZYLEN(found_machine.recieved_paperwork) >= 8)
				continue
			num_papers_added++
			LAZYADD(found_machine.recieved_paperwork, generate_paperwork(found_machine))
		if(num_papers_added)
			found_machine.audible_message(span_notice("[found_machine] beeps as new paperwork becomes available to process."))
			playsound(found_machine,  'sound/machines/twobeep.ogg', 50)

/proc/generate_paperwork(obj/machinery/fax_machine/destination_machine)
	var/error_paper = prob(5)
	var/paper_base_subject = pick_list(PAPERWORK_FILE, "subject")
	var/paper_time_period = pick_list(PAPERWORK_FILE, "time_period")
	var/paper_occasion = pick_list(PAPERWORK_FILE, "occasion")
	var/paper_contents
	var/paper_victim
	var/paper_subject

	switch(paper_occasion)
		if("court case", "trial")
			paper_subject = paper_base_subject
			paper_victim = pick_list(PAPERWORK_FILE, "subject")
			if(prob(30) || paper_victim == paper_subject)
				paper_victim = random_unique_name()
			paper_contents = pick_list(PAPERWORK_FILE, "contents_court_cases")

		if("execution", "re-education")
			paper_subject = paper_base_subject
			paper_victim = random_unique_name()
			paper_contents = pick_list(PAPERWORK_FILE, "contents_executions")

		if("patent")
			paper_subject = paper_base_subject
			paper_contents = pick_list(PAPERWORK_FILE, "contents_patents")

		else
			paper_contents = pick_list(PAPERWORK_FILE, "contents_random")

	if(error_paper)
		var/list/error_options = list("occasion", "time", "subject", "victim")
		if(!paper_subject)
			error_options -= "subject"
		if(!paper_victim)
			error_options -= "victim"
		switch(pick(error_options))
			if("subject")
				paper_subject = scramble_text(paper_subject)
			if("victim")
				paper_victim = scramble_text(paper_victim)
			if("time")
				paper_time_period = scramble_text(paper_time_period)
			if("occasion")
				paper_occasion = scramble_text(paper_occasion)

	if(paper_subject)
		paper_contents = replacetext(paper_contents, "subject", paper_subject)
	if(paper_victim)
		paper_contents = replacetext(paper_contents, "victim", paper_victim)

	var/list/processed_paper_data = list()
	if(paper_subject)
		processed_paper_data["subject"] = paper_subject
	if(paper_victim)
		processed_paper_data["victim"] = paper_victim
	processed_paper_data["time_period"] = paper_time_period
	processed_paper_data["occasion"] = paper_occasion

	var/obj/item/paper/processed/spawned_paper = new(destination_machine)
	spawned_paper.paper_data = processed_paper_data
	spawned_paper.errors_present = error_paper
	spawned_paper.info = "\A [paper_time_period] [paper_occasion]: [paper_contents]"
	spawned_paper.generate_requirements()
	spawned_paper.update_appearance()

	return spawned_paper

/obj/item/paper/processed
	name = "\proper classified paperwork"
	desc = "Some classified paperwork sent by the big men themselves."
	var/list/paper_data
	var/required_question
	var/needed_answer
	var/last_answer
	var/errors_present = FALSE

/obj/item/paper/processed/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/pen) || istype(weapon, /obj/item/toy/crayon))
		INVOKE_ASYNC(src, .proc/answer_question, user)
		return TRUE

	return ..()

/*
 * Async open up an input for the user to answer the required question.
 */
/obj/item/paper/processed/proc/answer_question(mob/living/user)
	if(!required_question)
		return

	last_answer = input(user, required_question, "Paperwork") as null | text

/*
 * Generate a random question that will be required to process this paper successfully based on our paper's data.
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
 * Check if our paper's been thoroughly processed correctly.
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
