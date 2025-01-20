
// The shattered remnants of your broken limbs fill you with determination!
/atom/movable/screen/alert/determined
	name = "Determined"
	desc = "The serious wounds you've sustained have put your body into fight-or-flight mode! Now's the time to look for an exit!"
	icon_state = "wounded"


/// While someone has determination in their system, their bleed rate is slightly reduced
#define WOUND_DETERMINATION_BLEED_MOD 0.85

/datum/status_effect/determined
	id = "determined"
	remove_on_fullheal = TRUE
	tick_interval = 2 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// World.time when the status effect was applied
	var/start_time = 0

/datum/status_effect/determined/on_creation(mob/living/new_owner, set_duration = 5 SECONDS)
	src.duration = min(WOUND_DETERMINATION_MAX, set_duration)
	start_time = world.time
	return ..()

/datum/status_effect/determined/refresh(mob/living/new_owner, set_duration = 5 SECONDS)
	duration = min(duration + set_duration, start_time + WOUND_DETERMINATION_MAX)
	if(set_duration >= WOUND_DETERMINATION_SEVERE)
		owner.throw_alert(id, /atom/movable/screen/alert/determined)

/datum/status_effect/determined/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	owner.visible_message(
		span_danger("[owner]'s body tenses up noticeably, gritting against [owner.p_their()] pain!"),
		span_boldnotice("Your senses sharpen as your body tenses up from the wounds you've sustained!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod *= WOUND_DETERMINATION_BLEED_MOD
	ADD_TRAIT(owner, TRAIT_ABATES_SHOCK, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_HEART_RATE_BOOST, TRAIT_STATUS_EFFECT(id))
	owner.add_consciousness_multiplier(id, 1.15)
	if(duration >= WOUND_DETERMINATION_SEVERE)
		owner.throw_alert(id, /atom/movable/screen/alert/determined)
	return TRUE

/datum/status_effect/determined/on_remove()
	if(QDELING(owner))
		return

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod /= WOUND_DETERMINATION_BLEED_MOD
	REMOVE_TRAIT(owner, TRAIT_ABATES_SHOCK, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_HEART_RATE_BOOST, TRAIT_STATUS_EFFECT(id))
	owner.remove_consciousness_multiplier(id)
	owner.clear_alert(id)
	owner.apply_status_effect(/datum/status_effect/determination_crash)

/datum/status_effect/determined/tick(seconds_between_ticks)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD || !iscarbon(owner))
		return

	var/mob/living/carbon/carbowner = owner
	for(var/datum/wound/wound as anything in carbowner.all_wounds)
		wound.limb?.heal_damage(0.2 * seconds_between_ticks, 0.2 * seconds_between_ticks)

#undef WOUND_DETERMINATION_BLEED_MOD

/datum/status_effect/determination_crash
	id = "determination_crash"
	alert_type = null
	remove_on_fullheal = TRUE
	tick_interval = -1
	duration = 10 SECONDS

/datum/status_effect/determination_crash/on_apply()
	if(owner.stat == DEAD)
		return FALSE

	owner.visible_message(
		span_danger("[owner]'s body slackens noticeably!"),
		span_boldwarning("Your adrenaline rush dies off, and the pain from your wounds come aching back in..."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/determination_crash)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/determination_crash)
	return TRUE

/datum/status_effect/determination_crash/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/determination_crash)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/determination_crash)

/datum/movespeed_modifier/determination_crash
	multiplicative_slowdown = 0.1

/datum/actionspeed_modifier/determination_crash
	multiplicative_slowdown = 0.1

/datum/status_effect/limp
	id = "limp"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/limp
	on_remove_on_mob_delete = TRUE
	/// The left leg of the limping person
	var/obj/item/bodypart/leg/left/left
	/// The right leg of the limping person
	var/obj/item/bodypart/leg/right/right
	/// Which leg we're limping with next
	var/obj/item/bodypart/next_leg
	/// How many deciseconds we limp for on the left leg
	var/slowdown_left = 0
	/// How many deciseconds we limp for on the right leg
	var/slowdown_right = 0
	/// The chance we limp with the left leg each step it takes
	var/limp_chance_left = 0
	/// The chance we limp with the right leg each step it takes
	var/limp_chance_right = 0

/datum/status_effect/limp/on_apply()
	if(!iscarbon(owner))
		return FALSE
	update_limp()
	if(QDELETED(src)) // update limp might have removed us
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_step))
	RegisterSignals(owner, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_POST_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), PROC_REF(update_limp))
	return TRUE

