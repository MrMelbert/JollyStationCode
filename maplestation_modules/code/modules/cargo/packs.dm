// -- Modular cargo packs --

#define GROUP_DRUGS "Prescriptions (Goodies)"

/datum/supply_pack/goody/luciferium_bottle
	name = "Luciferium Bottle"
	desc = "Contains one bottle - twenty units - of Luciferium, an extremely dangerous medicine. Use with great caution."
	group = GROUP_DRUGS
	cost = PAYCHECK_COMMAND * 15
	contraband = TRUE
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/luciferium,
	)

/datum/supply_pack/medical/luciferium_bottles
	name = "Luciferium Shipment"
	desc = "Contains three bottles - sixty units - of Luciferium, an extremely dangerous drug that can cure the most absolute of medicinal issues, but cause permanent addiction. Requires CMO access to open."
	cost = PAYCHECK_COMMAND * 60
	access = ACCESS_CMO
	contraband = TRUE
	crate_name = "luciferium Shipment"
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/luciferium,
		/obj/item/reagent_containers/cup/glass/bottle/luciferium,
		/obj/item/reagent_containers/cup/glass/bottle/luciferium,
	)

/datum/supply_pack/goody/go_juice_bottle
	name = "Go-Juice Bottle"
	desc = "Contains one bottle - twenty units - of Go-Juice, a potent but addictive combat stimulant."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 10
	contraband = TRUE
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/gojuice,
	)

/datum/supply_pack/medical/go_juice_bottles
	name = "Go-Juice Shipment"
	desc = "Contains three bottles - sixty units - of Go-Juice, a potent but addictive combat stimulant and pain suppressant. Requires armory access to open."
	cost = PAYCHECK_COMMAND * 20
	contraband = TRUE
	access = ACCESS_ARMORY
	crate_name = "go-juice Shipment"
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/gojuice,
		/obj/item/reagent_containers/cup/glass/bottle/gojuice,
		/obj/item/reagent_containers/cup/glass/bottle/gojuice,
	)

/datum/supply_pack/medical/psychoids
	name = "Psychoid Variety Shipment"
	desc = "Contains three randomly selected containers of drugs made from the psychoid leaf - Yayo, Flake, or Psychite Tea - often used to reduce pain and raise moods. Requires medical access to open."
	cost = PAYCHECK_COMMAND * 16
	access = ACCESS_MEDICAL
	crate_name = "psychoid shipment"
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/flake,
		/obj/item/reagent_containers/cup/glass/bottle/yayo,
		/obj/item/reagent_containers/cup/glass/mug/psychite_tea,
		/obj/item/reagent_containers/cup/glass/mug/psychite_tea,
	)

/datum/supply_pack/medical/psychoids/fill(obj/structure/closet/crate/spawned_crate)
	for(var/i in 1 to 3)
		var/item = pick(contains)
		new item(spawned_crate)

/datum/supply_pack/goody/psychite_tea
	name = "Psychite Tea Order"
	desc = "Contains two mugs of Psychite Tea, a slightly addictive but mood boosting tea made from the distant psychoid leaf."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 8
	contains = list(
		/obj/item/reagent_containers/cup/glass/mug/psychite_tea,
		/obj/item/reagent_containers/cup/glass/mug/psychite_tea,
	)

/datum/supply_pack/goody/oxycodone_syringe
	name = "Oxycodone Syringe"
	desc = "Contains three injections of Oxycodone, an extremely addictive but effective painkiller."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 4
	contains = list(
		/obj/item/reagent_containers/syringe/oxycodone,
	)

/datum/supply_pack/goody/morphine_syringe
	name = "Morphine Syringe"
	desc = "Contains three injections of Morphine, an addictive painkiller used to treat moderate pain."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 3
	contains = list(
		/obj/item/reagent_containers/syringe/morphine,
	)


/obj/item/storage/pill_bottle/prescription/aspirin_para_coffee
	pill_type = /obj/item/reagent_containers/pill/aspirin_para_coffee
	num_pills = 3

/datum/supply_pack/goody/aspirin_para_coffee
	name = "Aspirin/paracetamol/caffeine Prescription"
	desc = "Contains a pill bottle of aspirin/paracetamol/caffeine, a combination painkiller used to treat pain with few side effects."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 7.5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/aspirin_para_coffee,
	)

