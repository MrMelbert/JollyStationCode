/obj/item/stock_parts/cell/bluespace/redtech
	// Just an EMP resistant bluespace cell.
	name = "processed red power cell"
	desc = "A processed power cell. Its design is unlike anything you've seen before. It seems to be EMP resistant."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redcell"
	connector_type = "redcellconnector"
	charge_light_type = null
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plasma=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/consumable/liquidelectricity/auric = 15)

/obj/item/stock_parts/cell/bluespace/redtech/empty
	empty = TRUE

/obj/item/stock_parts/cell/bluespace/redtech/Initialize(mapload)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	return ..()

/obj/item/stock_parts/cell/bluespace/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redcellemissive", src, alpha = src.alpha)

/obj/item/stock_parts/servo/femto/redtech
	// Just a reskinned femto servo.
	name = "alloyed red servo"
	desc = "An alloyed servo module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redservo"
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/carbon = 15, /datum/reagent/gravitum/aerialite = 15)

/obj/item/stock_parts/servo/femto/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redservoemissive", src, alpha = src.alpha)

/obj/item/stock_parts/servo/femto/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/stock_parts/capacitor/quadratic/redtech
	// Reskinned quadratic capacitor.
	name = "processed red capacitor"
	desc = "A processed capacitor module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redcapacitor"
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/consumable/liquidelectricity/auric = 15)

/obj/item/stock_parts/capacitor/quadratic/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redcapacitoremissive", src, alpha = src.alpha)

/obj/item/stock_parts/capacitor/quadratic/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/stock_parts/scanning_module/triphasic/redtech
	// Reskinned triphasic scanner.
	name = "resonant red scanning module"
	desc = "A resonant scanning module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redscanner"
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 15, /datum/reagent/bluespace = 15, /datum/reagent/resmythril = 15)

/obj/item/stock_parts/scanning_module/triphasic/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redscanneremissive", src, alpha = src.alpha)

/obj/item/stock_parts/scanning_module/triphasic/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/stock_parts/micro_laser/quadultra/redtech
	// Reskinned quadultra laser.
	name = "crystalline red micro laser"
	desc = "A crystalline laser module. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redlaser"
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/uranium=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/uranium = 15, /datum/reagent/bluespace = 15, /datum/reagent/exodust = 15)

/obj/item/stock_parts/micro_laser/quadultra/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redlaseremissive", src, alpha = src.alpha)

/obj/item/stock_parts/micro_laser/quadultra/redtech/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/stock_parts/matter_bin/bluespace/redtech
	// Reskinned bluespace matter bin.
	name = "condensed red matter bin"
	desc = "A condensed matter bin. Its design is unlike anything you've seen before."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redparts.dmi'
	icon_state = "redmatterbin"
	// Useful for scrapping.
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/titanium=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace=HALF_SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/iron = 15, /datum/reagent/bluespace = 15, /datum/reagent/darkplasma = 15)

/obj/item/stock_parts/matter_bin/bluespace/redtech/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redmatterbinemissive", src, alpha = src.alpha)

/obj/item/stock_parts/matter_bin/bluespace/redtech/Initialize(mapload)
	. = ..()
	update_appearance()
