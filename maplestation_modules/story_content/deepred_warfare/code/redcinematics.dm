/proc/play_unbidden_cinematic(chosen_cinematic, charge_time)
	switch(chosen_cinematic)
		if("Culmination Spark End")
			SSsecurity_level.set_level(SEC_LEVEL_DELTA)
			priority_announce(
				text = "A large energy weapon buildup event has been detected in your sector. Highly recommend immediate evacuation. TIME BEFORE CRITICAL ENERGY THRESHOLD: [charge_time] MINUTES.",
				title = "[command_name()] Crisis & Damage Control Center",
				sound = 'sound/misc/airraid.ogg',
			)
			// addtimer(CALLBACK(src, GLOBAL_PROC_REF(fire_unbidden_spark)), charge_time MINUTES)
			return TRUE
	return FALSE

// Modded version of the cinematic atom to allow this to stay modular.
/atom/movable/screen/cinematic/modded
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/cinematics.dmi'

/datum/cinematic/unbidden

/datum/cinematic/unbidden/New(watcher, datum/callback/special_callback)
	. = ..()
	screen = new /atom/movable/screen/cinematic/modded()

/datum/cinematic/unbidden/culmination_spark

/datum/cinematic/unbidden/culmination_spark/play_cinematic()
	flick("intro_spark", screen)
	stoplag(3.5 SECONDS)
	// Only intro plays, other bits seem broken (upon gib).
	flick("culmination_spark", screen)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg')) // Change this later.
	if(special_callback) // Prevents the code from imploding on accident.
		special_callback.Invoke()
	screen.icon_state = "spark_end"

/proc/fire_unbidden_spark()
	// play_cinematic(/datum/cinematic/unbidden/culmination_spark, world, CALLBACK(SSticker, TYPE_PROC_REF(/datum/controller/subsystem/ticker, station_explosion_detonation), src))
	// INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(callback_on_everyone_on_z), SSmapping.levels_by_trait(ZTRAIT_STATION), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(nuke_gib)), src)

/proc/remove_air_stationz()
	for(var/area/station/station_area in GLOB.areas)
		if(!is_station_level(station_area.z))
			continue
		for(var/turf/area_turf as anything in station_area.get_turfs_from_all_zlevels())
			if(isopenturf(area_turf))
				var/turf/open/deleting_turf = area_turf
				if(deleting_turf.air)
					deleting_turf.remove_air(INFINITY)
