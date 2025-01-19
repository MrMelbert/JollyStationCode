/// -- Modular armor items. --
// BO Armor
/datum/armor/bridge_vest
	melee = 25
	bullet = 20
	laser = 20
	energy = 20
	bomb = 15
	bio = 0
	fire = 100
	acid = 90
	wound = 10

/obj/item/clothing/suit/armor/vest/bridge_officer
	name = "bridge officer's armor vest"
	desc = "A somewhat flexible but stiff suit of armor. It reminds you of a simpler time."
	armor_type = /datum/armor/bridge_vest

//Unused, but we're keeping it
/obj/item/clothing/suit/armor/vest/bridge_officer/large
	name = "bridge officer's large armor vest"
	desc = "A larger, yet still comfortable suit of armor worn by Bridge Officers who prefer function over form."
	icon_state = "blueshift"
	inhand_icon_state = "armor"

//AP Armor
/datum/armor/ap_vest
	melee = 40
	bullet = 40
	laser = 40
	energy = 40
	bomb = 30
	bio = 0
	fire = 100
	acid = 90
	wound = 10

/obj/item/clothing/suit/armor/vest/asset_protection
	name = "asset protection's armor vest"
	desc = "A rigid vest of armor worn by Asset Protection. Rigid and stiff, just like your attitude."
	icon_state = "bulletproof"
	inhand_icon_state = "armor"
	armor_type = /datum/armor/ap_vest

/obj/item/clothing/suit/armor/vest/asset_protection/large
	name = "asset protection's large armor vest"
	desc = "A SUPPOSEDLY bulkier, heavier armor that Asset Protection can use when the situation calls for it. Feels identical to your other one."
	icon_state = "blueshift"
	inhand_icon_state = "armor"

// Subtype of the toggle icon component (i know, ew) for GAGS items
/datum/component/toggle_icon/greyscale
	/// Config when toggled.
	var/toggled_config
	/// Worn config when toggled.
	var/toggled_config_worn

/datum/component/toggle_icon/greyscale/Initialize(toggle_noun = "buttons", config, worn_config)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	if(!config || !worn_config)
		stack_trace("[type] component initialized without a greyscale config / worn greyscale config!")
		return COMPONENT_INCOMPATIBLE

	src.toggled_config = config
	src.toggled_config_worn = worn_config

/datum/component/toggle_icon/greyscale/do_icon_toggle(atom/source, mob/living/user)
	. = ..()
	if(isitem(source))
		var/obj/item/item_source = source

		if(toggled)
			item_source.set_greyscale(new_config = toggled_config, new_worn_config = toggled_config_worn)
		else
			item_source.set_greyscale(new_config = initial(item_source.greyscale_config), new_worn_config = initial(item_source.greyscale_config_worn))

		item_source.update_slot_icon()

// GAGS parade uniform, because why not
/obj/item/clothing/suit/greyscale_parade
	name = "tailored parade jacket"
	desc = "No armor, all fashion, unfortunately."
	icon_state = "formal"
	icon_preview = 'maplestation_modules/icons/obj/clothing/suit.dmi'
	icon_state_preview = "formal"
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/storage/box/matches,
		/obj/item/modular_computer/pda,
		/obj/item/toy,
		/obj/item/stamp,
		/obj/item/pen,
		/obj/item/radio,
		/obj/item/knife,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/reagent_containers/cup/glass/flask,
		/obj/item/storage/fancy/candle_box,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/assembly/flash/handheld,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
	)

	greyscale_colors = "#DDDDDD"
	greyscale_config = /datum/greyscale_config/parade_formal
	greyscale_config_worn = /datum/greyscale_config/parade_formal_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/greyscale_parade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon/greyscale, "buttons", /datum/greyscale_config/parade_formal_open, /datum/greyscale_config/parade_formal_open_worn)
