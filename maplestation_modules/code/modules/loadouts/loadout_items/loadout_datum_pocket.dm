/// Pocket items (Moved to backpack)
/datum/loadout_category/pocket
	category_name = "Other"
	type_to_generate = /datum/loadout_item/pocket_items
	tab_order = 14
	/// How many pocket items are allowed
	VAR_PRIVATE/max_allowed = 3

/datum/loadout_category/pocket/New()
	. = ..()
	category_info = "([max_allowed] allowed)"

/datum/loadout_category/pocket/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	var/list/datum/loadout_item/pocket_items/other_pocket_items = list()
	for(var/datum/loadout_item/pocket_items/other_pocket_item in all_loadout_items)
		other_pocket_items += other_pocket_item

	if(length(other_pocket_items) >= max_allowed)
		// We only need to deselect something if we're above the limit
		// (And if we are we prioritize the first item found, FIFO)
		manager.deselect_item(other_pocket_items[1])
	return TRUE

/datum/loadout_item/pocket_items
	abstract_type = /datum/loadout_item/pocket_items

/datum/loadout_item/pocket_items/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	// Backpack items aren't created if it's a visual equipping, so don't do any on equip stuff. It doesn't exist.
	if(visuals_only)
		return NONE

	return ..()

// The wallet loadout item is special, and puts the player's ID and other small items into it on initialize (fancy!)
/datum/loadout_item/pocket_items/wallet
	name = "Wallet"
	item_path = /obj/item/storage/wallet

/datum/loadout_item/pocket_items/wallet/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, job_equipping_step = FALSE)
	if(visuals_only || isdummy(equipper))
		return
	if(!job_equipping_step)
		return ..()
	// We hook the signal because we equip the wallet at the very end of prefs setup.
	// We wait for the end of prefs setup so we can check the equipper's bag for any other loadout items / quirk items to put in the wallet.
	RegisterSignal(equipper, COMSIG_HUMAN_CHARACTER_SETUP, PROC_REF(apply_after_setup), override = TRUE)

/datum/loadout_item/pocket_items/wallet/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	return NONE

/datum/loadout_item/pocket_items/wallet/proc/apply_after_setup(mob/living/carbon/human/source, ...)
	SIGNAL_HANDLER
	equip_wallet(source)
	UnregisterSignal(source, COMSIG_HUMAN_CHARACTER_SETUP)

/datum/loadout_item/pocket_items/wallet/proc/equip_wallet(mob/living/carbon/human/equipper)
	var/obj/item/card/id/advanced/id_card = equipper.get_item_by_slot(ITEM_SLOT_ID)
	if(istype(id_card, /obj/item/storage/wallet)) // Wallets station trait guard
		return

	var/obj/item/storage/wallet/wallet = new(equipper)
	if(istype(id_card))
		equipper.temporarilyRemoveItemFromInventory(id_card, force = TRUE)
		equipper.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial = TRUE)
		id_card.forceMove(wallet)

		for(var/obj/item/thing in equipper?.back)
			if(wallet.contents.len >= 3)
				break
			if(thing.w_class > WEIGHT_CLASS_SMALL)
				continue
			wallet.atom_storage.attempt_insert(thing, override = TRUE, force = TRUE)

	else
		if(!equipper.equip_to_slot_if_possible(wallet, slot = ITEM_SLOT_BACKPACK, initial = TRUE))
			wallet.forceMove(equipper.drop_location())

/datum/loadout_item/pocket_items/beach_towel
	name = "Beach Towel"
	item_path = /obj/item/towel/beach

/datum/loadout_item/pocket_items/towel
	name = "Towel"
	item_path = /obj/item/towel

/datum/loadout_item/pocket_items/rag
	name = "Rag"
	item_path = /obj/item/reagent_containers/cup/rag

/datum/loadout_item/pocket_items/gum_pack
	name = "Pack of Gum"
	item_path = /obj/item/storage/box/gum

/datum/loadout_item/pocket_items/gum_pack_nicotine
	name = "Pack of Nicotine Gum"
	item_path = /obj/item/storage/box/gum/nicotine

/datum/loadout_item/pocket_items/gum_pack_hp
	name = "Pack of HP+ Gum"
	item_path = /obj/item/storage/box/gum/happiness

/datum/loadout_item/pocket_items/lipstick
	name = "Lipstick"
	item_path = /obj/item/lipstick
	additional_displayed_text = list("Recolorable")

