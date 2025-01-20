// For debugging pain
// #define PAIN_DEBUG

/**
 * # Pain controller
 *
 * Attatched to a mob, this datum tracks all the pain values on all their bodyparts and handles updating them.
 * This datum processes on alive humans every 2 seconds.
 */
/datum/pain
	/// The parent mob we're tracking.
	VAR_PRIVATE/mob/living/carbon/parent
	/**
	 * Modifier that determines how much of the "pain" the mob actually feels.]
	 *
	 * Affects:
	 * - Pain feedback messages
	 * - Doing pain-related emotes (screams or gasps)
	 * - Duration of some pain effects (dizziness, etc)
	 * - Rate of traumatic shock buildup
	 *
	 * Below 0.5, a mob is treated as "numb", and will outright no longer
	 * experience pain feedback messages or effects (but it'll still accumulate!)
	 */
	VAR_FINAL/pain_modifier = 1
	/// Lazy Assoc list [id] to [modifier], all our pain modifiers affecting our final mod
	VAR_PRIVATE/list/pain_mods
	/// Lazy Assoc list [zones] to [references to bodyparts], all the body parts we're tracking
	VAR_PRIVATE/list/body_zones
	/// Natural amount of decay given to each limb per 5 ticks of process, increases over time
	VAR_FINAL/natural_pain_decay = -0.5
	/// The base amount of pain decay received.
	VAR_FINAL/base_pain_decay
	/// Amount of traumatic shock building up from higher levels of pain
	VAR_FINAL/traumatic_shock = 0
	/// Tracks how many successful heart attack rolls in a row
	VAR_FINAL/heart_attack_counter = 0
	/// Cooldown to track the last time we lost pain.
	COOLDOWN_DECLARE(time_since_last_pain_loss)
	/// Cooldown to track last time we sent a pain message.
	COOLDOWN_DECLARE(time_since_last_pain_message)
	/// Cooldown to track last time heart attack counter went up.
	COOLDOWN_DECLARE(time_since_last_heart_attack_counter)

#ifdef PAIN_DEBUG
	/// For testing. Does this pain datum print testing messages when it happens?
	var/print_debug_messages = TRUE
	/// For testing. Does this pain datum include ALL test messages, including very small and constant ones (like pain decay)?
	var/print_debug_decay = FALSE
#endif

/datum/pain/New(mob/living/carbon/human/new_parent)
	if(!iscarbon(new_parent) || isdummy(new_parent))
		qdel(src) // If we're not a carbon, or a dummy, delete us
		return

	parent = new_parent

	body_zones = list()
	for(var/obj/item/bodypart/parent_bodypart as anything in parent.bodyparts)
		add_bodypart(parent, parent_bodypart, TRUE)

	if(!length(body_zones))
		stack_trace("Pain datum failed to find any body_zones to track!")
		qdel(src) // If we have no bodyparts, delete us
		return

	register_pain_signals()
	base_pain_decay = natural_pain_decay

	addtimer(CALLBACK(src, PROC_REF(start_pain_processing), 1))

#ifdef PAIN_DEBUG
	if(new_parent.z && !is_station_level(new_parent.z))
		print_debug_messages = FALSE
#endif

/datum/pain/Destroy()
	body_zones = null
	if(parent)
		STOP_PROCESSING(SSpain, src)
		unregister_pain_signals()
		parent = null
	return ..()

/datum/pain/proc/start_pain_processing()
	if(parent.stat != DEAD)
		START_PROCESSING(SSpain, src)

/datum/pain/proc/register_pain_signals()
	RegisterSignal(parent, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(add_bodypart))
	RegisterSignal(parent, COMSIG_CARBON_GAIN_WOUND, PROC_REF(add_wound_pain))
	RegisterSignal(parent, COMSIG_CARBON_LOSE_WOUND, PROC_REF(remove_wound_pain))
	RegisterSignal(parent, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(remove_bodypart))
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_analyzed))
	RegisterSignal(parent, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(remove_all_pain))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(add_damage_pain))
	RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(on_parent_statchance))
	RegisterSignal(parent, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(handle_message))
	RegisterSignal(parent, COMSIG_MOB_FIRED_GUN, PROC_REF(on_mob_fired_gun))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(revived))

/**
 * Unregister all of our signals from our parent when we're done, if we have signals to unregister.
 */
/datum/pain/proc/unregister_pain_signals()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_GAIN_WOUND,
		COMSIG_CARBON_LOSE_WOUND,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_LIVING_HEALTHSCAN,
		COMSIG_LIVING_POST_FULLY_HEAL,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_TREAT_MESSAGE,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_STATCHANGE,
	))

