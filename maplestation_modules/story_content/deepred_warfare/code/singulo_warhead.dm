/obj/effect/singulo_warhead
	name = "active bluespace singularity warhead"
	desc = "An active bluespace singularity warhead. You probably should be running instead of looking at this."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "dimensional"
	opacity = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

	light_range = 8
	light_power = 5
	light_on = TRUE
	color = COLOR_RED
	light_color = COLOR_RED

	COOLDOWN_DECLARE(detonate_cooldown)
	var/detonate_delay = 1 SECONDS

	//Lifetime of the singularity, 4 seconds by default for untuned warheads.
	var/lifetime = 8 SECONDS

	//Determines if the warhead should be in area denial mode.
	var/tuned = FALSE

	//The cluster version is less destructive.
	var/cluster = FALSE

	//Spooky.
	var/atom/movable/warp_effect/warp

/obj/effect/singulo_warhead/Initialize(mapload)
	. = ..()
	warp = new(src)
	vis_contents += warp
	if(tuned)
		START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(detonate)), lifetime)

/obj/effect/singulo_warhead/Destroy()
	vis_contents -= warp
	QDEL_NULL(warp)
	return ..()

/obj/effect/singulo_warhead/proc/detonate()
	if(!tuned)
		if(cluster)
			explosion(src, devastation_range = 4, heavy_impact_range = 8, light_impact_range = 12, flame_range = 12, flash_range = 15, ignorecap = TRUE, adminlog = FALSE)
		else
			explosion(src, devastation_range = 5, heavy_impact_range = 10, light_impact_range = 15, flame_range = 15, flash_range = 20, ignorecap = TRUE, adminlog = FALSE)
	qdel(src)

/obj/effect/singulo_warhead/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, detonate_cooldown))
		return
	COOLDOWN_START(src, detonate_cooldown, detonate_delay)
	if(cluster)
		explosion(src, light_impact_range = 3, flame_range = 10, flash_range = 12, ignorecap = TRUE, adminlog = FALSE)
	else
		explosion(src, light_impact_range = 4, flame_range = 12, flash_range = 16, ignorecap = TRUE, adminlog = FALSE)

/obj/effect/singulo_warhead/tuned
	tuned = TRUE
	lifetime = 16 SECONDS

/obj/effect/singulo_warhead/cluster
	cluster = TRUE
	lifetime = 6 SECONDS

/obj/effect/singulo_warhead/tuned_cluster
	tuned = TRUE
	cluster = TRUE
	lifetime = 12 SECONDS
