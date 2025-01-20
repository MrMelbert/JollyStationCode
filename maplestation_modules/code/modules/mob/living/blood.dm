/**
 * When given a name, reagent, or typepath, returns the blood type singleton associated with it
 *
 * For example, you could pass it "A+" and it would return the /datum/blood_type/crew/human/a_plus singleton
 *
 * Arguments
 * * name_reagent_or_typepath - The name of a blood type, the reagent type of a blood type, or the typepath of a blood type
 * Can be null, in which case it will return null. Mostly just for ease of use.
 */
/proc/find_blood_type(name_reagent_or_typepath) as /datum/blood_type
	RETURN_TYPE(/datum/blood_type)

	var/static/list/datum/blood_type/blood_type_singletons
	if(!blood_type_singletons)
		blood_type_singletons = list()
		for(var/datum/blood_type/blood_type_type as anything in subtypesof(/datum/blood_type))
			if(initial(blood_type_type.name))
				blood_type_singletons[blood_type_type] = new blood_type_type()

	// either a blood type, or a reagent that has been instantiated as a blood type
	if(blood_type_singletons[name_reagent_or_typepath])
		return blood_type_singletons[name_reagent_or_typepath]
	// reagents as blood types, (possibly) uninitialized
	if(ispath(name_reagent_or_typepath, /datum/reagent))
		// snowflake to always return universal donor for generic blood
		if(ispath(name_reagent_or_typepath, /datum/reagent/blood))
			return blood_type_singletons[/datum/blood_type/crew/human/o_minus]
		// otherwise we need to find a blood type that uses this reagent
		// this catches stuff like liquid electricity and oil
		for(var/blood_type in blood_type_singletons)
			if(blood_type_singletons[blood_type].reagent_type == name_reagent_or_typepath)
				return blood_type_singletons[blood_type]
		// otherwise otherwise, we make a new one
		. = new /datum/blood_type/random_chemical(name_reagent_or_typepath)
		blood_type_singletons[name_reagent_or_typepath] = .
		return .
	// stuff like "AB+" or "O-" or "L"
	if(istext(name_reagent_or_typepath))
		for(var/blood_type in blood_type_singletons)
			if(blood_type_singletons[blood_type].name == name_reagent_or_typepath)
				return blood_type_singletons[blood_type]
		return null
	// who knows?
	if(name_reagent_or_typepath)
		stack_trace("find_blood_type called with invalid argument ([name_reagent_or_typepath])")
	return null

/**
 * Blood Drying SS
 *
 * Used as a low priority backround system to handling the drying of blood on the ground
 * (basically just handles reducing their bloodiness value over time)
 */
PROCESSING_SUBSYSTEM_DEF(blood_drying)
	name = "Blood Drying"
	flags = SS_NO_INIT | SS_BACKGROUND
	priority = 10
	wait = 4 SECONDS

/**
 * Blood Types
 *
 * Singleton datums which represent, well, blood inside someone
 */
/datum/blood_type
	/// The short-hand name of the blood type
	/// (No name = abstract, won't be instantiated)
	var/name
	/// What color is blood decals spawned of this type
	var/color = COLOR_BLOOD
	/// What blood types can this type receive from?
	/// Itself is always included in this list
	var/list/compatible_types = list()
	/// What reagent is represented by this blood type?
	var/datum/reagent/reagent_type = /datum/reagent/blood
	/// What chem is used to restore this blood type (outside of itself, of course)?
	var/datum/reagent/restoration_chem = /datum/reagent/iron

/datum/blood_type/New()
	. = ..()
	compatible_types |= type_key()

/datum/blood_type/Destroy(force)
	if(!force)
		stack_trace("qdel called on blood type singleton! (use FORCE if necessary)")
		return QDEL_HINT_LETMELIVE

	return ..()

/**
 * Key used to identify this blood type in the global blood_types list
 *
 * Allows for more complex or dynamically generated blood types
 */
/datum/blood_type/proc/type_key()
	return type

