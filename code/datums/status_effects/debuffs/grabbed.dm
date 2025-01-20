#define LINK_SOURCE(id) "[id]_linked"
#define GRAB_SOURCE(id) "[id]_grabbing"
#define CRIT_SOURCE(id) "[id]_crit"
#define PIN_SOURCE(id) "[id]_pin"

/// Abstract item to represent grabbing someone
/obj/item/grabbing_hand
	name = "grab"
	icon = 'maplestation_modules/icons/obj/hand.dmi'
	icon_state = "grab"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON | EXAMINE_SKIP // not currently a hand item, but we could implement it for stuff like handing grabs off to people
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/grabbing_hand/on_thrown(mob/living/carbon/user, atom/target)
	return user.pulling

/obj/item/grabbing_hand/attack_self(mob/user, modifiers)
	return user.start_pulling(user.pulling)

/// Status effect applied to someone grabbing something
/datum/status_effect/grabbing
	id = "grabbing"
	tick_interval = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	/// Linked grab status effect
	var/datum/status_effect/grabbed/paired_effect
	/// Abstract grabbing item to be put in the owner's hands
	var/obj/item/grabbing_hand/hand

/datum/status_effect/grabbing/on_creation(mob/living/new_owner, datum/status_effect/grabbed/grabbed_effect)
	paired_effect = grabbed_effect
	return ..()

/datum/status_effect/grabbing/on_apply()
	if(!owner.has_limbs)
		return TRUE
	hand = new()
	if(!owner.put_in_hands(hand))
		return FALSE

	RegisterSignal(hand, COMSIG_QDELETING, PROC_REF(hand_gone))
	RegisterSignals(hand, list(
		COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
	), PROC_REF(hand_use))
	RegisterSignals(hand, list(
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_ITEM_AFTERATTACK_SECONDARY,
	), PROC_REF(hand_use_deprecated))
	return TRUE

/datum/status_effect/grabbing/Destroy()
	paired_effect = null
	UnregisterSignal(hand, list(
		COMSIG_QDELETING,
		COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_ITEM_AFTERATTACK_SECONDARY,
	))
	if(!QDELING(hand))
		qdel(hand)
	hand = null
	return ..()

/datum/status_effect/grabbing/proc/hand_gone(...)
	SIGNAL_HANDLER
	if(!QDELING(owner))
		owner.stop_pulling()
	if(!QDELING(src))
		stack_trace("[type] should be qdelled when the hand is deleted via stop_pulling.")
		qdel(src)

// Allows the grab hand to function like a normal hand for tabling and punching and the like
/datum/status_effect/grabbing/proc/hand_use(datum/source, mob/living/user, atom/interacting_with, modifiers)
	SIGNAL_HANDLER
	// Mirrored from Click, not ideal (why doesn't punching apply the cd itself??). refactor later I guess
	if(ismob(interacting_with))
		user.changeNext_move(CLICK_CD_MELEE)
	user.UnarmedAttack(interacting_with, TRUE, modifiers)
	return ITEM_INTERACT_SUCCESS

// Similar to above but we can kill this when we get ranged item interaction because afterattack is cringe
/datum/status_effect/grabbing/proc/hand_use_deprecated(datum/source, atom/interacting_with, mob/living/user, prox, modifiers)
	SIGNAL_HANDLER
	if(prox)
		return NONE
	user.RangedAttack(interacting_with, modifiers)
	return ITEM_INTERACT_SUCCESS

/datum/status_effect/grabbing/get_examine_text()
	if(paired_effect.pin)
		switch(owner.grab_state)
			if(GRAB_AGGRESSIVE)
				return span_notice("[owner.p_Theyre()] pinning [paired_effect.owner]!")
			if(GRAB_NECK)
				return span_warning("[owner.p_Theyre()] pinning [paired_effect.owner] by the neck!")
			if(GRAB_KILL)
				return span_boldwarning("[owner.p_Theyre()] pinning [paired_effect.owner] by the neck, strangling [paired_effect.owner.p_them()]!")

	switch(owner.grab_state)
		if(GRAB_PASSIVE)
			if((owner.zone_selected == BODY_ZONE_L_ARM || owner.zone_selected == BODY_ZONE_R_ARM) && paired_effect.owner.usable_hands > 0)
				return span_notice("[owner.p_Theyre()] holding hands with [paired_effect.owner]!")

			return span_notice("[owner.p_Theyre()] holding [paired_effect.owner] passively.")
		if(GRAB_AGGRESSIVE)
			return span_warning("[owner.p_Theyre()] holding [paired_effect.owner] aggressively!")
		if(GRAB_NECK)
			return span_warning("[owner.p_Theyre()] holding [paired_effect.owner] by the neck!")
		if(GRAB_KILL)
			return span_boldwarning("[owner.p_Theyre()] strangling [paired_effect.owner]!")

