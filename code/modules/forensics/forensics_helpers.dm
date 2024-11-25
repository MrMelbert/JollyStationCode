/// Adds a list of fingerprints to the atom
/atom/proc/add_fingerprint_list(list/fingerprints_to_add) //ASSOC LIST FINGERPRINT = FINGERPRINT
	if (QDELING(src))
		return FALSE
	if (isnull(fingerprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(fingerprints = fingerprints_to_add)
	else
		forensics = new(src, fingerprints = fingerprints_to_add)
	return TRUE

/// Adds a single fingerprint to the atom
/atom/proc/add_fingerprint(mob/suspect, ignoregloves = FALSE) //Set ignoregloves to add prints irrespective of the mob having gloves on.
	if (QDELING(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fingerprint(suspect, ignoregloves)
	return TRUE

/// Add a list of fibers to the atom
/atom/proc/add_fiber_list(list/fibers_to_add) //ASSOC LIST FIBERTEXT = FIBERTEXT
	if (QDELING(src))
		return FALSE
	if (isnull(fibers_to_add))
		return
	if (forensics)
		forensics.inherit_new(fibers = fibers_to_add)
	else
		forensics = new(src, fibers = fibers_to_add)
	return TRUE

/// Adds a single fiber to the atom
/atom/proc/add_fibers(mob/living/carbon/human/suspect)
	if (QDELING(src))
		return FALSE
	var/old = 0
	if(suspect.gloves && istype(suspect.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/suspect_gloves = suspect.gloves
		old = length(GET_ATOM_BLOOD_DNA(suspect_gloves))
		if(suspect_gloves.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect_gloves)) && GET_ATOM_BLOOD_DNA_LENGTH(suspect_gloves) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				suspect_gloves.transfer_blood -= 1
	else if(suspect.blood_in_hands > 1)
		old = length(GET_ATOM_BLOOD_DNA(suspect))
		if(add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect)) && GET_ATOM_BLOOD_DNA_LENGTH(suspect) > old)
			suspect.blood_in_hands -= 1
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fibers(suspect)
	return TRUE

/// Adds a list of hiddenprints to the atom
/atom/proc/add_hiddenprint_list(list/hiddenprints_to_add) //NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if (QDELING(src))
		return FALSE
	if (isnull(hiddenprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(hiddenprints = hiddenprints_to_add)
	else
		forensics = new(src, hiddenprints = hiddenprints_to_add)
	return TRUE

/// Adds a single hiddenprint to the atom
/atom/proc/add_hiddenprint(mob/suspect)
	if (QDELING(src))
		return FALSE
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_hiddenprint(suspect)
	return TRUE

// NON-MODULE CHANGE for blood
/atom
	/// Cached mixed color of all blood DNA on us
	VAR_PROTECTED/cached_blood_dna_color

/atom/proc/get_blood_dna_color()
	if(cached_blood_dna_color)
		return cached_blood_dna_color

	var/list/colors = list()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	for(var/dna_sample in all_dna)
		colors += find_blood_type(all_dna[dna_sample]).color

	var/final_color = pop(colors)
	for(var/color in colors)
		final_color = BlendRGB(final_color, color, 0.5)
	cached_blood_dna_color = final_color
	return final_color

/obj/effect/decal/cleanable/blood/drip/get_blood_dna_color()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	var/blood_type_to_use = all_dna[all_dna[1]]
	return find_blood_type(blood_type_to_use).color

/// Adds blood dna to the atom
/atom/proc/add_blood_DNA(list/blood_DNA_to_add) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add)
	if (QDELING(src))
		return FALSE
	if (isnull(blood_DNA_to_add))
		return FALSE
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	cached_blood_dna_color = null
	return TRUE

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_DNA_to_add)
	var/first_dna = GET_ATOM_BLOOD_DNA_LENGTH(src)
	if(!..())
		return FALSE
	if(dried)
		return TRUE
	color = get_blood_dna_color()
	// Imperfect, ends up with some blood types being double-set-up, but harmless (for now)
	for(var/new_blood in blood_DNA_to_add)
		var/datum/blood_type/blood = find_blood_type(blood_DNA_to_add[new_blood])
		blood.set_up_blood(src, first_dna == 0)
	update_appearance()
	update_blood_drying_effect()
	return TRUE

/obj/item/add_blood_DNA(list/blood_DNA_to_add)
	if(item_flags & NO_BLOOD_ON_ITEM)
		return FALSE
	return ..()

// NON-MODULE CHANGE for blood
/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if(.)
		transfer_blood = rand(2, 4)
	return .

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/blood_splatter = locate() in src
	if(!blood_splatter)
		blood_splatter = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	if(!QDELETED(blood_splatter))
		blood_splatter.add_blood_DNA(blood_dna) //give blood info to the blood decal.
		return TRUE //we bloodied the floor
	return FALSE

/turf/closed/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return FALSE

/obj/item/clothing/under/add_blood_DNA(list/blood_DNA_to_add)
	. = ..()
	if(!.)
		return
	for(var/obj/item/clothing/accessory/thing_accessory as anything in attached_accessories)
		if(prob(66))
			continue
		thing_accessory.add_blood_DNA(blood_DNA_to_add)

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	return add_blood_DNA_to_items(blood_DNA_to_add)

/// Adds blood DNA to certain slots the mob is wearing
/mob/living/carbon/human/proc/add_blood_DNA_to_items(
	list/blood_DNA_to_add,
	target_flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING|ITEM_SLOT_GLOVES|ITEM_SLOT_HEAD|ITEM_SLOT_MASK,
)
	if(QDELING(src))
		return FALSE
	if(!length(blood_DNA_to_add))
		return FALSE

	// Don't messy up our jumpsuit if we're got a coat
	if((target_flags & ITEM_SLOT_OCLOTHING) && (wear_suit?.body_parts_covered & CHEST))
		target_flags &= ~ITEM_SLOT_ICLOTHING

	var/dirty_hands = !!(target_flags & (ITEM_SLOT_GLOVES|ITEM_SLOT_HANDS))
	var/dirty_feet = !!(target_flags & ITEM_SLOT_FEET)
	var/slots_to_bloody = target_flags & ~check_obscured_slots()
	var/list/all_worn = get_equipped_items()
	for(var/obj/item/thing as anything in all_worn)
		if(thing.slot_flags & slots_to_bloody)
			thing.add_blood_DNA(blood_DNA_to_add)
		if(thing.body_parts_covered & HANDS)
			dirty_hands = FALSE
		if(thing.body_parts_covered & FEET)
			dirty_feet = FALSE

	if(slots_to_bloody & ITEM_SLOT_HANDS)
		for(var/obj/item/thing in held_items)
			thing.add_blood_DNA(blood_DNA_to_add)

	if(dirty_hands || dirty_feet || !length(all_worn))
		if(isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
		if(dirty_hands)
			blood_in_hands = rand(2, 4)

	cached_blood_dna_color = null
	update_clothing(slots_to_bloody)
	return TRUE

/mob/living/carbon/human/proc/add_fingerprints_to_items(mob/living/from_mob, target_flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)
	if(QDELING(src))
		return FALSE

	var/slots_to_fingerprint = target_flags & ~check_obscured_slots()
	for(var/obj/item/thing as anything in get_equipped_items())
		if(thing.slot_flags & slots_to_fingerprint)
			. ||= thing.add_fingerprint(from_mob)

	if(!.)
		. = add_fingerprint(from_mob)

	return .

/mob/living/add_blood_DNA(list/blood_DNA_to_add)
	if(QDELING(src))
		return FALSE
	if(!length(blood_DNA_to_add))
		return FALSE
	if(isnull(forensics))
		forensics = new(src)
	forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	cached_blood_dna_color = null
	return TRUE

/*
 * Transfer all the fingerprints and hidden prints from [src] to [transfer_to].
 */
/atom/proc/transfer_fingerprints_to(atom/transfer_to)
	transfer_to.add_fingerprint_list(GET_ATOM_FINGERPRINTS(src))
	transfer_to.add_hiddenprint_list(GET_ATOM_HIDDENPRINTS(src))
	transfer_to.fingerprintslast = fingerprintslast

/*
 * Transfer all the fibers from [src] to [transfer_to].
 */
/atom/proc/transfer_fibers_to(atom/transfer_to)
	transfer_to.add_fiber_list(GET_ATOM_FIBRES(src))