/// Gets data to pass to a reagent
/datum/blood_type/proc/get_blood_data(mob/living/sampled_from)
	return null

/**
 * Used to handle any unique facets of blood spawned of this blood type
 *
 * You don't need to worry about updating the icon of the decal,
 * it will be handled automatically after setup is finished
 *
 * Arguments
 * * blood - the blood being set up
 * * new_splat - whether this is a newly instantiated blood decal, or an existing one this blood is being added to
 */
/datum/blood_type/proc/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	return

/**
 * Helper proc to make a blood splatter from the passed mob of this type
 *
 * Arguments
 * * bleeding - the mob bleeding the blood, note we assume this blood type is that mob's blood
 * * blood_turf - the turf to spawn the blood on
 * * drip - whether to spawn a drip or a splatter
 */
/datum/blood_type/proc/make_blood_splatter(mob/living/bleeding, turf/blood_turf, drip)
	if(isgroundlessturf(blood_turf))
		blood_turf = GET_TURF_BELOW(blood_turf)
	if(isnull(blood_turf) || isclosedturf(blood_turf))
		return

	var/list/temp_blood_DNA
	if(drip)
		var/new_blood = /obj/effect/decal/cleanable/blood/drip::bloodiness
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in blood_turf
		if(isnull(drop))
			var/obj/effect/decal/cleanable/blood/splatter = locate() in blood_turf
			if(!QDELETED(splatter))
				splatter.add_mob_blood(bleeding)
				splatter.adjust_bloodiness(new_blood)
				splatter.slow_dry(1 SECONDS * new_blood * BLOOD_PER_UNIT_MODIFIER)
				return splatter

			drop = new(blood_turf, bleeding.get_static_viruses())
			if(!QDELETED(drop))
				drop.add_mob_blood(bleeding)
				drop.random_icon_states -= drop.icon_state
			return drop

		if(length(drop.random_icon_states))
			// Handle adding a single drip to the base atom
			// Makes use of viscontents so every drip can dry at an individual rate (with an individual color)
			var/obj/effect/decal/cleanable/blood/drip/new_drop = new(drop)
			new_drop.icon_state = pick_n_take(drop.random_icon_states)
			new_drop.color = color
			new_drop.vis_flags |= (VIS_INHERIT_LAYER|VIS_INHERIT_PLANE|VIS_INHERIT_ID)
			new_drop.appearance_flags |= (RESET_COLOR)
			new_drop.add_mob_blood(bleeding)
			drop.vis_contents += new_drop
			// Handle adding blood to the base atom
			drop.adjust_bloodiness(new_blood)
			drop.add_mob_blood(bleeding)
			return drop

		temp_blood_DNA = GET_ATOM_BLOOD_DNA(drop) //we transfer the dna from the drip to the splatter
		qdel(drop)//the drip is replaced by a bigger splatter

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/splatter = locate() in blood_turf
	if(isnull(splatter))
		splatter = new(blood_turf, bleeding.get_static_viruses())
		if(QDELETED(splatter)) //Give it up
			return null
	else
		splatter.adjust_bloodiness(BLOOD_AMOUNT_PER_DECAL)
		splatter.slow_dry(1 SECONDS * BLOOD_AMOUNT_PER_DECAL * BLOOD_PER_UNIT_MODIFIER)
	splatter.add_mob_blood(bleeding) //give blood info to the blood decal.
	if(LAZYLEN(temp_blood_DNA))
		splatter.add_blood_DNA(temp_blood_DNA)
	return splatter

/// A base type for all blood related to the crew, for organization's sake
/datum/blood_type/crew

/// A base type for all blood used by humans (NOT humanoids), for organization's sake
/datum/blood_type/crew/human

