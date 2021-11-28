/datum/action/item_action/cult/clock_spell/teleport // Must be cast with a slab, stronger.
	name = "Slab: Teleport"
	desc = "Empowers the slab to teleport you and anyone who you are dragging to a sigil of teleportation."
	examine_hint = "use on yourself to teleport you, and anyone who you are dragging, to a target sigil of teleportation."
	button_icon_state = "teleport"
	invocation = "Trg Zr Gur'er!"
	manually_handle_charges = TRUE

/datum/action/item_action/cult/clock_spell/teleport/do_hit_spell_effects(mob/living/victim, mob/living/user)
	to_chat(user, span_brasstalics("This spell must be invoked upon yourself - anyone you are dragging will teleport with you."))
	return TRUE

/datum/action/item_action/cult/clock_spell/teleport/do_self_spell_effects(mob/living/user)
	var/list/potential_runes = list()
	var/list/teleport_names = list()
	for(var/obj/effect/rune/teleport/teleport_rune as anything in GLOB.teleport_runes)
		potential_runes[avoid_assoc_duplicate_keys(teleport_rune.listkey, teleport_names)] = teleport_rune

	if(!potential_runes.len)
		to_chat(user, span_warning("There are no valid sigils to teleport to!"))
		return TRUE

	var/turf/our_turf = get_turf(user)
	if(is_away_level(our_turf.z))
		to_chat(user, span_cultitalic("You are not in the right dimension!"))
		return TRUE

	INVOKE_ASYNC(src, .proc/try_teleport, potential_runes, user)
	return TRUE

/datum/action/item_action/cult/clock_spell/teleport/proc/try_teleport(list/potential_runes, mob/living/user)
	var/input_rune_key = input(user, "Choose a sigil to teleport to.", "Sigil to Teleport to") as null|anything in potential_runes
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key]
	if(!actual_selected_rune || !can_teleport(user))
		return

	var/turf/dest = get_turf(actual_selected_rune)
	if(dest.is_blocked_turf(TRUE))
		to_chat(user, span_warning("The target rune is blocked. You cannot teleport there."))
		return

	var/teleport_time = 2.5 SECONDS
	if(user.pulling)
		if(isliving(user.pulling))
			teleport_time *= 2
		else
			user.stop_pulling()

	if(!do_after(user, teleport_time, extra_checks = CALLBACK(src, .proc/can_teleport, user)))
		return

	if(!can_teleport(user))
		return

	do_the_teleport(dest, user)

/datum/action/item_action/cult/clock_spell/teleport/proc/do_the_teleport(turf/target_turf, mob/living/user)
	user.whisper(invocation, language = /datum/language/common, forced = "cult invocation")
	var/turf/origin = get_turf(user)
	var/mob/living/brought_along
	var/pulled_tp_result = FALSE
	if(isliving(user.pulling))
		brought_along = user.pulling

	if(!do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_CULT))
		to_chat(user, span_warning("Your teleport fails, leaving you where you began!"))
		return

	if(brought_along)
		pulled_tp_result = do_teleport(brought_along, target_turf, channel = TELEPORT_CHANNEL_CULT)

	origin.visible_message(
		span_warning("[target] glows in [user]'s hand, and [user.p_they()] disappear[user.p_s()] with a ring[pulled_tp_result ? " - [brought_along] nowhere to be seen":""]!"),
		null,
		span_hear("You hear a ring.")
		)
	target_turf.visible_message(
		span_warning("There is a boom of outrushing air as something appears above the rune!"),
		null,
		span_hear("You hear a whoosh.")
		)

	if(pulled_tp_result)
		user.start_pulling(brought_along, supress_message = TRUE)

	playsound(origin, 'sound/magic/teleport_diss.ogg', 50, TRUE)
	playsound(target_turf, 'sound/magic/teleport_app.ogg', 50, TRUE)
	to_chat(user, span_brasstalics("[target] glows in a flash of yellow as you speak the invocation, and you appear somewhere else!"))
	if(pulled_tp_result)
		to_chat(brought_along, span_warning("You suddenly appear somewhere else in a flash of yellow!"))

	if(--charges <= 0)
		qdel(src)
		return

/datum/action/item_action/cult/clock_spell/teleport/proc/can_teleport(mob/living/user)
	if(QDELETED(src) || !user || !IS_CULTIST(user) || !user.is_holding(target) || user.incapacitated())
		return FALSE
	return TRUE

/datum/action/innate/cult/clock_spell/abscond // Can be cast without a slab, weaker.
	name = "Abscond"
	desc = "Allows you to instantly teleport to a random sigil of teleportation without needing a slab."
	button_icon_state = "abscond"
	invocation = "Rrg Zr Nj'nl!"

/datum/action/innate/cult/clock_spell/abscond/Activate()
	if(!isliving(owner))
		return

	var/mob/living/user = owner
	if(!LAZYLEN(GLOB.teleport_runes))
		to_chat(user, span_warning("There are no valid sigils to abscond to!"))
		return

	var/obj/effect/rune/teleport/picked_rune
	var/turf/dest
	var/max_chances = LAZYLEN(GLOB.teleport_runes) * 2
	var/chance_num = 0
	while(!dest && chance_num++ <= max_chances)
		picked_rune = pick(GLOB.teleport_runes)
		dest = get_turf(picked_rune)
		if(dest.is_blocked_turf(TRUE))
			dest = null

	if(!dest)
		to_chat(user, span_warning("There are no valid sigils to abscond to!"))
		return

	user.whisper(invocation, language = /datum/language/common, forced = "cult invocation")

	var/turf/origin = get_turf(user)
	if(!do_teleport(user, dest, channel = TELEPORT_CHANNEL_CULT))
		to_chat(user, span_warning("Your abscond fails, leaving you where you began!"))
		return

	origin.visible_message(span_warning("[user]'s snaps their fingers as [user.p_they()] disappear[user.p_s()] suddenly in a purple flash!"))
	dest.visible_message(
		span_warning("There is a boom of outrushing air as something appears above the rune!"),
		null,
		span_hear("You hear a whoosh.")
		)

	playsound(origin, 'sound/magic/teleport_diss.ogg', 50, TRUE)
	playsound(dest, 'sound/magic/teleport_app.ogg', 50, TRUE)
	to_chat(user, span_brasstalics("You glow in a brilliant purple light as you suddenly appear on the [picked_rune.listkey] sigil!"))
	if(ishuman(user))
		to_chat(user, span_warning("You feel unwell after invoking [name]..."))
		var/mob/living/carbon/human/human_user = user
		human_user.cause_pain(BODY_ZONES_ALL, 20)
		human_user.adjust_disgust(33)
		human_user.dizziness += 15
		human_user.stuttering += 15
		human_user.Jitter(20)

	if(--charges <= 0)
		qdel(src)
