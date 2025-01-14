/*
 * # Components for Volkan pets or others!
 * This file has a bunch of components as well as various things like HUDs and things like that.
 * Ones not named for a specific mob is made to be used in more than one mob. Maybe.
 */

///signal for the vroomba's tools to know if it is in combat mode
#define COMSIG_COMBAT_MODE "combat_mode_active"

/*
 * # Tractor field component
 * A very important and complicated piece of Vtech (Volkan and Co technology).
 * Invented by CaLE, based on gravity generators.
 * In game it will basically act like telekinesis.
 * Add it to a mob if the mob has tractor field Vtech inside.
 */

///A piece of Vtech. Like a tractor beam, but its a whole field around the object instead.
/datum/component/tractorfield
	///the maximum range the tractorfield has influence over
	var/max_range = 6
	///the damage the tractor field does when doing a force attack. Shouldn't be not much damage.
	var/damage = 5
	///The pushing force does the tractor field has.
	var/force = 4

	///Stuff tractor field cannot interact with
	var/static/list/blacklisted_atoms = typecacheof(list(/atom/movable/screen))

/datum/component/tractorfield/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))


/datum/component/tractorfield/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_ATTACK_RANGED,COMSIG_LIVING_UNARMED_ATTACK))


///Checks if clicked on item is in tractor field's influence.
/datum/component/tractorfield/proc/tractorRangeCheck(mob/user, atom/target)
	var/d = get_dist(user, target)
	if(d > max_range)
		user.balloon_alert(user, "can't lift, too far!")
		return
	return TRUE

///Same as /datum/component/tractorfield/proc/tractorRangeCheck() but for the telekinetic grab object instead.
/obj/item/tk_grab/tractor/proc/tractorRangeCheck(mob/user, atom/target) //Melbert if you know how to combine this with above one plz tell me. It works though.
	var/d = get_dist(user, target)
	if(d > max_range)
		user.balloon_alert(user, "can't move, too far!")
		return
	return TRUE

///Manages all the stuff a tractor field can do from a distance.
/datum/component/tractorfield/proc/on_ranged_attack(mob/source, atom/target, src)
	SIGNAL_HANDLER
	if(is_type_in_typecache(target, blacklisted_atoms))
		return
	if(!tractorRangeCheck(source, target) || source.z != target.z)
		return
	if(ismob(target)) //atacking mobs
		return target.attack_tractor(source, target, damage, force)
	if(isitem(target))
		return tractor_grab(source, target)
	return on_unarmed_attack(source, target, TRUE)

//Grabs the item with the tractor field at a distance
/datum/component/tractorfield/proc/tractor_grab(mob/user, target)
	var/obj/item/tk_grab/tractor/O = new(target)
	O.tk_user = user
	O.max_range = max_range + force //it can throw things just a little bit further than it can pick up
	if(!O.focus_object(target))
		return
	INVOKE_ASYNC(O, TYPE_PROC_REF(/atom, attack_hand), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Tractor Field's "Telekinetic" grab object
/obj/item/tk_grab/tractor
	name = "Tractor Field Grab"
	desc = "Lifting things with complex gravity technology"

	///The speed the tractor field moves things at.
	var/speed = 6
	///The maximum range a tractor field can move an object
	var/max_range = 7

/obj/item/tk_grab/tractor/focus_object(obj/target)
	if(!check_if_focusable(target))
		return
	focus = target
	ADD_TRAIT(focus, TRAIT_TELEKINESIS_CONTROLLED, REF(tk_user))
	update_appearance()
	apply_focus_overlay()
	return TRUE

/obj/item/tk_grab/tractor/check_if_focusable(obj/target)
	if(!tk_user || QDELETED(target) || !istype(target))
		qdel(src)
		return
	if(!tractorRangeCheck(tk_user, target) || target.anchored || !isturf(target.loc))
		qdel(src)
		return
	return TRUE

/obj/item/tk_grab/tractor/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	move_object(user, target)

///Moving an object around
/obj/item/tk_grab/tractor/proc/move_object(mob/user, atom/target)
	if(!focus)
		return
	if(!tractorRangeCheck(user, target))
		return
	apply_focus_overlay()
	focus.throw_at(get_turf(target), 10, speed, thrower = user)
	var/turf/start_turf = get_turf(focus)
	var/turf/end_turf = get_turf(target)
	user.log_message("has thrown [focus] from [AREACOORD(start_turf)] towards [AREACOORD(end_turf)] using a tractor field!", LOG_ATTACK)
	update_appearance()

/// Interact with items at range. replaces on_unarmed_attack.
/datum/component/tractorfield/proc/on_unarmed_attack(mob/living/hand_haver, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!proximity && target.loc != hand_haver)
		var/obj/item/obj_item = target
		if (istype(obj_item) && !obj_item.atom_storage && !(obj_item.item_flags & IN_STORAGE))
			return NONE
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand_secondary), hand_haver, modifiers)
	else
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand), hand_haver, modifiers)
	INVOKE_ASYNC(hand_haver, TYPE_PROC_REF(/mob, update_held_items))
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Ranged attacking with the tractor field.
/atom/proc/attack_tractor(mob/user, mob/target, damage, force)
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	user.changeNext_move(CLICK_CD_MELEE)
	//push them to where you are facing!!
	target.throw_at(get_edge_target_turf(target, user.dir), force, damage, thrower = user)
	balloon_alert(target, "gravity shifts!") // It essentially rotates gravity to the side for its target.
	visible_message(span_danger("[user] pushes [target] back with an unknown force!"))
	user.log_message("has attacked [target] using a tractor field!", LOG_ATTACK) //for the admins

	return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * # Broken tractor field
 * This one is just fucked IC. Should feel chaotic to use.
 */
