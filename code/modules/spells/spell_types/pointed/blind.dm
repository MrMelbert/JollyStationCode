/datum/action/cooldown/spell/pointed/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS

	invocation = "STI KALY"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to blind a target..."

	/// The amount of blind to apply
	var/eye_blind_duration = 20 SECONDS
	/// The amount of blurriness to apply
	var/eye_blur_duration = 40 SECONDS

/datum/action/cooldown/spell/pointed/blind/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !human_target.is_blind()

/datum/action/cooldown/spell/pointed/blind/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/magic_tier = cast_on.can_block_magic(antimagic_flags)
	if(magic_tier & ANTIMAGIC_TIER_IMMUNE)
		to_chat(cast_on, span_notice("Your eye itches, but it passes momentarily."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	var/duration_mod = 1
	if(magic_tier & ANTIMAGIC_TIER_STRONG)
		duration_mod = 0.33
	else if(magic_tier & ANTIMAGIC_TIER_WEAK)
		duration_mod = 0.66

	to_chat(cast_on, span_warning("Your eyes cry out in pain!"))
	cast_on.adjust_temp_blindness(eye_blind_duration * duration_mod)
	cast_on.set_eye_blur_if_lower(eye_blur_duration * duration_mod)
	return TRUE
