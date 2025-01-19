/obj/projectile/bullet/coil
	name ="low velocity 10mm coilslug"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "coilslug"
	range = 60
	damage = 30
	armour_penetration = 20
	dismemberment = 0
	damage_falloff_tile = 0
	wound_bonus = 10
	wound_falloff_tile = -1
	embed_falloff_tile = -1

/obj/item/ammo_casing/coil
	name = "internal low velocity 10mm coilslug"
	desc = "You should not be seeing this."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/coilguns.dmi'
	icon_state = "debug"
	projectile_type = /obj/projectile/bullet/coil

	fire_sound = 'maplestation_modules/story_content/deepred_warfare/sound/coilshoot.ogg'
	delay = 0 // How long it takes to fire the ammo?

	var/select_name = "low velocity"
	var/ammo_energy_usage = 1000 // How much power it takes to fire the ammo (note, redtech cells have 50000 energy).
	var/ammo_heat_generation = 20 // How much heat it generates.

/obj/projectile/bullet/coil/highvelo
	name ="10mm coilslug"
	icon_state = "high_velo"
	speed = 0.4 // Twice as fast as normal.
	range = 80
	damage = 40
	armour_penetration = 50
	dismemberment = 10
	wound_bonus = 20

/obj/item/ammo_casing/coil/highvelo
	name = "internal 10mm coilslug"
	projectile_type = /obj/projectile/bullet/coil/highvelo

	select_name = "high velocity"
	ammo_energy_usage = 2000
	ammo_heat_generation = 30

/obj/projectile/bullet/coil/overcharge
	name = "overcharged slag"
	icon_state = "overcharge"
	damage_type = BURN
	reflectable = NONE
	parried = TRUE
	damage = 5
	range = 10
	armour_penetration = 0
	weak_against_armour = TRUE
	dismemberment = 5
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -1
	embed_falloff_tile = -1
	damage_falloff_tile = -1

/obj/item/ammo_casing/coil/overcharge
	name = "internal overcharge slag"
	projectile_type = /obj/projectile/bullet/coil/overcharge
	fire_sound = 'maplestation_modules/story_content/deepred_warfare/sound/coilbang.ogg'

	select_name = "overcharge"
	ammo_energy_usage = 5000
	ammo_heat_generation = 60
	pellets = 12
	variance = 30

/obj/projectile/bullet/coil/piercing
	name ="low velocity 10mm armour piercing coilslug"
	damage = 20
	armour_penetration = 50

	var/object_damage = 30
	var/mecha_damage = 20

/obj/projectile/bullet/coil/piercing/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isobj(target) && (blocked != 100))
		var/obj/thing_to_break = target
		var/damage_to_deal = object_damage
		if(ismecha(thing_to_break) && mecha_damage)
			damage_to_deal += mecha_damage
		if(damage_to_deal)
			thing_to_break.take_damage(damage_to_deal, BRUTE, BULLET, FALSE)
	return ..()

/obj/item/ammo_casing/coil/piercing
	name = "internal low velocity 10mm armour piercing coilslug"
	projectile_type = /obj/projectile/bullet/coil/piercing
	select_name = "low velocity AP"

/obj/projectile/bullet/coil/highvelo/piercing
	name ="10mm armour piercing coilslug"
	damage = 30
	armour_penetration = 80
	projectile_piercing = PASSMOB

	var/object_damage = 40
	var/mecha_damage = 30

/obj/projectile/bullet/coil/highvelo/piercing/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isobj(target) && (blocked != 100))
		var/obj/thing_to_break = target
		var/damage_to_deal = object_damage
		if(ismecha(thing_to_break) && mecha_damage)
			damage_to_deal += mecha_damage
		if(damage_to_deal)
			thing_to_break.take_damage(damage_to_deal, BRUTE, BULLET, FALSE)
	return ..()

/obj/item/ammo_casing/coil/highvelo/piercing
	name = "internal 10mm armour piercing coilslug"
	projectile_type = /obj/projectile/bullet/coil/highvelo/piercing

	select_name = "high velocity AP"
	ammo_heat_generation = 40

/obj/projectile/bullet/coil/red_lightning
	name = "charged 10mm coilslug"
	icon_state = "red_lightning"
	range = 80
	damage = 30
	armour_penetration = 60

	var/extra_damage = 30 // Damage done by shock aftereffect.
	var/emp_radius = 1 // Radius of EMP effect.

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
	else
		empulse(target, emp_radius, emp_radius)
		new /obj/effect/temp_visual/impact_effect/ion(get_turf(target))

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

