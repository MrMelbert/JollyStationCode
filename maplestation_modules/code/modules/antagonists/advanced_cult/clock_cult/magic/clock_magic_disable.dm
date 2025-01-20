/datum/action/item_action/cult/clock_spell/disable
	name = "Slab: Disable"
	desc = "Empowers the slab to disable and mute targets on hit."
	examine_hint = "deal heavy stamina damage and knock down targets hit with the slab. Non-mindshielded targets will also be silenced."
	button_icon_state = "kindle"
	invocation = "Cb'jre Bh'gntr!"
	active_overlay_name = "volt"
	active_overlay_held_name = "slab_volt"
	charges = 4

/datum/action/item_action/cult/clock_spell/disable/do_hit_spell_effects(mob/living/victim, mob/living/user)
	if(IS_CULTIST(victim))
		return

	if(HAS_TRAIT_FROM(victim, TRAIT_I_WAS_FUNNY_HANDED, REF(user)))
		return FALSE

	var/mob/living/living_target = victim
	user.visible_message(
		span_warning("[user] holds up [target], which glows in a harsh white light!"),
		span_brasstalics("You attempt to disable [living_target] with [target]!")
		)

	user.mob_light(range = 3, color = LIGHT_COLOR_TUNGSTEN, duration = 0.8 SECONDS)

	if(victim.can_block_magic())
		return TRUE

	if(living_target.getStaminaLoss() >= 70)
		living_target.flash_act(1, TRUE, visual = TRUE, length = 6 SECONDS)
	else
		living_target.Knockdown(1 SECONDS)
	living_target.apply_damage(75, PAIN, BODY_ZONE_CHEST)
	new /obj/effect/temp_visual/clock/disable(get_turf(victim))
	var/final_hit = living_target.getStaminaLoss() >= 100

	if(issilicon(victim))
		var/mob/living/silicon/silicon_target = victim
		silicon_target.emp_act(EMP_HEAVY)
		if(iscyborg(target))
			var/mob/living/silicon/robot/cyborg_target = victim
			cyborg_target.cell.charge = clamp(cyborg_target.cell.charge - 5000, 0, cyborg_target.cell.maxcharge)

		to_chat(user, span_brasstalics("[victim] is enveloped in a bright white flash, overloading their sensors[iscyborg(victim)?" and draining their power":""]!"))
		to_chat(target, span_userdanger("A bright white light washes over you, overloading your system[iscyborg(victim)?" and draining your cell":""]!"))
		victim.visible_message(
			span_warning("[victim] overloads and shuts down!"),
			ignored_mobs = list(user, victim)
			)
	else if(isbot(victim))
		victim.emp_act(EMP_HEAVY)
		to_chat(user, span_brasstalics("[victim] is enveloped in a bright white flash, overloading it!"))
		victim.visible_message(
			span_warning("[victim] overloads!"),
			ignored_mobs = list(user, victim)
			)

	else if(iscarbon(victim))
		var/mob/living/carbon/carbon_target = victim
		if(HAS_TRAIT(victim, TRAIT_MINDSHIELD))
			if(!final_hit)
				to_chat(user, span_brass("[victim] is enveloped in a white flash, <b>but their mind is too strong to be silenced!</b>"))
				to_chat(victim, span_userdanger("A bright white light washes over you, sapping you of energy!"))
		else
			if(!final_hit)
				to_chat(user, span_brass("[victim] is enveloped in a white flash, preventing them from speaking!"))
				to_chat(victim, span_userdanger("A bright white light washes over you, sapping you of energy and voice!"))
			carbon_target.adjust_silence(8 SECONDS)

		carbon_target.adjust_stutter(16 SECONDS)
		carbon_target.adjust_jitter(8 SECONDS)

	ADD_TRAIT(victim, TRAIT_I_WAS_FUNNY_HANDED, REF(user))
	addtimer(TRAIT_CALLBACK_REMOVE(victim, TRAIT_I_WAS_FUNNY_HANDED, REF(user)), 3 SECONDS)
	playsound(get_turf(user), 'sound/magic/blind.ogg', 10, FALSE, SILENCED_SOUND_EXTRARANGE, pressure_affected = FALSE, ignore_walls = FALSE)

	return TRUE

/obj/effect/temp_visual/clock/disable
	icon_state = "volt_hit"