/datum/blood_type/crew/human/get_blood_data(mob/living/carbon/sampled_from)
	if(!istype(sampled_from) || isnull(sampled_from.dna))
		return ..()

	var/list/blood_data = list()
	//set the blood data
	blood_data["viruses"] = list()

	for(var/datum/disease/disease as anything in sampled_from.diseases)
		blood_data["viruses"] += disease.Copy()

	blood_data["blood_DNA"] = sampled_from.dna.unique_enzymes
	blood_data["resistances"] = LAZYLISTDUPLICATE(sampled_from.disease_resistances)

	var/list/temp_chem = list()
	for(var/datum/reagent/trace_chem as anything in sampled_from.reagents.reagent_list)
		temp_chem[trace_chem.type] = trace_chem.volume
	blood_data["trace_chem"] = list2params(temp_chem)

	blood_data["mind"] = sampled_from.mind || sampled_from.last_mind
	blood_data["ckey"] = sampled_from.ckey || ckey(sampled_from.last_mind?.key)
	blood_data["cloneable"] = !HAS_TRAIT_FROM(sampled_from, TRAIT_SUICIDED, REF(sampled_from))
	blood_data["blood_type"] = sampled_from.dna.human_blood_type
	blood_data["gender"] = sampled_from.gender
	blood_data["real_name"] = sampled_from.real_name
	blood_data["features"] = sampled_from.dna.features
	blood_data["factions"] = sampled_from.faction
	blood_data["quirks"] = list()
	for(var/datum/quirk/sample_quirk as anything in sampled_from.quirks)
		blood_data["quirks"] += sample_quirk.type
	return blood_data

/datum/blood_type/crew/human/a_minus
	name = "A-"
	compatible_types = list(
		/datum/blood_type/crew/human/o_minus,
	)

/datum/blood_type/crew/human/a_plus
	name = "A+"
	compatible_types = list(
		/datum/blood_type/crew/human/a_minus,
		/datum/blood_type/crew/human/a_plus,
		/datum/blood_type/crew/human/o_minus,
		/datum/blood_type/crew/human/o_plus,
	)

/datum/blood_type/crew/human/b_minus
	name = "B-"
	compatible_types = list(
		/datum/blood_type/crew/human/b_minus,
		/datum/blood_type/crew/human/o_minus,
	)

/datum/blood_type/crew/human/b_plus
	name = "B+"
	compatible_types = list(
		/datum/blood_type/crew/human/b_minus,
		/datum/blood_type/crew/human/b_plus,
		/datum/blood_type/crew/human/o_minus,
		/datum/blood_type/crew/human/o_plus,
	)

/datum/blood_type/crew/human/ab_minus
	name = "AB-"
	compatible_types = list(
		/datum/blood_type/crew/human/b_minus,
		/datum/blood_type/crew/human/ab_minus,
		/datum/blood_type/crew/human/a_minus,
		/datum/blood_type/crew/human/o_minus,
	)

/datum/blood_type/crew/human/ab_plus
	name = "AB+"
	// Universal Recipient

/datum/blood_type/crew/human/ab_plus/New()
	. = ..()
	compatible_types |= subtypesof(/datum/blood_type/crew/human)

/datum/blood_type/crew/human/o_minus
	name = "O-"
	// Universal Donor

/datum/blood_type/crew/human/o_plus
	name = "O+"
	compatible_types = list(
		/datum/blood_type/crew/human/o_minus,
		/datum/blood_type/crew/human/o_plus,
	)

/datum/blood_type/crew/lizard
	name = "L"
	color = "#047200" // Some species of lizards have mutated green blood due to biliverdin build up
	compatible_types = list(/datum/blood_type/silver/lizard)

/datum/blood_type/silver
	name = "Ag"
	color = "#c9c9c99c"
	reagent_type = /datum/reagent/silver

/datum/blood_type/silver/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat)
	blood.can_dry = FALSE
	blood.emissive_alpha = max(blood.emissive_alpha, new_splat ? 125 : 63)

/datum/blood_type/silver/lizard
	name = "sL"
	compatible_types = list(/datum/blood_type/crew/lizard)

/datum/blood_type/crew/skrell
	name = "S"
	color = "#009696" // Did you know octopi have blue blood, as it contains hemocyanin rather than hemoglobin? It binds to copper instead of Iron
	restoration_chem = /datum/reagent/copper

