// NON-MODULE CHANGE : this whole file
/obj/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	embed_type = null
	shrapnel_type = null
	range = 15
	var/obj/item/syringe

/obj/projectile/bullet/dart/proc/add_syringe(obj/item/new_syringe)
	syringe = new_syringe
	syringe.forceMove(src)

/obj/projectile/bullet/dart/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == syringe)
		if(!QDELETED(syringe) && (syringe.item_flags & DROPDEL))
			qdel(syringe)
		syringe = null

/obj/projectile/bullet/dart/on_range()
	syringe.forceMove(drop_location())
	return ..()

/obj/projectile/bullet/dart/on_hit(mob/living/carbon/target, blocked = 0, pierce_hit)
	. = ..()
	if(pierce_hit || isnull(syringe))
		return .
	var/obj/item/syringe_ref = syringe
	if(!istype(target))
		syringe.forceMove(drop_location())
		if(!QDELETED(syringe_ref))
			target.Bumped(syringe_ref) // So it will do stuff like get dusted by the SM
		return BULLET_ACT_BLOCK

	var/real_zone = target.get_random_valid_zone(def_zone)
	var/injection_flags = NONE
	if(istype(syringe, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/real_syringe = syringe
		injection_flags |= real_syringe.inject_flags

	if(!target.can_inject(target_zone = real_zone, injection_flags = injection_flags))
		blocked = 100

	if(. == BULLET_ACT_BLOCK || blocked >= 100)
		syringe.forceMove(drop_location())
		if(!QDELETED(syringe_ref))
			target.Bumped(syringe_ref) // Ditto
		return BULLET_ACT_BLOCK

	syringe = null
	syringe_ref.tryEmbed(target, zone = real_zone, forced = TRUE)
	return BULLET_ACT_HIT

/obj/projectile/bullet/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"
	generic_name = "syringe"

// Code to handle what happens when a syringe is embedded in a mob
/obj/item/reagent_containers/syringe
	embed_type = /datum/embed_data/syringe

/datum/embed_data/syringe
	embed_chance = 0 // only when forced
	fall_chance = 0 // only when edited
	rip_time = 1.5 SECONDS
	pain_stam_pct = 0.75
	impact_pain_mult = 8 // half this if syringe w class goes up.
	remove_pain_mult = 8 // same
	pain_chance = 20
	pain_mult = 4 // same
	jostle_chance = 3
	jostle_pain_mult = 8 // same

/obj/item/reagent_containers/syringe/embedded(mob/living/embedded_target, obj/item/bodypart/part)
	. = ..()
	if(!istype(embedded_target))
		return
	addtimer(CALLBACK(src, PROC_REF(inject_embedded_target), embedded_target, part), 5 SECONDS)

/obj/item/reagent_containers/syringe/proc/inject_embedded_target(mob/living/embedded_target, obj/item/bodypart/part)
	if(QDELETED(embedded_target) || QDELETED(part))
		return
	if(part.owner != embedded_target || !(src in part.embedded_objects))
		return
	if(!embedded_target.can_inject(target_zone = part, injection_flags = inject_flags))
		// This is turbo cringe but embedded itself is cringe so I don't feel so bad
		var/datum/component/embedded/embed_comp = embedded_target.GetComponent(/datum/component/embedded)
		embed_comp?.fallOut()
		update_appearance()
		return

	reagents.trans_to(embedded_target, reagents.maximum_volume * (1 / 3), methods = INJECT)
	if(reagents.total_volume <= 1)
		// More cringe. When we're done injecting add a chance to fall out moving forward
		var/datum/component/embedded/embed_comp = embedded_target.GetComponent(/datum/component/embedded)
		embed_comp?.fall_chance_mod = 20
		update_appearance()
		return

	addtimer(CALLBACK(src, PROC_REF(inject_embedded_target), embedded_target, part), 2 SECONDS)

// Code to handle what happens when a DNA injector is embedded in a mob
/obj/item/dnainjector
	embed_type = /datum/embed_data/syringe

/obj/item/dnainjector/embedded(mob/living/embedded_target, obj/item/bodypart/part)
	. = ..()
	if(!istype(embedded_target))
		return
	addtimer(CALLBACK(src, PROC_REF(inject_embedded_target), embedded_target, part), 5 SECONDS)

/obj/item/dnainjector/proc/inject_embedded_target(mob/living/embedded_target, obj/item/bodypart/part)
	if(QDELETED(embedded_target) || QDELETED(part))
		return
	if(part.owner != embedded_target || !(src in part.embedded_objects))
		return
	if(used)
		// This is also cringe etc etc etc
		var/datum/component/embedded/embed_comp = embedded_target.GetComponent(/datum/component/embedded)
		embed_comp?.fallOut()
		return

	if(embedded_target.can_inject(target_zone = part))
		inject(embedded_target) // Falls out regardless of success or failure

	used = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(inject_embedded_target), embedded_target, part), 5 SECONDS)
