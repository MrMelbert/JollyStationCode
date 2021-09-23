// -- Flavor text datum stuff. --
/// Global list of all flavor texts we have generated. Associated list of [mob name] to [datum ref]
GLOBAL_LIST_EMPTY(flavor_texts)

/*
 * Create a flavor text datum for [added_mob].
 *
 * Returns TRUE if successful, FALSE otherwise.
 */
/proc/add_mob_flavor_text(mob/living/added_mob)
	if(!added_mob?.client?.prefs)
		return FALSE
	if(!istype(added_mob))
		return FALSE

	if(!GLOB.flavor_texts[added_mob.real_name])
		var/datum/flavor_text/found_text = new /datum/flavor_text(added_mob)
		GLOB.flavor_texts[added_mob.real_name] = found_text
		added_mob.linked_flavor = found_text

	return TRUE

/// Flavor text define for carbons.
/mob/living
	/// The flavor text linked to our carbon.
	var/datum/flavor_text/linked_flavor

/mob/living/Destroy()
	linked_flavor = null // We should never QDEL flavor text datums.
	return ..()

/// The actual flavor text datum. This should never be qdeleted - just leave it floating in the global list.
/datum/flavor_text
	/// The mob that owns this flavor text.
	var/datum/weakref/owner
	/// The name associated with this flavor text.
	var/name
	/// The species associated with this flavor text.
	var/linked_species
	/// The actual flavor text.
	var/flavor_text
	/// General records associated with this flavor text
	var/gen_records
	/// Medical records associated with this flavor text
	var/med_records
	/// Security records associated with this flavor text
	var/sec_records
	/// Exploitable info associated with this flavor text
	var/expl_info

/datum/flavor_text/New(mob/living/initial_linked_mob)
	owner = WEAKREF(initial_linked_mob)
	name = initial_linked_mob.client?.prefs?.read_preference(/datum/preference/name/real_name)

	if(issilicon(initial_linked_mob))
		linked_species = "silicon"
	else
		var/datum/species/our_species =initial_linked_mob.client?.prefs?.read_preference(/datum/preference/choiced/species)
		linked_species = our_species.id

/*
 * Get the flavor text formatted.
 *
 * examiner - who's POV we're gettting this flavor text from
 * shorten - whether to cut it off at [EXAMINE_FLAVOR_MAX_DISPLAYED]
 *
 * returns a string
 */
/datum/flavor_text/proc/get_flavor_text(mob/living/carbon/human/examiner, shorten = TRUE)
	. = flavor_text

	if(shorten && length(.) > EXAMINE_FLAVOR_MAX_DISPLAYED)
		. = TextPreview(., EXAMINE_FLAVOR_MAX_DISPLAYED)
		. += " <a href='?src=[REF(src)];flavor_text=1'>\[More\]</a>"

	if(.)
		. += "\n"

/*
 * Get the href buttons for all the mob's records, formatted.
 *
 * examiner - who's POV we're gettting the records from
 *
 * returns a string
 */
/datum/flavor_text/proc/get_records_text(mob/living/carbon/human/examiner)
	if(!examiner)
		CRASH("get_records_text() called without an examiner argument - proc is not implemented for a null examiner")

	. = ""

	// Antagonists can see exploitable info.
	if(examiner.mind?.antag_datums && expl_info)
		for(var/datum/antagonist/antag_datum as anything in examiner.mind.antag_datums)
			if(antag_datum.antag_flags & CAN_SEE_EXPOITABLE_INFO)
				. += "<a href='?src=[REF(src)];exploitable_info=1'>\[Exploitable Info\]</a>"
				break

	// Medhuds can see medical records.
	if(examiner.check_med_hud_and_access())
		if(med_records)
			. += "<a href='?src=[REF(src)];medical_records=1'>\[Past Medical Records\]</a>"
		if(gen_records)
			. += "<a href='?src=[REF(src)];general_records=1'>\[General Records\]</a>"
	// Sechuds can see security records.
	if(sec_records && examiner.check_sec_hud_and_access())
		. += "<a href='?src=[REF(src)];security_records=1'>\[Past Security Records\]</a>"

	if(.)
		. += "\n"

/*
 * All-In-One proc that gets the flavor text and record hrefs and formats it into one message.
 *
 * examiner - who's POV we're gettting this flavor text from
 * shorten - whether to cut it off at [EXAMINE_FLAVOR_MAX_DISPLAYED]
 *
 * returns a string
 */
/datum/flavor_text/proc/get_flavor_and_records_links(mob/living/carbon/human/examiner, shorten = TRUE)
	if(!examiner)
		CRASH("get_flavor_and_records_links() called without an examiner argument - proc is not implemented for a null examiner")

	. = ""

	// Whether or not we would have additional info on `examine_more()`.
	var/list/added_info = list()

	// If the client has flavor text set.
	if(flavor_text)
		var/found_flavor_text = get_flavor_text(examiner, shorten)
		. += found_flavor_text
		if(length(found_flavor_text) > EXAMINE_FLAVOR_MAX_DISPLAYED)
			added_info += "longer flavor text"

	// Antagonists can see expoitable information.
	if(expl_info && examiner.mind?.antag_datums)
		for(var/datum/antagonist/antag_datum as anything in examiner.mind.antag_datums)
			if(antag_datum.antag_flags & CAN_SEE_EXPOITABLE_INFO)
				added_info += "exploitable information"
				break
	// Medhuds can see medical and general records, with adequate access.
	if(examiner.check_med_hud_and_access() && (med_records || gen_records))
		added_info += "past records"
	// Sechuds can see security records, with adequate access.
	else if(examiner.check_sec_hud_and_access() && sec_records)
		added_info += "past records"

	if(added_info.len && shorten)
		. += span_smallnoticeital("This individual may have [english_list(added_info, and_text = " or ", final_comma_text = ",")] available if you [EXAMINE_CLOSER_BOLD].\n")
	else
		. += get_records_text(examiner)

/datum/flavor_text/Topic(href, href_list)
	. = ..()
	if(href_list["flavor_text"])
		if(flavor_text)
			var/datum/browser/popup = new(usr, "[name]'s flavor text", "[name]'s Flavor Text (expanded)", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s flavor text (expanded)", replacetext(flavor_text, "\n", "<BR>")))
			popup.open()
			return

	if(href_list["general_records"])
		if(gen_records)
			var/datum/browser/popup = new(usr, "[name]'s gen rec", "[name]'s General Record", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s general records", replacetext(gen_records, "\n", "<BR>")))
			popup.open()
			return

	if(href_list["security_records"])
		if(sec_records)
			var/datum/browser/popup = new(usr, "[name]'s sec rec", "[name]'s Security Record", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s security records", replacetext(sec_records, "\n", "<BR>")))
			popup.open()
			return

	if(href_list["medical_records"])
		if(med_records)
			var/datum/browser/popup = new(usr, "[name]'s med rec", "[name]'s Medical Record", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s medical records", replacetext(med_records, "\n", "<BR>")))
			popup.open()
			return

	if(href_list["exploitable_info"])
		if(expl_info)
			var/datum/browser/popup = new(usr, "[name]'s exp info", "[name]'s Exploitable Info", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s exploitable information", replacetext(expl_info, "\n", "<BR>")))
			popup.open()
			return
