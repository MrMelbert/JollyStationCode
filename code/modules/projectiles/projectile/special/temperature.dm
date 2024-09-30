/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	/// What temp to trend the target towards
	var/temperature = -10 CELCIUS

/obj/projectile/temp/is_hostile_projectile()
	return temperature != 0 // our damage is done by cooling or heating (casting to boolean here)

/obj/projectile/temp/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		// we have to manually account for insulation, ensuring 100% insulatio =/= 100% resistance,
		// otherwise some mobs (like watchers) become completely non-threatening
		var/final_change = temperature * (1 - (0.5 * M.get_insulation(M.body_temperature + temperature))) * ((100 - blocked) / 100)
		M.adjust_body_temperature(final_change)

/obj/projectile/temp/hot
	name = "heat beam"
	icon_state = "lava"
	temperature = 10 CELCIUS

/obj/projectile/temp/cryo
	name = "cryo beam"
	range = 3
	temperature = -25 CELCIUS

/obj/projectile/temp/cryo/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(isopenturf(target))
		var/turf/open/T = target
		T.freeze_turf()

/obj/projectile/temp/cryo/on_range()
	var/turf/T = get_turf(src)
	if(isopenturf(T))
		var/turf/open/O = T
		O.freeze_turf()
	return ..()
