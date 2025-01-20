// A real Rat'varian Spear.
// Slightly less force than an E.L., more armor pen and throwforce.
/obj/item/melee/ratvar_spear
	name = "rat'varian spear"
	desc = "A mechanical spear made of genuine brass. It menaces as you stare upon it."
	icon = 'maplestation_modules/icons/obj/clockwork_objects.dmi'
	worn_icon = 'icons/mob/clothing/belt.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	icon_state = "ratvarian_spear"
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	throwforce = 20 // javelin throw!
	armour_penetration = 10
	block_chance = 50
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	drop_sound = 'maplestation_modules/sound/items/drop/sword.ogg'
	pickup_sound = 'maplestation_modules/sound/items/pickup/sword1.ogg'
	equip_sound = 'maplestation_modules/sound/items/drop/sword.ogg'

/obj/item/melee/ratvar_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)

/obj/item/melee/ratvar_spear/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(IS_CULTIST(owner) && prob(final_block_chance))
		new /obj/effect/particle_effect/sparks(get_turf(owner))
		playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		return TRUE

	return FALSE

/obj/item/melee/ratvar_spear/attack(mob/living/target, mob/living/carbon/human/user)
	if(IS_CULTIST(user))
		return ..()

	user.Paralyze(100)
	user.dropItemToGround(src, TRUE)
	user.visible_message(
		span_warning("A powerful force shoves [user] away from [target]!"),
		span_large_brass("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""),
		)
	user.apply_damage(rand(force / 2, force), BRUTE, user.get_active_hand())
	return TRUE
