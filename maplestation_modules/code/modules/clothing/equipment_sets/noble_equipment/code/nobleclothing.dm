// Hi Melbert :)

/obj/item/clothing/under/rank/noble
	name = "quality suit"
	desc = "A high quality shirt with slacks, it's soft to the touch."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "noblesuit"
	inhand_icon_state = "noblesuit"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE

/obj/item/clothing/under/rank/noblealt
	name = "formal dress"
	desc = "A dress made from silk. The dress is embroidered with an elaborate blue pattern."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "nobledress"
	inhand_icon_state = "nobledress"
	supports_variations_flags = CLOTHING_NO_VARIATION
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDESHOES

/obj/item/clothing/shoes/noble
	name = "fancy loafers"
	desc = "Hard leather loafers with thick soles on the bottom, the leather lightly shines in the light."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "nobleshoes"
	inhand_icon_state = "nobleshoes"

/obj/item/clothing/shoes/noblealt
	name = "white heels"
	desc = "Delicate white heels with a gold clasp. This pair looks very well cared for."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "nobleheels"
	inhand_icon_state = "nobleheels"

/obj/item/clothing/shoes/noblealt/Initialize(mapload)
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

/obj/item/clothing/gloves/noble
	name = "black leather gloves"
	desc = "Tough black leather gloves with the top section cut off for breathability."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "noblegloves"
	inhand_icon_state = "noblegloves"

/obj/item/clothing/gloves/noblealt
	name = "silky sleeves"
	desc = "Delicate white sleeves detatched from their intended partner. Wearing them makes you feel just a tad more delicate."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "noblesleeves"
	inhand_icon_state = "noblesleeves"

/obj/item/clothing/suit/toggle/noble
	name = "quality suit coat"
	desc = "A fitted black coat lined with golden embroidery."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "noblejacket"
	inhand_icon_state = "noblejacket"


/obj/item/clothing/head/costume/crown/noble
	name = "jeweled tiara"
	desc = "A sparkling tiara set with multiple white and red gems. The center gemstone especially sparkled in the light."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "noblecrown"
	inhand_icon_state = "noblecrown"

//I offically need an adult :(

/obj/item/clothing/under/rank/chiffon
	name = "chiffon dress"
	desc = "A dress made from silk chiffon. The elegant fabric was guaranteed to draw attention."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantdress"
	inhand_icon_state = "elegantdress"
	supports_variations_flags = CLOTHING_NO_VARIATION
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDESHOES

/obj/item/clothing/suit/costume/chiffon
	name = "chiffon lace coat"
	desc = "A lace chiffon overcoat that falls delicately along the form of the wearer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantcoat"
	inhand_icon_state = "elegantcoat"

/obj/item/clothing/gloves/chiffon
	name = "chiffon gloves"
	desc = "Delicate gloves that felt soft to the touch. Commit crimes with elegance!"
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantgloves"
	inhand_icon_state = "elegantgloves"

/obj/item/clothing/gloves/chiffon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/glove_slapper)

//The type path is a lie.
/obj/item/clothing/shoes/chiffon
	name = "velvet flats"
	desc = "Delicate velvet flats in a purplish pink color. The flats offered a lot of support for the arch of the foot."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantflats"
	inhand_icon_state = "elegantflats"

/obj/item/clothing/head/costume/chiffonbow
	name = "chiffon bow"
	desc = "A dainty bow made from similar materials from it matching dress and coat."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantbow"
	inhand_icon_state = "elegantbow"

//This type path is also a lie.
/obj/item/storage/backpack/satchel/leather/chiffon
	name = "velvet satchel"
	desc = "A fancy satchel. The interior was lined with soft velvet."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "elegantsatchel"
	inhand_icon_state = "elegantsatchel"

