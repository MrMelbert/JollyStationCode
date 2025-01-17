/datum/crafting_recipe/barb_bat
	name = "Barbara"
	result = /obj/item/melee/baseball_bat/barbed
	reqs = list(/obj/item/melee/baseball_bat = 1,
				/obj/item/stack/rods = 10,
				)
	tool_behaviors = list(TOOL_WELDER, TOOL_WIRECUTTER)
	time = 1.5 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/home_bat
	name = "Homerun Bat"
	result = /obj/item/melee/baseball_bat/homerun
	reqs = list(/obj/item/melee/baseball_bat = 1,
				/obj/item/toy/crayon/red = 1,
				/obj/item/stock_parts/cell/hyper = 1,
				)
	tool_behaviors = list(TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	time = 2 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/metal_bat
	name = "Metal Bat"
	result = /obj/item/melee/baseball_bat/ablative
	reqs = list(/obj/item/melee/baseball_bat = 1,
				/obj/item/stack/sheet/mineral/plastitanium = 20,
				)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 2 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/volite_amulet
	name = "Volite Amulet"
	result = /obj/item/clothing/neck/mana_star
	reqs = list(
		/obj/item/mana_battery/mana_crystal/cut = 1,
		/obj/item/stack/sheet/mineral/gold = 1, // cheap for now
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/umbrella
	name = "Umbrella"
	result = /obj/item/umbrella
	reqs = list(
		/obj/item/stack/sheet/cloth = 3,
		/obj/item/stack/rods = 1,
	)
	tool_behaviors = list(TOOL_CROWBAR)
	time = 5 SECONDS
	category = CAT_EQUIPMENT
