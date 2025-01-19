// Need to override this so that T5 parts can be used without crashing.
/datum/stock_part/energy_rating()
	switch (tier)
		if (1)
			return 1
		if (2)
			return 3
		if (3)
			return 5
		if (4)
			return 10
		if (5)
			return 20
		else
			CRASH("Invalid level given to energy_rating: [tier]")

/obj/item/stock_parts/cell/redtech
	name = "processed red power cell"
	desc = "A processed power cell. Its design is unlike anything you've seen before. It seems to be EMP resistant."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redcell"
	// connector_type = "redcellconnector"
	charge_light_type = null
	rating = 4

	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = STANDARD_CELL_CHARGE * 5

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/plasma=SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/consumable/liquidelectricity/auric = 15)

/obj/item/stock_parts/cell/redtech/empty
	empty = TRUE

/obj/item/stock_parts/cell/redtech/Initialize(mapload)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	return ..()

/obj/item/stock_parts/cell/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redcellemissive", src, alpha = src.alpha)

/obj/item/stock_parts/cell/redtech/nonetech
	name = "Nonetech power cell"
	desc = "A Nonetech power cell. Its design is oddly familiar. It seems to be EMP resistant."
	icon_state = "nonecell"

/datum/stock_part/matter_bin/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/cell/redtech

/obj/item/stock_parts/servo/redtech
	name = "alloyed red servo"
	desc = "An alloyed servo module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redservo"

	rating = 5
	energy_rating = 20

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/titanium=SHEET_MATERIAL_AMOUNT, /datum/material/diamond=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/carbon = 15, /datum/reagent/gravitum/aerialite = 15)

/obj/item/stock_parts/servo/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redservoemissive", src, alpha = src.alpha)

/obj/item/stock_parts/servo/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/datum/stock_part/servo/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/servo/redtech

// Basically have to override the entire thing to allow T5 servos to dispense emagged reagents.
/obj/machinery/chem_dispenser/RefreshParts()
	. = ..()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	var/parts_rating = 0
	for(var/obj/item/stock_parts/cell/stock_cell in component_parts)
		cell = stock_cell
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		newpowereff += 0.0166666666 * matter_bin.tier
		parts_rating += matter_bin.tier
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		recharge_amount *= capacitor.tier
		parts_rating += capacitor.tier
	for(var/datum/stock_part/servo/servo in component_parts)
		if (servo.tier > 3)
			dispensable_reagents |= upgrade_reagents
		else
			dispensable_reagents -= upgrade_reagents
		// Tier 5 servo parts are special and allow for emagged reagents.
		if (servo.tier > 4)
			dispensable_reagents |= emagged_reagents
		else
			dispensable_reagents -= emagged_reagents
		parts_rating += servo.tier
	powerefficiency = round(newpowereff, 0.01)

/obj/item/stock_parts/capacitor/redtech
	name = "processed red capacitor"
	desc = "A processed capacitor module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redcapacitor"

	rating = 5
	energy_rating = 20

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/titanium=SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/consumable/liquidelectricity/auric = 15)

/obj/item/stock_parts/capacitor/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redcapacitoremissive", src, alpha = src.alpha)

/obj/item/stock_parts/capacitor/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/datum/stock_part/capacitor/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/capacitor/redtech

/obj/item/stock_parts/scanning_module/redtech
	name = "resonant red scanning module"
	desc = "A resonant scanning module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redscanner"

	rating = 5
	energy_rating = 20

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/gold=SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 15, /datum/reagent/bluespace = 15, /datum/reagent/resmythril = 15)

/obj/item/stock_parts/scanning_module/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redscanneremissive", src, alpha = src.alpha)

/obj/item/stock_parts/scanning_module/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/datum/stock_part/scanning_module/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/scanning_module/redtech

/obj/item/stock_parts/micro_laser/redtech
	name = "crystalline red micro laser"
	desc = "A crystalline laser module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redlaser"

	rating = 5
	energy_rating = 20

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/uranium=SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/uranium = 15, /datum/reagent/bluespace = 15, /datum/reagent/exodust = 15)

/obj/item/stock_parts/micro_laser/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redlaseremissive", src, alpha = src.alpha)

/obj/item/stock_parts/micro_laser/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/datum/stock_part/micro_laser/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/micro_laser/redtech
/obj/item/stock_parts/matter_bin/redtech
	name = "condensed red matter bin"
	desc = "A condensed matter bin. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redmatterbin"

	rating = 5
	energy_rating = 20

	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/titanium=SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/darkplasma = 15)

/obj/item/stock_parts/matter_bin/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redmatterbinemissive", src, alpha = src.alpha)

/obj/item/stock_parts/matter_bin/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/datum/stock_part/matter_bin/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/matter_bin/redtech
