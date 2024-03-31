/client/proc/warfareEvent()
	set name = "Warfare Module"
	set desc = "Allows you to perform various actions related to warfare"
	set category = "Admin.Events"

	var/datum/warfare_event/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/warfare_event
	var/client/holder //client of whoever is using this datum
	var/list/selectedShells = list() //list of selected shells to fire
	var/fireDirection = NORTH //default direction to fire shells (fires from top down)

/datum/warfare_event/New(user)//user can either be a client or a mob due to byondcode(tm)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

/datum/warfare_event/ui_state(mob/user)
	return GLOB.admin_state

/datum/warfare_event/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WarfareEvent")
		ui.open()

/datum/warfare_event/ui_data(mob/user)
	var/list/data = list()
	data["selectedShells"] = selectedShells
	data["fireDirection"] = fireDirection
	return data

/datum/warfare_event/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("addShell")
			var/selected = params["selected"]
			switch(selected)
				if("bigAP")
					selectedShells += /obj/effect/meteor/shell/big_ap
					. = TRUE
				if("smallAP")
					selectedShells += /obj/effect/meteor/shell/small_ap
					. = TRUE
				if("WMDHE")
					selectedShells += /obj/effect/meteor/shell/small_wmd_he
					. = TRUE
				if("WMDFlak")
					selectedShells += /obj/effect/meteor/shell/small_wmd_flak
					. = TRUE
				if("clusterAP")
					selectedShells += /obj/effect/meteor/shell/small_cluster_ap
					. = TRUE
				if("clusterWMDHE")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_he
					. = TRUE
				if("clusterWMDFlak")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_flak
					. = TRUE
				if("kajari")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/kajari
					. = TRUE
		if("removeShell")
			var/selected = params["selected"]
			switch(selected)
				if("bigAP")
					selectedShells -= /obj/effect/meteor/shell/big_ap
					. = TRUE
				if("smallAP")
					selectedShells -= /obj/effect/meteor/shell/small_ap
					. = TRUE
				if("WMDHE")
					selectedShells -= /obj/effect/meteor/shell/small_wmd_he
					. = TRUE
				if("WMDFlak")
					selectedShells -= /obj/effect/meteor/shell/small_wmd_flak
					. = TRUE
				if("clusterAP")
					selectedShells -= /obj/effect/meteor/shell/small_cluster_ap
					. = TRUE
				if("clusterWMDHE")
					// ADD CONFIRMATION.
					selectedShells -= /obj/effect/meteor/shell/big_cluster_wmd_he
					. = TRUE
				if("clusterWMDFlak")
					// ADD CONFIRMATION.
					selectedShells -= /obj/effect/meteor/shell/big_cluster_wmd_flak
					. = TRUE
				if("kajari")
					// ADD CONFIRMATION.
					selectedShells -= /obj/effect/meteor/shell/kajari
					. = TRUE
		if("changeDirection")
			var/direction = params["direction"]
			switch(direction)
				if("North")
					fireDirection = 1
				if("South")
					fireDirection = 2
				if("East")
					fireDirection = 4
				if("West")
					fireDirection = 8
			. = TRUE
		if("fireShells")
			for(var/shell in selectedShells)
				spawn_meteor(shell, fireDirection, null)
				selectedShells -= shell
			. = TRUE
