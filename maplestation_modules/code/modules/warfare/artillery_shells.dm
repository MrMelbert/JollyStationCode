/obj/effect/meteor/shell
	name = "generic artillery shell"
	desc = "A generic artillery shell."
	icon = 'maplestation_modules/icons/obj/arty_shell.dmi'
	icon_state = "rocket_ap_big"
	//I'd expect shells to made out of plasteel or something.
	meteordrop = list(/obj/item/stack/sheet/plasteel)
	dropamt = 4
	//Mostly everything about this is the same as the meteor.
	//Except for the fact that it's not a meteor.
	spins = FALSE
	achievementworthy = FALSE

/obj/effect/meteor/shell/big_ap
	name = "460mm rocket assisted AP shell"
	desc = "A rocket assisted armour piercing shell, designed to cut through the heaviest of armour. You should probably get out of the way."
	icon_state = "rocket_ap_big"
	//Pierces a lot of hull.
	hits = 20
	//Will fuck you up if you get hit by it.
	hitpwr = EXPLODE_DEVASTATE
	//Made of very hard materials.
	meteordrop = list(/obj/item/stack/sheet/mineral/plastitanium)

/obj/effect/meteor/shell/big_ap/Move()
	. = ..()
	if(.)
		//Fire trail, because it's rocket assisted.
		new /obj/effect/temp_visual/fire(get_turf(src))

/obj/effect/meteor/shell/small_ap
	name = "160mm rocket assisted AP shell"
	desc = "A small rocket assisted armour piercing shell, designed to cut through armour. You should probably get out of the way."
	icon_state = "rocket_ap_small"
	hits = 8
	meteordrop = list(/obj/item/stack/sheet/mineral/plastitanium)
	dropamt = 2

/obj/effect/meteor/shell/small_ap/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/fire(get_turf(src))

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
	new /obj/effect/singulo_warhead/tuned(get_turf(src))