/datum/status_effect/limp/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_POST_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	next_leg = null
	left = null
	right = null

/atom/movable/screen/alert/status_effect/limp
	name = "Limping"
	desc = "One or more of your legs has been wounded, slowing down steps with that leg! Get it fixed, or at least in a sling of gauze!"

/datum/status_effect/limp/proc/check_step(mob/whocares, OldLoc, Dir, forced)
	SIGNAL_HANDLER

	if(!owner.client || owner.body_position == LYING_DOWN || !owner.has_gravity() || (owner.movement_type & (FLYING|FLOATING)) || forced || owner.buckled)
		return

	if(SEND_SIGNAL(owner, COMSIG_CARBON_LIMPING, (next_leg || right || left)) & COMPONENT_CANCEL_LIMP)
		next_leg = (next_leg == left ? right : left)
		return

	// less limping while we have determination still
	var/determined_mod = CAN_FEEL_PAIN(owner) ? 1 : 0.5

	if(next_leg == left)
		if(prob(limp_chance_left * determined_mod))
			owner.client.move_delay += slowdown_left * determined_mod
		next_leg = right
	else
		if(prob(limp_chance_right * determined_mod))
			owner.client.move_delay += slowdown_right * determined_mod
		next_leg = left

/datum/status_effect/limp/proc/update_limp()
	SIGNAL_HANDLER

	left = owner.get_bodypart(BODY_ZONE_L_LEG)
	right = owner.get_bodypart(BODY_ZONE_R_LEG)
	next_leg = null

	if(!left && !right)
		qdel(src)
		return

	slowdown_left = 0
	slowdown_right = 0
	limp_chance_left = 0
	limp_chance_right = 0

	// technically you can have multiple wounds causing limps on the same limb, even if practically only bone wounds cause it in normal gameplay
	if(left)
		for(var/datum/wound/W as anything in left.wounds)
			slowdown_left += W.limp_slowdown
			limp_chance_left = max(limp_chance_left, W.limp_chance)

	if(right)
		for(var/datum/wound/W as anything in right.wounds)
			slowdown_right += W.limp_slowdown
			limp_chance_right = max(limp_chance_right, W.limp_chance)

	// this handles losing your leg with the limp and the other one being in good shape as well
	if(!slowdown_left && !slowdown_right)
		qdel(src)
		return


/////////////////////////
//////// WOUNDS /////////
/////////////////////////

// wound status effect base
/datum/status_effect/wound
	id = "wound"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/bodypart/linked_limb
	var/datum/wound/linked_wound
	alert_type = NONE

/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	linked_wound = incoming_wound
	linked_limb = linked_wound.limb
	return ..()

/datum/status_effect/wound/on_remove()
	linked_wound = null
	linked_limb = null
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_WOUND)

/datum/status_effect/wound/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_WOUND, PROC_REF(check_remove))
	return TRUE

/// check if the wound getting removed is the wound we're tied to
/datum/status_effect/wound/proc/check_remove(mob/living/L, datum/wound/W)
	SIGNAL_HANDLER

	if(W == linked_wound)
		qdel(src)

/datum/status_effect/wound/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.get_action_delay_mult()

	return ..()

/datum/status_effect/wound/nextmove_adjust()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.get_action_delay_increment()

	return ..()


// bones
/datum/status_effect/wound/blunt/bone

// blunt
/datum/status_effect/wound/blunt/bone/rib_break
	id = "rib_break"
/datum/status_effect/wound/blunt/bone/moderate
	id = "disjoint"
/datum/status_effect/wound/blunt/bone/severe
	id = "hairline"
/datum/status_effect/wound/blunt/bone/critical
	id = "compound"

// slash

/datum/status_effect/wound/slash/flesh/moderate
	id = "abrasion"
/datum/status_effect/wound/slash/flesh/severe
	id = "laceration"
/datum/status_effect/wound/slash/flesh/critical
	id = "avulsion"
// pierce
/datum/status_effect/wound/pierce/moderate
	id = "breakage"
/datum/status_effect/wound/pierce/severe
	id = "puncture"
/datum/status_effect/wound/pierce/critical
	id = "rupture"
// burns
/datum/status_effect/wound/burn/flesh/moderate
	id = "seconddeg"
/datum/status_effect/wound/burn/flesh/severe
	id = "thirddeg"
/datum/status_effect/wound/burn/flesh/critical
	id = "fourthdeg"