/// Status effect applied to someone being grabbed
/datum/status_effect/grabbed
	id = "grabbed"
	tick_interval = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE

	var/datum/status_effect/grabbing/paired_effect
	/// Who is grabbing us
	var/atom/movable/grabbing_us
	/// Whether the grab has been side-graded into a pin
	var/pin = FALSE
	/// Whether the grabbe is linked to the grabber
	var/linked = FALSE

/datum/status_effect/grabbed/on_creation(mob/living/new_owner, mob/living/grabber)
	grabbing_us = grabber
	return ..()

/datum/status_effect/grabbed/on_apply()
	if(isnull(grabbing_us))
		stack_trace("Grabbed status effect applied without a grabber!")
		return FALSE

	RegisterSignal(grabbing_us, COMSIG_MOVABLE_SET_GRAB_STATE, PROC_REF(update_state))
	RegisterSignal(grabbing_us, COMSIG_QDELETING, PROC_REF(grabber_gone))
	RegisterSignal(grabbing_us, COMSIG_MOB_EMOTED("flip"), PROC_REF(grabber_flip))

	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(owner_stat))
	RegisterSignal(owner, COMSIG_LIVING_TRYING_TO_PULL, PROC_REF(try_upgrade))
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(try_pin))
	RegisterSignal(owner, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(ungrabbed))
	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(breath_fail))

	if(owner.stat >= SOFT_CRIT)
		ADD_TRAIT(owner, TRAIT_IMMOBILIZED, CRIT_SOURCE(id))
	if(isliving(grabbing_us))
		var/mob/living/mob_grabber = grabbing_us
		paired_effect = mob_grabber.apply_status_effect(/datum/status_effect/grabbing, src)
		if(QDELETED(paired_effect))
			return FALSE

	return TRUE

/datum/status_effect/grabbed/on_remove()
	QDEL_NULL(paired_effect)
	if(grabbing_us)
		UnregisterSignal(grabbing_us, list(
			COMSIG_MOB_EMOTED("flip"),
			COMSIG_MOVABLE_PRE_MOVE,
			COMSIG_MOVABLE_SET_GRAB_STATE,
			COMSIG_QDELETING,
		))
		// grabbing_us.setGrabState(GRAB_PASSIVE)
		grabbing_us = null

	UnregisterSignal(owner, list(
		COMSIG_MOB_STATCHANGE,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_LIVING_TRYING_TO_PULL,
		COMSIG_ATOM_NO_LONGER_PULLED,
		COMSIG_CARBON_ATTEMPT_BREATHE,
	))
	unlink_mobs()
	unpin()
	// grab stuff
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, GRAB_SOURCE(id))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, GRAB_SOURCE(id))
	// softcrit stuff
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, CRIT_SOURCE(id))

/datum/status_effect/grabbed/get_examine_text()
	if(pin)
		switch(grabbing_us.grab_state)
			if(GRAB_AGGRESSIVE)
				return span_notice("[owner.p_Theyre()] being pinned by [grabbing_us]!")
			if(GRAB_NECK)
				return span_warning("[owner.p_Theyre()] being pinned by the neck by [grabbing_us]!")
			if(GRAB_KILL)
				return span_boldwarning("[owner.p_Theyre()] being pinned and being strangled by [grabbing_us]!")

	switch(grabbing_us.grab_state)
		if(GRAB_PASSIVE)
			if(isliving(grabbing_us))
				var/mob/living/mob_grabber = grabbing_us
				if((mob_grabber.zone_selected == BODY_ZONE_L_ARM || mob_grabber.zone_selected == BODY_ZONE_R_ARM) && owner.usable_hands > 0)
					return span_notice("[owner.p_Theyre()] holding hands with [grabbing_us]!")

			return span_notice("[owner.p_Theyre()] being held passively by [grabbing_us].")
		if(GRAB_AGGRESSIVE)
			return span_warning("[owner.p_Theyre()] being held aggressively by [grabbing_us]!")
		if(GRAB_NECK)
			return span_warning("[owner.p_Theyre()] being held by the neck by [grabbing_us]!")
		if(GRAB_KILL)
			return span_boldwarning("[owner.p_Theyre()] being strangled by [grabbing_us]!")