/// Add a bodypart to be tracked.
/// Also causes pain if the limb was added non-'special'.
/datum/pain/proc/add_bodypart(mob/living/carbon/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER

	if(!istype(new_limb)) // pseudo-bodyparts are not tracked for simplicity (chainsaw arms)
		return

	var/obj/item/bodypart/existing = body_zones[new_limb.body_zone]
	if(!isnull(existing)) // if we already have a val assigned to this key, remove it
		remove_bodypart(source, existing, FALSE, special)

	body_zones[new_limb.body_zone] = new_limb

	if(special || (HAS_TRAIT(source, TRAIT_ROBOTIC_LIMBATTACHMENT) && (new_limb.bodytype & BODYTYPE_ROBOTIC)))
		new_limb.pain = 0
	else
		adjust_bodypart_pain(new_limb.body_zone, new_limb.pain)
		adjust_bodypart_pain(BODY_ZONE_CHEST, new_limb.pain / 3)

	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_delete))

/// Removes a limb from being tracked.
/// Also causes pain if the limb was removed non-'special'.
/datum/pain/proc/remove_bodypart(mob/living/carbon/source, obj/item/bodypart/lost_limb, special, dismembered)
	SIGNAL_HANDLER

	var/bad_zone = lost_limb.body_zone
	if(lost_limb != body_zones[bad_zone])
		CRASH("Pain datum tried to remove a bodypart that wasn't being tracked!")

	body_zones -= bad_zone
	UnregisterSignal(lost_limb, COMSIG_QDELETING)

	if(!QDELETED(parent))
		if(!special && !(HAS_TRAIT(source, TRAIT_ROBOTIC_LIMBATTACHMENT) && (lost_limb.bodytype & BODYTYPE_ROBOTIC)))
			var/limb_removed_pain = (dismembered ? PAIN_LIMB_DISMEMBERED : PAIN_LIMB_REMOVED)
			adjust_bodypart_pain(BODY_ZONE_CHEST, limb_removed_pain)
			adjust_bodypart_pain(BODY_ZONES_MINUS_CHEST, limb_removed_pain / 3)

	if(!QDELETED(lost_limb))
		lost_limb.pain = initial(lost_limb.pain)
		REMOVE_TRAIT(lost_limb, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)

/// Clear reference when a limb is deleted.
/datum/pain/proc/limb_delete(obj/item/bodypart/source)
	SIGNAL_HANDLER

	remove_bodypart(source.owner, source, special = TRUE) // Special I guess? Straight up deleted

/**
 * Add a pain modifier and update our overall modifier.
 *
 * * key - key of the added modifier
 * * amount - multiplier of the modifier
 *
 * Returns TRUE if our pain mod actually changed
 */
/datum/pain/proc/set_pain_modifier(key, amount)
	var/existing_key = LAZYACCESS(pain_mods, key)
	if(!isnull(existing_key))
		if(amount > 1 && existing_key >= amount)
			return FALSE
		if(amount < 1 && existing_key <= amount)
			return FALSE
		if(amount == 1)
			return FALSE

	LAZYSET(pain_mods, key, amount)
	return update_pain_modifier()

/**
 * Remove a pain modifier and update our overall modifier.
 *
 * * key - key of the removed modifier
 *
 * Returns TRUE if our pain mod actually changed
 */
/datum/pain/proc/unset_pain_modifier(key)
	if(isnull(LAZYACCESS(pain_mods, key)))
		return FALSE

	LAZYREMOVE(pain_mods, key)
	return update_pain_modifier()

/**
 * Update our overall pain modifier.
 * The pain modifier is multiplicative based on all the pain modifiers we have.
 *
 * Returns TRUE if our pain modifier was changed after update, FALSE if it remained the same
 */
/datum/pain/proc/update_pain_modifier()
	var/old_pain_mod = pain_modifier
	pain_modifier = 1
	for(var/mod in pain_mods)
		pain_modifier *= pain_mods[mod]
	if(old_pain_mod == pain_modifier)
		return FALSE
	refresh_pain_attributes()
	return TRUE

/**
 * Adjust the amount of pain in all [def_zones] provided by [amount] (multiplied by the [pain_modifier] if positive).
 *
 * This is the bread and butter way to apply pain to a mob.
 *
 * * def_zones - list of all zones being adjusted. Can be passed a non-list.
 * * amount - amount of pain being applied to all items in [def_zones]. If posiitve, multiplied by [pain_modifier].
 *
 * Returns TRUE if pain was adjusted, FALSE if no pain was adjusted.
 */
/datum/pain/proc/adjust_bodypart_pain(list/def_zones, amount = 0, dam_type = BRUTE)
	SHOULD_NOT_SLEEP(TRUE) // This needs to be asyncronously called in a lot of places, it should already check that this doesn't sleep but just in case.

	if(!islist(def_zones))
		def_zones = list(def_zones)

	// No pain at all
	if(amount == 0)
		return FALSE
	if(amount > 0 && (parent.status_flags & GODMODE))
		return FALSE

	amount = round(amount, 0.01)

	for(var/zone in shuffle(def_zones))
		var/obj/item/bodypart/adjusted_bodypart = body_zones[check_zone(zone)]
		if(isnull(adjusted_bodypart)) // it's valid - for if we're passed a zone we don't have
			continue

		var/current_amount = adjusted_bodypart.pain
		// Pain is negative (healing)
		if(amount < 0)
			if(current_amount <= adjusted_bodypart.min_pain)
				continue

		// Pain is positive (dealing)
		else
			// Officially recieving pain at this point
			adjusted_bodypart.last_received_pain_type = dam_type

