/obj/item/organ/internal/cyberimp/arm/lighter
	name = "finger-implanted lighter"
	desc = "Allows you to light cigarettes with the snap of a finger."
	extend_sound = 'sound/items/welderactivate.ogg'
	retract_sound = 'sound/items/welderdeactivate.ogg'
	items_to_create = list(/obj/item/lighter/finger)

/obj/item/organ/internal/cyberimp/arm/lighter/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(isnull(owner))
		return
	var/obj/item/bodypart/real_hand = hand
	if(!istype(real_hand))
		return
	owner.apply_damage(10 / severity, BURN, real_hand, attacking_item = src)
	to_chat(owner, span_warning("You feel your [parse_zone(zone)] begin to burn up!"))

/obj/item/organ/internal/cyberimp/arm/lighter/on_mob_insert(mob/living/carbon/arm_owner)
	. = ..()
	RegisterSignal(arm_owner, COMSIG_MOB_EMOTED("snap"), PROC_REF(on_snap))

/obj/item/organ/internal/cyberimp/arm/lighter/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	UnregisterSignal(arm_owner, COMSIG_MOB_EMOTED("snap"))

/obj/item/organ/internal/cyberimp/arm/lighter/Extend(obj/item/augment)
	. = ..()
	var/obj/item/lighter/finger/lighter = augment
	if(!istype(augment) || augment.loc == src)
		return
	lighter.name = "[owner]'s [name]"
	lighter.set_lit(TRUE)

/obj/item/organ/internal/cyberimp/arm/lighter/Retract()
	var/obj/item/lighter/finger/lighter = active_item
	if(istype(lighter))
		lighter.set_lit(FALSE)
		lighter.name = initial(lighter.name)
	return ..()

/obj/item/organ/internal/cyberimp/arm/lighter/proc/on_snap(mob/living/source)
	SIGNAL_HANDLER
	if(source.get_active_hand() != hand)
		return
	if(organ_flags & ORGAN_FAILING)
		return
	if(isnull(active_item))
		Extend(contents[1])
		source.visible_message(
			span_infoplain(span_rose("With a snap, [source]'s finger emits a low flame.")),
			span_infoplain(span_rose("With a snap, your finger begins to emit a low flame.")),
		)

	else
		Retract()
		source.visible_message(
			span_infoplain(span_rose("With a snap, [source]'s finger extinguishes.")),
			span_infoplain(span_rose("With a snap, your finger is extinguished.")),
		)

/obj/item/organ/internal/cyberimp/arm/lighter/left
	zone = BODY_ZONE_L_ARM

// Used for finger lighter implant and spell
/obj/item/lighter/finger
	name = "finger light"
	desc = "Fire at your fingertips!"
	inhand_icon_state = "nothing"
	item_flags = EXAMINE_SKIP | ABSTRACT
	light_sound_on = null
	light_sound_off = null

/obj/item/lighter/finger/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		playsound(user, pick('sound/misc/fingersnap1.ogg', 'sound/misc/fingersnap2.ogg'), 50, TRUE)
		return span_infoplain(span_rose(
			"With a snap, [user]'s finger emits a low flame, which they use to light [A] ablaze. \
			Hot damn, [user.p_theyre()] badass."))

/obj/item/lighter/finger/attack_self(mob/living/user)
	return

/obj/item/lighter/finger/magic
	name = "finger flame"

// Used for lizard mouth breathing
/obj/item/lighter/flame
	name = "flame"
	desc = "Your ancestors would be proud."
	icon = 'maplestation_modules/icons/obj/magic_particles.dmi'
	icon_state = "fire"
	inhand_icon_state = "nothing"
	item_flags = EXAMINE_SKIP | ABSTRACT
	light_sound_on = null
	light_sound_off = null
	/// World.time we were last lit.
	VAR_FINAL/world_time_lit = -1
	/// Tracks seconds between times we've burned someone holding the flame.
	VAR_FINAL/seconds_burning = 0
	/// Weakref to the action that created us
	VAR_FINAL/datum/weakref/origin_ref

/obj/item/lighter/flame/Initialize(mapload, datum/action/cooldown/spell/touch/finger_flame/lizard/origin)
	. = ..()
	if(origin)
		origin_ref = WEAKREF(origin)
	else
		item_flags |= DROPDEL

/obj/item/lighter/flame/proc/clear_up(mob/user, do_message = FALSE)
	var/datum/action/cooldown/spell/touch/finger_flame/lizard/origin = origin_ref?.resolve()
	if(!QDELETED(origin))
		origin.remove_hand(user, do_message)
		return

	qdel(src)

/obj/item/lighter/flame/ignition_effect(atom/A, mob/user)
	if(!get_temperature())
		return

	. = span_infoplain(span_rose("[user] breathes a small mote of fire at [A], setting it ablaze. Prehistoric."))
	clear_up(user, do_message = FALSE)

/obj/item/lighter/flame/attack_self(mob/living/user)
	clear_up(user, do_message = TRUE)

/obj/item/lighter/flame/set_lit(new_lit)
	if(lit == new_lit)
		return

	. = ..()
	if(lit)
		world_time_lit = world.time

/obj/item/lighter/flame/process(seconds_per_tick)
	. = ..()
	if(world_time_lit + 30 SECONDS > world.time)
		return
	var/mob/living/holder = loc
	if(!istype(holder) || !holder.get_bodypart(BODY_ZONE_HEAD))
		qdel(src)
		return

	if(!holder.is_mouth_covered())
		seconds_burning += seconds_per_tick

		if(seconds_burning >= rand(4, 12))
			if(holder.apply_damage(2, BURN, BODY_ZONE_HEAD))
				to_chat(holder, span_warning("The flame [pick("burns", "scorches", "singes", "torches", "sears")] your mouth a little."))
			seconds_burning = 0

		if(world_time_lit + 60 SECONDS > world.time)
			return

	to_chat(holder, span_warning("The flame burns out in your mouth."))
	clear_up(holder, do_message = FALSE)
