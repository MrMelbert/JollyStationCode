// ALIAS = FAKE NAME
// NOT ALIAS = REAL NAME

/obj/item/starblight_soot
	name = "starblight soot jar"
	desc = "A small jar filled with a fine, sparkling purple powder. It's sealed tight, and the label reads Starblight. The jar's glass just the faintest tinted blue and feels heavy in your hand."

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "starblight_soot"

	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	drop_sound = 'maplestation_modules/sound/items/drop/glass_small.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/glass_small.ogg'

/obj/item/starblight_soot/alias
	name = "sealed soot jar"

/obj/item/suspicious_scrap
	name = "suspicious scrap"
	desc = "A small chunk of componentry that looks like part of a larger device. Despite this, it's not immediately clear what it's from or what it does."

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "scrap"

	inhand_icon_state = "reverse_bear_trap"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	drop_sound = 'maplestation_modules/sound/items/drop/metal_drop.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/device.ogg'

/obj/item/suspicious_scrap/alt
	icon_state = "scrap_alt"
	drop_sound = 'maplestation_modules/sound/items/drop/card.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/card.ogg'

/obj/item/ammo_casing/shotgun/godslayer
	name = "godslayer round"
	desc = "A strange 12 gauge slug made of an unknown alloy. It's heavy and seems to be humming with energy. You feel that shooting this would be a really bad idea."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "godslayer"
	projectile_type = /obj/projectile/bullet/godslayer
	custom_materials = list(/datum/material/aerialite=SHEET_MATERIAL_AMOUNT*2)
	fire_sound = 'maplestation_modules/story_content/deepred_warfare/sound/techblaster.ogg'

	var/obj/item/gun/fired_record

/obj/item/ammo_casing/shotgun/godslayer/alias
	name = "annhilator round"

/obj/item/ammo_casing/shotgun/godslayer/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if(isgun(fired_from))
		fired_record = fired_from
		fired_record.fire_sound_volume = 0
		fired_record.recoil = initial(fired_record.recoil) + 3

	. = ..()
	playsound(src, fire_sound, 100, extrarange = 10)

	if(fired_record)
		addtimer(CALLBACK(src, PROC_REF(reset_gunstats)), 1)

/obj/item/ammo_casing/shotgun/godslayer/proc/reset_gunstats()
	if(fired_record)
		fired_record.fire_sound_volume = initial(fired_record.fire_sound_volume)
		fired_record.recoil = initial(fired_record.recoil)

/obj/item/redtech_nan_sample
	name = "redtech nanite sample"
	desc = "A small, hard cube that glows a deep red at its seams. It seems to move and shift geometrically in place."

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "nanite_sample"

	inhand_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	drop_sound = 'maplestation_modules/sound/items/drop/ammobox.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/ammobox.ogg'

/obj/item/redtech_nan_sample/alias
	name = "crimson nanite sample"

/obj/item/throwing_star/needle
	name = "persuasion needle"
	desc = "A large, sharp needle designed for persuasion. It has a small, intricate yin-yang design etched into the side."
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "needle"

	inhand_icon_state = "rods"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	drop_sound = 'maplestation_modules/sound/items/drop/knife_big.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/knife_big.ogg'

/obj/item/throwing_star/needle/alias
	name = "throwing needle"

/obj/item/yin_yang_orb
	name = "yin-yang orb"
	desc = "A small, smooth orb that seems all but inert now. It seems to almost be crystaline in nature and has the design of a yin-yang. Throwing this at someone would hurt quite a bit."

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	force = 8
	throwforce = 16

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "yin_yang_orb"

	inhand_icon_state = "nothing"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	drop_sound = 'maplestation_modules/sound/items/drop/glass_small.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/glass_small.ogg'

/obj/item/yin_yang_orb/alias
	name = "intricate orb"

/obj/item/yin_yang_orb/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/knockback, 1, FALSE, FALSE)

/obj/item/snowglobe
	name = "snowglobe"
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of The Collector?"
	w_class = WEIGHT_CLASS_SMALL

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	icon = 'maplestation_modules/story_content/deepred_warfare/icons/curios.dmi'
	icon_state = "snowglobe"

	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	drop_sound = 'maplestation_modules/sound/items/drop/glass_small.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/glass_small.ogg'

/obj/item/snowglobe/reimu
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a red and white shrine maiden at an oriental shrine."

/obj/item/snowglobe/yukari
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a tall, ribboned lady with a parasol standing on an old, abandoned train platform."

/obj/item/snowglobe/sdm
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a misty, lakeside mansion."

/obj/item/snowglobe/draedon
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a strange robotic figure sitting on a flying chair, flanked by a landscape of metal and machinery."

/obj/item/snowglobe/starfarers
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of two twins, both wearing purple, starry attire. They stand on a floating island with a towering spire, surrounded by a sea of clouds."

/obj/item/snowglobe/calamitas
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a dark skinned sorceress wearing red robes, standing in a incinerated city."

/obj/item/snowglobe/angela
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a pale librarian holding a book, surrounded by an odd library."

/obj/item/snowglobe/library
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a giant, tree-like library out in a barren wasteland."

/obj/item/snowglobe/city
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a cityscape, with a large, imposing tower in the center."

/obj/item/snowglobe/station
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of the space station you're currently on?"

/obj/item/snowglobe/empty
	desc = "A small glass globe filled with a miniature winter scene. This one is completely empty, save for the snow."

/obj/item/snowglobe/extra
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a human, clad deep red naval captain's attire, with a large gun case slung across their back."

/obj/item/snowglobe/extra/moon
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of Earth's moon. You didn't know it snowed on the Moon."

/obj/item/snowglobe/extra/mars
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of Mars from the Sol system. You didn't know it snowed on Mars."

/obj/item/snowglobe/extra/marisa
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a monochromatic, ordinary witch soaring through snowy clouds on their broom."

/obj/item/snowglobe/extra/lunar
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a vast cityscape, built on the far side of the Moon."

/obj/item/snowglobe/extra/needlecastle
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a large palace, suspended in the sky upside down."

/obj/item/snowglobe/extra/astral
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a starstruck wasteland, infected by an otherworldly blight."

/obj/item/snowglobe/extra/dog
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a titanic armoured serpent, coiled around a rift in time and space."

/obj/item/snowglobe/extra/goozma
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a massive, gooey, tentacled creature, floating in a monsoon of slime."

/obj/item/snowglobe/extra/arbiter
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a person wrapped in a pitch black cloak with golden, hexagonal highlights. They stand in the centre of a ruined cityscape."

/obj/item/snowglobe/extra/limbus
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a strange, train-like bus. It has bright text written on its side, but you can't quite make it out."

/obj/item/snowglobe/extra/silence
	desc = "A small glass globe filled with a miniature winter scene. Inside is a miniature model of a man in a black suit and black gloves, with a featureless mask."
