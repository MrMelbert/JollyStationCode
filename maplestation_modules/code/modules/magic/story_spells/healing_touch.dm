#define COMSIG_SPELL_HEALING_TOUCH_IS_VALID "spell_healing_touch_is_valid"
	#define CAN_BE_HEALED (1<<0)
#define COMSIG_SPELL_HEALING_TOUCH_CAST "spell_healing_touch_cast"
	#define HEAL_HANDLED (1<<0)
	#define HEAL_CANCELLED (1<<1)

#define HEALING_TOUCH_ATTUNEMENT_LIFE 0.5
#define HEALING_TOUCH_COST_PER_HEALED 1.5


// Touch based healing spell, very simple. Only works on organic mobs or anything that hooks to the comsig.
/datum/action/cooldown/spell/touch/healing_touch
	name = "Healing Touch"
	desc = "Lay your hands on a living target to heal them."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "blessed"
	sound = 'sound/magic/staff_healing.ogg'

	school = SCHOOL_RESTORATION // or SCHOOL_HOLY
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	var/mana_cost = HEALING_TOUCH_COST_PER_HEALED

	invocation = "Sana manu!"
	invocation_type = INVOCATION_WHISPER

	hand_path = /obj/item/melee/touch_attack/healing_touch

	/// How much brute damage to heal.
	var/brute_heal = 10
	/// How much burn damage to heal.
	var/burn_heal = 10
	/// How much toxin damage to heal.
	var/tox_heal = 0
	/// How much oxygen damage to heal.
	var/oxy_heal = 0
	/// How much pain to heal, applies to all bodyparts
	var/pain_heal = 8

/datum/action/cooldown/spell/touch/healing_touch/New(Target, original)
	. = ..()

	var/list/datum/attunement/attunements = GLOB.default_attunements.Copy()
	attunements[MAGIC_ELEMENT_LIFE] += HEALING_TOUCH_ATTUNEMENT_LIFE

	AddComponent(/datum/component/uses_mana/touch_spell, \
		activate_check_failure_callback = CALLBACK(src, PROC_REF(spell_cannot_activate)), \
		mana_required = CALLBACK(src, PROC_REF(get_mana_consumed)), \
		get_user_callback = CALLBACK(src, PROC_REF(get_owner)), \
		attunements = attunements, \
		)
/datum/action/cooldown/spell/touch/healing_touch/proc/get_mana_consumed(atom/caster, datum/spell, atom/cast_on)
	return (brute_heal + burn_heal + tox_heal + oxy_heal + pain_heal * 3) \
		* mana_cost

/datum/action/cooldown/spell/touch/healing_touch/is_valid_target(atom/cast_on)
	if(SEND_SIGNAL(cast_on, COMSIG_SPELL_HEALING_TOUCH_IS_VALID, src) & CAN_BE_HEALED)
		return TRUE

	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.stat == DEAD)
		return FALSE // can't heal the dead
	if(living_cast_on.mob_biotypes & (MOB_UNDEAD|MOB_SPIRIT))
		return FALSE // can't heal the (un)dead
	if(living_cast_on.mob_biotypes & MOB_ORGANIC)
		return TRUE // CAN heal the organic

	// everyone else need not apply (robots, golems, whatever)
	return FALSE

/datum/action/cooldown/spell/touch/healing_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/sigreturn = SEND_SIGNAL(victim, COMSIG_SPELL_HEALING_TOUCH_CAST, src, caster, hand)
	if(sigreturn & HEAL_HANDLED)
		return TRUE
	if(sigreturn & HEAL_CANCELLED)
		return FALSE

	// Brute and burn damage have a little conversion thing going on
	// where if someone is healed for more than they need, the excess is converted to the other damage type.
	// I'm not bothering to do this for toxin and oxygen out of thematics and laziness
	// (Healing touch = touches your skin, not your lungs or stomach or liver)
	var/final_brute_heal = brute_heal
	var/final_burn_heal = burn_heal

	var/target_brute = victim.getBruteLoss()
	var/target_burn = victim.getFireLoss()

	// (This can result in us *gaining* net healing if both values are below each other, but this is fine,
	// becuase the mob's health will be low enough such that it'll be full healed regardless)
	if(target_brute < brute_heal)
		final_burn_heal += (brute_heal - target_brute)
	if(target_burn < burn_heal)
		final_brute_heal += (burn_heal - target_burn)

	var/starting_health = victim.health
	var/starting_pain = victim.pain_controller?.get_total_pain()

	victim.adjustBruteLoss(-1 * final_brute_heal, updating_health = FALSE, forced = TRUE, required_bodytype = BODYTYPE_ORGANIC)
	victim.adjustFireLoss(-1 * final_burn_heal, updating_health = FALSE, forced = TRUE, required_bodytype = BODYTYPE_ORGANIC)
	victim.adjustToxLoss(-1 * tox_heal, updating_health = FALSE, forced = TRUE, required_biotype = MOB_ORGANIC)
	victim.adjustOxyLoss(-1 * oxy_heal, updating_health = FALSE, forced = TRUE, required_biotype = MOB_ORGANIC)
	victim.cause_pain(BODY_ZONES_ALL, -1 * pain_heal)
	victim.updatehealth()

	if(victim.health == starting_health && victim.pain_controller?.get_total_pain() == starting_pain)
		return FALSE

	new /obj/effect/temp_visual/heal(victim.loc, LIGHT_COLOR_HOLY_MAGIC)
	return TRUE

