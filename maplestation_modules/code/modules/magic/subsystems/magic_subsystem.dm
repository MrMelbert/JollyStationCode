PROCESSING_SUBSYSTEM_DEF(magic)
	name = "Magic"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING

	wait = MAGIC_SUBSYSTEM_FIRE_RATE
	priority = FIRE_PRIORITY_MAGIC

/datum/controller/subsystem/processing/magic/Initialize()
	. = ..()

	var/amount_of_leylines = get_leyline_amount()
	while (amount_of_leylines-- > 0)
		new /datum/mana_holder/leyline() //generate initial leylines

	return SS_INIT_SUCCESS

/// This proc only exists for if we decide to make leylines better simulated.
/datum/controller/subsystem/processing/magic/proc/get_leyline_amount()
	return 1 //CHANGE THIS IN OTEHR VERSIONS TO BE BETTER

/// Starts processing the leyline, and adds it to our list of leylines.
/datum/controller/subsystem/processing/magic/proc/start_processing_leyline(datum/mana_holder/leyline/leyline_to_process)
	if (!istype(leyline_to_process))
		CRASH("[leyline_to_process], type of [leyline_to_process?.type] used as arg in start_processing_leyline!")
	START_PROCESSING(src, leyline_to_process)
	leylines += leyline_to_process

/// Stops processing the leyline, and removes it from our list of leylines.
/datum/controller/subsystem/processing/magic/proc/stop_processing_leyline(datum/mana_holder/leyline/leyline_to_process)
	if (!istype(leyline_to_process))
		CRASH("[leyline_to_process], type of [leyline_to_process?.type] used as arg in stop_processing_leyline!")
	STOP_PROCESSING(src, leyline_to_process)
	leylines -= leyline_to_process

/// Returns a list of all our leylines' mana pools.
/datum/controller/subsystem/processing/magic/proc/get_all_leyline_mana()
	var/list/datum/mana_pool/mana = list()
	for (var/datum/mana_holder/leyline/processing_leyline as anything in leylines)
		mana += processing_leyline.get_stored_mana()

	return mana

/// Returns the raw amount of mana all our leylines have.
/datum/controller/subsystem/processing/magic/proc/get_all_leyline_raw_mana_amount()
	var/list/datum/mana_pool/mana = get_all_leyline_mana()
	var/amount = 0
	for (var/datum/mana_pool/group as anything in mana)
		amount += group.amount
	return amount

/// Returns the attuned amount of mana for all our leylines, using attunements to generate attunement mults.
/datum/controller/subsystem/processing/magic/proc/get_all_leyline_attuned_mana_amount(list/datum/attunement/attunements, atom/caster)
	var/list/datum/mana_pool/mana = get_all_leyline_mana()
	var/amount = 0
	for (var/datum/mana_pool/group as anything in mana)
		amount += group.get_attuned_amount(attunements, caster)
	return amount

/// Adjusts the mana of picked_leyline by amount, with incoming_attunements.
/datum/controller/subsystem/processing/magic/proc/adjust_stored_mana(datum/mana_holder/leyline/picked_leyline, amount, list/incoming_attunements)
	if (isnull(incoming_attunements))
		incoming_attunements = picked_leyline.get_attunements()
	picked_leyline.adjust_mana(amount, incoming_attunements)
