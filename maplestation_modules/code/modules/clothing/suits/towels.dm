/// -- Towels. --
// Inhand and icon sprites ported from baystation.

/// do_after key, related to towels
#define DOAFTER_SOURCE_TOWEL "doafter_towel"

// A Towel. Can be used to dry wet floors or people.
/obj/item/towel
	name = "towel"
	desc = "A nice, soft towel you can use to dry things off."
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_OCLOTHING
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	max_integrity = 120
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	layer = MOB_LAYER

	icon = 'maplestation_modules/icons/mob/clothing/under/towel.dmi'
	icon_state = "towel"
	worn_icon = 'maplestation_modules/icons/mob/clothing/under/towel.dmi'
	worn_icon_state = "towel_worn"
	lefthand_file = 'maplestation_modules/icons/mob/inhands/towel_inhand_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/towel_inhand_righthand.dmi'
	inhand_icon_state = "towel_hand"

	greyscale_config = /datum/greyscale_config/towel
	greyscale_config_worn = /datum/greyscale_config/towel_worn
	greyscale_config_inhand_left = /datum/greyscale_config/towel_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/towel_inhand_right
	greyscale_colors = "#dddddd"
	flags_1 = IS_PLAYER_COLORABLE_1

	/// Whether our tower is warm and comfy.
	var/warm_towel = FALSE
	/// The timer ID on our towel cooling.
	var/cooling_timer_id

/obj/item/towel/examine(mob/user)
	. = ..()
	if(warm_towel && user.is_holding(src))
		. += span_red("It's noticeably warm. Nice.")
	. += span_notice("Attack a wet or lubed floor to dry it off.")
	. += span_notice("Attack a burning or soaked mob to either dampen the flames or dry them off.")

/obj/item/towel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pat_out_fire)

/obj/item/towel/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(isopenturf(target))
		try_dry_floor(target, user)
		return TRUE

/obj/item/towel/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!isliving(user) || !warm_towel)
		return
	if(slot_flags & slot)
		if(islizard(user))
			user.add_mood_event("warm_towel", /datum/mood_event/warm_towel_lizard)
		else
			user.add_mood_event("warm_towel", /datum/mood_event/warm_towel)

/**
 * Check if our [target_turf] is valid to try to dry and begin a do_after.
 * If the turf is valid, try a do_after, and if successful, call [do_dry_floor].
 *
 * target_turf - the turf we're trying to dry
 * user - the mob drying the turf
 *
 * returns FALSE if the floor is invalid to dry, and TRUE otherwise.
 */
/obj/item/towel/proc/try_dry_floor(turf/open/target_turf, mob/living/user)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_TOWEL))
		return FALSE

	if(resistance_flags & ON_FIRE)
		return FALSE

	var/turf_wetness = SEND_SIGNAL(target_turf, COMSIG_TURF_IS_WET)
	if(!turf_wetness)
		return FALSE

	if(turf_wetness & (TURF_WET_SUPERLUBE | TURF_WET_PERMAFROST | TURF_WET_ICE))
		to_chat(user, span_warning("You'll need something stronger than [src] to dry this mess."))
		return FALSE

	to_chat(user, span_notice("You begin drying off [target_turf] with [src]..."))
	visible_message(span_notice("[user] begins drying off [target_turf] with [src]..."), ignored_mobs = list(user))
	if(!do_after(user, 2 SECONDS, target = target_turf, interaction_key = DOAFTER_SOURCE_TOWEL))
		to_chat(user, span_warning("You fail to sop up the mess on [target_turf]."))
		return FALSE

	do_dry_floor(target_turf, user)
	return TRUE

/**
 * Actually dry the floor, removing a minute of wetness from [target_turf] and washing it lightly.
 *
 * target_turf - the turf we're drying
 * user - the mob drying the turf
 *
 */
