/client/proc/warfareEvent()
	set name = "Warfare Module"
	set desc = "Allows you to perform various actions related to warfare"
	set category = "Admin.Events"

	var/datum/warfare_event/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/warfare_event
	var/client/holder //client of whoever is using this datum
	var/list/selectedShells = list() //list of selected shells to fire

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
				if("smallAP")
					selectedShells += /obj/effect/meteor/shell/small_ap
				if("WMDHE")
					selectedShells += /obj/effect/meteor/shell/small_wmd_he
				if("WMDFlak")
					selectedShells += /obj/effect/meteor/shell/small_wmd_flak
				if("clusterAP")
					selectedShells += /obj/effect/meteor/shell/small_cluster_ap
				if("clusterWMDHE")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_he
				if("clusterWMDFlak")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/big_cluster_wmd_flak
				if("kajari")
					// ADD CONFIRMATION.
					selectedShells += /obj/effect/meteor/shell/kajari
				. = TRUE
				return
