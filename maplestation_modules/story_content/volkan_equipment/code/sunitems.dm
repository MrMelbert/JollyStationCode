/*
 * # Stuff for the beach!
 * Volkan has 0 pigment, so the sun damages him a lot IC.
 * His synth avatar also has this flaw, mainly due to the type of synthflesh used. He made it too damn realistic.
 * As a result, have items that help with dealing with the sun!
 */

///sunscreen, does nothing for now but is cool for flavor.
/obj/item/sunscreen
	name = "generic sunscreen"
	desc = "A generic sunscreen product. Cream based application. It is labeled SPF 30"
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cosmetic.dmi' //TODO: replace
	icon_state = "dyespray" //TODO: replace
	///How long it takes before sunscreen runs out in minutes
	var/reaplication_time = 30
	///The sunscreen's SPF rating.
	var/spf = 30

/obj/item/sunscreen/nanotrasen
	name = "Nanotrasen sunscreen"
	desc = "A Nanotrasen sunscreen product. Cream based application. It is labeled SPF 50"
	icon = 'icons/obj/cosmetic.dmi' //TODO: replace
	icon_state = "dyespray" //TODO: replace
	spf = 50

/obj/item/sunscreen/volkan
	name = "strange sunscreen"
	desc = "A sunscreen product in a metal container. It seems to have a high SPF rating."
	icon = 'icons/obj/cosmetic.dmi' //TODO: replace
	icon_state = "dyespray" //TODO: replace
	spf = 50

/obj/item/sunscreen/attack_self(mob/user)
	apply(user, user)

/obj/item/sunscreen/pre_attack(atom/target, mob/living/user, params)
	apply(target, user)
	return ..()

/**
 * Applies sunscreen to a mob.
 *
 * Arguments:
 * * target - The mob who we will apply the sunscreen to.
 */
/obj/item/sunscreen/proc/apply(mob/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	to_chat(user, span_notice("You start applying the sunscreen..."))
