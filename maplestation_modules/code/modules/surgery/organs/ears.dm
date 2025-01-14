/obj/item/organ/internal/ears/cat/cybernetic
	name = "cybernetic cat ears"
	desc = "Replacement cat ears that are better than the original model. You're getting closer to becoming the ultimate creature."
	icon = 'maplestation_modules/icons/obj/clothing/hats.dmi'
	icon_state = "cyber_kitty"
	damage_multiplier = 1.5 //slightly better than regular cat ears

/obj/item/organ/internal/ears/cat/cybernetic/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = "Cybernetic Cat"
		ear_owner.update_body()

/obj/item/organ/internal/ears/cat/cybernetic/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = "None"
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()

/obj/item/organ/internal/ears/cat/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(40 /  severity)

/datum/sprite_accessory/ears/cat/cyber
	name = "Cybernetic Cat"
	icon_state = "catcyber"
	icon = 'maplestation_modules/icons/mob/mutant_bodyparts.dmi'
	locked = TRUE

/obj/item/organ/internal/ears/cat/werewolf
	name = "wolf ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "kitty"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

/obj/item/organ/internal/ears/cat/werewolf/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = "Werewolf"
		ear_owner.update_body()
		ADD_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cat/werewolf/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		ear_owner.dna.features["ears"] = "None"
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()
		REMOVE_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/datum/sprite_accessory/ears/werewolf
	name = "Werewolf"
	icon_state = "werewolf"
	icon = 'maplestation_modules/icons/mob/mutant_bodyparts.dmi'
	locked = TRUE
	hasinner = TRUE
	color_src = HAIR_COLOR
