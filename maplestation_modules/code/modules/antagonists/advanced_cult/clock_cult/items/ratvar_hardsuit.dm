// Clockwork hardsuit and helemet.
/obj/item/clothing/head/hooded/clock
	name = "\improper Rat'varian clockwork suit"
	desc = "A heavily-armored helmet worn by warriors of the Rat'varian cult. It can withstand hard vacuum."
	icon = 'icons/mob/clothing/head/chaplain.dmi'
	icon_state = "clockwork_helmet"
	inhand_icon_state = null
	armor_type = /datum/armor/clockword_suit
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	cold_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	heat_protection = HEAD
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	actions_types = list()
	strip_delay = 5 SECONDS
	equip_delay_other = 5 SECONDS

/obj/item/clothing/suit/hooded/clock
	name = "\improper Rat'varian clockwork suit"
	desc = "A heavily-armored exosuit worn by warriors of the Rat'varian cult. It can withstand hard vacuum."
	icon = 'icons/obj/clothing/suits/chaplain.dmi'
	icon_state = "clockwork_cuirass"
	worn_icon_state = "clockwork_cuirass"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/clockwork_slab, /obj/item/melee/ratvar_spear, /obj/item/tank/internals, /obj/item/construction/rcd/clock)
	hoodtype = /obj/item/clothing/head/hooded/clock
	armor_type = /datum/armor/clockword_suit //Slightly better than a secvest
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	resistance_flags = NONE
	strip_delay = 8 SECONDS
	equip_delay_other = 8 SECONDS

/datum/armor/clockword_suit
	melee = 40
	bullet = 35
	laser = 30
	energy = 40
	bomb = 50
	bio = 30
	fire = 100
	acid = 100
	wound = 10

// Hack to get around hooded things changing their icon state
/obj/item/clothing/suit/hooded/clock/ToggleHood()
	. = ..()
	icon_state = initial(icon_state)