/obj/item/clothing/under/rank/noble/penrose
	name = "ancient suit"
	desc = "A suit made from an unidentifiable material. Staring at it fills you with a sense of existential dread."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "penrosesuit"
	inhand_icon_state = "penrosesuit"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/suit/toggle/noble/penrose
	name = "ancient dinner coat"
	desc = "A luxurious coat made from an unidentifiable material. The gem on the coat begs you to step closer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "penrosecoat"
	inhand_icon_state = "penrosecoat"
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/gloves/penrose
	name = "ancient gloves"
	desc = "Flexable gloves made from an unidentifiable material."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "penrosegloves"
	inhand_icon_state = "penrosegloves"
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/shoes/jackboots/penrose
	name = "ancient boots"
	desc = "An old pair of boots made from an unidentifable material. These boots have taken their fair share of steps."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "penroseboots"
	inhand_icon_state = "penroseboots"
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/neck/cloak/penrose
	name = "ancient scarf"
	desc = "A strong scarf made from an unknown material. You get the feeling there's more to it than meets the eye."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "penrosescarf"
	inhand_icon_state = "penrosescarf"
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/head/costume/hairpin
	name = "elaborate hairpin"
	desc = "A jewled hairpin only made for the most delicate of being."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "hairpin_fancy"
	inhand_icon_state = "hairpin_fancy"

/obj/item/clothing/under/kimono/fancy
	name = "fancy kimono"
	desc = "A beatifuly elaborate kimono made from fine delicate silk."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "kimono_fancy"
	inhand_icon_state = "kimono_fancy"
	supports_variations_flags = CLOTHING_NO_VARIATION
	can_adjust = TRUE
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER

/obj/item/clothing/shoes/jackboots/plague
	name = "plaguestrider boots"
	desc = "Sturdy and resilient boots, aptly named for their ability to stride confidently through plague-ridden terrains, offering both protection and mobility for the dedicated healer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plagueboots"
	inhand_icon_state = "plagueboots"
	armor_type = /datum/armor/plauge
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/clothing/shoes/jackboots/plague/Initialize(mapload)
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

/obj/item/clothing/gloves/latex/nitrile/plague
	name = "shadowlace talons"
	desc = "Gloves with an aura of nocturnal grace, featuring talon-like fingertips adorned in shadowlace, allowing mystery and precision essential for a skilled doctor's interventions."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plaguegloves"
	inhand_icon_state = "plaguegloves"
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor_type = /datum/armor/plauge

/obj/item/clothing/gloves/latex/nitrile/plague/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/glove_slapper)

/obj/item/clothing/under/rank/plague
	name = "shadowlace plague gown"
	desc = "An exquisite gown shrouded in the elegance of shadowlace, seamlessly blending the mystique of the night with the functionality required for a vigilant doctor, enchanting and purposeful."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plaguedress"
	inhand_icon_state = "plaguedress"
	supports_variations_flags = CLOTHING_NO_VARIATION
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor_type = /datum/armor/clothing_under/plague

/datum/armor/clothing_under/plague
	bio = 100

/datum/armor/plauge
	bio = 100

/obj/item/clothing/mask/nobreath/plague
	name = "plaguestriders visage"
	desc = "A meticulously designed and enchanted mask with advanced filtration. It's secondary duty is to protect the idenity of a vigilant healer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plaguebeak"
	inhand_icon_state = "plaguebeak"
	supports_variations_flags = CLOTHING_NO_VARIATION
	body_parts_covered = HIDEFACE
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor_type = /datum/armor/plauge

/obj/item/clothing/mask/nobreath/plague/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/head/plague
	name = "shadowlace bonnet"
	desc = "A meticulously crafted frilly bonnet adorned with intricate shadowlace, designed to bring an air of mysterious elegance to the diligent healer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plaguehat"
	inhand_icon_state = "plaguehat"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor_type = /datum/armor/plauge

/obj/item/staff/plague
	name = "plague warding parasol"
	desc = "A parasol of dark elegance, intricately designed to not only shield from the sun but also to ward off the invisible threats of disease, combines fashion with practical defense."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "umbrellafrilly"
	inhand_icon_state = "umbrellafrilly"
	attack_verb_continuous = list("disciplines")
	attack_verb_simple = list("discipline")
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/item/staff/plague/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(.)
		return

	target_mob.Knockdown(1 SECONDS)

