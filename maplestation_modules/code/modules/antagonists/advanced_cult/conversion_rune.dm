/obj/effect/rune/conversion
	/// Message displayed to someone in big, bold text when they're converted.
	var/on_conversion_message
	/// A list of invocations required if the user has conversion disbaled and use this rune.
	var/list/conversion_unallowed_invocations
	/// A list of invocations if the victim is mindshileded or holy and cannot be converted.
	var/list/conversion_blocked_invocations
	/// A list of invoctions if the victim can be converted.
	var/list/conversion_success_invocations

/obj/effect/rune/conversion/invoke(list/invokers)
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		to_chat(user, span_warning("The [cultist_name] is currently in use!"))
		return

	var/list/myriad_targets = list()
	for(var/mob/living/potential_convertee in get_turf(src))
		if(IS_CULTIST(potential_convertee))
			continue

		myriad_targets |= potential_convertee

	if(!myriad_targets.len)
		fail_invoke()
		return

	visible_message(span_warning("[src] pulses a mesmerizing shade!"))
	var/mob/living/convertee = pick(myriad_targets)

	INVOKE_ASYNC(src, PROC_REF(invoke_wrapper), convertee, user)

	. = ..()

/**
 * Wraps [invoke_process] to ensure [var/rune_in_use] is properly set.
 */
/obj/effect/rune/conversion/proc/invoke_wrapper(mob/living/convertee, mob/living/user)
	rune_in_use = TRUE
	invoke_process(convertee, user)
	rune_in_use = FALSE

/**
 * The actual process of invoking the rune on [convertee] by [user]. Sleeps.
 */
/obj/effect/rune/conversion/proc/invoke_process(mob/living/convertee, mob/living/user)
	var/datum/antagonist/advanced_cult/cultist = user.mind.has_antag_datum(/datum/antagonist/advanced_cult, TRUE)
	var/datum/team/advanced_cult/cult_team = cultist?.get_team()
	if(!cultist || !cult_team)
		stack_trace("[user] attempted to convert someone to their cult, but had no [cultist ? "cult team":"cult antag datum"]!")
		to_chat(user, span_warning("For some reason or another, you could not begin to invoke the [cultist_name]. Contact your local god!"))
		return

	var/can_we_convert = cult_team.can_join_cult(convertee)
	switch(can_we_convert)
		if(CONVERSION_NOT_ALLOWED)
			if(!invoke_do_afters(convertee, user, conversion_unallowed_invocations))
				return FALSE

			do_torment(convertee, user, protected = can_we_convert)

		if(CONVERSION_MINDSHIELDED, CONVERSION_HOLY)
			if(!invoke_do_afters(convertee, user, conversion_blocked_invocations))
				return FALSE

			do_torment(convertee, user, protected = can_we_convert)

		if(CONVERSION_SUCCESS)
			if(!invoke_do_afters(convertee, user, conversion_success_invocations))
				return FALSE

			do_convert(convertee, user, cult_team)

	return TRUE

/**
 * Causes multiple do_afters, similar to how changeling absorbing works,
 * based on the length of the invocations list passed into it.
 *
 * Duration = 6 seconds * length of invocations.
 */
