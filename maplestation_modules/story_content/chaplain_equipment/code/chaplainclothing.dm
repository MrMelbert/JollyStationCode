/obj/item/clothing/under/rank/cleric
	name = "puligard unifrom"
	desc = "A uniform designed for the faithful holy army of Gilidan."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "clericrobe"
	inhand_icon_state = "clericrobe"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE

/obj/item/clothing/under/rank/cleric/skirt
	name = "puligard uniform skirt"
	desc = "A uniform designed for the faithful holy army of Gilidan. This uniform is fitted with a skirt."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "clericskirt"
	inhand_icon_state = "clericrobe"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE

/obj/item/clothing/shoes/cleric
	name = "puligard's shoes"
	desc = "Soft leather shoes designed for acolyte's of the Puligard church."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "clericshoes"
	inhand_icon_state = "clericshoes"
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	can_be_tied = FALSE
	armor_type = /datum/armor/shoes_jackboots

/obj/item/clothing/suit/hooded/cleric
	name = "puligard's cloak"
	desc = "A soft feathery cloak designed for high ranking officals of the Puligard church."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "clericcloak"
	inhand_icon_state = "clericcloak"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/cleirc
	allowed = list( // melbert, replace this with the global
		/obj/item/book/bible,
		/obj/item/nullrod,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/storage/fancy/candle_box,
		/obj/item/flashlight/flare/candle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/gun/ballistic/bow,
	)
	armor_type = /datum/armor/armor_riot

/obj/item/clothing/head/hooded/cleirc
	name = "puligard's hood"
	desc = "The hood attached to a Puligard's cloak."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "clerichood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEYES|HIDEFACIALHAIR|HIDEEARS
	armor_type = /datum/armor/armor_riot

/obj/item/nullrod/cleric
	name = "holy puligard spear"
	desc = "A gold-bossed, white crystal embeded spear hailing from the holy land of Gilidan. The weight of the spear requires two handed use. Can be worn on the belt."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	icon_state = "spear0"
	base_icon_state = "spear"
	inhand_icon_state = null
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	slot_flags = ITEM_SLOT_BACK
	worn_icon_state = "sacredspear"
	force = 7
	armour_penetration = 30
	throwforce = 20
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("stabs", "pokes", "slashes")
	attack_verb_simple = list("stab", "poke", "slash")
	hitsound = 'sound/weapons/bladeslice.ogg'
	menu_description = "A pointy spear which penetrates armor a little. Can be worn only on the back."

/obj/item/nullrod/cleric/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 7, force_wielded = 18, icon_wielded = "spear1")

/obj/item/nullrod/cleric/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

//Cleric kit
/obj/item/storage/box/holy/cleric
	name = "Puligard Kit"

/obj/item/storage/box/holy/cleric/PopulateContents()
	new /obj/item/clothing/under/rank/cleric(src)
	new /obj/item/clothing/under/rank/cleric/skirt(src)
	new /obj/item/clothing/shoes/cleric(src)
	new /obj/item/clothing/suit/hooded/cleric(src)

/obj/item/clothing/under/rank/security/officer/puligard
	name = "puligard security uniform"
	desc = "A tailored security uniform typically seen worn by members of the Puligard."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "pulisec"
	inhand_icon_state = "pulisec"

/obj/item/clothing/mask/gas/sechailer/puligard
	name = "puligard sechailer"
	desc = "With the Puligards ingenious technological advancements, they in their infinite wisdom wrap a scarf around their face over their sechailers."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "sechailer_pulisec"
	inhand_icon_state = "sechailer_pulisec"

/obj/item/clothing/suit/armor/vest/puligard
	name = "puligard security vest"
	desc = "A semi ceremonial protective vest worn by frontline Puligard members, the red indicates this one is for security officers."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	icon_state = "armor_pulisec"

/obj/item/clothing/head/helmet/sec/puligard
	name = "puligard security uniform"
	desc = "A tailored uniform typically seen worn by members of the Puligard."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "helmet_pulisec"
	inhand_icon_state = "helmet_pulisec"

/obj/item/clothing/gloves/color/black/puligard
	name = "puligard security uniform"
	desc = "Plated gauntlets with soft protective fabric, so the Puligard may enact Her Will without discomfort."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "gloves_pulisec"
	inhand_icon_state = "gloves_pulisec"
	greyscale_config = NONE
	greyscale_config_inhand_left = NONE
	greyscale_config_inhand_right = NONE
	greyscale_colors = NONE
	greyscale_config_worn = NONE

/obj/item/clothing/shoes/jackboots/puligard
	name = "puligard security jackboots"
	desc = "A sturdy pair of boots with added metal plating, typically worn by frontline Puligard members."
	icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_icons.dmi'
	worn_icon = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_worn.dmi'
	lefthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_lhand.dmi'
	righthand_file = 'maplestation_modules/story_content/chaplain_equipment/icons/cleric_rhand.dmi'
	icon_state = "jackboots_pulisec"
	inhand_icon_state = "jackboots_pulisec"
