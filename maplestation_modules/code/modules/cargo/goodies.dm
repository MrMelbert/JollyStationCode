/datum/supply_pack/goody/peepy
	name = "Peepy"
	desc = "Each Peepy may differ slightly in appearance, the pattern will be slightly different and your Peepy's face may be aligned slightly more or less off center. \
	It's ok because it's very cute. Peepy is about 6 inches from beak to butt."
	cost = PAYCHECK_CREW * 4
	crate_type = /obj/structure/closet/crate/critter
	contains = list(/obj/item/toy/plush/peepy)

/datum/supply_pack/goody/cut_volite
	name = "Cut Volite Gemstone"
	desc = "An expertly cut volite gemstone, ready to be socketed into an amulet."
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/mana_battery/mana_crystal/cut,
	)

/datum/supply_pack/goody/mana_star
	name = "Pre-Assembled Volite Amulet"
	desc = "A volite gemstone pre-cut and placed within an amulet, saving you the hassle."
	cost = PAYCHECK_CREW * 8
	contains = list(
		/obj/item/clothing/neck/mana_star,
	)

/datum/supply_pack/goody/volite_single_pack
	name = "Volite Crystal Single Pack"
	desc = "A singular volite crystal, ready for use." // planned to be cut with rework part 2, here for ease of access.
	cost = PAYCHECK_CREW * 4
	contains = list(
		/obj/item/mana_battery/mana_crystal/standard,
	)

/datum/supply_pack/goody/small_volite_pack
	name = "Small Volite Crystal Single Pack"
	desc = "A miniaturized volite crystal." // planned to be cut with rework part 2
	cost = PAYCHECK_CREW * 2
	contains = list(
		/obj/item/mana_battery/mana_crystal/small,
	)

/datum/supply_pack/goody/volitious_lignite_single_pack
	name = "Volitious Lignite Pack"
	desc = "A single pack of a natural source of volite, volitious lignite."
	cost = PAYCHECK_CREW * 2
	contains = list(
		/obj/item/mana_battery/mana_crystal/lignite,
	)
