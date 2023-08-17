/// The base component to be applied to all spells that interact with the mana system.
/datum/component/uses_mana/story_spell
	can_transfer = FALSE

/datum/component/uses_mana/story_spell/Initialize(...)
	. = ..()

	if (!istype(parent, /datum/action/cooldown/spell))
		return . | COMPONENT_INCOMPATIBLE

/datum/component/uses_mana/story_spell/RegisterWithParent()
	. = ..()

	RegisterSignal(parent, COMSIG_SPELL_BEFORE_CAST, PROC_REF(handle_precast))
	RegisterSignal(parent, COMSIG_SPELL_CAST, PROC_REF(handle_cast))
	RegisterSignal(parent, COMSIG_SPELL_AFTER_CAST, PROC_REF(react_to_successful_use))

/datum/component/uses_mana/story_spell/UnregisterFromParent()
	. = ..()

	UnregisterSignal(parent, COMSIG_SPELL_BEFORE_CAST)
	UnregisterSignal(parent, COMSIG_SPELL_CAST)
	UnregisterSignal(parent, COMSIG_SPELL_AFTER_CAST)

/datum/component/uses_mana/story_spell/give_unable_to_activate_feedback(atom/caster, atom/cast_on, ...)
	caster.balloon_alert(caster, "insufficient mana!")

// SIGNAL HANDLERS

/**
 * Actions done before the actual cast is called.
 * This is the last chance to cancel the spell from being cast.
 *
 * Can be used for target selection or to validate checks on the caster (cast_on).
 *
 * Returns a bitflag.
 * - SPELL_CANCEL_CAST will stop the spell from being cast.
 * - SPELL_NO_FEEDBACK will prevent the spell from calling [proc/spell_feedback] on cast. (invocation), sounds)
 * - SPELL_NO_IMMEDIATE_COOLDOWN will prevent the spell from starting its cooldown between cast and before after_cast.
 */
/datum/component/uses_mana/story_spell/proc/handle_precast(datum/action/cooldown/spell/source, atom/cast_on)
	SIGNAL_HANDLER

	return can_activate_check(TRUE, source.owner, cast_on)

/datum/component/uses_mana/story_spell/can_activate_check_failure(give_feedback, atom/caster, atom/cast_on, ...)
	. = ..()
	return . | SPELL_CANCEL_CAST

/**
 * Actions done as the main effect of the spell.
 *
 * For spells without a click intercept, [cast_on] will be the owner.
 * For click spells, [cast_on] is whatever the owner clicked on in casting the spell.
 */
/datum/component/uses_mana/story_spell/proc/handle_cast(datum/action/cooldown/spell/source, atom/cast_on)
	SIGNAL_HANDLER
	return

/datum/component/uses_mana/story_spell/react_to_successful_use(datum/action/cooldown/spell/source, atom/cast_on)
	drain_mana(null, null, source.owner, cast_on)

/datum/component/uses_mana/story_spell/get_mana_required(atom/caster, atom/cast_on, ...)
	if(ismob(caster))
		var/mob/caster_mob = caster
		return caster_mob.get_casting_cost_mult()
	return 1
