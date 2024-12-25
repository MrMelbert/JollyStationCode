
/obj/item/borg/upgrade/magic
	name = "borg magical focus"
	desc = "A magical focus which allows borgs to create magic."
	icon = 'maplestation_modules/icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "cyborg_magic_focus"
	w_class = WEIGHT_CLASS_SMALL

	has_initial_mana_pool = TRUE
	///the mana pool from the borg that the upgrade is inside. Set to null when not in a borg.
	var/datum/mana_pool/borg_mana_pool = null

//mana pool stuff for the magic borg upgrade
/datum/mana_pool/borg_focus
	maximum_mana_capacity = CARBON_BASE_MANA_CAPACITY //same as carbons!

/obj/item/borg/upgrade/magic/get_initial_mana_pool_type()
	return /datum/mana_pool/mob/living/silicon

/obj/item/borg/upgrade/magic/action(mob/living/silicon/robot/borg)
	. = ..()
	if(.)
		//add the spells to the borg's actions
		var/list/list_value = borg.client.prefs.read_preference(/datum/preference/spellbook)
		for (var/datum/spellbook_item/entry in spellbook_list_to_datums(list_value))
			entry.apply(borg, list_value[entry.type])

		//store the borg's current mana pool for returning it when the module is removed
		if (borg.mana_pool != null) //incase the borg has no mana pool
			borg_mana_pool = borg.mana_pool

		//put the upgrade's magic pool into the borg.
		if(src.mana_pool != null)
			mana_pool = borg.initialize_mana_pool(src.mana_pool)
			borg.set_mana_pool(mana_pool) // no need to check if the borg has a mana pool, as this makes one.

		//if the upgrade has no magic pool for some reason, make one!
		else
			mana_pool = borg.initialize_mana_pool(src.mana_pool)
			borg.set_mana_pool(mana_pool)

/obj/item/borg/upgrade/magic/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(.)
		//removes the spells
		for (var/datum/action/cooldown/spell/action_to_remove in borg.actions)
			action_to_remove.Remove(borg)
		//resets the mana pool to before
		borg.set_mana_pool(borg_mana_pool)
		borg_mana_pool = null //removes the borg's mana pool var from the upgrade as this upgrade being removed from the borg

//borg panel qdels, so i gotta make sure it works when borg panel removes it.
// /obj/item/borg/upgrade/magic/proc/clear_on_delete(datum/to_clear)
// 	RegisterSignal(to_clear, COMSIG_QDELETING, PROC_REF(on_delete))

// /obj/item/borg/upgrade/magic/proc/on_delete()
// 	if(.)
// 		//removes the spells
// 		for (var/datum/action/cooldown/spell/action_to_remove in borg.actions)
// 			action_to_remove.Remove(borg)
// 			//resets the mana pool to before
// 		borg.set_mana_pool(borg_mana_pool)
// 		borg_mana_pool = null //removes the borg's mana pool var from the upgrade as this upgrade being removed from the borg
