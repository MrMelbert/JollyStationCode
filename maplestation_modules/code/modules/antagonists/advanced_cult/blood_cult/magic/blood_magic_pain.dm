// -- Pain spell. --

// Causes pain to the target.
// Amount of pain and target limb depends on user targeting.

/datum/action/innate/cult/blood_spell/pain
	name = "Pain"
	desc = "Empowers your hand cause immense pain to a victim's limb on contact. Respects limb targeting."
	button_icon_state = "hand"
	magic_path = "/obj/item/melee/blood_magic/pain"
	health_cost = 8

/obj/item/melee/blood_magic/pain
	name = "Touch of Pain"
	desc = "Causes immense pain to the target. Respects limb targeting."
	color = RUNE_COLOR_DARKRED
	invocation = "Sha Mi!"

/obj/item/melee/blood_magic/pain/examine(mob/user)
	. = ..()
	. += span_cult("Targeting the chest will cause moderate pain to all the target's limbs and chest.")
	. += span_cult("Targeting the head will cause minor lasting pain to the target's head.")
	. += span_cult("Targeting any limbs will cause a high, sharp pain to that limb.")

/obj/item/melee/blood_magic/pain/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!ishuman(target) || !proximity || target == user)
		return
	var/mob/living/carbon/human/human_target = target
	if(IS_CULTIST(human_target))
		to_chat(user, span_cultitalic("[target] is a fellow cultist, they are unaffected!"))
		return
	if(!IS_CULTIST(user))
		return

	user.visible_message(
		span_warning("[user] holds up [user.p_their()] hand, which glows in harsh red light!"),
		span_cultitalic("You attempt to wrack [target] with immense pain!")
		)

	user.mob_light(range = 3, color = LIGHT_COLOR_BLOOD_MAGIC, duration = 0.3 SECONDS)

	if(!(human_target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) & ANTIMAGIC_TIER_IMMUNE))
		to_chat(user, span_cultitalic("You curse [human_target] with [src]!"))
		target.visible_message(
			span_warning("[human_target] writhes in pain!"),
			span_userdanger("A red light washes over you, and you suddenly feel a world of immense pain!")
			)

		var/targeted_zone = check_zone(user.zone_selected)
		switch(targeted_zone)
			if(BODY_ZONE_HEAD)
				human_target.sharp_pain(targeted_zone, 30, duration = 30 SECONDS)

			if(BODY_ZONE_CHEST)
				human_target.cause_pain(BODY_ZONES_MINUS_HEAD, 30)

			else
				human_target.cause_pain(targeted_zone, 70)

	uses--
	. = ..()