/datum/component/tractorfield/broken
	max_range = 4
	//less damage, throws things less far
	damage = 2
	force = 2

///throw yourself around if you try to touch something far away
/datum/component/tractorfield/broken/tractorRangeCheck(mob/user, atom/target)
	var/d = get_dist(user, target)
	if(d > max_range)
		user.balloon_alert(user, "you feel something in your chest pull against you!")
		new /obj/effect/temp_visual/telekinesis(get_turf(src))
		user.throw_at(get_edge_target_turf(user, rand(0,8)), force, damage, thrower = user)
		return
	return TRUE

/datum/component/tractorfield/broken/on_ranged_attack(mob/source, atom/target, src)
	if(is_type_in_typecache(target, blacklisted_atoms))
		return
	if(!tractorRangeCheck(source, target) || source.z != target.z)
		return
	if(ismob(target)) //atacking mobs
		return target.attack_tractor_broken(source, target, damage, force)
	if(isitem(target))
		return target.throw_tractor_broken(source, target, damage, force) //ittl just throw it
	return on_unarmed_attack(source, target, TRUE)

///A tractor field attack fro the broken tractor field
/atom/proc/attack_tractor_broken(mob/user, mob/target, damage, force)
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	user.changeNext_move(CLICK_CD_MELEE)

	//throw people against eachother!
	user.throw_at(get_turf(target), force, damage, thrower = user)
	target.throw_at(get_turf(user), force, damage, thrower = user)

	user.balloon_alert(target, "gravity shifts!")
	user.balloon_alert(user, "you feel something in your chest pull you forward!")
	balloon_alert(target, "gravity shifts uncomfortably!") // It essentially rotates gravity to the side for its target.
	visible_message(span_danger("[user] pushes [target] with an unknown force!"))
	user.log_message("has attacked [target] using a broken tractor field!", LOG_ATTACK) //for the admins
	return COMPONENT_CANCEL_ATTACK_CHAIN

///A broken grab. Instead, it just throws the object around.
/atom/proc/throw_tractor_broken(mob/user, obj/item/target, damage, force, random = FALSE)
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	user.changeNext_move(CLICK_CD_MELEE)
	target.throw_at(get_edge_target_turf(user, rand(0,8)), force + rand(force), damage, thrower = user)// randomly throws it, stronger than it would with a person.
	visible_message(span_danger("[user] throws the [target] with an unknown force chaotically!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * # Vroomba only stuff
 * Components just for the vroomba.
 */
///The vroomba's hud!
/datum/hud/vroomba/New(mob/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	build_hand_slots()

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	zone_select = new /atom/movable/screen/zone_sel(null, src)
	zone_select.icon = ui_style
	zone_select.update_appearance()
	static_inventory += zone_select

	using = new /atom/movable/screen/area_creator(null, src)
	using.icon = ui_style
	static_inventory += using

	mymob.canon_client?.clear_screen()

///The vroombas cleaner for when it is not in combat.
/datum/component/cleaner/vroomba/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_COMBAT_MODE, PROC_REF(remove_self))

/datum/component/cleaner/vroomba/proc/remove_self()
	SIGNAL_HANDLER

	qdel(src)

///this tractor field removes itself when combat mode is deactivated.
/datum/component/tractorfield/vroomba
	max_range = 3
	force = 2

/datum/component/tractorfield/vroomba/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_COMBAT_MODE, PROC_REF(remove_self))

/datum/component/tractorfield/vroomba/proc/remove_self()
	SIGNAL_HANDLER

	qdel(src)