/datum/loadout_item/pocket_items/lipstick/on_equip_item(
	obj/item/lipstick/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only,
)
	. = ..()
	var/picked_style = style_to_style(preference_list[item_path]?[INFO_LAYER])
	var/picked_color = preference_list[item_path]?[INFO_GREYSCALE] || /obj/item/lipstick::lipstick_color
	if(istype(equipped_item)) // can be null for visuals_only
		equipped_item.style = picked_style
		equipped_item.lipstick_color = picked_color
	equipper.update_lips(picked_style, picked_color)

/// Converts style (readable) to style (internal)
/datum/loadout_item/pocket_items/lipstick/proc/style_to_style(style)
	switch(style)
		if(UPPER_LIP)
			return "lipstick_upper"
		if(LOWER_LIP)
			return "lipstick_lower"
	return "lipstick"

/datum/loadout_item/pocket_items/lipstick/get_ui_buttons()
	. = ..()
	UNTYPED_LIST_ADD(., list(
		"label" = "Style",
		"act_key" = "select_lipstick_style",
		"button_icon" = FA_ICON_ARROWS_ROTATE,
		"active_key" = INFO_LAYER,
	))
	UNTYPED_LIST_ADD(., list(
		"label" = "Color",
		"act_key" = "select_lipstick_color",
		"button_icon" = FA_ICON_PALETTE,
		"active_key" = INFO_GREYSCALE,
	))

/datum/loadout_item/pocket_items/lipstick/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action, params)
	switch(action)
		if("select_lipstick_style")
			var/old_style = get_active_loadout(manager.preferences)[item_path][INFO_LAYER] || MIDDLE_LIP
			var/chosen = tgui_input_list(user, "Pick a lipstick style. This determines where it goes on your sprite.", "Pick a style", list(UPPER_LIP, MIDDLE_LIP, LOWER_LIP), old_style)
			var/list/loadout = get_active_loadout(manager.preferences) // after sleep: sanity check
			if(loadout?[item_path]) // Validate they still have it equipped
				loadout[item_path][INFO_LAYER] = chosen
				update_loadout(manager.preferences, loadout)
			return TRUE // Update UI

		if("select_lipstick_color")
			var/old_color = get_active_loadout(manager.preferences)[item_path][INFO_GREYSCALE] || /obj/item/lipstick::lipstick_color
			var/chosen = input(user, "Pick a lipstick color.", "Pick a color", old_color) as color|null
			var/list/loadout = get_active_loadout(manager.preferences) // after sleep: sanity check
			if(loadout?[item_path]) // Validate they still have it equipped
				loadout[item_path][INFO_GREYSCALE] = chosen
				update_loadout(manager.preferences, loadout)
			return TRUE // Update UI

	return ..()

/datum/loadout_item/pocket_items/razor
	name = "Razor"
	item_path = /obj/item/razor

/datum/loadout_item/pocket_items/lighter
	name = "Lighter"
	item_path = /obj/item/lighter

/datum/loadout_item/pocket_items/plush
	abstract_type = /datum/loadout_item/pocket_items/plush
	can_be_named = TRUE

/datum/loadout_item/pocket_items/plush/bee
	name = "Plush (Bee)"
	item_path = /obj/item/toy/plush/beeplushie

/datum/loadout_item/pocket_items/plush/carp
	name = "Plush (Carp)"
	item_path = /obj/item/toy/plush/carpplushie

/datum/loadout_item/pocket_items/plush/lizard_greyscale
	name = "Plush (Lizard, Colorable)"
	item_path = /obj/item/toy/plush/lizard_plushie/greyscale

/datum/loadout_item/pocket_items/plush/lizard_random
	name = "Plush (Lizard, Random)"
	can_be_greyscale = DONT_GREYSCALE
	item_path = /obj/item/toy/plush/lizard_plushie
	additional_displayed_text = list("Random color")

/datum/loadout_item/pocket_items/plush/moth
	name = "Plush (Moth)"
	item_path = /obj/item/toy/plush/moth

/datum/loadout_item/pocket_items/plush/narsie
	name = "Plush (Nar'sie)"
	item_path = /obj/item/toy/plush/narplush

/datum/loadout_item/pocket_items/plush/nukie
	name = "Plush (Nukie)"
	item_path = /obj/item/toy/plush/nukeplushie

/datum/loadout_item/pocket_items/plush/peacekeeper
	name = "Plush (Peacekeeper)"
	item_path = /obj/item/toy/plush/pkplush