/obj/effect/rune/conversion/proc/invoke_do_afters(mob/living/convertee, mob/living/user, list/invocations)
	if(!LAZYLEN(invocations))
		fail_invoke()
		return FALSE

	for(var/i in 1 to invocations.len)
		if(!do_after(user, 6 SECONDS, convertee))
			fail_invoke()
			return FALSE

		if(QDELETED(user) || QDELETED(convertee) || QDELETED(src))
			return FALSE

		if(!IS_CULTIST(user) || !user.Adjacent(src) || !(convertee in get_turf(src)))
			fail_invoke()
			return FALSE

		if(convertee.can_block_magic())
			fail_invoke()
			return FALSE

		if(convertee.getStaminaLoss() <= 100)
			convertee.apply_damage(50, PAIN, BODY_ZONE_CHEST)
		convertee.adjust_stutter(20 SECONDS)
		user.say(invocations[i], language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")

	return TRUE

/**
 * Actually convert [convertee] to [cult] by [user].
 */
/obj/effect/rune/conversion/proc/do_convert(mob/living/convertee, mob/living/user, datum/team/advanced_cult/cult)
	if(!cult)
		CRASH("[type] - do_convert attempted without a destination cult team!")

	if(cult.can_join_cult(convertee) != CONVERSION_SUCCESS)
		return FALSE

	convertee.heal_and_revive(50, span_warning("[convertee] writhes in pain as the sigil below [convertee.p_them()] flashes!"))
	to_chat(convertee, cult.team_theme.our_cult_span("AAAAAAAAAAAAAA-", bold = TRUE))

	var/datum/antagonist/advanced_cult/new_cultist = convertee.mind.add_antag_datum(/datum/antagonist/advanced_cult/convertee)
	if(!new_cultist)
		CRASH("[type] - do_convert failed to add an antag datum onto [convertee.mind]!")

	new_cultist.team = cult
	new_cultist.cultist_style = cult.team_theme
	new_cultist.finalize_antag()

	convertee.Unconscious(10 SECONDS)
	to_chat(convertee, cult.team_theme.our_cult_span(on_conversion_message, TRUE, TRUE, TRUE))
	to_chat(convertee, cult.team_theme.our_cult_span("Assist your new compatriots in their unceasing work. Your goal is their's, and their goals are your's. [cult.original_cultist] is your leader, seek guidance from them.", italics = TRUE))
	if(ishuman(convertee))
		var/mob/living/carbon/human/human_convertee = convertee
		human_convertee.uncuff()
		human_convertee.remove_status_effect(/datum/status_effect/speech/stutter)
		human_convertee.remove_status_effect(/datum/status_effect/speech/slurring/cult)

	return TRUE

/**
 * For when [user] has conversion disabled, or [convertee] is a protected role, such as chaplain or mindshielded.
 * Protected is a return value, from can_join_cult(). Will be 0, 1, or 2. see antag_defines.dm for more informaiton.
 *
 * Causes the [convertee] to experience some kind of discomfort.
 * Ideally, enough such that they will be out of the cultist's business for a while,
 * but not enough such that they're effectively removed from the round.
 */
/obj/effect/rune/conversion/proc/do_torment(mob/living/convertee, mob/living/user, protected)
	if(protected)
		var/obj/item/implant/mindshield/their_shield = locate(/obj/item/implant/mindshield) in convertee
		if(their_shield)
			qdel(their_shield)

		convertee.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70, 100)
		if(protected == CONVERSION_HOLY)
			to_chat(convertee, span_userdanger("Your faith protects you, but you begin falter as unnatural forces invade your mind!"))
		else
			to_chat(convertee, span_userdanger("Your mindshield protects you, but begins to lose strength as unnatural forces invade your mind!"))

	else
		convertee.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100, 150)
		to_chat(convertee, span_userdanger("An unnatural force begins to invade your mind!"))

	convertee.do_jitter_animation(100)
	if(iscarbon(convertee))
		var/mob/living/carbon/carbon_convertee = convertee
		carbon_convertee.gain_trauma(/datum/brain_trauma/hypnosis, TRAUMA_LIMIT_LOBOTOMY, "There are forces beyond my understanding at play...")

	if(ishuman(convertee))
		var/mob/living/carbon/human/human_convertee = convertee
		if(!protected)
			human_convertee.adjust_traumatic_shock(SHOCK_HEART_ATTACK_THRESHOLD)
		human_convertee.cause_pain(BODY_ZONES_ALL, 65)

	ADD_TRAIT(convertee, TRAIT_WAS_ON_CONVERSION_RUNE, REF(user))
