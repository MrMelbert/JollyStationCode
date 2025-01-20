/datum/wound_pregen_data/internal_bleeding
	abstract = FALSE
	wound_path_to_generate = /datum/wound/bleed_internal
	ignore_cannot_bleed = FALSE
	required_limb_biostate = BIO_BLOODED
	required_wounding_types = list(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE)
	threshold_minimum = 45

/datum/wound/bleed_internal
	name = "Internal Bleeding"
	desc = "The patient is bleeding internally, causing severe pain and difficulty breathing."
	treat_text = "Surgical repair of the affected vein is necessary. \
		Blood clotting medical will slow the bleeding, but only very rare and advanced medication can repair it on its own."
	treat_text_short = "Surgical repair required."
	examine_desc = ""
	scar_keyword = ""
	severity = WOUND_SEVERITY_MODERATE
	simple_treat_text = "Surgery."
	homemade_treat_text = "Taking a <b>blood clotting</b> pill or shot may help slow the bleeding. \
		Alternatively, an <b>iron supplement</b> may help your body replenish lost blood faster."
	processes = TRUE
	wound_flags = NONE
	/// How much blood lost per life tick, gets modified by severity.
	var/bleed_amount = 0.25
	/// Cooldown between when the wound can be allowed to worsen
	COOLDOWN_DECLARE(worsen_cd)

/datum/wound/bleed_internal/second_wind()
	return

/datum/wound/bleed_internal/get_self_check_description(mob/user)
	return span_warning("It feels tense to the touch.") // same as rib fracture!

/datum/wound/bleed_internal/handle_process(seconds_per_tick, times_fired)
	if(!victim || victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_STASIS) || !victim.needs_heart())
		return
	victim.bleed(bleed_amount * severity * seconds_per_tick, drip = FALSE)
	if(SPT_PROB(1, seconds_per_tick))
		victim.emote("cough")
		victim.visible_message(
			span_warning("[victim] coughs up blood."),
			span_warning("You cough up blood."),
			vision_distance = COMBAT_MESSAGE_RANGE,
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	if(SPT_PROB(0.1, seconds_per_tick))
		victim.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 0)

/datum/wound/bleed_internal/on_xadone(power)
	heal_percent(power / 10)

/datum/wound/bleed_internal/wound_injury(datum/wound/old_wound, attack_direction)
	COOLDOWN_START(src, worsen_cd, 5 SECONDS)

/datum/wound/bleed_internal/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	if(isnull(victim) || wounding_type == WOUND_BURN || wound_bonus == CANT_WOUND)
		return
	if(!COOLDOWN_FINISHED(src, worsen_cd))
		return
	if(wounding_dmg + wound_bonus + rand(-10, 30) - victim.getarmor(limb, WOUND) < 45)
		return
	severity = min(severity + 1, WOUND_SEVERITY_CRITICAL)
	COOLDOWN_START(src, worsen_cd, 6 SECONDS)

/datum/wound/bleed_internal/proc/heal_amount(amount)
	bleed_amount -= amount
	if(bleed_amount > 0)
		return
	if(severity > 0)
		severity--
		bleed_amount = initial(bleed_amount)
		return
	qdel(src)

/datum/wound/bleed_internal/proc/heal_percent(percent)
	heal_amount(initial(bleed_amount) * percent)
