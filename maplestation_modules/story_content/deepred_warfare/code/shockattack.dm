/datum/element/shockattack
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	// If the attack stuns on hit.
	var/stun_on_hit
	// How much damage the attack does.
	var/shock_damage

/datum/element/shockattack/Attach(datum/target, stun_on_hit = FALSE, shock_damage, thrown_effect = FALSE)
	. = ..()
	src.stun_on_hit = stun_on_hit
	src.shock_damage = shock_damage
	target.AddComponent(\
		/datum/component/on_hit_effect,\
		on_hit_callback = CALLBACK(src, PROC_REF(do_shocking)),\
		thrown_effect = thrown_effect,\
	)

/datum/element/shockattack/Detach(datum/target)
	qdel(target.GetComponent(/datum/component/on_hit_effect))
	return ..()

/datum/element/shockattack/proc/do_shocking(datum/element_owner, mob/living/owner, mob/living/target)
	if(!istype(target))
		return
	if(target.stat == DEAD)
		return
	if(stun_on_hit)
		target.electrocute_act(shock_damage, owner, 1, SHOCK_NOGLOVES)
		return
	target.electrocute_act(shock_damage, owner, 1, SHOCK_NOSTUN | SHOCK_NOGLOVES)
