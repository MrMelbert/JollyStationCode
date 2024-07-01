/obj/item/clothing/head/utility/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	inhand_icon_state = "welding"
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.75, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT
	drop_sound = 'maplestation_modules/sound/items/drop/helm.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/helm.ogg'

/datum/armor/utility_welding
	melee = 10
	fire = 100
	acid = 60

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/head/utility/welding/visor_toggling()
	. = ..()
	inhand_icon_state = "[initial(inhand_icon_state)][up ? "off" : ""]"