/datum/status_effect/grabbed/proc/owner_stat(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	if(new_stat >= SOFT_CRIT)
		ADD_TRAIT(owner, TRAIT_IMMOBILIZED, CRIT_SOURCE(id))
	else if(old_stat < SOFT_CRIT)
		REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, CRIT_SOURCE(id))

/datum/status_effect/grabbed/proc/try_upgrade(datum/source, mob/living/user, force)
	SIGNAL_HANDLER
	if(user != grabbing_us)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(upgrade_attempt))
	return COMSIG_LIVING_CANCEL_PULL

/datum/status_effect/grabbed/proc/upgrade_attempt()
	var/mob/living/mob_grabber = grabbing_us
	if(istype(mob_grabber) && DOING_INTERACTION_WITH_TARGET(mob_grabber, owner))
		return
	if(!(owner.status_flags & CANPUSH) || HAS_TRAIT(owner, TRAIT_PUSHIMMUNE))
		to_chat(grabbing_us, span_warning("[owner] can't be grabbed more aggressively!"))
		return
	if(grabbing_us.grab_state >= GRAB_AGGRESSIVE && HAS_TRAIT(grabbing_us, TRAIT_PACIFISM))
		to_chat(grabbing_us, span_warning("You don't want to risk hurting [owner]!"))
		return
	if(grabbing_us.grab_state >= grabbing_us.max_grab)
		to_chat(grabbing_us, span_warning("You can't grab [owner] any more aggressively!"))
		return

	playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	grabbing_us.do_attack_animation(owner, "grab")
	if(istype(mob_grabber))
		mob_grabber.face_atom(owner)
		mob_grabber.changeNext_move(CLICK_CD_GRABBING)
	owner.add_fingerprint(grabbing_us)
	if(grabbing_us.grab_state >= GRAB_AGGRESSIVE)
		owner.visible_message(
			span_danger("[grabbing_us] starts to tighten [grabbing_us.p_their()] grip on [owner]!"),
			span_userdanger("[grabbing_us] starts to tighten [grabbing_us.p_their()] grip on you!"),
			span_hear("You hear aggressive shuffling!"),
			null,
			grabbing_us,
		)
		to_chat(grabbing_us, span_danger("You start to tighten your grip on [owner]!"))
		if(owner.is_blind())
			to_chat(owner, span_userdanger("Someone starts to tighten their grip on you!"))
		switch(grabbing_us.grab_state)
			if(GRAB_AGGRESSIVE)
				log_combat(grabbing_us, owner, "attempted to neck grab", addition = "neck grab")
			if(GRAB_NECK)
				log_combat(grabbing_us, owner, "attempted to strangle", addition = "kill grab")
		if(!do_after(grabbing_us, get_grab_time(8 SECONDS), owner, extra_checks = CALLBACK(src, PROC_REF(upgrade_check), grabbing_us.grab_state),))
			return

	grabbing_us.setGrabState(grabbing_us.grab_state + 1)
	switch(grabbing_us.grab_state)
		if(GRAB_AGGRESSIVE)
			var/add_log = ""
			if(HAS_TRAIT(grabbing_us, TRAIT_PACIFISM))
				owner.visible_message(
					span_danger("[grabbing_us] firmly grips [owner]!"),
					span_danger("[grabbing_us] firmly grips you!"),
					span_hear("You hear aggressive shuffling!"),
					null,
					grabbing_us,
				)
				to_chat(grabbing_us, span_danger("You firmly grip [owner]!"))
				if(owner.is_blind())
					to_chat(owner, span_danger("Someone firmly grips you!"))
				add_log = " (pacifist)"
			else
				owner.visible_message(
					span_danger("[grabbing_us] grabs [owner] aggressively!"),
					span_userdanger("[grabbing_us] grabs you aggressively!"),
					span_hear("You hear aggressive shuffling!"),
					null,
					grabbing_us,
				)
				to_chat(grabbing_us, span_danger("You grab [owner] aggressively!"))
				if(owner.is_blind())
					to_chat(owner, span_userdanger("Someone grabs you aggressively!"))
			owner.stop_pulling()
			log_combat(grabbing_us, owner, "grabbed", addition = "aggressive grab[add_log]")
		if(GRAB_NECK)
			log_combat(grabbing_us, owner, "grabbed", addition = "neck grab")
			owner.visible_message(
				span_danger("[grabbing_us] grabs [owner] by the neck!"),
				span_userdanger("[grabbing_us] grabs you by the neck!"),
				span_hear("You hear aggressive shuffling!"),
				null,
				grabbing_us,
			)
			to_chat(grabbing_us, span_danger("You grab [owner] by the neck!"))
			if(owner.is_blind())
				to_chat(owner, span_userdanger("Someone grabs you by the neck!"))
		if(GRAB_KILL)
			log_combat(grabbing_us, owner, "strangled", addition = "kill grab")
			owner.visible_message(
				span_danger("[grabbing_us] is strangling [owner]!"),
				span_userdanger("[grabbing_us] is strangling you!"),
				span_hear("You hear aggressive shuffling!"),
				null,
				grabbing_us,
			)
			to_chat(grabbing_us, span_danger("You're strangling [owner]!"))
			if(owner.is_blind())
				to_chat(owner, span_userdanger("Someone is strangling you!"))

	if(grabbing_us.grab_state >= GRAB_NECK && !owner.buckled && !pin)
		link_mobs()
	if(QDELETED(src))
		stack_trace("Grab self-terminated at some time during the upgrade process.")
		return
	if(istype(mob_grabber))
		owner.setDir(mob_grabber.dir)
		mob_grabber.set_pull_offsets(owner, grabbing_us.grab_state)