/obj/item/storage/pill_bottle/prescription/paracetamol
	pill_type = /obj/item/reagent_containers/pill/paracetamol
	num_pills = 3

/datum/supply_pack/goody/paracetamol
	name = "Paracetamol Prescription"
	desc = "Contains a pill bottle of Paracetamol."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/paracetamol,
	)

/obj/item/storage/pill_bottle/prescription/aspirin
	pill_type = /obj/item/reagent_containers/pill/aspirin
	num_pills = 3

/datum/supply_pack/goody/aspirin
	name = "Aspirin Prescription"
	desc = "Contains a pill bottle of Aspirin."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/aspirin,
	)

/obj/item/storage/pill_bottle/prescription/ibuprofen
	pill_type = /obj/item/reagent_containers/pill/ibuprofen
	num_pills = 3

/datum/supply_pack/goody/ibuprofen
	name = "Ibuprofen Prescription"
	desc = "Contains a pill bottle of Ibuprofen."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/ibuprofen,
	)

/obj/item/storage/pill_bottle/prescription/happiness
	pill_type = /obj/item/reagent_containers/pill/happinesspsych
	num_pills = 5

/datum/supply_pack/goody/happiness
	name = "Mood Stabilizer Prescription"
	desc = "Contains a pill bottle of Mood Stabilizers. May contain Happiness."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/happiness,
	)

/obj/item/storage/pill_bottle/prescription/psicodine
	pill_type = /obj/item/reagent_containers/pill/psicodine
	num_pills = 3

/datum/supply_pack/goody/psicodine
	name = "Psicodine Prescription"
	desc = "Contains a pill bottle of Psicodine."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/psicodine,
	)

/datum/supply_pack/goody/experimental
	name = "Experimental Medicine Prescription"
	desc = "Contains a pill bottle of Experimental Medicine required for living with Hereditary Manifold Sickness."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 4
	contains = list(
		/obj/item/storage/pill_bottle/sansufentanyl,
	)

/obj/item/storage/pill_bottle/prescription/naloxone
	pill_type = /obj/item/reagent_containers/pill/naloxone
	num_pills = 3

/datum/supply_pack/goody/naloxone
	name = "Naloxone Prescription"
	desc = "Contains a pill bottle of Naloxone, which helps with opioid overdoses and addiction."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/naloxone,
	)

/obj/item/storage/pill_bottle/prescription/buproprion
	pill_type = /obj/item/reagent_containers/pill/buproprion
	num_pills = 3

/datum/supply_pack/goody/buproprion
	name = "Buproprion Prescription"
	desc = "Contains a pill bottle of Buproprion, which helps with stimulant and nicotine addiction."
	group = GROUP_DRUGS
	cost = PAYCHECK_CREW * 5
	contains = list(
		/obj/item/storage/pill_bottle/prescription/buproprion,
	)

/datum/supply_pack/medical/painkiller_syringes
	name = "Painkiller Syringe Shipment"
	desc = "Contains six syringes of general medicinal painkillers - Ibuprofen, Paracetamol, and Aspirin."
	cost = PAYCHECK_COMMAND * 15
	crate_name = "syringe shipment"
	contains = list(
		/obj/item/reagent_containers/syringe/ibuprofen,
		/obj/item/reagent_containers/syringe/ibuprofen,
		/obj/item/reagent_containers/syringe/paracetamol,
		/obj/item/reagent_containers/syringe/paracetamol,
		/obj/item/reagent_containers/syringe/aspirin,
		/obj/item/reagent_containers/syringe/aspirin,
	)

/datum/supply_pack/medical/painkiller_pens
	name = "Painkiller Medipen Shipment"
	desc = "Contains three emergency painkiller medipens."
	cost = PAYCHECK_COMMAND * 8
	crate_name = "medipen shipment"
	contains = list(
		/obj/item/reagent_containers/hypospray/medipen/emergency_painkiller,
		/obj/item/reagent_containers/hypospray/medipen/emergency_painkiller,
		/obj/item/reagent_containers/hypospray/medipen/emergency_painkiller,
	)

