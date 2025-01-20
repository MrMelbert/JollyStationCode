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
	item_flags = NO_BLOOD_ON_ITEM
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
	drop_sound = 'maplestation_modules/sound/items/drop/generic2.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/generic2.ogg'

/obj/item/melee/psych_rock/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded)

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	var/static/paperweight_spawned = FALSE
	if(mapload && !paperweight_spawned  && istype(get_area(src), /area/station/medical/psychology))
		new /obj/item/melee/psych_rock(loc)
		paperweight_spawned = TRUE

/datum/embed_data/combat_knife/nullknife
	embed_chance = 35

/obj/item/knife/combat/nullknife
	name = "\improper XM6N Null Knife"
	icon = 'maplestation_modules/icons/obj/weapons.dmi'
	icon_state = "null_knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	inhand_icon_state = "knife"
	worn_icon_state = "knife"
	desc = "An experimental anti-magic knife."
	force = 17
	throwforce = 10
	embed_type = /datum/embed_data/combat_knife/nullknife
	custom_materials = null

/obj/item/knife/combat/nullknife/Initialize(mapload)
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)
	return ..()

/obj/item/knife/combat/nullknife/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>While the weapon passed the field-testing phase with the TGMC, TerraGov declined to continue mass-production due to a lack of practical applications at the time. However, paramilitaries foreign to the Mu sector (especially those that don't use magic) will sometimes procure and issue their own knives to deal with the increased usage of magic in the area.</i>")
