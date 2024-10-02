/datum/mana_pool/mana_battery
	amount = 0

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
		balloon_alert(user, "canceled draw.")
		mana_pool.stop_transfer(user.mana_pool)
	else
		var/mana_to_draw = tgui_input_number(user, "How much mana do you want to draw from the battery? Soft Cap (You will lose mana when above this!): [user.mana_pool.softcap]", "Draw Mana", max_value = mana_pool.maximum_mana_capacity)
		balloon_alert(user, "drawing mana....")
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
		balloon_alert(user, "canceled send.")
		user.mana_pool.stop_transfer(mana_pool)
	else
		var/mana_to_send = tgui_input_number(user, "How much mana do you want to send to the battery? Max Capacity: [mana_pool.maximum_mana_capacity]", "Send Mana", max_value = mana_pool.maximum_mana_capacity)
		balloon_alert(user, "sending mana....")
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
	icon_state = "small"
	mana_pool = /datum/mana_pool/mana_battery/mana_crystal/small/
	w_class = WEIGHT_CLASS_SMALL

/obj/item/mana_battery/mana_crystal/cut
	name = "Cut Volite Crystal"
	desc = "A cut and shaped Volite Crystal, using a standardized square cut. It lacks power until it is slotted into a proper amulet."
	icon_state = "cut"
	mana_pool = /datum/mana_pool/mana_battery/mana_crystal/small/

/datum/mana_pool/mana_battery/mana_crystal/small/
	// half the size of the normal crystal
	maximum_mana_capacity = (MANA_CRYSTAL_BASE_MANA_CAPACITY / 2)
	softcap = (MANA_CRYSTAL_BASE_MANA_CAPACITY / 2)

/datum/mana_pool/mana_star
	// a special type of mana battery that regenerates passively- but cannot be given mana
	maximum_mana_capacity = 400 // 400 by default
	softcap = 400
	amount = 0
	ethereal_recharge_rate = 2 // forgot this was a thing LMFAO

/obj/item/clothing/neck/mana_star
	name = "Volite Amulet"
	desc = "A cut volite crystal placed within a gilded amulet. It naturally draws and fixes mana for your use."
	has_initial_mana_pool = TRUE
	mana_pool = /datum/mana_pool/mana_star
	worn_icon = 'maplestation_modules/icons/mob/clothing/neck.dmi'
	worn_icon_state = "volite_amulet"
	icon = 'maplestation_modules/icons/obj/magic/crystals.dmi'
	icon_state = "amulet"

/obj/item/clothing/neck/mana_star/get_initial_mana_pool_type()
	return mana_pool

/obj/item/clothing/neck/mana_star/attack_self(mob/user, modifiers) // you can only draw by default.
	. = ..()

	if (.)
		return TRUE

	if (!user.mana_pool)
		balloon_alert(user, "you have no mana pool!")
		return FALSE

	var/already_transferring = (user in mana_pool.transferring_to)
	if (already_transferring)
		balloon_alert(user, "canceled draw.")
		mana_pool.stop_transfer(user.mana_pool)
	else
		var/mana_to_draw = tgui_input_number(user, "How much mana do you want to draw from the star? Soft Cap (You will lose mana when above this!): [user.mana_pool.softcap]", "Draw Mana", max_value = mana_pool.maximum_mana_capacity)
		balloon_alert(user, "drawing mana....")
		mana_pool.transfer_specific_mana(user.mana_pool, mana_to_draw, decrement_budget = TRUE)

/obj/item/mana_battery/mana_crystal/small/focus //really only exists for debug.
	name = "Focused Small Volite Crystal"
	desc = "A focused variant of the standard small volite crystal. You can draw mana from this while casting."
	icon_state = "small"

/obj/item/mana_battery/mana_crystal/small/focus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_POOL_AVAILABLE_FOR_CAST, INNATE_TRAIT)

