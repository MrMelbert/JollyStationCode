/obj/effect/meteor/shell
	name = "generic artillery shell"
	desc = "A generic artillery shell."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/arty_shell.dmi'
	icon_state = "rocket_ap_big"
	//I'd expect shells to made out of plasteel or something.
	meteordrop = list(/obj/item/stack/sheet/plasteel)
	dropamt = 4
	//Mostly everything about this is the same as the meteor.
	//Except for the fact that it's not a meteor.
	spins = FALSE
	achievementworthy = FALSE
	//Shows the shell over the trail.
	layer = ABOVE_ALL_MOB_LAYER
	density = FALSE

/obj/effect/meteor/shell/big_ap
	name = "460mm rocket assisted AP shell"
	desc = "A rocket assisted armour piercing shell, designed to cut through the heaviest of armour. You should probably get out of the way."
	icon_state = "rocket_ap_big"
	//Pierces a lot of hull.
	hits = 8
	//Will fuck you up if you get hit by it.
	hitpwr = EXPLODE_DEVASTATE
	//Made of very hard materials.
	meteordrop = list(/obj/item/stack/sheet/mineral/plastitanium)
	//For rocket assisted shells.
	var/fuel = 100
	//Adds speed to the shells.
	var/speedfuel = 10

/obj/effect/meteor/shell/big_ap/Move()
	. = ..()
	if(. && fuel > 0)
		//Fire trail, because it's rocket assisted.
		new /obj/effect/temp_visual/fire(get_turf(src))
		fuel--
	if(. && speedfuel > 0)
		//Converts speedfuel to hits.
		speedfuel--
		hits++

/obj/effect/meteor/shell/big_ap/meteor_effect()
	..()
	//Detonate fuel.
	if(fuel > 0)
		explosion(src, heavy_impact_range = 2, light_impact_range = 3, flash_range = 4, adminlog = FALSE)

/obj/effect/meteor/shell/small_ap
	name = "160mm rocket assisted AP shell"
	desc = "A small rocket assisted armour piercing shell, designed to cut through armour. You should probably get out of the way."
	icon_state = "rocket_ap_small"
	hits = 4
	meteordrop = list(/obj/item/stack/sheet/mineral/plastitanium)
	dropamt = 2
	var/fuel = 60
	var/speedfuel = 6

/obj/effect/meteor/shell/small_ap/Move()
	. = ..()
	if(. && fuel > 0)
		new /obj/effect/temp_visual/fire(get_turf(src))
		fuel--
	if(. && speedfuel > 0)
		speedfuel--
		hits++

/obj/effect/meteor/shell/small_ap/meteor_effect()
	..()
	if(fuel > 0)
		explosion(src, light_impact_range = 1, flash_range = 2, adminlog = FALSE)

/obj/effect/meteor/shell/small_wmd_he
	name = "160mm WMD singularity explosive shell"
	desc = "A small WMD explosive singularity shell, designed to annihilate anything in its path. You should probably run far away."
	icon_state = "he_wmd_small"
	hits = 2
	hitpwr = EXPLODE_LIGHT
	dropamt = 2
	heavy = TRUE

/obj/effect/meteor/shell/small_wmd_he/meteor_effect()
	..()
	new /obj/effect/temp_visual/space_explosion(get_turf(src))
	new /obj/effect/singulo_warhead(get_turf(src))

/obj/effect/meteor/shell/small_wmd_flak
	name = "160mm tuned singularity flak shell"
	desc = "A small WMD flak singularity shell, designed for explosive area denial. You should probably run far away."
	icon_state = "flak_wmd_small"
	hits = 2
	hitpwr = EXPLODE_LIGHT
	dropamt = 2
	heavy = TRUE

/obj/effect/meteor/shell/small_wmd_flak/meteor_effect()
	..()
	new /obj/effect/temp_visual/space_explosion(get_turf(src))
	new /obj/effect/singulo_warhead/tuned(get_turf(src))

/obj/effect/meteor/shell/small_cluster_ap
	name = "160mm cluster AP shell"
	desc = "A small cluster armour piercing shell, designed to deploy a large amount of AP submunitions. You should probably watch out for submunitions."
	icon_state = "cluster_ap_small"
	hits = 4
	dropamt = 2
	//Fun fact: Canon is 3x this amount.
	var/submunitions = 64
	//Deploys this many submunitions per step.
	var/deployment_rate = 8

/obj/effect/meteor/shell/small_cluster_ap/Move()
	var/deploys_left = deployment_rate
	. = ..()
	if(. && submunitions > 0)
		while(deploys_left > 0)
			var/start_turf = get_turf(src)
			var/turf/destination = spaceDebrisStartLoc(dir, z) //This might shit submunitions all over the place if it is moving diagonally.
			new /obj/effect/meteor/shell/tiny_ap_submunition(start_turf, destination)
			submunitions--
			deploys_left--

/obj/effect/meteor/shell/tiny_ap_submunition
	name = "AP submunition"
	desc = "A small armour piercing submunition, designed for area denial. You should probably watch out for more."
	icon_state = "sub_ap"
	hits = 2
	hitpwr = EXPLODE_LIGHT
	dropamt = 0
	var/start_delay = TRUE
	var/actual_delay = 0

/obj/effect/meteor/shell/tiny_ap_submunition/Move()
	if(start_delay)
		start_delay = FALSE
		actual_delay = rand(0, 6)

	if(actual_delay > 0)
		actual_delay--
		return FALSE

	. = ..()