/obj/item/towel/proc/do_dry_floor(turf/open/target_turf, mob/living/user)
	to_chat(user, span_notice("You dry off [target_turf] with [src]."))
	visible_message(span_notice("[user] dries off [target_turf] with [src]."), ignored_mobs = list(user))
	target_turf.MakeDry(ALL, TRUE, 1 MINUTES)
	target_turf.wash(CLEAN_WASH)

/**
 * Begin drying off a [target_mob] with [src].
 * If [target_mob] is on fire, call [try_extinguish_mob].
 * Otherwise, begin a do_after, and call [do_dry_mob] afterwards.
 *
 * target_mob - the mob we're trying to dry
 * user - the mob drying the target_mob
 *
 * returns FALSE if the mob is invalid to dry, and TRUE otherwise.
 */
/obj/item/towel/proc/try_dry_mob(mob/living/target_mob, mob/living/user)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_TOWEL))
		return FALSE

	if(resistance_flags & ON_FIRE)
		return FALSE

	to_chat(user, span_notice("You begin drying off [target_mob == user ? "yourself" : "[target_mob]"] with [src]..."))
	visible_message(span_notice("[user] begins drying off [target_mob == user ? "[user.p_them()]self" : "[target_mob]"] with [src]..."), ignored_mobs = list(user))
	if(!do_after(user, 2 SECONDS, target = target_mob, interaction_key = DOAFTER_SOURCE_TOWEL))
		return FALSE

	do_dry_mob(target_mob, user)
	return TRUE

/**
 * Actually dry the mob, giving them a moodlet if the towel is warm and washing them.
 * Also removes negative firestacks (wetness).
 *
 * target_mob - the mob we're drying
 * user - the mob drying the target_mob
 */
/obj/item/towel/proc/do_dry_mob(mob/living/target_mob, mob/living/user)
	to_chat(user, span_notice("You dry off [target_mob == user ? "yourself" : "[target_mob]"] with [src]."))
	visible_message(span_notice("[user] dries off [target_mob == user ? "[user.p_them()]self" : "[target_mob]"] with [src]."), ignored_mobs = list(user))
	target_mob.wash(CLEAN_WASH)
	target_mob.set_fire_stacks(max(0, target_mob.fire_stacks))
	if(warm_towel)
		if(islizard(target_mob))
			target_mob.add_mood_event("warm_towel", /datum/mood_event/warm_towel_lizard)
		else
			target_mob.add_mood_event("warm_towel", /datum/mood_event/warm_towel)
		if(prob(66)) //66% chance to cool the towel after
			cool_towel()

/// Cool down the towel.
/obj/item/towel/proc/cool_towel()
	warm_towel = FALSE
	cooling_timer_id = null

// BEACH Towel. On right click, can be placed on the ground.
/obj/item/towel/beach
	name = "beach towel"
	desc = "A colorful beach towel you can use to dry yourself off or soak up some rays."

/obj/item/towel/beach/Initialize(mapload)
	. = ..()
	set_greyscale("#" + random_color())

/obj/item/towel/beach/examine(mob/user)
	. = ..()
	. += span_notice("Right click on the floor with [src] to lay it flat on the ground.")

/obj/item/towel/beach/pre_attack_secondary(atom/target, mob/living/user, params)
	. = ..()
	if(. != SECONDARY_ATTACK_CALL_NORMAL)
		return

	if(isopenturf(target))
		try_place_towel(target, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Check if our [target_turf] is valid to place our towel on.
 * If the turf is valid, begin a do_after, and if the turf is valid still after the do_after call [do_place_towel].
 *
 * target_turf - the turf we're trying to place our towel on
 * user - the mob placing the towel
 *
 * returns FALSE if the towel cannot be placed, and TRUE otherwise
 */
/obj/item/towel/beach/proc/try_place_towel(turf/open/floor/target_turf, mob/living/user)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_TOWEL))
		return FALSE

	if(resistance_flags & ON_FIRE)
		return FALSE

	if(!check_towel_location(target_turf, user))
		return FALSE

	to_chat(user, span_notice("You begin placing [src] onto [target_turf]..."))
	visible_message(span_notice("[user] begins placing [src] onto [target_turf]..."), ignored_mobs = list(user))
	if(!do_after(user, 3 SECONDS, target = target_turf, interaction_key = DOAFTER_SOURCE_TOWEL))
		return FALSE

	if(!check_towel_location(target_turf, user))
		return FALSE

	do_place_towel(target_turf, user)
	return TRUE