/datum/blood_type/crew/ethereal
	name = "LE"
	color = "#97ee63"
	reagent_type = /datum/reagent/consumable/liquidelectricity

/datum/blood_type/crew/ethereal/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat)
	blood.emissive_alpha = max(blood.emissive_alpha, new_splat ? 188 : 125)
	if(!new_splat)
		return
	blood.can_dry = FALSE
	RegisterSignals(blood, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY), PROC_REF(on_cleaned))

/datum/blood_type/crew/ethereal/proc/on_cleaned(obj/effect/decal/cleanable/source, mob/living/user, obj/item/tool, ...)
	SIGNAL_HANDLER

	if(!istype(tool, /obj/item/mop))
		return NONE
	if(!tool.reagents?.has_reagent(chemical_flags = REAGENT_CLEANS))
		return NONE
	if(source.bloodiness <= BLOOD_AMOUNT_PER_DECAL * 0.2)
		return NONE
	if(!user.electrocute_act(clamp(sqrt(source.bloodiness * BLOOD_PER_UNIT_MODIFIER * 4), 5, 50), source, flags = SHOCK_SUPPRESS_MESSAGE))
		return NONE
	playsound(source, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, FALSE, source)
	user.visible_message(
		span_warning("Upon touching [source] with [tool], the [initial(reagent_type.name)] inside conducts, shocking [user]!"),
		span_warning("Upon touching [source] with [tool], the [initial(reagent_type.name)] conducts, shocking you!"),
	)
	return ITEM_INTERACT_BLOCKING

/// Oil based blood for robot lifeforms
/datum/blood_type/oil
	name = "Oil"
	color = "#1f1a00"
	reagent_type = /datum/reagent/fuel/oil

/datum/blood_type/oil/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat)
	if(!new_splat)
		return
	// Oil blood will never dry and can be ignited with fire
	blood.can_dry = FALSE
	blood.AddElement(/datum/element/easy_ignite)

/// A universal blood type which accepts everything
/datum/blood_type/universal
	name = "U"

/datum/blood_type/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)

/// Clown blood, only used on April Fools
/datum/blood_type/clown
	name = "C"
	color = "#FF00FF"
	reagent_type = /datum/reagent/colorful_reagent

/// Slimeperson's jelly blood, is also known as "toxic" or "toxin" blood
/datum/blood_type/slime
	name = "TOX"
	color = /datum/reagent/toxin/slimejelly::color
	reagent_type = /datum/reagent/toxin/slimejelly

/// Water based blood for Podpeople primairly
/datum/blood_type/water
	name = "H2O"
	color = /datum/reagent/water::color
	reagent_type = /datum/reagent/water

/// Snails have Lube for blood, for some reason?
/datum/blood_type/snail
	name = "Lube"
	reagent_type = /datum/reagent/lube

/datum/blood_type/snail/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat)
	if(blood.bloodiness < BLOOD_AMOUNT_PER_DECAL)
		return
	var/slip_amt = new_splat ? 4 SECONDS : 1 SECONDS
	var/slip_flags = new_splat ? (NO_SLIP_WHEN_WALKING | SLIDE) : (NO_SLIP_WHEN_WALKING)
	blood.AddComponent(/datum/component/slippery, slip_amt, slip_flags)

/// For Xeno blood, though they don't actually USE blood
/datum/blood_type/xenomorph
	name = "X*"
	color = "#96bb00"
	reagent_type = /datum/reagent/toxin/acid

/// For simplemob blood, which also largely don't actually use blood
/datum/blood_type/animal
	name = "Y-"

/// An abstract-ish blood type used particularly for species with blood set to random reagents, such as podpeople
/datum/blood_type/random_chemical

/datum/blood_type/random_chemical/New(datum/reagent/reagent_type)
	. = ..()
	src.name = initial(reagent_type.name)
	src.color = initial(reagent_type.color)
	src.reagent_type = reagent_type
	src.restoration_chem = reagent_type

/datum/blood_type/random_chemical/type_key()
	return reagent_type
