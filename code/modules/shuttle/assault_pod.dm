/obj/docking_port/mobile/assault_pod
	name = "assault pod"
	shuttle_id = "steel_rain"

/obj/docking_port/mobile/assault_pod/request(obj/docking_port/stationary/S)
	if(!(z in SSmapping.levels_by_trait(ZTRAIT_STATION))) //No launching pods that have already launched
		return ..()


/obj/docking_port/mobile/assault_pod/initiate_docking(obj/docking_port/stationary/S1)
	. = ..()
	if(!istype(S1, /obj/docking_port/stationary/transit))
		playsound(get_turf(src.loc), 'sound/effects/explosion1.ogg',50,TRUE)



/obj/item/assault_pod
	name = "Assault Pod Targeting Device"
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "gangtool-red"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	desc = "Used to select a landing zone for assault pods."
	drop_sound = 'maplestation_modules/sound/items/drop/device2.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/device.ogg'
	var/shuttle_id = "steel_rain"
	var/dwidth = 3
	var/dheight = 0
	var/width = 7
	var/height = 7
	var/lz_dir = 1


/obj/item/assault_pod/attack_self(mob/living/user)
	var/target_area = tgui_input_list(user, "Area to land", "Landing Zone", GLOB.teleportlocs)
	if(isnull(target_area))
		return
	if(isnull(GLOB.teleportlocs[target_area]))
		return
	var/area/picked_area = GLOB.teleportlocs[target_area]
	if(!src || QDELETED(src))
		return

	var/list/turfs = get_area_turfs(picked_area)
	if (!length(turfs))
		return
	var/turf/T = pick(turfs)
	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.shuttle_id = "assault_pod([REF(src)])"
	landing_zone.port_destinations = "assault_pod([REF(src)])"
	landing_zone.name = "Landing Zone"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.setDir(lz_dir)

	for(var/obj/machinery/computer/shuttle/S in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/shuttle))
		if(S.shuttleId == shuttle_id)
			S.possible_destinations = "[landing_zone.shuttle_id]"

	to_chat(user, span_notice("Landing zone set."))

	qdel(src)