#ifdef PAIN_DEBUG
		if(print_debug_messages)
			testing("[amount] was adjusted down to [adjusted_amount]. (Modifiers: [pain_modifier], [adjusted_bodypart.bodypart_pain_modifier])")
#endif

		// Actually do the pain addition / subtraction here
		adjusted_bodypart.pain = max(current_amount + amount, adjusted_bodypart.min_pain)

		if(amount > 0)
			INVOKE_ASYNC(src, PROC_REF(on_pain_gain), adjusted_bodypart, amount, dam_type)
		else if(amount <= -1.5 || COOLDOWN_FINISHED(src, time_since_last_pain_loss))
			INVOKE_ASYNC(src, PROC_REF(on_pain_loss), adjusted_bodypart, amount, dam_type)
		SShealth_updates.queue_update(parent, UPDATE_SELF_DAMAGE|UPDATE_CON)

#ifdef PAIN_DEBUG
		if(print_debug_messages && (print_debug_decay || abs(adjusted_amount) > 1))
			testing("PAIN DEBUG: [parent] recived [adjusted_amount] pain to [adjusted_bodypart]. Part pain: [adjusted_bodypart.pain]")
#endif

	return TRUE

/**
 * Adjusts the progress of pain shock on the current mob.
 *
 * * amount - the number of ticks of progress to remove. Note that one tick = two seconds for pain.
 * * down_to - the minimum amount of pain shock the mob can have.
 */
/datum/pain/proc/adjust_traumatic_shock(amount, down_to = -20)
	if(amount > 0)
		amount *= max(pain_modifier, 0.33)

	traumatic_shock = clamp(traumatic_shock + amount, down_to, MAX_TRAUMATIC_SHOCK)
	SShealth_updates.queue_update(parent, UPDATE_SELF_DAMAGE)
	if(traumatic_shock <= 0)
		parent.remove_consciousness_modifier(PAINSHOCK)
	else
		parent.add_consciousness_modifier(PAINSHOCK, -0.33 * traumatic_shock)
	// Soft crit
	if(traumatic_shock >= SHOCK_DANGER_THRESHOLD)
		if(!HAS_TRAIT_FROM(parent, TRAIT_SOFT_CRIT, PAINSHOCK))
			set_pain_modifier(PAINSHOCK, 1.2)
			parent.add_max_consciousness_value(PAINSHOCK, 60)
			parent.apply_status_effect(/datum/status_effect/low_blood_pressure)
			parent.add_traits(list(TRAIT_SOFT_CRIT, TRAIT_LABOURED_BREATHING), PAINSHOCK)

	else
		if(HAS_TRAIT_FROM(parent, TRAIT_SOFT_CRIT, PAINSHOCK))
			unset_pain_modifier(PAINSHOCK)
			parent.remove_max_consciousness_value(PAINSHOCK)
			parent.remove_status_effect(/datum/status_effect/low_blood_pressure)
			parent.remove_traits(list(TRAIT_SOFT_CRIT, TRAIT_LABOURED_BREATHING), PAINSHOCK)
/**
 * Set the minimum amount of pain in all [def_zones] by [amount].
 *
 * * def_zones - list of all zones being adjusted. Can be passed a non-list.
 * * amount - amount of pain being all items in [def_zones] are set to.
 */
/datum/pain/proc/adjust_bodypart_min_pain(list/def_zones, amount = 0)
	if(!amount)
		return

	if(!islist(def_zones))
		def_zones = list(def_zones)

	for(var/zone in def_zones)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[zone]
		if(isnull(adjusted_bodypart)) // it's valid - for if we're passed a zone we don't have
			continue

		adjusted_bodypart.min_pain = max(adjusted_bodypart.min_pain + amount, 0) // Negative min pain is a neat idea ("banking pain") but not today
		adjusted_bodypart.pain = max(adjusted_bodypart.pain, adjusted_bodypart.min_pain)

	return TRUE

/**
 * Called when pain is gained to apply side effects.
 * Calls [affected_part]'s [on_gain_pain_effects] proc with arguments [amount].
 *
 * * affected_part - the bodypart that gained the pain
 * * amount - amount of pain that was gained, post-[pain_modifier] applied
 */
/datum/pain/proc/on_pain_gain(obj/item/bodypart/affected_part, amount, dam_type)
	affected_part.on_gain_pain_effects(amount, dam_type)
	refresh_pain_attributes()
	SEND_SIGNAL(parent, COMSIG_CARBON_PAIN_GAINED, affected_part, amount, dam_type)
	COOLDOWN_START(src, time_since_last_pain_loss, 60 SECONDS)
	if(amount > 20)
		if(prob(33))
			parent.pain_emote("scream", 5 SECONDS)
		parent.flash_pain_overlay(2)

	else if(amount > 12)
		if(prob(33))
			parent.pain_emote(pick("wince", "gasp", "grimace", "inhale_s", "exhale_s", "flinch"), 3 SECONDS)
		parent.flash_pain_overlay(1)


