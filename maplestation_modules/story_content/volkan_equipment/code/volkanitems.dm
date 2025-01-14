/*
 * # Volkan's Equipment
 * Wowie volkan is in the cool club now!
 * Sci-fi things only. For now.
 */
//---------comunication chips---------
/obj/item/computer_disk/volkan/communication_chip //the basic default one
	name = "standard communication chip"
	desc = "A small, grey chip. It has a connector for a standard NT computer. The chip has a white symbol engraved on the top."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/communication_chip.dmi'
	icon_state = "communication_chipc"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

	w_class = WEIGHT_CLASS_TINY
	max_capacity = 1
	starting_programs = list( //this is a messenger after all
		/datum/computer_file/program/messenger/volkan,
	)


/obj/item/computer_disk/volkan/communication_chip/usb //this one has a small USB port instead of the default big chonker connector
	name = "USB communication chip"
	desc = "A small, grey chip. It has a connector for a USB. The chip has a white symbol engraved on the top."
	icon_state = "communication_chipa"

/obj/item/computer_disk/volkan/communication_chip/usb/Initialize(mapload) //add the actual USB port because this one has one
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/ntnet_send/volkan,/obj/item/circuit_component/ntnet_receive/volkan,
	))

/obj/item/computer_disk/volkan/communication_chip/bare //missing a connector entirely.
	name = "communication chip"
	desc = "A small, grey chip. The chip has a white symbol engraved on the top."
	icon_state = "communication_chipb"

/obj/item/computer_disk/volkan/communication_chip/drone //A default one but with the symbol of the drone. Unlikely to be used but good to have here.
	name = "standard communication chip"
	desc = "A small, grey chip. It has a connector for a standard NT computer. The chip has a white symbol engraved on the top."
	icon_state = "communication_chipd"

//---------communication chip data------------
//I would add proper functionality but it sounds like a DAUNTING task.
//Instead have a messenger app that cannot be installed in testing but has a custom name :D

/datum/computer_file/program/messenger/volkan
	filename = "Private Messenger"
	filedesc = "Secure & Private Messenger"
	size = 1
	can_run_on_flags = PROGRAM_ALL

//For the USB port: Basically the ntnet sender and receiver, but with a custom name and description.  IC it would be *all* custom but I am lazy and this is pretty damn close :)
/obj/item/circuit_component/ntnet_send/volkan
	display_name = "Private Sender"
	desc = "A private messenger, sends the data via quantum link to a bluespace relay."
	category = "vnet"

/obj/item/circuit_component/ntnet_receive/volkan
	name = "Private Receiver"
	desc = "A private Receiver, receives the data via quantum link from a bluespace relay."
	category = "vnet"
//---------misc items!---------

//--bots--
//Stored Bot
//I intend to use this base for other ones later, maybe. For if somebody wants to buy a custom one or something. No sprite for this one yet.
/obj/item/volkan/stored_bot
	name = "folded up bot"
	desc = "A folded up, intricate machine. This is probably a long term storage configuration."
	icon = null
	/// the typepath of mob mob that it will turn into
	var/mobtype
	/// the sound the mob will make when it turns on (is created).
	var/startup = 'maplestation_modules/story_content/volkan_equipment/audio/bot_startup.ogg'
	w_class = WEIGHT_CLASS_NORMAL

//activate bot action
/obj/item/volkan/stored_bot/attack_self(mob/user)
	playsound(src, startup, 100, ignore_walls = FALSE)// play startup sound
	addtimer(CALLBACK(src, PROC_REF(spawn_bot)), 0.2 SECONDS) // wait till sound is over

//spawn the bot
/obj/item/volkan/stored_bot/proc/spawn_bot()
	if(QDELETED(src)) //don't make bot if it got qdeleted in the timer.
		return
	//Make mob
	new mobtype(get_turf(src))

	//Remove item
	qdel(src)

//Stored Companion
//Volkan's shoulder companion for within a shift. In storage mode.
/obj/item/volkan/stored_bot/shoulder_pet
	name = "folded up companion"
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/companions.dmi'
	icon_state = "drone_stored"

	mobtype = /mob/living/basic/volkan/shoulder_pet

