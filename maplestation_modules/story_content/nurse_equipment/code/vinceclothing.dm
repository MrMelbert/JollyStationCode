// -- nurse outfit --

/obj/item/clothing/under/dress/vince
	name = "violet nurse uniform"
	desc = "A short violet nurse dress, lined with subtle red and pink hues."
	icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_item.dmi'
	worn_icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_worn.dmi'
	icon_state = "vincedress"
	resistance_flags = INDESTRUCTIBLE

/datum/loadout_item/under/jumpsuit/vince
	name = "Violet Nurse Uniform"
	item_path = /obj/item/clothing/under/dress/vince
	additional_displayed_text = list("Character Item")

/obj/item/clothing/shoes/vince
	name = "slick syringe heels"
	desc = "Black pumps with decorative syringes making the heels. They're decorative, right?"
	icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_item.dmi'
	worn_icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_worn.dmi'
	icon_state = "vinceshoes"
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/shoes/vince/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shoe_footstep, \
		sounds = list( \
			'maplestation_modules/sound/items/highheel1.ogg', \
			'maplestation_modules/sound/items/highheel2.ogg', \
		), \
		volume = 55, \
		chance_per_play = 50, \
		can_tape = TRUE, \
	)

/datum/loadout_item/shoes/vince
	name = "Slick Syringe Heels"
	item_path = /obj/item/clothing/shoes/vince
	additional_displayed_text = list("Character Item")

/obj/item/clothing/head/costume/vince
	name = "violet nurse cap"
	desc = "A violet nurse cap with a deep red 'X' on it. Shouldn't violate the Geneva Convention."
	icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_item.dmi'
	worn_icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_worn.dmi'
	icon_state = "vincecap"
	resistance_flags = INDESTRUCTIBLE

/datum/loadout_item/head/vince
	name = "Violet Nurse Cap"
	item_path = /obj/item/clothing/head/costume/vince
	additional_displayed_text = list("Character Item")

/obj/item/clothing/gloves/vince
	name = "buckled black gloves"
	desc = "Slick black gloves with a neon green palm and pink lining. Poisonous!"
	icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_item.dmi'
	worn_icon = 'maplestation_modules/story_content/nurse_equipment/icons/vince_worn.dmi'
	icon_state = "vincegloves"
	resistance_flags = INDESTRUCTIBLE

/datum/loadout_item/gloves/vince
	name = "Buckled Black Gloves"
	item_path = /obj/item/clothing/gloves/vince
	additional_displayed_text = list("Character Item")