/**
 * Called when pain is lost, if the mob did not lose pain in the last 60 seconds.
 * Calls [affected_part]'s [on_lose_pain_effects] proc with arguments [amount].
 *
 * * affected_part - the bodypart that lost pain
 * * amount - amount of pain that was lost
 */
/datum/pain/proc/on_pain_loss(obj/item/bodypart/affected_part, amount, type)
	affected_part.on_lose_pain_effects(amount)
	refresh_pain_attributes()
	SEND_SIGNAL(parent, COMSIG_CARBON_PAIN_LOST, affected_part, amount, type)

/// Hooks into [apply_damage] to apply pain to the parent based on incoming damage.
/datum/pain/proc/add_damage_pain(
	mob/living/carbon/source,
	damage,
	damagetype,
	def_zone,
	blocked = 0,
	wound_bonus = 0,
	bare_wound_bonus = 0,
	sharpness = NONE,
	attack_direction,
	obj/item/attacking_item,
)

	SIGNAL_HANDLER

	if(damage < 2.5 || (parent.status_flags & GODMODE))
		return
	if(isbodypart(def_zone))
		var/obj/item/bodypart/targeted_part = def_zone
		def_zone = targeted_part.body_zone
	else
		def_zone = check_zone(def_zone)

	var/pain = damage * (sharpness ? 1.15 : 1)
	switch(parent.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			pain *= 0.5
		if(DEAD)
			pain *= 0.1
	switch(damagetype)
		// Brute pain is dealt to the target zone
		// pain is just divided by a random number, for variance
		if(BRUTE)
			pain *= pick(0.75, 0.8, 0.85, 0.9)

		// Burn pain is dealt to the target zone
		// pain is lower for weaker burns, but scales up for more damaging burns
		if(BURN)
			switch(damage)
				if(1 to 9)
					pain *= 0.4
				if(10 to 19)
					pain *= 0.6
				// if(20 to INFINITY)
				// 	pass()

		// Toxins pain is dealt to the chest (stomach and liver)
		// Note: 99% of sources of toxdamage is done through adjusttoxloss, and as such doesn't go through this
		if(TOX)
			if(HAS_TRAIT(parent, TRAIT_TOXINLOVER) || HAS_TRAIT(parent, TRAIT_TOXIMMUNE))
				return
			def_zone = BODY_ZONE_CHEST

		// Oxyloss is painless. Drift into the void
		if(OXY)
			return

		// Should be obvious
		if(STAMINA, PAIN)
			return

		// Head pain causes brain damage, so brain damage causes no pain (to prevent death spirals)
		if(BRAIN)
			return

		else
			stack_trace("Pain datum recieved damage of unknown type [damagetype]")

	if(!def_zone || !pain)
#ifdef PAIN_DEBUG
		if(print_debug_messages)
			testing("PAIN DEBUG: [parent] recieved damage but no pain. ([def_zone ? "Nullified to [pain]" : "No def zone"])")
#endif
		return

#ifdef PAIN_DEBUG
	if(print_debug_messages)
		testing("PAIN DEBUG: [parent] is recieving [pain] of type [damagetype] to the [parse_zone(def_zone)]. (Original amount: [damage])")
#endif

	adjust_bodypart_pain(def_zone, pain, damagetype)

/// Gaining a wound applies a flat amount of pain based on severity.
/datum/pain/proc/add_wound_pain(mob/living/carbon/source, datum/wound/applied_wound, obj/item/bodypart/wounded_limb)
	SIGNAL_HANDLER

#ifdef PAIN_DEBUG
	if(print_debug_messages)
		testing("PAIN DEBUG: [parent] is recieving a wound of level [applied_wound.severity] to the [parse_zone(wounded_limb.body_zone)].")
#endif

	adjust_bodypart_min_pain(wounded_limb.body_zone, initial(applied_wound.severity) * 5)
	adjust_bodypart_pain(wounded_limb.body_zone, (applied_wound.severity) * 7.5)

/// Removes pain when a wound is healed.
/datum/pain/proc/remove_wound_pain(mob/living/carbon/source, datum/wound/removed_wound, obj/item/bodypart/wounded_limb)
	SIGNAL_HANDLER

	adjust_bodypart_min_pain(wounded_limb.body_zone, initial(removed_wound.severity) * - 5)
	adjust_bodypart_pain(wounded_limb.body_zone, initial(removed_wound.severity) * - 5)

/datum/pain/process(seconds_per_tick)
	if(parent.stat == DEAD)
		stack_trace("Pain datum tried to process a dead mob, it should have been stopped!")
		return PROCESS_KILL

	if(HAS_TRAIT(parent, TRAIT_STASIS))
		// you can just ignore everything if you're in stasis
		// this means no decay, no shock, and also no sad
		// future idea: keep building up shock and apply it all at once when you leave stasis
		// this is a horrible idea to do with pain in general but for shock, maybe fun.
		return

	var/has_pain = FALSE
	var/just_cant_feel_anything = !CAN_FEEL_PAIN(parent)
	var/no_recent_pain = COOLDOWN_FINISHED(src, time_since_last_pain_loss)
	for(var/part in shuffle(body_zones))
		var/obj/item/bodypart/checked_bodypart = body_zones[part]
		if(checked_bodypart.pain <= 0)
			continue
		has_pain = TRUE
		// IF we are KO'd we don't feel specific pain
		if(HAS_TRAIT(parent, TRAIT_KNOCKEDOUT))
			if(has_pain)
				break
			continue
		if(just_cant_feel_anything || !COOLDOWN_FINISHED(src, time_since_last_pain_message))
			continue
		// 1% chance per 8 pain being experienced to get a feedback message every second
		if(!SPT_PROB(checked_bodypart.get_modified_pain() / 8, seconds_per_tick))
			continue
		if(checked_bodypart.pain_feedback(seconds_per_tick, no_recent_pain))
			COOLDOWN_START(src, time_since_last_pain_message, rand(8 SECONDS, 12 SECONDS))

	if(!has_pain && traumatic_shock <= 0)
		// no-op if none of our bodyparts are in pain and we're not building up shock
		return

	var/shock_mod = 1
	if(HAS_TRAIT(parent, TRAIT_ABATES_SHOCK))
		shock_mod *= 0.5
	if(parent.health > 0)
		shock_mod *= 0.25
	if(parent.health <= parent.maxHealth * -2 || (!HAS_TRAIT(parent, TRAIT_NOBLOOD) && parent.blood_volume < BLOOD_VOLUME_BAD))
		shock_mod *= 2
	if(parent.health <= parent.maxHealth * -4 || (!HAS_TRAIT(parent, TRAIT_NOBLOOD) && parent.blood_volume < BLOOD_VOLUME_SURVIVE))
		shock_mod *= 3 // stacks with above
	var/curr_pain = get_total_pain()
	if(curr_pain < 25)
		parent.adjust_traumatic_shock(-3 * seconds_per_tick)
	else if(curr_pain < 50)
		parent.adjust_traumatic_shock(-1 * seconds_per_tick)
	else if(curr_pain < 100)
		if(traumatic_shock <= SHOCK_DANGER_THRESHOLD || parent.consciousness <= 50)
			parent.adjust_traumatic_shock(0.5 * shock_mod * seconds_per_tick)
	else if(curr_pain < 200)
		parent.adjust_traumatic_shock(1 * shock_mod * seconds_per_tick)
		if(SPT_PROB(2, seconds_per_tick))
			do_pain_message(span_bolddanger(pick("It hurts.", "You really need some painkillers.")))
	else
		parent.adjust_traumatic_shock(clamp(round(0.5 * (curr_pain / 100), 0.1), 1.5, 8) * shock_mod * seconds_per_tick)
		if(SPT_PROB(2, seconds_per_tick))
			do_pain_message(span_userdanger(pick("Stop the pain!", "It hurts!", "You need painkillers now!")))

	if((traumatic_shock >= 20 || curr_pain >= 50) && !just_cant_feel_anything)
		if(SPT_PROB(min(curr_pain / 5, 24), seconds_per_tick))
			parent.adjust_jitter_up_to(5 SECONDS * pain_modifier, 30 SECONDS)
		if(SPT_PROB(min(curr_pain / 5, 24), seconds_per_tick))
			parent.adjust_eye_blur_up_to(5 SECONDS * pain_modifier, 30 SECONDS)
		if(SPT_PROB(min(curr_pain / 10, 12), seconds_per_tick))
			parent.adjust_dizzy_up_to(5 SECONDS * pain_modifier, 30 SECONDS)
		if(SPT_PROB(min(curr_pain / 20, 6), seconds_per_tick)) // pain applies its own stutter
			parent.adjust_stutter_up_to(5 SECONDS * pain_modifier, 30 SECONDS)

	if((traumatic_shock >= 40 || curr_pain >= 80) && parent.stat != HARD_CRIT)
		if(SPT_PROB(traumatic_shock / 60, seconds_per_tick))
			//parent.vomit(VOMIT_CATEGORY_KNOCKDOWN, lost_nutrition = 7.5)
			parent.Knockdown(rand(3 SECONDS, 6 SECONDS))

	if((traumatic_shock >= 60 || curr_pain >= 100) && parent.stat != HARD_CRIT)
		if(SPT_PROB(max(traumatic_shock / 20, 2), seconds_per_tick))
			if(!parent.IsParalyzed() && parent.Paralyze(rand(2 SECONDS, 8 SECONDS)))
				parent.visible_message(
					span_warning("[parent]'s body falls limp!"),
					span_warning("Your body [just_cant_feel_anything ? "goes" : "falls"] limp!"),
					visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				)
		if(SPT_PROB(max(traumatic_shock / 20, 3), seconds_per_tick))
			parent.adjust_confusion_up_to(8 SECONDS * pain_modifier, 24 SECONDS)

	if(traumatic_shock >= SHOCK_DANGER_THRESHOLD || curr_pain >= 150)
		if(SPT_PROB(max(traumatic_shock / 30, 4), seconds_per_tick))
			parent.losebreath += 1

	if((traumatic_shock >= SHOCK_HEART_ATTACK_THRESHOLD || curr_pain >= 200) && SPT_PROB(max(traumatic_shock / 40, 1), seconds_per_tick) && parent.stat != HARD_CRIT)
		if(!parent.IsUnconscious() && parent.Unconscious(rand(4 SECONDS, 16 SECONDS)))
			parent.visible_message(
				span_warning("[parent] falls unconscious!"),
				span_warning(pick("You black out!", "You feel like you're about to die!", "You lose consciousness!")),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			)

	// This is death
	if(traumatic_shock >= SHOCK_HEART_ATTACK_THRESHOLD && !parent.undergoing_cardiac_arrest())
		var/heart_attack_prob = 0
		if(parent.health <= parent.maxHealth * -1)
			heart_attack_prob += abs(parent.health + parent.maxHealth) * 0.1
		if(traumatic_shock >= 180)
			heart_attack_prob += (traumatic_shock * 0.1)
		if(SPT_PROB(min(20, heart_attack_prob), seconds_per_tick))
			if(!COOLDOWN_FINISHED(src, time_since_last_heart_attack_counter))
				parent.losebreath += 1
			else if(!parent.can_heartattack())
				parent.losebreath += 4
			else if(heart_attack_counter >= 3)
				to_chat(parent, span_userdanger("Your heart stops!"))
				if(!parent.incapacitated())
					parent.visible_message(span_danger("[parent] grabs at [parent.p_their()] chest!"), ignored_mobs = parent)
				parent.set_heartattack(TRUE)
				heart_attack_counter = -2
			else
				COOLDOWN_START(src, time_since_last_heart_attack_counter, 6 SECONDS)
				parent.losebreath += 1
				parent.playsound_local(get_turf(parent), 'sound/effects/singlebeat.ogg', 40, 1, use_reverb = FALSE)
				heart_attack_counter += 1
				switch(heart_attack_counter)
					if(-INFINITY to 0)
						pass()
					if(1)
						to_chat(parent, span_userdanger("You feel your heart beat irregularly."))
					if(2)
						to_chat(parent, span_userdanger("You feel your heart skip a beat."))
					else
						to_chat(parent, span_userdanger("You feel your body shutting down!"))
	else
		heart_attack_counter = 0

	if(traumatic_shock >= SHOCK_CRIT_THRESHOLD || curr_pain >= PAIN_CRIT_THRESOLD)
		parent.adjust_jitter_up_to(5 SECONDS * pain_modifier, 120 SECONDS)

	parent.paincrit_check()

	// Finally, handle pain decay over time
	if(parent.on_fire)
		// No decay if you're burning (because you'll be gaining pain constantly anyways)
		return

	if(COOLDOWN_FINISHED(src, time_since_last_pain_loss) && parent.stat == CONSCIOUS)
		natural_pain_decay = max(natural_pain_decay + (base_pain_decay * 0.05), natural_pain_decay * 3)
	else
		natural_pain_decay = base_pain_decay

	adjust_bodypart_pain(BODY_ZONES_ALL, natural_pain_decay)

/// Affect accuracy of fired guns while in pain.
/datum/pain/proc/on_mob_fired_gun(mob/living/carbon/human/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	var/obj/item/bodypart/shooting_with = user.get_active_hand()
	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)

	var/penalty = 0
	// Basically averaging the pain of the shooting hand, chest, and head, with the hand being weighted more
	penalty += shooting_with?.get_modified_pain()
	penalty += chest?.get_modified_pain() * 0.5
	penalty += head?.get_modified_pain() * 0.5
	penalty /= 3
	// Applying min and max
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] += floor(penalty / 3)
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += floor(penalty)

