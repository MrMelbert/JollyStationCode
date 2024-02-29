/// Adds a list of fingerprints to the atom
/atom/proc/add_fingerprint_list(list/fingerprints_to_add) //ASSOC LIST FINGERPRINT = FINGERPRINT
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
	if (isnull(fibers_to_add))
		return
	if (forensics)
		forensics.inherit_new(fibers = fibers_to_add)
	else
		forensics = new(src, fibers = fibers_to_add)
	return TRUE

/// Adds a single fiber to the atom
/atom/proc/add_fibers(mob/living/carbon/human/suspect)
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
	if (isnull(hiddenprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(hiddenprints = hiddenprints_to_add)
	else
		forensics = new(src, hiddenprints = hiddenprints_to_add)
	return TRUE

/// Adds a single hiddenprint to the atom
/atom/proc/add_hiddenprint(mob/suspect)
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_hiddenprint(suspect)
	return TRUE

// NON-MODULE CHANGE for blood
/atom
	/// Cached mixed color of all blood DNA on us
	var/blood_dna_color

/atom/proc/get_blood_dna_color()
	if(blood_dna_color)
		return blood_dna_color

	var/list/colors = list()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	for(var/dna_sample in all_dna)
		var/datum/blood_type/blood = GLOB.blood_types[all_dna[dna_sample]]
		colors += blood.color

	var/final_color = pop(colors)
	for(var/color in colors)
		final_color = BlendRGB(final_color, color, 0.5)
	blood_dna_color = final_color
	return final_color

/// Adds blood dna to the atom
/atom/proc/add_blood_DNA(list/blood_DNA_to_add) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add)
	if (isnull(blood_DNA_to_add))
		return FALSE
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	blood_dna_color = null
	return TRUE

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_DNA_to_add)
	var/first_dna = GET_ATOM_BLOOD_DNA_LENGTH(src)
	if(!..())
		return FALSE

	color = get_blood_dna_color()
	// Imperfect, ends up with some blood types being double-set-up, but harmless (for now)
	for(var/new_blood in blood_DNA_to_add)
		var/datum/blood_type/blood = GLOB.blood_types[blood_DNA_to_add[new_blood]]
		blood.set_up_blood(src, first_dna == 0)
	update_appearance()
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

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_DNA_to_add)
		update_worn_oversuit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_DNA_to_add)
		update_worn_undersuit()
	if(gloves)
		var/obj/item/clothing/gloves/mob_gloves = gloves
		mob_gloves.add_blood_DNA(blood_DNA_to_add)
	else if(length(blood_DNA_to_add))
		if (isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
		blood_in_hands = rand(2, 4)
	blood_dna_color = null
	update_worn_gloves()
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
