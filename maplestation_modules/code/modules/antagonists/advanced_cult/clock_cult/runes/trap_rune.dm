
/// Only alive non-cultists will see this appearance.
/datum/atom_hud/alternate_appearance/basic/noncult/observers_explicit/mobShouldSee(mob/M)
	if(isobserver(M))
		return FALSE
	return ..()

/obj/effect/rune/clock_trap
	name = "glint of the light"
	desc = "A strange glint shining from seemingly nowhere."
	cultist_name = "Sigil of Transgression"
	cultist_desc = "is invisible to non-cultists observing it. It disorients and blinds any non-cultists who step over it. Can be manually invoked to trigger its effects on anyone nearby."
	invocation = "N Yv'ggyr Vz'cng-vrag, Trg Rz!"
	icon = 'maplestation_modules/icons/effects/clockwork_effects.dmi'
	icon_state = "sigiltransgression"
	color = LIGHT_COLOR_TUNGSTEN
	construct_invoke = FALSE
	/// The amount of charges on the rune. Deletes itself when out.
	var/charges = 3
	/// A list of everyone who this rune's afflicted, so we don't double-dip.
	var/list/people_we_dazed

/obj/effect/rune/clock_trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	var/image/hidden = image('maplestation_modules/icons/effects/clockwork_effects.dmi', src, null, SIGIL_LAYER)
	hidden.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/noncult/observers_explicit, "clock_trap_rune", hidden)

	animate(src, alpha = 155, time = 20)
	desc = "A strange glint shining out of [loc] from seemingly nowhere."

/obj/effect/rune/clock_trap/Destroy(force)
	for(var/mob/living/carbon/person as anything in people_we_dazed)
		UnregisterSignal(person, COMSIG_QDELETING)

	LAZYCLEARLIST(people_we_dazed)
	return ..()

/obj/effect/rune/clock_trap/invoke(list/invokers)
	var/blinded_someone = FALSE
	for(var/mob/living/carbon/victim in orange(3, src))
		if(IS_CULTIST(victim))
			continue

		// No spam blinding on people
		if(victim in people_we_dazed)
			continue

		if(victim.can_block_magic())
			continue

		daze_victim(victim)
		blinded_someone = TRUE

	if(blinded_someone)
		. = ..()
		if(--charges <= 0)
			qdel(src)
	else
		fail_invoke()

/obj/effect/rune/clock_trap/do_invoke_glow()
	set waitfor = FALSE
	animate(src, transform = matrix() * 2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
	sleep(5)
	animate(src, transform = matrix(), alpha = 155, time = 0, flags = ANIMATION_END_NOW)

/obj/effect/rune/clock_trap/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!iscarbon(arrived))
		return

	var/mob/living/carbon/victim = arrived
	if(IS_CULTIST(victim))
		return

	// Pulling someone into an invisible trap can be abused
	if(victim.pulledby)
		return

	// No double dipping
	if(victim in people_we_dazed)
		return

	if(victim.can_block_magic())
		return

	new /obj/effect/particle_effect/sparks(get_turf(victim))
	daze_victim(victim)
	do_invoke_glow()

	if(--charges <= 0)
		qdel(src)

/obj/effect/rune/clock_trap/proc/daze_victim(mob/living/carbon/victim)
	// Keep track of the people we hit for later. But also don't hard-delete
	LAZYADD(people_we_dazed, victim)
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(clear_references))

	if(victim.is_blind())
		to_chat(victim, span_userdanger("Something warm envelops you and dazes you!"))
	else
		to_chat(victim, span_userdanger("A bright yellow flash obscures your vision and dazes you!"))

	victim.flash_act(1, affect_silicon = TRUE, visual = TRUE, length = 4 SECONDS)
	victim.apply_damage(50, PAIN, BODY_ZONE_CHEST)
	victim.adjust_dizzy(30 SECONDS)
	victim.adjust_confusion(40 SECONDS)

	playsound(get_turf(victim), 'sound/magic/blind.ogg', 15, FALSE, SILENCED_SOUND_EXTRARANGE, pressure_affected = FALSE, ignore_walls = FALSE)
	victim.mob_light(range = 2, color = LIGHT_COLOR_TUNGSTEN, duration = 0.8 SECONDS)
	new /obj/effect/temp_visual/clock/disable(get_turf(victim))

/obj/effect/rune/clock_trap/proc/clear_references(datum/source, force)
	SIGNAL_HANDLER

	LAZYREMOVE(people_we_dazed, source)
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/effect/rune/clock_trap/conceal()
	return

/obj/effect/rune/clock_trap/reveal()
	return