/obj/projectile/bullet/coil/red_lightning/generate_hitscan_tracers(cleanup = TRUE, duration = 2 SECONDS, impacting = TRUE)
	duration = 2 SECONDS
	. = ..()

/obj/projectile/bullet/godslayer
	name = "annihilator round"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_tracer"
	range = 120
	damage = 80
	armour_penetration = 100

	dismemberment = 10
	catastropic_dismemberment = TRUE
	parried = TRUE

	projectile_piercing = PASSTABLE|PASSGLASS|PASSGRILLE|PASSBLOB|PASSMOB|PASSMACHINE|PASSSTRUCTURE|PASSFLAPS|PASSDOORS|PASSVEHICLE

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

	var/extra_damage = 500 // Extra damage dealt to non-mob, non-vehicle objects (secondary shot will not trigger).

	var/datum/marked_target

	var/warp_sound = 'maplestation_modules/story_content/deepred_warfare/sound/techpowerup.ogg'
	var/fire_sound = 'maplestation_modules/story_content/deepred_warfare/sound/techblaster.ogg'

/obj/projectile/bullet/godslayer/fire(angle, atom/direct_target, make_sound)
	if(make_sound != null)
		playsound(firer, fire_sound, 100, extrarange = 10)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_warp))

/obj/projectile/bullet/godslayer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(marked_target != null)
		return
	if(isliving(target) || isvehicle(target))
		marked_target = target
	else
		target.take_damage(extra_damage)

/obj/projectile/bullet/godslayer/proc/fire_warp()
	sleep(35)
	if(marked_target == null || QDELETED(marked_target) || QDELETED(firer))
		return
	playsound(firer, warp_sound, 100, extrarange = 10)
	sleep(25)

	if(marked_target != null && !QDELETED(marked_target) && !QDELETED(firer))
		var/obj/projectile/A = new /obj/projectile/bullet/supergodslayer(get_turf(firer))
		A.preparePixelProjectile(marked_target, get_turf(firer))
		A.firer = firer
		A.fired_from = firer
		A.fire(null, marked_target)

/obj/effect/projectile/muzzle/godslayer
	name = "annihilator muzzle flash"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_muzzle"

/obj/effect/projectile/tracer/godslayer
	name = "annihilator tracer"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_tracer"

/obj/effect/projectile/impact/godslayer
	name = "annihilator warp site"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_impact"

/obj/projectile/bullet/godslayer/generate_hitscan_tracers(cleanup = TRUE, duration = 4 SECONDS, impacting = TRUE)
	duration = 4 SECONDS
	. = ..()

/obj/projectile/bullet/supergodslayer
	name = "supercharged annihilator round"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "godslayer_tracer"
	range = 120
	damage = 800
	armour_penetration = 100

	dismemberment = 10
	catastropic_dismemberment = TRUE
	parried = TRUE

	muzzle_type = /obj/effect/projectile/muzzle/supergodslayer
	tracer_type = /obj/effect/projectile/tracer/supergodslayer
	impact_type = /obj/effect/projectile/impact/supergodslayer
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

	var/supercharge_sound = 'maplestation_modules/story_content/deepred_warfare/sound/techexplosion.ogg'

/obj/effect/projectile/muzzle/supergodslayer
	name = "supercharged annihilator warp site"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "supergodslayer_muzzle"

/obj/effect/projectile/tracer/supergodslayer
	name = "supercharged annihilator tracer"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "supergodslayer_tracer"

/obj/effect/projectile/impact/supergodslayer
	name = "supercharged annihilator impact"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/projectiles.dmi'
	icon_state = "supergodslayer_impact"

/obj/projectile/bullet/supergodslayer/generate_hitscan_tracers(cleanup = TRUE, duration = 5 SECONDS, impacting = TRUE)
	duration = 5 SECONDS
	. = ..()

/obj/projectile/bullet/supergodslayer/fire(angle, atom/direct_target)
	playsound(firer, supercharge_sound, 100, extrarange = 10)
	. = ..()

/obj/projectile/bullet/supergodslayer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!QDELETED(target) && isliving(target))
		var/mob/living/duster = target
		if(duster.client)
			var/client/hopper = duster.client
			hopper << link("byond://terry.tgstation13.org:3336")
		duster.dust(just_ash = TRUE, drop_items = FALSE, force = TRUE)
	if(. == BULLET_ACT_HIT && !pierce_hit)
		explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 2, flame_range = 2, flash_range = 3, adminlog = FALSE)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(src))