/**
 * Check if our [target_turf] contains invalid atmos.
 *
 * target_turf - the turf we're checking
 * user - the mob who initiated the check
 *
 * returns FALSE if our turf contains invalid atoms, TRUE otherwise.
 */
/obj/item/towel/beach/proc/check_towel_location(turf/open/floor/target_turf, mob/living/user)
	for(var/atom/blocker in target_turf)
		if(isliving(blocker))
			if(blocker == user)
				to_chat(user, span_warning("You can't lay [src] out on [target_turf] while you're standing there."))
			else
				to_chat(user, span_warning("You can't place [src] on [target_turf] while [blocker] is in the way."))
			return FALSE

		if(istype(blocker, /obj/structure/beach_towel))
			to_chat(user, span_warning("You can't place [src] onto [blocker], that's disrepectful."))
			return FALSE

		if(blocker.density)
			to_chat(user, span_warning("You can't place [src] on [target_turf], something is in the way."))
			return FALSE

	return TRUE

/**
 * Actually place our towel on [target_turf].
 *
 * target_turf - the turf we're putting the towel
 * user - the mob who placed the towel
 */
/obj/item/towel/beach/proc/do_place_towel(turf/open/floor/target_turf, mob/living/user)
	to_chat(user, span_notice("You spread out [src] across [target_turf]."))
	visible_message(span_notice("[user] places [src] onto [target_turf]."), ignored_mobs = list(user))
	new /obj/structure/beach_towel(target_turf, src)

/// Structure that represents the Beach towel item placed down.
/obj/structure/beach_towel
	name = "beach towel"
	desc = "A beach towel spread out over the floor, for maximum comfort and mimimum sand contact while soaking up the rays."
	density = FALSE
	anchored = TRUE

	icon = 'maplestation_modules/icons/mob/clothing/under/towel.dmi'
	icon_state = "towel_placed"

	greyscale_config = /datum/greyscale_config/towel_placed
	greyscale_colors = "#dddddd"

	/// The beach towel we came from
	var/obj/item/towel/beach/our_towel

/obj/structure/beach_towel/Initialize(mapload, obj/item/towel/beach/new_towel)
	. = ..()
	if(!our_towel)
		if(mapload || !new_towel)
			our_towel = new(src)
		else
			our_towel = new_towel
			new_towel.forceMove(src)
	name = our_towel.name
	set_greyscale(our_towel.greyscale_colors)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/beach_towel/Destroy()
	if(our_towel)
		our_towel.forceMove(drop_location())
		our_towel = null
	return ..()

/// Signal from whenever an atom enters a turf with a towel on top.
/obj/structure/beach_towel/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/living_arrived = arrived
	if(our_towel.warm_towel)
		if(islizard(arrived))
			living_arrived.add_mood_event("on_towel", /datum/mood_event/on_warm_towel_lizard)
		else
			living_arrived.add_mood_event("on_towel", /datum/mood_event/on_warm_towel)
	else
		living_arrived.add_mood_event("on_towel", /datum/mood_event/on_towel)

/// Signal from whenever an atom exits a turf with a towel on top.
/obj/structure/beach_towel/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(!isliving(gone))
		return
	var/mob/living/living_gone = gone
	living_gone.clear_mood_event("on_towel")