/datum/supply_pack/goody/crew_plasma_sword_pack // this is, in effect, now a placeholder/current thing only. there are plans to rework this to instead require upgrades to get this to be good.
	name = "Plasma Blade Case"
	desc = "A premium (standard) case containing a highly advanced (dangerously volatile) NT Plasma Sword. Requires permit for open carry and use, but not for purchase."
	cost = PAYCHECK_CREW * 30 // this should equal roughly 1500 credits on average.
	contains = list(/obj/item/melee/maple_plasma_blade)

/datum/supply_pack/medical/liver_autodoc
	name = "Liver Replacement Autosurgeon"
	desc = "Contains an emergency autosurgeon capable of quickly replacing a patient's damaged liver. \
		Liver not included. Requires surgery access to open."
	cost = PAYCHECK_COMMAND * 20
	access = ACCESS_SURGERY
	contains = list(/obj/item/autosurgeon/only_on_damaged_organs/liver)
	crate_name = "autosurgeon crate"

/datum/supply_pack/medical/lung_autodoc
	name = "Lung Replacement Autosurgeon"
	desc = "Contains an emergency autosurgeon capable of quickly replacing a patient's damaged lungs. \
		Lungs not included. Requires surgery access to open."
	cost = PAYCHECK_COMMAND * 20
	access = ACCESS_SURGERY
	contains = list(/obj/item/autosurgeon/only_on_damaged_organs/lungs)
	crate_name = "autosurgeon crate"

/datum/supply_pack/costumes_toys/ornithid_mask
	name = "Ornithid Mask Crate"
	desc = "A cheap bundle containing all kinds of Ornithid masks."
	cost = PAYCHECK_COMMAND * 3 //300 cr, selling the crate back actually makes 284 cr
	contains = list(
		/obj/item/clothing/mask/breath/ornithid/cardinal,
		/obj/item/clothing/mask/breath/ornithid/secretary,
		/obj/item/clothing/mask/breath/ornithid/toucan,
		/obj/item/clothing/mask/breath/ornithid/bluejay,
	)

/datum/supply_pack/science/volite_shipment
	name = "Volite Shipment"
	desc = "A bundle containing 5 volite formations."
	cost = PAYCHECK_COMMAND * 8 // 800, 4x the cost of a single volite crystal
	contains = list(
		/obj/item/mana_battery/mana_crystal/standard,
		/obj/item/mana_battery/mana_crystal/standard,
		/obj/item/mana_battery/mana_crystal/standard,
		/obj/item/mana_battery/mana_crystal/standard,
		/obj/item/mana_battery/mana_crystal/standard,
	)

/datum/supply_pack/science/volite_shipment
	name = "Small Volite Crystal Shipment"
	desc = "A bundle containing 6 miniature volite crystals."
	cost = PAYCHECK_COMMAND * 5
	contains = list(
		/obj/item/mana_battery/mana_crystal/small,
		/obj/item/mana_battery/mana_crystal/small,
		/obj/item/mana_battery/mana_crystal/small,
		/obj/item/mana_battery/mana_crystal/small,
		/obj/item/mana_battery/mana_crystal/small,
		/obj/item/mana_battery/mana_crystal/small,
	)

/datum/supply_pack/science/cut_volite_crystals
	name = "Cut Volite Gemstone Pack"
	desc = "A bundle containing 4 expertly cut volite crystals, to be slotted in an amulet."
	cost = PAYCHECK_COMMAND * 9
	contains = list(
		/obj/item/mana_battery/mana_crystal/cut,
		/obj/item/mana_battery/mana_crystal/cut,
		/obj/item/mana_battery/mana_crystal/cut,
		/obj/item/mana_battery/mana_crystal/cut,
	)

/datum/supply_pack/science/volitious_lignite_single_pack
	name = "Volitious Lignite Pack"
	desc = "A bundle containing 5 pieces of a natural source of volite, volitious lignite."
	cost = PAYCHECK_COMMAND * 2
	contains = list(
		/obj/item/mana_battery/mana_crystal/lignite,
		/obj/item/mana_battery/mana_crystal/lignite,
		/obj/item/mana_battery/mana_crystal/lignite,
		/obj/item/mana_battery/mana_crystal/lignite,
		/obj/item/mana_battery/mana_crystal/lignite,
	)

