// --- baby mode dress ---
/obj/item/clothing/under/dress/nndress
	name = "blue dress"
	desc = "A small blue dress. Incredibly silky and poofy."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nndress"

// --- second outfit ---
/obj/item/clothing/under/dress/nnseconddress
	name = "fancy blue dress"
	desc = "A decorated blue dress. Appears silky, but feels rough upon touching it.."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nnseconddress"
	resistance_flags = INDESTRUCTIBLE
	clothing_traits = list(TRAIT_VENTCRAWLER_ALWAYS, TRAIT_SHARPNESS_VULNERABLE) //gives nono her funny traits
	var/heat_mod = FALSE

/obj/item/clothing/under/dress/nnseconddress/equipped(mob/user, slot) //gives nono her weaknesses
	. = ..()
	if(!ishuman(user) || !(slot & slot_flags))
		return
	heat_mod = TRUE
	RegisterSignal(user, COMSIG_HUMAN_BURNING, PROC_REF(on_burn))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	var/mob/living/carbon/human/wearer = user
	wearer.physiology.burn_mod /= 0.5

/obj/item/clothing/under/dress/nnseconddress/dropped(mob/user)
	. = ..()
	if(!heat_mod)
		return
	if(!ishuman(user) || QDELING(user))
		return
	var/mob/living/carbon/human/wearer = user
	wearer.physiology.burn_mod *= 0.5
	heat_mod = FALSE
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	UnregisterSignal(user, COMSIG_HUMAN_BURNING, PROC_REF(on_burn))
	REMOVE_TRAIT(user, TRAIT_NOBREATH, VENTCRAWLING_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, VENTCRAWLING_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, VENTCRAWLING_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, VENTCRAWLING_TRAIT)

/obj/item/clothing/under/dress/nnseconddress/proc/on_move(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_MOVE_VENTCRAWLING))
		ADD_TRAIT(source, TRAIT_NOBREATH, VENTCRAWLING_TRAIT)
		ADD_TRAIT(source, TRAIT_RESISTCOLD, VENTCRAWLING_TRAIT)
		ADD_TRAIT(source, TRAIT_RESISTHIGHPRESSURE, VENTCRAWLING_TRAIT)
		ADD_TRAIT(source, TRAIT_RESISTLOWPRESSURE, VENTCRAWLING_TRAIT)
	else
		REMOVE_TRAIT(source, TRAIT_NOBREATH, VENTCRAWLING_TRAIT)
		REMOVE_TRAIT(source, TRAIT_RESISTCOLD, VENTCRAWLING_TRAIT)
		REMOVE_TRAIT(source, TRAIT_RESISTHIGHPRESSURE, VENTCRAWLING_TRAIT)
		REMOVE_TRAIT(source, TRAIT_RESISTHIGHPRESSURE, VENTCRAWLING_TRAIT)

/obj/item/clothing/under/dress/nnseconddress/proc/on_burn(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	source.apply_damage(5, STAMINA)

/obj/item/clothing/shoes/nnredshoes
	name = "fake red shoes"
	desc = "Red Mary Janes with a shining texture. Gliding your finger over it, it feels like sandpaper.."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nnshoes"

/obj/item/clothing/head/costume/nnbluebonnet
	name = "blue bonnet"
	desc = "A decorated bonnet with various charms."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nnbonnet"
