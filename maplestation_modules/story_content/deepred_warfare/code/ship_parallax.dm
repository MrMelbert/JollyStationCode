GLOBAL_VAR_INIT(unbidden_distance, 0) // 0 = empty, 1 = very far, 2 = far, 3 = close
GLOBAL_VAR_INIT(unbidden_ringed, TRUE) // TRUE = ringed, FALSE = not ringed
GLOBAL_LIST_EMPTY(collective_unbiddens) // A list of all unbidden parallax layers.

/atom/movable/screen/parallax_layer/planet/unbidden
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/unbidden_parallax.dmi'
	icon_state = "unbidden_empty"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE
	speed = 5
	layer = 40

	var/distance = 0
	var/ringed = TRUE

/atom/movable/screen/parallax_layer/planet/unbidden/Initialize(mapload)
	. = ..()
	GLOB.collective_unbiddens += src
	distance = GLOB.unbidden_distance
	ringed = GLOB.unbidden_ringed
	full_update()

/atom/movable/screen/parallax_layer/planet/unbidden/Destroy()
	GLOB.collective_unbiddens -= src
	return ..()

/atom/movable/screen/parallax_layer/planet/unbidden/proc/get_random_look()
	return

/atom/movable/screen/parallax_layer/planet/unbidden/proc/change_distance()
	switch(GLOB.unbidden_distance)
		if(0)
			icon_state = "unbidden_empty"
			distance = 0
		if(1)
			if(ringed)
				icon_state = "unbidden_very_far_ring"
			else
				icon_state = "unbidden_very_far"
			distance = 1
			speed = 3
		if(2)
			if(ringed)
				icon_state = "unbidden_far_ring"
			else
				icon_state = "unbidden_far"
			distance = 2
			speed = 4
		if(3)
			if(ringed)
				icon_state = "unbidden_ring"
			else
				icon_state = "unbidden"
			distance = 3
			speed = 5

/atom/movable/screen/parallax_layer/planet/unbidden/proc/full_update()
	if(GLOB.unbidden_ringed)
		ringed = TRUE
	else
		ringed = FALSE
	change_distance()

/proc/update_unbidden(new_distance, new_ringed)
	GLOB.unbidden_distance = new_distance
	GLOB.unbidden_ringed = new_ringed
	for(var/atom/movable/screen/parallax_layer/planet/unbidden/R as anything in GLOB.collective_unbiddens)
		R.full_update()

/atom/movable/screen/parallax_layer/planet/unbidden/on_z_change(mob/source)
	. = ..()
	full_update()