//--other misc--
//Imprint Key
//A key used to imprint a Volkan bot to whoever has it.
/obj/item/circuitboard/volkan/imprint_key
	name = "imprint key"
	desc = "A very small circuit used for a specific purpose."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/misc_items.dmi'
	icon_state = "imprint_key"
	drop_sound = "sound/items/handling/disk_drop.ogg"
	pickup_sound = "sound/items/handling/disk_pickup.ogg"

	w_class = WEIGHT_CLASS_TINY

///Volkan's umbrella. Stops radiation.
/obj/item/umbrella/volkan
	name = "Volkan's umbrella"
	desc = "A very thick, almost metallic umbrella. It has a dark black plasticky rim on the edge."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/umbrellas.dmi'
	icon_state = "umbrella_volkan"
	inhand_icon_state = "umbrella_volkan_closed"
	lefthand_file = 'maplestation_modules/story_content/volkan_equipment/icons/umbrellas_inhand_lh.dmi'
	righthand_file = 'maplestation_modules/story_content/volkan_equipment/icons/umbrellas_inhand_rh.dmi'

	on_inhand_icon_state = "umbrella_volkan_open"

	random_color = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

/obj/item/umbrella/volkan/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(user)
		if(active)
			ADD_TRAIT(user, TRAIT_RADIMMUNE, TRAIT_GENERIC)
		else
			REMOVE_TRAIT(user, TRAIT_RADIMMUNE, TRAIT_GENERIC)

/obj/item/umbrella/volkan/pickup(mob/user)
	. = ..()
	if (open)
		ADD_TRAIT(user, TRAIT_RADIMMUNE, TRAIT_GENERIC)

/obj/item/umbrella/volkan/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_RADIMMUNE, TRAIT_GENERIC)

/datum/loadout_item/pocket_items/rad_umbrella
	name = "Umbrella (Radiation Shielded)"
	item_path = /obj/item/umbrella/volkan
	additional_displayed_text = list("Character Item")

//---------------------cool boxes!-----------------------

//Unfoldable Box.
//A box designed to hold both a pet and the communication chips for transit. It is easy to unfold once the items inside has been taken out.
/obj/item/storage/box/volkan/unfoldable_box
	name = "unfoldable box"
	desc = "A large metal box with visible seams."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/metal_box.dmi'
	icon_state = "unfoldable_box"
	foldable_result = /obj/item/stack/sheet/iron
	w_class = WEIGHT_CLASS_NORMAL
	illustration = null

/obj/item/storage/box/volkan/unfoldable_box/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = FALSE
	atom_storage.max_total_storage = 10
	atom_storage.max_slots = 3

/obj/item/storage/box/volkan/unfoldable_box/PopulateContents() //The pet, the pet key, and the chip box.
	var/static/items_inside = list(
		/obj/item/storage/box/volkan/chip_box = 1,
		/obj/item/circuitboard/volkan/imprint_key = 1,
		/obj/item/volkan/stored_bot/shoulder_pet = 1,
	)
	generate_items_inside(items_inside, src)

//Chip box
//Designed to hold communication chips
/obj/item/storage/box/volkan/chip_box
	name = "small metal box"
	desc = "A very small rectangular metal box. The box looks like its built to hold specific things."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/metal_box.dmi'
	icon_state = "chip_box"
	foldable_result = null
	illustration = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/volkan/chip_box/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	atom_storage.numerical_stacking = TRUE
	atom_storage.max_total_storage = 5 //It can only hold 5 tiny items, which is 5 chips.
	atom_storage.max_slots = 5

/obj/item/storage/box/volkan/chip_box/PopulateContents() //various chips. 3 of the basic ones and one of the other two just in case.
	var/static/items_inside = list(
		/obj/item/computer_disk/volkan/communication_chip = 3,
		/obj/item/computer_disk/volkan/communication_chip/usb = 1,
		/obj/item/computer_disk/volkan/communication_chip/bare = 1,
	)
	generate_items_inside(items_inside, src)


//Intricate box.
//Designed for gifts and trades.
//NOT for use yet but I am coding this in for when I want to add more Volkan stuff later on :)
/obj/item/storage/box/volkan/intricate_box
	name = "intricate metal box"
	desc = "A lightweight metal box. The box has intricate engraved designs throughout."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/metal_box.dmi'
	icon_state = "intricate_box"
	foldable_result = null
	w_class = WEIGHT_CLASS_NORMAL
	illustration = null

/obj/item/storage/box/volkan/intricate_box/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = TRUE
	atom_storage.max_total_storage = 6
	atom_storage.max_slots = 2 // I expect trades to only have two items max right now.
