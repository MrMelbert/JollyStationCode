/datum/mana_pool/mana_battery

/datum/mana_pool/mana_battery/can_transfer(datum/mana_pool/target_pool)
	if (QDELETED(target_pool.parent))
		return FALSE
	var/obj/item/mana_battery/battery = parent

	if (battery.loc == target_pool.parent.loc)
		return TRUE

	if (get_dist(battery, target_pool.parent) > battery.max_allowed_transfer_distance)
		return FALSE
	return ..()

/obj/item/mana_battery
	name = "generic mana battery"
	mana_pool = /datum/mana_pool/mana_battery/mana_crystal
	has_initial_mana_pool = TRUE
	var/max_allowed_transfer_distance = MANA_BATTERY_MAX_TRANSFER_DISTANCE

/obj/item/mana_battery/get_initial_mana_pool_type()
	return mana_pool

// when we hit ourself with left click, we draw mana FROM the battery.
/obj/item/mana_battery/attack_self(mob/user, modifiers)
	. = ..()

	if (.)
		return TRUE

	if (!user.mana_pool)
		balloon_alert(user, "you have no mana pool!")
		return FALSE

	var/already_transferring = (user in mana_pool.transferring_to)
	if (already_transferring)
		balloon_alert(user, "Canceled Draw.")
		mana_pool.stop_transfer(user.mana_pool)
	else
		var/mana_to_draw = tgui_input_number(user, "How much mana do you want to draw from the battery? Soft Cap (You will lose mana when above this!): [user.mana_pool.softcap]", "Draw Mana", max_value = mana_pool.maximum_mana_capacity)
		balloon_alert(user, "Drawing Mana....")
		mana_pool.transfer_specific_mana(user.mana_pool, mana_to_draw, decrement_budget = TRUE)
// when we hit ourself with right click, however, we send mana TO the battery.
/obj/item/mana_battery/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if (.)
		return TRUE

	if (!user.mana_pool)
		balloon_alert(user, "you have no mana pool!")
		return FALSE
	var/already_transferring = (user in mana_pool.transferring_to)
	if (already_transferring)
		balloon_alert(user, "Canceled Send.")
		user.mana_pool.stop_transfer(mana_pool)
	else
		var/mana_to_send = tgui_input_number(user, "How much mana do you want to send to the battery? Max Capacity: [mana_pool.maximum_mana_capacity]", "Send Mana", max_value = mana_pool.maximum_mana_capacity)
		balloon_alert(user, "Sending Mana....")
		user.mana_pool.transfer_specific_mana(mana_pool, mana_to_send, decrement_budget = TRUE)
/obj/item/mana_battery/mana_crystal
	name = MAGIC_MATERIAL_NAME + " crystal"
	desc = "Crystalized mana." //placeholder desc
	icon = 'maplestation_modules/icons/obj/magic/crystals.dmi' //placeholder

// Do not use, basetype
/datum/mana_pool/mana_battery/mana_crystal

	maximum_mana_capacity = MANA_CRYSTAL_BASE_MANA_CAPACITY
	softcap = MANA_CRYSTAL_BASE_MANA_CAPACITY

	exponential_decay_divisor = MANA_CRYSTAL_BASE_DECAY_DIVISOR

	max_donation_rate_per_second = BASE_MANA_CRYSTAL_DONATION_RATE

/datum/mana_pool/mana_battery/mana_crystal/New(atom/parent, amount)
	. = ..()
	softcap = maximum_mana_capacity

/obj/item/mana_battery/mana_crystal/standard
	name = "Stabilized Volite Crystal"
	desc = "A stabilized Volite Crystal, one of the few objects capable of stably storing mana without binding."
	icon_state = "standard"
	mana_pool = /datum/mana_pool/mana_battery/mana_crystal/standard

/datum/mana_pool/mana_battery/mana_crystal/standard // basically, just, bog standard, none of the variables need to be changed

/obj/item/mana_battery/mana_crystal/small
	name = "Small Volite Crystal"
	desc = "A miniaturized Volite crystal, formed using the run-off of cutting larger ones. Able to hold mana still, although not as much as a proper formation."
	icon_state = "small" //placeholder
	mana_pool = /datum/mana_pool/mana_battery/mana_crystal/small/

/datum/mana_pool/mana_battery/mana_crystal/small/
	// half the size of the normal crystal
	maximum_mana_capacity = (MANA_CRYSTAL_BASE_MANA_CAPACITY / 2)
	softcap = (MANA_CRYSTAL_BASE_MANA_CAPACITY / 2)