/// Apply or remove pain various modifiers from pain (mood, action speed, movement speed) based on the [average_pain].
/datum/pain/proc/refresh_pain_attributes(...)
	SIGNAL_HANDLER

	var/pain = get_total_pain()
	if(parent.stat == DEAD)
		pain *= 0.1
	// Consciousness penalty from pain is unnaffected by pain modifier
	if(pain <= 25)
		parent.remove_consciousness_modifier(PAIN)
	else
		parent.add_consciousness_modifier(PAIN, round(-0.33 * (pain ** 0.75)), 0.01)
	// Buuut the other modifiers aren't
	pain *= pain_modifier

	switch(pain)
		if(0 to 25)
			parent.remove_surgery_speed_mod(PAIN)
			parent.outgoing_damage_mod = initial(parent.outgoing_damage_mod)
			parent.remove_movespeed_modifier(MOVESPEED_ID_PAIN)
			parent.remove_actionspeed_modifier(ACTIONSPEED_ID_PAIN)
			parent.clear_mood_event(PAIN)
		if(25 to 75)
			parent.add_surgery_speed_mod(PAIN, 1.1)
			parent.outgoing_damage_mod = 0.9
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/light)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/light)
			parent.add_mood_event(PAIN, /datum/mood_event/light_pain)
		if(75 to 125)
			parent.add_surgery_speed_mod(PAIN, 1.25)
			parent.outgoing_damage_mod = 0.75
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/medium)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/medium)
			parent.add_mood_event(PAIN, /datum/mood_event/med_pain)
		if(125 to 175)
			parent.add_surgery_speed_mod(PAIN, 1.4)
			parent.outgoing_damage_mod = 0.6
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/heavy)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/heavy)
			parent.add_mood_event(PAIN, /datum/mood_event/heavy_pain)
		if(225 to INFINITY)
			parent.add_surgery_speed_mod(PAIN, 1.5)
			parent.outgoing_damage_mod = 0.5
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/crippling)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/crippling)
			parent.add_mood_event(PAIN, /datum/mood_event/crippling_pain)

