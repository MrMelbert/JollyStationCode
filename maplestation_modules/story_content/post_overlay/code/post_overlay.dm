/datum/action/innate/story_post_overlay
	name = "Toggle Post Overlay"
	button_icon = 'icons/obj/wizard.dmi' //Not making a sprite for something people won't see, so fireball because it looks like a generic soul.
	button_icon_state = "fireball"

/datum/action/innate/story_post_overlay/Activate()
	var/mob/living/carbon/human/user = owner
	var/mutable_appearance/overlay = mutable_appearance('maplestation_modules/story_content/post_overlay/icons/post_overlay.dmi', "post_overlay", -HALO_LAYER)
	user.overlays_standing[HALO_LAYER] = overlay //using the halo layer because too lazy to see if there are better layers for something that wont ever conflict
	user.apply_overlay(HALO_LAYER)
	active = TRUE

/datum/action/innate/story_post_overlay/Deactivate()
	var/mob/living/carbon/human/user = owner
	user.remove_overlay(HALO_LAYER) //Technically removes cult halo, but this is on a character that's aligned with the clock cult anyway
	user.update_body()
	active = FALSE

/obj/item/story_post_overlay_granter //Just an item to make getting the overlay easy.
	name = "Post Overlay Granter"
	desc = "If you have this, either an admin wants to do something wacky or something seriously wrong has happened."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "duffelcurse"
	inhand_icon_state = "duffelcurse"

/obj/item/story_post_overlay_granter/attack_self(mob/user)
	var/datum/action/innate/story_post_overlay/overlay_action = new(user)
	overlay_action.Grant(user)
	qdel(src)
