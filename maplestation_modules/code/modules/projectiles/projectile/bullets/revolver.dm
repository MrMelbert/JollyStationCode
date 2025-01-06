/obj/projectile/bullet/c38/dual_stage
	name = ".38 dual-stage bullet"
	icon = 'maplestation_modules/icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "dual_stage"
	damage = 20
	speed = 1.2 // make the effect look cooler
	armour_penetration = 10
	ricochets_max = 0
	ricochet_chance = 0
	wound_bonus = -30
	embedding = list(embed_chance=20, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=1 SECONDS)
	embed_falloff_tile = -1.5

/obj/projectile/bullet/c38/dual_stage/fire(angle, atom/direct_target)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(speed_up)), 0.4 SECONDS)

/obj/projectile/bullet/c38/dual_stage/proc/speed_up()
	speed /= 2.5
	icon_state = "dual_stage-fast"
	wound_bonus += 30
	armour_penetration += 20
	new /obj/item/ammo_casing/spent/dual_stage_booster(get_turf(src))

/obj/item/ammo_casing/spent/dual_stage_booster
	name = "spent dual-stage bullet booster"
	desc = "A bullet booster."
	icon = 'maplestation_modules/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "dual_stage_junk"

/obj/item/ammo_casing/spent/dual_stage_booster/Initialize(mapload)
	. = ..()
	bounce_away(still_warm = TRUE, bounce_delay = 3)

/obj/item/ammo_casing/spent/dual_stage_booster/update_icon_state()
	icon_state = "dual_stage_junk"
	return ..()

/obj/projectile/bullet/c38/maginull
	name = ".38 maginull bullet"
	damage = 20
	ricochets_max = 0 // do you expect hollow-point gold and obsidian to endure a ricochet?
	ricochet_chance = 0
	weak_against_armour = TRUE
	wound_bonus = -30
	embedding = list(embed_chance=50, fall_chance=1, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.2, pain_mult=1, jostle_pain_mult=2, remove_pain_mult = 2, rip_time=1 SECONDS)
	embed_falloff_tile = -2.5
	shrapnel_type = /obj/item/shrapnel/bullet/maginull

/obj/item/shrapnel/bullet/maginull
	var/mob/living/carbon/spiked_mob

/obj/item/shrapnel/bullet/maginull/embedded(atom/embedded_target, obj/item/bodypart/part)
	. = ..()
	if(iscarbon(embedded_target))
		spiked_mob = embedded_target
		START_PROCESSING(SSprocessing, src)

/obj/item/shrapnel/bullet/maginull/process(seconds_per_tick)
	if(spiked_mob?.mana_pool)
		spiked_mob.safe_adjust_personal_mana(-1.5 * seconds_per_tick)

/obj/item/shrapnel/bullet/maginull/unembedded()
	spiked_mob = null
	STOP_PROCESSING(SSprocessing, src)
	. = ..()
