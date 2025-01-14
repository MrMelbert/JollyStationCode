///WEREWOLF
/obj/item/bodypart/head/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	burn_modifier = 0.9
	brute_modifier = 0.7
	unarmed_attack_verb = "bite"
	grappled_attack_verb = "maul"
	unarmed_attack_effect = ATTACK_EFFECT_BITE
	unarmed_attack_sound = 'sound/weapons/bite.ogg'
	unarmed_miss_sound = 'sound/weapons/bite.ogg'
	unarmed_damage_low = 30
	unarmed_damage_high = 35
	unarmed_effectiveness = 30
	dmg_overlay_type = null
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR

/obj/item/bodypart/head/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color

/obj/item/bodypart/chest/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	is_dimorphic = TRUE
	should_draw_greyscale = TRUE
	burn_modifier = 0.9
	brute_modifier = 0.7
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_NO_JUMPSUIT, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE)
	wing_types = NONE

/obj/item/bodypart/chest/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color


/obj/item/bodypart/arm/left/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	unarmed_damage_low = 17
	unarmed_damage_high = 23
	unarmed_effectiveness = 15
	burn_modifier = 0.9
	brute_modifier = 0.7
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)


/obj/item/bodypart/arm/left/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color


/obj/item/bodypart/arm/right/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	unarmed_attack_verb = "slash"
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	unarmed_damage_low = 17
	unarmed_damage_high = 23
	unarmed_effectiveness = 15
	burn_modifier = 0.9
	brute_modifier = 0.7
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color


/obj/item/bodypart/leg/left/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	burn_modifier = 0.9
	brute_modifier = 0.7
	speed_modifier = -0.1
	dmg_overlay_type = null
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color

/obj/item/bodypart/leg/right/werewolf
	limb_id = SPECIES_WEREWOLF
	icon_greyscale = 'maplestation_modules/icons/mob/werewolf_parts_greyscale.dmi'
	should_draw_greyscale = TRUE
	burn_modifier = 0.9
	brute_modifier = 0.7
	speed_modifier = -0.1
	dmg_overlay_type = null
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/werewolf/update_limb(dropping_limb, is_creating)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/wolf = owner
		species_color = wolf.hair_color
