/*
	Baseball bats
	Adds a variable for the storage, and some basic variants.
*/

// Basic Bat
/obj/item/melee/baseball_bat
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	lefthand_file = 'maplestation_modules/icons/mob/inhands/weapons/bats_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/weapons/bats_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Default" = "baseball_bat",
		"Pretty Pink Bat" = "baseball_bat_kitty",
		"Magical Bat" = "baseball_bat_magic"
		)
	/// The overlay this will add to the bat sheathe
	var/belt_sprite = "-basic"

// Home Run Bat
/obj/item/melee/baseball_bat/homerun
	icon_state = "baseball_bat_home"
	inhand_icon_state = "baseball_bat_home"
	belt_sprite = "-home"

// Metal Bat
/obj/item/melee/baseball_bat/ablative
	belt_sprite = "-metal"

// Barbed Bat
/obj/item/melee/baseball_bat/barbed
	name = "Barbara"
	desc = "A bat wrapped in hooked wires meant to dig into the flesh of the undead, although it works just as well on the living."
	icon_state = "baseball_bat_barbed"
	inhand_icon_state = "baseball_bat_barbed"
	attack_verb_simple = list("beat", "bashed", "tore into")
	attack_verb_continuous = list("beats", "bashes", "tears into")
	force = 10
	wound_bonus = 20
	bare_wound_bonus = 15
	belt_sprite = "-barbed"

/obj/item/melee/maple_plasma_blade // calling it this in the odds that the upstream adds their own "plasma_blade"
	name = "plasma blade"
	desc = "A chimeric hybrid of NT and retrieved Syndicate energy swords, powered using an experimental crystal made of plasma and zaukerite. Interestingly, its blade has more in common with an Abductor cutter."
	/// unlike the nullrod variant, this one's desc isn't flavor.
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	icon_state = "mpl_plasma_blade" //mpl = maple. once again, insurance, although since this in the modular DMI it shouldn't be too much an issue.
	base_icon_state = "mpl_plasma_blade"
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	inhand_icon_state = "mpl_plasma_blade"
	lefthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "mpl_plasma_blade"
	worn_icon = 'maplestation_modules/icons/mob/clothing/belt.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// looking for armor penetration? sorry, but thats only on the null rod. Like hell I'm letting anyone have a 20 AP 20 damage esword.
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb_continuous = list("stubs","whacks","pokes")
	attack_verb_simple = list("stub","whack","poke")
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_on = FALSE
	///force when active, passed onto component/transforming
	var/active_force = 18
	///throwforce when active, passed onto component/transforming
	var/active_throwforce = 16
	///hitsound when active, passed onto component/transforming
	var/active_hitsound = 'maplestation_modules/sound/weapons/plasmaslice.ogg'
	///w_class when active, passed onto component/transforming
	var/active_w_class = WEIGHT_CLASS_BULKY
	///attack_verb_continous_on when active, passed onto component/transforming
	var/active_attack_verb_continous_on = list("incinerates", "slashes", "singes", "scorches", "tears", "stabs")
	///attack_verb_simple_on when active, passed onto component/transforming
	var/active_attack_verb_simple_on = list("incinerate", "slash", "singe", "scorch", "tear", "stab")
	///light color when active, passed onto proc/on_transform
	var/active_light_color = COLOR_AMETHYST