/obj/effect/meteor/shell/big_cluster_wmd_he
	name = "460mm cluster WMD singularity explosive shell"
	desc = "A cluster WMD explosive singularity shell, designed to deploy a large amount of WMDs. You should probably watch out for submunitions."
	icon_state = "cluster_wmd_big"
	hits = 4
	//Fun fact: Canon is 2x this amount.
	var/submunitions = 12
	//Deploys this many submunitions per step.
	var/deployment_rate = 2

/obj/effect/meteor/shell/big_cluster_wmd_he/Move()
	var/deploys_left = deployment_rate
	. = ..()
	if(. && submunitions > 0)
		while(deploys_left > 0)
			var/start_turf = get_turf(src)
			var/turf/destination = spaceDebrisStartLoc(dir, z) //This might shit submunitions all over the place if it is moving diagonally.
			new /obj/effect/meteor/shell/small_wmd_he_submunition(start_turf, destination)
			submunitions--
			deploys_left--

/obj/effect/meteor/shell/small_wmd_he_submunition
	name = "explosive WMD submunition"
	desc = "A small explosive WMD submunition, designed to annihilate anything in its path. You should probably watch out for more."
	icon_state = "sub_wmd_he"
	hits = 1
	hitpwr = EXPLODE_LIGHT
	dropamt = 0
	var/start_delay = TRUE
	var/actual_delay = 0

/obj/effect/meteor/shell/small_wmd_he_submunition/Move()
	if(start_delay)
		start_delay = FALSE
		actual_delay = rand(0, 10)

	if(actual_delay > 0)
		actual_delay--
		return FALSE

	. = ..()

/obj/effect/meteor/shell/small_wmd_he_submunition/meteor_effect()
	..()
	new /obj/effect/temp_visual/space_explosion(get_turf(src))
	new /obj/effect/singulo_warhead/cluster(get_turf(src))

/obj/effect/meteor/shell/big_cluster_wmd_flak
	name = "460mm cluster WMD singularity flak shell"
	desc = "A cluster WMD flak singularity shell, designed to deploy a large amount of WMDs. You should probably watch out for submunitions."
	icon_state = "cluster_wmd_big" //Deployer looks the same as the HE variant.
	hits = 4
	//Fun fact: Canon is 2x this amount.
	var/submunitions = 12
	//Deploys this many submunitions per step.
	var/deployment_rate = 2

/obj/effect/meteor/shell/big_cluster_wmd_flak/Move()
	var/deploys_left = deployment_rate
	. = ..()
	if(. && submunitions > 0)
		while(deploys_left > 0)
			var/start_turf = get_turf(src)
			var/turf/destination = spaceDebrisStartLoc(dir, z) //This might shit submunitions all over the place if it is moving diagonally.
			new /obj/effect/meteor/shell/small_wmd_flak_submunition(start_turf, destination)
			submunitions--
			deploys_left--

/obj/effect/meteor/shell/small_wmd_flak_submunition
	name = "flak WMD submunition"
	desc = "A small flak WMD submunition, designed for area denial. You should probably watch out for more."
	icon_state = "sub_wmd_flak"
	hits = 1
	hitpwr = EXPLODE_LIGHT
	dropamt = 0
	var/start_delay = TRUE
	var/actual_delay = 0

/obj/effect/meteor/shell/small_wmd_flak_submunition/Move()
	if(start_delay)
		start_delay = FALSE
		actual_delay = rand(0, 10)

	if(actual_delay > 0)
		actual_delay--
		return FALSE

	. = ..()

/obj/effect/meteor/shell/small_wmd_flak_submunition/meteor_effect()
	..()
	new /obj/effect/temp_visual/space_explosion(get_turf(src))
	new /obj/effect/singulo_warhead/tuned_cluster(get_turf(src))

/obj/effect/meteor/shell/kajari
	name = "460mm KAJARI WMD shell"
	desc = "A KAJARI WMD shell, designed to project an incredibly destructive plasma lance. You should consider leaving while you still can."
	icon_state = "kajari_big"
	hits = 8
	hitpwr = EXPLODE_DEVASTATE
	//How long until we fire the KAJARI beam.
	var/fuse = 6
	//Holy shitcode.
	var/done = FALSE

/obj/effect/meteor/shell/kajari/Initialize(mapload, turf/target)
	. = ..()
	//Forces the station to red alert when this thing is fired.
	var/current_sec_level = SSsecurity_level.get_current_level_as_number()
	if(current_sec_level < SEC_LEVEL_RED)
		SSsecurity_level.set_level(SEC_LEVEL_RED)

/obj/effect/meteor/shell/kajari/Move()
	if(done)
		return
	. = ..()
	if(fuse <= 0)
		done = TRUE
		make_debris()
		meteor_effect()
		QDEL_IN(src, 9 SECONDS)
	else
		fuse--

/obj/effect/meteor/shell/kajari/meteor_effect()
	..()
	new /obj/effect/temp_visual/space_explosion(get_turf(src))
	new /obj/effect/singulo_warhead(get_turf(src))
	addtimer(CALLBACK(src, PROC_REF(fire_beam)), 8 SECONDS)

/obj/effect/meteor/shell/kajari/proc/fire_beam()
	var/obj/projectile/A = new /obj/projectile/kajari_lance/hitscan(get_turf(src))
	A.preparePixelProjectile(dest, get_turf(src))
	A.firer = src
	A.fired_from = src
	A.fire(null, dest)