/datum/status_effect/grabbed/proc/upgrade_check(initial_state)
	return !QDELETED(src) && !QDELETED(grabbing_us) && grabbing_us.grab_state == initial_state

/datum/status_effect/grabbed/proc/try_pin(datum/source, mob/living/user, modifiers)
	SIGNAL_HANDLER
	if(user != grabbing_us)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(pin_attempt))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/grabbed/proc/pin_attempt()
	if(pin)
		manual_unpin()
		return
	if(grabbing_us.grab_state < GRAB_AGGRESSIVE)
		return
	var/mob/living/mob_grabber = grabbing_us
	if(istype(mob_grabber) && DOING_INTERACTION_WITH_TARGET(mob_grabber, owner))
		return
	if(!grabbing_us.has_gravity())
		to_chat(grabbing_us, span_warning("You can't pin someone if you're not standing on the ground!"))
		return
	if(!owner.has_gravity())
		to_chat(grabbing_us, span_warning("You can't pin someone who's not standing on the ground!"))
		return
	if(owner.buckled)
		to_chat(grabbing_us, span_warning("You can't pin someone who's buckled to something!"))
		return

	playsound(owner, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	grabbing_us.do_attack_animation(owner, "grab")
	if(istype(mob_grabber))
		mob_grabber.face_atom(owner)
		mob_grabber.changeNext_move(CLICK_CD_GRABBING)
	// owner.add_fingerprint(grabbing_us)
	owner.visible_message(
		span_danger("[grabbing_us] starts to pin [owner] to the ground!"),
		span_userdanger("[grabbing_us] starts to pin you to the ground!"),
		span_hear("You hear aggressive shuffling!"),
		null,
		grabbing_us,
	)
	to_chat(grabbing_us, span_danger("You start to pin [owner] to the ground!"))
	if(owner.is_blind())
		to_chat(owner, span_userdanger("Someone is trying to pin you to the ground!"))

	if(!do_after(grabbing_us, get_grab_time(6 SECONDS), owner, extra_checks = CALLBACK(src, PROC_REF(pin_check)),))
		return
	if(owner.buckled || HAS_TRAIT_NOT_FROM(owner, TRAIT_FORCED_STANDING, LINK_SOURCE(id)))
		to_chat(grabbing_us, span_warning("You fail to pin [owner] to the ground!"))
		return

	owner.visible_message(
		span_danger("[grabbing_us] pins [owner] to the ground!"),
		span_userdanger("[grabbing_us] pins you to the ground!"),
		span_hear("You hear a loud thud!"),
		null,
		grabbing_us,
	)
	to_chat(grabbing_us, span_danger("You pin [owner] to the ground!"))
	if(owner.is_blind())
		to_chat(owner, span_userdanger("You are pinned to the ground!"))

	log_combat(grabbing_us, owner, "pinned")
	pin = TRUE
	unlink_mobs()
	ADD_TRAIT(owner, TRAIT_NO_MOVE_PULL, PIN_SOURCE(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, PIN_SOURCE(id))
	owner.Paralyze(2 SECONDS)
	owner.setDir(SOUTH)
	grabbing_us.Move(owner.loc)
	grabbing_us.setDir(UNLINT(owner.lying_angle) == 270 ? WEST : EAST) // melbert todo
	RegisterSignal(grabbing_us, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(start_dragging))

/datum/status_effect/grabbed/proc/pin_check()
	return !QDELETED(src) && !QDELETED(grabbing_us) && !pin && grabbing_us.grab_state >= GRAB_AGGRESSIVE

/datum/status_effect/grabbed/proc/start_dragging(datum/source, atom/new_loc)
	SIGNAL_HANDLER
	if(!isturf(new_loc) || new_loc == owner.loc)
		return
	owner.visible_message(
		span_danger("[grabbing_us] starts dragging [owner]!"),
		span_danger("[grabbing_us] starts dragging you!"),
		span_hear("You hear the sound of dragging!"),
		null,
		grabbing_us,
	)
	to_chat(grabbing_us, span_danger("You start dragging [owner] along!"))
	UnregisterSignal(grabbing_us, COMSIG_MOVABLE_PRE_MOVE)
	owner.set_resting(TRUE)
	owner.Knockdown(5 SECONDS)
	unpin()

/datum/status_effect/grabbed/proc/manual_unpin()
	owner.visible_message(
		span_danger("[grabbing_us] releases [owner] from the pin!"),
		span_danger("[grabbing_us] releases you from the pin!"),
		null,
		null,
		grabbing_us,
	)
	to_chat(grabbing_us, span_danger("You release [owner] from the pin!"))
	if(owner.is_blind())
		to_chat(owner, span_danger("Someone releases you from a pin!"))
	unpin()
	grabbing_us.setGrabState(GRAB_AGGRESSIVE)
	owner.Paralyze(0.75 SECONDS)
	// grabbing_us.stop_pulling()

/datum/status_effect/grabbed/proc/unpin()
	if(!pin)
		return

	pin = FALSE
	REMOVE_TRAIT(owner, TRAIT_FLOORED, PIN_SOURCE(id))
	REMOVE_TRAIT(owner, TRAIT_NO_MOVE_PULL, PIN_SOURCE(id))
	UnregisterSignal(grabbing_us, COMSIG_MOVABLE_PRE_MOVE)

/datum/status_effect/grabbed/proc/update_state(datum/source, new_state)
	SIGNAL_HANDLER
	if(new_state >= GRAB_AGGRESSIVE)
		ADD_TRAIT(owner, TRAIT_IMMOBILIZED, GRAB_SOURCE(id))
		ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, GRAB_SOURCE(id))
	if(linked && new_state <= GRAB_AGGRESSIVE)
		unlink_mobs()

/datum/status_effect/grabbed/proc/breath_fail(...)
	SIGNAL_HANDLER
	if(grabbing_us.grab_state >= GRAB_KILL && !HAS_TRAIT(owner, TRAIT_ASSISTED_BREATHING))
		return BREATHE_SKIP_BREATH
	return NONE

/datum/status_effect/grabbed/proc/ungrabbed(datum/source, mob/living/gone)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/grabbed/proc/grabber_gone(...)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/grabbed/proc/grabber_flip(datum/source)
	SIGNAL_HANDLER
	if(grabbing_us.grab_state <= GRAB_AGGRESSIVE || pin)
		return
	if(!grabbing_us.has_gravity())
		to_chat(grabbing_us, span_warning("You can't suplex someone without gravity!"))
		return

	var/mob/living/grabber = grabbing_us

	owner.SpinAnimation(7, 1, parallel = TRUE)
	owner.Immobilize(2.5 SECONDS)
	grabber.Immobilize(0.5 SECONDS)
	grabber.apply_damage(30, STAMINA)

	addtimer(CALLBACK(src, PROC_REF(finish_flip)), 0.5 SECONDS, TIMER_DELETE_ME)

/datum/status_effect/grabbed/proc/finish_flip()
	var/mob/living/grabber = grabbing_us

	owner.visible_message(
		span_danger("[grabbing_us] suplexes [owner]!"),
		span_danger("[grabbing_us] suplexes you!"),
		span_hear("You hear a loud thud!"),
		null,
		grabber,
	)
	to_chat(grabber, span_danger("You suplex [owner]!"))

	owner.Knockdown(5 SECONDS)
	owner.apply_damage(10, BRUTE, BODY_ZONE_CHEST, owner.run_armor_check(BODY_ZONE_CHEST, MELEE))

	unlink_mobs(get_step(grabber.loc, REVERSE_DIR(grabber.dir)))
	grabber.Knockdown(2 SECONDS)
	//grabber.stop_pulling()

/datum/status_effect/grabbed/proc/link_mobs()
	if(linked)
		return

	linked = TRUE
	ADD_TRAIT(owner, TRAIT_UNDENSE, LINK_SOURCE(id))
	ADD_TRAIT(owner, TRAIT_FORCED_STANDING, LINK_SOURCE(id))
	ADD_TRAIT(owner, TRAIT_NO_MOVE_PULL, LINK_SOURCE(id))
	owner.setDir(grabbing_us.dir)
	owner.Move(grabbing_us.loc)
	RegisterSignal(grabbing_us, COMSIG_MOVABLE_MOVED, PROC_REF(bring_along))
	RegisterSignal(grabbing_us, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(bullet_shield))
	RegisterSignal(grabbing_us, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(dir_changed))

/datum/status_effect/grabbed/proc/unlink_mobs(atom/unlink_loc)
	if(!linked)
		return

	linked = FALSE
	REMOVE_TRAIT(owner, TRAIT_UNDENSE, LINK_SOURCE(id))
	REMOVE_TRAIT(owner, TRAIT_FORCED_STANDING, LINK_SOURCE(id))
	REMOVE_TRAIT(owner, TRAIT_NO_MOVE_PULL, LINK_SOURCE(id))
	if(!QDELING(owner) && !QDELING(grabbing_us))
		owner.Move(unlink_loc || get_step(grabbing_us.loc, grabbing_us.dir))
	UnregisterSignal(grabbing_us, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_PRE_BULLET_ACT,
		COMSIG_ATOM_POST_DIR_CHANGE,
	))