/datum/loadout_item/pocket_items/plush/plasmaman
	name = "Plush (Plasmaman)"
	item_path = /obj/item/toy/plush/plasmamanplushie

/datum/loadout_item/pocket_items/plush/ratvar
	name = "Plush (Ratvar)"
	item_path = /obj/item/toy/plush/ratplush

/datum/loadout_item/pocket_items/plush/rouny
	name = "Plush (Rouny)"
	item_path = /obj/item/toy/plush/rouny

/datum/loadout_item/pocket_items/plush/snake
	name = "Plush (Snake)"
	item_path = /obj/item/toy/plush/snakeplushie

/datum/loadout_item/pocket_items/plush/albertcat
	name = "Plush (Albus)"
	item_path = /obj/item/toy/plush/albertcat
	additional_displayed_text = list("Character Item")

/datum/loadout_item/pocket_items/card_binder
	name = "Card Binder"
	item_path = /obj/item/storage/card_binder

/datum/loadout_item/pocket_items/card_deck
	name = "Playing Card Deck"
	item_path = /obj/item/toy/cards/deck

/datum/loadout_item/pocket_items/kotahi_deck
	name = "Kotahi Deck"
	item_path = /obj/item/toy/cards/deck/kotahi

/datum/loadout_item/pocket_items/wizoff_deck
	name = "Wizoff Deck"
	item_path = /obj/item/toy/cards/deck/wizoff

/datum/loadout_item/pocket_items/dice_bag
	name = "Dice Bag"
	item_path = /obj/item/storage/dice

/datum/loadout_item/pocket_items/d1
	name = "D1"
	item_path = /obj/item/dice/d1

/datum/loadout_item/pocket_items/d2
	name = "D2"
	item_path = /obj/item/dice/d2

/datum/loadout_item/pocket_items/d4
	name = "D4"
	item_path = /obj/item/dice/d4

/datum/loadout_item/pocket_items/d6
	name = "D6"
	item_path = /obj/item/dice/d6

/datum/loadout_item/pocket_items/d6_ebony
	name = "D6 (Ebony)"
	item_path = /obj/item/dice/d6/ebony

/datum/loadout_item/pocket_items/d6_space
	name = "D6 (Space)"
	item_path = /obj/item/dice/d6/space

/datum/loadout_item/pocket_items/d8
	name = "D8"
	item_path = /obj/item/dice/d8

/datum/loadout_item/pocket_items/d10
	name = "D10"
	item_path = /obj/item/dice/d10

/datum/loadout_item/pocket_items/d12
	name = "D12"
	item_path = /obj/item/dice/d12

/datum/loadout_item/pocket_items/d20
	name = "D20"
	item_path = /obj/item/dice/d20

/datum/loadout_item/pocket_items/d100
	name = "D100"
	item_path = /obj/item/dice/d100

/datum/loadout_item/pocket_items/d00
	name = "D00"
	item_path = /obj/item/dice/d00

/datum/loadout_item/pocket_items/tdatet_pack_red
	name = "TDATET Red Pack"
	item_path = /obj/item/cardpack/tdatet

/datum/loadout_item/pocket_items/tdatet_pack_green
	name = "TDATET Green Pack"
	item_path = /obj/item/cardpack/tdatet/green

/datum/loadout_item/pocket_items/tdatet_pack_blue
	name = "TDATET Blue Pack"
	item_path = /obj/item/cardpack/tdatet/blue

/datum/loadout_item/pocket_items/tdatet_pack_mixed
	name = "TDATET Mixed Pack"
	item_path = /obj/item/cardpack/tdatet/mixed

/datum/loadout_item/pocket_items/counter
	name = "Counter"
	item_path = /obj/item/toy/counter

/datum/loadout_item/pocket_items/cybernetics_paintkit
	name = "Cybernetics Paint Kit"
	item_path = /obj/item/cybernetics_paintkit

/datum/loadout_item/pocket_items/umbrella
	name = "Umbrella"
	item_path = /obj/item/umbrella

/datum/loadout_item/pocket_items/black_parasol
	name = "Umbrella (Black Parasol)"
	item_path = /obj/item/umbrella/parasol

/datum/loadout_item/pocket_items/rad_umbrella
	name = "Umbrella (Radiation Shielded)"
	item_path = /obj/item/umbrella/volkan
	additional_displayed_text = list("Character Item")
