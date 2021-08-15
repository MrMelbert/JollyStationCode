// --- Loadout item datums for glasses ---

/// Glasses Slot Items (Moves overrided items to backpack)
GLOBAL_LIST_INIT(loadout_glasses, generate_loadout_items(/datum/loadout_item/glasses))

/datum/loadout_item/glasses
	category = LOADOUT_ITEM_GLASSES

/datum/loadout_item/glasses/equip_outfit_with_item(mob/living/equipper, datum/outfit/outfit, visual)
	if(outfit.glasses)
		LAZYADD(outfit.backpack_contents, outfit.glasses)
	outfit.glasses = item_path

/datum/loadout_item/glasses/prescription_glasses
	name = "Glasses"
	item_path = /obj/item/clothing/glasses/regular
	additional_tooltip_contents = list("These glasses function with the 'nearsighted' quirk.")

/datum/loadout_item/glasses/prescription_glasses/circle_glasses
	name = "Circle Glasses"
	item_path = /obj/item/clothing/glasses/regular/circle

/datum/loadout_item/glasses/prescription_glasses/hipster_glasses
	name = "Hipster Glasses"
	item_path = /obj/item/clothing/glasses/regular/hipster

/datum/loadout_item/glasses/prescription_glasses/jamjar_glasses
	name = "Jamjar Glasses"
	item_path = /obj/item/clothing/glasses/regular/jamjar

/datum/loadout_item/glasses/black_blindfold
	name = "Black Blindfold"
	item_path = /obj/item/clothing/glasses/blindfold

/datum/loadout_item/glasses/colored_blindfold
	name = "Colored Blindfold"
	item_path = /obj/item/clothing/glasses/blindfold/white/loadout
	additional_tooltip_contents = list("The color of this item matches your character's eye color on spawn.")

/datum/loadout_item/glasses/cold_glasses
	name = "Cold Glasses"
	item_path = /obj/item/clothing/glasses/cold

/datum/loadout_item/glasses/heat_glasses
	name = "Heat Glasses"
	item_path = /obj/item/clothing/glasses/heat

/datum/loadout_item/glasses/geist_glasses
	name = "Geist Gazers"
	item_path = /obj/item/clothing/glasses/geist_gazers

/datum/loadout_item/glasses/orange_glasses
	name = "Orange Glasses"
	item_path = /obj/item/clothing/glasses/orange

/datum/loadout_item/glasses/psych_glasses
	name = "Psych Glasses"
	item_path = /obj/item/clothing/glasses/psych

/datum/loadout_item/glasses/red_glasses
	name = "Red Glasses"
	item_path = /obj/item/clothing/glasses/red

/datum/loadout_item/glasses/welding_goggles
	name = "Welding Goggles"
	item_path = /obj/item/clothing/glasses/welding
