/obj/item/stack/sheet/mineral/aerialite
	name = "alloyed aerialite"
	desc = "An alloyed blue metal. It shimmers with the power of the skies and cosmos."
	singular_name = "alloyed aerialite bar"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redmaterials.dmi'
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon_state = "sheet-aerialite"
	inhand_icon_state = "sheet-adamantine" // ADD SPRITES.
	mats_per_unit = list(/datum/material/aerialite=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gravitum/aerialite = 20)
	merge_type = /obj/item/stack/sheet/mineral/aerialite
	material_type = /datum/material/aerialite
	armor_type = /datum/armor/sheet_aerialite
	// FUN FACT: This this actually an aerialite --> cosmilite alloy.

/datum/armor/sheet_aerialite
	fire = 100
	acid = 80

/datum/material/aerialite
	name = "alloyed aerialite"
	desc = "Alloyed Aerialite"
	color = "#00d0ff"
	greyscale_colors = "#00d0ff"
	strength_modifier = 3 // You must be a maniac to forge something out of this in the first place.
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/aerialite
	value_per_unit = 6000 / SHEET_MATERIAL_AMOUNT // Giga valuable.
	beauty_modifier = 1.5 // I think aerialite / cosmilite looks nice.
	armor_modifiers = list(MELEE = 2.5, BULLET = 2.5, LASER = 1.5, ENERGY = 1.5, BOMB = 2.5, BIO = 1, FIRE = 1.5, ACID = 1.5)

/datum/material/aerialite/on_applied_obj(obj/o, amount, material_flags)
	. = ..()
	o.AddElement(/datum/element/forced_gravity, 0)

/datum/material/aerialite/on_removed_obj(obj/o, amount, material_flags)
	. = ..()
	o.RemoveElement(/datum/element/forced_gravity, 0)

/obj/item/stack/sheet/mineral/resmythril
	name = "resonant mythril"
	desc = "A resonant turquoise metal. It shimmers with the power of souls and essences."
	singular_name = "resonant mythril bar"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redmaterials.dmi'
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon_state = "sheet-resonant"
	inhand_icon_state = "sheet-adamantine"// ADD SPRITES.
	mats_per_unit = list(/datum/material/resmythril=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/resmythril = 20)
	merge_type = /obj/item/stack/sheet/mineral/resmythril
	material_type = /datum/material/resmythril
	armor_type = /datum/armor/sheet_resmythril
	// FUN FACT: I chose mythril for the scanner module because it's used in the codebreaker's scanner.

/datum/armor/sheet_resmythril
	fire = 100
	acid = 80

/datum/material/resmythril
	name = "resonant mythril"
	desc = "Resonant Mythril"
	color = "#14747c"
	greyscale_colors = "#14747c"
	strength_modifier = 2
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/resmythril
	value_per_unit = 6000 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 2
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.5, LASER = 2.5, ENERGY = 2.5, BOMB = 1.5, BIO = 1, FIRE = 2.5, ACID = 1.5)
	// We already have mythril in the code, so this is resonant.

/obj/item/stack/sheet/mineral/miracle_matter
	name = "Miracle Matter"
	desc = "Its amorphous form contains untold destructive potential. Wish upon a star."
	singular_name = "Miracle Matter"
	icon = "" // ADD SPRITES.
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon_state = "sheet-runite"
	mats_per_unit = list(/datum/material/miracle=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/miracle = 1)
	merge_type = /obj/item/stack/sheet/mineral/miracle_matter
	material_type = /datum/material/miracle

/datum/material/miracle
	name = "Miracle Matter"
	desc = "Miracle Matter"
	color = "#e6a6e0"
	greyscale_colors = "#e6a6e0"
	strength_modifier = 20 // UNTOLD DESTRUCTIVE POTENTIAL.
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/miracle_matter
	value_per_unit = 60000 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 10
	armor_modifiers = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	// The Miracle Matter. This material code will probably never show up, but if you make a toolbox out of Miracle Matter, you are going to oneshot everything.