/obj/structure/beach_towel/examine(mob/user)
	. = ..()
	if(Adjacent(user) && our_towel.warm_towel)
		. += span_red("It's warm and fresh. Nice!")
	. += span_notice("Drag [src] to you to pick it up.")

/// On click-drag, try to pick up the towel.
/obj/structure/beach_towel/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	var/mob/living/carbon/picker_up = usr

	if(!istype(picker_up))
		return

	if(over != picker_up)
		return

	try_pick_up(picker_up)

/**
 * Attempt to pick up the towel. Run through a few checks and a do-after, then call [do_pick_up]
 *
 * picker_up - the mob who is trying to pick up the towel.
 *
 * return FALSE if we cannot pick up the towel and TRUE otherwise
 */
/obj/structure/beach_towel/proc/try_pick_up(mob/living/carbon/picker_up)
	if(!picker_up.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return FALSE

	var/turf/our_turf = get_turf(src)
	if(locate(/mob/living) in our_turf)
		to_chat(picker_up, span_warning("There's something on [src]!"))
		return FALSE

	if(DOING_INTERACTION_WITH_TARGET(picker_up, src))
		return FALSE

	to_chat(picker_up, span_notice("You begin folding up [src]..."))
	visible_message(span_notice("[picker_up] begins folding up [src]..."), ignored_mobs = list(picker_up))
	if(!do_after(picker_up, 4 SECONDS, target = src))
		return FALSE

	do_pick_up(picker_up)
	return TRUE

/**
 * Actually pick up the towel, moving the item to [picker_up], and deleting [src].
 * If any mobs walk onto the towel while being picked up, give them a slip.
 *
 * picker_up - the mob who is picking up the towel.
 */
/obj/structure/beach_towel/proc/do_pick_up(mob/living/carbon/picker_up)
	var/turf/our_turf = get_turf(src)
	var/mob/living/slipped_up_mob = locate(/mob/living) in our_turf

	if(slipped_up_mob) // If someone steps on our towel right after we start picking it up, knock 'em over
		slipped_up_mob.Knockdown(1.5 SECONDS)
		to_chat(slipped_up_mob, span_danger("[src] gets pulled up right as you step on it, knocking you over!"))
		visible_message(span_danger("[src] is pulled out from right under [slipped_up_mob], knocking them over!"), ignored_mobs = list(slipped_up_mob))

	if(picker_up.put_in_hands(our_towel))
		to_chat(picker_up, span_notice("You fold up [src] off [our_turf]."))
		visible_message(span_notice("[picker_up] fold up [src] off [our_turf]."), ignored_mobs = list(picker_up))
	else
		our_towel.forceMove(drop_location())
		to_chat(picker_up, span_notice("You go to fold up [src] from [our_turf], but your hands are full, leaving it considerably less kempt than it was before."))
		visible_message(span_notice("[picker_up] tries to fold up [src] from [our_turf], but ends up leaving it considerably less kempt than it was before."), ignored_mobs = list(picker_up))

	our_towel = null
	qdel(src)

/// Mood event for warm towels
/datum/mood_event/warm_towel
	description = "<span class='nicegreen'>Warm towels are cosy.</span>\n"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/warm_towel_lizard
	description = "<span class='nicegreen'>Warm towelsss are ssso cosssy.</span>\n"
	mood_change = 4
	timeout = 3 MINUTES

/// Mood event for laying on towels
/datum/mood_event/on_towel
	description = "<span class='nicegreen'>I could lay here all day...</span>\n"
	mood_change = 3
	timeout = 10 MINUTES

/datum/mood_event/on_warm_towel
	description = "<span class='nicegreen'>Warm towel, nice day... This is the life.</span>\n"
	mood_change = 5
	timeout = 10 MINUTES

/datum/mood_event/on_warm_towel_lizard
	description = "<span class='nicegreen'>Ssso warm... Ahhhh.</span>\n"
	mood_change = 8
	timeout = 10 MINUTES

#undef DOAFTER_SOURCE_TOWEL
