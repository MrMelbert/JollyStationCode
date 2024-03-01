/obj/projectile/kajari_lance
	name = "Kajari particle lance"
	icon = 'maplestation_modules/icons/effects/beam.dmi'
	icon_state = "kajari_beam"
	pass_flags = NONE
	damage = 200
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	range = 200
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	ricochets_max = 0
	ricochet_chance = 0 //No.
	reflectable = NONE //Hell no, this is a big ass particle beam.
	wound_bonus = 50
	bare_wound_bonus = 80
	armour_penetration = 90
	projectile_piercing = ALL
	hit_prone_targets = TRUE
	can_hit_turfs = TRUE
	var/explosion_tile_cooldown = 6

/obj/projectile/kajari_lance/prehit_pierce()
	return PROJECTILE_PIERCE_HIT

/obj/projectile/kajari_lance/scan_moved_turf()
	if(explosion_tile_cooldown <= 0)
		explosion(src, devastation_range = 4, heavy_impact_range = 6, light_impact_range = 10, flame_range = 15, flash_range = 15, ignorecap = TRUE, adminlog = FALSE)
		explosion_tile_cooldown = 3
	else
		explosion_tile_cooldown--
	return ..()

/obj/projectile/kajari_lance/singularity_pull()
	return

/obj/projectile/kajari_lance/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/tracer/laser/kajari
	tracer_type = /obj/effect/projectile/tracer/laser/kajari
	impact_type = /obj/effect/projectile/tracer/laser/kajari
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 16
	hitscan_light_color_override = COLOR_RED_LIGHT
	muzzle_flash_intensity = 3
	muzzle_flash_range = 16
	muzzle_flash_color_override = COLOR_RED_LIGHT
	impact_light_intensity = 3
	impact_light_range = 16
	impact_light_color_override = COLOR_RED_LIGHT

/obj/projectile/kajari_lance/generate_hitscan_tracers(cleanup = TRUE, duration = 10, impacting = TRUE)
	duration = 10
	. = ..()
