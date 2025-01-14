//the copy_outfit admin proc, but reused for internal usage, sucks, but thats from the original also being bad
/mob/living/carbon/human/proc/copy_to_outfit(datum/outfit/varedit/outfit_copy)
	//Copy equipment
	var/list/result = list()
	var/list/slots_to_check = list(ITEM_SLOT_ICLOTHING,ITEM_SLOT_BACK,ITEM_SLOT_OCLOTHING,ITEM_SLOT_BELT,ITEM_SLOT_GLOVES,ITEM_SLOT_FEET,ITEM_SLOT_HEAD,ITEM_SLOT_MASK,ITEM_SLOT_NECK,ITEM_SLOT_EARS,ITEM_SLOT_EYES,ITEM_SLOT_ID,ITEM_SLOT_SUITSTORE,ITEM_SLOT_LPOCKET,ITEM_SLOT_RPOCKET)
	for(var/s in slots_to_check)
		var/obj/item/I = get_item_by_slot(s)
		var/vedits = collect_vv(I)
		if(vedits)
			result["[s]"] = vedits
		if(istype(I))
			outfit_copy.set_equipment_by_slot(s,I.type)

	//Copy access
	outfit_copy.stored_access = list()
	var/obj/item/id_slot = get_item_by_slot(ITEM_SLOT_ID)
	if(id_slot)
		outfit_copy.stored_access |= id_slot.GetAccess()
		var/obj/item/card/id/ID = id_slot.GetID()
		if(ID)
			if(ID.registered_name == real_name)
				outfit_copy.update_id_name = TRUE
			if(ID.trim)
				outfit_copy.id_trim = ID.trim.type
	//Copy hands
	if(held_items.len >= 2)
		var/obj/item/left_hand = held_items[1]
		var/obj/item/right_hand = held_items[2]
		if(istype(left_hand))
			outfit_copy.l_hand = left_hand.type
			var/vedits = collect_vv(left_hand)
			if(vedits)
				result["LHAND"] = vedits
		if(istype(right_hand))
			outfit_copy.r_hand = right_hand.type
			var/vedits = collect_vv(left_hand)
			if(vedits)
				result["RHAND"] = vedits
	outfit_copy.vv_values = result
	//Copy backpack contents if exist.
	var/obj/item/backpack = get_item_by_slot(ITEM_SLOT_BACK)
	if(istype(backpack) && backpack.atom_storage)
		var/list/bp_stuff = backpack.atom_storage.return_inv(recursive = FALSE)
		var/list/typecounts = list()
		for(var/obj/item/backpack_item in bp_stuff)
			if(typecounts[backpack_item.type])
				typecounts[backpack_item.type] += 1
			else
				typecounts[backpack_item.type] = 1
		outfit_copy.backpack_contents = typecounts
	//Copy implants
	outfit_copy.implants = list()
	for(var/obj/item/implant/I in implants)
		outfit_copy.implants |= I.type

// species mobs
/mob/living/carbon/human/species/werewolf
	race = /datum/species/werewolf
