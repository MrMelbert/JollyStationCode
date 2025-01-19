/client/proc/warfareEvent()
	set name = "Warfare Module"
	set desc = "Allows you to perform various actions related to warfare"
	set category = "Admin.Events"

	var/datum/warfare_event/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/warfare_event
	var/client/holder //client of whoever is using this datum
	var/list/selectedShells = list() //list of selected shells to fire (obj)
	var/list/selectedNames = list() //list of selected shells to fire (but the name)
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
	data["selectedNames"] = selectedNames
	return data

/datum/warfare_event/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("addShell")
			var/selected = params["selected"]
			switch(selected)
				if("460mm Rocket Assisted AP")
					selectedShells += /obj/effect/meteor/shell/big_ap
					selectedNames += "460mm Rocket Assisted AP"
					. = TRUE
				if("160mm Rocket Assisted AP")
					selectedShells += /obj/effect/meteor/shell/small_ap
					selectedNames += "160mm Rocket Assisted AP"
					. = TRUE
				if("160mm HE")
					selectedShells += /obj/effect/meteor/shell/small_wmd_he
					selectedNames += "160mm HE"
					. = TRUE
				if("160mm Flak")
					selectedShells += /obj/effect/meteor/shell/small_wmd_flak
					selectedNames += "160mm Flak"
					. = TRUE
				if("160mm Cluster AP")
					selectedShells += /obj/effect/meteor/shell/small_cluster_ap
					selectedNames += "160mm Cluster AP"
					. = TRUE
				if("460mm Cluster HE")
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_he
					selectedNames += "460mm Cluster HE"
					. = TRUE
				if("460mm Cluster Flak")
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_flak
					selectedNames += "460mm Cluster Flak"
					. = TRUE
				if("WMD KAJARI")
					selectedShells += /obj/effect/meteor/shell/kajari
					selectedNames += "WMD KAJARI"
					. = TRUE
		if("removeShell")
			var/selected = params["selected"]
			switch(selected)
				if("460mm Rocket Assisted AP")
					selectedShells -= /obj/effect/meteor/shell/big_ap
					selectedNames -= "460mm Rocket Assisted AP"
					. = TRUE
				if("160mm Rocket Assisted AP")
					selectedShells -= /obj/effect/meteor/shell/small_ap
					selectedNames -= "160mm Rocket Assisted AP"
					. = TRUE
				if("160mm HE")
					selectedShells -= /obj/effect/meteor/shell/small_wmd_he
					selectedNames -= "160mm HE"
					. = TRUE
				if("160mm Flak")
					selectedShells -= /obj/effect/meteor/shell/small_wmd_flak
					selectedNames -= "160mm Flak"
					. = TRUE
				if("160mm Cluster AP")
					selectedShells -= /obj/effect/meteor/shell/small_cluster_ap
					selectedNames -= "160mm Cluster AP"
					. = TRUE
				if("460mm Cluster HE")
					selectedShells -= /obj/effect/meteor/shell/big_cluster_wmd_he
					selectedNames -= "460mm Cluster HE"
					. = TRUE
				if("460mm Cluster Flak")
					selectedShells -= /obj/effect/meteor/shell/big_cluster_wmd_flak
					selectedNames -= "460mm Cluster Flak"
					. = TRUE
				if("WMD KAJARI")
					selectedShells -= /obj/effect/meteor/shell/kajari
					selectedNames -= "WMD KAJARI"
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
				var/list/chosenList = list()
				chosenList[shell] = 1
				spawn_meteor(chosenList, fireDirection, null)
				selectedShells -= shell
			for(var/name in selectedNames)
				selectedNames -= name
			. = TRUE
