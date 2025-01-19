/obj/item/storage/dread_storage
	name = "Heavy Duty Storage Unit"
	desc = "A heavy duty storage unit, designed to hold a large amount of items. You could carry it around, but it's too big to equip."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreaditems.dmi'
	icon_state = "storageunit"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi' // Change this to a prexisting sprite, I do not want to make a new one.
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "rack_parts"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor_type = /datum/armor/dread_storage
	storage_type = /datum/storage/dread_storage

/datum/armor/dread_storage
	fire = 100
	acid = 50

/datum/storage/dread_storage
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = 90
	max_slots = 30
	allow_big_nesting = TRUE

/obj/item/clothing/neck/cloak/redtech_dread
	name = "The Collector's Cloak"
	desc = "The Collector's Cloak, a heavy duty cloak lined with heavy metals the wearer from external analysis. It's a bit bulky and was probably made for something a lot larger than you."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreaditems.dmi'
	worn_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothing.dmi'
	icon_state = "cloak"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/neck/cloak/redtech_dread/pattern
	worn_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothingbig.dmi'
	icon_state = "cloak_pattern"

/obj/item/clothing/mask/collector
	name = "The Collector's Mask"
	desc = "A strange oriental fox mask, made of heavy metal. It's half black and half white, with only one eye hole."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreaditems.dmi'
	worn_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothing.dmi'
	icon_state = "mask"
	w_class = WEIGHT_CLASS_BULKY
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/mask/collector/pattern
	worn_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothingbig.dmi'
	icon_state = "mask_pattern"

/obj/item/implant/radio/redtech
	desc = "Redtech."
	radio_key = /obj/item/encryptionkey/redtech
	subspace_transmission = TRUE

/obj/item/encryptionkey/redtech
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_SYNDICATE = 1)
	translate_binary = TRUE
	translated_language = /datum/language/machine
	syndie = TRUE
	greyscale_config = /datum/greyscale_config/encryptionkey_syndicate
	greyscale_colors = "#171717#990000"