/obj/item/melee/touch_attack/healing_touch
	name = "\improper healing touch"
	desc = "Take all my strength into you and be whole once more!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "duffelcurse"
	inhand_icon_state = "duffelcurse"
	color = LIGHT_COLOR_HOLY_MAGIC

/obj/item/melee/touch_attack/healing_touch/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()
	var/mob/living/carbon/caster = loc
	if(!istype(caster) || caster.usable_hands <= 1 || caster.get_num_held_items() > 0)
		return
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/melee/touch_attack/healing_touch/attack(mob/target, mob/living/carbon/user)
	. = ..()
	if(.)
		return TRUE

	var/datum/action/cooldown/spell/touch/healing_touch/touch = spell_which_made_us?.resolve()
	if(!touch?.can_hit_with_hand(target, user))
		return TRUE // cancel attack chain
	if(DOING_INTERACTION(user, REF(src)))
		return TRUE // cancel attack chain

	var/hand_or_hands = HAS_TRAIT(src, TRAIT_WIELDED) ? "hands" : "hand"

	user.visible_message(
		span_notice("[user] lays [user.p_their()] [hand_or_hands] on [target]..."),
		span_notice("You lay your [hand_or_hands] on [target]..."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	// I'm putting this behavior on the touch itself instead of hooking a signal so I can via doafter, sue me
	if(!do_after(user, 3 SECONDS, target, interaction_key = REF(src)))
		return TRUE // cancel attack chain

	user.visible_message(
		span_green("[user]'s [hand_or_hands] glow a brilliant yellow light!"),
		span_green("Your [hand_or_hands] glow a brilliant yellow light!"),
	)
	return FALSE // go to after attack (cast)

// Lets hydroponics trays be healed by healing touch
/obj/machinery/hydroponics/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SPELL_HEALING_TOUCH_IS_VALID, PROC_REF(can_be_healed))
	RegisterSignal(src, COMSIG_SPELL_HEALING_TOUCH_CAST, PROC_REF(healing_touched))

/obj/machinery/hydroponics/proc/can_be_healed(datum/source)
	SIGNAL_HANDLER

	if(plant_status == HYDROTRAY_PLANT_DEAD || plant_status == HYDROTRAY_NO_PLANT)
		return NONE
	if(myseed.get_gene(/datum/plant_gene/trait/anti_magic))
		return NONE // maybe i should add feedback to this but i feel like one can connect the dots
	return CAN_BE_HEALED

/obj/machinery/hydroponics/proc/healing_touched(datum/source, datum/action/cooldown/spell/touch/healing_touch/spell, mob/living/carbon/caster)
	SIGNAL_HANDLER

	adjust_plant_health(-1 * (spell.brute_heal + spell.burn_heal))
	adjust_toxic(-2 * spell.tox_heal)
	if(pestlevel > 1)
		adjust_pestlevel(pestlevel * 0.5) // increases the amount of pests, you just healed them!
	if(weedlevel > 2)
		adjust_weedlevel(weedlevel * 0.5) // increases the amount of weeds, you just healed them!
	return HEAL_HANDLED

#undef COMSIG_SPELL_HEALING_TOUCH_IS_VALID
	#undef CAN_BE_HEALED
#undef COMSIG_SPELL_HEALING_TOUCH_CAST
	#undef HEAL_HANDLED
	#undef HEAL_CANCELLED
#undef HEALING_TOUCH_ATTUNEMENT_LIFE
#undef HEALING_TOUCH_COST_PER_HEALED
