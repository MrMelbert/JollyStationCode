/obj/item/clothing/under/rank/captain/formal
	name = "captain's turtleneck"
	desc = "Clothing designed for the commander of the station, the turtleneck is soft to the touch."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "capturtleneck"
	// Sleeves adjusted: "capturtleneck_r"
	// Adjusted: "capturtleneck_r"
	// Inhand: "uni"
	// Worn: "capturtleneck"
	icon_state = "capturtleneck"
	inhand_icon_state = "capturtleneck"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor_type = /datum/armor/clothing_under/rank_captain

/obj/item/clothing/under/rank/captain/formal/skirt
	name = "captain's skirtleneck"
	desc = "A uniform designed for the commander of the station, the skirt is just long enough to clear the length standard."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "capskirtleneck"
	// Sleeves adjusted: "capskirtleneck_r"
	// Adjusted: "capskirtleneck_d"
	// Inhand: "uni"
	// Worn: "capskirtleneck"
	icon_state = "capskirtleneck"
	inhand_icon_state = "capturtleneck"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor_type = /datum/armor/clothing_under/rank_captain

/obj/item/clothing/shoes/jackboots/captain
	name = "captain's boots"
	desc = "Hard leather boots meant for the commander of the station, these boots look combat ready."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "capboots"
	// Inhand: "capboots"
	// Worn: "capboots"
	icon_state = "capboots"
	inhand_icon_state = "capboots"
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	can_be_tied = FALSE
	armor_type = /datum/armor/shoes_jackboots

/obj/item/clothing/gloves/captain/formal
	name = "captain's black gloves"
	desc = "Black gloves commanding officer gloves with a sleek appearance to them."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "capgloves"
	// Inhand: "capgloves"
	// Worn: "capgloves"
	icon_state = "capgloves"
	inhand_icon_state = "capgloves"
	siemens_coefficient = 0
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	resistance_flags = NONE
	armor_type = /datum/armor/captain_gloves

/obj/item/clothing/suit/armor/vest/capformalcarapace
	name = "captain's quality carapace"
	desc = "A high quality carapace fitted with sturdy painted metal plating. This one is meant for the stations commander."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "caparmorvest"
	// Inhand: "caparmorvest"
	// Worn: "noblejacket"
	icon_state = "caparmorvest"
	inhand_icon_state = "caparmorvest"
	body_parts_covered = CHEST|GROIN
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/vest_capcarapace

/obj/item/clothing/suit/armor/vest/capvestformal
	name = "captain's vest"
	desc = "An elegant heavy duty vest. It appears that this vest was modified from a bullet proof vest."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	// Item: "capvest"
	// Inhand: "capvest"
	// Worn: "capvest"
	icon_state = "capvest"
	inhand_icon_state = "capvest"
	body_parts_covered = CHEST|GROIN
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/vest_capcarapace

/obj/item/clothing/neck/cloak/capformal
	name = "captain's half cape"
	desc = "Worn by the commander of the station, this cape only covers half of the body."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_icon.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/captain_equipment/captain_rhand.dmi'
	icon_state = "caphalfcape"
	inhand_icon_state = "caphalfcape"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/storage/bag/garment/cap_cust
	name = "captain's extended garment bag"
	desc = "Due to the captain's over-extravagance, a second garment bag had to be requisitioned to hold all of their various outfits."

	// Clothes to the bag
/obj/item/storage/bag/garment/cap_cust/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/rank/captain/formal(src)
	new /obj/item/clothing/under/rank/captain/formal/skirt(src)
	new /obj/item/clothing/shoes/jackboots/captain(src)
	new /obj/item/clothing/gloves/captain/formal(src)
	new /obj/item/clothing/suit/armor/vest/capformalcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capvestformal(src)
	new /obj/item/clothing/neck/cloak/capformal(src)

/obj/structure/closet/secure_closet/captains/PopulateContents()
	. = ..()
	new /obj/item/storage/bag/garment/cap_cust(src)
