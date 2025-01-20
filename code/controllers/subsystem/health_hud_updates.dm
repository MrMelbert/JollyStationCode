/**
 * # SShealth_updates
 *
 * Used to queue the expensive parts of updating a mob's health values,
 * the updates to all associated HUDs, and then fire them all at once.
 */
SUBSYSTEM_DEF(health_updates)
	name = "Health Hud Updates"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 0.1 SECONDS

	var/list/queued = list()

/datum/controller/subsystem/health_updates/stat_entry(msg)
	msg = "Q:[length(queued)]"
	return ..()

/datum/controller/subsystem/health_updates/proc/queue_update(mob/living/to_queue, to_update = ALL)
	if(queued[to_queue])
		queued[to_queue] |= to_update
		return

#ifdef UNIT_TESTS
	if(to_update & UPDATE_CON)
		to_queue.update_conscisouness()
	if(!QDELETED(to_queue))
		if(to_update & UPDATE_SELF_DAMAGE)
			to_queue.update_damage_hud()
			to_queue.update_succumb_action()
		if(to_update & UPDATE_SELF_HEALTH)
			to_queue.update_health_hud()
		if(to_update & UPDATE_MEDHUD_HEALTH)
			to_queue.med_hud_set_health()
		if(to_update & UPDATE_MEDHUD_STATUS)
			to_queue.med_hud_set_status()
#else
	RegisterSignal(to_queue, COMSIG_QDELETING, PROC_REF(queue_del))
	queued[to_queue] = to_update
#endif

/datum/controller/subsystem/health_updates/proc/queue_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	queued -= source

/datum/controller/subsystem/health_updates/fire()
	while(length(queued))
		var/mob/living/to_update = queued[1]
		var/to_update_flag = queued[to_update]
		queued.Cut(1, 2)

		UnregisterSignal(to_update, COMSIG_QDELETING)
		if(to_update_flag & UPDATE_CON)
			to_update.update_conscisouness()
		if(!QDELETED(to_update))
			if(to_update_flag & UPDATE_SELF_DAMAGE)
				to_update.update_damage_hud()
				to_update.update_succumb_action()
			if(to_update_flag & UPDATE_SELF_HEALTH)
				to_update.update_health_hud()
			if(to_update_flag & UPDATE_MEDHUD_HEALTH)
				to_update.med_hud_set_health()
			if(to_update_flag & UPDATE_MEDHUD_STATUS)
				to_update.med_hud_set_status()

		if(MC_TICK_CHECK)
			return
