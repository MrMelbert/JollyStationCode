// --- baby mode dress ---
/obj/item/clothing/under/dress/nndress
	name = "blue dress"
	desc = "A small blue dress. Incredibly silky and poofy."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nndress"

/datum/loadout_item/under/formal/nndress
	name = "Blue Dress"
	item_path = /obj/item/clothing/under/dress/nndress
	additional_displayed_text = list("Character Item")

/// Component to make a suit item allow the wearer to safely ventcrawl, with some drawbacks
/datum/component/ventcrawler_clothing
	/// Tracks if it is currently equipped and applied
	VAR_FINAL/applied = FALSE

/datum/component/ventcrawler_clothing/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/clothing/thing = parent
	thing.attach_clothing_traits(TRAIT_VENTCRAWLER_ALWAYS)

	RegisterSignal(thing, COMSIG_ITEM_EQUIPPED, PROC_REF(outfit_equipped))
	RegisterSignal(thing, COMSIG_ITEM_DROPPED, PROC_REF(outfit_dropped))

/datum/component/ventcrawler_clothing/Destroy()
	var/obj/item/clothing/thing = parent
	thing.detach_clothing_traits(TRAIT_VENTCRAWLER_ALWAYS)

	UnregisterSignal(thing, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(thing, COMSIG_ITEM_DROPPED)
	return ..()

/datum/component/ventcrawler_clothing/proc/outfit_equipped(obj/item/clothing/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!ishuman(user) || !(slot & source.slot_flags))
		return

	ASSERT(!applied)

	applied = TRUE
	RegisterSignal(user, COMSIG_HUMAN_BURNING, PROC_REF(on_burn))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(vulnerable_to_stab))
	var/mob/living/carbon/human/wearer = user
	wearer.physiology.burn_mod /= 0.5

/datum/component/ventcrawler_clothing/proc/outfit_dropped(obj/item/clothing/source, mob/user)
	SIGNAL_HANDLER

	if(!applied || !ishuman(user))
		return

	applied = FALSE

	if(!QDELING(user))
		var/mob/living/carbon/human/wearer = user
		wearer.physiology.burn_mod *= 0.5

	UnregisterSignal(user, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_HUMAN_BURNING,
		COMSIG_MOB_APPLY_DAMAGE_MODIFIERS,
	))
	var/obj/item/clothing/thing = parent
	thing.detach_clothing_traits(list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE
	))

/datum/component/ventcrawler_clothing/proc/on_move(mob/living/carbon/human/source, ...)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_MOVE_VENTCRAWLING))
		var/obj/item/clothing/thing = parent
		thing.attach_clothing_traits(list(
			TRAIT_NOBREATH,
			TRAIT_RESISTCOLD,
			TRAIT_RESISTHIGHPRESSURE,
			TRAIT_RESISTLOWPRESSURE,
		))
	else
		var/obj/item/clothing/thing = parent
		thing.detach_clothing_traits(list(
			TRAIT_NOBREATH,
			TRAIT_RESISTCOLD,
			TRAIT_RESISTHIGHPRESSURE,
			TRAIT_RESISTLOWPRESSURE,
		))

/datum/component/ventcrawler_clothing/proc/on_burn(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	source.apply_damage(5, STAMINA, forced = TRUE)

/datum/component/ventcrawler_clothing/proc/vulnerable_to_stab(datum/source, list/damage_mods, damage, damagetype, def_zone, sharpness, ...)
	SIGNAL_HANDLER

	if(sharpness)
		damage_mods += 2

// --- second outfit ---
/obj/item/clothing/under/dress/nnseconddress
	name = "fancy blue dress"
	desc = "A decorated blue dress. Appears silky, but feels rough upon touching it.."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "nnseconddress"
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/under/dress/nnseconddress/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ventcrawler_clothing)

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

// --- alter ego outfit ---

/obj/item/clothing/head/costume/crown/atrox
	name = "rosed crown"
	desc = "A small golden grown adorned with painted red roses. One of them looks unfinished."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "amcrown"

/obj/item/clothing/under/jumpsuit/atrox
	name = "regal red and black suit"
	desc = "A regal suit that reminds you of a foul-tempered monarch. Sentence first, verdict last."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "amsuit"
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/under/jumpsuit/atrox/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ventcrawler_clothing)

/obj/item/clothing/shoes/atrox
	name = "regal white boots"
	desc = "White boots with a heart motif. Not a single piece of dirt attaches itself to it."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "amboots"

// --- bnuuy ---

/obj/item/clothing/head/costume/hat/blanche
	name = "fluffy sun hat"
	desc = "A white sunhat with fluffy rabbit ears. Stylish!"
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "blhat"

/obj/item/clothing/glasses/blanche
	name = "feathery monocle"
	desc = "A monocle decorated with white feathers and black lace. With a red gem in front, they can't see your eye, but you can certainly see them."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "blmask"

/obj/item/clothing/under/jumpsuit/blanche
	name = "white fluffy dress"
	desc = "A large white dress decorated with various playing card suits. On the side is a large golden stopwatch, just to check if you're late."
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "bldress"
	resistance_flags = INDESTRUCTIBLE
	alternate_worn_layer = ABOVE_SHOES_LAYER

/obj/item/clothing/shoes/blanche
	name = "delicate white heels"
	desc = "Small white heels with red claws in the front, along with large cuffs. Hop away!"
	icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_item.dmi'
	worn_icon = 'maplestation_modules/story_content/noname_equipment/icons/nndress_worn.dmi'
	icon_state = "blshoes"
