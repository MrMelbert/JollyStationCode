/// Number of "beats" per CPR cycle
/// This corresponds to N - 1 compressions and 1 breath
#define BEATS_PER_CPR_CYCLE 16
// Also I'm kinda cheating here because we do 15 compressions to 1 breath rather than 30 compressions to 2 breaths
// But it's close enough to the real thing (ratio wise) that I'm OK with it

/mob/living/carbon/human/proc/cpr_process(mob/living/carbon/human/target, beat = 0, panicking = FALSE)
	set waitfor = FALSE

	if(get_active_held_item() || get_inactive_held_item() || usable_hands <= 0)
		to_chat(src, span_warning("Your hands are full, you can't perform CPR!"))
		return

	var/cpr_certified = HAS_TRAIT(src, TRAIT_CPR_CERTIFIED)
	if(!panicking && target.stat != CONSCIOUS && beat >= BEATS_PER_CPR_CYCLE + 1)
		to_chat(src, span_warning("[target] still has no pulse[cpr_certified ? " - you pick up the pace." : "! You try harder!"]"))
		panicking = TRUE

	var/doafter_mod = panicking ? 0.5 : 1
	var/doing_a_breath = FALSE
	if(beat % BEATS_PER_CPR_CYCLE == 0 || beat == 1)
		if (is_mouth_covered())
			to_chat(src, span_warning("Your mouth is covered, so you can only perform compressions!"))

		else if (target.is_mouth_covered())
			to_chat(src, span_warning("[p_Their()] mouth is covered, so you can only perform compressions!"))

		else if (!get_organ_slot(ORGAN_SLOT_LUNGS))
			to_chat(src, span_warning("You have no lungs to breathe with, so you can only perform compressions!"))

		else if (HAS_TRAIT(src, TRAIT_NOBREATH))
			to_chat(src, span_warning("You do not breathe, so you can only perform compressions!"))

		else
			doing_a_breath = TRUE

	if(doing_a_breath)
		visible_message(
			span_notice("[src] attempts to give [target.name] a rescue breath!"),
			span_notice("You attempt to give [target.name] a rescue breath as a part of CPR... Hold still!"),
		)
		if(target.stat == DEAD)
			to_chat(src, span_warning("[target.p_Their()] mouth feels cold to the touch..."))
		else if(!target.undergoing_cardiac_arrest())
			to_chat(src, span_notice("You feel a pulse!"))

		if(!do_after(user = src, delay = doafter_mod * 6 SECONDS, target = target))
			return

		add_mood_event("saved_life", /datum/mood_event/saved_life)
		visible_message(
			span_notice("[src] delivers a rescue breath to [target.name]!"),
			span_notice("You deliver a rescue breath to [target.name]."),
		)

	else
		var/is_first_compression = beat % BEATS_PER_CPR_CYCLE == 1
		if(is_first_compression)
			visible_message(
				span_notice("[src] attempts to give [target.name] chest compressions!"),
				span_notice("You try to perform chest compressions as a part of CPR on [target.name]... Hold still!"),
			)

		if(!do_after(user = src, delay = doafter_mod * 1 SECONDS, target = target))
			return

		if(is_first_compression)
			visible_message(
				span_notice("[src] delivers chest compressions on [target.name]!"),
				span_notice("You deliver chest compressions on [target.name]."),
			)

		target.apply_status_effect(/datum/status_effect/cpr_applied)
		// compressions help a little bit with oxyloss, to simulate blood flow returning to your body
		target.adjustOxyLoss(-0.5 * (cpr_certified ? 2 : 1))

	if(doing_a_breath)
		if(HAS_TRAIT(target, TRAIT_NOBREATH))
			to_chat(target, span_unconscious("You feel a breath of fresh air... which is a sensation you don't recognise..."))
		else if (!target.get_organ_slot(ORGAN_SLOT_LUNGS))
			to_chat(target, span_unconscious("You feel a breath of fresh air... but you don't feel any better..."))
		else if(cpr_certified)
			target.adjustOxyLoss(-18)
			to_chat(target, span_unconscious("You feel a breath of fresh air enter your lungs... It feels good..."))
		else
			// but breaths are where the real oxyloss is healed
			target.adjustOxyLoss(-12)
			to_chat(target, span_unconscious("You feel a breath of fresh air enter your lungs..."))

		// Breath relieves some of the pressure on the chest
		var/obj/item/bodypart/chest/chest = target.get_bodypart(BODY_ZONE_CHEST)
		if(IS_ORGANIC_LIMB(chest))
			to_chat(target, span_notice("You feel the pressure on your chest ease!"))
			chest.heal_damage(brute = 3)
			target.cause_pain(BODY_ZONE_CHEST, -3)

		log_combat(src, target, "CPRed", addition = "(breath)")

	else if(beat % (BEATS_PER_CPR_CYCLE / 4) == 0 && panicking)
		var/obj/item/bodypart/chest/chest = target.get_bodypart(BODY_ZONE_CHEST)
		if(IS_ORGANIC_LIMB(chest))
			var/critical_success = prob(1) && target.undergoing_cardiac_arrest()
			if(!cpr_certified)
				// Apply damage directly to chest. I would use apply damage but I can't, kinda
				if(critical_success)
					target.set_heartattack(FALSE)
					to_chat(target, span_warning("You feel immense pressure on your chest, and a sudden wave of pain... and then relief."))
					target.apply_damage(6, BRUTE, chest, wound_bonus = CANT_WOUND, attacking_item = "chest compressions")

				else
					to_chat(target, span_warning("You feel pressure on your chest!"))
					target.apply_damage(3, BRUTE, chest, wound_bonus = CANT_WOUND, attacking_item = "chest compressions")

				to_chat(src, span_warning("You bruise [target.name]'s chest with the pressure!"))

			else if(critical_success)
				target.set_heartattack(FALSE)
				to_chat(target, span_warning("You pressure fade away from your chest... and then relief."))
				target.cause_pain(BODY_ZONE_CHEST, 8)

		log_combat(src, target, "CPRed", addition = "(compression)")

	if(target.body_position != LYING_DOWN || !target.undergoing_cardiac_arrest())
		return

	cpr_process(target, beat + 1, panicking)

#undef BEATS_PER_CPR_CYCLE

/datum/status_effect/cpr_applied
	id = "cpr"
	alert_type = null
	duration = 1 SECONDS
	tick_interval = -1
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/cpr_applied/on_apply()
	if(!is_effective(owner))
		return FALSE
	owner.add_consciousness_modifier(id, 5)
	ADD_TRAIT(owner, TRAIT_NO_ORGAN_DECAY, id) // cycling the heart, so if they're dead, organs aren't decaying
	ADD_TRAIT(owner, TRAIT_ASSISTED_BREATHING, id)
	return TRUE

/datum/status_effect/cpr_applied/on_remove()
	owner.remove_consciousness_modifier(id)
	REMOVE_TRAIT(owner, TRAIT_NO_ORGAN_DECAY, id)
	REMOVE_TRAIT(owner, TRAIT_ASSISTED_BREATHING, id)

/datum/status_effect/cpr_applied/refresh(effect, ...)
	if(!is_effective(owner))
		return
	return ..()

/// Checks if CPR is effective against this mob
/datum/status_effect/cpr_applied/proc/is_effective(mob/checking)
	if(isnull(checking))
		return FALSE
	if(!checking.get_organ_slot(ORGAN_SLOT_HEART)) // A heart is required for CPR to pump your heart
		return FALSE
	return TRUE