/datum/status_effect/grabbed/proc/bring_along(datum/source, atom/old_loc, movement_dir)
	SIGNAL_HANDLER

	if(grabbing_us.loc != old_loc && isturf(grabbing_us.loc))
		owner.Move(grabbing_us.loc, movement_dir, grabbing_us.glide_size)

/datum/status_effect/grabbed/proc/dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir != new_dir)
		owner.setDir(new_dir)

/datum/status_effect/grabbed/proc/bullet_shield(datum/source, obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SIGNAL_HANDLER
	if(piercing_hit)
		return NONE
	var/forwards_dir = REVERSE_DIR(grabbing_us.dir)
	if(!(hitting_projectile.dir & forwards_dir))
		return NONE
	if(prob(33 * (owner.mob_size + 1)))
		return NONE

	owner.bullet_act(hitting_projectile, def_zone, piercing_hit)
	return COMPONENT_BULLET_BLOCKED

/datum/status_effect/grabbed/proc/get_grab_time(base_time = 5 SECONDS)
	var/vulnerability_delta = 0
	if(isliving(grabbing_us))
		var/mob/living/grabber = grabbing_us
		// Compare grab strength vs resist strength
		vulnerability_delta = owner.get_grab_resist_strength() - grabber.get_grab_strength()
	else
		// Just assume 5 (roughly the same as a human with gloves)
		vulnerability_delta = owner.get_grab_resist_strength() - 5

	return clamp(base_time + (vulnerability_delta * 1 SECONDS), 2 SECONDS, 20 SECONDS)

#undef LINK_SOURCE
#undef GRAB_SOURCE
#undef CRIT_SOURCE
#undef PIN_SOURCE

/// Checks how strong our grabs are.
/mob/living/proc/get_grab_strength()
	. += get_grab_resist_strength()
	if(HAS_TRAIT(src, TRAIT_QUICKER_CARRY))
		. += 1
	else if(HAS_TRAIT(src, TRAIT_QUICK_CARRY))
		. += 0.5

/// Checks how strong we are at resisting being grabbed.
/mob/living/proc/get_grab_resist_strength()
	. += mob_size * 2
	. += clamp(0.5 * ((mind?.get_skill_level(/datum/skill/fitness) || 1) - 1), 0, 3)
	if(ismonkey(src))
		. -= 1
	if(stat == DEAD)
		. -= 4
	else if(incapacitated(IGNORE_GRAB|IGNORE_STASIS) \
		|| body_position == LYING_DOWN \
		|| (has_status_effect(/datum/status_effect/staggered) && getStaminaLoss() >= 30) \
	)
		. -= 2
	if(HAS_TRAIT(src, TRAIT_GRABWEAKNESS))
		. -= 2
	// these two are not
	if(HAS_TRAIT(src, TRAIT_DWARF))
		. -= 2
	if(HAS_TRAIT(src, TRAIT_HULK))
		. += 2