/obj/item/staff/plague/attack_secondary(mob/living/victim, mob/living/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	healthscan(user, victim, advanced = TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/philemon_extract
	name = "philemon blessed cure-all"
	desc = "A potent healing extract infused with the divine essence of Philemon, known for its miraculous ability to mend ailments and restore vitality with a touch of divine grace."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "voidextract"
	inhand_icon_state = "voidextract"
	force = 0

/obj/item/philemon_extract/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target))
		return

	var/mob/living/healing = target
	if(healing == user)
		user.visible_message(
			span_notice("[user] slathers [src] over [user.p_them()]self, the butterfly detaches and flies away after [user.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts in your hand, the butterfly detaches and flies away after it regenerates your injuries!"),
		)
	else
		user.visible_message(
			span_notice("As [user] slathers [src] over [healing], the butterfly detaches and flies away after healing [healing.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts over [healing], the butterfly detaches and flies away after healing [healing.p_their()] injuries."),
		)

	healing.revive(HEAL_ALL)
	playsound(healing, 'sound/effects/splat.ogg', 40, TRUE)

/obj/item/scalpel/advanced/plague
	name = "flesh render"
	desc = "A deceptively cruel looking cutting tool. The imposing power from the tool guides a dedicated doctors hand to cut with absolute precision."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_scalpel"
	inhand_icon_state = "plague_scalpel"
	light_color = "#582640"

/obj/item/retractor/advanced/plague
	name = "flesh manipulator"
	desc = "A tool blessed by Philemon that acts as both a retractor and a hemostat. A powerful tool for the most dedicated of healers."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_retractor"
	inhand_icon_state = "plague_retractor"

/obj/item/bonesetter/plague
	name = "limb mendistry tool"
	desc = "A precision instrument with adjustable components and intricate tendrils, ensuring the meticulous restoration of limbs under the skilled hands of a dedicated healer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_bonesetter"
	inhand_icon_state = "plague_bonesetter"

/obj/item/stack/medical/bone_gel/plague
	name = "bonebond elixir"
	desc = "A potent mixture of unidentifiable ingredients used by the most attentive doctors. The tendrils within are almost desprate to mend the bones of the injured, still just as painful as regular bone gel."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_bone-gel"
	inhand_icon_state = "plague_bone-gel"

/obj/item/surgical_drapes/plague
	name = "plagueweaver coverings"
	desc = "A set of surgical coverings swarming with Philemons blessed butterflies. The butterflies will guide you true, as the most dedicated doctor."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_surgical_drapes"
	inhand_icon_state = "plague_surgical_drapes"

/obj/item/storage/backpack/satchel/leather/plague
	name = "remedial satchel"
	desc = "A finely-crafted leather bag adorned with subtle shadowlace accents, designed to complement the attire of the vigilant doctor. It embodies both practicality and style for the most dedicated healer."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	worn_icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_worn.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plaguebag"
	inhand_icon_state = "plaguebag"

/obj/item/cautery/advanced/plague
	name = "shadowflame cautery"
	desc = "A potent surical tool imbuled with a flame blessed by Philemon. The flame is cool to the touch, only worth while to use on open wounds by the most attentive doctor."
	icon = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_item.dmi'
	lefthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_lhand.dmi'
	righthand_file = 'maplestation_modules/code/modules/clothing/equipment_sets/noble_equipment/icons/noble_rhand.dmi'
	icon_state = "plague_cautery"
	inhand_icon_state = "plague_cautery"
	light_color = "#582640"

//As proof of my sprite obsession we will now encroach closer to 500 lines of code :shrivel:

/obj/item/clothing/under/rank/chiffon/alt
	name = "starry dress"
	desc = "A dress made from an unidentifiable material, it shimmers in the light with movement to reflect the very stars around you."
	icon_state = "stardress"
	inhand_icon_state = "stardress"
	supports_variations_flags = CLOTHING_NO_VARIATION
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/gloves/chiffon/alt
	name = "starry gloves"
	desc = "Delicate black gloves that shimmer in the light with movement."
	icon_state = "stargloves"
	inhand_icon_state = "stargloves"

/obj/item/clothing/shoes/chiffon/alt
	name = "purple velvet flats"
	desc = "Delicate velvet flats in a dark purple color. The flats offered a lot of support for the arch of the foot."
	icon_state = "starflats"
	inhand_icon_state = "starflats"

/obj/item/clothing/head/costume/chiffonbow/alt
	name = "starry bow"
	desc = "A dainty bow made from similar materials from it matching dress. The fabric seems almost unatural from the way it reflects the stars as it moves."
	icon_state = "starbow"
	inhand_icon_state = "starbow"
