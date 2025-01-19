/datum/reagent/consumable/liquidelectricity/auric
	name = "Processed Auric Tesla"
	description = "A processed metallic gel that seems to spark and crackle with electricity. It is unlike anything you've seen before."
	color = "#fff870"
	taste_description = "absolute power"
	var/shock_timer = 0
	var/shock_speed = 20
	creation_purity = 1

/datum/reagent/consumable/liquidelectricity/auric/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	shock_timer++
	if(shock_timer >= rand(0, 50 - shock_speed))
		shock_timer = 0
		affected_mob.electrocute_act(rand(10, 30), "Auric Tesla in their body", 1, SHOCK_NOGLOVES)
		playsound(affected_mob, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	if(affected_mob?.mana_pool)
		affected_mob.adjust_personal_mana(10) // HOLY JESUS, BATMAN.

/datum/chemical_reaction/auricelectrolysis
	results = list(/datum/reagent/oxygen = 10, /datum/reagent/hydrogen = 20)
	required_reagents = list(/datum/reagent/water = 10)
	required_catalysts = list(/datum/reagent/consumable/liquidelectricity/auric = 1)
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_CHEMICAL
	mix_message = "the reaction zaps suddenly!"
	mix_sound = 'sound/effects/supermatter.ogg'

/datum/reagent/gravitum/aerialite
	name = "Alloyed Aerialite"
	description = "A powdered alloy of a strange blue metal that seems to defy the laws of gravity. It is unlike anything you've seen before."
	color = "#00aaff"
	taste_description = "the boundless sky"
	chemical_flags = null
	taste_mult = 1
	reagent_state = SOLID

/datum/reagent/resmythril
	name = "Resonant Mythril"
	description = "A powdered turquoise metal that seems to resonate with electromagnetic waves. It is unlike anything you've seen before."
	color = "#14747c"
	taste_description = "resonance"
	reagent_state = SOLID

/datum/chemical_reaction/resmythril_emp
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/resmythril = 1)
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	mix_message = "the reaction resonates!"
	mix_sound = 'sound/machines/defib_zap.ogg'

/datum/chemical_reaction/resmythril_emp/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	empulse(location, round(created_volume / 12), round(created_volume / 7), 1)
	holder.clear_reagents()

/datum/reagent/exodust
	name = "Crystalline ExoPrism"
	description = "A pulverized crystalline dust that seems to be unusually energized. It is unlike anything you've seen before."
	color = "#d3d1ed"
	taste_description = "a forge of a bygone era"
	reagent_state = SOLID

/datum/chemical_reaction/exo_stabilizer
	results = list(/datum/reagent/exotic_stabilizer = 1)
	required_reagents = list(/datum/reagent/exodust = 1,/datum/reagent/stabilizing_agent = 1)
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_CHEMICAL

/datum/reagent/darkplasma
	name = "Condensed Dark Plasma"
	description = "A swirling dark liquid that seems to dissipate any light around it. It is unlike anything you've seen before."
	color = "#0e0033"
	taste_description = "an endless void"
	metabolization_rate = 4 * REAGENTS_METABOLISM

/datum/reagent/darkplasma/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.damage_random_bodypart(10*REM*seconds_per_tick)) // Health rework compatibility.
	// if(affected_mob.take_bodypart_damage(10*REM*seconds_per_tick, 0)) // Original code.
		return UPDATE_MOB_HEALTH

	if(affected_mob?.mana_pool)
		affected_mob.adjust_personal_mana(-10)

/datum/chemical_reaction/plasma_vortex
	required_reagents = list(/datum/reagent/darkplasma = 1)
	required_temp = 474
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	mix_message = "the reaction destabilizes!"
	mix_sound = 'sound/magic/cosmic_energy.ogg'

/datum/chemical_reaction/plasma_vortex/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/range = clamp(sqrt(created_volume), 1, 6)
	goonchem_vortex(T, 0, range)

/datum/reagent/miracle
	name = "Prototype Miracle Matter"
	description = "A shifting web of fractal energies, it seems to shift to be a solid, liquid, or gas. It is unlike anything you've seen before."
	color = "#e6a6e0"
	taste_description = "a universe far, far away"
	metabolization_rate = 0.05 * REAGENTS_METABOLISM

