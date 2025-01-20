
/mob/living/brain/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(isnull(loc) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	if(!isnull(container))
		if(!istype(container))
			stack_trace("/mob/living/brain with container set, but container was not an MMI!")
			container = null
		if(!container.contains(src))
			stack_trace("/mob/living/brain with container set, but we weren't inside of it!")
			container = null
	. = ..()
	handle_emp_damage(seconds_per_tick, times_fired)

/mob/living/brain/fully_heal(heal_flags)
	. = ..()
	var/obj/item/organ/internal/brain/brain_real = container?.brain || loc
	if(!istype(brain_real))
		return
	if(heal_flags & (HEAL_BODY|HEAL_DAMAGE|HEAL_ADMIN))
		brain_real.set_organ_damage(0)
	if(heal_flags & HEAL_ADMIN)
		brain_real.suicided = FALSE

/mob/living/brain/revive(full_heal_flags, excess_healing, force_grab_ghost)
	if(QDELETED(src))
		return FALSE
	var/obj/item/organ/internal/brain/brain_real = container?.brain || loc
	if(!istype(brain_real))
		return FALSE
	if(full_heal_flags)
		fully_heal(full_heal_flags)
	if(!can_be_revived())
		return FALSE

	set_stat(CONSCIOUS)
	return TRUE

/mob/living/brain/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat == DEAD)
		return

	var/obj/item/organ/internal/brain/brain_real = container?.brain || loc
	if(!istype(brain_real))
		return

	if(health <= -maxHealth || (brain_real.organ_flags & ORGAN_FAILING))
		if(stat != DEAD)
			death()
		return

	if(stat != CONSCIOUS)
		set_stat(CONSCIOUS)

/mob/living/brain/proc/handle_emp_damage(seconds_per_tick, times_fired)
	if(!emp_damage)
		return

	if(stat == DEAD)
		emp_damage = 0
	else
		emp_damage = max(emp_damage - (0.5 * seconds_per_tick), 0)
