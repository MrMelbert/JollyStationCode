// Because pain puts such an emphasis on anesthetic for surgery,
// and I hate the fact that using anesthetic leaves gas in the air
// (which is actually realistic, and a major danger of using anesthetic)
// Scrubbers located in areas which commonly use anesthesia will scrub nitrous by default
/obj/machinery/atmospherics/components/unary/vent_scrubber/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	// Scrubbers should scrub nitrous from the rooms which we use anesthetic in most commonly
	var/static/list/scrub_nitrous_by_default_areas = typecacheof(list(
		/area/station/medical/cryo,
		/area/station/medical/exam_room,
		/area/station/medical/morgue,
		/area/station/medical/patients_rooms,
		/area/station/medical/surgery,
		/area/station/medical/treatment_center,
		/area/station/science/robotics,
		/area/station/security/medical,
		/area/station/security/execution,
	))

	var/area/scrubber_area = get_area(src)
	if(is_type_in_typecache(scrubber_area, scrub_nitrous_by_default_areas))
		filter_types |= /datum/gas/nitrous_oxide
		set_widenet(TRUE)