/datum/reagent/miracle/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	radiation_pulse(affected_mob, max_range = 1, threshold = 0.1, chance = 80)
	if(affected_mob.adjustToxLoss(10 * seconds_per_tick * REM, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/miracle/expose_turf(turf/exposed_turf)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

	radiation_pulse(holder, max_range = 4, threshold = 0.1, chance = 80)

/datum/reagent/miracle/expose_obj(obj/exposed_obj)
	. = ..()
	radiation_pulse(holder, max_range = 4, threshold = 0.1, chance = 80)

/datum/reagent/miracle/expose_mob(mob/living/exposed_mob, methods=TOUCH)
	. = ..()
	radiation_pulse(exposed_mob, max_range = 4, threshold = 0.1, chance = 80)

/datum/chemical_reaction/miracle_creation
	results = list(/datum/reagent/miracle = 1)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity/auric = 30, /datum/reagent/gravitum/aerialite = 30, /datum/reagent/resmythril = 30, /datum/reagent/exodust = 30, /datum/reagent/darkplasma = 30)
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_CHEMICAL
	mix_message = "the reaction fractalizes!"
	mix_sound = 'sound/magic/cosmic_expansion.ogg'

/datum/chemical_reaction/miracle_creation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	radiation_pulse(holder, max_range = 6, threshold = 0.1, chance = 80)

/datum/reagent/aggregation_agent
	name = "Aggregation Agent"
	description = "A specially designed agent used to solidify metals. This does not work on everything."
	reagent_state = LIQUID
	color = "#00ff08"
	taste_description = "metal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/aggregation_creation
	results = list(/datum/reagent/aggregation_agent = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/liquid_dark_matter = 1, /datum/reagent/iron = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/silver_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/silver = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_OTHER

/datum/chemical_reaction/silver_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/silver(location)

/datum/chemical_reaction/gold_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/gold = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/gold_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/uranium_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/uranium = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/uranium_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/uranium(location)

/datum/chemical_reaction/bs_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/bluespace = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/bs_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/bluespace_crystal(location)

/datum/chemical_reaction/aerialite_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/gravitum/aerialite = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/aerialite_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/aerialite(location)

/datum/chemical_reaction/resmythril_aggregation
	required_reagents = list(/datum/reagent/aggregation_agent = 5, /datum/reagent/resmythril = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/resmythril_aggregation/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/resmythril(location)

/datum/reagent/consumable/liquidelectricity/auric/redlightning
	name = "Liquid Red Lightning"
	description = "A liquid lightning that seems to sputter with explosive power. It is unlike anything you've seen before."
	color = "#ff4545"
	taste_description = "godlike power"
	shock_speed = 40 // YOU WILL HAVE A VERY BAD TIME DRINKING THIS.

/obj/item/reagent_containers/cup/beaker/redlightning
	name = "red lightning container"
	desc = "A strange, heavy-duty electromagnetic stasis container, powered by unknown technology. Can hold up to 300 units."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redcanister.dmi'
	icon_state = "redlightning"
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plasma = SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)
	// spillable = FALSE
	reagent_flags = OPENCONTAINER | NO_REACT
	fill_icon = 'maplestation_modules/story_content/deepred_warfare/icons/redfillings.dmi'
	fill_icon_state = "redlightning"
	fill_icon_thresholds = list(0, 1, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300) // For some reason the fill icon doesn't work properly.
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/cup/beaker/redlightning/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "redlightningemissive", src, alpha = src.alpha)

/obj/item/reagent_containers/cup/beaker/redlightning/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/beaker/redlightning/filled
	list_reagents = list(/datum/reagent/consumable/liquidelectricity/auric/redlightning = 300)

/datum/reagent/aggregation_agent/advanced
	name = "Advanced Aggregation Agent"
	description = "An advanced agent used solely to produce stable miracle matter. Use with caution."
	reagent_state = LIQUID
	color = "#ff8400"
	taste_description = "otherworldly space"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/advanced_aggregation_creation
	results = list(/datum/reagent/aggregation_agent/advanced = 1)
	required_reagents = list(/datum/reagent/aggregation_agent = 1, /datum/reagent/consumable/liquidelectricity/auric/redlightning = 2)
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_EXPLOSIVE | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/true_miracle
	required_reagents = list(/datum/reagent/aggregation_agent = 150, /datum/reagent/miracle = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/true_miracle/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/miracle_matter(location) // Replace with miracle matter.
