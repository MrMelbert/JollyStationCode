/obj/projectile/bullet/coil
	name ="10mm coilslug"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "coilslug"
	range = 40
	damage = 10
	armour_penetration = 0

/obj/projectile/bullet/coil/highvelo
	name ="high velocity 10mm coilslug"
	icon_state = "high_velo"
	speed = 0.4
	range = 80
	damage = 20
	armour_penetration = 20

/obj/projectile/bullet/coil/red_lightning
	name = "charged 10mm coilslug"
	icon_state = "red_lightning"
	range = 80
	damage = 10
	armour_penetration = 60

	var/extra_damage = 20 // Damage done by shock aftereffect (or straight damage to mechs).

	muzzle_type = /obj/effect/projectile/muzzle/RLcoil
	tracer_type = /obj/effect/projectile/tracer/RLcoil
	impact_type = /obj/effect/projectile/impact/RLcoil
	hitscan = TRUE
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_RED_LIGHT
	muzzle_flash_intensity = 5
	muzzle_flash_range = 1
	muzzle_flash_color_override = COLOR_RED_LIGHT
	impact_light_intensity = 5
	impact_light_range = 1
	impact_light_color_override = COLOR_RED_LIGHT

/obj/projectile/bullet/coil/red_lightning/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/shocked_fellow = target
		shocked_fellow.electrocute_act(extra_damage, src, 1, SHOCK_NOSTUN | SHOCK_NOGLOVES)
	if(ismecha(target))
		target.take_damage(extra_damage * 2, BURN, BULLET, FALSE)

/obj/effect/projectile/muzzle/RLcoil
	name = "charged coilslug muzzle flash"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "rl_coil_muzzle"

/obj/effect/projectile/tracer/RLcoil
	name = "charged coilslug tracer"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "rl_coil_tracer"

/obj/effect/projectile/impact/RLcoil
	name = "charged coilslug impact"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "rl_coil_impact"

/obj/projectile/bullet/godslayer
	name = "godslayer round"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_tracer"
	range = 120
	damage = 120
	armour_penetration = 100

	dismemberment = 10
	catastropic_dismemberment = TRUE
	parried = TRUE

	projectile_piercing = PASSMOB|PASSVEHICLE

	muzzle_type = /obj/effect/projectile/muzzle/godslayer
	tracer_type = /obj/effect/projectile/tracer/godslayer
	impact_type = /obj/effect/projectile/impact/godslayer
	hitscan = TRUE
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_BLUE_LIGHT
	muzzle_flash_intensity = 5
	muzzle_flash_range = 1
	muzzle_flash_color_override = COLOR_BLUE_LIGHT
	impact_light_intensity = 5
	impact_light_range = 1
	impact_light_color_override = COLOR_BLUE_LIGHT

	var/warp_sound = 'maplestation_modules/story_content/deepred_warfare/sound/warp.ogg'
	var/supercharge_sound = 'maplestation_modules/story_content/deepred_warfare/sound/supercharge.ogg'

	var/marked_target

/obj/projectile/bullet/godslayer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT && !pierce_hit)
		warp()
		return
	if(marked_target)
		return
	if(isliving(target) || isvehicle(target))
		marked_target = target

/obj/projectile/bullet/godslayer/proc/warp()
	if(marked_target)
		playsound(src, warp_sound, 100, extrarange = 5)
		addtimer(CALLBACK(src, PROC_REF(fire_warp)), 2)

/obj/projectile/bullet/godslayer/proc/fire_warp()
	playsound(src, supercharge_sound, 100, extrarange = 5)

	var/obj/projectile/A = new /obj/projectile/bullet/coil/red_lightning(get_turf(firer))
	A.preparePixelProjectile(marked_target, get_turf(firer))
	A.firer = firer
	A.fired_from = firer
	A.fire(null, marked_target)

/obj/effect/projectile/muzzle/godslayer
	name = "godslayer muzzle flash"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_muzzle"

/obj/effect/projectile/tracer/godslayer
	name = "godslayer tracer"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_tracer"

/obj/effect/projectile/impact/godslayer
	name = "godslayer warp site"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_impact"

/obj/projectile/bullet/godslayer/generate_hitscan_tracers(cleanup = TRUE, duration = 0.2 SECONDS, impacting = TRUE)
	duration = 0.2 SECONDS
	. = ..()