/**
 * Run a pain related emote, if a few checks are successful.
 *
 * Comes with defaults so you can just call it straight up to do a random emote
 *
 * * emote - string, what emote we're running
 * * cooldown - what cooldown to set our emote cooldown to
 *
 * Returns TRUE if successful.
 * Returns FALSE if we failed to send an emote.
 */
/datum/pain/proc/do_pain_emote(emote = pick(PAIN_EMOTES), cooldown = 3 SECONDS)
	ASSERT(istext(emote))
	if(!CAN_FEEL_PAIN(parent))
		return FALSE
	if(cooldown && !COOLDOWN_FINISHED(src, time_since_last_pain_message))
		return FALSE
	if(parent.stat >= UNCONSCIOUS || parent.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		return FALSE

	INVOKE_ASYNC(parent, TYPE_PROC_REF(/mob, emote), emote)
	COOLDOWN_START(src, time_since_last_pain_message, cooldown)
	return TRUE

/**
 * Run a pain related message, if a few checks are successful.
 *
 * * message - string, what message we're sending
 * * painless_message - optional string, what message we're sending if the mob doesn't "feel" pain
 * * cooldown - what cooldown to set our message cooldown to
 *
 * Returns TRUE if successful.
 * Returns FALSE if we failed to send a message, even if painless_message was provided and sent.
 */
/datum/pain/proc/do_pain_message(message, painless_message, cooldown = 0 SECONDS)
	ASSERT(istext(message))
	if(!CAN_FEEL_PAIN(parent))
		if(painless_message)
			to_chat(parent, painless_message)
		return FALSE
	if(parent.stat >= UNCONSCIOUS)
		return FALSE
	if(cooldown && !COOLDOWN_FINISHED(src, time_since_last_pain_message))
		return FALSE

	to_chat(parent, message)
	COOLDOWN_START(src, time_since_last_pain_message, cooldown)
	return TRUE

/// Get the total pain of all bodyparts.
/datum/pain/proc/get_total_pain()
	var/total_pain = 0
	for(var/zone in body_zones)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[zone]
		total_pain += adjusted_bodypart.pain

	return total_pain

/// Adds a custom stammer to people under the effects of pain.
/datum/pain/proc/handle_message(datum/source, list/message_args)
	SIGNAL_HANDLER

	var/phrase = html_decode(message_args[TREAT_MESSAGE_ARG])
	if(!length(phrase))
		return

	var/num_repeats = floor(((get_total_pain() / 75) + (traumatic_shock / 75)) * pain_modifier)
	if(traumatic_shock < 90)
		num_repeats *= 0.5

	num_repeats = clamp(num_repeats, 1, 6)
	if(num_repeats <= 1)
		return
	var/static/regex/no_stammer = regex(@@[ ""''()[\]{}.!?,:;_`~-]@)
	var/static/regex/half_stammer = regex(@@[aeiouAEIOU]@)
	var/final_phrase = ""
	var/original_char = ""
	for(var/i = 1, i <= length(phrase), i += length(original_char))
		original_char = phrase[i]
		if(no_stammer.Find(original_char))
			final_phrase += original_char
			continue
		if(half_stammer.Find(original_char))
			if(num_repeats <= 2)
				final_phrase += original_char
				continue
			final_phrase += repeat_string(ceil(num_repeats / 2), original_char)
			continue
		final_phrase += repeat_string(num_repeats, original_char)

	message_args[TREAT_TTS_MESSAGE_ARG] = phrase
	message_args[TREAT_MESSAGE_ARG] = sanitize(final_phrase)

/// Remove all pain, pain paralysis, side effects, etc. from our mob after we're fully healed by something (like an adminheal)
/datum/pain/proc/remove_all_pain(datum/source, heal_flags)
	SIGNAL_HANDLER

	// Ideally pain would have its own heal flag but we live in a society
	if(!(heal_flags & (HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS)))
		return

	for(var/zone in body_zones)
		var/obj/item/bodypart/healed_bodypart = body_zones[zone]
		adjust_bodypart_min_pain(zone, -INFINITY)
		adjust_bodypart_pain(zone, -INFINITY)
		// Shouldn't be necessary but you never know!
		REMOVE_TRAIT(healed_bodypart, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)

	adjust_traumatic_shock(-INFINITY, 0)
	natural_pain_decay = base_pain_decay
	parent.paincrit_check()
	refresh_pain_attributes()

/// Determines if we should be processing or not.
/datum/pain/proc/on_parent_statchance(...)
	SIGNAL_HANDLER

	if(parent.stat == DEAD)
		if(datum_flags & DF_ISPROCESSING)
			STOP_PROCESSING(SSpain, src)
	else
		START_PROCESSING(SSpain, src)

/// When we are revived, reduced shock & pain
/datum/pain/proc/revived(...)
	SIGNAL_HANDLER

	parent.adjust_traumatic_shock(traumatic_shock * -0.66)
	for(var/zone in body_zones)
		var/obj/item/bodypart/revived_bodypart = body_zones[zone]
		parent.cause_pain(zone, revived_bodypart.pain * -0.9)

/**
 * Signal proc for [COMSIG_LIVING_HEALTHSCAN]
 * Reports how much pain [parent] is sustaining to [user].
 *
 * Note, this report is relatively vague intentionally -
 * rather than sending a detailed report of which bodyparts are in pain and how much,
 * the patient is encouraged to elaborate on which bodyparts hurt the most, and how much they hurt.
 *
 * (To encourage a bit more interaction between the doctors and their patients)
 */
/datum/pain/proc/on_analyzed(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(parent.stat == DEAD)
		return

	var/amount = ""
	var/pain_tip = ""

	switch(get_total_pain())
		if(10 to 50)
			amount = "minor"
			pain_tip += "Pain should subside in time."
		if(50 to 100)
			amount = "moderate"
			pain_tip += "Pain should subside in time and can be quickened with rest or painkilling medication."
		if(100 to 150)
			amount = "major"
			pain_tip += "Treat wounds and abate pain with rest, cryogenics, and painkilling medication."
		if(150 to 200)
			amount = span_bold("severe")
			pain_tip += "Treat wounds and abate pain with long rest, cryogenics, and moderate painkilling medication."
		if(200 to INFINITY)
			amount = span_bold("extreme")
			pain_tip += "Treat wounds and abate pain with long rest, cryogenics, and heavy painkilling medication."

	var/shock = ""
	var/shock_tip = ""

	switch(traumatic_shock)
		if(20 to 60)
			shock = "Warning"
			shock_tip += "Supply epinephrine and pain relief."
		if(60 to 120)
			shock = span_bold("Alert")
			shock_tip += "Supply epinephrine and immediate pain relief."
		if(120 to MAX_TRAUMATIC_SHOCK)
			shock = span_bold("Critical")
			shock_tip += "Supply epinephrine and immediate pain relief. Monitor for cardiac or respiratory arrest."

	if(!amount && !shock)
		return

	var/amount_text = ""
	if(amount)
		amount_text = span_danger("Subject is experiencing [amount] pain.")
		if(tochat && pain_tip)
			amount_text = span_tooltip(pain_tip, amount_text)

	var/shock_text = ""
	if(shock)
		shock_text = span_danger("[shock]: Traumatic shock")
		if(tochat && shock_tip)
			shock_text = span_tooltip(shock_tip, shock_text)

	render_list += "<span class='alert ml-1'>"
	if(amount_text && shock_text)
		render_list += "[shock_text] - [amount_text]"
	else
		// one of these is empty, so doesn't matter ultimately
		render_list += shock_text
		render_list += amount_text
	render_list += "</span><br>"

#ifdef PAIN_DEBUG
	debug_print_pain()
#endif

// ------ Pain debugging stuff. ------
/datum/pain/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("debug_pain", "Debug Pain")
	VV_DROPDOWN_OPTION("set_limb_pain", "Adjust Limb Pain")
	VV_DROPDOWN_OPTION("refresh_mod", "Refresh Pain Mod")

/datum/pain/vv_do_topic(list/href_list)
	. = ..()
	if(href_list["debug_pain"])
		debug_print_pain()
	if(href_list["set_limb_pain"])
		admin_adjust_bodypart_pain()
	if(href_list["refresh_mod"])
		update_pain_modifier()

/datum/pain/proc/debug_print_pain()

	var/list/final_print = list()
	final_print += "<div class='examine_block'><span class='info'>DEBUG PRINTOUT PAIN: [REF(src)]"
	final_print += "[parent] has a total pain of [get_total_pain()]."
	final_print += "[parent] has a traumatic shock of [traumatic_shock]."
	final_print += "[parent] has a pain modifier of [pain_modifier]."
	final_print += " - - - - "
	final_print += "[parent] bodypart printout: (min / current)"
	for(var/part in body_zones)
		var/obj/item/bodypart/checked_bodypart = body_zones[part]
		final_print += "[checked_bodypart.name]: [checked_bodypart.min_pain] / [checked_bodypart.pain]"

	final_print += " - - - - "
	final_print += "[parent] pain modifier printout:"
	for(var/mod in pain_mods)
		final_print += "[mod]: [pain_mods[mod]]"

	final_print += "</span></div>"
	to_chat(usr, final_print.Join("\n"))

/datum/pain/proc/admin_adjust_bodypart_pain()
	var/zone = input(usr, "Which bodypart") as null|anything in BODY_ZONES_ALL + "All"
	var/amount = input(usr, "How much?") as null|num

	if(isnull(amount) || isnull(zone))
		return
	if(zone == "All")
		zone = BODY_ZONES_ALL

	amount = clamp(amount, -200, 200)
	adjust_bodypart_pain(zone, amount)
