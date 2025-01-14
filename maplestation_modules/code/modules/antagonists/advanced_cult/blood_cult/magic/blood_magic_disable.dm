// -- Disable spell. --

// Applies heavy stamina damage, mute, and cult slurring. Has 4 charges.
// You can only hit the same person every 3 seconds.
// The mute + slurring is can only be applied to the same person every 12 seconds.

// Sic semper tyrannis (disables fuu majin)
/datum/action/innate/cult/blood_spell/stun
	blacklisted_by_default = TRUE

/datum/action/innate/cult/blood_spell/disable
	name = "Disable"
	desc = "Empowers your hand to mute and cause heavy stamina damage to a victim on contact. Has multiple uses."
	button_icon_state = "hand"
	magic_path = "/obj/item/melee/blood_magic/disable"
	health_cost = 6
	charges = 4

/obj/item/melee/blood_magic/disable
	name = "Disabling Light"
	desc = "Will mute and cause stamina damage to a weak-minded victim on contact."
	color = RUNE_COLOR_EMP
	invocation = "Dia ta'jin!"
	/// Health cost on initialize.
	var/base_health_cost = 0

/obj/item/melee/blood_magic/disable/Initialize(mapload, spell)
	. = ..()
	if(spell)
		base_health_cost = source.health_cost

/obj/item/melee/blood_magic/disable/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(HAS_TRAIT_FROM(A, TRAIT_I_WAS_FUNNY_HANDED, REF(user)))
		to_chat(user, span_warning("You need to wait before using [src] on [A] again!"))
		return TRUE

/obj/item/melee/blood_magic/disable/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity || target == user)
		return
	var/mob/living/living_target = target
	if(IS_CULTIST(living_target))
		to_chat(user, span_cultitalic("[target] is a fellow cultist, their mind is not weak enough!"))
		return
	if(!IS_CULTIST(user))
		return
	if(HAS_TRAIT_FROM(target, TRAIT_I_WAS_FUNNY_HANDED, REF(user)))
		return

	user.visible_message(
		span_warning("[user] holds up [user.p_their()] hand, which glows in soothing blue light!"),
		span_cultitalic("You attempt to disable [living_target] with the spell!")
		)

	user.mob_light(range = 3, color = LIGHT_COLOR_LIGHT_CYAN, duration = 0.3 SECONDS)

	var/applied_effects = FALSE
	if(living_target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) & ANTIMAGIC_TIER_IMMUNE)
		applied_effects = TRUE
	else
		if(living_target.getStaminaLoss() >= 70)
			living_target.flash_act(1, TRUE, visual = TRUE, length = 3 SECONDS)
		else
			living_target.Knockdown(1 SECONDS)
		living_target.apply_damage(75, STAMINA, BODY_ZONE_CHEST)

		if(!HAS_TRAIT_FROM(target, TRAIT_NO_FUNNY_HAND_SIDE_EFFECTS, REF(user)))
			applied_effects = TRUE
			if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
				to_chat(user, span_cultitalic("[target] is enveloped in a brilliant flash of blue, but their mind is too strong to be silenced!"))
			else
				apply_side_effects_to_target(target, user)

		ADD_TRAIT(target, TRAIT_NO_FUNNY_HAND_SIDE_EFFECTS, REF(user))
		addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_NO_FUNNY_HAND_SIDE_EFFECTS, REF(user)), 12 SECONDS)

	ADD_TRAIT(target, TRAIT_I_WAS_FUNNY_HANDED, REF(user))
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_I_WAS_FUNNY_HANDED, REF(user)), 3 SECONDS)

	playsound(get_turf(user), 'sound/magic/mandswap.ogg', 10, FALSE, SILENCED_SOUND_EXTRARANGE, pressure_affected = FALSE, ignore_walls = FALSE)
	if(applied_effects)
		invocation = initial(invocation)
		health_cost = base_health_cost
	else
		invocation = null
		health_cost = 0

	uses--
	. = ..()

/obj/item/melee/blood_magic/disable/proc/apply_side_effects_to_target(mob/living/target, mob/living/user)

	if(issilicon(target))
		var/mob/living/silicon/silicon_target = target

		to_chat(user, span_cultitalic("[target] is enveloped in a brilliant flash of blue, overloading their sensors!"))
		to_chat(target, span_userdanger("A cold wave of light washes over you, overloading your system[iscyborg(target)?" and draining your cell":""]!"))
		target.visible_message(
			span_warning("[target] overloads and shuts down!"),
			ignored_mobs = list(user, target)
			)

		silicon_target.emp_act(EMP_HEAVY)
		if(iscyborg(target))
			var/mob/living/silicon/robot/cyborg_target = target
			cyborg_target.cell.charge = clamp(cyborg_target.cell.charge - 5000, 0, cyborg_target.cell.maxcharge)

	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target

		to_chat(user, span_cultitalic("[target] is enveloped in a briliant flash of blue, preventing them from speaking!"))
		to_chat(target, span_userdanger("A cold wave of light washes over you, sapping you of energy!"))

		carbon_target.adjust_silence(16 SECONDS)
		carbon_target.adjust_stutter(30 SECONDS)
		carbon_target.adjust_timed_status_effect(36 SECONDS, /datum/status_effect/speech/slurring/cult)
		carbon_target.adjust_jitter(60 SECONDS)