/obj/item/melee/maple_plasma_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = active_hitsound, \
		w_class_on = active_w_class, \
		attack_verb_continuous_on = active_attack_verb_continous_on, \
		attack_verb_simple_on = active_attack_verb_simple_on, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/maple_plasma_blade/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, "[active ? "ignited":"extinguished"] [src]")
	playsound(user ? user : src, active ? 'maplestation_modules/sound/weapons/plasmaon.ogg' : 'maplestation_modules/sound/weapons/plasmaoff.ogg', 20, TRUE)
	update_appearance(UPDATE_ICON)
	set_light_on(active)
	set_light_color(active_light_color) // shoutouts to jade for the lighting code.
	tool_behaviour = (active ? TOOL_KNIFE : NONE) // Yolo. this will let it work as a knife can.
	slot_flags = active ? NONE : ITEM_SLOT_BELT // this is to prevent it from being storable in belt.
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/psych_rock
	name = "heavy paperweight"
	desc = "A rock designed specifically to hold down stacks of paper from the wind. Although, it is way heavier than it should be."
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	icon_state = "psych_rock"
	lefthand_file = 'maplestation_modules/icons/mob/inhands/weapons/rock_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/weapons/rock_righthand.dmi'
	inhand_icon_state = "psych_rock"
	var/force_unwielded = 6
	var/force_wielded = 16
	wound_bonus = 20
	throwforce = 16
	w_class = WEIGHT_CLASS_BULKY

/obj/item/melee/psych_rock/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded)

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	var/static/paperweight_spawned = FALSE
	if(mapload && !paperweight_spawned  && istype(get_area(src), /area/station/medical/psychology))
		new /obj/item/melee/psych_rock(loc)
		paperweight_spawned = TRUE

/obj/item/melee/maugrim
	name = "Maugrim"
	desc = "Hilda Brandt's longsword. It was christened after slaying a space-werewolf of the same name." // todo
	force = 18 // identical the the chappie claymore rod, but without anti-magic
	block_chance = 30
	icon_state = "maugrim"
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	inhand_icon_state = "maugrim"
	lefthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 16
	demolition_mod = 0.75
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/melee/maugrim/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sheathe/maugrim/sword = container.real_location?.resolve()
	if(istype(sword))
		playsound(sword, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/maugrim/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sheathe/maugrim/sword = container.real_location?.resolve()
	if(istype(sword))
		playsound(sword, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/maugrim/razorwing
	name = "Razorwing"
	desc = "Cyril Pembrooke's Jikdo. Unlike the on-station katanas, this single-edged blade is meant to be straight." // lampshade on how all katanas have been straight-edge, when they're meant to be curved.
	icon_state = "razorwing"
	inhand_icon_state = "razorwing"
	attack_verb_continuous = list("cuts", "slashes", "slices")
	attack_verb_simple = list("cut", "slash", "slice")

/obj/item/melee/maugrim/razorwing/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sheathe/maugrim/razorwing/sword = container.real_location?.resolve()
	if(istype(sword))
		playsound(sword, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/maugrim/razorwing/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sheathe/maugrim/razorwing/sword = container.real_location?.resolve()
	if(istype(sword))
		playsound(sword, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/maugrim/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 95, \
		bonus_modifier = 5, \
	)

/obj/item/melee/maugrim/razorwing/Initialize(mapload) // you don't need to ask me to add world building only a few people will ever see.
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The tassel is made out of a shed ornithid primary feather. \
		Judging by the color, it would be a feather from its owner. \
		Given the importance of these feathers to the flight, its quite common to hold on to these such feathers. ", \
		EXAMINE_CHECK_SPECIES, /datum/species/ornithid)

/obj/item/melee/gehenna // matthew's sword when he's asset protection
	name = "Gehenna"
	desc = "The christened blade of Matthew Scoria."
	icon_state = "amber_blade"
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	worn_icon_state = "amber_blade"
	worn_icon = 'maplestation_modules/icons/mob/clothing/belt.dmi'
	inhand_icon_state = "amber_blade"
	lefthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'maplestation_modules/icons/mob/inhands/weapons/swords_righthand.dmi'
	// this is seperate from the null rod- this will have no anti-magic and higher stats to compensate for it being used by a command member who refuses to use energy guns
	force = 20
	sharpness = SHARP_EDGED
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_SUITSTORE
	block_chance = 25
	armour_penetration = 20
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("stabs", "cuts", "slashes", "power attacks")
	attack_verb_simple = list("stab", "cut", "slash", "power attack")
