/datum/component/uses_mana/story_spell/pointed/soothe
	var/soothe_attunement_amount = 0.5
	var/soothe_cost = 20

/datum/component/uses_mana/story_spell/pointed/soothe/get_attunement_dispositions()
	. = ..()
	.[/datum/attunement/life] += soothe_attunement_amount

/datum/component/uses_mana/story_spell/pointed/soothe/get_mana_required(atom/caster, mob/living/cast_on, ...)
	var/final_cost = ..() * soothe_cost
	if(!isnull(cast_on.mind))
		final_cost *= 2 // costs more on other players because pacifism is kind of annoying...
	return final_cost

// Calm Emotions / Soothe, basically just applied pacifism after a short do_after. Can be resisted.
/datum/action/cooldown/spell/pointed/soothe_target
	name = "Soothe"
	desc = "Attempt to calm a target, preventing them from attacking others for a short time and stopping \
		and anger, fear, or doubt they may be feeling. This effect can be resisted by sentient targets, \
		but works on more simple-minded creatures."
	sound = 'sound/effects/magic.ogg'

	cooldown_time = 2 MINUTES
	spell_requirements = NONE

	school = SCHOOL_PSYCHIC
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 4

	/// How long it takes to soothe someone, gives them time to resist the effect
	var/cast_time = 5 SECONDS
	/// How long the soothing effect lasts
	var/pacifism_duration = 30 SECONDS

/datum/action/cooldown/spell/pointed/soothe_target/New(Target)
	. = ..()
	AddComponent(/datum/component/uses_mana/story_spell/pointed/soothe)

/datum/action/cooldown/spell/pointed/soothe_target/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/soothe_target/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .

	var/mob/caster = usr || owner
	if(!cast_on.apply_status_effect(/datum/status_effect/being_soothed, cast_time * 2)) // extra long duration for leeway but we remove it after anyways
		cast_on.balloon_alert(caster, "already being soothed!")
		return . | SPELL_CANCEL_CAST

	if(!do_after(
		user = caster,
		delay = 5 SECONDS,
		target = cast_on,
		timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_SLOWDOWNS,
		extra_checks = CALLBACK(src, PROC_REF(block_cast), caster, cast_on) \
	))
		if(!QDELETED(cast_on) && !QDELETED(caster))
			cast_on.balloon_alert(caster, "cast resisted!")
		. |= SPELL_CANCEL_CAST

	cast_on.remove_status_effect(/datum/status_effect/being_soothed)
	return .

/datum/action/cooldown/spell/pointed/soothe_target/proc/block_cast(mob/living/caster, mob/living/cast_on)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(cast_on))
		return FALSE
	if(!caster.has_status_effect(/datum/status_effect/being_soothed))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/soothe_target/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/soothe, pacifism_duration)

// Interregnum effect from while the soothe is being applied that allows the target to resist
/datum/status_effect/being_soothed
	id = "being_soothed"
	alert_type = /atom/movable/screen/alert/status_effect/being_soothed
	tick_interval = -1

/datum/status_effect/being_soothed/on_creation(mob/living/new_owner, new_duration = 10 SECONDS)
	src.duration = new_duration
	return ..()

/datum/status_effect/being_soothed/on_apply()
	if(!isnull(owner.mind))
		// Only sentient mobs can resist the effect
		RegisterSignals(owner, list(COMSIG_LIVING_RESIST), PROC_REF(generic_block))
		RegisterSignals(owner, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK), PROC_REF(attack_block))
	to_chat(owner, span_hypnophrase("You inexplicably start to feel calmer..."))
	return TRUE

/datum/status_effect/being_soothed/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_RESIST, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK))

/datum/status_effect/being_soothed/proc/generic_block(datum/source)
	SIGNAL_HANDLER
	sooth_blocked()

/datum/status_effect/being_soothed/proc/attack_block(datum/source)
	SIGNAL_HANDLER
	if(owner.combat_mode)
		sooth_blocked()

/datum/status_effect/being_soothed/proc/sooth_blocked()
	new /obj/effect/temp_visual/annoyed(owner.loc)
	qdel(src)

/atom/movable/screen/alert/status_effect/being_soothed
	name = "Being Soothed"
	desc = "Some force is being exerted on you, suddenly quieting your rage, fear, and doubt. \
		You can <b>resist</b> this effect, if your feelings are stronger than this force lets on."
	icon_state = "high"

/atom/movable/screen/alert/status_effect/being_soothed/Click(location, control, params)
	if(usr != owner || !isliving(owner))
		return FALSE

	var/mob/living/clicker = owner
	clicker.execute_resist()
	return TRUE

// Soothe effect that prevents attacks and also stops mob AI from attacking
/datum/status_effect/soothe
	id = "soothe"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/soothed
	tick_interval = -1
	remove_on_fullheal = TRUE
	/// Tracks if we had [FACTION_NEUTRAL] before adding
	var/had_neutral_before = TRUE

/datum/status_effect/soothe/on_creation(mob/living/new_owner, new_duration = 10 SECONDS)
	src.duration = new_duration
	return ..()

/datum/status_effect/soothe/refresh(effect, new_duration = 10 SECONDS)
	duration += new_duration
	to_chat(owner, span_hypnophrase("You feel calmer."))

/datum/status_effect/soothe/on_apply()
	if(istype(owner.ai_controller, /datum/ai_controller/monkey))
		owner.ai_controller.clear_blackboard_key(BB_MONKEY_CURRENT_ATTACK_TARGET)
		owner.ai_controller.clear_blackboard_key(BB_MONKEY_ENEMIES)
		owner.ai_controller.set_blackboard_key(BB_MONKEY_ENEMIES, list())
		owner.ai_controller.set_blackboard_key(BB_MONKEY_AGGRESSIVE, FALSE)

	if(!(FACTION_NEUTRAL in owner.faction))
		had_neutral_before = FALSE
		owner.factions += FACTION_NEUTRAL

	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	to_chat(owner, span_hypnophrase("You feel calm."))
	return TRUE

/datum/status_effect/soothe/on_remove()
	if(!had_neutral_before)
		owner.factions -= FACTION_NEUTRAL
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)

/atom/movable/screen/alert/status_effect/soothed
	name = "Soothed"
	desc = "Some force is being exerted on you, calming you down. All of your rage, fear, and doubt disappear."
	icon_state = "hypnosis"
